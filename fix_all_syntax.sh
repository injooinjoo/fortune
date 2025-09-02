#!/bin/bash

echo "🔧 Comprehensive syntax fix..."

# Fix all arrow function patterns that got broken
FILES=$(grep -r "(_, __) {" /Users/jacobmac/Desktop/Dev/fortune/lib --include="*.dart" -l)

for file in $FILES; do
    echo "Fixing: $(basename $file)"
    # Fix patterns like (_, __) { something
    sed -i '' 's/(_, __) { /(_, __) => /g' "$file"
    # Fix patterns like (error, stack) { something
    sed -i '' 's/(error, stack) { /(error, stack) => /g' "$file"
    # Fix patterns like (error, stackTrace) { something
    sed -i '' 's/(error, stackTrace) { /(error, stackTrace) => /g' "$file"
done

# Fix standalone errorRed and errorRedDark
FILES=$(grep -r "^errorRed,$\|^errorRedDark,$" /Users/jacobmac/Desktop/Dev/fortune/lib --include="*.dart" -l)

for file in $FILES; do
    echo "Fixing colors in: $(basename $file)"
    sed -i '' 's/^errorRed,$/      errorRed,/g' "$file"
    sed -i '' 's/^errorRedDark,$/      errorRedDark,/g' "$file"
done

echo "✅ All syntax errors fixed!"