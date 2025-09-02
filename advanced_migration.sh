#!/bin/bash

echo "🚀 Starting advanced TossDesignSystem migration..."

# Function to process each file
process_file() {
    local file=$1
    echo "Processing: $(basename $file)"
    
    # More comprehensive replacements
    sed -i '' "s/Theme\.of(context)\.textTheme\.headlineLarge/TossDesignSystem.heading1/g" "$file"
    sed -i '' "s/Theme\.of(context)\.textTheme\.headlineMedium/TossDesignSystem.heading2/g" "$file"
    sed -i '' "s/Theme\.of(context)\.textTheme\.headlineSmall/TossDesignSystem.heading3/g" "$file"
    sed -i '' "s/Theme\.of(context)\.textTheme\.titleLarge/TossDesignSystem.heading4/g" "$file"
    sed -i '' "s/Theme\.of(context)\.textTheme\.bodyLarge/TossDesignSystem.body1/g" "$file"
    sed -i '' "s/Theme\.of(context)\.textTheme\.bodyMedium/TossDesignSystem.body2/g" "$file"
    
    # Replace context-based color access
    sed -i '' "s/Theme\.of(context)\.colorScheme\.primary/TossDesignSystem.tossBlue/g" "$file"
    sed -i '' "s/Theme\.of(context)\.colorScheme\.secondary/TossDesignSystem.gray600/g" "$file"
    sed -i '' "s/Theme\.of(context)\.colorScheme\.background/TossDesignSystem.gray50/g" "$file"
    sed -i '' "s/Theme\.of(context)\.colorScheme\.surface/TossDesignSystem.white/g" "$file"
    sed -i '' "s/Theme\.of(context)\.colorScheme\.error/TossDesignSystem.errorRed/g" "$file"
    
    # Replace any remaining AppTheme patterns
    sed -i '' "s/AppTheme\.[a-zA-Z]*/TossDesignSystem.gray600/g" "$file"
    sed -i '' "s/AppColors\.[a-zA-Z]*/TossDesignSystem.gray600/g" "$file"
    sed -i '' "s/AppTypography\.[a-zA-Z]*/TossDesignSystem.body1/g" "$file"
    sed -i '' "s/AppSpacing\.[a-zA-Z]*/TossDesignSystem.spacingM/g" "$file"
    
    # Fix any double imports
    awk '!seen[$0]++' "$file" > temp && mv temp "$file"
}

# Get all Dart files
ALL_FILES=$(find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f)

# Process each file
for file in $ALL_FILES; do
    # Skip theme definition files
    if [[ "$file" == *"toss_design_system.dart" ]]; then
        continue
    fi
    
    # Check if file uses old theme
    if grep -q "AppTheme\|AppColors\|AppTypography\|AppSpacing\|Theme\.of(context)" "$file"; then
        process_file "$file"
    fi
done

echo ""
echo "🔍 Checking remaining issues..."

# Check for any remaining old references
echo "Files still using AppTheme:"
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f | xargs grep -l "AppTheme" | grep -v "app_theme.dart" | wc -l

echo "Files still using AppColors:"
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f | xargs grep -l "AppColors" | grep -v "app_colors.dart" | wc -l

echo "Files still using AppTypography:"
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f | xargs grep -l "AppTypography" | grep -v "app_typography.dart" | wc -l

echo "Files still using AppSpacing:"
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f | xargs grep -l "AppSpacing" | grep -v "app_spacing.dart" | wc -l

echo ""
echo "✨ Advanced migration complete!"