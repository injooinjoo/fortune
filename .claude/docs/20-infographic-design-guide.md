# 인포그래픽 결과 페이지 구현 가이드

> 모든 운세 결과 페이지를 인포그래픽 스타일로 리디자인하기 위한 기술 가이드
> 21-figma-design-prompts.md와 함께 사용

---

## 핵심 원칙

### 1. 한눈에 보이는 비주얼 (Glanceable)
- **모든 정보를 스크롤 없이** 첫 화면에 시각화
- 점수, 키워드, 아이콘으로 즉시 파악 가능
- 텍스트 최소화, 이미지/일러스트 극대화

### 2. 탭하면 상세 (Tap-to-Expand)
- 각 섹션을 탭하면 BottomSheet로 상세 설명
- **기본 화면 = 인포그래픽 요약**
- **탭 후 = 텍스트 상세 설명**

### 3. 완전히 다른 테마
- **공통 레이아웃 없음** - 각 운세별 고유 디자인
- 21개 문서의 Figma 프롬프트 참조
- 운세 성격에 맞는 비주얼 언어 사용

---

## 인터랙션 패턴

### Pattern A: 탭 → BottomSheet
```dart
// 가장 기본적인 상세보기 패턴
GestureDetector(
  onTap: () => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => FortuneDetailSheet(
      title: '연애운 상세',
      content: result.love.detail,
    ),
  ),
  child: LoveScoreCard(score: result.love.score),
)
```

### Pattern B: 카드 PageView (스와이프)
```dart
// 여러 일러스트를 스와이프로 탐색
PageView.builder(
  itemCount: result.illustrations.length,
  itemBuilder: (_, index) => IllustrationCard(
    image: result.illustrations[index],
    onTap: () => showDetail(index),
  ),
)
```

### Pattern C: 확장 카드
```dart
// 카드 자체가 확장되는 애니메이션
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  height: isExpanded ? 300 : 100,
  child: isExpanded
    ? DetailContent(data: item)
    : SummaryContent(data: item),
)
```

### Pattern D: 오버레이 상세
```dart
// 이미지 위에 상세 정보 오버레이
Stack(
  children: [
    IllustrationImage(path: imagePath),
    if (showOverlay)
      DetailOverlay(
        opacity: overlayOpacity,
        content: detailText,
      ),
  ],
)
```

---

## 운세별 정보 구조 & 시각화 전략

### 1. 일일 운세 (fortune-daily)

**데이터 구조:**
```typescript
{
  overall_score: number,        // 종합 점수 (1-100)
  summary: string,              // 한줄 요약
  categories: {
    love: { score, advice },
    money: { score, advice },
    work: { score, advice },
    study: { score, advice },
    health: { score, advice },
  },
  lucky_items: {
    time, color, number, direction, food, item
  },
  daily_predictions: { morning, afternoon, evening },
}
```

**시각화 전략:**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| overall_score | 중앙 대형 원형 + 마스코트 | 점수 해석 |
| categories | 5개 아이콘 + 미니 프로그레스바 | 각 카테고리 조언 |
| lucky_items | 6개 일러스트 원형 그리드 | 행운 아이템 설명 |
| daily_predictions | 3단 타임라인 아이콘 | 시간대별 상세 |

**레이아웃 (모던 그라데이션):**
```
┌─────────────────────────────┐
│  ← 오늘의 운세              │  Header
├─────────────────────────────┤
│                             │
│     ┌───────────────┐       │
│     │      84       │       │  Hero Score
│     │  🐕 마스코트   │       │  + 마스코트
│     └───────────────┘       │
│                             │
│  #키워드1 #키워드2 #키워드3   │  해시태그 칩
├─────────────────────────────┤
│  💕  💰  💼  📚  💪        │
│  72  65  88  79  91        │  5개 카테고리
│ ■■■ ■■□ ■■■ ■■■ ■■■■      │  미니 바
├─────────────────────────────┤
│ ┌───┐ ┌───┐ ┌───┐         │
│ │시간│ │색상│ │숫자│         │  행운 아이템
│ └───┘ └───┘ └───┘         │  일러스트 그리드
│ ┌───┐ ┌───┐ ┌───┐         │
│ │방향│ │음식│ │물건│         │
│ └───┘ └───┘ └───┘         │
├─────────────────────────────┤
│  🌅 아침 │ ☀️ 오후 │ 🌙 저녁  │  시간대 타임라인
│   좋음  │  주의   │  최고   │
└─────────────────────────────┘
```

