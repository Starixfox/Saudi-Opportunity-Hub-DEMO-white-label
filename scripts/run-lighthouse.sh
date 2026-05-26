#!/usr/bin/env bash
# Run Lighthouse against the live Saudi Opportunity Hub URLs and write
# JSON + HTML reports to polish/lighthouse/.
#
# Requirements: Node, npx, and Chrome installed at the system default path.
# Closes issue #17 (Lighthouse baseline on the live URL).

set -e

BASE="${OH_BASE:-https://starixfox.github.io/Saudi-Opportunity-Hub-DEMO-white-label}"
OUT_DIR="${OH_LIGHTHOUSE_DIR:-polish/lighthouse}"

mkdir -p "$OUT_DIR"

run_lh() {
  local name="$1"
  local url="$2"
  echo "=== Lighthouse: $name ==="
  npx --yes lighthouse@12 \
    "$url" \
    --output=json --output=html \
    --output-path="${OUT_DIR}/${name}" \
    --chrome-flags="--headless --no-sandbox --disable-gpu" \
    --only-categories=performance,accessibility,best-practices,seo \
    --quiet
  echo ""
}

run_lh "login"    "${BASE}/login.html"
run_lh "showcase" "${BASE}/polish/showcase.html"

# Pretty-print the four scores from each report
echo "=== Summary ==="
for name in login showcase; do
  if [ -f "${OUT_DIR}/${name}.report.json" ]; then
    node -e "
      const r = require('./${OUT_DIR}/${name}.report.json');
      const c = r.categories;
      const a = r.audits;
      console.log('${name}');
      console.log('  Performance:    ' + Math.round(c.performance.score * 100));
      console.log('  Accessibility:  ' + Math.round(c.accessibility.score * 100));
      console.log('  Best Practices: ' + Math.round(c['best-practices'].score * 100));
      console.log('  SEO:            ' + Math.round(c.seo.score * 100));
      console.log('  LCP (ms):       ' + a['largest-contentful-paint'].numericValue.toFixed(0));
      console.log('  TBT (ms):       ' + a['total-blocking-time'].numericValue.toFixed(0));
      console.log('  CLS:            ' + a['cumulative-layout-shift'].numericValue.toFixed(4));
    "
  fi
done

echo ""
echo "Reports: ${OUT_DIR}/{login,showcase}.report.{html,json}"
