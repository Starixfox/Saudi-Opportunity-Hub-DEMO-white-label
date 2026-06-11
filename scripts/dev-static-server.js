#!/usr/bin/env node
/* Tiny static file server for local preview.
   Replaces `python -m http.server`, which reproducibly stalled
   mid-stream on this repo's large files (index.html is ~900 KB; the
   272 KB legacy-app.css had the same issue — see the old XHR-injection
   workaround). Node streams with explicit Content-Length don't stall.

   Usage: node scripts/dev-static-server.js [port] [rootDir]
   Defaults: port 5181, repo root (one level up from this script). */
'use strict';

const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT = parseInt(process.argv[2], 10) || 5181;
const ROOT = path.resolve(process.argv[3] || path.join(__dirname, '..'));

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css':  'text/css; charset=utf-8',
  '.js':   'text/javascript; charset=utf-8',
  '.mjs':  'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg':  'image/svg+xml',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.ico':  'image/x-icon',
  '.mp4':  'video/mp4',
  '.webm': 'video/webm',
  '.woff': 'font/woff',
  '.woff2':'font/woff2',
  '.txt':  'text/plain; charset=utf-8',
  '.xml':  'application/xml',
  '.webmanifest': 'application/manifest+json',
  '.pdf':  'application/pdf',
  '.csv':  'text/csv; charset=utf-8',
  '.sql':  'text/plain; charset=utf-8',
  '.md':   'text/plain; charset=utf-8'
};

const server = http.createServer((req, res) => {
  let urlPath;
  try {
    urlPath = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  } catch (e) {
    res.writeHead(400); res.end('Bad request'); return;
  }
  if (urlPath.endsWith('/')) urlPath += 'index.html';

  const filePath = path.join(ROOT, urlPath);
  /* Path-traversal guard: resolved target must stay inside ROOT. */
  if (!filePath.startsWith(ROOT)) { res.writeHead(403); res.end('Forbidden'); return; }

  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) { res.writeHead(404); res.end('Not found'); return; }
    res.writeHead(200, {
      'Content-Type': MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream',
      'Content-Length': stat.size,
      'Cache-Control': 'no-store'
    });
    if (req.method === 'HEAD') { res.end(); return; }
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, () => {
  console.log('[dev-static-server] serving ' + ROOT + ' on http://localhost:' + PORT);
});
