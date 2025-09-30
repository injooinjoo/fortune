#!/bin/bash

echo "🚀 Starting complete TossDesignSystem migration..."

# Get all files that still use old theme
FILES=$(find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f | xargs grep -l "AppTheme\|AppColors\|AppTypography\|AppSpacing" | grep -v "app_theme.dart\|app_colors.dart\|app_typography.dart\|app_spacing.dart\|app_text_styles.dart")

TOTAL=$(echo "$FILES" | wc -l | xargs)
CURRENT=0

echo "📊 Found $TOTAL files to migrate"

for file in $FILES; do
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL] Processing: $(basename $file)"
    
    # Skip theme definition files themselves
    if [[ "$file" == *"app_theme.dart" ]] || [[ "$file" == *"app_colors.dart" ]] || [[ "$file" == *"app_typography.dart" ]] || [[ "$file" == *"app_spacing.dart" ]] || [[ "$file" == *"app_text_styles.dart" ]]; then
        echo "  ⏭️  Skipping theme definition file"
        continue
    fi
    
    # Replace imports
    sed -i '' "s|import '.*app_colors\.dart';|import '../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '.*app_typography\.dart';|import '../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '.*app_spacing\.dart';|import '../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '.*app_text_styles\.dart';|import '../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '.*app_theme\.dart';|import '../core/theme/toss_design_system.dart';|g" "$file"
    
    # Fix relative import paths
    sed -i '' "s|import '\.\./\.\./\.\./\.\./core/theme/toss_design_system\.dart';|import '../../../../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '\.\./\.\./\.\./core/theme/toss_design_system\.dart';|import '../../../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '\.\./\.\./core/theme/toss_design_system\.dart';|import '../../core/theme/toss_design_system.dart';|g" "$file"
    sed -i '' "s|import '\.\./core/theme/toss_design_system\.dart';|import '../core/theme/toss_design_system.dart';|g" "$file"
    
    # Replace AppColors references
    sed -i '' 's/AppColors\.primary/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppColors\.secondary/TossDesignSystem.gray600/g' "$file"
    sed -i '' 's/AppColors\.background/TossDesignSystem.gray50/g' "$file"
    sed -i '' 's/AppColors\.surface/TossDesignSystem.white/g' "$file"
    sed -i '' 's/AppColors\.error/TossDesignSystem.errorRed/g' "$file"
    sed -i '' 's/AppColors\.textPrimary/TossDesignSystem.gray900/g' "$file"
    sed -i '' 's/AppColors\.textSecondary/TossDesignSystem.gray600/g' "$file"
    sed -i '' 's/AppColors\.divider/TossDesignSystem.gray200/g' "$file"
    sed -i '' 's/AppColors\.success/TossDesignSystem.successGreen/g' "$file"
    sed -i '' 's/AppColors\.warning/TossDesignSystem.warningOrange/g' "$file"
    sed -i '' 's/AppColors\.info/TossDesignSystem.tossBlue/g' "$file"
    
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
    
    # Replace AppTheme references
    sed -i '' 's/AppTheme\.of(context)\.primaryColor/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppTheme\.primaryColor/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppTheme\.darkBackground/TossDesignSystem.grayDark50/g' "$file"
    sed -i '' 's/AppTheme\.cardDark/TossDesignSystem.grayDark100/g' "$file"
    sed -i '' 's/AppTheme\.textPrimary/TossDesignSystem.gray900/g' "$file"
    sed -i '' 's/AppTheme\.textSecondary/TossDesignSystem.gray600/g' "$file"
    sed -i '' 's/AppTheme\.primary/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppTheme\.secondary/TossDesignSystem.gray600/g' "$file"
    sed -i '' 's/AppTheme\.background/TossDesignSystem.gray50/g' "$file"
    sed -i '' 's/AppTheme\.surface/TossDesignSystem.white/g' "$file"
    sed -i '' 's/AppTheme\.error/TossDesignSystem.errorRed/g' "$file"
    sed -i '' 's/AppTheme\.success/TossDesignSystem.successGreen/g' "$file"
    sed -i '' 's/AppTheme\.warning/TossDesignSystem.warningOrange/g' "$file"
    sed -i '' 's/AppTheme\.info/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/AppTheme\.borderColor/TossDesignSystem.gray200/g' "$file"
    sed -i '' 's/AppTheme\.gold/TossDesignSystem.warningOrange/g' "$file"
    
    # Replace AppTypography references
    sed -i '' 's/AppTypography\.heading1/TossDesignSystem.heading1/g' "$file"
    sed -i '' 's/AppTypography\.heading2/TossDesignSystem.heading2/g' "$file"
    sed -i '' 's/AppTypography\.heading3/TossDesignSystem.heading3/g' "$file"
    sed -i '' 's/AppTypography\.heading4/TossDesignSystem.heading4/g' "$file"
    sed -i '' 's/AppTypography\.body1/TossDesignSystem.body1/g' "$file"
    sed -i '' 's/AppTypography\.body2/TossDesignSystem.body2/g' "$file"
    sed -i '' 's/AppTypography\.caption/TossDesignSystem.caption/g' "$file"
    sed -i '' 's/AppTypography\.button/TossDesignSystem.button/g' "$file"
    sed -i '' 's/AppTypography\.label/TossDesignSystem.label/g' "$file"
    
    # Replace AppSpacing references
    sed -i '' 's/AppSpacing\.xs/TossDesignSystem.spacingXS/g' "$file"
    sed -i '' 's/AppSpacing\.sm/TossDesignSystem.spacingS/g' "$file"
    sed -i '' 's/AppSpacing\.md/TossDesignSystem.spacingM/g' "$file"
    sed -i '' 's/AppSpacing\.lg/TossDesignSystem.spacingL/g' "$file"
    sed -i '' 's/AppSpacing\.xl/TossDesignSystem.spacingXL/g' "$file"
    sed -i '' 's/AppSpacing\.xxl/TossDesignSystem.spacingXXL/g' "$file"
    sed -i '' 's/AppSpacing\.spacing1/TossDesignSystem.spacingXS/g' "$file"
    sed -i '' 's/AppSpacing\.spacing2/TossDesignSystem.spacingXS/g' "$file"
    sed -i '' 's/AppSpacing\.spacing3/TossDesignSystem.spacingS/g' "$file"
    sed -i '' 's/AppSpacing\.spacing4/TossDesignSystem.spacingS/g' "$file"
    sed -i '' 's/AppSpacing\.spacing5/TossDesignSystem.spacingM/g' "$file"
    sed -i '' 's/AppSpacing\.spacing6/TossDesignSystem.spacingM/g' "$file"
    sed -i '' 's/AppSpacing\.spacing7/TossDesignSystem.spacingL/g' "$file"
    sed -i '' 's/AppSpacing\.spacing8/TossDesignSystem.spacingL/g' "$file"
    sed -i '' 's/AppSpacing\.spacing9/TossDesignSystem.spacingXL/g' "$file"
    sed -i '' 's/AppSpacing\.spacing10/TossDesignSystem.spacingXL/g' "$file"
    sed -i '' 's/AppSpacing\.spacing11/TossDesignSystem.spacingXXL/g' "$file"
    sed -i '' 's/AppSpacing\.spacing12/TossDesignSystem.spacingXXL/g' "$file"
    
    # Fortune-specific color mappings
    sed -i '' 's/FortuneColors\.primary/TossDesignSystem.tossBlue/g' "$file"
    sed -i '' 's/FortuneColors\.secondary/TossDesignSystem.gray600/g' "$file"
    sed -i '' 's/FortuneColors\.background/TossDesignSystem.gray50/g' "$file"
    sed -i '' 's/FortuneColors\.cardBackground/TossDesignSystem.white/g' "$file"
    sed -i '' 's/FortuneColors\.textPrimary/TossDesignSystem.gray900/g' "$file"
    sed -i '' 's/FortuneColors\.textSecondary/TossDesignSystem.gray600/g' "$file"
    
    echo "  ✅ Completed"
done

echo ""
echo "🔍 Checking for remaining references..."
REMAINING=$(find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f | xargs grep -l "AppTheme\|AppColors\|AppTypography\|AppSpacing" | grep -v "app_theme.dart\|app_colors.dart\|app_typography.dart\|app_spacing.dart\|app_text_styles.dart" | wc -l | xargs)

echo "📊 Migration Summary:"
echo "  - Files processed: $TOTAL"
echo "  - Files remaining: $REMAINING"
echo ""
echo "✨ Migration script complete!"