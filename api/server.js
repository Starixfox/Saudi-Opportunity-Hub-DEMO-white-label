const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3001;

// Enable CORS for all origins
app.use(cors());

// Load dataset
// Try local copy first, then fall back to parent directory
let opportunities = [];
const localPath = path.join(__dirname, 'opportunitiesData.json');
const parentPath = path.join(__dirname, '..', 'opportunitiesData.json');

if (fs.existsSync(localPath)) {
  opportunities = JSON.parse(fs.readFileSync(localPath, 'utf-8'));
} else if (fs.existsSync(parentPath)) {
  opportunities = JSON.parse(fs.readFileSync(parentPath, 'utf-8'));
} else {
  console.error('ERROR: opportunitiesData.json not found!');
  process.exit(1);
}

console.log(`Loaded ${opportunities.length} opportunities`);

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

  // Count by status
  const statusCounts = {};
  opportunities.forEach(o => {
    const s = o.status || 'unknown';
    statusCounts[s] = (statusCounts[s] || 0) + 1;
  });

  // Count by type
  const typeCounts = {};
  opportunities.forEach(o => {
    const t = o.type || 'unknown';
    typeCounts[t] = (typeCounts[t] || 0) + 1;
  });

  // Count by region
  const regionCounts = {};
  opportunities.forEach(o => {
    const r = o.eligibility_region || 'unknown';
    regionCounts[r] = (regionCounts[r] || 0) + 1;
  });

  res.json({
    total,
    byStatus: statusCounts,
    byType: typeCounts,
    byRegion: regionCounts
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

// ─── Start server ───
app.listen(PORT, () => {
  console.log(`\n  Saudi Opportunity Hub API running at:`);
  console.log(`  Local:  http://localhost:${PORT}`);
  console.log(`\n  Endpoints:`);
  console.log(`  GET /api/opportunities`);
  console.log(`  GET /api/opportunities/:id`);
  console.log(`  GET /api/stats`);
  console.log(`  GET /api/meta\n`);
});
