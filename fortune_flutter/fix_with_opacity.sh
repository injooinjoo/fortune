#!/bin/bash

# Find all Dart files and replace withOpacity with withValues
find lib -name "*.dart" -type f -exec sed -i '' 's/\.withOpacity(\([^)]*\))/.withValues(alpha: \1)/g' {} +

echo "Replaced all withOpacity calls with withValues"