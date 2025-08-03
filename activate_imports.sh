#!/bin/bash

# 주석 처리된 임포트를 활성화하고 에러를 확인하는 스크립트

echo "🚀 Flutter 임포트 활성화 및 에러 체크 스크립트"
echo "============================================"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 파일 경로
MAIN_FILE="/Users/jacobmac/Desktop/Dev/fortune/lib/main.dart"
ROUTER_FILE="/Users/jacobmac/Desktop/Dev/fortune/lib/routes/route_config.dart"

# 로그 파일
LOG_FILE="import_activation_log.txt"
ERROR_LOG="import_errors.txt"

# 초기화
echo "📝 로그 파일 초기화..." > $LOG_FILE
echo "❌ 에러 로그" > $ERROR_LOG

# 백업 생성
echo -e "${YELLOW}📁 백업 파일 생성 중...${NC}"
cp $MAIN_FILE "${MAIN_FILE}.backup"
cp $ROUTER_FILE "${ROUTER_FILE}.backup"

# 주석 처리된 임포트 찾기
echo -e "\n${YELLOW}🔍 주석 처리된 임포트 찾기...${NC}"

# main.dart에서 주석 처리된 임포트 찾기
echo -e "\n--- main.dart 주석 처리된 임포트 ---" | tee -a $LOG_FILE
grep -n "^// import" $MAIN_FILE | tee -a $LOG_FILE

# router_config.dart에서 주석 처리된 임포트 찾기
echo -e "\n--- router_config.dart 주석 처리된 임포트 ---" | tee -a $LOG_FILE
grep -n "^// import" $ROUTER_FILE | tee -a $LOG_FILE

# 함수: 임포트 활성화 및 에러 체크
activate_and_check() {
    local file=$1
    local line_num=$2
    local import_line=$3
    
    echo -e "\n${GREEN}✅ 활성화 시도: $import_line${NC}"
    echo "파일: $file, 라인: $line_num" | tee -a $LOG_FILE
    
    # 임포트 활성화 (주석 제거)
    sed -i '' "${line_num}s/^\/\/ //" "$file"
    
    echo "⏳ 빌드 테스트 중..."
    
    # 빌드 및 에러 체크
    if flutter analyze --no-pub 2>&1 | grep -E "error|Error" > temp_errors.txt; then
        echo -e "${RED}❌ 에러 발견!${NC}"
        echo "--- $import_line 활성화 시 에러 ---" >> $ERROR_LOG
        cat temp_errors.txt | tee -a $ERROR_LOG
        
        # 사용자에게 계속할지 물어보기
        echo -e "${YELLOW}계속하시겠습니까? (y/n/s=skip):${NC}"
        read -r response
        
        case $response in
            y|Y)
                echo "에러가 있지만 계속 진행합니다."
                ;;
            s|S)
                echo "이 임포트를 건너뜁니다. 주석 처리 복원..."
                sed -i '' "${line_num}s/^/\/\/ /" "$file"
                ;;
            *)
                echo "중단합니다."
                rm temp_errors.txt
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}✅ 에러 없음!${NC}"
        echo "✅ $import_line - 성공" >> $LOG_FILE
    fi
    
    rm -f temp_errors.txt
}

# main.dart 처리
echo -e "\n${YELLOW}📋 main.dart 처리 시작${NC}"
while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    import_line=$(echo "$line" | cut -d: -f2-)
    
    activate_and_check "$MAIN_FILE" "$line_num" "$import_line"
    
    # 잠시 대기
    sleep 1
done < <(grep -n "^// import" $MAIN_FILE)

# router_config.dart 처리
echo -e "\n${YELLOW}📋 router_config.dart 처리 시작${NC}"
while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    import_line=$(echo "$line" | cut -d: -f2-)
    
    activate_and_check "$ROUTER_FILE" "$line_num" "$import_line"
    
    # 잠시 대기
    sleep 1
done < <(grep -n "^// import" $ROUTER_FILE)

echo -e "\n${GREEN}✨ 완료!${NC}"
echo "📄 로그 파일: $LOG_FILE"
echo "❌ 에러 로그: $ERROR_LOG"

# 최종 상태 확인
echo -e "\n${YELLOW}📊 최종 빌드 상태 확인...${NC}"
flutter build ios --debug --simulator --no-pub 2>&1 | tail -20