---

### 2. 연애운 (fortune-love)

**데이터 구조:**
```typescript
{
  score: number,
  loveProfile: {
    attractionType: string,
    romanticStyle: string,
    keywords: string[],
  },
  detailedAnalysis: {
    currentState: string,
    opportunities: string[],
    challenges: string[],
  },
  recommendations: {
    dateSpots: string[],
    fashion: {
      top: string,
      bottom: string,
      accessories: string[],
    },
  },
}
```

**시각화 전략 (봄 벚꽃 테마):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| score | 하트 게이지 + 수채화 배경 | 연애운 해석 |
| loveProfile | 일러스트 커플 + 키워드 배지 | 프로필 상세 |
| fashion | 족자 스타일 패션 아이템 | 코디 조언 |
| dateSpots | 미니 일러스트 카드 | 장소 설명 |

**레이아웃:**
```
┌─────────────────────────────┐
│ 🌸 연애운 패션 스타일링 🌸   │  벚꽃 배너
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │   💕 커플 일러스트     │    │  메인 PageView
│  │   (수채화 스타일)      │    │  스와이프 가능
│  │     ● ○ ○ ○          │    │
│  └─────────────────────┘    │
├─────────────────────────────┤
│  ┌─┐ ┌─┐ ┌─┐              │
│  │奔│ │適│ │肴│              │  한자 키워드
│  └─┘ └─┘ └─┘              │  금박 원형
├─────────────────────────────┤
│  "코디 아이템"              │
│  ┌───────┐ ┌───────┐       │
│  │ 상의  │ │ 하의  │       │  족자 프레임
│  │🧥     │ │👖     │       │  패션 아이템
│  └───────┘ └───────┘       │
│  ┌───────┐                 │
│  │ 아우터│                 │
│  │🧥     │                 │
│  └───────┘                 │
└─────────────────────────────┘
```

---

### 3. 타로 (fortune-tarot)

**데이터 구조:**
```typescript
{
  spreadType: 'single' | 'threeCard' | 'relationship' | 'celticCross',
  cards: [
    {
      position: string,
      card: { name, nameKr, keywords, element },
      isReversed: boolean,
      interpretation: string,
    }
  ],
  overallReading: string,
  advice: string,
  luckyMessage: string,
}
```

**시각화 전략 (신비로운 밤):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| cards | 선택된 카드 이미지 배열 | 카드별 상세 해석 |
| position | 카드 아래 위치 라벨 | 위치 의미 설명 |
| interpretation | 숨김 (탭 시만) | 카드 해석 BottomSheet |
| overallReading | 하단 요약 텍스트 | 전체 리딩 상세 |

**레이아웃 (3카드 기준):**
```
┌─────────────────────────────┐
│  ✨ 타로 카드 리딩 ✨         │  별빛 헤더
├─────────────────────────────┤
│        ⭐ 🌙 ⭐              │
│                             │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │     │ │     │ │     │   │
│  │ 🃏  │ │ 🃏  │ │ 🃏  │   │  타로 카드
│  │     │ │     │ │     │   │  이미지
│  │     │ │     │ │     │   │
│  └─────┘ └─────┘ └─────┘   │
│   과거    현재    미래       │  위치 라벨
│                             │
├─────────────────────────────┤
│  "종합 메시지"              │
│  ┌─────────────────────┐    │
│  │ 🔮 핵심 키워드 표시    │    │  요약 카드
│  │    (탭하여 상세)      │    │
│  └─────────────────────┘    │
├─────────────────────────────┤
│  💜 오늘의 행운 메시지 💜    │  행운 배너
└─────────────────────────────┘
```

---

### 4. 관상 (fortune-face-reading)

**데이터 구조:**
```typescript
{
  overview: {
    faceType: string,
    faceTypeElement: string,
    firstImpression: string,
    overallBlessingScore: number,
  },
  ogwan: {  // 오관 (5개 부위)
    ear, eyebrow, eye, nose, mouth: {
      observation, interpretation, score, advice
    }
  },
  samjeong: {  // 삼정 (상중하)
    upper, middle, lower: { period, description, peakAge, score }
  },
  fortunes: {
    wealth, love, career, health, overall: FortuneDetail
  },
  faceTypeClassification: {
    animalType: { primary, secondary, matchScore, description, traits }
  },
}
```

