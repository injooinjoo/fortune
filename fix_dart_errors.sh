#!/bin/bash

# Fortune page dart files 에러 수정 스크립트

echo "Starting Flutter error fixes..."

# 파일 목록
FILES=(
  "lib/features/fortune/presentation/pages/lucky_number_fortune_page.dart"
  "lib/features/fortune/presentation/pages/lucky_color_fortune_page.dart" 
  "lib/features/fortune/presentation/pages/dream_fortune_page.dart"
  "lib/features/fortune/presentation/pages/celebrity_compatibility_page.dart"
  "lib/data/constants/celebrity_database_enhanced.dart"
  "lib/features/fortune/presentation/pages/investment_fortune_enhanced_page.dart"
  "lib/features/fortune/presentation/pages/traditional_saju_fortune_page.dart"
  "lib/features/fortune/presentation/pages/saju_psychology_fortune_page.dart"
  "lib/features/fortune/presentation/pages/sports_player_fortune_page.dart"
  "lib/features/fortune/presentation/pages/investment_fortune_page.dart"
  "lib/features/fortune/presentation/pages/traditional_fortune_unified_page.dart"
  "lib/features/fortune/presentation/pages/lottery_fortune_page.dart"
  "lib/features/fortune/presentation/pages/traditional_fortune_enhanced_page.dart"
  "lib/features/fortune/presentation/pages/lucky_place_fortune_page.dart"
  "lib/features/fortune/presentation/pages/ex_lover_fortune_result_page.dart"
)

# celebrity_database_enhanced.dart의 keywords 배열 수정
echo "Fixing keywords arrays in celebrity_database_enhanced.dart..."
if [ -f "lib/data/constants/celebrity_database_enhanced.dart" ]; then
  # ':' 구분자를 ',' 로 변경
  sed -i '' "s/keywords: \['\([^']*\)': '\([^']*\)': '\([^']*\)'/keywords: ['\1', '\2', '\3'/g" lib/data/constants/celebrity_database_enhanced.dart
  sed -i '' "s/keywords: \['\([^']*\)': '\([^']*\)'/keywords: ['\1', '\2'/g" lib/data/constants/celebrity_database_enhanced.dart
fi

# 모든 파일에서 공통 패턴 수정
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing $file..."
    
    # return const SizedBox.shrink(), 패턴 수정
    sed -i '' 's/return const SizedBox\.shrink(),$/return const SizedBox.shrink();/g' "$file"
    
    # 중복된 세미콜론 및 쉼표 수정
    sed -i '' 's/),;$/);/g' "$file"
    sed -i '' 's/};$/}/g' "$file"
    
    # null}, 패턴 수정
    sed -i '' 's/: null},$/],/g' "$file"
    sed -i '' 's/: null}};$/]\n    }\n  };/g' "$file"
    
    # 잘못된 if 문 세미콜론 수정 
    sed -i '' 's/if (.*) return const SizedBox\.shrink(),/if \1 return const SizedBox.shrink();/g' "$file"
    
    # 잘못된 줄바꿈 수정
    sed -i '' 's/,\\n            /;\n    /g' "$file"
  fi
done

echo "Basic error fixes completed. Running Flutter analyze..."
flutter analyze lib/features/fortune/presentation/pages/ 2>&1 | grep -c "error"
echo " errors remaining."