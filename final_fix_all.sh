#!/bin/bash

echo "🔧 Final comprehensive fix for all Dart files..."

# Fix all arrow function errors
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Fix (error, stack) => patterns
    sed -i '' 's/(error, stack) => Center/(error, stack) { return Center/g' "$file"
    sed -i '' 's/(error, stack) => _buildErrorWidget/(error, stack) { return _buildErrorWidget/g' "$file"
    
    # Fix (_, __) => patterns 
    sed -i '' 's/(_, __) => Container/(_, __) { return Container/g' "$file"
    
    # Fix errorRed and errorRedDark references
    sed -i '' 's/errorRed,/TossDesignSystem.errorRed,/g' "$file"
    sed -i '' 's/errorRedDark,/TossDesignSystem.errorRedDark,/g' "$file"
    
    # Fix standalone color references that might be missing
    sed -i '' 's/^[[:space:]]*errorRed[[:space:]]*$/TossDesignSystem.errorRed/g' "$file"
    sed -i '' 's/^[[:space:]]*errorRedDark[[:space:]]*$/TossDesignSystem.errorRedDark/g' "$file"
done

echo "✅ All fixes complete!"