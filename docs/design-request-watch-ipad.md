# 온도(Ondo) — Apple Watch & iPad UI 디자인 의뢰 브리프

**요청자**: 온도 개발팀 (김인주 / 비욘드)
**수신자**: claude.ai/design
**작성일**: 2026-04-23
**목적**: 기존 iPhone 앱을 **Apple Watch**와 **iPad**로 확장하기 위한 UI 설계 의뢰

> 이 문서는 디자인 의뢰를 위한 **입력 자료(Input Brief)** 입니다. 기존 iPhone 앱의 IA·토큰·핵심 컴포넌트를 요약하고, 새 플랫폼에서 필요한 스코프·제약·기대 산출물을 정의합니다.

---

## 0. TL;DR

| 항목 | Apple Watch | iPad |
|------|-------------|------|
| 우선순위 | Phase 2 (MVP 이후) | **Phase 1 (즉시)** |
| 타깃 유즈케이스 | ① 오늘의 한줄 운세 ② 운세 도착 알림 ③ Complication(워치페이스) | ① 채팅 + 결과 카드 동시 조망 ② 결과 카드 대화면 뷰잉 ③ 사주판·관상·타로의 시각적 몰입 |
| 범위 | Standalone 없음. Companion + Complication + Notification 중심 | iPhone UI 재사용 + **Split View / Sidebar** 적응 |
| 톤 | 초미니멀, glanceable(1-2초) | 잡지·기도실 같은 몰입형. 여백 넉넉 |
| 기술 | WatchOS target 신규. RN 미지원 → **SwiftUI Widget Extension / Watch App** (native) | 기존 RN 화면 재활용 + 레이아웃 분기 |

---

## 1. 프로젝트 정체성

### 앱 개요
- **이름**: 온도 (Ondo)
- **한줄소개**: AI 페르소나 + 사주 기반 **운세 상담 채팅 앱**
- **현재 플랫폼**: iOS / Android (Expo SDK 54, RN 0.81)
- **버전**: 1.0.9 / 번들 ID `com.beyond.fortune`
- **위치**: 한국 정서 + 동양 명리학 + 현대 AI 캐릭터 채팅의 교집합

### 브랜드 톤
- **형용사**: 차분한 · 신비로운 · 친밀한 · 밤의 톤
- **피할 것**: 점집·미신 인상 / 토스류 과도한 밝음 / 게임성 과장
- **목표 정서**: "조용한 방에서 AI 친구가 내 얘기를 들어주는 느낌"

---

## 2. 기존 디자인 시스템 (재사용 전제)

### 2.1 컬러 — 다크 전용
| Token | HEX | 용도 |
|-------|-----|------|
| `bg.base` | `#0B0B10` | 앱 배경 (거의 검정에 가까운 딥 퍼플) |
| `bg.surface` | `#141421` | 카드/시트 |
| `text.primary` | `#F5F6FB` | 주 텍스트 |
| `text.secondary` | `#A8AAB8` | 보조 |
| `accent.primary` | `#8B7BE8` | CTA / 강조 (라벤더 퍼플) |
| `accent.gold` | `#D4A857` | 사주·오행(토) 강조 |

**오방색(五行)** — 결과 카드 계열색
`wood #5FA66B` · `fire #E26464` · `earth #D4A857` · `metal #9FA4B0` · `water #4A7AB8`

### 2.2 타이포 (시스템 폰트)
- iOS: SF Pro Text / SF Pro Display
- 한글: Pretendard (또는 Apple SD Gothic Neo 폴백)
- 위계: Display / Headline / Title / Body / Caption 5단

### 2.3 핵심 프리미티브
`ResultCardFrame` · `ScoreDial`(반원 게이지) · `MetricBar` · `BulletList` · `Pill` · `Section` · `StoryChapterTimeline`
→ **Watch/iPad 에서도 시각 언어 일관성 유지**. 비율만 조정.

### 2.4 다크 전용 고정
앱 전체가 `userInterfaceStyle: 'dark'`. Watch/iPad 디자인도 **다크 단일 테마**로만 설계해주세요.

---

## 3. 현재 앱 IA (참조용)

### 탭 구조
- **chat** — AI 캐릭터 채팅 (메인 진입점)
- **profile** — 사주·생년월일·MBTI·관심사·알림·구독

### 채팅 메시지 종류 (`ChatShellMessage`)
`text` · `embedded-result`(운세 결과 카드) · `fortune-cookie` · `saju-preview` · `image` · `story-reveal`(애니메이션 시퀀스) · `my-saju-context`

### 결과 화면 카테고리 (13개 스크린)
- 묶음형: `ondo-batch`, `batch-a` ~ `batch-e`
- 개별: 유명인 궁합 · 관상 · 작명 · 탄생석 · 길한 물건 · 반려동물 궁합 · 이사 운

