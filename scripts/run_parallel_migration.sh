#!/bin/bash

# Parallel Theme Migration Script
# Processes files in batches for maximum efficiency

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MIGRATION_SCRIPT="$SCRIPT_DIR/migrate_theme_batch.dart"

# Function to process a batch of files
process_batch() {
    local batch_name=$1
    shift
    local files=("$@")
    
    echo "🚀 Starting batch: $batch_name"
    dart "$MIGRATION_SCRIPT" "${files[@]}"
    echo "✅ Completed batch: $batch_name"
}

# Fortune Feature Pages - Batch processing
echo "📦 Processing Fortune Feature Pages..."

# Batch A: AI and Career Fortune Pages
batch_a=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/ai_comprehensive_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/career_change_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/career_crisis_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/career_future_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/freelance_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/startup_career_fortune_page.dart"
)

# Batch B: Traditional and Time-based Fortune Pages
batch_b=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/traditional_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/traditional_fortune_result_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/traditional_fortune_enhanced_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/time_based_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/hourly_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/daily_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/today_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/tomorrow_fortune_page.dart"
)

# Batch C: Personality and Compatibility Pages
batch_c=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/personality_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/personality_fortune_enhanced_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/personality_fortune_optimized_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/personality_fortune_result_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/compatibility_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/traditional_compatibility_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/chemistry_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/chemistry_fortune_page.dart"
)

# Batch D: Dream and Pet Fortune Pages
batch_d=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/dream_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/dream_fortune_chat_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/dream_fortune_flow_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/pet_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/physiognomy_input_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/physiognomy_result_page.dart"
)

# Batch E: Health and Family Fortune Pages
batch_e=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/health_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/health_sports_unified_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/family_fortune_unified_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/children_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/love_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/marriage_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/ex_lover_fortune_result_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart"
)

# Batch F: Investment and Financial Fortune Pages
batch_f=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/investment_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/investment_fortune_result_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/investment_fortune_enhanced_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/investment_fortune_unified_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lottery_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_investment_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_stock_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_lottery_fortune_page.dart"
)

# Batch G: Moving and Location Fortune Pages
batch_g=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/moving_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/moving_fortune_enhanced_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/moving_fortune_unified_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/moving_date_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_place_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_realestate_fortune_page.dart"
)

# Batch H: Lucky Items and Sports Fortune Pages
batch_h=(
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_items_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_items_unified_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_color_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/lucky_number_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/sports_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/enhanced_sports_fortune_page.dart"
    "$PROJECT_DIR/lib/features/fortune/presentation/pages/sports_player_fortune_page.dart"
)

# Shared Components
echo "📦 Processing Shared Components..."

# Find all shared component files
shared_components=$(find "$PROJECT_DIR/lib/shared/components" -name "*.dart" -type f | head -20)
shared_widgets=$(find "$PROJECT_DIR/lib/shared/widgets" -name "*.dart" -type f | head -20)

# Process batches in parallel using background jobs
process_batch "Batch A - AI & Career" "${batch_a[@]}" &
process_batch "Batch B - Traditional & Time" "${batch_b[@]}" &
process_batch "Batch C - Personality & Compatibility" "${batch_c[@]}" &
process_batch "Batch D - Dream & Pet" "${batch_d[@]}" &

# Wait for first set of batches
wait

# Process second set
process_batch "Batch E - Health & Family" "${batch_e[@]}" &
process_batch "Batch F - Investment & Financial" "${batch_f[@]}" &
process_batch "Batch G - Moving & Location" "${batch_g[@]}" &
process_batch "Batch H - Lucky Items & Sports" "${batch_h[@]}" &

# Wait for second set
wait

# Process shared components
if [ ! -z "$shared_components" ]; then
    process_batch "Shared Components" $shared_components &
fi

if [ ! -z "$shared_widgets" ]; then
    process_batch "Shared Widgets" $shared_widgets &
fi

# Wait for all background jobs to complete
wait

echo "✅ All batches completed!"

# Run flutter analyze to check for issues
echo "🔍 Running flutter analyze..."
cd "$PROJECT_DIR"
flutter analyze --no-fatal-infos

echo "🎉 Migration complete!"