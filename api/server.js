const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;
const NODE_ENV = process.env.NODE_ENV || 'development';

app.disable('x-powered-by');
app.set('trust proxy', 1);

// ─── CORS ──────────────────────────────────────────────────────
// Accept a comma-separated allowlist via ALLOWED_ORIGINS or CORS_ORIGINS env.
// In production with no allowlist set, default to permissive (demo); set the
// var to lock it down.
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS || process.env.CORS_ORIGINS || '')
  .split(',')
  .map(s => s.trim())
  .filter(Boolean);

app.use(cors({
  origin(origin, cb) {
    if (!ALLOWED_ORIGINS.length) return cb(null, true);
    if (!origin) return cb(null, true);                    // server-to-server / curl
    if (ALLOWED_ORIGINS.includes(origin)) return cb(null, true);
    return cb(new Error('Origin not allowed by CORS'));
  },
  methods: ['GET', 'HEAD', 'OPTIONS'],
  maxAge: 86400,
}));

// ─── Security headers (manual, no extra deps) ──────────────────
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader('Permissions-Policy', 'geolocation=(), camera=(), microphone=(), payment=()');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
  res.setHeader('Cache-Control', 'public, max-age=60');
  next();
});

// ─── Request logging (concise, no body) ────────────────────────
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - start;
    const ip = req.ip || req.headers['x-forwarded-for'] || req.socket.remoteAddress || '-';
    console.log(`${new Date().toISOString()} ${ip} ${req.method} ${req.originalUrl} ${res.statusCode} ${ms}ms`);
  });
  next();
});

// ─── In-memory token-bucket rate limiter ───────────────────────
const RATE_LIMIT_WINDOW_MS = 60 * 1000;
const RATE_LIMIT_MAX = parseInt(process.env.RATE_LIMIT_MAX, 10) || 60;
const buckets = new Map();

setInterval(() => {
  const cutoff = Date.now() - RATE_LIMIT_WINDOW_MS * 2;
  for (const [key, bucket] of buckets) {
    if (bucket.resetAt < cutoff) buckets.delete(key);
  }
}, RATE_LIMIT_WINDOW_MS).unref();

app.use('/api', (req, res, next) => {
  const key = req.ip || req.headers['x-forwarded-for'] || 'unknown';
  const now = Date.now();
  let bucket = buckets.get(key);
  if (!bucket || bucket.resetAt < now) {
    bucket = { count: 0, resetAt: now + RATE_LIMIT_WINDOW_MS };
    buckets.set(key, bucket);
  }
  bucket.count++;
  const remaining = Math.max(0, RATE_LIMIT_MAX - bucket.count);
  res.setHeader('X-RateLimit-Limit', String(RATE_LIMIT_MAX));
  res.setHeader('X-RateLimit-Remaining', String(remaining));
  res.setHeader('X-RateLimit-Reset', String(Math.ceil(bucket.resetAt / 1000)));
  if (bucket.count > RATE_LIMIT_MAX) {
    res.setHeader('Retry-After', String(Math.ceil((bucket.resetAt - now) / 1000)));
    return res.status(429).json({ error: 'Too many requests', retryAfter: Math.ceil((bucket.resetAt - now) / 1000) });
  }
  next();
});

// ─── Supabase config ───────────────────────────────────────────
const SUPABASE_URL =
  process.env.SUPABASE_URL || 'https://dshrbbnjahjcwxzvzygh.supabase.co';
const SUPABASE_ANON_KEY =
  process.env.SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzaHJiYm5qYWhqY3d4enZ6eWdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0ODE3OTgsImV4cCI6MjA5NDA1Nzc5OH0.OpUGgfL91m7STsZpE6fnX281KN_Ge8oytR-2lM-3qTo';

if (NODE_ENV === 'production' && (!process.env.SUPABASE_URL || !process.env.SUPABASE_ANON_KEY)) {
  console.error('FATAL: SUPABASE_URL and SUPABASE_ANON_KEY must be set in production.');
  process.exit(1);
}

// ─── In-memory cache ───────────────────────────────────────────
let opportunities = [];
let lastLoadedAt = 0;
let isLoading = false;
let loadPromise = null;
const CACHE_TTL_MS = 5 * 60 * 1000;

