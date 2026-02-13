#!/bin/bash

# ZPZG UITests 설정 스크립트
# Xcode에서 수동으로 UITests 타겟을 추가해야 합니다.

echo "============================================"
echo "ZPZG 스크린샷 자동화 설정 가이드"
echo "============================================"
echo ""
echo "1. Xcode에서 Runner.xcworkspace 열기"
echo ""
echo "2. UITests 타겟 추가:"
echo "   - File > New > Target 선택"
echo "   - 'UI Testing Bundle' 선택"
echo "   - Product Name: RunnerUITests"
echo "   - Target to be Tested: Runner"
echo "   - Language: Swift"
echo ""
echo "3. 생성된 파일 교체:"
echo "   - 자동 생성된 RunnerUITests.swift 삭제"
echo "   - RunnerUITests 폴더에 다음 파일 추가:"
echo "     * ScreenshotUITests.swift (이미 생성됨)"
echo "     * SnapshotHelper.swift (이미 생성됨)"
echo ""
echo "4. 스크린샷 촬영:"
echo "   cd ios"
echo "   fastlane snapshot"
echo ""
echo "5. 앱스토어 제출:"
echo "   fastlane deliver"
echo ""
echo "============================================"
echo ""

# fastlane snapshot init (이미 Snapfile이 있으면 스킵)
if [ ! -f "fastlane/Snapfile" ]; then
    echo "Snapfile 생성 중..."
    cd fastlane
    fastlane snapshot init
    cd ..
fi

echo "설정 완료! Xcode에서 UITests 타겟을 추가해주세요."
