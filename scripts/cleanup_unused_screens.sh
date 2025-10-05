#!/bin/bash

# Flutter 미사용 스크린 자동 정리 스크립트
#
# 사용법:
#   ./scripts/cleanup_unused_screens.sh
#   ./scripts/cleanup_unused_screens.sh --dry-run  # 실제 이동 없이 시뮬레이션만
#   ./scripts/cleanup_unused_screens.sh --auto     # 확인 없이 자동 실행

set -e  # 에러 발생 시 즉시 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 플래그 파싱
DRY_RUN=false
AUTO_MODE=false

for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --auto)
      AUTO_MODE=true
      shift
      ;;
  esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧹 Flutter 미사용 스크린 자동 정리 시스템${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}⚠️  DRY RUN 모드: 실제 파일 이동 없이 시뮬레이션만 실행합니다${NC}"
fi

# 1. 정적 분석 실행
echo -e "\n${BLUE}📊 1단계: 정적 분석 실행 중...${NC}"
if ! dart run tools/screen_analyzer.dart --output /tmp/screen_analysis.json; then
  echo -e "${RED}❌ 정적 분석 실패${NC}"
  exit 1
fi

# 2. 분석 결과 파싱
if [ ! -f "/tmp/screen_analysis.json" ]; then
  echo -e "${RED}❌ 분석 결과 파일을 찾을 수 없습니다${NC}"
  exit 1
fi

# jq가 없으면 python으로 대체
if command -v jq &> /dev/null; then
  UNUSED_COUNT=$(jq '.summary.unused_screens' /tmp/screen_analysis.json)
  UNUSED_FILES=$(jq -r '.unused_list[].file' /tmp/screen_analysis.json)
else
  UNUSED_COUNT=$(python3 -c "import json; data=json.load(open('/tmp/screen_analysis.json')); print(data['summary']['unused_screens'])")
  UNUSED_FILES=$(python3 -c "import json; data=json.load(open('/tmp/screen_analysis.json')); print('\n'.join([item['file'] for item in data['unused_list']]))")
fi

echo -e "${GREEN}✅ 분석 완료: ${UNUSED_COUNT}개 미사용 스크린 발견${NC}"

if [ "$UNUSED_COUNT" -eq 0 ]; then
  echo -e "${GREEN}🎉 정리할 미사용 스크린이 없습니다!${NC}"
  exit 0
fi

# 3. 미사용 파일 목록 출력
echo -e "\n${YELLOW}📝 미사용 스크린 목록:${NC}"
echo "$UNUSED_FILES" | while read -r file; do
  if [ -n "$file" ]; then
    echo -e "  ${RED}✗${NC} $file"
  fi
done

# 4. 사용자 확인 (AUTO_MODE가 아닐 때)
if [ "$AUTO_MODE" = false ] && [ "$DRY_RUN" = false ]; then
  echo -e "\n${YELLOW}⚠️  위 파일들을 lib/screens_unused/로 이동하시겠습니까?${NC}"
  echo -e "${YELLOW}   (이동 후 dart analyze로 에러 체크하며, 에러 시 자동 롤백됩니다)${NC}"
  read -p "계속하시겠습니까? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}취소되었습니다${NC}"
    exit 0
  fi
fi

# 5. 백업 브랜치 생성 (DRY_RUN이 아닐 때)
if [ "$DRY_RUN" = false ]; then
  BACKUP_BRANCH="backup/unused-screens-cleanup-$(date +%Y%m%d-%H%M%S)"
  echo -e "\n${BLUE}💾 2단계: 백업 브랜치 생성 중...${NC}"
  git branch "$BACKUP_BRANCH"
  echo -e "${GREEN}✅ 백업 브랜치 생성: $BACKUP_BRANCH${NC}"
fi

# 6. lib/screens_unused/ 폴더 생성
UNUSED_DIR="lib/screens_unused"
if [ "$DRY_RUN" = false ]; then
  echo -e "\n${BLUE}📁 3단계: $UNUSED_DIR 폴더 생성 중...${NC}"
  mkdir -p "$UNUSED_DIR"
  echo -e "${GREEN}✅ 폴더 생성 완료${NC}"
fi

# 7. 파일 이동
echo -e "\n${BLUE}🚚 4단계: 파일 이동 중...${NC}"
MOVE_COUNT=0

echo "$UNUSED_FILES" | while read -r file; do
  if [ -z "$file" ]; then
    continue
  fi

  if [ ! -f "$file" ]; then
    echo -e "${YELLOW}⚠️  파일이 존재하지 않음: $file${NC}"
    continue
  fi

  # 파일명 추출
  filename=$(basename "$file")
  target="$UNUSED_DIR/$filename"

  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${BLUE}[시뮬레이션]${NC} $file → $target"
  else
    echo -e "  ${GREEN}✓${NC} $file → $target"
    git mv "$file" "$target"
  fi

  MOVE_COUNT=$((MOVE_COUNT + 1))
done

echo -e "${GREEN}✅ ${MOVE_COUNT}개 파일 이동 완료${NC}"

# 8. dart analyze 실행 (DRY_RUN이 아닐 때)
if [ "$DRY_RUN" = false ]; then
  echo -e "\n${BLUE}🔍 5단계: dart analyze 실행 중...${NC}"

  if ! flutter analyze 2>&1 | head -50; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ dart analyze 에러 발생!${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🔄 자동 롤백 중...${NC}"

    # 변경사항 되돌리기
    git restore --staged .
    git restore .

    echo -e "${GREEN}✅ 롤백 완료${NC}"
    echo -e "${YELLOW}💡 일부 파일이 실제로 사용 중일 수 있습니다. screen_analysis_result.json을 확인하세요.${NC}"
    exit 1
  fi

  echo -e "${GREEN}✅ dart analyze 통과${NC}"
fi

# 9. 결과 요약
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 정리 완료!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$DRY_RUN" = false ]; then
  echo -e "${GREEN}✓${NC} ${MOVE_COUNT}개 파일이 $UNUSED_DIR 로 이동되었습니다"
  echo -e "${GREEN}✓${NC} dart analyze 통과"
  echo -e "${GREEN}✓${NC} 백업 브랜치: $BACKUP_BRANCH"

  echo -e "\n${YELLOW}💡 다음 단계:${NC}"
  echo -e "  1. 앱을 실행하여 정상 동작하는지 확인"
  echo -e "  2. 확인 후 커밋:"
  echo -e "     ${BLUE}./scripts/git_jira_commit.sh \"Remove ${MOVE_COUNT} unused screens\" \"KAN-92\" \"done\"${NC}"
  echo -e "  3. 롤백이 필요하다면:"
  echo -e "     ${BLUE}git restore . && git checkout $BACKUP_BRANCH${NC}"
else
  echo -e "${BLUE}[시뮬레이션]${NC} ${MOVE_COUNT}개 파일 이동 예정"
  echo -e "\n${YELLOW}💡 실제 실행하려면:${NC}"
  echo -e "  ${BLUE}./scripts/cleanup_unused_screens.sh${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
