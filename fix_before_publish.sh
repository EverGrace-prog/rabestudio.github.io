#!/usr/bin/env bash
set -euo pipefail

echo "▶ RABE STUDIO — Fix paths + ensure CSS & favicon"

# helper
rpl()  { sed -i "s|$1|$2|g" "$3"; }
nl2lf(){ sed -i 's|\r$||' "$1" 2>/dev/null || true; }

ROOT="."
LANGS=("it" "en" "de")

# 0) normalizza line endings
find "$ROOT" -type f -name "*.html" -not -path "*/assets/*" -print0 | while IFS= read -r -d '' f; do nl2lf "$f"; done

# 1) fix path assets nei file a livello lingua (../assets/…)
for L in "${LANGS[@]}"; do
  for f in "$L"/*.html; do
    [ -e "$f" ] || continue
    rpl 'href="/assets/'  'href="../assets/'  "$f"
    rpl 'src="/assets/'   'src="../assets/'   "$f"
  done
done

# 2) fix path assets nelle pagine works (../../assets/…)
for L in "${LANGS[@]}"; do
  for f in "$L/works/"*.html; do
    [ -e "$f" ] || continue
    rpl 'href="/assets/'   'href="../../assets/' "$f"
    rpl 'src="/assets/'    'src="../../assets/'  "$f"
    rpl 'href="../assets/' 'href="../../assets/' "$f"
    rpl 'src="../assets/'  'src="../../assets/'  "$f"
  done
done

# 3) root index deve restare con assets/ (non ../)
if [ -f "index.html" ]; then
  rpl 'href="../assets/' 'href="assets/' index.html
  rpl 'src="../assets/'  'src="assets/'  index.html
  rpl 'href="/assets/'   'href="assets/' index.html
  rpl 'src="/assets/'    'src="assets/'  index.html
fi

# 4) uniforma favicon/logo in tutti i file e ASSICURA presenza <link rel="stylesheet"> e favicon
ensure_head_bits () {
  local f="$1"
  # determina profondità
  local UP=""
  case "$f" in
    */works/*)   UP='../../' ;;
    */it/*|*/en/*|*/de/*) UP='../' ;;
    *)           UP='' ;;
  esac

  # assicura <head> esista
  if ! grep -qi '<head' "$f"; then
    sed -i '1s|^|<head></head>\n|' "$f"
  fi

  # CSS: <link rel="stylesheet" href="…assets/style.css">
  if ! grep -qi 'rel="stylesheet"' "$f"; then
    sed -i "0,/<head>/s||<head>\n  <meta charset=\"utf-8\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n  <link rel=\"stylesheet\" href=\"${UP}assets/style.css\">|" "$f"
  fi

  # se il link al CSS c'è ma con path assoluto, correggi
  sed -i "s|href=\"/assets/style.css\"|href=\"${UP}assets/style.css\"|g" "$f"

  # FAVICON: inserisci se assente
  if ! grep -qi 'rel="icon"' "$f"; then
    sed -i "0,/<head>/s||<head>\n  <link rel=\"icon\" href=\"${UP}assets/favicon.png\">\n  <link rel=\"shortcut icon\" href=\"${UP}assets/favicon.ico\">|" "$f"
  else
    sed -i "s|href=\"/assets/favicon\.png\"|href=\"${UP}assets/favicon.png\"|g" "$f"
    sed -i "s|href=\"/assets/favicon\.ico\"|href=\"${UP}assets/favicon.ico\"|g" "$f"
  fi

  # logo <img … src="…assets/photo.jpg"> se presente con /assets, rendilo relativo
  sed -i "s|src=\"/assets/|src=\"${UP}assets/|g" "$f"
}

# applica ai file
find "$ROOT" -type f -name "*.html" -not -path "*/assets/*" -print0 | while IFS= read -r -d '' f; do
  ensure_head_bits "$f"
done

# 5) report diagnostica
echo "— Diagnostica —"
echo "Pagine senza CSS:"
grep -RLi --exclude-dir=assets -e 'rel="stylesheet"' . | sed 's/^/  • /' || true
echo "Pagine con link assoluti residui:"
grep -Rn --exclude-dir=assets -E 'href="/(assets|it|en|de)/|src="/assets/' . | sed 's/^/  • /' || true

echo "✅ Fix + checks completati."
