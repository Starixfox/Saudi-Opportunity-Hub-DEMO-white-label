#!/usr/bin/env node
/**
 * Bump `color: rgba(255, 255, 255, X)` declarations where X is dim (≤ 0.65)
 * to brighter, AA-comfortable values. Only touches `color:` — borders and
 * backgrounds at the same alpha stay untouched.
 *
 * Alpha mapping (output ≥ AA on dark surface tokens):
 *   0.40 → 0.65   (was 3.0:1, becomes 5.6:1)
 *   0.45 → 0.65
 *   0.50 → 0.70   (was 3.85:1, becomes 6.5:1)
 *   0.55 → 0.72
 *   0.60 → 0.78   (was 5.0:1, becomes 8.5:1)
 *   0.65 → 0.80   (was 5.5:1, becomes 9.0:1)
 *   0.70 → 0.85   (was 6.5:1, becomes 10:1)
 *
 * Higher alphas (0.85+) stay where they are — already very bright.
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const FILES = [
  'assets/polish-overrides.css',
  'assets/legacy-app.css',
  'assets/components.css',
  'index.html',
];

// Map of old alpha → new alpha. Only these alphas get bumped.
const ALPHA_MAP = {
  '0.40': '0.65',
  '0.45': '0.65',
  '0.50': '0.70',
  '0.55': '0.72',
  '0.60': '0.78',
  '0.65': '0.80',
  '0.70': '0.85',
};

let totalReplacements = 0;

// Match: color: rgba(255, 255, 255, 0.X) — captures the alpha
const COLOR_RE =
  /(\bcolor\s*:\s*rgba\(\s*255\s*,\s*255\s*,\s*255\s*,\s*)(0\.\d{1,2})(\s*\))/g;

for (const rel of FILES) {
  const file = path.join(ROOT, rel);
  let src = fs.readFileSync(file, 'utf8');
  const before = src;
  let fileCount = 0;

  src = src.replace(COLOR_RE, (_full, before, alpha, after) => {
    // Normalize alpha (strip trailing zero, allow 0.4 → 0.40 lookup)
    const norm = alpha.length === 3 ? alpha + '0' : alpha;
    const next = ALPHA_MAP[norm];
    if (!next) return _full;
    fileCount++;
    return before + next + after;
  });

  if (src !== before) {
    fs.writeFileSync(file, src, 'utf8');
    console.log(`${rel}: ${fileCount} replacements`);
    totalReplacements += fileCount;
  } else {
    console.log(`${rel}: no changes`);
  }
}

console.log(`\nTotal: ${totalReplacements} replacements across ${FILES.length} files.`);
