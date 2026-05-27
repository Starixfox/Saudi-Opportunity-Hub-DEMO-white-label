#!/usr/bin/env node
/**
 * One-shot script: replace every hard-coded Saudi-green / legacy-tenant
 * brand colour in legacy-app.css and polish-overrides.css with the
 * canonical gold tokens (or, where appropriate, var(--accent) /
 * var(--accent-hover) so the colour follows the theme).
 *
 * Run via: node scripts/unify-to-gold.js
 *
 * Safe to re-run — it's idempotent because every replacement target is a
 * literal that the script removes on the first pass.
 *
 * Semantic colours (status-open, success, error, warning) are
 * INTENTIONALLY LEFT ALONE. Only brand-accent paints get unified.
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const FILES = [
  'assets/legacy-app.css',
  'assets/polish-overrides.css',
  'index.html',
  'login.html',
  'contact.html',
  'reset-password.html',
  'api.html',
  '404.html',
];

// Brand-green hex literals → token references for CSS, or gold hex for
// contexts where var() can't be used (HTML attributes, SVG fills, JS
// string literals, inline styles in JS template literals).
//
// Status greens #10b981 and #16a34a are deliberately NOT in this map.
const HEX_REPLACEMENTS_CSS = [
  // Saudi green (light + dark variants used as brand accent)
  [/#006C35\b/g, 'var(--accent)'],
  [/#006c35\b/g, 'var(--accent)'],
  [/#005228\b/g, 'var(--accent-hover)'],
  [/#005229\b/g, 'var(--accent-hover)'],
  [/#003c1d\b/g, 'var(--accent-pressed, var(--accent-hover))'],
  [/#003C1D\b/g, 'var(--accent-pressed, var(--accent-hover))'],
  [/#00a651\b/g, 'var(--accent)'],
  [/#00A651\b/g, 'var(--accent)'],
  [/#00c460\b/g, 'var(--accent-hover)'],
  [/#00C460\b/g, 'var(--accent-hover)'],
  [/#007a3d\b/g, 'var(--accent)'],
  [/#007A3D\b/g, 'var(--accent)'],
  [/#006232\b/g, 'var(--accent-hover)'],
  // Legacy lifted-green from dark mode override
  [/#34d97b\b/g, 'var(--accent)'],
  [/#4ee08c\b/g, 'var(--accent-hover)'],
];

// For index.html: same literals, but converted to literal gold hex
// values (SVG fill="", meta theme-color content="", JS strings cannot
// use var()). Light-mode gold #C9A66B for primaries, lifted #e3bd6c for
// brighter dark-mode replacements.
const HEX_REPLACEMENTS_HTML = [
  [/#006C35\b/g, '#C9A66B'],
  [/#006c35\b/g, '#C9A66B'],
  [/#005228\b/g, '#a88947'],
  [/#005229\b/g, '#a88947'],
  [/#003c1d\b/g, '#876d36'],
  [/#003C1D\b/g, '#876d36'],
  [/#00a651\b/g, '#e3bd6c'],
  [/#00A651\b/g, '#e3bd6c'],
  [/#00c460\b/g, '#d4ab48'],
  [/#00C460\b/g, '#d4ab48'],
  [/#007a3d\b/g, '#C9A66B'],
  [/#007A3D\b/g, '#C9A66B'],
  [/#006232\b/g, '#a88947'],
  [/#34d97b\b/g, '#e3bd6c'],
  [/#4ee08c\b/g, '#d4ab48'],
];

// rgba(0,108,53,X) (Saudi green light) → rgba(201,166,107,X) (gold light)
// rgba(0,166,81,X)  (Saudi green dark)  → rgba(227,189,108,X) (gold dark lift)
//
// rgba(0, 166, 81, …) is ALSO used by status-open in dark mode. We do
// the swap anyway — the user has been clear they want every accent-coloured
// pixel to be gold across the platform. The semantic status palette
// (--color-success-500 = #10b981) is untouched, so true status colours
// (the rgba(16,185,129,X) family) keep their green semantics.
const RGBA_REPLACEMENTS = [
  // Saudi green light family
  [/rgba\(\s*0\s*,\s*108\s*,\s*53\s*,\s*([0-9.]+)\s*\)/g, 'rgba(201, 166, 107, $1)'],
  // Saudi green dark family
  [/rgba\(\s*0\s*,\s*166\s*,\s*81\s*,\s*([0-9.]+)\s*\)/g, 'rgba(227, 189, 108, $1)'],
  // Legacy light-mode green
  [/rgba\(\s*0\s*,\s*122\s*,\s*61\s*,\s*([0-9.]+)\s*\)/g, 'rgba(201, 166, 107, $1)'],
  // Mid green sometimes used
  [/rgba\(\s*0\s*,\s*140\s*,\s*70\s*,\s*([0-9.]+)\s*\)/g, 'rgba(201, 166, 107, $1)'],
  // Lifted dark-mode accent #34d97b = rgb(52, 217, 123)
  [/rgba\(\s*52\s*,\s*217\s*,\s*123\s*,\s*([0-9.]+)\s*\)/g, 'rgba(227, 189, 108, $1)'],
];

let totalReplacements = 0;

for (const rel of FILES) {
  const file = path.join(ROOT, rel);
  let src = fs.readFileSync(file, 'utf8');
  const before = src;
  let fileCount = 0;

  const hexMap = rel.endsWith('.html') ? HEX_REPLACEMENTS_HTML : HEX_REPLACEMENTS_CSS;
  for (const [re, to] of hexMap) {
    const matches = src.match(re);
    if (matches) {
      fileCount += matches.length;
      src = src.replace(re, to);
    }
  }
  for (const [re, to] of RGBA_REPLACEMENTS) {
    const matches = src.match(re);
    if (matches) {
      fileCount += matches.length;
      src = src.replace(re, to);
    }
  }

  if (src !== before) {
    fs.writeFileSync(file, src, 'utf8');
    console.log(`${rel}: ${fileCount} replacements`);
    totalReplacements += fileCount;
  } else {
    console.log(`${rel}: no changes`);
  }
}

console.log(`\nTotal: ${totalReplacements} replacements across ${FILES.length} files.`);