### 사용자 데이터
`displayName`, `birthDate`, `birthTime`, `mbti`, `bloodType`, `interestIds[]`, 알림 선호, 프리미엄/토큰 상태

---

## 4. 스코프 A — Apple Watch

### 4.1 타깃 유즈케이스 (우선순위 순)

1. **Glance: 오늘의 한마디 운세** (fortune-cookie 1 문장)
2. **Complication: 워치페이스에 오늘의 운세 점수/컬러**
3. **Notification: 일일 인사이트 알림 수신 → 워치에서 요약 확인**
4. **Quick Reply: 캐릭터 메시지 답장 (미리 정의된 스탬프)**

> ✂ **범위 제외**: 사주 입력, 결제, 긴 채팅, 설문 입력은 Watch에서 제공하지 않음.

### 4.2 화면/서피스 리스트

| # | 서피스 | 설명 | 인터랙션 |
|---|--------|------|----------|
| W1 | **App — Today** | 오늘 날짜 · 종합 점수(ScoreDial 미니) · 한줄 운세 · 오행 색 악센트 | 탭 → W2 |
| W2 | **App — Detail** | 분야별 운(애정/재물/건강) 3개 바 + 오늘의 럭키 컬러/숫자 | 스크롤 / Digital Crown |
| W3 | **App — Character Ping** | "○○이가 메시지를 보냈어요" — 캐릭터 아바타 + 첫 줄 | Force Touch/탭 → Quick Reply |
| W4 | **Notification (long-look)** | 푸시 도착 시 자동 노출. 점수 + 한줄 운세 | Dismiss |
| C1 | **Complication — Corner** | 오행 컬러 + 점수 숫자 | |
| C2 | **Complication — Circular** | ScoreDial 미니 + "吉" / "中" / "凶" 한자 1글자 | |
| C3 | **Complication — Inline** | "오늘의 운 78 · 물의 기운" | |
| C4 | **Complication — Rectangular (modular)** | 한줄 운세 텍스트 + 점수 | |

### 4.3 제약
- **디바이스**: Apple Watch Series 7 이상 (41mm / 45mm / 49mm Ultra)
- **Safe Area**: corner radius 보정 필수 (Series 7+ 둥근 베젤)
- **텍스트**: 한글 기준 한 화면 **최대 2줄**, 글자수 엄격
- **색상**: OLED 번인 방지 — 큰 면적 단색은 지양, 배경은 순수 검정 권장
- **인풋**: 크라운 스크롤 / 큰 탭 영역 (44x44pt 이상)

### 4.4 데이터 동기화 가정
- iPhone 앱이 매일 아침 6-9시 사이 "오늘의 운세 스냅샷"을 WatchConnectivity / Shared App Group 으로 push
- 오프라인에서도 마지막 스냅샷 표시 가능

---

## 5. 스코프 B — iPad

### 5.1 포지셔닝
- iPad는 "**거실에서 AI 캐릭터와 여유롭게 운세를 보는 자리**"
- iPhone보다 **몰입형 비주얼** (전각 배경, 만세력·관상 풀샷)
- 현재 앱은 `requireFullScreen: true` + portrait 잠금 상태지만, iPad에서는 **landscape 허용 + Split View 기본 레이아웃**으로 확장

### 5.2 레이아웃 전략

**Regular Width (iPad 12.9" / 11" landscape)**:
```
┌────────────┬──────────────────────────────┐
│  Sidebar   │         Main Pane            │
│  (320pt)   │  (채팅 또는 결과 카드)         │
│            │                               │
│  - 오늘    │  ┌─ 채팅 스레드 ─┐            │
│  - 캐릭터  │  │                │  ← 풀폭    │
│  - 내 사주 │  │  [결과 카드]    │   결과     │
│  - 프로필  │  │                │   카드 시  │
│            │  └────────────────┘   2단 그리드│
│            │                               │
└────────────┴──────────────────────────────┘
```

**Compact Width (Split View 1/3)**: iPhone UI 그대로.

### 5.3 화면별 재구성

| 화면 | iPad 변경점 |
|------|------------|
| **Chat** | 좌: 캐릭터 리스트 사이드바 / 우: 스레드. 메시지 최대폭 680pt (읽기 편한 measure) |
| **결과 카드 (batch)** | 기존 세로 스크롤 → **2-column grid** (요약 좌 / 디테일 우) |
| **Saju Preview** | 네 기둥을 **전각 그리드**로 배치, 오행 원형 차트를 메인 히어로로 |
| **관상(face-reading)** | 얼굴 이미지 크게 + 주석(annotation) 콜아웃이 이미지 주변에 floating |
| **Fortune Cookie** | 화면 중앙 큰 카드 1장, 배경 파티클/별자리 |
| **Profile** | 좌: 섹션 리스트 / 우: 디테일 (Settings.app 스타일) |

