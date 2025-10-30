set -e

# --- helper: make a localized HITH page
mk_hith() {
  lang="$1" ; title="$2" ; back="$3"
  base="/rabestudio.github.io/$lang/"
  cat > "$lang/works/hith.html" <<HTML
<!doctype html><html lang="$lang"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title · RABE STUDIO</title>
<base href="$base">
<link rel="icon" href="../assets/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="../assets/style.css">
<style>
.storyteller blockquote{border-left:3px solid #d4af37;padding-left:1.5rem;margin:2rem 0;color:#d4c68a;font-style:italic;line-height:1.7;font-size:1.05rem}
.storyteller h2{color:#d4af37;text-transform:uppercase;letter-spacing:1px;margin-bottom:1rem}
.ded-list li{margin:.25rem 0}
.muted{opacity:.8;font-size:.95rem}
</style>
</head><body>

<header class="header">
  <a class="brand" href="index.html"><img src="../assets/logo-dark.png" alt="RABE"><span>RABE STUDIO</span></a>
  <nav class="nav">
    <a href="vision.html">${lang=="it"?"Vision":"Vision"}</a>
    <a href="catalog.html">${lang=="it"?"Catalogo":lang=="de"?"Katalog":"Catalog"}</a>
    <a href="works/hith.html" class="active">HITH</a>
    <span class="lang">
      ${lang!="it" ? "<a href=\"../it/works/hith.html\">IT</a> · " : "" }
      ${lang!="en" ? "<a href=\"../en/works/hith.html\">EN</a> · " : "" }
      ${lang!="de" ? "<a href=\"../de/works/hith.html\">DE</a>" : "" }
    </span>
  </nav>
</header>

<main class="container storyteller">
  <nav class="breadcrumbs"><a href="index.html">$back</a> · HITH</nav>
  <h1>HITH — ${lang=="it"?"Dediche":"en"==lang?"Dedications":"Widmungen"}</h1>
  <p class="muted">
    ${lang=="it"?"Ogni opera porta una dedica HITH. Qui le raccogliamo per lingua e titolo.":
      lang=="de"?"Jedes Werk trägt eine HITH-Widmung. Hier sammeln wir sie nach Sprache und Titel.":
      "Every work carries a HITH dedication. We collect them here by language and title."}
  </p>

  <h2>${lang=="it"?"Romanzi & Saggi":"de"==lang?"Romane & Essays":"Novels & Essays"}</h2>
  <ul class="ded-list">
    <li><a href="sankofa.html">Sankofa</a> — ${lang=="it"?"dedica HITH":lang=="de"?"HITH-Widmung":"HITH dedication"}</li>
    <li><a href="the-stranger.html">${lang=="it"?"Lo straniero":lang=="de"?"Der Fremde":"The Stranger"}</a> — …</li>
    <li><a href="the-gold-i-never-had.html">${lang=="it"?"L’oro che non ho mai tenuto":lang=="de"?"Das Gold, das ich nie gehalten habe":"The Gold I Never Had"}</a> — …</li>
    <li><a href="ghitalian.html">Ghitalian</a> — …</li>
    <li><a href="../a-mothers-legacy.html">${lang=="it"?"L’eredità di una madre":lang=="de"?"Das Erbe einer Mutter":"A Mother’s Legacy"}</a> — …</li>
  </ul>

  <h2>${lang=="it"?"Estratto-stile Narratore":"de"==lang?"Erzähl-Tonprobe":"Storyteller sample"}</h2>
  <blockquote>
    ${lang=="it"?"Quando oggi mi volto indietro, vedo una bambina seduta in un grande compound…":
      lang=="de"?"Wenn ich mich heute umsehe, sehe ich ein Mädchen in einem großen Hof sitzen…":
      "When I look back today, I see a little girl in a wide compound, listening to stories by candlelight…"}
  </blockquote>

  <p class="muted">
    ${lang=="it"?"Se desideri, possiamo collegare qui ogni dedica completa per ciascuna opera.":
      lang=="de"?"Auf Wunsch verlinken wir hier jede vollständige Widmung pro Werk.":
      "If you’d like, we can link each full dedication for every work here."}
  </p>

  <p><a href="catalog.html">⟵ ${back}</a></p>
</main>

<footer class="footer">© 2025 RABE STUDIO · Legacy • Creativity • Care · No cookies · contact@rabestudio.com</footer>
</body></html>
HTML
}

# ensure folders exist
mkdir -p it/works en/works de/works

# create pages
mk_hith it "HITH — Dediche" "Catalogo"
mk_hith en "HITH — Dedications" "Catalog"
mk_hith de "HITH — Widmungen" "Katalog"

# tiny redirects for old URL "telegram-hith.html"
for L in it en de; do
  cat > "$L/works/telegram-hith.html" <<HTML
<!doctype html><meta http-equiv="refresh" content="0; url=hith.html">
<link rel="canonical" href="hith.html">
HTML
done

# fix any old nav links pointing to telegram-hith.html
sed -i 's|works/telegram-hith\.html|works/hith.html|g' **/*.html

# commit & push
git add -A
git commit -m "Add localized HITH pages + redirects; fix nav links; light storyteller styles"
git push
echo "✅ HITH pages published."
