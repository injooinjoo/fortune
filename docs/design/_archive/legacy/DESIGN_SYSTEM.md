# Fortune App Design System v2.0 - 한국 전통 미학

> **Version**: 2.0.0
> **Last Updated**: December 2025
> **Design Language**: Korean Traditional Aesthetics (한국 전통 미학)

---

## 목차

1. [디자인 철학](#디자인-철학)
2. [색상 시스템](#색상-시스템)
3. [타이포그래피](#타이포그래피)
4. [핵심 컴포넌트](#핵심-컴포넌트)
5. [화면별 가이드](#화면별-가이드)
6. [민화 에셋 가이드](#민화-에셋-가이드)
7. [다크모드 가이드](#다크모드-가이드)
8. [애니메이션 가이드](#애니메이션-가이드)
9. [보조 참조: Toss Design System](#보조-참조-toss-design-system)

---

## 디자인 철학

### 핵심 정체성: 한국 전통 미학의 현대적 재해석

Fortune 앱은 한국 전통 미학의 정수를 현대 디지털 환경에 재해석합니다. 단순한 복고풍이 아닌, 전통의 깊이와 현대의 편의성을 조화롭게 융합합니다.

> *"당신의 사주에 스민 하늘의 뜻을 읽다"*

### 4대 디자인 원칙

#### 1. 질감 (Texture) - 한지와 먹

디지털 화면에 아날로그의 따뜻함을 불어넣습니다.

| 요소 | 설명 | 구현 |
|------|------|------|
| **한지 배경** | 순백색의 차가운 디지털 화면 대신, 은은한 한지(닥종이) 질감 사용 | `HanjiBackground`, `HanjiCard` |
| **발묵 효과** | 먹이 종이에 스며들며 번지는 듯한 효과 | `_HanjiCardPainter` ink bleed |
| **붓터치 가장자리** | UI 요소의 가장자리에 거친 붓터치 느낌 | Corner decorations |

**질감 표현 예시:**
```dart
// 한지 배경
HanjiCard(
  style: HanjiCardStyle.standard,
  child: Content(),
)

// 한지 전체 배경
HanjiBackground(
  child: Scaffold(...),
)
```

---

#### 2. 색상 (Color) - 오방색과 쪽빛

전통 오방색을 톤다운하여 현대적으로 재해석합니다.

**기조 색상:**
- **먹색 (Meok)**: 검정~회색 그라데이션 - 텍스트, 강조
- **미색 (Misaek)**: 아이보리/베이지 - 배경, 카드

**오방색 (톤다운):**

| 오행 | 이름 | 색상 | Hex | 의미 |
|------|------|------|-----|------|
| 목(木) | 청 (Cheong) | 깊은 쪽빛 | `#1E3A5F` | 동, 봄, 성장 |
| 화(火) | 적 (Jeok) | 톤다운 다홍 | `#B91C1C` | 남, 여름, 열정 |
| 토(土) | 황 (Hwang) | 황토색/겨자색 | `#B8860B` | 중앙, 환절기, 풍요 |
| 금(金) | 백 (Baek) | 은은한 소색 | `#F5F5DC` | 서, 가을, 순수 |
| 수(水) | 흑 (Heuk) | 깊은 현무색 | `#1C1C1C` | 북, 겨울, 지혜 |

**강조 색상:**
- **인주 (Inju)**: `#DC2626` - 붉은 도장 색상, 중요 버튼 및 CTA에 사용

---

#### 3. 타이포그래피 (Typography) - 서예와 명조

전통 서예의 품격과 현대 가독성의 균형을 추구합니다.

| 용도 | 폰트 | 스타일 | 설명 |
|------|------|--------|------|
| **제목** | GowunBatang | Bold/SemiBold | 흘림체와 정자체의 중간, 서예 느낌 |
| **본문** | ZenSerif / Pretendard | Regular | 가독성 높은 현대적 명조/고딕 |
| **한자/낙관** | GowunBatang | Bold | 전통 요소 표현 |
| **숫자** | TossFace / ZenSerif | Tabular | 숫자 정렬 |

**서예적 표현 팁:**
- 제목에 약간의 기울임 적용 가능 (`rotation: -2deg`)
- 자간 조정으로 붓글씨 느낌 (`letterSpacing: -0.02em`)

---

#### 4. 공간 (Space) - 여백의 미

수묵화의 여백 원칙을 UI에 적용합니다. 비움으로 채우는 미학.

**원칙:**
- 요소 간 충분한 여백 확보
- 정보 밀도보다 호흡 우선
- 중요한 요소에 시선 집중

**간격 체계:**
```dart
// 기본 간격 (8px 그리드)
DSSpacing.xs   // 4px
DSSpacing.sm   // 8px
DSSpacing.md   // 16px
DSSpacing.lg   // 24px
DSSpacing.xl   // 32px
DSSpacing.xxl  // 48px
```

---

## 색상 시스템

### 오방색 팔레트 (ObangseokColors)

**파일**: `lib/core/theme/obangseok_colors.dart`

#### 기본 색상

```dart
// 목(木) - 청색 계열
ObangseokColors.cheong      // #1E3A5F - 기본
ObangseokColors.cheongLight // #2D5A87 - 밝은
ObangseokColors.cheongDark  // #0F1F33 - 어두운
ObangseokColors.cheongMuted // #3D5A73 - 톤다운

// 화(火) - 적색 계열
ObangseokColors.jeok        // #B91C1C - 기본
ObangseokColors.jeokLight   // #DC2626 - 밝은
ObangseokColors.jeokDark    // #7F1D1D - 어두운
ObangseokColors.jeokMuted   // #9B4D4D - 톤다운

// 토(土) - 황색 계열
ObangseokColors.hwang       // #B8860B - 기본
ObangseokColors.hwangLight  // #D4A017 - 밝은
ObangseokColors.hwangDark   // #8B6914 - 어두운
ObangseokColors.hwangMuted  // #A39171 - 톤다운

// 금(金) - 백색 계열
ObangseokColors.baek        // #F5F5DC - 기본
ObangseokColors.baekLight   // #FFFFF0 - 밝은
ObangseokColors.baekDark    // #E8E4C9 - 어두운
ObangseokColors.baekMuted   // #D4D0BB - 톤다운

// 수(水) - 흑색 계열
ObangseokColors.heuk        // #1C1C1C - 기본
ObangseokColors.heukLight   // #2D2D2D - 밝은
ObangseokColors.heukDark    // #0A0A0A - 어두운
ObangseokColors.heukMuted   // #404040 - 톤다운
```

#### 특수 색상

```dart
// 인주 (붉은 도장)
ObangseokColors.inju        // #DC2626 - 기본
ObangseokColors.injuDark    // #B91C1C
ObangseokColors.injuLight   // #EF4444

// 먹색 (잉크)
ObangseokColors.meok        // #1A1A1A - 기본
ObangseokColors.meokLight   // #333333
ObangseokColors.meokDark    // #0D0D0D
ObangseokColors.meokFaded   // #666666 - 옅은 먹

// 미색 (한지 배경)
ObangseokColors.misaek      // #F7F3E9 - 기본
ObangseokColors.misaekLight // #FAF8F2
ObangseokColors.misaekDark  // #EDE8DA
ObangseokColors.misaekWarm  // #F5F0E1 - 따뜻한

// 한지 배경
ObangseokColors.hanjiBackground     // #FAF8F5 - 라이트
ObangseokColors.hanjiBackgroundDark // #1E1E1E - 다크
```

#### 도메인별 색상 매핑

```dart
// 운세 카테고리별 자동 색상 매핑
ObangseokColors.getDomainColor('love')      // 연애 - jeokMuted (적)
ObangseokColors.getDomainColor('career')    // 직업 - cheongMuted (청)
ObangseokColors.getDomainColor('money')     // 재물 - hwang (황)
ObangseokColors.getDomainColor('health')    // 건강 - baekDark (백)
ObangseokColors.getDomainColor('spiritual') // 운명 - heukMuted (흑)

// 오행별 색상
ObangseokColors.getElementColor('목')  // cheong
ObangseokColors.getElementColor('화')  // jeok
ObangseokColors.getElementColor('토')  // hwang
ObangseokColors.getElementColor('금')  // baek
ObangseokColors.getElementColor('수')  // heuk
```

#### 그라데이션

```dart
// 수묵 그라데이션 (다크 배경)
ObangseokColors.inkWashGradient

// 한지 그라데이션 (라이트 배경)
ObangseokColors.hanjiGradient

// 오방색 원형 배열
ObangseokColors.fiveElementsColors // [cheong, jeok, hwang, baek, heuk]
```

---

## 타이포그래피

### 폰트 계층

| 카테고리 | 스타일 | 크기 | 폰트 | 용도 |
|----------|--------|------|------|------|
| **Display** | displayLarge | 48pt | GowunBatang | 스플래시, 온보딩 |
| | displayMedium | 40pt | GowunBatang | 큰 헤드라인 |
| | displaySmall | 32pt | GowunBatang | 중간 헤드라인 |
| **Heading** | heading1 | 28pt | GowunBatang | 메인 페이지 제목 |
| | heading2 | 24pt | GowunBatang | 섹션 제목 |
| | heading3 | 20pt | Pretendard | 서브 섹션 제목 |
| | heading4 | 18pt | Pretendard | 작은 섹션 제목 |
| **Body** | bodyLarge | 17pt | Pretendard | 큰 본문 |
| | bodyMedium | 15pt | Pretendard | 기본 본문 |
| | bodySmall | 14pt | Pretendard | 작은 본문 |
| **Label** | labelMedium | 12pt | Pretendard | 라벨, 캡션 |
| **한자/낙관** | hanja | Variable | GowunBatang | 전통 요소 |

### 사용 예시

```dart
// 전통 제목 (GowunBatang)
Text(
  '오늘의 운세',
  style: TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
)

// 현대 본문 (context extension 사용)
Text('운세 내용...', style: context.bodyMedium)

// 한자 요소
Text(
  '運',
  style: TextStyle(
    fontFamily: 'GowunBatang',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: ObangseokColors.inju,
  ),
)
```

---

## 핵심 컴포넌트

### HanjiCard - 한지 카드

**파일**: `lib/core/design_system/components/traditional/hanji_card.dart`

한지 질감의 카드 컴포넌트. 모든 운세 결과 표시에 사용.

#### 스타일 변형 (HanjiCardStyle)

| 스타일 | 설명 | 용도 |
|--------|------|------|
| `standard` | 기본 한지 카드 | 일반 콘텐츠 |
| `scroll` | 두루마리 스타일, 둥근 모서리 | 사주 명식, 긴 콘텐츠 |
| `hanging` | 족자 스타일, 직선 모서리 | 총평, 조언 |
| `elevated` | 먹 그림자 효과 | 강조 카드 |
| `minimal` | 최소 테두리 | 서브 콘텐츠 |

#### 색상 스킴 (HanjiColorScheme)

| 스킴 | 색상 | 용도 |
|------|------|------|
| `fortune` | 자주색 + 금색 | 일반 운세 |
| `love` | 연지색 + 분홍 | 연애운, 궁합 |
| `luck` | 황금색 + 적색 | 재물운, 행운 |
| `biorhythm` | 오방색 | 바이오리듬 |
| `health` | 청록색 | 건강운 |

#### 사용 예시

```dart
// 기본 사용
HanjiCard(
  child: FortuneContent(),
)

// 두루마리 스타일 + 낙관
HanjiCard(
  style: HanjiCardStyle.scroll,
  colorScheme: HanjiColorScheme.fortune,
  showSealStamp: true,
  sealText: '運',
  child: SajuResult(),
)

// 족자 스타일 (총평)
HanjiCard(
  style: HanjiCardStyle.hanging,
  showCornerDecorations: true,
  child: FortuneAdvice(),
)
```

### SealStamp - 낙관 (도장)

전통 인장 스타일의 도장 위젯.

```dart
SealStamp(
  text: '福',
  color: ObangseokColors.inju,
  size: 32,
)
```

### HanjiSectionCard - 섹션 카드

제목과 한자 아이콘이 포함된 섹션 카드.

```dart
HanjiSectionCard(
  title: '오늘의 조언',
  subtitle: 'Today\'s Advice',
  hanja: '言',
  colorScheme: HanjiColorScheme.fortune,
  child: AdviceContent(),
)
```

---

## 화면별 가이드

### 1. 스플래시 및 로그인 화면 - "운명의 문을 열다"

**디자인 컨셉:**
- 수묵 산수화가 안개 속에 희미하게 펼쳐짐
- 일월오봉도 모티브 (해와 달이 산봉우리 사이로)
- 먹물이 퍼지는 애니메이션

**핵심 요소:**

| 요소 | 구현 |
|------|------|
| 배경 | 수묵 산수화 + 안개 효과 |
| 로고 | 붉은색 낙관(도장) 형태, 우측 상단 |
| 애니메이션 | 먹물 한 방울이 떨어져 화면 전체로 퍼짐 |
| 카피 | "당신의 사주에 스민 하늘의 뜻을 읽다" |
| 버튼 | 붓으로 그린 듯한 테두리의 로그인 버튼 |

```dart
// 스플래시 배경
Stack(
  children: [
    // 수묵화 배경
    Image.asset('assets/images/splash_sumukwa.png'),
    // 안개 오버레이
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            ObangseokColors.misaek.withOpacity(0.3),
          ],
        ),
      ),
    ),
    // 낙관 로고
    Positioned(
      top: 60,
      right: 24,
      child: SealStamp(text: '運', size: 48),
    ),
  ],
)
```

---

### 2. 메인 홈 화면 - "오늘의 화폭 (My Daily Canvas)"

**디자인 컨셉:**
- 한 폭의 그림처럼 오늘의 운세 표시
- 여백을 많이 두어 시원한 느낌
- 민화풍 운세 카드

**핵심 요소:**

| 요소 | 구현 |
|------|------|
| 날짜 표시 | 음력/절기와 함께 붓글씨 스타일 |
| 운세 카드 | 민화풍 그림이 그려진 HanjiCard |
| 네비게이션 | 붓터치로 그려진 심볼 아이콘 |
| 여백 | 상하좌우 충분한 여백 |

**민화 카드 매핑:**

| 운세 | 민화 | 의미 |
|------|------|------|
| 재물운 좋음 | 모란꽃 + 나비 | 부귀영화 |
| 애정운 좋음 | 원앙 한 쌍 | 부부화합 |
| 건강운 좋음 | 학 + 거북 | 장수 |
| 직장운 좋음 | 잉어 | 입신출세 |

**네비게이션 아이콘 (붓터치 스타일):**
- 홈: 기와집 형상
- 만세력: 달과 별
- 상담: 붓과 벼루
- 더보기: 매듭 장식

---

### 3. 사주 분석 결과 화면 - "사주팔자도 (The Map of Destiny)"

**디자인 컨셉:**
- 복잡한 사주 정보를 예술 작품처럼 시각화
- 두루마리(족자) 형태의 명식 표시
- 오행을 자연물로 표현

**핵심 요소:**

#### 명식 표시 (만세력)
- 네 개의 두루마리(족자)로 연주, 월주, 일주, 시주 표현
- 각 기둥 안에 천간/지지 붓글씨
- 해당 오행 배경색 은은하게 적용

```dart
// 사주 명식 카드
Row(
  children: [
    // 연주
    HanjiCard(
      style: HanjiCardStyle.scroll,
      customBackgroundColor: ObangseokColors.getElementColor('목').withOpacity(0.1),
      child: PillarContent(pillar: yearPillar),
    ),
    // 월주, 일주, 시주...
  ],
)
```

#### 오행 분석 그래프
- 막대그래프 대신 자연물로 표현
- 목(木) 많음 → 울창한 소나무 숲 크게
- 수(水) 부족 → 메마른 계곡 작게

#### 총평 (서신 형태)
- 옛 선비의 서신(편지) 스타일
- 한지 배경 + 세로쓰기 느낌
- 중요 키워드 붉은색 붓터치 강조

```dart
// 총평 카드
HanjiCard(
  style: HanjiCardStyle.hanging,
  showCornerDecorations: true,
  child: Column(
    children: [
      Text(
        '총평',
        style: TextStyle(
          fontFamily: 'GowunBatang',
          fontSize: 20,
        ),
      ),
      // 세로쓰기 느낌의 본문
      Text(
        fortuneSummary,
        style: context.bodyMedium.copyWith(
          height: 1.8, // 넓은 줄간격
        ),
      ),
    ],
  ),
)
```

---

## 민화 에셋 가이드

**경로**: `assets/images/minhwa/`

### 카테고리별 에셋

#### 전체운 (Overall)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_overall_dragon.png` | 용 | 권위, 성공, 출세 |
| `minhwa_overall_tiger.png` | 호랑이 | 보호, 액막이 |
| `minhwa_overall_phoenix.png` | 봉황 | 행복, 번영 |
| `minhwa_overall_turtle.png` | 거북 | 장수, 지혜 |
| `minhwa_overall_sunrise.png` | 일출 | 새로운 시작 |
| `minhwa_overall_moon.png` | 달 | 음의 기운, 평화 |

#### 연애운 (Love)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_love_mandarin.png` | 원앙 | 부부화합, 사랑 |
| `minhwa_love_butterfly.png` | 나비 | 사랑의 기쁨 |
| `minhwa_love_peony.png` | 모란 | 부귀영화, 아름다움 |
| `minhwa_love_magpie_bridge.png` | 까치다리 | 만남, 인연 |

#### 재물운 (Money)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_money_carp.png` | 잉어 | 입신출세, 성공 |
| `minhwa_money_toad.png` | 두꺼비 | 재물, 복 |
| `minhwa_money_pig.png` | 돼지 | 풍요, 재물 |
| `minhwa_money_treasure.png` | 보물 | 부귀 |

#### 직장/사업운 (Work)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_work_eagle.png` | 독수리 | 권위, 성취 |
| `minhwa_work_crane.png` | 학 | 품격, 승진 |
| `minhwa_work_bamboo.png` | 대나무 | 절개, 성장 |
| `minhwa_work_waterfall.png` | 폭포 | 돌파, 발전 |

#### 학업운 (Study)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_study_owl.png` | 부엉이 | 지혜 |
| `minhwa_study_magpie.png` | 까치 | 좋은 소식 |
| `minhwa_study_brush.png` | 문방사우 | 학문 |
| `minhwa_study_plum.png` | 매화 | 인내, 합격 |

#### 건강운 (Health)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_health_crane_turtle.png` | 학과 거북 | 장수 |
| `minhwa_health_deer.png` | 사슴 | 건강, 활력 |
| `minhwa_health_pine.png` | 소나무 | 불로장생 |
| `minhwa_health_mountain.png` | 산 | 안정, 건강 |

#### 사주/명리 (Saju)
| 파일명 | 상징 | 의미 |
|--------|------|------|
| `minhwa_saju_yin_yang.png` | 음양 | 균형 |
| `minhwa_saju_dragon.png` | 청룡 | 동쪽 수호 |
| `minhwa_saju_tiger_dragon.png` | 용호 | 상생 |
| `minhwa_saju_fourguardians.png` | 사신도 | 사방 수호 |

### 사용 예시

```dart
// 민화 배경 카드
Stack(
  children: [
    Opacity(
      opacity: 0.15,
      child: Image.asset('assets/images/minhwa/minhwa_love_mandarin.png'),
    ),
    HanjiCard(
      colorScheme: HanjiColorScheme.love,
      child: LoveFortuneContent(),
    ),
  ],
)
```

---

## 다크모드 가이드

### 색상 전환 규칙

| 요소 | 라이트 모드 | 다크 모드 |
|------|-------------|-----------|
| 배경 | `misaek` (#F7F3E9) | `heukLight` (#2D2D2D) |
| 한지 배경 | `hanjiBackground` (#FAF8F5) | `hanjiBackgroundDark` (#1E1E1E) |
| 텍스트 | `meok` (#1A1A1A) | `baekDark` (#E8E4C9) |
| 강조 | `inju` (#DC2626) | `injuLight` (#EF4444) |
| 테두리 | `meok` 15% | `baek` 15% |

### 테마 헬퍼

```dart
// 다크모드 인식 색상
ObangseokColors.getHanjiBackground(context)
ObangseokColors.getMisaek(context)
ObangseokColors.getMeok(context)
ObangseokColors.getInju(context)

// 일반 조건문
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark
    ? ObangseokColors.hanjiBackgroundDark
    : ObangseokColors.hanjiBackground;
```

---

## 애니메이션 가이드

### 전통 미학 애니메이션 원칙

| 원칙 | 설명 | 구현 |
|------|------|------|
| **수묵화 붓터치** | 부드러운 이징, 먹물이 스미듯 | `Curves.easeOutCubic` |
| **먹물 퍼짐** | 중앙에서 외곽으로 확산 | Radial reveal animation |
| **발묵 효과** | 농담의 변화, 번짐 | Opacity + blur transition |
| **여백의 호흡** | 느린 템포, 정적 | 500-800ms duration |

### 주요 애니메이션

#### 카드 진입
```dart
// 먹물이 스미듯 페이드 인
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 600),
  curve: Curves.easeOutCubic,
  child: HanjiCard(...),
)
```

#### 페이지 전환
```dart
// 두루마리가 펼쳐지듯
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(0, 0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: FadeTransition(
    opacity: animation,
    child: page,
  ),
)
```

#### 로딩 애니메이션
```dart
// 먹물 물방울 + 파문 효과
CustomPaint(
  painter: InkDropPainter(
    progress: animationController.value,
    color: ObangseokColors.meok,
  ),
)
```

---

## 보조 참조: Toss Design System

> **Note**: 이 섹션은 보조 참조입니다. Fortune 앱의 기본 디자인 언어는 **한국 전통 미학**입니다.
> Toss Design System은 현대적 UI 패턴과 상호작용 가이드라인에만 참조합니다.

### 참조 대상

| 항목 | Toss 참조 | 전통 미학 적용 |
|------|-----------|----------------|
| 버튼 상호작용 | Press animation, haptic | 붓터치 테두리 스타일 적용 |
| 토스트/스낵바 | 위치, 애니메이션 | 한지 배경 + 먹 텍스트 |
| 바텀시트 | 드래그 동작, 핸들 | 두루마리 펼침 효과 적용 |
| 입력 필드 | 포커스 상태, 에러 | 붓터치 테두리 적용 |

### 상세 문서

- [TOSS_DESIGN_SYSTEM.md](./TOSS_DESIGN_SYSTEM.md) - 전체 Toss 디자인 시스템 참조

---

## 관련 문서

- [KOREAN_TALISMAN_DESIGN_GUIDE.md](./KOREAN_TALISMAN_DESIGN_GUIDE.md) - 부적 및 민화 상세 가이드
- [UI_UX_MASTER_POLICY.md](./UI_UX_MASTER_POLICY.md) - UX 정책
- [UNIFIED_FONT_SYSTEM.md](./UNIFIED_FONT_SYSTEM.md) - 폰트 시스템

---

**Last Updated**: December 2025
**Version**: 2.0.0
**Design Language**: Korean Traditional Aesthetics
