# FortuneWatch - Xcode 설정 가이드

## 1. watchOS Target 추가

### Step 1: Target 생성
1. Xcode에서 `Runner.xcworkspace` 열기
2. **File > New > Target** 선택
3. **watchOS > App** 선택 후 Next
4. 설정 입력:
   - **Product Name**: `FortuneWatch`
   - **Bundle Identifier**: `com.beyond.fortune.watchapp`
   - **Language**: Swift
   - **User Interface**: SwiftUI
   - **Watch App for Existing iOS App**: Runner 선택
   - **Include Complication**: 체크
5. Finish 클릭

### Step 2: 기존 파일 교체
Target 생성 후 자동으로 만들어진 파일들을 삭제하고 이 폴더의 파일들을 사용하세요:

```
FortuneWatch/
├── FortuneWatchApp.swift        ← 교체
├── ContentView.swift            ← 교체
├── Info.plist                   ← 교체
├── FortuneWatch.entitlements    ← 추가
├── Models/
│   └── WatchDataManager.swift   ← 추가
├── Views/
│   ├── DailySummaryView.swift   ← 추가
│   ├── BiorhythmView.swift      ← 추가
│   ├── LuckyItemsView.swift     ← 추가
│   └── TimeSlotFortuneView.swift ← 추가
└── Complications/
    └── ComplicationViews.swift   ← 추가
```

## 2. App Groups 설정

### Step 1: Signing & Capabilities
1. FortuneWatch Target 선택
2. **Signing & Capabilities** 탭 클릭
3. **+ Capability** 클릭
4. **App Groups** 추가
5. `group.com.beyond.fortune` 선택 (Runner와 동일)

### Step 2: Entitlements 확인
`FortuneWatch.entitlements` 파일이 제대로 연결되었는지 확인:
- Build Settings > Code Signing Entitlements: `FortuneWatch/FortuneWatch.entitlements`

## 3. Build Settings

### Deployment Target
- **watchOS Deployment Target**: 9.0

### Bundle Identifier
- FortuneWatch: `com.beyond.fortune.watchapp`
- FortuneWatch Complication: `com.beyond.fortune.watchapp.complication`

## 4. Complication Target 설정 (선택)

WidgetKit 기반 Complication을 위해:

1. **File > New > Target**
2. **watchOS > Widget Extension** 선택
3. 설정:
   - **Product Name**: `FortuneWatchComplication`
   - **Include Configuration App Intent**: 체크 해제
4. 생성된 파일을 `ComplicationViews.swift` 내용으로 교체

## 5. 테스트

### 시뮬레이터
1. Scheme에서 `FortuneWatch` 선택
2. Watch 시뮬레이터 선택 (예: Apple Watch Series 9 - 45mm)
3. Run (⌘R)

### 실제 디바이스
1. iPhone과 Apple Watch가 페어링되어 있어야 함
2. iPhone에서 먼저 앱 실행하여 데이터 저장
3. Watch 앱 실행하여 데이터 확인

## 6. 체크리스트

- [ ] FortuneWatch Target 생성됨
- [ ] App Groups 설정 (`group.com.beyond.fortune`)
- [ ] 모든 Swift 파일이 Target에 포함됨
- [ ] Entitlements 파일 연결됨
- [ ] Build Settings에서 watchOS 9.0 이상
- [ ] 시뮬레이터에서 빌드 성공
- [ ] iPhone 앱에서 데이터 저장 후 Watch 앱에서 표시됨

## 7. 트러블슈팅

### "No such module 'SwiftUI'" 에러
- Build Settings > Supported Platforms에 watchOS 포함 확인

### App Groups 데이터가 안 읽힘
- iPhone 앱과 Watch 앱 모두 동일한 App Group ID 사용 확인
- iPhone 앱에서 `HomeWidget.saveWidgetData()` 호출 확인

### Complication이 표시 안 됨
- Watch 앱 실행 후 시계 화면 편집에서 Complication 추가
- Complication Target이 제대로 빌드되었는지 확인
