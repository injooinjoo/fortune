#!/bin/bash

# Fix TextStyle bracket issues across the codebase
# This script finds and fixes patterns where TextStyle has an extra closing parenthesis before the comma

echo "Fixing TextStyle bracket mismatches..."

# Find all dart files and fix the common patterns
find lib -name "*.dart" -type f | while read file; do
    # Fix patterns like: style: theme.textTheme.something),
    sed -i '' 's/style: theme\.textTheme\.\([a-zA-Z]*\)),/style: theme.textTheme.\1,/g' "$file"
    
    # Fix patterns like: style: Theme.of(context).textTheme.something),
    sed -i '' 's/style: Theme\.of(context)\.textTheme\.\([a-zA-Z]*\)),/style: Theme.of(context).textTheme.\1,/g' "$file"
    
    # Fix double commas
    sed -i '' 's/,,/,/g' "$file"
    
    # Fix patterns where there's a comma after a closing parenthesis that should be a closing parenthesis
    sed -i '' 's/,$/)/g' "$file"
done

echo "TextStyle bracket fixes completed!"