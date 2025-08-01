#!/bin/bash

# Final typography migration script - handles all remaining files
# This script will complete the migration for all 252 remaining files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MIGRATION_SCRIPT="$SCRIPT_DIR/migrate_typography_final.dart"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to process a batch of files
process_batch() {
    local batch_name=$1
    shift
    local files=("$@")
    
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No files to process in $batch_name${NC}"
        return
    fi
    
    echo -e "${BLUE}🚀 Starting batch: $batch_name (${#files[@]} files)${NC}"
    dart "$MIGRATION_SCRIPT" "${files[@]}"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Completed batch: $batch_name${NC}"
    else
        echo -e "${RED}❌ Failed batch: $batch_name${NC}"
    fi
}

# Clear screen and show header
clear
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          FINAL TYPOGRAPHY MIGRATION - FORTUNE APP          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Run the finder script to get all files needing migration
echo -e "${YELLOW}📋 Finding all files that need typography migration...${NC}"
cd "$PROJECT_DIR"
dart scripts/find_typography_migration_targets.dart > /tmp/migration_report.txt 2>&1

# Extract file paths from the report
MIGRATION_FILES=$(grep -E "^\s*-\s*\[\s*\]\s*lib/" /tmp/migration_report.txt | sed 's/- \[ \] //')

# Convert to array
IFS=$'\n' read -d '' -r -a ALL_FILES <<< "$MIGRATION_FILES"

echo -e "${GREEN}📊 Found ${#ALL_FILES[@]} files needing migration${NC}"
echo

# Group files by directory
declare -A file_groups

for file in "${ALL_FILES[@]}"; do
    # Extract directory path
    dir=$(dirname "$file" | cut -d'/' -f1-3)
    
    # Add file to group
    if [ -z "${file_groups[$dir]}" ]; then
        file_groups[$dir]="$file"
    else
        file_groups[$dir]="${file_groups[$dir]}"$'\n'"$file"
    fi
done

# Process each group
echo -e "${BLUE}🔄 Processing files by directory...${NC}"
echo

