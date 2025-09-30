#!/bin/bash

# Fortune 페이지 버튼 표준화 스크립트

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Fortune 페이지 버튼 표준화 시작...${NC}"

# Fortune 페이지 디렉토리
FORTUNE_DIR="/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages"

# 1. Import 추가가 필요한 파일들 찾기
echo -e "${YELLOW}1. fortune_button_spacing import 추가...${NC}"

for file in "$FORTUNE_DIR"/*.dart; do
  filename=$(basename "$file")
  
  # 이미 처리된 파일은 건너뛰기
  if grep -q "fortune_button_spacing" "$file"; then
    echo "  ✓ $filename - 이미 import 있음"
    continue
  fi
  
  # TossButton 또는 ElevatedButton이 있는 파일만 처리
  if grep -qE "(TossButton|ElevatedButton|OutlinedButton|TextButton)" "$file"; then
    # import 추가
    sed -i '' "/import '.*toss_theme.dart';/a\\
import '../constants/fortune_button_spacing.dart';" "$file"
    echo -e "  ${GREEN}✓${NC} $filename - import 추가됨"
  fi
done

echo -e "${YELLOW}2. ElevatedButton을 TossButton으로 변경...${NC}"

# ElevatedButton 패턴 변경
for file in "$FORTUNE_DIR"/*.dart; do
  filename=$(basename "$file")
  
  if grep -q "ElevatedButton" "$file"; then
    # ElevatedButton → TossButton 변경
    sed -i '' 's/ElevatedButton(/TossButton(/g' "$file"
    sed -i '' 's/ElevatedButton\.styleFrom/TossButtonStyle/g' "$file"
    
    # onPressed 패턴 유지
    sed -i '' 's/child: Text(/text: /g' "$file"
    
    echo -e "  ${GREEN}✓${NC} $filename - ElevatedButton 변경됨"
  fi
done

echo -e "${YELLOW}3. OutlinedButton을 TossButton으로 변경...${NC}"

for file in "$FORTUNE_DIR"/*.dart; do
  filename=$(basename "$file")
  
  if grep -q "OutlinedButton" "$file"; then
    # OutlinedButton → TossButton with secondary style
    sed -i '' 's/OutlinedButton(/TossButton(/g' "$file"
    
    echo -e "  ${GREEN}✓${NC} $filename - OutlinedButton 변경됨"
  fi
done

echo -e "${YELLOW}4. TextButton을 TossButton으로 변경...${NC}"

for file in "$FORTUNE_DIR"/*.dart; do
  filename=$(basename "$file")
  
  if grep -q "TextButton" "$file"; then
    # TextButton → TossButton with tertiary style
    sed -i '' 's/TextButton(/TossButton(/g' "$file"
    
    echo -e "  ${GREEN}✓${NC} $filename - TextButton 변경됨"
  fi
done

echo -e "${YELLOW}5. 버튼 간격 상수 적용...${NC}"

for file in "$FORTUNE_DIR"/*.dart; do
  filename=$(basename "$file")
  
  # SizedBox 간격 표준화
  if grep -qE "SizedBox\(height: (32|40)\)" "$file"; then
    sed -i '' 's/SizedBox(height: 32)/SizedBox(height: FortuneButtonSpacing.buttonTopSpacing)/g' "$file"
    sed -i '' 's/SizedBox(height: 40)/SizedBox(height: FortuneButtonSpacing.buttonTopSpacing)/g' "$file"
    
    echo -e "  ${GREEN}✓${NC} $filename - 간격 표준화됨"
  fi
done

echo -e "${GREEN}완료! Fortune 페이지 버튼 표준화가 완료되었습니다.${NC}"
echo -e "${YELLOW}변경된 파일 수:${NC}"
git status --porcelain | grep -c "^ M"