async function loadData() {
  const pageSize = 1000;
  let offset = 0;
  const all = [];

  while (true) {
    const url = `${SUPABASE_URL}/rest/v1/opportunities?select=*&order=id.asc&limit=${pageSize}&offset=${offset}`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 15000);
    let res;
    try {
      res = await fetch(url, {
        headers: {
          apikey: SUPABASE_ANON_KEY,
          Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        },
        signal: controller.signal,
      });
    } finally {
      clearTimeout(timer);
    }
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Supabase HTTP ${res.status}: ${body.slice(0, 200)}`);
    }
    const batch = await res.json();
    all.push(...batch);
    if (batch.length < pageSize) break;
    offset += pageSize;
    if (offset > 100000) break;  // hard safety cap
  }

  opportunities = all;
  lastLoadedAt = Date.now();
  console.log(`Loaded ${opportunities.length} opportunities from Supabase`);
}

// Coalesce concurrent refresh attempts so a thundering herd hits Supabase once.
async function ensureFresh() {
  const stale = !opportunities.length || Date.now() - lastLoadedAt > CACHE_TTL_MS;
  if (!stale) return;
  if (isLoading && loadPromise) return loadPromise;
  isLoading = true;
  loadPromise = loadData()
    .catch(err => {
      console.error('Refresh failed:', err.message);
      if (!opportunities.length) throw err;
    })
    .finally(() => {
      isLoading = false;
      loadPromise = null;
    });
  return loadPromise;
}

// ─── Input validation helpers ──────────────────────────────────
function sanitize(value, maxLen = 100) {
  if (typeof value !== 'string') return '';
  return value.replace(/[\x00-\x1f\x7f]/g, '').slice(0, maxLen).trim();
}

function clampInt(value, min, max, fallback) {
  const n = parseInt(value, 10);
  if (Number.isNaN(n)) return fallback;
  return Math.min(max, Math.max(min, n));
}

// Middleware: ensure data loaded before any /api/* request (except health)
app.use('/api', async (req, res, next) => {
  if (req.path === '/health') return next();
  try {
    await ensureFresh();
    next();
  } catch (err) {
    res.status(503).json({ error: 'Data temporarily unavailable', detail: err.message });
  }
});

// ─── GET /api/opportunities ────────────────────────────────────
app.get('/api/opportunities', (req, res) => {
  let results = opportunities;

  const q = sanitize(req.query.q, 200);
  if (q) {
    const needle = q.toLowerCase();
    results = results.filter(o =>
      (o.title && o.title.toLowerCase().includes(needle)) ||
      (o.sponsor_institution && o.sponsor_institution.toLowerCase().includes(needle)) ||
      (o.description_short && o.description_short.toLowerCase().includes(needle))
    );
  }

  const sector = sanitize(req.query.sector).toLowerCase();
  if (sector) {
    results = results.filter(o =>
      Array.isArray(o.sectors) && o.sectors.some(s => s.toLowerCase() === sector)
    );
  }

  const region = sanitize(req.query.region).toLowerCase();
  if (region) {
    results = results.filter(o =>
      o.eligibility_region && o.eligibility_region.toLowerCase().includes(region)
    );
  }

  const type = sanitize(req.query.type).toLowerCase();
  if (type) {
    results = results.filter(o => o.type && o.type.toLowerCase() === type);
  }

  const status = sanitize(req.query.status).toLowerCase();
  if (status) {
    results = results.filter(o => o.status && o.status.toLowerCase() === status);
  }

  const profile = sanitize(req.query.profile).toLowerCase();
  if (profile) {
    results = results.filter(o =>
      Array.isArray(o.profiles) && o.profiles.some(p => p.toLowerCase() === profile)
    );
  }

  const sort = sanitize(req.query.sort, 30).toLowerCase();
  if (sort) {
    results = results.slice();
    if (sort === 'newest')      results.sort((a, b) => String(b.last_verified || b.created_at || '').localeCompare(String(a.last_verified || a.created_at || '')));
    else if (sort === 'oldest') results.sort((a, b) => String(a.last_verified || a.created_at || '').localeCompare(String(b.last_verified || b.created_at || '')));
    else if (sort === 'title')  results.sort((a, b) => String(a.title || '').localeCompare(String(b.title || '')));
  }

  const page = clampInt(req.query.page, 1, 10000, 1);
  const limit = clampInt(req.query.limit, 1, 100, 20);
  const total = results.length;
  const start = (page - 1) * limit;
  const paged = results.slice(start, start + limit);

  res.json({
    total,
    page,
    limit,
    pages: Math.ceil(total / limit),
    results: paged,
  });
});

// ─── GET /api/opportunities/:id ────────────────────────────────
app.get('/api/opportunities/:id', (req, res) => {
  const id = sanitize(req.params.id, 50);
  if (!id || !/^[A-Za-z0-9_\-]+$/.test(id)) {
    return res.status(400).json({ error: 'Invalid id format' });
  }
  const opp = opportunities.find(o => o.id === id);
  if (!opp) return res.status(404).json({ error: 'Opportunity not found', id });
  res.json(opp);
});

// ─── GET /api/stats ────────────────────────────────────────────
app.get('/api/stats', (req, res) => {
  const total = opportunities.length;
  const statusCounts = {};
  const typeCounts = {};
  const regionCounts = {};
  const sectorCounts = {};

  opportunities.forEach(o => {
    const s = o.status || 'unknown';
    statusCounts[s] = (statusCounts[s] || 0) + 1;
    const t = o.type || 'unknown';
    typeCounts[t] = (typeCounts[t] || 0) + 1;
    const r = o.eligibility_region || 'unknown';
    regionCounts[r] = (regionCounts[r] || 0) + 1;
    if (Array.isArray(o.sectors)) {
      o.sectors.forEach(sec => { sectorCounts[sec] = (sectorCounts[sec] || 0) + 1; });
    }
  });

  const lastVerifiedDates = opportunities.map(o => o.last_verified).filter(Boolean).sort();
  const lastUpdatedDates = opportunities.map(o => o.updated_at || o.last_updated).filter(Boolean).sort();

  res.json({
    total,
    byStatus: statusCounts,
    byType: typeCounts,
    byRegion: regionCounts,
    bySector: sectorCounts,
    lastVerified: lastVerifiedDates.length ? lastVerifiedDates[lastVerifiedDates.length - 1] : null,
    lastUpdated: lastUpdatedDates.length ? lastUpdatedDates[lastUpdatedDates.length - 1] : null,
    cacheAge: lastLoadedAt ? Math.round((Date.now() - lastLoadedAt) / 1000) : null,
    dataSource: 'supabase',
  });
});

// ─── GET /api/meta ─────────────────────────────────────────────
app.get('/api/meta', (req, res) => {
  const sectorsSet = new Set();
  const profilesSet = new Set();
  const typesSet = new Set();
  const statusesSet = new Set();
  const regionsSet = new Set();

  opportunities.forEach(o => {
    if (Array.isArray(o.sectors)) o.sectors.forEach(s => sectorsSet.add(s));
    if (Array.isArray(o.profiles)) o.profiles.forEach(p => profilesSet.add(p));
    if (o.type) typesSet.add(o.type);
    if (o.status) statusesSet.add(o.status);
    if (o.eligibility_region) regionsSet.add(o.eligibility_region);
  });

  res.json({
    sectors: [...sectorsSet].sort(),
    profiles: [...profilesSet].sort(),
    types: [...typesSet].sort(),
    statuses: [...statusesSet].sort(),
    regions: [...regionsSet].sort(),
  });
});

// ─── GET /api/health ───────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    loaded: opportunities.length,
    lastLoadedAt: lastLoadedAt ? new Date(lastLoadedAt).toISOString() : null,
    uptime: Math.round(process.uptime()),
    env: NODE_ENV,
    dataSource: 'supabase',
  });
});

// ─── 404 fallback for /api/* ───────────────────────────────────
app.use('/api', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found', path: req.originalUrl });
});

// ─── Root: tiny landing JSON ───────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    name: 'Saudi Opportunity Hub API',
    version: '1.1.0',
    docs: '/api.html',
    endpoints: ['/api/opportunities', '/api/opportunities/:id', '/api/stats', '/api/meta', '/api/health'],
  });
});

// ─── Global error handler (last resort) ────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err && err.stack ? err.stack : err);
  if (res.headersSent) return next(err);
  res.status(500).json({ error: 'Internal server error' });
});

// ─── Start server ──────────────────────────────────────────────
function startListening(message) {
  const server = app.listen(PORT, () => {
    console.log(`\n  Saudi Opportunity Hub API running at:`);
    console.log(`  Local:  http://localhost:${PORT}`);
    console.log(`  Env:    ${NODE_ENV}`);
    console.log(`  Data:   Supabase (${SUPABASE_URL})`);
    if (message) console.log(`  Note:   ${message}`);
    console.log(`\n  Endpoints:`);
    console.log(`  GET /api/opportunities`);
    console.log(`  GET /api/opportunities/:id`);
    console.log(`  GET /api/stats`);
    console.log(`  GET /api/meta`);
    console.log(`  GET /api/health\n`);
  });

  // Background refresh — keeps the cache warm even if no requests come in.
  const refreshInterval = setInterval(() => {
    loadData().catch(err => console.error('Background refresh failed:', err.message));
  }, CACHE_TTL_MS);

  // Graceful shutdown
  function shutdown(signal) {
    console.log(`\n${signal} received — shutting down gracefully...`);
    clearInterval(refreshInterval);
    server.close(err => {
      if (err) { console.error('Error during shutdown:', err); process.exit(1); }
      console.log('HTTP server closed.');
      process.exit(0);
    });
    setTimeout(() => process.exit(1), 10000).unref();
  }
  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

loadData()
  .then(() => startListening())
  .catch(err => {
    console.error('FATAL: initial Supabase load failed:', err.message);
    // Still start the server so /api/health works & retries happen on demand.
    startListening('dataset empty — will retry on first request');
  });