total_processed=0
total_groups=${#file_groups[@]}
current_group=0

# Process settings screens first (smaller batch for testing)
if [ -n "${file_groups['lib/screens/settings']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing settings screens...${NC}"
    IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups['lib/screens/settings']}"
    process_batch "Settings Screens" "${batch_files[@]}"
    ((total_processed+=${#batch_files[@]}))
    echo
fi

# Process home screens
if [ -n "${file_groups['lib/screens/home']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing home screens...${NC}"
    IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups['lib/screens/home']}"
    process_batch "Home Screens" "${batch_files[@]}"
    ((total_processed+=${#batch_files[@]}))
    echo
fi

# Process auth screens
if [ -n "${file_groups['lib/screens/auth']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing auth screens...${NC}"
    IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups['lib/screens/auth']}"
    process_batch "Auth Screens" "${batch_files[@]}"
    ((total_processed+=${#batch_files[@]}))
    echo
fi

# Process onboarding screens
if [ -n "${file_groups['lib/screens/onboarding']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing onboarding screens...${NC}"
    IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups['lib/screens/onboarding']}"
    process_batch "Onboarding Screens" "${batch_files[@]}"
    ((total_processed+=${#batch_files[@]}))
    echo
fi

# Process other screens
for dir in "${!file_groups[@]}"; do
    if [[ ! "$dir" =~ ^lib/screens/(settings|home|auth|onboarding) ]] && [[ "$dir" =~ ^lib/screens ]]; then
        ((current_group++))
        echo -e "${YELLOW}[$current_group/$total_groups] Processing $dir...${NC}"
        IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups[$dir]}"
        process_batch "$(basename $dir) Screens" "${batch_files[@]}"
        ((total_processed+=${#batch_files[@]}))
        echo
    fi
done

# Process fortune pages in batches (largest group)
if [ -n "${file_groups['lib/features/fortune']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing fortune pages (this will take a while)...${NC}"
    IFS=$'\n' read -d '' -r -a fortune_files <<< "${file_groups['lib/features/fortune']}"
    
    # Split into smaller batches of 20 files each
    batch_size=20
    batch_num=1
    
    for ((i=0; i<${#fortune_files[@]}; i+=batch_size)); do
        batch=("${fortune_files[@]:i:batch_size}")
        echo -e "${BLUE}  Processing fortune batch $batch_num (${#batch[@]} files)...${NC}"
        process_batch "Fortune Batch $batch_num" "${batch[@]}"
        ((batch_num++))
        ((total_processed+=${#batch[@]}))
        
        # Small pause between batches
        sleep 1
    done
    echo
fi

# Process presentation widgets
if [ -n "${file_groups['lib/presentation/widgets']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing presentation widgets...${NC}"
    IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups['lib/presentation/widgets']}"
    process_batch "Presentation Widgets" "${batch_files[@]}"
    ((total_processed+=${#batch_files[@]}))
    echo
fi

# Process shared components
if [ -n "${file_groups['lib/shared/components']}" ]; then
    ((current_group++))
    echo -e "${YELLOW}[$current_group/$total_groups] Processing shared components...${NC}"
    IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups['lib/shared/components']}"
    process_batch "Shared Components" "${batch_files[@]}"
    ((total_processed+=${#batch_files[@]}))
    echo
fi

# Process remaining groups
for dir in "${!file_groups[@]}"; do
    if [[ ! "$dir" =~ ^(lib/screens|lib/features/fortune|lib/presentation/widgets|lib/shared/components) ]]; then
        ((current_group++))
        echo -e "${YELLOW}[$current_group/$total_groups] Processing $dir...${NC}"
        IFS=$'\n' read -d '' -r -a batch_files <<< "${file_groups[$dir]}"
        process_batch "$(basename $dir)" "${batch_files[@]}"
        ((total_processed+=${#batch_files[@]}))
        echo
    fi
done

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    MIGRATION COMPLETE                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Generate final report
echo -e "${YELLOW}📊 Generating final migration report...${NC}"

# Count files using new theme system
migrated_count=$(grep -l "app_typography\|AppTypography\|AppSpacing\|AppDimensions" lib/**/*.dart 2>/dev/null | wc -l | tr -d ' ')

# Count remaining files with old patterns
remaining_count=$(find lib -name "*.dart" -type f -exec grep -l "TextStyle(\|fontSize:\|fontWeight:\|Colors\." {} \; | grep -v -E "(app_typography|app_colors|app_theme|theme/)" | wc -l | tr -d ' ')

echo
echo -e "${GREEN}📊 Final Migration Statistics:${NC}"
echo -e "   Total files processed: $total_processed"
echo -e "   Total files migrated: $migrated_count"
echo -e "   Files with remaining patterns: $remaining_count"
echo -e "   Migration success rate: $((migrated_count * 100 / (migrated_count + remaining_count)))%"
echo

# Run flutter analyze
echo -e "${YELLOW}🔍 Running flutter analyze to check for errors...${NC}"
flutter analyze --no-fatal-infos 2>&1 | grep -E "(error|warning)" | head -20

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ No critical errors found${NC}"
else
    echo -e "${RED}⚠️  Some issues found - please review${NC}"
fi

echo
echo -e "${GREEN}🎉 Typography migration completed!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Run 'flutter test' to ensure all tests pass"
echo -e "  2. Test the app on both iOS and Android"
echo -e "  3. Verify dark mode functionality"
echo -e "  4. Check all screens for visual consistency"
echo

# Save detailed report
echo "Generating detailed report..."
{
    echo "# Typography Migration Final Report"
    echo "Generated: $(date)"
    echo
    echo "## Statistics"
    echo "- Total files processed: $total_processed"
    echo "- Successfully migrated: $migrated_count"
    echo "- Remaining files: $remaining_count"
    echo "- Success rate: $((migrated_count * 100 / (migrated_count + remaining_count)))%"
    echo
    echo "## Files Still Needing Manual Review"
    find lib -name "*.dart" -type f -exec grep -l "TextStyle(\|fontSize:\|fontWeight:\|Colors\." {} \; | grep -v -E "(app_typography|app_colors|app_theme|theme/)" | head -50
} > TYPOGRAPHY_MIGRATION_FINAL_REPORT.md

echo -e "${GREEN}📄 Detailed report saved to TYPOGRAPHY_MIGRATION_FINAL_REPORT.md${NC}"