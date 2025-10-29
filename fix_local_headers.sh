set -euo pipefail

clean_top_banner() {
  # elimina eventuali righe “banner” prima del primo <h1>
  # (quelle con RABE / Vision / Catalogo / Works / Home / EN / DE / Marketplace)
  local f="$1"
  awk '
    BEGIN{done=0}
    {
      if (!done) {
        if ($0 ~ /<h1[^>]*>/) {done=1; print}
        else if ($0 ~ /(RABE|Vision|Catalogo|Katalog|Works|Opere|Home|EN|DE|Marketplace)/) {next}
        else {print}
      } else {print}
    }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

replace_header() {
  local f="$1" lang="$2" level="$3"

  # path relativi
  if [[ "$level" == "root" ]]; then
    AS="assets"; HOME="index.html"; CATALOG="catalog.html"; VISION="vision.html"
    IT="it/index.html"; EN="en/index.html"; DE="de/index.html"
  else
    AS="../assets"; HOME="../index.html"; CATALOG="../catalog.html"; VISION="../vision.html"
    IT="../it/index.html"; EN="../en/index.html"; DE="../de/index.html"
  fi

  # label localizzate
  case "$lang" in
    it) L1="Catalogo"; L2="Visione" ;;
    en) L1="Catalog";  L2="Vision"  ;;
    de) L1="Katalog";  L2="Vision"  ;;
  esac

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

  read -r -d '' CSS <<'EOF'
<style>
.site-header{display:flex;align-items:center;justify-content:space-between;gap:.75rem;margin:0 auto 1.25rem auto;padding:.75rem 0;border-bottom:1px solid rgba(255,255,255,.08)}
.site-header .brand{display:flex;align-items:center;gap:.5rem;font-weight:700;text-decoration:none}
.site-header .brand img{display:block;border-radius:4px}
.site-header .nav a{margin-left:1rem;text-decoration:none;opacity:.9}
.site-header .nav a:hover{opacity:1}
.site-header .lang{margin-left:.5rem;opacity:.9}
</style>
EOF

  # 0) pulisci vecchie barre testuali in cima
  clean_top_banner "$f"

  # 1) togli eventuale <base> e percorsi assoluti rimasti
  sed -i -E '/<base[^>]*>/Id' "$f"
  sed -i -E 's|/rabestudio\.github\.io/||g' "$f"

  # 2) sostituisci (o inserisci) <header>…</header>
  if grep -qi '</header>' "$f"; then
    awk -v RS= -v ORS= -v NEW="$HDR" '{s=$0; gsub(/<header[^>]*>[[:space:][:print:]\n\r]*?<\/header>/, NEW, s); printf "%s", s}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  else
    sed -i "0,/<body[^>]*>/s//&\n$HDR/" "$f"
  fi

  # 3) collega style.css con path corretto e inietta CSS inline dell’header
  if ! grep -q 'assets/style.css' "$f"; then
    if [[ "$level" == "root" ]]; then
      sed -i '0,/<\/head>/s//  <link rel="stylesheet" href="assets\/style.css">\n&/' "$f"
    else
      sed -i '0,/<\/head>/s//  <link rel="stylesheet" href="..\/assets\/style.css">\n&/' "$f"
    fi
  fi
  if ! grep -q 'site-header{display:flex' "$f"; then
    sed -i "0,/<\/head>/s//$(printf %s "$CSS" | sed 's/[&/\]/\\&/g')\n&/" "$f"
  fi

  # 4) normalizza riferimenti ad assets
  if [[ "$level" == "root" ]]; then
    sed -i -E 's|src="/?assets/|src=assets/|g; s|href="/?assets/|href=assets/|g' "$f"
  else
    sed -i -E 's|src="/?assets/|src=../assets/|g; s|href="/?assets/|href=../assets/|g' "$f"
  fi
}

shopt -s globstar nullglob

# root
for f in it/*.html en/*.html de/*.html; do
  replace_header "$f" "$(basename "$(dirname "$f")")" "root"
done
# inner
for f in it/works/*.html it/products/*.html en/works/*.html en/products/*.html de/works/*.html de/products/*.html; do
  replace_header "$f" "$(echo "$f" | sed -E 's#.*/(it|en|de)/.*#\1#')" "inner"
done

echo "✓ Header sistemati su tutte le pagine."
