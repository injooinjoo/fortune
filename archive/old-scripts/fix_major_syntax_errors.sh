#!/bin/bash

echo "🔧 Fixing major syntax errors in all Dart files..."

# Fix common bracket and parenthesis issues
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Fix missing closing brackets after previousStep patterns
    sed -i '' 's/if (state > 0) state--;$/if (state > 0) state--; }/g' "$file"
    
    # Fix Container syntax where maps are incorrectly wrapped
    sed -i '' 's/Container($/Container(/g' "$file"
    
    # Fix missing brackets in class definitions
    perl -0777 -i -pe 's/class (\w+) extends StateNotifier<[^>]+> \{\n([^}]+)\n\}/class $1 extends StateNotifier<$2> {\n$3\n}\n}/gs' "$file"
    
    # Fix arrow function patterns
    sed -i '' 's/(error, stack) { /(error, stack) => /g' "$file"
    sed -i '' 's/(error, stackTrace) { /(error, stackTrace) => /g' "$file"
    
    # Fix loading: () => { patterns
    sed -i '' 's/loading: () => {$/loading: () => Container(/g' "$file"
    
    # Fix error: (_, __) => { patterns
    sed -i '' 's/error: (_, __) => {$/error: (_, __) => Container(/g' "$file"
done

echo "✅ Major syntax fixes complete!"