**시각화 전략 (동양 고전):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| faceType | 중앙 얼굴형 아이콘 | 얼굴형 상세 |
| animalType | 동물상 일러스트 + 매칭 % | 동물상 특징 |
| ogwan | 5개 부위 아이콘 + 점수 | 부위별 관상 해석 |
| samjeong | 삼단 바 (상중하) | 시기별 운세 |
| fortunes | 5개 운 카테고리 | 각 운 상세 |

**레이아웃:**
```
┌─────────────────────────────┐
│  🏯 관상 분석 결과 🏯        │  전통 프레임
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │                     │    │
│  │   🐰 토끼상 92%     │    │  동물상
│  │   (업로드 사진 위)   │    │  오버레이
│  │                     │    │
│  └─────────────────────┘    │
├─────────────────────────────┤
│  "오관 분석"                │
│  👂 귀   눈썹  👁️ 눈  👃 코  👄 입 │  5개 부위
│  88   85   92   78   86    │  점수
├─────────────────────────────┤
│  "삼정 분석"                │
│  ┌───────────────────┐     │
│  │████████░░░░│ 상정 88  │     │  상중하
│  │██████░░░░░░│ 중정 72  │     │  프로그레스
│  │████████████│ 하정 95  │     │
│  └───────────────────┘     │
├─────────────────────────────┤
│  💰재물  💕연애  💼직업      │
│  85    78    92           │  운세 카테고리
└─────────────────────────────┘
```

---

### 5. 궁합 (fortune-compatibility)

**데이터 구조:**
```typescript
{
  overall_score: number,
  compatibility_grade: 'A' | 'B' | 'C' | 'D' | 'F',
  categories: {
    love, communication, values, lifestyle, future: { score, analysis }
  },
  strengths: string[],
  challenges: string[],
  advice: string[],
  specialCompatibility: {
    zodiacAnimal: { compatibility, description },
    zodiacSign: { compatibility, description },
  }
}
```

**시각화 전략 (전통 혼례):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| overall_score | 원앙 일러스트 + 점수 | 궁합 총평 |
| compatibility_grade | 한자 도장 스타일 등급 | 등급 설명 |
| categories | 5개 하트/별 아이콘 | 카테고리별 분석 |
| strengths/challenges | 음양 아이콘 리스트 | 상세 설명 |

**레이아웃:**
```
┌─────────────────────────────┐
│  🎎 천생연분 궁합 🎎         │  전통 배너
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │   🦢   88점   🦢    │    │  원앙
│  │   A+ 천생연분       │    │  일러스트
│  │   (한자 도장 스타일) │    │
│  └─────────────────────┘    │
├─────────────────────────────┤
│ "궁합 분석"                 │
│ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │💕   │ │💬   │ │🎯   │   │  카테고리
│ │연애 │ │소통 │ │가치 │   │  원형 카드
│ │ 92  │ │ 85  │ │ 78  │   │
│ └─────┘ └─────┘ └─────┘   │
│ ┌─────┐ ┌─────┐           │
│ │🏠   │ │🔮   │           │
│ │생활 │ │미래 │           │
│ │ 88  │ │ 95  │           │
│ └─────┘ └─────┘           │
├─────────────────────────────┤
│  ☯️ 장점: ●●●              │  장점/주의점
│  ⚠️ 주의: ●●               │  도트 표시
└─────────────────────────────┘
```

---

### 6. 신년 운세 (fortune-new-year)

**데이터 구조:**
```typescript
{
  overall_score: number,
  yearly_theme: string,
  monthly_fortunes: Array<{ month, score, highlight }>,
  lucky_items: { color, number, direction },
  peak_months: number[],
  caution_months: number[],
  yearly_advice: string[],
}
```

**시각화 전략 (봉황 + 황금):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| overall_score | 봉황 배경 + 대형 점수 | 연간 총평 |
| lucky_items | 민화 스타일 원형 | 행운 요소 설명 |
| monthly_fortunes | 12개 월별 컬러 타일 | 월별 상세 |
| peak/caution | 강조 표시 월 | 해당 월 조언 |

---

### 7. MBTI 운세 (fortune-mbti)

**데이터 구조:**
```typescript
{
  mbtiType: string,
  dailyFortune: { score, message },
  dimensionFortunes: {
    EI, SN, TF, JP: { score, analysis }
  },
  compatibleTypes: string[],
  avoidTypes: string[],
  careerAdvice: string,
  relationshipAdvice: string,
}
```

