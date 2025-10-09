#!/bin/bash

# 운세 표준화 프로젝트 JIRA 티켓 자동 생성 스크립트
# 에픽 1개 + 스토리 26개 자동 생성

set -e

# JIRA 인증 정보
JIRA_EMAIL="injooinjoo@gmail.com"
JIRA_TOKEN="ATATT3xFfGF0e3diiy0TFqT7AyCmZDVHQ5o_7ysG2ioH9bu0uIf6Ai1n0mGLgSIvtzGXzNqAxchMeCR3hyH1WTb1b7zqpz6vVbDwXfn1i9N28V3etR2bMZVRGm3xsxL9vRi89EU9z2uzH3XoRwBRVAW5yWUo1AS3PGaETYHJPEPtFqh8ft82RRE=CAF65568"
JIRA_URL="https://beyond-app.atlassian.net"
JIRA_PROJECT_KEY="KAN"

AUTH_HEADER="Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_TOKEN" | base64)"

echo "🚀 운세 표준화 JIRA 티켓 자동 생성 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==================== Step 1: 에픽 생성 ====================
echo "📋 Step 1/2: 에픽 생성 중..."

EPIC_RESPONSE=$(curl -s -X POST "$JIRA_URL/rest/api/2/issue" \
  -H "$AUTH_HEADER" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "'$JIRA_PROJECT_KEY'"},
      "summary": "[에픽] 26개 운세 표준화 - 통일된 프로세스 구축",
      "description": "# 목표\n모든 운세를 통일된 표준 프로세스로 전환하여 중복 방지, 조건 반영, 영구 저장을 구현\n\n# 범위\n- 26개 운세 (소원빌기, 꿈해몽 제외)\n- UnifiedFortuneService 공통 인프라\n- fortune_history 테이블 확장\n\n# 기대 효과\n✅ 중복 방지: 같은 날 + 같은 조건 = 기존 결과 반환\n✅ 조건 반영: 사용자 입력이 결과에 영향\n✅ 영구 저장: 모든 결과 DB 저장\n✅ 일관된 UX: 동일한 사용자 경험\n\n# 관련 문서\n- docs/development/FORTUNE_STANDARDIZATION_GUIDE.md",
      "issuetype": {"name": "Epic"},
      "labels": ["fortune-standardization", "infrastructure", "high-priority"]
    }
  }')

