#!/bin/bash

# Advanced Parallel Theme Migration Script
# Processes files in batches with better pattern matching

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MIGRATION_SCRIPT="$SCRIPT_DIR/migrate_theme_advanced.dart"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to process a batch of files
process_batch() {
    local batch_name=$1
    shift
    local files=("$@")
    
    echo -e "${YELLOW}🚀 Starting batch: $batch_name${NC}"
    dart "$MIGRATION_SCRIPT" "${files[@]}"
    echo -e "${GREEN}✅ Completed batch: $batch_name${NC}"
}

# Create file lists for each batch
echo -e "${GREEN}📦 Preparing file batches...${NC}"

# Fortune Feature Pages
fortune_pages=($(find "$PROJECT_DIR/lib/features/fortune/presentation/pages" -name "*.dart" -type f | grep -v "test"))

# Split fortune pages into smaller batches
batch_size=15
total_files=${#fortune_pages[@]}
num_batches=$(( (total_files + batch_size - 1) / batch_size ))

echo -e "${YELLOW}Found $total_files fortune pages, splitting into $num_batches batches${NC}"

# Process fortune pages in parallel batches
for ((i=0; i<num_batches; i++)); do
    start=$((i * batch_size))
    end=$((start + batch_size))
    if [ $end -gt $total_files ]; then
        end=$total_files
    fi
    
    batch_files=("${fortune_pages[@]:$start:$((end-start))}")
    process_batch "Fortune Pages Batch $((i+1))" "${batch_files[@]}" &
    
    # Limit parallel processes to prevent system overload
    if [ $((i % 4)) -eq 3 ]; then
        wait
    fi
done

# Wait for remaining fortune page batches
wait

# Shared Components and Widgets
echo -e "${GREEN}📦 Processing Shared Components...${NC}"

shared_components=($(find "$PROJECT_DIR/lib/shared/components" -name "*.dart" -type f 2>/dev/null))
shared_widgets=($(find "$PROJECT_DIR/lib/shared/widgets" -name "*.dart" -type f 2>/dev/null))

if [ ${#shared_components[@]} -gt 0 ]; then
    process_batch "Shared Components" "${shared_components[@]}" &
fi

if [ ${#shared_widgets[@]} -gt 0 ]; then
    process_batch "Shared Widgets" "${shared_widgets[@]}" &
fi

# Presentation Widgets
presentation_widgets=($(find "$PROJECT_DIR/lib/presentation/widgets" -name "*.dart" -type f 2>/dev/null))
if [ ${#presentation_widgets[@]} -gt 0 ]; then
    echo -e "${GREEN}📦 Processing Presentation Widgets...${NC}"
    
    # Split presentation widgets into batches
    pw_batch_size=20
    pw_total=${#presentation_widgets[@]}
    pw_num_batches=$(( (pw_total + pw_batch_size - 1) / pw_batch_size ))
    
    for ((i=0; i<pw_num_batches; i++)); do
        start=$((i * pw_batch_size))
        end=$((start + pw_batch_size))
        if [ $end -gt $pw_total ]; then
            end=$pw_total
        fi
        
        batch_files=("${presentation_widgets[@]:$start:$((end-start))}")
        process_batch "Presentation Widgets Batch $((i+1))" "${batch_files[@]}" &
        
        if [ $((i % 4)) -eq 3 ]; then
            wait
        fi
    done
fi

# Wait for all background jobs to complete
wait

echo -e "${GREEN}✅ All batches completed!${NC}"

# Generate migration report
echo -e "${YELLOW}📊 Generating migration report...${NC}"

# Count files that were successfully migrated
migrated_count=$(grep -l "AppSpacing\|AppDimensions\|AppTypography" \
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/"*.dart \
    "$PROJECT_DIR/lib/shared/components/"*.dart \
    "$PROJECT_DIR/lib/shared/widgets/"*.dart \
    "$PROJECT_DIR/lib/presentation/widgets/"*.dart 2>/dev/null | wc -l)

echo -e "${GREEN}📊 Migration Report:${NC}"
echo "   Total fortune pages: $total_files"
echo "   Shared components: ${#shared_components[@]}"
echo "   Shared widgets: ${#shared_widgets[@]}"
echo "   Presentation widgets: ${#presentation_widgets[@]}"
echo "   Successfully migrated: $migrated_count files"

# Run flutter analyze to check for issues
echo -e "${YELLOW}🔍 Running flutter analyze...${NC}"
cd "$PROJECT_DIR"
flutter analyze --no-fatal-infos | grep -E "(error|warning)" | head -20

echo -e "${GREEN}🎉 Migration phase complete!${NC}"