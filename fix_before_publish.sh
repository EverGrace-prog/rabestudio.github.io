#!/usr/bin/env bash
set -euo pipefail

echo "▶ Fix RABE STUDIO — paths & links for GitHub Pages"

# -------- helper sed (compat Windows Git Bash) --------
_sed() { sed -i 's|\r$||' "$1" 2>/dev/null || true; }
rpl()  { sed -i "s|$1|$2|g" "$3"; }

# -------- scope --------
ROOT="."
LANGS=("it" "en" "de")

# 0) Normalizza fine-riga CRLF→LF solo per .html
echo "• Normalize line endings"
find "$ROOT" -type f -name "*.html" -not -path "*/assets/*" -print0 | while IFS= read -r -d '' f; do _sed "$f"; done

# 1) File al livello lingua (es: it/index.html, it/catalog.html, it/vision.html, it/marketplace.html)
echo "• Fix assets paths in language root pages (../assets/…)"
for L in "${LANGS[@]}"; do
  for f in "$L"/*.html; do
    [ -e "$f" ] || continue
    rpl 'href="/assets/'  'href="../assets/'  "$f"
    rpl 'src="/assets/'   'src="../assets/'   "$f"
    # Se ci fossero ancora riferimenti assoluti a /it /en /de, rendili relativi
    rpl 'href="/it/' 'href="it/' "$ROOT/index.html" 2>/dev/null || true
    rpl 'href="/en/' 'href="en/' "$ROOT/index.html" 2>/dev/null || true
    rpl 'href="/de/' 'href="de/' "$ROOT/index.html" 2>/dev/null || true
  done
done

# 2) File dentro works/ (es: it/works/*.html) → due livelli: ../../assets/…
echo "• Fix assets paths in works pages (../../assets/…)"
for L in "${LANGS[@]}"; do
  for f in "$L/works/"*.html; do
    [ -e "$f" ] || continue
    rpl 'href="/assets/'  'href="../../assets/' "$f"
    rpl 'src="/assets/'   'src="../../assets/'  "$f"
    # In caso qualcuno abbia messo ../assets per sbaglio, portalo a ../../assets
    rpl 'href="../assets/' 'href="../../assets/' "$f"
    rpl 'src="../assets/'  'src="../../assets/"' "$f"
  done
done

# 3) Homepage root (index.html) deve restare su "assets/" relativo
if [ -f "index.html" ]; then
  echo "• Ensure root index keeps assets/ (not ../assets/)"
  rpl 'href="../assets/' 'href="assets/' index.html
  rpl 'src="../assets/'  'src="assets/'  index.html
  rpl 'href="/assets/'   'href="assets/' index.html
  rpl 'src="/assets/'    'src="assets/'  index.html
fi

# 4) Favicon & logo (qualunque percorso assoluto → relativo corretto)
echo "• Unify favicon & logo paths"
find "$ROOT" -type f -name "*.html" -not -path "*/assets/*" -print0 | while IFS= read -r -d '' f; do
  case "$f" in
    */works/*)   UP="../../" ;;
    */it/*|*/en/*|*/de/*) UP="../" ;;
    *)           UP="" ;;
  esac
  # favicon canonica
  sed -i "s|href=\"/assets/favicon\.png\"|href=\"${UP}assets/favicon.png\"|g" "$f"
  sed -i "s|href=\"/assets/favicon\.ico\"|href=\"${UP}assets/favicon.ico\"|g" "$f"
  # logo canonico (se usi assets/photo.jpg o simili)
  sed -i "s|src=\"/assets/|src=\"${UP}assets/|g" "$f"
done

# 5) Report rapido per link ancora assoluti (dovrebbero essere 0)
echo "• Scan for remaining absolute links (/assets or /it|/en|/de)"
REM=$(grep -Rn --exclude-dir=assets -E 'href="/(assets|it|en|de)/|src="/assets/' || true)
if [ -n "$REM" ]; then
  echo "⚠ Restano link assoluti da correggere manualmente:"
  echo "$REM"
else
  echo "✓ Nessun link assoluto residuo."
fi

echo "✅ Fix completato."