**시각화 전략 (컬러풀 + 모던):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| mbtiType | 대형 MBTI 4글자 | MBTI 설명 |
| dimensionFortunes | 4개 막대 차트 | 차원별 분석 |
| compatible/avoid | 타입 칩 리스트 | 궁합 설명 |

---

### 8. 꿈해몽 (fortune-dream)

**데이터 구조:**
```typescript
{
  dreamSymbols: Array<{ symbol, meaning, fortuneType }>,
  overallInterpretation: string,
  luckyNumbers: string[],
  advice: string,
  relatedFortunes: { wealth, love, health },
}
```

**시각화 전략 (몽환 + 구름):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| dreamSymbols | 구름 모양 카드 | 심볼 상세 해석 |
| luckyNumbers | 별 모양 숫자 | 숫자 의미 |
| relatedFortunes | 3개 카테고리 아이콘 | 운세 상세 |

---

### 9. 사주 (fortune-traditional-saju)

**데이터 구조:**
```typescript
{
  fourPillars: {
    year, month, day, time: {
      stem, branch, element, meaning
    }
  },
  fiveElements: {
    wood, fire, earth, metal, water: number  // 비율
  },
  majorLuck: Array<{ age, element, description }>,
  yearlyFortune: { score, analysis },
  personalityAnalysis: string,
}
```

**시각화 전략 (동양 철학):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| fourPillars | 4개 한자 기둥 | 각 기둥 해석 |
| fiveElements | 오행 원형 차트 | 오행 분석 |
| majorLuck | 타임라인 그래프 | 대운 상세 |

---

### 10. 바이오리듬 (fortune-biorhythm)

**데이터 구조:**
```typescript
{
  date: string,
  physical: { value, percentage, description },
  emotional: { value, percentage, description },
  intellectual: { value, percentage, description },
  average: number,
  peakDays: string[],
  lowDays: string[],
  weeklyChart: Array<{ date, p, e, i }>,
}
```

**시각화 전략 (과학적 + 그래프):**
| 데이터 | 시각화 방식 | 탭 시 상세 |
|--------|------------|-----------|
| 3 rhythms | 3색 파형 그래프 | 각 리듬 설명 |
| peakDays | 달력 하이라이트 | 최고 날짜 조언 |
| weeklyChart | 미니 주간 그래프 | 일별 상세 |

---

## 이미지 에셋 총괄 목록

### 공통 에셋

| 카테고리 | 에셋 | 수량 | 형식 | 용도 |
|---------|------|------|------|------|
| 아이콘 | 카테고리 아이콘 | 20개 | SVG | 연애/재물/건강 등 |
| 아이콘 | 행운 아이템 아이콘 | 30개 | SVG | 색상/숫자/방향 등 |
| 프레임 | 전통 프레임 | 10종 | PNG | 족자/두루마리/도장 |
| 배경 | 그라데이션 배경 | 10종 | PNG | 운세별 배경 |
| 장식 | 꽃/구름/별 | 50개 | PNG | 배경 장식 |

### 운세별 고유 에셋

#### 일일 운세
- 마스코트 (강아지): 10개 포즈
- 시간대 아이콘: 3개 (아침/오후/저녁)
- 해시태그 칩 배경: 3종

#### 연애운
- 커플 일러스트: 8개 (계절/상황별)
- 패션 아이템: 50개 (상의/하의/악세서리)
- 벚꽃 요소: 10개
- 족자 프레임: 3종

#### 타로
- 메이저 아르카나: 22장
- 마이너 아르카나: 56장
- 카드 뒷면: 5종
- 스프레드 배경: 4종

#### 관상
- 얼굴형 아이콘: 6종
- 동물상 일러스트: 12종
- 오관 아이콘: 5개
- 전통 프레임: 5종

#### 궁합
- 원앙 일러스트: 3종
- 음양 아이콘: 10개
- 등급 도장: 5종 (A~F)
- 전통 혼례 장식: 10개

#### 신년 운세
- 봉황 일러스트: 2종
- 용 일러스트: 2종
- 월별 아이콘: 12개
- 금박 장식: 20개

---

## Flutter 구현 가이드

### 기본 구조

