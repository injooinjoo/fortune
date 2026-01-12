#!/bin/bash

# ============================================================
# WebP 이미지 변환 스크립트
# ============================================================
#
# 사용법:
#   ./scripts/convert_to_webp.sh [옵션]
#
# 옵션:
#   --dry-run      실제 변환 없이 대상 파일만 표시
#   --quality N    WebP 품질 (기본: 80, 범위: 0-100)
#   --keep-orig    원본 파일 유지 (기본: 삭제)
#   --dir PATH     특정 디렉토리만 처리
#   --report       변환 결과 리포트 생성
#
# 요구사항:
#   - cwebp (libwebp 패키지)
#   macOS: brew install webp
#   Linux: apt-get install webp
#
# ============================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 기본 설정
QUALITY=80
PNG_QUALITY=85
DRY_RUN=false
KEEP_ORIGINAL=false
TARGET_DIR="assets"
GENERATE_REPORT=false
REPORT_FILE="webp_conversion_report.md"

# 통계
TOTAL_FILES=0
CONVERTED_FILES=0
SKIPPED_FILES=0
ORIGINAL_SIZE=0
CONVERTED_SIZE=0

# 도움말 출력
show_help() {
    echo "WebP 이미지 변환 스크립트"
    echo ""
    echo "사용법: $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  --dry-run      실제 변환 없이 대상 파일만 표시"
    echo "  --quality N    JPG WebP 품질 (기본: 80)"
    echo "  --png-quality N  PNG WebP 품질 (기본: 85)"
    echo "  --keep-orig    원본 파일 유지"
    echo "  --dir PATH     특정 디렉토리만 처리"
    echo "  --report       변환 결과 리포트 생성"
    echo "  --help         이 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 --dry-run                    # 변환 대상 확인"
    echo "  $0 --quality 75 --report        # 품질 75로 변환 + 리포트"
    echo "  $0 --dir assets/images/tarot    # 특정 폴더만 변환"
}

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --quality)
            QUALITY="$2"
            shift 2
            ;;
        --png-quality)
            PNG_QUALITY="$2"
            shift 2
            ;;
        --keep-orig)
            KEEP_ORIGINAL=true
            shift
            ;;
        --dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        --report)
            GENERATE_REPORT=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}알 수 없는 옵션: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# cwebp 설치 확인
check_cwebp() {
    if ! command -v cwebp &> /dev/null; then
        echo -e "${RED}오류: cwebp가 설치되어 있지 않습니다.${NC}"
        echo ""
        echo "설치 방법:"
        echo "  macOS:  brew install webp"
        echo "  Linux:  apt-get install webp"
        exit 1
    fi
    echo -e "${GREEN}✓ cwebp 발견${NC}"
}

# 파일 크기를 읽기 쉽게 포맷
format_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size} B"
    elif [ $size -lt 1048576 ]; then
        echo "$(echo "scale=1; $size / 1024" | bc) KB"
    else
        echo "$(echo "scale=1; $size / 1048576" | bc) MB"
    fi
}

# 단일 파일 변환
convert_file() {
    local input_file="$1"
    local extension="${input_file##*.}"
    local output_file="${input_file%.*}.webp"
    local quality=$QUALITY

    # PNG는 더 높은 품질 사용
    if [[ "$extension" == "png" || "$extension" == "PNG" ]]; then
        quality=$PNG_QUALITY
    fi

    # 이미 WebP면 스킵
    if [[ "$extension" == "webp" ]]; then
        ((SKIPPED_FILES++))
        return
    fi

    # WebP 버전이 이미 있으면 스킵
    if [ -f "$output_file" ]; then
        echo -e "${YELLOW}스킵: $input_file (WebP 존재)${NC}"
        ((SKIPPED_FILES++))
        return
    fi

    local original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
    ORIGINAL_SIZE=$((ORIGINAL_SIZE + original_size))
    ((TOTAL_FILES++))

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY-RUN] 변환 예정: $input_file → $output_file${NC}"
        return
    fi

    # 변환 실행
    if cwebp -q "$quality" "$input_file" -o "$output_file" -quiet; then
        local new_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)
        CONVERTED_SIZE=$((CONVERTED_SIZE + new_size))
        local saved=$((original_size - new_size))
        local percent=$((saved * 100 / original_size))

        echo -e "${GREEN}✓ 변환: $input_file${NC}"
        echo "  $(format_size $original_size) → $(format_size $new_size) (-${percent}%)"

        ((CONVERTED_FILES++))

        # 원본 삭제 (옵션)
        if [ "$KEEP_ORIGINAL" = false ]; then
            rm "$input_file"
            echo -e "  ${YELLOW}원본 삭제됨${NC}"
        fi
    else
        echo -e "${RED}✗ 실패: $input_file${NC}"
    fi
}

