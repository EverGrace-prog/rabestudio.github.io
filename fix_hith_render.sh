set -e

# Correct base paths (removes extra /rabestudio.github.io/ prefix if double)
for f in it/works/hith.html en/works/hith.html de/works/hith.html; do
  [ -f "$f" ] || continue
  sed -i 's|<base href="/rabestudio.github.io/|<base href="/|g' "$f"
done

# Commit & push
git add -A
git commit -m "Fix base href for HITH pages to render correctly on GitHub Pages"
git push

echo "✅ Base path fixed. Wait ~2 minutes and refresh the page."
