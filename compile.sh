#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT_NAME="egps-sanky-venn"
OUTPUT_DIR="./out/production/${PROJECT_NAME}"

echo "Compiling ${PROJECT_NAME}..."

# Clean and create output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Compile Java files
/home/dell/software/java25/jdk-25+36/bin/javac -encoding UTF-8 \
    -d "$OUTPUT_DIR" \
    -cp "dependency-egps/*" \
    $(find src -name "*.java")

# Copy resource files (images, html, txt, etc.)
find src -type f \( -name "*.svg" -o -name "*.png" -o -name "*.jpg" -o -name "*.gif" -o -name "*.ico" \
    -o -name "*.txt" -o -name "*.html" -o -name "*.properties" -o -name "*.xml" -o -name "*.json" \) | while read file; do
    target="${file/src\//$OUTPUT_DIR/}"
    mkdir -p "$(dirname "$target")"
    cp "$file" "$target"
done

echo "Compilation complete! Output: $OUTPUT_DIR"
echo "Java classes: $(find "$OUTPUT_DIR" -name "*.class" | wc -l)"
