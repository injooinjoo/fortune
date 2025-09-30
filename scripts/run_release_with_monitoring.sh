#!/bin/bash

# Flutter 릴리즈 빌드 + 자동 JIRA 에러 모니터링 시스템
# 사용법: ./run_release_with_monitoring.sh

set -e

DEVICE_ID="00008140-00120304260B001C"
LOG_FILE="/tmp/flutter_release_logs.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "🚀 Flutter 릴리즈 빌드 + 에러 모니터링"
echo "========================================"
echo ""

# 1. 로그 파일 초기화
echo "📝 로그 파일 초기화: $LOG_FILE"
> "$LOG_FILE"

# 2. 백그라운드에서 에러 모니터 시작
echo "🤖 자동 JIRA 에러 리포터 시작..."
python3 "$SCRIPT_DIR/scripts/auto_jira_error_reporter.py" &
MONITOR_PID=$!
echo "   PID: $MONITOR_PID"
sleep 2

# 3. Flutter 릴리즈 빌드 시작
echo ""
echo "🔨 Flutter 릴리즈 빌드 시작..."
echo "   디바이스: $DEVICE_ID"
echo "   로그: $LOG_FILE"
echo ""
echo "----------------------------------------"

# Flutter 실행 (로그를 파일과 화면에 동시 출력)
flutter run --release -d "$DEVICE_ID" 2>&1 | tee "$LOG_FILE"

# 4. 종료 시 정리
echo ""
echo "----------------------------------------"
echo "⏹️  빌드 종료"

# 모니터 프로세스 종료
if kill -0 $MONITOR_PID 2>/dev/null; then
    echo "🛑 에러 모니터 종료 중..."
    kill $MONITOR_PID 2>/dev/null || true
    wait $MONITOR_PID 2>/dev/null || true
fi

echo "✅ 완료"
echo ""
echo "📊 로그 파일: $LOG_FILE"
echo "   확인: cat $LOG_FILE"