set -euo pipefail

# --- helper: sostituzione del blocco <header> oppure inserimento dopo <body>
replace_header() {
  local file="$1"       # percorso file
  local lang="$2"       # it | en | de
  local level="$3"      # root | inner

  # path relativi per assets e link base a seconda del livello
  if [[ "$level" == "root" ]]; then
    AS="assets"
    HOME="index.html"
    CATALOG="catalog.html"
    VISION="vision.html"
    IT="it/index.html"; EN="en/index.html"; DE="de/index.html"
  else
    AS="../assets"
    HOME="../index.html"
    CATALOG="../catalog.html"
    VISION="../vision.html"
    IT="../it/index.html"; EN="../en/index.html"; DE="../de/index.html"
  fi

  # testi localizzati
  case "$lang" in
    it) L1="Catalogo"; L2="Visione" ;;
    en) L1="Catalog";  L2="Vision"  ;;
    de) L1="Katalog";  L2="Vision"  ;;
  esac

  # header compatto (B) – con 🌐 e link IT/EN/DE
  read -r -d '' HDR <<EOF
<header class="site-header">
  <a class="brand" href="$HOME">
    <img src="$AS/favicon.png" alt="RABE" width="28" height="28" />
    <span>RABE STUDIO</span>
  </a>
  <nav class="nav">
    <a href="$CATALOG">$L1</a>
    <a href="$VISION">$L2</a>
    <span class="lang">🌐 <a href="$IT">IT</a> · <a href="$EN">EN</a> · <a href="$DE">DE</a></span>
  </nav>
</header>
EOF

  # CSS minimal per l’header (inline per evitare problemi di path)
  read -r -d '' HDRCSS <<'EOF'
<style>
.site-header{display:flex;align-items:center;justify-content:space-between;gap:.75rem;margin:0 auto 1.25rem auto;padding:.75rem 0;border-bottom:1px solid rgba(255,255,255,.08)}
.site-header .brand{display:flex;align-items:center;gap:.5rem;font-weight:700;text-decoration:none}
.site-header .brand img{display:block;border-radius:4px}
.site-header .nav a{margin-left:1rem;text-decoration:none;opacity:.9}
.site-header .nav a:hover{opacity:1}
.site-header .lang{margin-left:.5rem;opacity:.9}
</style>
EOF

  # 1) rimuovi eventuale <base> (causa dei link rotti)
  sed -i -E '/<base[^>]*>/Id' "$file"

  # 2) normalizza vecchi prefissi assoluti
  sed -i -E 's|/rabestudio\.github\.io/||g' "$file"

  # 3) sostituisci eventuale header o inserisci dopo <body>
  if grep -qi '</header>' "$file"; then
    awk -v RS= -v ORS= -v NEW="$HDR" '{s=$0; gsub(/<header[^>]*>[[:space:][:print:]\n\r]*?<\/header>/, NEW, s); printf "%s", s}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  else
    sed -i "0,/<body[^>]*>/s//&\n$HDR/" "$file"
  fi

  # 4) assicura CSS principale del sito e inline dell’header
  if ! grep -q 'assets/style.css' "$file"; then
    # link a style.css con path relativo corretto
    if [[ "$level" == "root" ]]; then
      sed -i '0,/<\/head>/s//  <link rel="stylesheet" href="assets\/style.css">\n&/' "$file"
    else
      sed -i '0,/<\/head>/s//  <link rel="stylesheet" href="..\/assets\/style.css">\n&/' "$file"
    fi
  fi
  # inserisci il CSS inline dell’header una sola volta
  if ! grep -q 'site-header{display:flex' "$file"; then
    sed -i "0,/<\/head>/s//$(printf %s "$HDRCSS" | sed 's/[&/\]/\\&/g')\n&/" "$file"
  fi

  # 5) metti in sicurezza eventuali riferimenti a /assets o assets/ nel file
  if [[ "$level" == "root" ]]; then
    sed -i -E 's|src="/?assets/|src=assets/|g; s|href="/?assets/|href=assets/|g' "$file"
  else
    sed -i -E 's|src="/?assets/|src=../assets/|g; s|href="/?assets/|href=../assets/|g' "$file"
  fi
}

# --- Applica a tutte le pagine
shopt -s globstar nullglob

# root pages
for f in it/*.html en/*.html de/*.html; do
  replace_header "$f" "$(basename "$(dirname "$f")")" "root"
done

# inner pages (works/ + products/)
for f in it/works/*.html it/products/*.html en/works/*.html en/products/*.html de/works/*.html de/products/*.html; do
  replace_header "$f" "$(echo "$f" | sed -E 's#.*/(it|en|de)/.*#\1#')" "inner"
done

echo "✓ Header e link corretti. Pronto per commit."
