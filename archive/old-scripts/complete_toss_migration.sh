#!/bin/bash

echo "🎨 Starting complete Toss Design System migration..."

# First, update main.dart
echo "📱 Updating main.dart..."
sed -i '' "s/import 'core\/theme\/app_theme.dart';/import 'core\/theme\/toss_design_system.dart';/g" lib/main.dart
sed -i '' "s/AppTheme\.lightTheme()/TossDesignSystem.lightTheme()/g" lib/main.dart
sed -i '' "s/AppTheme\.darkTheme()/TossDesignSystem.darkTheme()/g" lib/main.dart

# Update all files with old theme references
echo "🔄 Replacing old theme references..."
find lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Replace AppColors references
    sed -i '' 's/AppColors\.primaryBlue/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppColors\.primaryColor/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppColors\.secondaryColor/TossDesignSystem.tossPurple/g' "$file"
    sed -i '' 's/AppColors\.backgroundColor/TossDesignSystem.gray50/g' "$file"
    sed -i '' 's/AppColors\.surfaceColor/TossDesignSystem.white/g' "$file"
    sed -i '' 's/AppColors\.errorColor/TossDesignSystem.errorRed/g' "$file"
    sed -i '' 's/AppColors\.successColor/TossDesignSystem.successGreen/g' "$file"
    sed -i '' 's/AppColors\.warningColor/TossDesignSystem.warningYellow/g' "$file"
    
    # Gray scale mappings
    sed -i '' 's/AppColors\.gray50/TossDesignSystem.gray50/g' "$file"
    sed -i '' 's/AppColors\.gray100/TossDesignSystem.gray100/g' "$file"
    sed -i '' 's/AppColors\.gray200/TossDesignSystem.gray200/g' "$file"
    sed -i '' 's/AppColors\.gray300/TossDesignSystem.gray300/g' "$file"
    sed -i '' 's/AppColors\.gray400/TossDesignSystem.gray400/g' "$file"
    sed -i '' 's/AppColors\.gray500/TossDesignSystem.gray500/g' "$file"
    sed -i '' 's/AppColors\.gray600/TossDesignSystem.gray600/g' "$file"
    sed -i '' 's/AppColors\.gray700/TossDesignSystem.gray700/g' "$file"
    sed -i '' 's/AppColors\.gray800/TossDesignSystem.gray800/g' "$file"
    sed -i '' 's/AppColors\.gray900/TossDesignSystem.gray900/g' "$file"
    
    # Any remaining AppColors
    sed -i '' 's/AppColors\./TossDesignSystem./g' "$file"
    
    # Replace AppTypography references
    sed -i '' 's/AppTypography\.headline1/TossDesignSystem.heading1/g' "$file"
    sed -i '' 's/AppTypography\.headline2/TossDesignSystem.heading2/g' "$file"
    sed -i '' 's/AppTypography\.headline3/TossDesignSystem.heading3/g' "$file"
    sed -i '' 's/AppTypography\.headline4/TossDesignSystem.heading4/g' "$file"
    sed -i '' 's/AppTypography\.headline5/TossDesignSystem.heading5/g' "$file"
    sed -i '' 's/AppTypography\.headline6/TossDesignSystem.heading6/g' "$file"
    sed -i '' 's/AppTypography\.bodyText1/TossDesignSystem.body1/g' "$file"
    sed -i '' 's/AppTypography\.bodyText2/TossDesignSystem.body2/g' "$file"
    sed -i '' 's/AppTypography\.caption/TossDesignSystem.caption/g' "$file"
    sed -i '' 's/AppTypography\.button/TossDesignSystem.button/g' "$file"
    
    # Any remaining AppTypography
    sed -i '' 's/AppTypography\./TossDesignSystem./g' "$file"
    
    # Replace AppSpacing references
    sed -i '' 's/AppSpacing\.xs/TossDesignSystem.spacingXS/g' "$file"
    sed -i '' 's/AppSpacing\.sm/TossDesignSystem.spacingS/g' "$file"
    sed -i '' 's/AppSpacing\.md/TossDesignSystem.spacingM/g' "$file"
    sed -i '' 's/AppSpacing\.lg/TossDesignSystem.spacingL/g' "$file"
    sed -i '' 's/AppSpacing\.xl/TossDesignSystem.spacingXL/g' "$file"
    sed -i '' 's/AppSpacing\.xxl/TossDesignSystem.spacingXXL/g' "$file"
    
    # Any remaining AppSpacing
    sed -i '' 's/AppSpacing\./TossDesignSystem./g' "$file"
    
    # Replace AppTheme references (careful not to break AppTheme.lightTheme())
    sed -i '' 's/AppTheme\.colors/TossDesignSystem/g' "$file"
    sed -i '' 's/AppTheme\.typography/TossDesignSystem/g' "$file"
    sed -i '' 's/AppTheme\.spacing/TossDesignSystem/g' "$file"
    
    # Update imports
    sed -i '' "s/import '.*app_colors\.dart';/import '..\/..\/..\/..\/core\/theme\/toss_design_system.dart';/g" "$file"
    sed -i '' "s/import '.*app_typography\.dart';/import '..\/..\/..\/..\/core\/theme\/toss_design_system.dart';/g" "$file"
    sed -i '' "s/import '.*app_spacing\.dart';/import '..\/..\/..\/..\/core\/theme\/toss_design_system.dart';/g" "$file"
    sed -i '' "s/import '.*app_theme\.dart';/import '..\/..\/..\/..\/core\/theme\/toss_design_system.dart';/g" "$file"
done

echo "✅ Migration complete!"
echo "📊 Checking remaining old references..."
echo "AppColors references: $(grep -r "AppColors" lib/ --include="*.dart" | wc -l)"
echo "AppTheme references: $(grep -r "AppTheme\." lib/ --include="*.dart" | wc -l)"
echo "AppTypography references: $(grep -r "AppTypography" lib/ --include="*.dart" | wc -l)"
echo "AppSpacing references: $(grep -r "AppSpacing" lib/ --include="*.dart" | wc -l)"