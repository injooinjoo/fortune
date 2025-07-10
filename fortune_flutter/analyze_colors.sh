#\!/bin/bash

echo "=== Fortune Flutter Hardcoded Colors Analysis ==="
echo ""

# Function to analyze a file
analyze_file() {
    local file=$1
    local count=$(grep -c "Colors\." "$file")
    if [ $count -gt 0 ]; then
        echo "File: $file"
        echo "Total hardcoded color instances: $count"
        echo "Color occurrences:"
        grep -o "Colors\.[a-zA-Z0-9_\[\]]*" "$file" | sort | uniq -c | sort -rn | sed 's/^/  /'
        echo ""
    fi
}

# Analyze fortune pages
echo "### Fortune Pages ###"
for file in ./lib/features/fortune/presentation/pages/*.dart; do
    analyze_file "$file"
done

# Analyze widgets
echo "### Presentation Widgets ###"
for file in ./lib/presentation/widgets/*.dart; do
    analyze_file "$file"
done

# Analyze shared components
echo "### Shared Components ###"
for file in ./lib/shared/components/*.dart; do
    analyze_file "$file"
done

# Analyze onboarding widgets
echo "### Onboarding Widgets ###"
for file in ./lib/screens/onboarding/widgets/*.dart; do
    analyze_file "$file"
done

# Summary
echo "### SUMMARY ###"
echo "Total files with hardcoded colors:"
find . -name "*.dart" -type f | xargs grep -l "Colors\." | grep -E "(pages|widgets|components)" | wc -l
