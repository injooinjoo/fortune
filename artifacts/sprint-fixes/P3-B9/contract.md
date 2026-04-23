# P3 / B9 (+C2) — Info.plist 버전 정렬 + 중복 URL scheme 제거

## 문제
1. `apps/mobile-rn/ios/app/Info.plist:24` 의 `CFBundleShortVersionString`이 `1.0.8`인데 `app.config.ts:89`와 `package.json`은 `1.0.9`. EAS가 `appVersionSource:"remote"`로 동작하지만 `./plugins/with-ios-prebuilt-react-native` 기반 bare 워크플로우에서 로컬 Info.plist가 바이너리에 반영될 가능성.
2. 같은 파일 32-33줄 `CFBundleURLSchemes`에 `com.beyond.fortune`가 중복 등록. `app.config.ts:92`는 단일 scheme 선언. 리뷰어 sysdiagnose 경고 유발.

## 수용 기준
1. `CFBundleShortVersionString`을 `1.0.9`로 수정
2. 중복된 `com.beyond.fortune` 엔트리 1개 제거 (하나만 유지)
3. 다른 Info.plist 키 변경 금지 (Speech/iPad/다크모드는 별도 phase)
4. `CFBundleVersion`(빌드 번호) 건드리지 않음 — EAS `autoIncrement: true`가 관리

## 비수용 기준
- `NSSpeechRecognitionUsageDescription` 변경 금지 (P4-B10)
- `UISupportedInterfaceOrientations~ipad` 변경 금지 (W6 별도)
- `UIUserInterfaceStyle` 변경 금지 (P5-B8)

## Quality Gate
- [ ] plutil로 XML 유효성 확인
- [ ] Reviewer PASS
- [ ] iOS Domain: EAS build 시 버전 덮어쓰는지 확인 권고
