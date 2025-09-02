#!/bin/bash

echo "🔧 Final comprehensive syntax fix..."

# Find and fix all broken arrow functions
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Fix (error, stack) { patterns - should be =>
    if grep -q "(error, stack) { " "$file"; then
        echo "Fixing arrow functions in: $(basename $file)"
        sed -i '' 's/(error, stack) { /(error, stack) => /g' "$file"
    fi
    
    # Fix (error, stackTrace) { patterns
    if grep -q "(error, stackTrace) { " "$file"; then
        sed -i '' 's/(error, stackTrace) { /(error, stackTrace) => /g' "$file"
    fi
    
    # Fix (_, __) { patterns
    if grep -q "(_, __) { " "$file"; then
        sed -i '' 's/(_, __) { /(_, __) => /g' "$file"
    fi
    
    # Fix standalone errorRed, and errorRedDark,
    if grep -q "^errorRed,$\|^errorRedDark,$" "$file"; then
        echo "Fixing color references in: $(basename $file)"
        # These should be part of a color definition, not standalone
        sed -i '' 's/^errorRed,$/    error: errorRed,/g' "$file"
        sed -i '' 's/^errorRedDark,$/    error: errorRedDark,/g' "$file"
    fi
done

echo "✅ Final fixes complete!"