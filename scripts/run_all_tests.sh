#!/bin/bash

# Ondo - 전체 테스트 실행 스크립트
# 사용법: ./scripts/run_all_tests.sh [options]
# 옵션:
#   --unit       Unit 테스트만 실행
#   --widget     Widget 테스트만 실행
#   --integration Integration 테스트만 실행 (디바이스 필요)
#   --consistency 코드 통일성 가드 실행
#   --coverage   커버리지 리포트 생성
#   --ci         CI 환경용 (Integration 테스트 제외, consistency 포함)

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 결과 저장
UNIT_RESULT=0
WIDGET_RESULT=0
INTEGRATION_RESULT=0
CONSISTENCY_RESULT=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Ondo - 테스트 실행기${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 옵션 파싱
RUN_UNIT=false
RUN_WIDGET=false
RUN_INTEGRATION=false
RUN_CONSISTENCY=false
RUN_COVERAGE=false
CI_MODE=false

if [ $# -eq 0 ]; then
  # 옵션 없으면 전체 실행
  RUN_UNIT=true
  RUN_WIDGET=true
  RUN_INTEGRATION=true
fi

for arg in "$@"; do
  case $arg in
    --unit)
      RUN_UNIT=true
      ;;
    --widget)
      RUN_WIDGET=true
      ;;
    --integration)
      RUN_INTEGRATION=true
      ;;
    --consistency)
      RUN_CONSISTENCY=true
      ;;
    --coverage)
      RUN_COVERAGE=true
      RUN_UNIT=true
      RUN_WIDGET=true
      ;;
    --ci)
      CI_MODE=true
      RUN_UNIT=true
      RUN_WIDGET=true
      RUN_INTEGRATION=false
      RUN_CONSISTENCY=true
      ;;
  esac
done

# 프로젝트 루트로 이동
cd "$(dirname "$0")/.."

# 1. Unit Tests
if [ "$RUN_UNIT" = true ]; then
  echo -e "${YELLOW}📦 [1/3] Unit Tests 실행 중...${NC}"
  echo "────────────────────────────────────────────────"

  if flutter test test/unit/ --reporter expanded 2>/dev/null; then
    UNIT_RESULT=0
    echo -e "${GREEN}✅ Unit Tests 통과${NC}"
  else
    UNIT_RESULT=1
    echo -e "${RED}❌ Unit Tests 실패${NC}"
  fi
  echo ""
fi

# 2. Widget Tests
if [ "$RUN_WIDGET" = true ]; then
  echo -e "${YELLOW}🎨 [2/3] Widget Tests 실행 중...${NC}"
  echo "────────────────────────────────────────────────"

  if flutter test test/widget/ --reporter expanded 2>/dev/null; then
    WIDGET_RESULT=0
    echo -e "${GREEN}✅ Widget Tests 통과${NC}"
  else
    WIDGET_RESULT=1
    echo -e "${RED}❌ Widget Tests 실패${NC}"
  fi
  echo ""
fi

# 3. Integration Tests (디바이스 필요)
if [ "$RUN_INTEGRATION" = true ]; then
  echo -e "${YELLOW}🔄 [3/3] Integration Tests 실행 중...${NC}"
  echo "────────────────────────────────────────────────"
  echo -e "${BLUE}ℹ️  시뮬레이터/디바이스가 필요합니다${NC}"

  # 연결된 디바이스 확인
  DEVICES=$(flutter devices --machine 2>/dev/null | grep -c '"id"' || echo "0")

  if [ "$DEVICES" -gt 0 ]; then
    if flutter test integration_test/ --reporter expanded 2>/dev/null; then
      INTEGRATION_RESULT=0
      echo -e "${GREEN}✅ Integration Tests 통과${NC}"
    else
      INTEGRATION_RESULT=1
      echo -e "${RED}❌ Integration Tests 실패${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  연결된 디바이스가 없어 건너뜁니다${NC}"
    echo -e "${BLUE}   시뮬레이터 실행: open -a Simulator${NC}"
    INTEGRATION_RESULT=2  # Skipped
  fi
  echo ""
fi

# 4. Consistency Guard (선택적)
if [ "$RUN_CONSISTENCY" = true ]; then
  echo -e "${YELLOW}🛡️  [4/5] Code Consistency Guard 실행 중...${NC}"
  echo "────────────────────────────────────────────────"

  if ./scripts/check_code_consistency.sh; then
    CONSISTENCY_RESULT=0
    echo -e "${GREEN}✅ Consistency Guard 통과${NC}"
  else
    CONSISTENCY_RESULT=1
    echo -e "${RED}❌ Consistency Guard 실패${NC}"
  fi
  echo ""
fi

# 5. Coverage Report (선택적)
if [ "$RUN_COVERAGE" = true ]; then
  echo -e "${YELLOW}📊 Coverage 리포트 생성 중...${NC}"
  echo "────────────────────────────────────────────────"

  flutter test --coverage test/

  if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ Coverage 리포트: coverage/html/index.html${NC}"
  else
    echo -e "${YELLOW}ℹ️  genhtml 없음. lcov 설치: brew install lcov${NC}"
  fi
  echo ""
fi

# 결과 요약
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   테스트 결과 요약${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

print_result() {
  local name=$1
  local result=$2

  if [ "$result" -eq 0 ]; then
    echo -e "  $name: ${GREEN}✅ PASS${NC}"
  elif [ "$result" -eq 2 ]; then
    echo -e "  $name: ${YELLOW}⏭️  SKIP${NC}"
  else
    echo -e "  $name: ${RED}❌ FAIL${NC}"
  fi
}

if [ "$RUN_UNIT" = true ]; then
  print_result "Unit Tests      " $UNIT_RESULT
fi
if [ "$RUN_WIDGET" = true ]; then
  print_result "Widget Tests    " $WIDGET_RESULT
fi
if [ "$RUN_INTEGRATION" = true ]; then
  print_result "Integration Tests" $INTEGRATION_RESULT
fi
if [ "$RUN_CONSISTENCY" = true ]; then
  print_result "Consistency Guard" $CONSISTENCY_RESULT
fi

echo ""

# 최종 결과
TOTAL_RESULT=$((UNIT_RESULT + WIDGET_RESULT))
if [ "$INTEGRATION_RESULT" -eq 1 ]; then
  TOTAL_RESULT=$((TOTAL_RESULT + 1))
fi
if [ "$CONSISTENCY_RESULT" -eq 1 ]; then
  TOTAL_RESULT=$((TOTAL_RESULT + 1))
fi

if [ $TOTAL_RESULT -eq 0 ]; then
  echo -e "${GREEN}🎉 모든 테스트 통과!${NC}"
  exit 0
else
  echo -e "${RED}💥 일부 테스트 실패${NC}"
  exit 1
fi