### 5.4 인풋/상호작용
- **키보드 단축키**: `Cmd+K` 캐릭터 스위처, `Cmd+N` 새 세션, `Cmd+,` 설정
- **포인터 hover**: 결과 카드 hover 시 미세한 scale/glow
- **드래그**: 결과 카드를 채팅으로 드래그해서 "다시 물어보기" (나중 기능 — 시안만)
- **Apple Pencil**: 관상/손금 결과에 필기 메모 (백로그)

### 5.5 제약
- 최소 지원: iPad (10th gen) / iOS 17+
- 분할뷰 Compact 상태에서는 iPhone 레이아웃 자동 폴백
- **다크 전용 유지**

---

## 6. 공통 요구사항

### 접근성
- Dynamic Type: XS ~ XXL 대응 (Watch는 XS~L)
- 최소 콘트라스트 WCAG AA
- VoiceOver 레이블 고려한 그룹핑

### 로컬라이제이션
- 한국어 (주) / 영어 (보조)
- 한자 1자 표시는 폰트 임베드 필요 (吉/凶/中)

### 애니메이션
- 진입: 0.3~0.5s ease-out
- 결과 reveal은 progressive (0→1) — 기존 Hero 컴포넌트 규약 유지
- Watch: 애니메이션 **최소화** (배터리)

---

## 7. 기대 산출물 (Deliverables)

### 7.1 포맷
- **Figma** (최우선) 또는 **Pencil (.pen)** — 온도 팀은 Pencil을 공식 디자인 툴로 씁니다
- 스크린샷 PNG (1x/2x/3x) — 리뷰용

### 7.2 파일 구조 제안
```
design/
├─ 00-system/           # 토큰·타이포·아이콘 (기존 시스템 재확인)
├─ 10-watch/
│  ├─ app-today.*
│  ├─ app-detail.*
│  ├─ complications/     (corner · circular · inline · rectangular)
│  └─ notification-long-look.*
└─ 20-ipad/
   ├─ chat-landscape.*
   ├─ chat-split-2-3.*
   ├─ result-batch.*
   ├─ saju-preview.*
   ├─ face-reading.*
   └─ profile.*
```

### 7.3 해상도
| 대상 | 해상도 |
|------|--------|
| Watch 41mm | 352×430 @2x |
| Watch 45mm | 396×484 @2x |
| Watch Ultra 49mm | 410×502 @2x |
| iPad 11" | 1194×834 (landscape) |
| iPad 12.9" | 1366×1024 (landscape) |
| iPad Split 1/2 | 694×1024 |
| iPad Split 1/3 | 375×1024 (iPhone 폴백) |

### 7.4 컴포넌트
- 기존 프리미티브의 **Watch/iPad 변형**을 별도 컴포넌트로 공급
  - `ScoreDial / watch` · `ScoreDial / ipad`
  - `ResultCardFrame / ipad-2col`
  - 등

---

## 8. 레퍼런스 / 무드

- **무드**: Apple Weather (다크) / Calm / Oura Ring 앱 / 하이쿠 북앱
- **기피**: 토스 밝은 플랫 / 게임형 카지노 UI / 과도한 글래스모피즘

(필요 시 별도 레퍼런스 보드 첨부 — 디자이너 쪽에서 mood board 3안 제안 환영)

---

## 9. 미정/디자이너 의견 요청

- [ ] Watch Standalone 앱을 정말 넣을지, **Notification + Complication만** 할지
- [ ] iPad에서 채팅의 **사이드바 vs 탭바** 최종 결정
- [ ] 관상/타로 같은 시각형 결과는 iPad에서 **몰입 모드(전체화면)** 를 따로 둘지
- [ ] 결과 카드 grid 전환 시 애니메이션 스타일
- [ ] 라이트 모드를 이번에도 생략할지 (현재 유지 권장)

---

## 10. 참고 파일 (저장소 내)

```
packages/design-tokens/src/index.ts      # 컬러/타이포 토큰
apps/mobile-rn/src/lib/theme.ts          # fortuneTheme
apps/mobile-rn/app/(tabs)/_layout.tsx    # 탭 구조
apps/mobile-rn/src/lib/chat-shell.ts     # 채팅 메시지 타입
apps/mobile-rn/src/features/fortune-results/primitives/   # 결과 카드 프리미티브
apps/mobile-rn/src/features/fortune-results/heroes/       # Hero 컴포넌트 38종
apps/mobile-rn/app.config.ts             # iPad 설정 (현재 portrait 잠금)
docs/design-request-for-nanobanana.md    # 이전 리디자인 브리프 (톤 참고)
```

---

**작성 종료.** 이 브리프를 claude.ai/design 세션에 그대로 붙여넣고, 섹션 4(Watch) / 섹션 5(iPad) 중 하나씩 착수 요청하면 됩니다.