# 리포트 생성
generate_report() {
    if [ "$GENERATE_REPORT" = false ]; then
        return
    fi

    local saved=$((ORIGINAL_SIZE - CONVERTED_SIZE))
    local percent=0
    if [ $ORIGINAL_SIZE -gt 0 ]; then
        percent=$((saved * 100 / ORIGINAL_SIZE))
    fi

    cat > "$REPORT_FILE" << EOF
# WebP 변환 리포트

**생성일**: $(date '+%Y-%m-%d %H:%M:%S')

## 요약

| 항목 | 값 |
|------|-----|
| 대상 디렉토리 | \`$TARGET_DIR\` |
| 총 파일 수 | $TOTAL_FILES |
| 변환 완료 | $CONVERTED_FILES |
| 스킵 | $SKIPPED_FILES |
| 원본 크기 | $(format_size $ORIGINAL_SIZE) |
| 변환 후 크기 | $(format_size $CONVERTED_SIZE) |
| **절감량** | **$(format_size $saved) (-${percent}%)** |

## 설정

- JPG 품질: $QUALITY
- PNG 품질: $PNG_QUALITY
- 원본 유지: $KEEP_ORIGINAL

## 권장사항

1. \`pubspec.yaml\`에서 WebP 파일 경로 업데이트
2. 코드에서 이미지 경로 확장자 변경 (.jpg/.png → .webp)
3. 앱 재빌드 후 테스트

EOF

    echo -e "${GREEN}리포트 생성됨: $REPORT_FILE${NC}"
}

# 메인 실행
main() {
    echo "=============================================="
    echo "WebP 이미지 변환 스크립트"
    echo "=============================================="
    echo ""

    check_cwebp

    echo ""
    echo -e "${BLUE}대상 디렉토리: $TARGET_DIR${NC}"
    echo -e "${BLUE}JPG 품질: $QUALITY${NC}"
    echo -e "${BLUE}PNG 품질: $PNG_QUALITY${NC}"
    echo -e "${BLUE}Dry Run: $DRY_RUN${NC}"
    echo -e "${BLUE}원본 유지: $KEEP_ORIGINAL${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}=== DRY RUN 모드 (실제 변환 없음) ===${NC}"
        echo ""
    fi

    # JPG 파일 변환
    echo "JPG 파일 검색 중..."
    while IFS= read -r -d '' file; do
        convert_file "$file"
    done < <(find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 2>/dev/null)

    # PNG 파일 변환
    echo ""
    echo "PNG 파일 검색 중..."
    while IFS= read -r -d '' file; do
        convert_file "$file"
    done < <(find "$TARGET_DIR" -type f -iname "*.png" -print0 2>/dev/null)

    # 결과 출력
    echo ""
    echo "=============================================="
    echo "변환 완료"
    echo "=============================================="
    echo ""
    echo -e "총 파일: ${BLUE}$TOTAL_FILES${NC}"
    echo -e "변환됨: ${GREEN}$CONVERTED_FILES${NC}"
    echo -e "스킵됨: ${YELLOW}$SKIPPED_FILES${NC}"

    if [ "$DRY_RUN" = false ] && [ $ORIGINAL_SIZE -gt 0 ]; then
        local saved=$((ORIGINAL_SIZE - CONVERTED_SIZE))
        local percent=$((saved * 100 / ORIGINAL_SIZE))
        echo ""
        echo -e "원본 크기: $(format_size $ORIGINAL_SIZE)"
        echo -e "변환 후: $(format_size $CONVERTED_SIZE)"
        echo -e "${GREEN}절감량: $(format_size $saved) (-${percent}%)${NC}"
    fi

    generate_report

    echo ""
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}실제 변환하려면 --dry-run 옵션 없이 다시 실행하세요.${NC}"
    fi
}

main
