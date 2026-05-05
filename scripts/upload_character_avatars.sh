#!/bin/bash

# 캐릭터 아바타 webp 20개를 character-avatars 공개 버킷에 업로드.
# 푸시 알림 richContent.image 가 사용하는 공개 URL 의 출처.
#
# 사용 전 마이그레이션 적용 필수:
#   supabase/migrations/20260430000001_create_character_avatars_storage.sql
#
# 환경 변수:
#   SUPABASE_URL=https://<project>.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY=<service-role-jwt>
#
# 사용법:
#   ./scripts/upload_character_avatars.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$PROJECT_ROOT/.env" ]; then
    # shellcheck disable=SC1091
    source "$PROJECT_ROOT/.env"
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo -e "${RED}오류: SUPABASE_URL 또는 SUPABASE_SERVICE_ROLE_KEY 누락.${NC}"
    exit 1
fi

BUCKET="character-avatars"
SRC_DIR="$PROJECT_ROOT/apps/mobile-rn/assets/character/avatars"

if [ ! -d "$SRC_DIR" ]; then
    echo -e "${RED}오류: 아바타 디렉토리 없음: $SRC_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}character-avatars 버킷에 webp 업로드${NC}"
echo "Supabase: $SUPABASE_URL"
echo "원본:     $SRC_DIR"
echo ""

# 버킷 존재 확인. 마이그레이션이 미적용이라도 우선 만들어둔다.
BUCKET_HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    "$SUPABASE_URL/storage/v1/bucket/$BUCKET")

if [ "$BUCKET_HTTP" != "200" ]; then
    echo -e "${YELLOW}버킷 생성 중...${NC}"
    curl -s -X POST \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"id\":\"$BUCKET\",\"name\":\"$BUCKET\",\"public\":true,\"file_size_limit\":2097152,\"allowed_mime_types\":[\"image/webp\",\"image/png\",\"image/jpeg\"]}" \
        "$SUPABASE_URL/storage/v1/bucket" > /dev/null
fi

TOTAL=0
SUCCESS=0
SKIPPED=0
FAILED=0

for file in "$SRC_DIR"/*.webp; do
    [ -f "$file" ] || continue
    TOTAL=$((TOTAL + 1))
    name=$(basename "$file")

    # 이미 동일 키가 있으면 PUT(upsert) 으로 덮어쓴다.
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: image/webp" \
        -H "x-upsert: true" \
        --data-binary @"$file" \
        "$SUPABASE_URL/storage/v1/object/$BUCKET/$name")
    http_code=$(echo "$response" | tail -n1)

    case "$http_code" in
        200|201)
            echo -e "  ${GREEN}✓${NC} $name"
            SUCCESS=$((SUCCESS + 1))
            ;;
        409)
            echo -e "  ${YELLOW}=${NC} $name (이미 존재)"
            SKIPPED=$((SKIPPED + 1))
            ;;
        *)
            echo -e "  ${RED}✗${NC} $name (HTTP $http_code)"
            FAILED=$((FAILED + 1))
            ;;
    esac
done

echo ""
echo "총 $TOTAL — 성공 $SUCCESS · 스킵 $SKIPPED · 실패 $FAILED"
echo ""
echo "공개 URL 예시:"
echo "  $SUPABASE_URL/storage/v1/object/public/$BUCKET/luts.webp"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
