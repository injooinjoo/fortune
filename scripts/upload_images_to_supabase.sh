#!/bin/bash

# Supabase Storage 이미지 업로드 스크립트
# 사용법: ./scripts/upload_images_to_supabase.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 프로젝트 루트 디렉토리
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 환경 변수 로드
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
fi

# Supabase 설정 확인
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo -e "${RED}오류: SUPABASE_URL 또는 SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다.${NC}"
    echo "다음 환경 변수를 설정해주세요:"
    echo "  export SUPABASE_URL=https://your-project.supabase.co"
    echo "  export SUPABASE_SERVICE_ROLE_KEY=your-service-role-key"
    exit 1
fi

STORAGE_BUCKET="fortune-assets"
ASSETS_DIR="$PROJECT_ROOT/assets"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Supabase Storage 이미지 업로드${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Supabase URL: $SUPABASE_URL"
echo "Storage Bucket: $STORAGE_BUCKET"
echo "Assets Directory: $ASSETS_DIR"
echo ""

# 버킷 존재 확인 및 생성
echo -e "${YELLOW}1. Storage 버킷 확인 중...${NC}"
BUCKET_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    "$SUPABASE_URL/storage/v1/bucket/$STORAGE_BUCKET")

if [ "$BUCKET_EXISTS" != "200" ]; then
    echo "   버킷 생성 중: $STORAGE_BUCKET"
    curl -s -X POST \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"id\": \"$STORAGE_BUCKET\", \"name\": \"$STORAGE_BUCKET\", \"public\": true}" \
        "$SUPABASE_URL/storage/v1/bucket" > /dev/null
    echo -e "   ${GREEN}버킷 생성 완료${NC}"
else
    echo -e "   ${GREEN}버킷 이미 존재함${NC}"
fi

# 이미지 업로드 함수
upload_file() {
    local file_path=$1
    local relative_path=${file_path#$ASSETS_DIR/}
    local storage_path="$relative_path"

    # Content-Type 결정
    local content_type="image/png"
    if [[ "$file_path" == *.jpg ]] || [[ "$file_path" == *.jpeg ]]; then
        content_type="image/jpeg"
    elif [[ "$file_path" == *.gif ]]; then
        content_type="image/gif"
    elif [[ "$file_path" == *.webp ]]; then
        content_type="image/webp"
    fi

    # 업로드
    local response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: $content_type" \
        --data-binary @"$file_path" \
        "$SUPABASE_URL/storage/v1/object/$STORAGE_BUCKET/$storage_path")

    local http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" == "200" ] || [ "$http_code" == "201" ]; then
        echo -e "   ${GREEN}✓${NC} $storage_path"
        return 0
    else
        echo -e "   ${RED}✗${NC} $storage_path (HTTP $http_code)"
        return 1
    fi
}

# 운세 아이콘 업로드
echo ""
echo -e "${YELLOW}2. 운세 아이콘 업로드 중...${NC}"
ICON_COUNT=0
ICON_SUCCESS=0
for file in "$ASSETS_DIR/icons/fortune/"*.png; do
    if [ -f "$file" ]; then
        ICON_COUNT=$((ICON_COUNT + 1))
        if upload_file "$file"; then
            ICON_SUCCESS=$((ICON_SUCCESS + 1))
        fi
    fi
done
echo "   업로드 완료: $ICON_SUCCESS / $ICON_COUNT 개"

# 타로 카드 업로드 (선택적)
echo ""
read -p "타로 카드 이미지도 업로드할까요? (y/N): " UPLOAD_TAROT
if [[ "$UPLOAD_TAROT" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}3. 타로 카드 업로드 중...${NC}"
    TAROT_COUNT=0
    TAROT_SUCCESS=0
    for file in $(find "$ASSETS_DIR/images/tarot" -name "*.png" -o -name "*.jpg" 2>/dev/null); do
        if [ -f "$file" ]; then
            TAROT_COUNT=$((TAROT_COUNT + 1))
            if upload_file "$file"; then
                TAROT_SUCCESS=$((TAROT_SUCCESS + 1))
            fi
        fi
    done
    echo "   업로드 완료: $TAROT_SUCCESS / $TAROT_COUNT 개"
fi

# CDN URL 출력
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}업로드 완료!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Firebase Remote Config에 다음 값을 설정하세요:"
echo ""
echo -e "${YELLOW}image_cdn_base_url:${NC}"
echo "  $SUPABASE_URL/storage/v1/object/public/$STORAGE_BUCKET"
echo ""
echo -e "${YELLOW}use_image_cdn:${NC}"
echo "  true"
echo ""
echo "예시 이미지 URL:"
echo "  $SUPABASE_URL/storage/v1/object/public/$STORAGE_BUCKET/icons/fortune/daily.png"
