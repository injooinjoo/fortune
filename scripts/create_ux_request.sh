#!/bin/bash

# UX/디자인 개선 요청을 JIRA에 자동 생성하는 스크립트
# 사용법: ./create_ux_request.sh "제목" "상세내용" "카테고리"

# JIRA 인증 정보 (환경변수에서 로드)
JIRA_EMAIL="${JIRA_EMAIL:-}"
JIRA_TOKEN="${JIRA_API_TOKEN:-}"
JIRA_URL="${JIRA_URL:-https://beyond-app.atlassian.net}"

# 환경변수 검증
if [ -z "$JIRA_EMAIL" ] || [ -z "$JIRA_TOKEN" ]; then
    echo "❌ 오류: JIRA 환경변수가 설정되지 않았습니다."
    echo "   export JIRA_EMAIL='your-email' JIRA_API_TOKEN='your-token'"
    exit 1
fi

# 입력 파라미터 확인
if [ $# -lt 2 ]; then
    echo "사용법: $0 \"제목\" \"상세내용\" [카테고리]"
    echo "예시: $0 \"폰트 크기 조정\" \"메인 화면 폰트가 너무 작아요\" \"font\""
    exit 1
fi

TITLE="$1"
DESCRIPTION="$2"
CATEGORY="${3:-general}"

# 카테고리별 라벨 설정
case "$CATEGORY" in
    "font")
        LABELS='["ux-improvement", "design", "font", "typography", "low-priority"]'
        CATEGORY_EMOJI="🔤"
        ;;
    "color")
        LABELS='["ux-improvement", "design", "color", "theme", "low-priority"]'
        CATEGORY_EMOJI="🎨"
        ;;
    "animation")
        LABELS='["ux-improvement", "animation", "transition", "motion", "low-priority"]'
        CATEGORY_EMOJI="✨"
        ;;
    "layout")
        LABELS='["ux-improvement", "design", "layout", "spacing", "low-priority"]'
        CATEGORY_EMOJI="📐"
        ;;
    "navigation")
        LABELS='["ux-improvement", "navigation", "ux", "flow", "low-priority"]'
        CATEGORY_EMOJI="🧭"
        ;;
    "accessibility")
        LABELS='["ux-improvement", "accessibility", "a11y", "usability", "medium-priority"]'
        CATEGORY_EMOJI="♿"
        ;;
    *)
        LABELS='["ux-improvement", "design", "enhancement", "low-priority"]'
        CATEGORY_EMOJI="🎨"
        ;;
esac

# 현재 날짜
DATE=$(date '+%Y-%m-%d')

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
      \"description\": \"$CATEGORY_EMOJI **UX/디자인 개선 요청**\\n\\n**요청 일자**: $DATE\\n**카테고리**: $CATEGORY\\n**우선순위**: 낮음 (UX 개선)\\n\\n**상세 내용**:\\n$DESCRIPTION\\n\\n**요청자**: 사용자\\n**생성 방식**: 자동 생성 (Claude Code)\\n\\n---\\n\\n**예상 작업**:\\n- UI/UX 분석\\n- 디자인 개선안 검토\\n- 구현 및 테스트\\n- 사용자 피드백 수집\",
      \"issuetype\": {
        \"id\": \"10001\"
      },
      \"labels\": $LABELS
    }
  }")

# 응답 파싱
ISSUE_KEY=$(echo "$RESPONSE" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)
ISSUE_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ -n "$ISSUE_KEY" ]; then
    echo "✅ UX 개선 요청이 성공적으로 생성되었습니다!"
    echo "📋 이슈 번호: $ISSUE_KEY"
    echo "🔗 링크: $JIRA_URL/browse/$ISSUE_KEY"
    echo "📝 제목: [UX] $TITLE"
    echo "🏷️  카테고리: $CATEGORY"
else
    echo "❌ 이슈 생성 실패"
    echo "응답: $RESPONSE"
fi