```dart
// 인포그래픽 결과 페이지 기본 구조
class InfographicResultPage extends StatelessWidget {
  final FortuneResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 테마별 배경
          ThemedBackground(theme: fortuneType),

          // 2. 스크롤 가능 콘텐츠
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 3. 헤더 (테마별)
                  ThemedHeader(title: title),

                  // 4. 히어로 섹션 (점수/메인 비주얼)
                  HeroSection(data: result.hero),

                  // 5. 인포그래픽 섹션들
                  ...buildSections(result),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 탭 가능 위젯

```dart
class TappableInfoCard extends StatelessWidget {
  final Widget summary;
  final Widget Function(BuildContext) detailBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          // 탭 가능함을 암시하는 미묘한 그림자
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            summary,
            // 탭 힌트 아이콘 (우측 하단)
            Positioned(
              right: 8,
              bottom: 8,
              child: Icon(
                Icons.touch_app,
                size: 16,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: detailBuilder(context),
        ),
      ),
    );
  }
}
```

### 운세별 테마 설정

```dart
// fortune_themes.dart
class FortuneThemes {
  static FortuneTheme get daily => FortuneTheme(
    gradient: LinearGradient(
      colors: [Color(0xFF98E4C9), Color(0xFFFFC3C3), Color(0xFFD4B6FF)],
    ),
    primaryColor: Color(0xFF6B4EFF),
    mascot: 'assets/images/mascot/dog_happy.png',
  );

  static FortuneTheme get love => FortuneTheme(
    gradient: LinearGradient(
      colors: [Color(0xFFF5E6D3), Color(0xFFFFD1DC)],
    ),
    primaryColor: Color(0xFFE91E63),
    decorations: ['cherry_blossom', 'scroll_frame'],
  );

  static FortuneTheme get tarot => FortuneTheme(
    gradient: LinearGradient(
      colors: [Color(0xFF1A1A2E), Color(0xFF4A148C)],
    ),
    primaryColor: Color(0xFFFFD700),
    particles: 'stars',
  );

  // ... 39개 운세별 테마
}
```

### 점수 시각화 위젯

```dart
class ScoreVisualization extends StatelessWidget {
  final int score;
  final VisualizationType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      VisualizationType.circle => CircularScoreIndicator(score: score),
      VisualizationType.heart => HeartGaugeIndicator(score: score),
      VisualizationType.bar => HorizontalBarIndicator(score: score),
      VisualizationType.stars => StarRatingIndicator(score: score),
      VisualizationType.thermometer => ThermometerIndicator(score: score),
    };
  }
}

// 원형 점수 표시
class CircularScoreIndicator extends StatelessWidget {
  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 12,
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
          // 점수 원
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 12,
            valueColor: AlwaysStoppedAnimation(_getColorForScore(score)),
          ),
          // 점수 텍스트
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: context.heading1.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('점', style: context.body1),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 애니메이션 가이드

### 진입 애니메이션

```dart
// 순차적 페이드인
class StaggeredFadeIn extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        return FadeInAnimation(
          delay: delay * entry.key,
          child: entry.value,
        );
      }).toList(),
    );
  }
}
```

### 점수 카운트업

```dart
class CountUpAnimation extends StatefulWidget {
  final int target;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: duration,
      builder: (_, value, __) => Text(
        '$value',
        style: context.heading1,
      ),
    );
  }
}
```

### 반짝임 효과

```dart
class SparkleEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: Colors.yellow,
      child: Icon(Icons.star),
    );
  }
}
```

---

## 접근성 고려사항

1. **색상 대비**: 모든 텍스트는 WCAG AA 기준 충족
2. **탭 영역**: 최소 44x44 포인트
3. **스크린 리더**: 모든 시각 요소에 semanticsLabel 추가
4. **대체 텍스트**: 인포그래픽의 핵심 정보를 텍스트로도 제공

```dart
Semantics(
  label: '연애운 점수 85점, 매우 좋음',
  child: HeartScoreIndicator(score: 85),
)
```

---

## 다음 단계

1. Figma에서 21-figma-design-prompts.md 기반 디자인 생성
2. 생성된 디자인을 SVG/PNG로 export
3. 이 가이드를 참고하여 Flutter 위젯 구현
4. 각 운세별 인포그래픽 페이지 개발

---

**관련 문서:**
- [21-figma-design-prompts.md](./21-figma-design-prompts.md) - Figma 디자인 요청 프롬프트
- [03-ui-design-system.md](./03-ui-design-system.md) - UI 디자인 시스템
- [05-fortune-system.md](./05-fortune-system.md) - 운세 시스템 개요