#!/bin/bash

# MediaPipe TensorFlowLiteC 시뮬레이터 빌드 수정 스크립트
# TensorFlowLiteC.framework는 iOS 기기 전용이라 시뮬레이터에서 링크 에러 발생
# 이 스크립트는 시뮬레이터용 더미 프레임워크를 생성합니다.

set -e

echo "🔧 MediaPipe 시뮬레이터 빌드 수정 시작..."

# pub-cache 경로 찾기
PUB_CACHE="${HOME}/.pub-cache/hosted/pub.dev"
MEDIAPIPE_PATH=$(find "${PUB_CACHE}" -maxdepth 1 -type d -name "mediapipe_face_mesh-*" | head -1)

if [ -z "$MEDIAPIPE_PATH" ]; then
    echo "❌ mediapipe_face_mesh 패키지를 찾을 수 없습니다."
    echo "   먼저 'flutter pub get'을 실행해주세요."
    exit 1
fi

FRAMEWORK_PATH="${MEDIAPIPE_PATH}/ios/Frameworks/TensorFlowLiteC.framework"

if [ ! -d "$FRAMEWORK_PATH" ]; then
    echo "❌ TensorFlowLiteC.framework를 찾을 수 없습니다: $FRAMEWORK_PATH"
    exit 1
fi

echo "📍 Framework 경로: $FRAMEWORK_PATH"

# 시뮬레이터용 슬라이스가 있는지 확인
ARCHS=$(lipo -archs "${FRAMEWORK_PATH}/TensorFlowLiteC" 2>/dev/null || echo "")
echo "📦 현재 아키텍처: $ARCHS"

if [[ "$ARCHS" == *"x86_64"* ]] || [[ "$ARCHS" == *"arm64"* && "$ARCHS" != "arm64" ]]; then
    echo "✅ 시뮬레이터 아키텍처가 이미 포함되어 있습니다."
    exit 0
fi

echo "⚠️ 시뮬레이터 아키텍처 없음. 더미 라이브러리 생성 중..."

# 백업 생성
BACKUP_PATH="${FRAMEWORK_PATH}/TensorFlowLiteC.device.backup"
if [ ! -f "$BACKUP_PATH" ]; then
    cp "${FRAMEWORK_PATH}/TensorFlowLiteC" "$BACKUP_PATH"
    echo "📋 백업 생성: $BACKUP_PATH"
fi

# 더미 소스 파일 생성
TEMP_DIR=$(mktemp -d)
cat > "${TEMP_DIR}/dummy.c" << 'EOF'
// TensorFlowLiteC dummy for iOS Simulator
// This is a stub that does nothing - MediaPipe features won't work on simulator

void TfLiteInterpreterCreate() {}
void TfLiteInterpreterDelete() {}
void TfLiteInterpreterInvoke() {}
void TfLiteModelCreate() {}
void TfLiteModelDelete() {}
void TfLiteTensorData() {}
void TfLiteTensorByteSize() {}
void TfLiteVersion() { }

// Add more stubs as needed
EOF

# 시뮬레이터용 더미 라이브러리 빌드
echo "🔨 x86_64 시뮬레이터용 더미 빌드..."
xcrun clang -arch x86_64 -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) \
    -dynamiclib -o "${TEMP_DIR}/TensorFlowLiteC_x86_64.dylib" \
    "${TEMP_DIR}/dummy.c" \
    -install_name @rpath/TensorFlowLiteC.framework/TensorFlowLiteC \
    -Xlinker -no_warn_duplicate_libraries 2>/dev/null || true

echo "🔨 arm64 시뮬레이터용 더미 빌드..."
xcrun clang -arch arm64 -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) \
    -target arm64-apple-ios15.0-simulator \
    -dynamiclib -o "${TEMP_DIR}/TensorFlowLiteC_arm64_sim.dylib" \
    "${TEMP_DIR}/dummy.c" \
    -install_name @rpath/TensorFlowLiteC.framework/TensorFlowLiteC \
    -Xlinker -no_warn_duplicate_libraries 2>/dev/null || true

# 유니버설 바이너리 생성
echo "🔗 유니버설 바이너리 생성..."

LIPO_INPUTS=("$BACKUP_PATH")

if [ -f "${TEMP_DIR}/TensorFlowLiteC_x86_64.dylib" ]; then
    LIPO_INPUTS+=("${TEMP_DIR}/TensorFlowLiteC_x86_64.dylib")
fi

if [ -f "${TEMP_DIR}/TensorFlowLiteC_arm64_sim.dylib" ]; then
    LIPO_INPUTS+=("${TEMP_DIR}/TensorFlowLiteC_arm64_sim.dylib")
fi

if [ ${#LIPO_INPUTS[@]} -gt 1 ]; then
    lipo -create "${LIPO_INPUTS[@]}" -output "${FRAMEWORK_PATH}/TensorFlowLiteC"
    echo "✅ 유니버설 바이너리 생성 완료!"

    # 결과 확인
    NEW_ARCHS=$(lipo -archs "${FRAMEWORK_PATH}/TensorFlowLiteC")
    echo "📦 새 아키텍처: $NEW_ARCHS"
else
    echo "⚠️ 더미 라이브러리 생성 실패. 원본 유지."
fi

# 정리
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 완료! 이제 시뮬레이터에서 빌드할 수 있습니다."
echo "   단, Face AI 기능은 시뮬레이터에서 작동하지 않습니다."
echo ""
echo "📝 다음 단계:"
echo "   cd ios && pod install"
echo "   flutter run"
