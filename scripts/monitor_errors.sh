#!/bin/bash

# Flutter Error Monitoring & JIRA Auto-Reporter
# 릴리즈 모드 앱 실행과 에러 모니터링을 자동화합니다.

set -e

echo "🚀 Flutter Error Monitoring & JIRA Auto-Reporter"
echo "=================================================="

# 프로젝트 루트로 이동
cd "$(dirname "$0")/.."

# 변수 설정
DEVICE_ID="00008140-00120304260B001C"  # iPhone 16 Pro
LOG_FILE="/tmp/flutter_release_logs.txt"
PYTHON_SCRIPT="error_to_jira.py"

# 함수 정의
cleanup() {
    echo ""
    echo "🛑 Cleaning up processes..."
    pkill -f "flutter run" 2>/dev/null || true
    pkill -f "python.*error_to_jira" 2>/dev/null || true
    echo "✅ Cleanup completed"
}

# 시그널 핸들러 설정
trap cleanup EXIT INT TERM

# 기존 로그 파일 백업
if [ -f "$LOG_FILE" ]; then
    BACKUP_FILE="${LOG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$LOG_FILE" "$BACKUP_FILE"
    echo "📁 Previous log backed up to: $BACKUP_FILE"
fi

# 메뉴 표시
echo ""
echo "Select monitoring mode:"
echo "1. 🔍 Process existing logs only"
echo "2. 📱 Run app + monitor in real-time"
echo "3. 🔄 Full monitoring (recommended)"
echo "4. 📊 View JIRA project"
echo "5. ❌ Exit"
echo ""

read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo "🔍 Processing existing logs..."
        if [ -f "$LOG_FILE" ]; then
            python3 "$PYTHON_SCRIPT" <<< "1"
        else
            echo "❌ No log file found at $LOG_FILE"
            exit 1
        fi
        ;;

    2)
        echo "📱 Starting Flutter app in release mode..."
        echo "📝 Logs will be saved to: $LOG_FILE"

        # Flutter 앱 백그라운드 실행
        flutter run --release -d "$DEVICE_ID" 2>&1 | tee "$LOG_FILE" &
        FLUTTER_PID=$!

        echo "⏳ Waiting for app to start..."
        sleep 10

        echo "🔄 Starting error monitoring..."
        python3 "$PYTHON_SCRIPT" <<< "2"
        ;;

    3)
        echo "🔄 Full monitoring mode activated!"
        echo "📱 Starting Flutter app + 🔍 Processing existing logs + 📊 Real-time monitoring"

        # 기존 로그가 있으면 먼저 처리
        if [ -f "$LOG_FILE" ]; then
            echo "📋 Processing existing logs first..."
            python3 "$PYTHON_SCRIPT" <<< "1"
        fi

        # Flutter 앱 백그라운드 실행
        echo "📱 Starting Flutter app in release mode..."
        flutter run --release -d "$DEVICE_ID" 2>&1 | tee "$LOG_FILE" &
        FLUTTER_PID=$!

        echo "⏳ Waiting for app to start..."
        sleep 10

        echo "🔄 Starting real-time error monitoring..."
        python3 "$PYTHON_SCRIPT" <<< "2"
        ;;

    4)
        echo "📊 Opening JIRA project..."
        open "https://beyond-app.atlassian.net/jira/software/projects/KAN/boards/1"
        ;;

    5)
        echo "👋 Goodbye!"
        exit 0
        ;;

    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "✅ Monitoring session completed"
echo "📊 Check JIRA project: https://beyond-app.atlassian.net/jira/software/projects/KAN/boards/1"