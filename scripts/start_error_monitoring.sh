#!/bin/bash

# Flutter 실시간 에러 모니터링 시스템 설정 스크립트
# 사용법: ./scripts/start_error_monitoring.sh [install|uninstall|start|stop|status]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLIST_FILE="$SCRIPT_DIR/com.fortune.error.monitor.plist"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCHAGENT_PATH="$LAUNCHAGENT_DIR/com.fortune.error.monitor.plist"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_header() {
    echo ""
    echo "========================================"
    echo "🤖 Flutter 실시간 에러 모니터링 시스템"
    echo "========================================"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# LaunchAgent 설치
install_launchagent() {
    print_header
    echo "📦 LaunchAgent 설치 중..."

    # LaunchAgents 디렉토리 생성
    mkdir -p "$LAUNCHAGENT_DIR"

    # plist 파일 복사
    cp "$PLIST_FILE" "$LAUNCHAGENT_PATH"
    print_success "plist 파일 복사 완료"

    # 권한 설정
    chmod 644 "$LAUNCHAGENT_PATH"
    print_success "권한 설정 완료"

    # LaunchAgent 로드
    launchctl load "$LAUNCHAGENT_PATH" 2>/dev/null || true
    launchctl start com.fortune.error.monitor 2>/dev/null || true

    print_success "LaunchAgent 설치 완료!"
    echo ""
    print_info "백그라운드 모니터링이 자동으로 시작되었습니다."
    print_info "시스템 재부팅 후에도 자동으로 실행됩니다."
    echo ""
}

# LaunchAgent 제거
uninstall_launchagent() {
    print_header
    echo "🗑️  LaunchAgent 제거 중..."

    # 서비스 중지
    launchctl stop com.fortune.error.monitor 2>/dev/null || true
    launchctl unload "$LAUNCHAGENT_PATH" 2>/dev/null || true

    # plist 파일 삭제
    if [ -f "$LAUNCHAGENT_PATH" ]; then
        rm "$LAUNCHAGENT_PATH"
        print_success "LaunchAgent 제거 완료"
    else
        print_warning "LaunchAgent가 설치되어 있지 않습니다."
    fi
    echo ""
}

# 서비스 시작
start_service() {
    print_header
    echo "🚀 서비스 시작 중..."

    if [ ! -f "$LAUNCHAGENT_PATH" ]; then
        print_error "LaunchAgent가 설치되어 있지 않습니다."
        print_info "먼저 'install' 명령으로 설치하세요."
        exit 1
    fi

    launchctl start com.fortune.error.monitor
    print_success "서비스 시작 완료"
    echo ""
}

# 서비스 중지
stop_service() {
    print_header
    echo "⏹️  서비스 중지 중..."

    launchctl stop com.fortune.error.monitor
    print_success "서비스 중지 완료"
    echo ""
}

# 서비스 상태 확인
check_status() {
    print_header
    echo "📊 서비스 상태 확인 중..."
    echo ""

    # LaunchAgent 설치 여부
    if [ -f "$LAUNCHAGENT_PATH" ]; then
        print_success "LaunchAgent 설치됨"
    else
        print_warning "LaunchAgent 미설치"
    fi

    # 서비스 실행 상태
    if launchctl list | grep -q "com.fortune.error.monitor"; then
        print_success "서비스 실행 중"

        # PID 확인
        PID=$(launchctl list | grep "com.fortune.error.monitor" | awk '{print $1}')
        if [ "$PID" != "-" ]; then
            echo "   PID: $PID"
        fi
    else
        print_warning "서비스 미실행"
    fi

    # 로그 파일 확인
    echo ""
    echo "📝 로그 파일:"
    LOG_FILE="/tmp/fortune_error_monitor.log"
    ERROR_LOG_FILE="/tmp/fortune_error_monitor_error.log"

    if [ -f "$LOG_FILE" ]; then
        LOG_SIZE=$(wc -l < "$LOG_FILE")
        echo "   $LOG_FILE (${LOG_SIZE} lines)"
    else
        echo "   $LOG_FILE (없음)"
    fi

    if [ -f "$ERROR_LOG_FILE" ]; then
        ERROR_SIZE=$(wc -l < "$ERROR_LOG_FILE")
        echo "   $ERROR_LOG_FILE (${ERROR_SIZE} lines)"
    fi

    # 에러 로그 파일 확인
    echo ""
    echo "🚨 에러 로그 파일:"
    ERROR_JSON="/tmp/fortune_runtime_errors.json"
    PROCESSED_JSON="/tmp/fortune_processed_errors.json"

    if [ -f "$ERROR_JSON" ]; then
        ERROR_COUNT=$(jq '. | length' "$ERROR_JSON" 2>/dev/null || echo "0")
        echo "   $ERROR_JSON (${ERROR_COUNT} errors)"
    else
        echo "   $ERROR_JSON (없음)"
    fi

    if [ -f "$PROCESSED_JSON" ]; then
        PROCESSED_COUNT=$(jq '.processed_hashes | length' "$PROCESSED_JSON" 2>/dev/null || echo "0")
        echo "   $PROCESSED_JSON (${PROCESSED_COUNT} processed)"
    fi

    echo ""
}

# 수동 실행 (포그라운드)
run_foreground() {
    print_header
    echo "🔄 포그라운드 모드로 실행 중..."
    echo "   (Ctrl+C로 종료)"
    echo ""

    python3 "$SCRIPT_DIR/runtime_error_monitor.py"
}

# 사용법 출력
print_usage() {
    print_header
    echo "사용법:"
    echo "  ./scripts/start_error_monitoring.sh [command]"
    echo ""
    echo "Commands:"
    echo "  install    - LaunchAgent 설치 (백그라운드 자동 실행)"
    echo "  uninstall  - LaunchAgent 제거"
    echo "  start      - 서비스 시작"
    echo "  stop       - 서비스 중지"
    echo "  status     - 서비스 상태 확인"
    echo "  run        - 포그라운드 모드로 실행 (테스트용)"
    echo ""
    echo "예시:"
    echo "  # 백그라운드 모니터링 설치 및 시작"
    echo "  ./scripts/start_error_monitoring.sh install"
    echo ""
    echo "  # 상태 확인"
    echo "  ./scripts/start_error_monitoring.sh status"
    echo ""
    echo "  # 포그라운드 테스트"
    echo "  ./scripts/start_error_monitoring.sh run"
    echo ""
}

# 메인 로직
case "${1:-}" in
    install)
        install_launchagent
        check_status
        ;;
    uninstall)
        uninstall_launchagent
        ;;
    start)
        start_service
        check_status
        ;;
    stop)
        stop_service
        check_status
        ;;
    status)
        check_status
        ;;
    run)
        run_foreground
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
