#!/bin/bash

# Pre-commit Hook: Flutter 화면 라우트 등록 체크
#
# lib/screens/ 폴더에 새 화면 파일이 추가되면
# route_config.dart에 라우트가 등록되었는지 확인합니다.
#
# 설치 방법:
#   ln -sf ../../scripts/pre-commit-screen-check.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit

# 색상 정의
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Staged된 파일 중 lib/screens/ 파일 찾기
SCREEN_FILES=$(git diff --cached --name-only --diff-filter=A | grep '^lib/screens/.*\.dart$' || true)

if [ -z "$SCREEN_FILES" ]; then
  # 새로 추가된 스크린 파일이 없으면 통과
  exit 0
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Pre-commit: 새 화면 라우트 등록 체크${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${YELLOW}📁 새로 추가된 스크린 파일:${NC}"
echo "$SCREEN_FILES" | while read -r file; do
  echo -e "  ✓ $file"
done

# 각 파일에서 클래스명 추출
UNREGISTERED_SCREENS=""

echo "$SCREEN_FILES" | while read -r file; do
  if [ -z "$file" ]; then
    continue
  fi

  # StatelessWidget, StatefulWidget 클래스 찾기
  CLASS_NAMES=$(grep -o 'class [A-Z][a-zA-Z0-9]* extends \(StatelessWidget\|StatefulWidget\|ConsumerWidget\|ConsumerStatefulWidget\)' "$file" | awk '{print $2}' || true)

  if [ -z "$CLASS_NAMES" ]; then
    continue
  fi

  # 각 클래스가 route_config.dart에 등록되었는지 확인
  for class_name in $CLASS_NAMES; do
    # route_config.dart에서 클래스 참조 찾기
    ROUTE_FILES="lib/routes/route_config.dart lib/routes/routes/*.dart"
    FOUND=false

    for route_file in $ROUTE_FILES; do
      if [ -f "$route_file" ] && grep -q "$class_name" "$route_file"; then
        FOUND=true
        break
      fi
    done

    if [ "$FOUND" = false ]; then
      echo -e "${YELLOW}⚠️  $class_name ($file) 가 라우트에 등록되지 않았습니다${NC}"
      UNREGISTERED_SCREENS="${UNREGISTERED_SCREENS}\n  - $class_name ($file)"
    fi
  done
done

if [ -n "$UNREGISTERED_SCREENS" ]; then
  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}⚠️  경고: 다음 화면이 라우트에 등록되지 않았을 수 있습니다${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "$UNREGISTERED_SCREENS"
  echo -e "\n${YELLOW}💡 lib/routes/route_config.dart 또는 하위 라우트 파일에${NC}"
  echo -e "${YELLOW}   GoRoute를 추가하거나, 위젯 컴포넌트라면 lib/core/widgets/로 이동하세요${NC}"
  echo -e "\n${GREEN}✓ 커밋은 계속 진행됩니다 (경고만 표시)${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 경고만 표시하고 커밋은 허용
exit 0
