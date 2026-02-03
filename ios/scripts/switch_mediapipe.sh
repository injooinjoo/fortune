#!/bin/bash
# MediaPipe TensorFlowLiteC 시뮬레이터/기기 전환 스크립트
# Usage: ./switch_mediapipe.sh [simulator|device]

FRAMEWORK_PATH="$HOME/.pub-cache/hosted/pub.dev/mediapipe_face_mesh-1.2.4/ios/Frameworks/TensorFlowLiteC.framework"
BINARY_PATH="$FRAMEWORK_PATH/TensorFlowLiteC"
DEVICE_PATH="$FRAMEWORK_PATH/TensorFlowLiteC.device"
SIMULATOR_PATH="$FRAMEWORK_PATH/TensorFlowLiteC.simulator"

show_status() {
  echo "📱 TensorFlowLiteC 상태:"
  if [ -f "$BINARY_PATH" ]; then
    PLATFORM=$(vtool -show-build "$BINARY_PATH" 2>/dev/null | grep "platform " | head -1 | awk '{print $2}')
    echo "   현재 플랫폼: $PLATFORM"
  else
    echo "   ⚠️ 바이너리 없음"
  fi

  echo ""
  echo "📦 사용 가능한 바이너리:"
  [ -f "$DEVICE_PATH" ] && echo "   ✅ 기기용: $DEVICE_PATH" || echo "   ❌ 기기용 없음"
  [ -f "$SIMULATOR_PATH" ] && echo "   ✅ 시뮬레이터용: $SIMULATOR_PATH" || echo "   ❌ 시뮬레이터용 없음"
}

case "$1" in
  simulator|sim|s)
    if [ -f "$SIMULATOR_PATH" ]; then
      cp "$SIMULATOR_PATH" "$BINARY_PATH"
      echo "✅ 시뮬레이터용으로 전환 완료"
    else
      echo "❌ 시뮬레이터 스텁을 찾을 수 없습니다."
      echo "   pod install을 먼저 실행해주세요."
      exit 1
    fi
    ;;
  device|dev|d)
    if [ -f "$DEVICE_PATH" ]; then
      cp "$DEVICE_PATH" "$BINARY_PATH"
      echo "✅ 기기용으로 전환 완료"
      echo "   Face Mesh 468 랜드마크 완전 지원됨"
    else
      echo "❌ 기기용 바이너리를 찾을 수 없습니다."
      echo "   flutter pub cache repair mediapipe_face_mesh를 실행하세요."
      exit 1
    fi
    ;;
  status|"")
    show_status
    ;;
  *)
    echo "사용법: $0 [simulator|device|status]"
    echo ""
    echo "  simulator (sim, s): 시뮬레이터 빌드용 스텁으로 전환"
    echo "  device (dev, d):    실제 기기 빌드용 원본으로 전환"
    echo "  status:             현재 상태 확인"
    exit 1
    ;;
esac

echo ""
show_status
