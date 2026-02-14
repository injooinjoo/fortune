# ZPZG → Figma 마이그레이션 스크립트

앱의 모든 화면을 자동으로 캡처하고 Figma 업로드용으로 조직화하는 스크립트입니다.

## 빠른 시작

```bash
# 1. Flutter Web 서버 실행 (터미널 1)
flutter run -d chrome --web-port=3000

# 2. 대량 스크린샷 캡처 (터미널 2)
node playwright/scripts/mass-screenshot.js

# 3. Figma용 조직화
node playwright/scripts/organize-screenshots.js
```

## 스크립트 설명

### 1. `mass-screenshot.js`
- **목적**: 120개+ 화면을 Light/Dark 모드로 자동 캡처
- **출력**: `screenshots/raw/{category}/{page}_{theme}.png`
- **예상 시간**: ~15-20분 (240장 기준)

### 2. `organize-screenshots.js`
- **목적**: 캡처된 스크린샷을 Figma 구조로 조직화
- **출력**:
  - `screenshots/figma_ready/` - 업로드용 폴더
  - `screenshots/metadata/figma-upload-checklist.md` - 체크리스트
  - `screenshots/metadata/figma-token-reference.md` - 디자인 토큰 참조

## 폴더 구조

```
screenshots/
├── raw/                    # 원본 캡처
│   ├── auth/
│   ├── home/
│   ├── profile/
│   ├── fortune_basic/
│   └── ...
├── figma_ready/            # Figma 업로드용
│   ├── 01-Auth-Onboarding/
│   │   ├── light/
│   │   └── dark/
│   ├── 02-Home-Navigation/
│   └── ...
└── metadata/
    ├── manifest.json
    ├── screens-metadata.json
    ├── figma-upload-checklist.md
    └── figma-token-reference.md
```

## 캡처 화면 목록 (120+)

| 카테고리 | 화면 수 | 설명 |
|----------|---------|------|
| Auth & Onboarding | 5 | 로그인, 회원가입, 온보딩 |
| Home & Navigation | 5 | 홈, 운세 목록, 트렌드 |
| Profile & Settings | 16 | 프로필, 설정, 구독 |
| Fortune - Basic | 10 | MBTI, 궁합, 유명인 |
| Fortune - Traditional | 5 | 사주, 타로, 관상 |
| Fortune - Love | 3 | 연애운, 소개팅 |
| Fortune - Career | 4 | 커리어, 투자 |
| Fortune - Time | 5 | 바이오리듬, 연간운 |
| Fortune - Health | 12 | 건강, 스포츠 |
| Fortune - Special | 3 | 꿈해몽, 행운아이템 |
| Interactive | 10 | 타로채팅, 심리테스트 |
| Trend | 3 | 심리테스트, 월드컵 |

**총: ~80 라우트 × 2 테마 = ~160장**

## Figma 업로드 프로세스

### Step 1: Codia AI Pro 구독
- https://www.figma.com/community/plugin/1329812760871373657
- Pro 플랜 (~$20/월) 권장 (배치 처리)

### Step 2: Foundation 설정
1. Figma에서 새 프로젝트 생성: "Fortune Design System"
2. Variables 생성 (Light/Dark modes)
3. Text Styles 생성 (27개)
4. 참조: `screenshots/metadata/figma-token-reference.md`

### Step 3: 화면 변환
1. Codia AI 플러그인 실행
2. `figma_ready/` 폴더의 스크린샷 업로드
3. 카테고리별 배치 변환
4. Auto Layout 확인

### Step 4: 컴포넌트 추출
1. 공통 요소 식별 (버튼, 카드, 앱바)
2. Component로 변환
3. Properties 설정

## 문제 해결

### Flutter 서버 연결 안 됨
```bash
# 포트 확인
lsof -i :3000

# 다른 포트로 실행
flutter run -d chrome --web-port=3001
```

### 스크린샷 품질 낮음
`mass-screenshot.js`에서 deviceScaleFactor 조정:
```javascript
const context = await browser.newContext({
  viewport: CONFIG.viewport,
  deviceScaleFactor: 3, // 1, 2, 3 중 선택
});
```

### 특정 화면 캡처 실패
- 인증이 필요한 화면은 수동 캡처 필요
- `ROUTES` 객체에서 해당 라우트 주석 처리 후 재실행

## 다음 단계

1. ✅ 스크린샷 캡처 완료
2. ⬜ Figma 프로젝트 생성
3. ⬜ Codia AI Pro 구독
4. ⬜ Foundation (Variables, Styles) 설정
5. ⬜ 화면 변환 및 조립
6. ⬜ 컴포넌트 라이브러리 구축
7. ⬜ Design Spec 문서화
