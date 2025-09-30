#!/bin/bash

echo "🔧 Fixing syntax errors from migration..."

# Fix arrow function syntax that was broken
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -exec sed -i '' 's/(error, stack) =>/(error, stack) {/g' {} \;
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -exec sed -i '' 's/(_, __) =>/(_, __) {/g' {} \;

# Fix errorRed and errorRedDark lines that got broken
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -exec sed -i '' 's/^errorRed,$/TossDesignSystem.errorRed,/g' {} \;
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -exec sed -i '' 's/^errorRedDark,$/TossDesignSystem.errorRedDark,/g' {} \;

echo "✅ Syntax fixes complete!"