#!/usr/bin/env bash
# Builds Arth_Product_and_Build_Report.pdf from the two Markdown documents.
# Needs pandoc and Google Chrome / Chromium. Run from the repo root or docs/.
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp -d)
strip() { awk 'BEGIN{y=0} NR==1&&/^---$/{y=1;next} y&&/^---$/{y=0;next} !y' "$1"; }
{
  strip ARTH_PRODUCT_OVERVIEW.md
  echo; echo
  strip ARTH_BUILD_TIMELINE.md
} > "$tmp/all.md"
commit=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
cat > "$tmp/before.html" <<HTML
<div class="cover">
  <div class="brand">Arth</div>
  <div class="tag">Privacy-first personal finance for India</div>
  <div class="title">Product overview &amp; build timeline</div>
  <div class="meta">$(date '+%d %B %Y') · repository commit ${commit}<br>
  App version 0.1.0 · database schema v17 · 443 automated tests</div>
</div>
HTML
pandoc "$tmp/all.md" -f markdown -t html5 -s --toc --toc-depth=2 \
  --metadata title="Arth — Product overview & build timeline" \
  --metadata pagetitle="Arth report" \
  -V title= -c "$(pwd)/report.css" --embed-resources \
  -B "$tmp/before.html" -o "$tmp/report.html"
chrome=$(command -v google-chrome-stable || command -v google-chrome || command -v chromium)
"$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$(pwd)/Arth_Product_and_Build_Report.pdf" "file://$tmp/report.html" 2>/dev/null
rm -rf "$tmp"
echo "Wrote $(pwd)/Arth_Product_and_Build_Report.pdf"
