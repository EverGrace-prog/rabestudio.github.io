#!/usr/bin/env bash
set -e

# --- utility: write a file safely
write() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

# --- 1) IT / EN / DE full pages -----------------------------

# IT
write it/works/a-mothers-legacy-full.html <<'HTML'
<!doctype html><html lang="it"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>L’eredità di una madre — Testo completo</title>
<link rel="icon" href="../assets/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="../assets/style.css">
</head><body>
<header class="header">
  <a class="brand" href="../index.html"><img src="../assets/logo-dark.png" alt="RABE"><span>RABE STUDIO</span></a>
  <nav class="nav"><a href="../vision.html">Vision</a><a href="../catalog.html">Catalogo</a><a href="../works/hith.html">HITH</a>
  <span class="lang"><a href="../en/works/a-mothers-legacy-full.html">EN</a> · <a href="../de/works/a-mothers-legacy-full.html">DE</a></span></nav>
</header>
<main class="container">
  <nav class="breadcrumbs"><a href="index.html">Home</a> · <a href="catalog.html">Catalogo</a> · Opere</nav>
  <h1 class="work-title">L’eredità di una madre — <em>Testo completo</em></h1>

  <!-- INCOLLA QUI IL TESTO COMPLETO (ITALIANO) -->
  <article class="work-body">
    <!-- PASTE: /mnt/data/a_mothers_legacy_full_IT -->
  </article>

  <hr>
  <p class="muted"><a href="a-mothers-legacy.html">Torna alla scheda breve</a></p>
</main>
<footer class="footer">© 2025 RABE STUDIO · Legacy • Creativity • Care · <a href="mailto:contact@rabestudio.com">contact@rabestudio.com</a></footer>
</body></html>
HTML

# EN
write en/works/a-mothers-legacy-full.html <<'HTML'
<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>A Mother’s Legacy — Full text</title>
<link rel="icon" href="../assets/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="../assets/style.css">
</head><body>
<header class="header">
  <a class="brand" href="../index.html"><img src="../assets/logo-dark.png" alt="RABE"><span>RABE STUDIO</span></a>
  <nav class="nav"><a href="../vision.html">Vision</a><a href="../catalog.html">Works</a><a href="../works/hith.html">HITH</a>
  <span class="lang"><a href="../it/works/a-mothers-legacy-full.html">IT</a> · <a href="../de/works/a-mothers-legacy-full.html">DE</a></span></nav>
</header>
<main class="container">
  <nav class="breadcrumbs"><a href="index.html">Home</a> · <a href="catalog.html">Catalog</a> · Works</nav>
  <h1 class="work-title">A Mother’s Legacy — <em>Full text</em></h1>

  <!-- PASTE FULL TEXT (ENGLISH) HERE -->
  <article class="work-body">
    <!-- PASTE: /mnt/data/a_mothers_legacy_full -->
  </article>

  <hr>
  <p class="muted"><a href="a-mothers-legacy.html">Back to overview</a></p>
</main>
<footer class="footer">© 2025 RABE STUDIO · Legacy • Creativity • Care · <a href="mailto:contact@rabestudio.com">contact@rabestudio.com</a></footer>
</body></html>
HTML

# DE
write de/works/a-mothers-legacy-full.html <<'HTML'
<!doctype html><html lang="de"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Das Erbe einer Mutter — Volltext</title>
<link rel="icon" href="../assets/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="../assets/style.css">
</head><body>
<header class="header">
  <a class="brand" href="../index.html"><img src="../assets/logo-dark.png" alt="RABE"><span>RABE STUDIO</span></a>
  <nav class="nav"><a href="../vision.html">Vision</a><a href="../catalog.html">Katalog</a><a href="../works/hith.html">HITH</a>
  <span class="lang"><a href="../it/works/a-mothers-legacy-full.html">IT</a> · <a href="../en/works/a-mothers-legacy-full.html">EN</a></span></nav>
</header>
<main class="container">
  <nav class="breadcrumbs"><a href="index.html">Home</a> · <a href="catalog.html">Katalog</a> · Werke</nav>
  <h1 class="work-title">Das Erbe einer Mutter — <em>Volltext</em></h1>

  <!-- VOLLEN TEXT (DEUTSCH) HIER EINFÜGEN -->
  <article class="work-body">
    <!-- PASTE: /mnt/data/a_mothers_legacy_full_DE -->
  </article>

  <hr>
  <p class="muted"><a href="a-mothers-legacy.html">Zurück zur Kurzansicht</a></p>
</main>
<footer class="footer">© 2025 RABE STUDIO · Legacy • Creativity • Care · <a href="mailto:contact@rabestudio.com">contact@rabestudio.com</a></footer>
</body></html>
HTML

# --- 2) Aggiunge in fondo alla scheda breve un link "Leggi il testo completo"
add_cta() {
  local f="$1" lbl="$2" href="$3"
  [[ -f "$f" ]] || return 0
  grep -q 'data-full-link' "$f" && return 0
  # prima del </main> aggiungi il bottone
  sed -i '0,/<\/main>/{s//  <p class="hith-cta" data-full-link="1"><a href="'"$href"'">'"$lbl"'<\/a><\/p>\n&/}' "$f"
}
add_cta it/works/a-mothers-legacy.html  "Leggi il testo completo" "a-mothers-legacy-full.html"
add_cta en/works/a-mothers-legacy.html  "Read the full work"      "a-mothers-legacy-full.html"
add_cta de/works/a-mothers-legacy.html  "Volltext lesen"          "a-mothers-legacy-full.html"

# --- 3) Commit & push
git add -A
git commit -m "A Mother’s Legacy: add IT/EN/DE full pages + link from overview"
git push
echo "✅ Pronto: le pagine *full* sono state create e collegate."
