# 🎨 Fortune 앱 운세 결과 디자인 시스템

> **최종 업데이트**: 2025년 7월 26일
> **작성자**: Fortune Design Team

## 📚 목차

1. [디자인 원칙](#디자인-원칙)
2. [공통 컴포넌트](#공통-컴포넌트)
3. [카테고리별 디자인](#카테고리별-디자인)
4. [운세 타입별 상세 레이아웃](#운세-타입별-상세-레이아웃)
5. [시각화 요소](#시각화-요소)
6. [애니메이션 가이드](#애니메이션-가이드)
7. [반응형 디자인](#반응형-디자인)

---

## 🎯 디자인 원칙

### 핵심 디자인 철학
- **Glass Morphism**: 투명도와 블러 효과를 활용한 현대적 디자인
- **모노크롬 테마**: 깔끔하고 세련된 흑백 기반 디자인
- **Instagram 스타일**: 친숙하고 미니멀한 비주얼 언어
- **정보의 점진적 공개**: 스크롤하며 자연스럽게 정보 습득
- **Less is More**: 불필요한 장식을 제거한 본질적 디자인

### 색상 시스템

```dart
// 모노크롬 색상 팔레트
static const Color primary = Color(0xFF000000);          // 순수 검정
static const Color primaryLight = Color(0xFF333333);     // 다크 그레이
static const Color primaryDark = Color(0xFF1A1A1A);      // 매우 진한 그레이

// 배경 색상
static const Color background = Color(0xFFFAFAFA);       // 밝은 회색 배경
static const Color surface = Color(0xFFFFFFFF);          // 순수 흰색
static const Color cardBackground = Color(0xFFF6F6F6);   // 카드 배경

// 텍스트 색상
static const Color textPrimary = Color(0xFF262626);      // Instagram 블랙
static const Color textSecondary = Color(0xFF8E8E8E);    // Instagram 그레이

// 액센트 색상 (제한적 사용)
static const Color secondary = Color(0xFFF56040);        // Instagram 오렌지
```

---

## 🧩 공통 컴포넌트

### 1. 헤더 섹션
```
┌─────────────────────────────────────┐
│  ← Back    운세 제목    Share 🔗    │
│                                     │
│     [카테고리 아이콘]               │
│      운세 타입 명칭                 │
│    2025.01.16 13:45                │
└─────────────────────────────────────┘
```

### 2. 점수 표시 컴포넌트
```
      ╭────────────╮
      │    85점    │  <- 애니메이션 숫자 카운팅
      │  ████████  │  <- 원형 프로그레스
      ╰────────────╯
```

### 3. Glass Card 컴포넌트
```dart
GlassContainer(
  blur: 10,
  borderRadius: BorderRadius.circular(24),
  gradient: LinearGradient(
    colors: [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.05),
    ],
  ),
  border: Border.all(
    color: Colors.white.withOpacity(0.2),
  ),
)
```

---

## 🎨 모든 카테고리 통합 디자인

### 통일된 비주얼 언어
- **색상**: 모든 카테고리가 동일한 모노크롬 테마 사용
- **구분**: 아이콘과 레이아웃으로 카테고리 구별
- **일관성**: 동일한 카드 스타일과 타이포그래피
- **집중도**: 색상 대신 콘텐츠에 집중할 수 있는 환경

### 카테고리별 아이콘 시스템
- **연애/인연**: 하트, 링, 커플 아이콘 (모노크롬)
- **직업/사업**: 브리프케이스, 차트, 트로피 아이콘
- **재물/투자**: 동전, 지갑, 다이아몬드 아이콘
- **건강/라이프**: 하트비트, 요가, 러닝 아이콘

### 공통 애니메이션 효과
- **진입**: fadeIn + scaleTransition (모든 카테고리 동일)
- **상호작용**: 0.95 scale on tap
- **데이터 시각화**: 모노크롬 차트와 그래프
- **로딩**: 통일된 shimmer 효과

---

## 📐 운세 타입별 상세 레이아웃

### 1. 일일 운세 (Daily Fortune)

```
┌─────────────────────────────────────┐
│         오늘의 운세 점수            │
│            [85점]                   │
│         ⭐⭐⭐⭐☆                  │
├─────────────────────────────────────┤
│  시간대별 운세 흐름                 │
│  ┌───────────────────────────┐     │
│  │ 📊 24시간 그래프          │     │
│  │    Peak: 14:00-16:00      │     │
│  └───────────────────────────┘     │
├─────────────────────────────────────┤
│  분야별 세부 점수                   │
│  ├─ 총운: ████████░░ 80%          │
│  ├─ 애정: ██████████ 100%         │
│  ├─ 금전: ██████░░░░ 60%          │
│  └─ 건강: ████████░░ 80%          │
├─────────────────────────────────────┤
│  오늘의 행운 아이템                 │
│  ┌─────┬─────┬─────┬─────┐        │
│  │ 색상 │ 숫자 │ 방향 │ 시간 │        │
│  │ 💙  │  7  │ 동쪽 │14-16│        │
│  └─────┴─────┴─────┴─────┘        │
└─────────────────────────────────────┘
```

### 2. 사주팔자 (Saju)

```
┌─────────────────────────────────────┐
│          사주 명식                  │
│  ┌─────┬─────┬─────┬─────┐        │
│  │ 年柱 │ 月柱 │ 日柱 │ 時柱 │        │
│  ├─────┼─────┼─────┼─────┤        │
│  │ 甲子 │ 乙丑 │ 丙寅 │ 丁卯 │        │
│  └─────┴─────┴─────┴─────┘        │
├─────────────────────────────────────┤
│         오행 균형도                 │
│     木 ████████░░ 80%              │
│     火 ██████░░░░ 60%              │
│     土 ████░░░░░░ 40%              │
│     金 ██████████ 100%             │
│     水 ██░░░░░░░░ 20%              │
├─────────────────────────────────────┤
│         운세 해석                   │
│  [Glass Card with interpretation]   │
└─────────────────────────────────────┘
```

### 3. MBTI 운세

```
┌─────────────────────────────────────┐
│        INTJ - 전략가형              │
│         ⚡️ 🧠 📊                   │
├─────────────────────────────────────┤
│  오늘의 성격 시너지                 │
│  ┌───────────────────────────┐     │
│  │   인지 기능 활성도         │     │
│  │   Ni ████████████ 100%    │     │
│  │   Te ████████░░░░ 80%     │     │
│  │   Fi ██████░░░░░░ 60%     │     │
│  │   Se ████░░░░░░░░ 40%     │     │
│  └───────────────────────────┘     │
├─────────────────────────────────────┤
│  행운의 활동                        │
│  • 전략 수립 (오전 9-11시)         │
│  • 심층 분석 (오후 2-4시)          │
│  • 독서/연구 (저녁 7-9시)          │
└─────────────────────────────────────┘
```

### 4. 궁합 운세 (Compatibility)

```
┌─────────────────────────────────────┐
│         궁합 분석 결과              │
│    Person A  ❤️  Person B           │
│         총점: 87/100                │
├─────────────────────────────────────┤
│        레이더 차트                  │
│         감정 100                    │
│          ╱│╲                       │
│    지성 ╱ │ ╲ 신체                │
│    80  ────┼──── 90                 │
│        ╲  │  ╱                    │
│    가치관╲│╱ 생활                  │
│         85  75                      │
├─────────────────────────────────────┤
│  세부 분석                          │
│  [Expandable cards for each area]  │
└─────────────────────────────────────┘
```

### 5. 타로 카드 운세

```
┌─────────────────────────────────────┐
│         오늘의 타로                 │
├─────────────────────────────────────┤
│     과거      현재      미래        │
│   ┌─────┐  ┌─────┐  ┌─────┐      │
│   │  🃏  │  │  🃏  │  │  🃏  │      │
│   │ The │  │ The │  │ The │      │
│   │Fool │  │Star │  │ Sun │      │
│   └─────┘  └─────┘  └─────┘      │
├─────────────────────────────────────┤
│  카드 해석 (스와이프 가능)         │
│  [Card interpretation carousel]     │
└─────────────────────────────────────┘
```

---

## 📊 시각화 요소

### 1. 차트 타입

#### 원형 프로그레스
```dart
CircularProgressIndicator(
  value: score / 100,
  strokeWidth: 8,
  backgroundColor: Colors.grey.shade200,
  valueColor: AlwaysStoppedAnimation<Color>(
    _getScoreColor(score),
  ),
)
```

#### 막대 그래프
```dart
LinearProgressIndicator(
  value: progress,
  minHeight: 20,
  backgroundColor: Colors.grey.shade200,
  valueColor: AlwaysStoppedAnimation<Color>(
    categoryColor,
  ),
)
```

#### 레이더 차트
```dart
RadarChart(
  data: RadarChartData(
    dataSets: [
      RadarDataSet(
        fillColor: color.withOpacity(0.3),
        borderColor: color,
        dataEntries: scores.map((score) => 
          RadarEntry(value: score.toDouble())
        ).toList(),
      ),
    ],
  ),
)
```

### 2. 인터랙티브 요소

#### 스와이프 카드
- 좌우 스와이프로 다음/이전 정보 확인
- 스프링 애니메이션으로 자연스러운 움직임

#### 확장 가능한 섹션
- 탭하면 상세 정보 표시
- 부드러운 높이 애니메이션

#### 플로팅 액션
- 공유, 저장, 즐겨찾기 버튼
- 롱프레스 시 툴팁 표시

---

## 🎬 애니메이션 가이드

### 1. 진입 애니메이션

```dart
// 페이드인 + 슬라이드
.animate()
  .fadeIn(duration: 500.ms)
  .slideY(begin: 0.1, end: 0)

// 스케일 + 페이드
.animate()
  .scale(duration: 600.ms, curve: Curves.elasticOut)
  .fade()

// 순차적 애니메이션
.animate()
  .fadeIn(delay: Duration(milliseconds: index * 100))
```

### 2. 인터랙션 애니메이션

```dart
// 탭 효과
Transform.scale(
  scale: _isPressed ? 0.95 : 1.0,
  child: widget,
)

// 호버 효과
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  transform: Matrix4.identity()
    ..translate(0.0, _isHovered ? -5.0 : 0.0),
)
```

### 3. 데이터 업데이트 애니메이션

```dart
// 숫자 카운팅
AnimatedCounter(
  value: score,
  duration: Duration(seconds: 1),
  curve: Curves.easeOut,
)

// 프로그레스 바
AnimatedContainer(
  duration: Duration(milliseconds: 1000),
  width: MediaQuery.of(context).size.width * progress,
)
```

---

## 📱 반응형 디자인

### 브레이크포인트

```dart
class ResponsiveBreakpoints {
  static const double mobile = 360;
  static const double tablet = 768;
  static const double desktop = 1024;
}
```

### 레이아웃 조정

#### 모바일 (360-768px)
- 단일 컬럼 레이아웃
- 풀 너비 카드
- 수직 스크롤 중심

#### 태블릿 (768-1024px)
- 2컬럼 그리드 가능
- 사이드바 네비게이션
- 팝오버 상세 정보

#### 데스크탑 (1024px+)
- 3컬럼 레이아웃
- 고정 사이드바
- 모달 다이얼로그

---

## 🎯 구현 체크리스트

### 필수 구현 사항
- [ ] Glass morphism 효과 적용
- [ ] 카테고리별 색상 시스템
- [ ] 기본 애니메이션 (페이드, 슬라이드)
- [ ] 반응형 레이아웃
- [ ] 점수 시각화
- [ ] 공유 기능

### 권장 구현 사항
- [ ] 파티클 효과
- [ ] 스와이프 제스처
- [ ] 햅틱 피드백
- [ ] 다크 모드 지원
- [ ] 접근성 개선
- [ ] 성능 최적화

---

## 📚 참고 자료

- [Flutter Animate Package](https://pub.dev/packages/flutter_animate)
- [Glass Morphism Design](https://glassmorphism.com/)
- [Material Design 3](https://m3.material.io/)
- [Instagram Design System](https://about.instagram.com/brand)

---

> 이 문서는 지속적으로 업데이트됩니다. 새로운 운세 타입이나 디자인 패턴이 추가될 때마다 이 문서를 참조하고 업데이트해주세요.