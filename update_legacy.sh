#!/usr/bin/env bash
set -euo pipefail

echo "→ Verifica file..."
for f in \
  "it/works/a-mothers-legacy.html" \
  "en/works/a-mothers-legacy.html" \
  "de/works/a-mothers-legacy.html" \
  "it/catalog.html" \
  "de/catalog.html"
do
  [[ -f "$f" ]] || { echo "Manca: $f"; exit 1; }
done

echo "→ IT: titolo + nota originale + formato IT/EN/DE"
sed -i 's/<h1 class="work-title">A Mother’s Legacy<\/h1>/<h1 class="work-title">L’eredità di una madre<\/h1>\n      <p class="work-original muted">Titolo originale: <em>A Mother’s Legacy<\/em><\/p>/' "it/works/a-mothers-legacy.html"
sed -i 's/Edizione IT\/EN/Edizione IT\/EN\/DE/' "it/works/a-mothers-legacy.html"

echo "→ EN: solo formato IT/EN/DE (nessuna nota Original Title)"
sed -i 's/IT\/EN edition/IT\/EN\/DE edition/' "en/works/a-mothers-legacy.html"

echo "→ DE: titolo + nota Originaltitel + formato IT/EN/DE"
sed -i 's/<h1 class="work-title">A Mother’s Legacy<\/h1>/<h1 class="work-title">Das Erbe einer Mutter<\/h1>\n      <p class="work-original muted">Originaltitel: <em>A Mother’s Legacy<\/em><\/p>/' "de/works/a-mothers-legacy.html"
sed -i 's/IT\/EN Ausgabe/IT\/EN\/DE Ausgabe/' "de/works/a-mothers-legacy.html"

echo "→ Cataloghi: link label localizzati"
sed -i 's@href="works/a-mothers-legacy\.html">[^<]*@href="works/a-mothers-legacy.html">L’eredità di una madre@' "it/catalog.html"
sed -i 's@href="works/a-mothers-legacy\.html">[^<]*@href="works/a-mothers-legacy.html">Das Erbe einer Mutter@' "de/catalog.html"

echo "→ Git add/commit/push"
git add -A
git commit -m "Localize A Mother’s Legacy (IT/DE titles + IT/EN/DE format) and catalogs"
git push

echo "✅ Fatto! Se non vedi subito le modifiche su GitHub Pages, fai hard refresh (Ctrl+F5)."