EPIC_KEY=$(echo "$EPIC_RESPONSE" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$EPIC_KEY" ]; then
    echo "✅ 에픽 생성 완료: $EPIC_KEY"
    echo "   🔗 $JIRA_URL/browse/$EPIC_KEY"
    echo ""
else
    echo "❌ 에픽 생성 실패"
    echo "응답: $EPIC_RESPONSE"
    exit 1
fi

# ==================== Step 2: 26개 스토리 생성 ====================
echo "📋 Step 2/2: 26개 운세 스토리 티켓 생성 중..."
echo ""

# High Priority: 로컬 → 표준화 (11개)
declare -a HIGH_PRIORITY_FORTUNES=(
    "전통 운세|local|생년월일, 시간|사주/토정비결 통합"
    "타로 카드|local|카드 3장 선택|카드명을 조건으로"
    "관상|local|얼굴 특징 입력|관상 특징 선택"
    "MBTI 운세|local|MBTI 타입|16개 타입별"
    "바이오리듬|local|생년월일, 조회일|수학 공식 계산"
    "성격 DNA|local|DNA 4가지 선택|조합 로직"
    "연애운|local|생년월일, 성별|연애 운세"
    "행운 아이템|local|날짜|색깔/숫자/음식/아이템"
    "재능 발견|local|생년월일|재능 분석"
    "운동운세|local|날짜, 운동 종류|피트니스/요가/런닝"
    "스포츠경기|local|날짜, 경기 종류|골프/야구/테니스"
)

# Medium Priority: API → 표준화 (15개)
declare -a MEDIUM_PRIORITY_FORTUNES=(
    "시간별 운세|api|날짜, 시간 구분|오늘/내일/주간/월간/연간"
    "궁합|api|두 사람 생년월일|커플 궁합"
    "피해야 할 사람|api|날짜|피해야 할 특징"
    "헤어진 애인|api|생년월일, 상대 정보|재회 가능성"
    "소개팅 운세|api|날짜, 상대 정보|소개팅 성공률"
    "커리어 운세|api|생년월일, 직업 정보|취업/직업/사업/창업"
    "시험 운세|api|날짜, 시험 정보|시험 합격 운세"
    "투자 운세|api|날짜, 투자 섹터|주식/부동산/코인 10개 섹터"
    "건강운세|api|날짜|신체 부위별 운세"
    "이사운|api|날짜, 방향|이사 길일과 방향"
    "포춘 쿠키|api|날짜|행운 메시지"
    "유명인 운세|api|유명인 ID|유명인과 나의 운세"
    "반려동물 운세|api|반려동물 정보|반려동물 궁합"
    "가족 운세|api|가족 구성원 정보|자녀/육아/가족화합"
    "부적|api|날짜, 부적 종류|부적 생성"
)

CREATED_COUNT=0
FAILED_COUNT=0

# High Priority 티켓 생성
for fortune_info in "${HIGH_PRIORITY_FORTUNES[@]}"; do
    IFS='|' read -r FORTUNE_NAME DATA_SOURCE REQUIRED_CONDITIONS NOTE <<< "$fortune_info"

    STORY_RESPONSE=$(curl -s -X POST "$JIRA_URL/rest/api/2/issue" \
      -H "$AUTH_HEADER" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d '{
        "fields": {
          "project": {"key": "'$JIRA_PROJECT_KEY'"},
          "summary": "[표준화] '"$FORTUNE_NAME"' - UnifiedFortuneService 통합",
          "description": "# 운세 정보\n- **운세명**: '"$FORTUNE_NAME"'\n- **데이터 소스**: '"$DATA_SOURCE"'\n- **필요 조건**: '"$REQUIRED_CONDITIONS"'\n- **비고**: '"$NOTE"'\n\n# 작업 내용\n## 1단계: 분석\n- [ ] 기존 코드 분석\n- [ ] 입력 조건 정의\n- [ ] 생성 로직 설계\n\n## 2단계: 구현\n- [ ] Generator 클래스 구현 (lib/core/services/fortune_generators/)\n- [ ] UnifiedFortuneService 통합\n- [ ] 입력 조건 정규화\n\n## 3단계: 테스트\n- [ ] 중복 방지 테스트\n- [ ] 조건 반영 테스트\n- [ ] DB 저장 확인\n- [ ] 실제 디바이스 테스트\n\n## 4단계: 검증\n- [ ] flutter analyze 통과\n- [ ] 기존 기능 정상 동작\n- [ ] 새 기능 정상 동작\n\n# 관련 문서\n- docs/development/FORTUNE_STANDARDIZATION_GUIDE.md\n\n# 우선순위\nHigh (로컬 운세는 현재 DB 저장 없어 사용자 영향 최소)",
          "issuetype": {"id": "10001"},
          "labels": ["fortune-standardization", "high-priority", "local-fortune", "'"$FORTUNE_NAME"'"],
          "parent": {"key": "'$EPIC_KEY'"}
        }
      }')

    STORY_KEY=$(echo "$STORY_RESPONSE" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$STORY_KEY" ]; then
        echo "  ✅ $STORY_KEY - $FORTUNE_NAME"
        ((CREATED_COUNT++))
    else
        echo "  ❌ 실패 - $FORTUNE_NAME"
        ((FAILED_COUNT++))
    fi
done

# Medium Priority 티켓 생성
for fortune_info in "${MEDIUM_PRIORITY_FORTUNES[@]}"; do
    IFS='|' read -r FORTUNE_NAME DATA_SOURCE REQUIRED_CONDITIONS NOTE <<< "$fortune_info"

    STORY_RESPONSE=$(curl -s -X POST "$JIRA_URL/rest/api/2/issue" \
      -H "$AUTH_HEADER" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d '{
        "fields": {
          "project": {"key": "'$JIRA_PROJECT_KEY'"},
          "summary": "[표준화] '"$FORTUNE_NAME"' - UnifiedFortuneService 통합",
          "description": "# 운세 정보\n- **운세명**: '"$FORTUNE_NAME"'\n- **데이터 소스**: '"$DATA_SOURCE"'\n- **필요 조건**: '"$REQUIRED_CONDITIONS"'\n- **비고**: '"$NOTE"'\n\n# 작업 내용\n## 1단계: 분석\n- [ ] 기존 API 분석\n- [ ] input_conditions 매핑 정의\n- [ ] Edge Function 수정 필요 여부 확인\n\n## 2단계: 구현\n- [ ] API 호출 코드를 UnifiedFortuneService로 이전\n- [ ] input_conditions 정규화\n- [ ] 중복 체크 로직 추가\n\n## 3단계: 테스트\n- [ ] 중복 방지 테스트\n- [ ] API 응답 정상 확인\n- [ ] DB 저장 확인\n- [ ] 실제 디바이스 테스트\n\n## 4단계: 검증\n- [ ] flutter analyze 통과\n- [ ] 기존 기능 정상 동작\n- [ ] 새 기능 정상 동작\n\n# 관련 문서\n- docs/development/FORTUNE_STANDARDIZATION_GUIDE.md\n\n# 우선순위\nMedium (이미 API가 있어 표준화만 하면 됨)",
          "issuetype": {"id": "10001"},
          "labels": ["fortune-standardization", "medium-priority", "api-fortune", "'"$FORTUNE_NAME"'"],
          "parent": {"key": "'$EPIC_KEY'"}
        }
      }')

    STORY_KEY=$(echo "$STORY_RESPONSE" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$STORY_KEY" ]; then
        echo "  ✅ $STORY_KEY - $FORTUNE_NAME"
        ((CREATED_COUNT++))
    else
        echo "  ❌ 실패 - $FORTUNE_NAME"
        ((FAILED_COUNT++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 JIRA 티켓 생성 완료!"
echo ""
echo "📊 결과:"
echo "  ✅ 성공: $CREATED_COUNT개"
echo "  ❌ 실패: $FAILED_COUNT개"
echo ""
echo "🔗 에픽 링크: $JIRA_URL/browse/$EPIC_KEY"
echo ""
echo "💡 다음 단계:"
echo "  1. DB 마이그레이션 실행: supabase db push"
echo "  2. 첫 운세 구현 시작 (추천: 타로 카드)"
echo "  3. 완료 후 JIRA 티켓 닫기"
echo ""
