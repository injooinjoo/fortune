#!/bin/bash

# 실패한 운세 표준화 티켓 재생성 스크립트

set -e

# JIRA 인증 정보
JIRA_EMAIL="injooinjoo@gmail.com"
JIRA_TOKEN="ATATT3xFfGF0e3diiy0TFqT7AyCmZDVHQ5o_7ysG2ioH9bu0uIf6Ai1n0mGLgSIvtzGXzNqAxchMeCR3hyH1WTb1b7zqpz6vVbDwXfn1i9N28V3etR2bMZVRGm3xsxL9vRi89EU9z2uzH3XoRwBRVAW5yWUo1AS3PGaETYHJPEPtFqh8ft82RRE=CAF65568"
JIRA_URL="https://beyond-app.atlassian.net"
EPIC_KEY="KAN-104"

AUTH_HEADER="Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_TOKEN" | base64)"

echo "🚀 실패한 운세 표준화 티켓 재생성 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 실패한 티켓 목록 (17개)
declare -a FAILED_FORTUNES=(
    "전통 운세|local|생년월일, 시간|사주/토정비결 통합|high"
    "타로 카드|local|카드 3장 선택|카드명을 조건으로|high"
    "MBTI 운세|local|MBTI 타입|16개 타입별|high"
    "성격 DNA|local|DNA 4가지 선택|조합 로직|high"
    "행운 아이템|local|날짜|색깔/숫자/음식/아이템|high"
    "재능 발견|local|생년월일|재능 분석|high"
    "시간별 운세|api|날짜, 시간 구분|오늘/내일/주간/월간/연간|medium"
    "피해야 할 사람|api|날짜|피해야 할 특징|medium"
    "헤어진 애인|api|생년월일, 상대 정보|재회 가능성|medium"
    "소개팅 운세|api|날짜, 상대 정보|소개팅 성공률|medium"
    "커리어 운세|api|생년월일, 직업 정보|취업/직업/사업/창업|medium"
    "시험 운세|api|날짜, 시험 정보|시험 합격 운세|medium"
    "투자 운세|api|날짜, 투자 섹터|주식/부동산/코인 10개 섹터|medium"
    "포춘 쿠키|api|날짜|행운 메시지|medium"
    "유명인 운세|api|유명인 ID|유명인과 나의 운세|medium"
    "반려동물 운세|api|반려동물 정보|반려동물 궁합|medium"
    "가족 운세|api|가족 구성원 정보|자녀/육아/가족화합|medium"
)

CREATED_COUNT=0
FAILED_COUNT=0

for fortune_info in "${FAILED_FORTUNES[@]}"; do
    IFS='|' read -r FORTUNE_NAME DATA_SOURCE REQUIRED_CONDITIONS NOTE PRIORITY <<< "$fortune_info"

    # Priority에 따라 설명과 라벨 조정
    if [ "$PRIORITY" = "high" ]; then
        PRIORITY_DESC="High (로컬 운세는 현재 DB 저장 없어 사용자 영향 최소)"
        FORTUNE_TYPE="local-fortune"
    else
        PRIORITY_DESC="Medium (이미 API가 있어 표준화만 하면 됨)"
        FORTUNE_TYPE="api-fortune"
    fi

    # JSON 문자열에서 특수문자 이스케이프
    ESCAPED_FORTUNE_NAME=$(echo "$FORTUNE_NAME" | sed 's/"/\\"/g')
    ESCAPED_CONDITIONS=$(echo "$REQUIRED_CONDITIONS" | sed 's/"/\\"/g')
    ESCAPED_NOTE=$(echo "$NOTE" | sed 's/"/\\"/g')

    STORY_RESPONSE=$(curl -s -X POST "$JIRA_URL/rest/api/2/issue" \
      -H "$AUTH_HEADER" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "{
        \"fields\": {
          \"project\": {\"key\": \"KAN\"},
          \"summary\": \"[표준화] $ESCAPED_FORTUNE_NAME - UnifiedFortuneService 통합\",
          \"description\": \"# 운세 정보\\n- **운세명**: $ESCAPED_FORTUNE_NAME\\n- **데이터 소스**: $DATA_SOURCE\\n- **필요 조건**: $ESCAPED_CONDITIONS\\n- **비고**: $ESCAPED_NOTE\\n\\n# 작업 내용\\n## 1단계: 분석\\n- [ ] 기존 코드 분석\\n- [ ] 입력 조건 정의\\n- [ ] 생성 로직 설계\\n\\n## 2단계: 구현\\n- [ ] Generator 클래스 구현 또는 API 통합\\n- [ ] UnifiedFortuneService 통합\\n- [ ] 입력 조건 정규화\\n\\n## 3단계: 테스트\\n- [ ] 중복 방지 테스트\\n- [ ] 조건 반영 테스트\\n- [ ] DB 저장 확인\\n- [ ] 실제 디바이스 테스트\\n\\n## 4단계: 검증\\n- [ ] flutter analyze 통과\\n- [ ] 기존 기능 정상 동작\\n- [ ] 새 기능 정상 동작\\n\\n# 관련 문서\\n- docs/development/FORTUNE_STANDARDIZATION_GUIDE.md\\n\\n# 우선순위\\n$PRIORITY_DESC\",
          \"issuetype\": {\"id\": \"10001\"},
          \"labels\": [\"fortune-standardization\", \"$PRIORITY-priority\", \"$FORTUNE_TYPE\"],
          \"parent\": {\"key\": \"$EPIC_KEY\"}
        }
      }")

    STORY_KEY=$(echo "$STORY_RESPONSE" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$STORY_KEY" ]; then
        echo "  ✅ $STORY_KEY - $FORTUNE_NAME"
        ((CREATED_COUNT++))
    else
        echo "  ❌ 실패 - $FORTUNE_NAME"
        echo "     응답: $(echo "$STORY_RESPONSE" | head -100)"
        ((FAILED_COUNT++))
    fi

    # API Rate Limiting 방지를 위한 대기
    sleep 1
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 티켓 재생성 완료!"
echo ""
echo "📊 결과:"
echo "  ✅ 성공: $CREATED_COUNT개"
echo "  ❌ 실패: $FAILED_COUNT개"
echo ""
echo "🔗 에픽 링크: $JIRA_URL/browse/$EPIC_KEY"
echo ""
