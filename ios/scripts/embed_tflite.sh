#!/bin/bash
# TensorFlowLiteC.framework를 앱 번들에 임베드하는 스크립트
# 시뮬레이터에서 mediapipe_face_mesh가 런타임에 로드할 수 있도록 함

set -e

echo "🔧 Embedding TensorFlowLiteC.framework..."

# 프레임워크 소스 경로
TFLITE_FRAMEWORK="${HOME}/.pub-cache/hosted/pub.dev/mediapipe_face_mesh-1.2.4/ios/Frameworks/TensorFlowLiteC.framework"

# 앱 번들의 Frameworks 폴더
DEST_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

if [ ! -d "$TFLITE_FRAMEWORK" ]; then
    echo "⚠️ TensorFlowLiteC.framework not found at $TFLITE_FRAMEWORK"
    echo "   Skipping framework embedding..."
    exit 0
fi

# Frameworks 폴더 생성
mkdir -p "$DEST_DIR"

# 프레임워크 복사
cp -R "$TFLITE_FRAMEWORK" "$DEST_DIR/"
echo "✅ Copied TensorFlowLiteC.framework to $DEST_DIR"

# 코드 사이닝 (실제 기기 빌드 시 필요)
if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" ] && [ "${EXPANDED_CODE_SIGN_IDENTITY}" != "-" ]; then
    echo "🔏 Signing TensorFlowLiteC.framework..."
    codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --timestamp=none "$DEST_DIR/TensorFlowLiteC.framework" 2>/dev/null || true
fi

echo "✅ TensorFlowLiteC.framework embedding complete"
