#!/bin/bash

echo "🔧 Fixing remaining syntax errors..."

# Fix double TossDesignSystem references
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Fix double TossDesignSystem
    sed -i '' 's/TossDesignSystem\.TossDesignSystem\./TossDesignSystem\./g' "$file"
    
    # Fix arrow function patterns that need closing
    sed -i '' 's/(error, stack) { return Center(/error: (error, stack) => Center(/g' "$file"
    sed -i '' 's/(error, stack) { return _buildErrorWidget/error: (error, stack) => _buildErrorWidget/g' "$file"
    sed -i '' 's/(_, __) { return Container/loading: () => Container/g' "$file"
done

echo "✅ Remaining fixes complete!"