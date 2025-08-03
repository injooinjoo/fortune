#!/bin/bash

# Flutter 앱 실행 스크립트
echo "Starting Fortune Flutter App..."
echo "첫 컴파일은 5-10분 정도 소요될 수 있습니다..."
echo "컴파일 중..."

# Chrome에서 실행
flutter run -d chrome --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false

# 만약 Chrome이 안되면 아래 명령어 시도:
# flutter run -d 1B54EF52-7E41-4040-A236-C169898F5527  # iOS Simulator
# flutter run -d macos  # macOS 앱