# ZPZG 스크린샷 촬영 가이드

## 개요
앱스토어 심사를 위해 "운세" 텍스트가 제거된 새 스크린샷을 촬영합니다.

---

## 방법 1: 자동 촬영 (Fastlane Snapshot) ⭐ 추천

### 사전 준비

1. **Xcode에서 UITests 타겟 추가**
   ```
   1. Runner.xcworkspace 열기
   2. File > New > Target
   3. "UI Testing Bundle" 선택
   4. Product Name: RunnerUITests
   5. Target to be Tested: Runner
   6. Language: Swift
   ```

2. **테스트 파일 연결**
   - 자동 생성된 `RunnerUITests.swift` 삭제
   - `ios/RunnerUITests/` 폴더의 파일들을 타겟에 추가:
     - `ScreenshotUITests.swift`
     - `SnapshotHelper.swift`

### 스크린샷 촬영

```bash
cd ios
fastlane snapshot
```

### 결과 확인
- 스크린샷: `ios/fastlane/screenshots/ko/`
- HTML 리포트: `ios/fastlane/screenshots/screenshots.html`

---

## 방법 2: 수동 촬영

시뮬레이터에서 직접 스크린샷을 촬영합니다.

### 필요한 디바이스
1. **iPhone 6.5"** - iPhone 15 Pro Max 시뮬레이터
2. **iPad Pro 12.9"** - iPad Pro (6th gen) 시뮬레이터

### 촬영할 화면 (8장)
| # | 화면 | 설명 |
|---|------|------|
| 1 | 홈 채팅 | 메인 인터페이스 |
| 2 | 기능 칩 목록 | 다양한 기능 표시 |
| 3 | Face AI | 얼굴 분석 화면 |
| 4 | 인사이트 카드 | 타로/카드 화면 |
| 5 | 바이오리듬 | 바이오리듬 그래프 |
| 6 | 프로필 | 사용자 프로필 |
| 7 | MBTI 분석 | 성격 분석 |
| 8 | 호흡 명상 | 명상 기능 |

### 스크린샷 단축키
- **시뮬레이터**: `Cmd + S`
- **저장 위치**: Desktop

### 파일 이름 규칙
```
iPhone 6.5" Display-1.png
iPhone 6.5" Display-2.png
...
iPad Pro (6th Gen) 12.9" Display-1.png
...
```

### 파일 복사
```bash
# 스크린샷을 fastlane 폴더로 복사
cp ~/Desktop/*.png ios/fastlane/screenshots/ko/
```

---

## 앱스토어 제출

스크린샷 촬영 후:

```bash
cd ios

# 메타데이터만 업로드 (스크린샷 포함)
fastlane deliver

# 또는 빌드 + 업로드
fastlane release
```

---

## 주의사항

### ❌ 피해야 할 텍스트
- "운세"
- "점술"
- "fortune telling"

### ✅ 사용 가능한 텍스트
- "인사이트"
- "분석"
- "가이드"
- "AI 관상"
- "Face AI"

---

## 문제 해결

### UITests 빌드 실패 시
```bash
# 프로젝트 클린
cd ios
rm -rf build/
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner
```

### Snapshot 실행 오류 시
```bash
# Fastlane 업데이트
bundle update fastlane

# 시뮬레이터 리셋
xcrun simctl erase all
```
