#!/bin/bash

# 자연어 UX 요청을 파싱하여 자동으로 JIRA에 등록하는 스크립트
# Claude Code에서 자동으로 호출됨

INPUT_TEXT="$1"

# JIRA 인증 정보
JIRA_EMAIL="injooinjoo@gmail.com"
JIRA_TOKEN="ATATT3xFfGF0e3diiy0TFqT7AyCmZDVHQ5o_7ysG2ioH9bu0uIf6Ai1n0mGLgSIvtzGXzNqAxchMeCR3hyH1WTb1b7zqpz6vVbDwXfn1i9N28V3etR2bMZVRGm3xsxL9vRi89EU9z2uzH3XoRwBRVAW5yWUo1AS3PGaETYHJPEPtFqh8ft82RRE=CAF65568"
JIRA_URL="https://beyond-app.atlassian.net"

# 카테고리 감지 함수
detect_category() {
    local text="$1"

    # 색상/테마 관련 (우선순위 높임)
    if echo "$text" | grep -i -E "(색깔|색상|컬러|테마|밝기|어두움|다크|라이트|대비|color|theme|bright|dark|contrast)" > /dev/null; then
        echo "color"
        return
    fi

    # 폰트/텍스트 관련
    if echo "$text" | grep -i -E "(폰트|글자|텍스트|크기|font|size|text|타이포|typography)" > /dev/null; then
        echo "font"
        return
    fi

    # 애니메이션 관련
    if echo "$text" | grep -i -E "(애니메이션|움직임|전환|트랜지션|부드럽|animation|transition|smooth|motion)" > /dev/null; then
        echo "animation"
        return
    fi

    # 버튼/터치 관련
    if echo "$text" | grep -i -E "(버튼|터치|누르|클릭|탭|button|touch|click|tap|press)" > /dev/null; then
        echo "accessibility"
        return
    fi

    # 레이아웃/배치 관련
    if echo "$text" | grep -i -E "(간격|여백|배치|위치|크기|레이아웃|spacing|margin|padding|layout|position)" > /dev/null; then
        echo "layout"
        return
    fi

    # 내비게이션 관련
    if echo "$text" | grep -i -E "(뒤로|이동|페이지|화면|네비|navigation|back|move|page|screen)" > /dev/null; then
        echo "navigation"
        return
    fi

    # 기본값
    echo "general"
}

# 제목 추출 함수
extract_title() {
    local text="$1"

    # 첫 번째 문장을 제목으로 사용 (최대 50자)
    echo "$text" | head -1 | cut -c1-50
}

# 우선순위 감지
detect_priority() {
    local text="$1"

    if echo "$text" | grep -i -E "(급해|빨리|중요|심각|critical|urgent|important)" > /dev/null; then
        echo "high"
        return
    fi

    if echo "$text" | grep -i -E "(접근성|장애|accessibility|a11y)" > /dev/null; then
        echo "medium"
        return
    fi

    echo "low"
}

# 입력 텍스트가 없으면 종료
if [ -z "$INPUT_TEXT" ]; then
    echo "Usage: $0 \"사용자 요청 텍스트\""
    exit 1
fi

# 자연어 분석
CATEGORY=$(detect_category "$INPUT_TEXT")
TITLE=$(extract_title "$INPUT_TEXT")
PRIORITY=$(detect_priority "$INPUT_TEXT")

# 카테고리별 라벨 및 이모지 설정
case "$CATEGORY" in
    "font")
        LABELS='["ux-improvement", "design", "font", "typography", "auto-generated", "'$PRIORITY'-priority"]'
        CATEGORY_EMOJI="🔤"
        ;;
    "color")
        LABELS='["ux-improvement", "design", "color", "theme", "auto-generated", "'$PRIORITY'-priority"]'
        CATEGORY_EMOJI="🎨"
        ;;
    "animation")
        LABELS='["ux-improvement", "animation", "transition", "motion", "auto-generated", "'$PRIORITY'-priority"]'
        CATEGORY_EMOJI="✨"
        ;;
    "layout")
        LABELS='["ux-improvement", "design", "layout", "spacing", "auto-generated", "'$PRIORITY'-priority"]'
        CATEGORY_EMOJI="📐"
        ;;
    "navigation")
        LABELS='["ux-improvement", "navigation", "ux", "flow", "auto-generated", "'$PRIORITY'-priority"]'
        CATEGORY_EMOJI="🧭"
        ;;
    "accessibility")
        LABELS='["ux-improvement", "accessibility", "a11y", "usability", "auto-generated", "medium-priority"]'
        CATEGORY_EMOJI="♿"
        ;;
    *)
        LABELS='["ux-improvement", "design", "enhancement", "auto-generated", "'$PRIORITY'-priority"]'
        CATEGORY_EMOJI="🎨"
        ;;
esac

# 현재 날짜
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "🤖 자연어 UX 요청 감지됨!"
echo "📝 제목: $TITLE"
echo "🏷️ 카테고리: $CATEGORY"
echo "⚡ 우선순위: $PRIORITY"
echo ""

# JIRA 이슈 생성
RESPONSE=$(curl -s -X POST "$JIRA_URL/rest/api/2/issue" \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_TOKEN" | base64)" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "{
    \"fields\": {
      \"project\": {
        \"key\": \"KAN\"
      },
      \"summary\": \"[UX] $TITLE\",
      \"description\": \"$CATEGORY_EMOJI **자연어 UX 개선 요청** (자동 생성)\\n\\n**원본 요청**:\\n$INPUT_TEXT\\n\\n**생성 일시**: $DATE\\n**감지된 카테고리**: $CATEGORY\\n**우선순위**: $PRIORITY\\n\\n**분석 결과**:\\n- 자동 카테고리 분류: $CATEGORY\\n- 우선순위 자동 설정: $PRIORITY\\n\\n---\\n\\n**예상 작업**:\\n- 현재 상태 분석\\n- 개선안 설계\\n- 구현 및 테스트\\n- 사용자 피드백 수집\\n\\n**자동 생성**: Claude Code 자연어 처리\",
      \"issuetype\": {
        \"id\": \"10001\"
      },
      \"labels\": $LABELS
    }
  }")

# 응답 파싱
ISSUE_KEY=$(echo "$RESPONSE" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)

if [ -n "$ISSUE_KEY" ]; then
    echo "✅ UX 개선 요청이 자동으로 JIRA에 등록되었습니다!"
    echo "📋 이슈 번호: $ISSUE_KEY"
    echo "🔗 링크: $JIRA_URL/browse/$ISSUE_KEY"
    echo "🏷️ 카테고리: $CATEGORY ($CATEGORY_EMOJI)"
    echo "⚡ 우선순위: $PRIORITY"
    echo ""
    echo "💡 작업 완료 후 다음 명령어로 커밋하세요:"
    echo "   ./scripts/git_jira_commit.sh \"작업 완료 메시지\" \"$ISSUE_KEY\" \"done\""
else
    echo "❌ 이슈 생성 실패"
    echo "응답: $RESPONSE"
fi