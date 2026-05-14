const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Restrict CORS to an allow-list in production, allow all in dev for easier debugging.
const CORS_ORIGINS = (process.env.CORS_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);
if (NODE_ENV === 'production' && CORS_ORIGINS.length) {
  app.use(cors({ origin: CORS_ORIGINS }));
} else {
  app.use(cors());
}

// Trust the first proxy when running behind a reverse proxy / PaaS load balancer.
app.set('trust proxy', 1);
app.disable('x-powered-by');

// ─── Supabase config ───
// Defaults are baked in for the demo project; production deploys MUST supply env vars.
const SUPABASE_URL =
  process.env.SUPABASE_URL || 'https://dshrbbnjahjcwxzvzygh.supabase.co';
const SUPABASE_ANON_KEY =
  process.env.SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzaHJiYm5qYWhqY3d4enZ6eWdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0ODE3OTgsImV4cCI6MjA5NDA1Nzc5OH0.OpUGgfL91m7STsZpE6fnX281KN_Ge8oytR-2lM-3qTo';

if (NODE_ENV === 'production' && (!process.env.SUPABASE_URL || !process.env.SUPABASE_ANON_KEY)) {
  console.error('FATAL: SUPABASE_URL and SUPABASE_ANON_KEY must be set in production.');
  process.exit(1);
}

// In-memory cache (refreshed periodically)
let opportunities = [];
let lastLoadedAt = 0;
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

async function loadData() {
  // Page through PostgREST (max 1000 per request)
  const pageSize = 1000;
  let offset = 0;
  const all = [];

  while (true) {
    const url = `${SUPABASE_URL}/rest/v1/opportunities?select=*&order=id.asc&limit=${pageSize}&offset=${offset}`;
    const res = await fetch(url, {
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      },
    });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Supabase HTTP ${res.status}: ${body.slice(0, 200)}`);
    }
    const batch = await res.json();
    all.push(...batch);
    if (batch.length < pageSize) break;
    offset += pageSize;
  }

  opportunities = all;
  lastLoadedAt = Date.now();
  console.log(`Loaded ${opportunities.length} opportunities from Supabase`);
}

async function ensureFresh() {
  if (!opportunities.length || Date.now() - lastLoadedAt > CACHE_TTL_MS) {
    try {
      await loadData();
    } catch (err) {
      // If we already have a cached copy, keep serving it; else surface the error.
      console.error('Refresh failed:', err.message);
      if (!opportunities.length) throw err;
    }
  }
}

// Middleware: ensure data loaded before any /api/* request
app.use('/api', async (req, res, next) => {
  try {
    await ensureFresh();
    next();
  } catch (err) {
    res.status(503).json({ error: 'Data temporarily unavailable', detail: err.message });
  }
});

// ─── GET /api/opportunities ───
app.get('/api/opportunities', (req, res) => {
  let results = [...opportunities];

  // Text search (q)
  if (req.query.q) {
    const q = req.query.q.toLowerCase();
    results = results.filter(o =>
      (o.title && o.title.toLowerCase().includes(q)) ||
      (o.sponsor_institution && o.sponsor_institution.toLowerCase().includes(q)) ||
      (o.description_short && o.description_short.toLowerCase().includes(q))
    );
  }

  // Filter: sector
  if (req.query.sector) {
    const sector = req.query.sector.toLowerCase();
    results = results.filter(o =>
      Array.isArray(o.sectors) && o.sectors.some(s => s.toLowerCase() === sector)
    );
  }

  // Filter: region
  if (req.query.region) {
    const region = req.query.region.toLowerCase();
    results = results.filter(o =>
      o.eligibility_region && o.eligibility_region.toLowerCase().includes(region)
    );
  }

  // Filter: type
  if (req.query.type) {
    const type = req.query.type.toLowerCase();
    results = results.filter(o =>
      o.type && o.type.toLowerCase() === type
    );
  }

  // Filter: status
  if (req.query.status) {
    const status = req.query.status.toLowerCase();
    results = results.filter(o =>
      o.status && o.status.toLowerCase() === status
    );
  }

  // Filter: profile
  if (req.query.profile) {
    const profile = req.query.profile.toLowerCase();
    results = results.filter(o =>
      Array.isArray(o.profiles) && o.profiles.some(p => p.toLowerCase() === profile)
    );
  }

  // Pagination
  const page = Math.max(1, parseInt(req.query.page) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
  const total = results.length;
  const start = (page - 1) * limit;
  const paged = results.slice(start, start + limit);

  res.json({
    total,
    page,
    limit,
    results: paged
  });
});

// ─── GET /api/opportunities/:id ───
app.get('/api/opportunities/:id', (req, res) => {
  const opp = opportunities.find(o => o.id === req.params.id);
  if (!opp) {
    return res.status(404).json({ error: 'Opportunity not found', id: req.params.id });
  }
  res.json(opp);
});

// ─── GET /api/stats ───
app.get('/api/stats', (req, res) => {
  const total = opportunities.length;

  const statusCounts = {};
  opportunities.forEach(o => {
    const s = o.status || 'unknown';
    statusCounts[s] = (statusCounts[s] || 0) + 1;
  });

  const typeCounts = {};
  opportunities.forEach(o => {
    const t = o.type || 'unknown';
    typeCounts[t] = (typeCounts[t] || 0) + 1;
  });

  const regionCounts = {};
  opportunities.forEach(o => {
    const r = o.eligibility_region || 'unknown';
    regionCounts[r] = (regionCounts[r] || 0) + 1;
  });

  // Freshness signals (driven by Supabase)
  const lastVerifiedDates = opportunities
    .map(o => o.last_verified)
    .filter(Boolean)
    .sort();
  const lastUpdatedDates = opportunities
    .map(o => o.updated_at || o.last_updated)
    .filter(Boolean)
    .sort();

  res.json({
    total,
    byStatus: statusCounts,
    byType: typeCounts,
    byRegion: regionCounts,
    lastVerified: lastVerifiedDates.length ? lastVerifiedDates[lastVerifiedDates.length - 1] : null,
    lastUpdated: lastUpdatedDates.length ? lastUpdatedDates[lastUpdatedDates.length - 1] : null,
    dataSource: 'supabase'
  });
});

// ─── GET /api/meta ───
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
    regions: [...regionsSet].sort()
  });
});

// ─── Health check ───
app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    loaded: opportunities.length,
    lastLoadedAt: lastLoadedAt ? new Date(lastLoadedAt).toISOString() : null,
    dataSource: 'supabase'
  });
});

// ─── Start server ───
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

  // Graceful shutdown so in-flight requests finish.
  const shutdown = signal => {
    console.log(`\n${signal} received — shutting down gracefully.`);
    clearInterval(refreshInterval);
    server.close(err => {
      if (err) { console.error('Error during shutdown:', err); process.exit(1); }
      process.exit(0);
    });
    // Hard exit if it takes too long.
    setTimeout(() => process.exit(1), 10000).unref();
  };
  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT',  () => shutdown('SIGINT'));
}

loadData()
  .then(() => startListening())
  .catch(err => {
    console.error('FATAL: initial Supabase load failed:', err.message);
    // Still start the server so /api/health works & retries happen on demand.
    startListening(`dataset empty — will retry on first request`);
  });
