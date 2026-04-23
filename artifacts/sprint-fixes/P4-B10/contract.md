# P4 / B10 — NSSpeechRecognitionUsageDescription 한국어화

## 문제
`apps/mobile-rn/ios/app/Info.plist:64-65`의 `NSSpeechRecognitionUsageDescription`이 플러그인 기본 영문값
`"Allow $(PRODUCT_NAME) to use speech recognition."`를 그대로 사용. 다른 권한은 모두 한국어인데 이것만 영문 → 5.1.1 리뷰어가 "권한 목적이 불분명" 사유로 리젝 단골.

원인: `app.config.ts:126-128`의 `expo-speech-recognition` 플러그인 옵션에 `speechRecognitionPermission` prop 누락. 플러그인 기본값(`node_modules/expo-speech-recognition/app.plugin.js:84`)이 fallback.

## 수용 기준
1. `expo-speech-recognition` 플러그인 옵션에 `speechRecognitionPermission` 추가
2. 문구: "음성을 텍스트로 변환하기 위해 음성 인식 접근이 필요합니다."
3. 기존 `microphonePermission` 유지 (마이크는 소리 캡처, 음성 인식은 텍스트 변환 — 분리된 권한)
4. prebuild 시 Info.plist NSSpeechRecognitionUsageDescription에 한국어 문구 반영
5. tsc 0 errors

## 비수용 기준
- 다른 권한 문자열 변경 금지
- 마이크 문구 변경 금지 (이미 한국어)
- `app.config.ts`의 다른 섹션 터치 금지

## Quality Gate
- [ ] tsc --noEmit
- [ ] Reviewer PASS (문구 자연스러움 + Apple reviewer 기준 부합)
