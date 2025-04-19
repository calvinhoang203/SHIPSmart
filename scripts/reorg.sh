#!/usr/bin/env bash
set -euo pipefail

echo "🔨 Starting repo reorganization…"

# 1) Make sure target dirs exist
for dir in data/raw sql src docs; do
  if [ ! -d "$dir" ]; then
    echo "✔️  Creating missing dir: $dir"
    mkdir -p "$dir"
    git add "$dir"
  else
    echo "✔️  Dir exists: $dir"
  fi
done

# 2) Move raw CSVs
for csv in visits.csv claims.csv; do
  src="data/$csv"
  dst="data/raw/$csv"
  if [ -f "$src" ]; then
    echo "➡️  Moving $src → $dst"
    git mv "$src" "$dst"
  else
    echo "⚠️  SKIP: source not found: $src"
  fi
done

# 3) Move SQL files
declare -A sql_moves=(
  ["create_shipsmart_db.sql"]="sql/create_tables.sql"
  ["InsertPolicy.sql"]="sql/insert_policy.sql"
  ["create_views.sql"]="sql/create_views.sql"
)
for src in "${!sql_moves[@]}"; do
  dst="${sql_moves[$src]}"
  # ensure parent dir exists
  parent=$(dirname "$dst")
  if [ ! -d "$parent" ]; then
    echo "✔️  Creating dir: $parent"
    mkdir -p "$parent"
    git add "$parent"
  fi
  if [ -f "$src" ]; then
    echo "➡️  Moving $src → $dst"
    git mv "$src" "$dst"
  else
    echo "⚠️  SKIP: source not found: $src"
  fi
done

# 4) Move Python scripts
declare -A py_moves=(
  ["ExtractText.py"]="src/extract_text.py"
  ["ExtractBenefit.py"]="src/extract_benefit.py"
  ["model.py"]="src/model.py"
  ["demo.py"]="src/demo.py"         # if you have a demo script
)
for src in "${!py_moves[@]}"; do
  dst="${py_moves[$src]}"
  parent=$(dirname "$dst")
  if [ ! -d "$parent" ]; then
    echo "✔️  Creating dir: $parent"
    mkdir -p "$parent"
    git add "$parent"
  fi
  if [ -f "$src" ]; then
    echo "➡️  Moving $src → $dst"
    git mv "$src" "$dst"
  else
    echo "⚠️  SKIP: source not found: $src"
  fi
done

# 5) Move docs
for doc in UCD-Anthem-Benefit-Book.pdf UCD-Anthem-Benefit-Book.txt; do
  src="$doc"
  dst="docs/$doc"
  if [ -f "$src" ]; then
    echo "➡️  Moving $src → $dst"
    git mv "$src" "$dst"
  else
    echo "⚠️  SKIP: source not found: $src"
  fi
done

# 6) Final cleanup / commit prompt
echo
echo "✅  Reorg complete. Review with 'git status', then:"
echo "   git commit -m \"Restructure repo into subfolders (data, sql, src, docs)\""
