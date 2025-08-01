#!/bin/bash

# Script to migrate remaining files that need theme migration

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
    
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No files to process in $batch_name${NC}"
        return
    fi
    
    echo -e "${YELLOW}🚀 Starting batch: $batch_name (${#files[@]} files)${NC}"
    dart "$MIGRATION_SCRIPT" "${files[@]}"
    echo -e "${GREEN}✅ Completed batch: $batch_name${NC}"
}

# Find remaining files that need migration
echo -e "${GREEN}📦 Finding remaining files that need migration...${NC}"

# Screens directory
screens_files=($(find "$PROJECT_DIR/lib/screens" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | head -30))

# Services directory
services_files=($(find "$PROJECT_DIR/lib/services" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | head -20))

# Core directory (excluding theme)
core_files=($(find "$PROJECT_DIR/lib/core" -name "*.dart" -type f -not -path "*/theme/*" -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | head -20))

# Data directory
data_files=($(find "$PROJECT_DIR/lib/data" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | head -20))

# Domain directory  
domain_files=($(find "$PROJECT_DIR/lib/domain" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | head -20))

# Features (other than fortune)
other_features=($(find "$PROJECT_DIR/lib/features" -name "*.dart" -type f -not -path "*/fortune/*" -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | head -30))

# Process in parallel batches
process_batch "Screens Batch 1" "${screens_files[@]:0:15}" &
process_batch "Screens Batch 2" "${screens_files[@]:15:15}" &
process_batch "Services" "${services_files[@]}" &
process_batch "Core Components" "${core_files[@]}" &

wait

process_batch "Data Layer" "${data_files[@]}" &
process_batch "Domain Layer" "${domain_files[@]}" &
process_batch "Other Features Batch 1" "${other_features[@]:0:15}" &
process_batch "Other Features Batch 2" "${other_features[@]:15:15}" &

wait

# Additional specific directories
echo -e "${GREEN}📦 Processing additional directories...${NC}"

# Routes
routes_files=($(find "$PROJECT_DIR/lib/routes" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)"))
process_batch "Routes" "${routes_files[@]}"

# Presentation providers
providers_files=($(find "$PROJECT_DIR/lib/presentation/providers" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)"))
process_batch "Providers" "${providers_files[@]}"

echo -e "${GREEN}✅ All remaining batches completed!${NC}"

# Generate final migration report
echo -e "${YELLOW}📊 Generating final migration report...${NC}"

# Count successfully migrated files
total_migrated=$(grep -l "AppSpacing\|AppDimensions\|AppTypography" \
    "$PROJECT_DIR/lib/"**/*.dart 2>/dev/null | wc -l)

# Count remaining files
remaining=$(find "$PROJECT_DIR/lib" -name "*.dart" -type f -exec grep -l "EdgeInsets\.all(\|SizedBox(height: [0-9]\|BorderRadius\.circular(" {} \; | grep -v -E "(AppSpacing|AppDimensions|AppTypography)" | wc -l)

echo -e "${GREEN}📊 Final Migration Report:${NC}"
echo "   Total migrated files: $total_migrated"
echo "   Remaining files: $remaining"
echo "   Migration success rate: $((total_migrated * 100 / (total_migrated + remaining)))%"

# Run flutter analyze
echo -e "${YELLOW}🔍 Running flutter analyze...${NC}"
cd "$PROJECT_DIR"
flutter analyze --no-fatal-infos | grep -E "(error|warning)" | head -20

echo -e "${GREEN}🎉 Migration phase complete!${NC}"