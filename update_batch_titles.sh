set -e

echo "▶ Verifico posizione..."
test -d it && test -d en && test -d de || { echo "Non sei nella root del sito"; exit 1; }

# ── helper sed inline (compatibile con Git Bash)
_sed() { sed -i "$@"; }

echo "▶ Aggiorno PAGINE OPERA (IT/EN/DE)..."

# --- THE GOLD I NEVER HAD ---
# IT page title + Original
_sed 's|<h1 class="work-title">.*</h1>|<h1 class="work-title">L’oro che non ho mai tenuto</h1>|' it/works/the-gold-i-never-had.html
grep -q 'work-original' it/works/the-gold-i-never-had.html \
  && _sed 's|<p class="work-original muted">.*</p>|<p class="work-original muted">Titolo originale: The Gold I Never Had</p>|' it/works/the-gold-i-never-had.html \
  || _sed '/<h1 class="work-title">L’oro che non ho mai tenuto<\/h1>/a <p class="work-original muted">Titolo originale: The Gold I Never Had</p>' it/works/the-gold-i-never-had.html

# EN page title only (remove Original)
_sed 's|<h1 class="work-title">.*</h1>|<h1 class="work-title">The Gold I Never Had</h1>|' en/works/the-gold-i-never-had.html
_sed '/class="work-original muted"/d' en/works/the-gold-i-never-had.html

# DE page title + Original
_sed 's|<h1 class="work-title">.*</h1>|<h1 class="work-title">Das Gold, das ich nie gehalten habe</h1>|' de/works/the-gold-i-never-had.html
grep -q 'work-original' de/works/the-gold-i-never-had.html \
  && _sed 's|<p class="work-original muted">.*</p>|<p class="work-original muted">Originaltitel: The Gold I Never Had</p>|' de/works/the-gold-i-never-had.html \
  || _sed '/<h1 class="work-title">Das Gold, das ich nie gehalten habe<\/h1>/a <p class="work-original muted">Originaltitel: The Gold I Never Had</p>' de/works/the-gold-i-never-had.html

# --- THE STRANGER ---
# IT
_sed 's|<h1 class="work-title">.*</h1>|<h1 class="work-title">Lo straniero</h1>|' it/works/the-stranger.html
grep -q 'work-original' it/works/the-stranger.html \
  && _sed 's|<p class="work-original muted">.*</p>|<p class="work-original muted">Titolo originale: The Stranger</p>|' it/works/the-stranger.html \
  || _sed '/<h1 class="work-title">Lo straniero<\/h1>/a <p class="work-original muted">Titolo originale: The Stranger</p>' it/works/the-stranger.html

# EN
_sed 's|<h1 class="work-title">.*</h1>|<h1 class="work-title">The Stranger</h1>|' en/works/the-stranger.html
_sed '/class="work-original muted"/d' en/works/the-stranger.html

# DE
_sed 's|<h1 class="work-title">.*</h1>|<h1 class="work-title">Der Fremde</h1>|' de/works/the-stranger.html
grep -q 'work-original' de/works/the-stranger.html \
  && _sed 's|<p class="work-original muted">.*</p>|<p class="work-original muted">Originaltitel: The Stranger</p>|' de/works/the-stranger.html \
  || _sed '/<h1 class="work-title">Der Fremde<\/h1>/a <p class="work-original muted">Originaltitel: The Stranger</p>' de/works/the-stranger.html

echo "▶ Aggiorno CATALOGHI (link text localizzati)..."

# GOLD in cataloghi
_sed 's|href="works/the-gold-i-never-had\.html">[^<]*</a>|href="works/the-gold-i-never-had.html">L’oro che non ho mai tenuto</a>|' it/catalog.html
_sed 's|href="works/the-gold-i-never-had\.html">[^<]*</a>|href="works/the-gold-i-never-had.html">The Gold I Never Had</a>|' en/catalog.html
_sed 's|href="works/the-gold-i-never-had\.html">[^<]*</a>|href="works/the-gold-i-never-had.html">Das Gold, das ich nie gehalten habe</a>|' de/catalog.html

# STRANGER in cataloghi
_sed 's|href="works/the-stranger\.html">[^<]*</a>|href="works/the-stranger.html">Lo straniero</a>|' it/catalog.html
_sed 's|href="works/the-stranger\.html">[^<]*</a>|href="works/the-stranger.html">The Stranger</a>|' en/catalog.html
_sed 's|href="works/the-stranger\.html">[^<]*</a>|href="works/the-stranger.html">Der Fremde</a>|' de/catalog.html

# Sankofa invariato: nulla da fare

echo "▶ Git add/commit/push..."
git add -A
git commit -m "Localize titles for The Gold I Never Had & The Stranger (IT/EN/DE) + catalogs"
git push -u origin main

echo "✅ Fatto! Aggiorna GitHub Pages (Ctrl+R)."
