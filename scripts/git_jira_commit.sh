#!/bin/bash

# Git 커밋과 동시에 JIRA 이슈를 자동 업데이트하는 스크립트
# 사용법: ./git_jira_commit.sh "커밋 메시지" "JIRA이슈번호" [상태]

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
    echo "사용법: $0 \"커밋 메시지\" \"JIRA이슈번호\" [상태]"
    echo ""
    echo "예시:"
    echo "  $0 \"UserProfile null 이슈 해결\" \"KAN-15\" \"done\""
    echo "  $0 \"폰트 크기 조정 완료\" \"KAN-39\" \"in-progress\""
    echo "  $0 \"코드 리뷰 반영\" \"KAN-39\""
    echo ""
    echo "상태 옵션: done, in-progress, comment (기본값: comment)"
    exit 1
fi

COMMIT_MESSAGE="$1"
JIRA_ISSUE="$2"
ACTION="${3:-comment}"

# GitHub 원격 저장소 정보 가져오기
GITHUB_REPO=$(git remote get-url origin | sed 's/.*github.com[:/]\([^.]*\).*/\1/')
CURRENT_BRANCH=$(git branch --show-current)
COMMIT_HASH=$(git rev-parse HEAD)

# 1. Git 커밋 먼저 실행
echo "📝 Git 커밋 생성 중..."
git add .
git commit -m "$COMMIT_MESSAGE ($JIRA_ISSUE)"

if [ $? -eq 0 ]; then
    echo "✅ Git 커밋 성공!"
    COMMIT_HASH=$(git rev-parse HEAD)

    # 2. JIRA 이슈에 커밋 정보 추가
    echo "🔗 JIRA 이슈 업데이트 중..."

    case "$ACTION" in
        "done")
            # 이슈를 Done으로 변경
            curl -s -X PUT "$JIRA_URL/rest/api/2/issue/$JIRA_ISSUE/transitions" \
              -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_TOKEN" | base64)" \
              -H "Accept: application/json" \
              -H "Content-Type: application/json" \
              -d '{
                "transition": {"id": "31"},
                "fields": {"resolution": {"name": "Done"}},
                "update": {
                  "comment": [{
                    "add": {
                      "body": "✅ **해결 완료**\n\n'"$COMMIT_MESSAGE"'\n\n🔗 **GitHub 커밋**: https://github.com/'"$GITHUB_REPO"'/commit/'"$COMMIT_HASH"'\n📂 **브랜치**: '"$CURRENT_BRANCH"'\n⏰ **완료 시간**: '"$(date '+%Y-%m-%d %H:%M:%S')"'"
                    }
                  }]
                }
              }' > /dev/null
            echo "✅ JIRA 이슈 $JIRA_ISSUE가 Done으로 변경되었습니다!"
            ;;
        "in-progress")
            # 이슈를 In Progress로 변경
            curl -s -X PUT "$JIRA_URL/rest/api/2/issue/$JIRA_ISSUE/transitions" \
              -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_TOKEN" | base64)" \
              -H "Accept: application/json" \
              -H "Content-Type: application/json" \
              -d '{
                "transition": {"id": "21"},
                "update": {
                  "comment": [{
                    "add": {
                      "body": "🔄 **작업 진행 중**\n\n'"$COMMIT_MESSAGE"'\n\n🔗 **GitHub 커밋**: https://github.com/'"$GITHUB_REPO"'/commit/'"$COMMIT_HASH"'\n📂 **브랜치**: '"$CURRENT_BRANCH"'\n⏰ **업데이트 시간**: '"$(date '+%Y-%m-%d %H:%M:%S')"'"
                    }
                  }]
                }
              }' > /dev/null
            echo "✅ JIRA 이슈 $JIRA_ISSUE가 In Progress로 변경되었습니다!"
            ;;
        *)
            # 코멘트만 추가
            curl -s -X POST "$JIRA_URL/rest/api/2/issue/$JIRA_ISSUE/comment" \
              -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_TOKEN" | base64)" \
              -H "Accept: application/json" \
              -H "Content-Type: application/json" \
              -d '{
                "body": "💻 **코드 변경사항**\n\n'"$COMMIT_MESSAGE"'\n\n🔗 **GitHub 커밋**: https://github.com/'"$GITHUB_REPO"'/commit/'"$COMMIT_HASH"'\n📂 **브랜치**: '"$CURRENT_BRANCH"'\n⏰ **커밋 시간**: '"$(date '+%Y-%m-%d %H:%M:%S')"'"
              }' > /dev/null
            echo "✅ JIRA 이슈 $JIRA_ISSUE에 커밋 정보가 추가되었습니다!"
            ;;
    esac

    echo ""
    echo "🔗 JIRA 이슈: $JIRA_URL/browse/$JIRA_ISSUE"
    echo "🔗 GitHub 커밋: https://github.com/$GITHUB_REPO/commit/$COMMIT_HASH"

else
    echo "❌ Git 커밋 실패"
    exit 1
fi