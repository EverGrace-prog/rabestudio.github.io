set -euo pipefail

# Map: work slug -> display per language
declare -A TITLE_IT=(
  [sankofa]="Sankofa"
  [the-stranger]="Lo straniero"
  [the-gold-i-never-had]="L’oro che non ho mai tenuto"
  [ghitalian]="Ghitalian"
  [a-mothers-legacy]="L’eredità di una madre"
)
declare -A TITLE_EN=(
  [sankofa]="Sankofa"
  [the-stranger]="The Stranger"
  [the-gold-i-never-had]="The Gold I Never Had"
  [ghitalian]="Ghitalian"
  [a-mothers-legacy]="A Mother’s Legacy"
)
declare -A TITLE_DE=(
  [sankofa]="Sankofa"
  [the-stranger]="Der Fremde"
  [the-gold-i-never-had]="Das Gold, das ich nie gehalten habe"
  [ghitalian]="Ghitalian"
  [a-mothers-legacy]="Das Erbe einer Mutter"
)

epitext() {
  case "$1" in
    it) echo "Epilogo" ;;
    en) echo "Epilogue" ;;
    de) echo "Epilog" ;;
  esac
}

update_lang() {
  lang="$1"
  file="$lang/works/hith.html"
  [[ -f "$file" ]] || { echo "skip: $file not found"; return; }

  # For each slug, if epilogue exists, replace "— …" for that LI line
  for slug in sankofa the-stranger the-gold-i-never-had ghitalian a-mothers-legacy; do
    ep="<$lang>/epilogues/$slug.html"
    ep="${lang}/epilogues/$slug.html"
    if [[ -f "$ep" ]]; then
      label="$(epitext "$lang")"
      # build sed-safe link
      link=" — <a href=\"../epilogues/$slug.html\">$label</a>"
      # Replace only within the <li> that contains the work link
      # Pattern: <a href="WORK.html">Title</a> — ...
      work_href="$slug.html"
      # Special case: legacy is outside works
      [[ "$slug" == "a-mothers-legacy" ]] && work_href="../a-mothers-legacy.html"
      # Escape slashes for sed
      work_href_esc=$(printf '%s\n' "$work_href" | sed 's/[\/&]/\\&/g')
      link_esc=$(printf '%s\n' "$link" | sed 's/[\/&]/\\&/g')
      sed -i "/href=\"$work_href_esc\"/ s/—[^\<]*/$link_esc/" "$file"
      echo "  [$lang] linked $slug → $ep"
    else
      echo "  [$lang] no epilogue for $slug (expected $ep)"
    fi
  done
}

echo "Scanning & linking epilogues…"
update_lang it
update_lang en
update_lang de

git add -A
git commit -m "HITH pages: auto-link localized epilogues into works list"
git push
echo "✅ Epilogue links added to HITH pages."
