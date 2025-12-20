# API 호출 최적화 시스템

> 운세별 API 호출 로직, 캐시 전략, 비용 분석 문서

## 1. 시스템 개요

### 1.1 최적화 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                    운세 조회 요청                                  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│  1️⃣ 개인 캐시 확인 (fortune_results)                              │
│     - 오늘 + 동일 조건 해시 조회                                    │
│     - 히트: 50% 확률 광고 → 즉시 반환                              │
│     ✅ API 호출 생략                                               │
└───────────────────────────┬─────────────────────────────────────┘
                            │ 미스
┌───────────────────────────▼─────────────────────────────────────┐
│  2️⃣ DB 풀 크기 확인                                               │
│     - 동일 해시 데이터 300개 이상?                                  │
│     - 충족: 랜덤 선택 → 5초 대기 → 반환                            │
│     ✅ API 호출 생략                                               │
└───────────────────────────┬─────────────────────────────────────┘
                            │ 미달
┌───────────────────────────▼─────────────────────────────────────┐
│  3️⃣ 30% 랜덤 선택                                                 │
│     - 30% 확률 당첨 시: 최근 100개 중 랜덤 선택                    │
│     ✅ API 호출 생략                                               │
└───────────────────────────┬─────────────────────────────────────┘
                            │ 미당첨 (70%)
┌───────────────────────────▼─────────────────────────────────────┐
│  4️⃣-6️⃣ API 호출                                                  │
│     - 광고 표시 (5초)                                              │
│     - Edge Function 호출                                          │
│     - 결과 DB 저장                                                 │
│     ❌ API 호출 발생                                               │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 핵심 상수

**파일**: `lib/core/services/fortune_optimization_service.dart`

```dart
static const int dbPoolThreshold = 300;           // DB 풀 최소 크기
static const double randomSelectionProbability = 0.3;  // 30% 확률
static const double personalCacheAdProbability = 0.5;  // 개인 캐시 50% 광고
static const Duration delayDuration = Duration(seconds: 5);  // 5초 대기
```

---

## 2. 운세별 해시 구성 분석

### 2.1 효율성 분류

| 등급 | 조합 수 | 300개 도달 가능성 | 운세 타입 |
|------|---------|-----------------|----------|
| 🟢 **매우 효율** | 1-20 | 빠름 (수천 회) | MBTI, 혈액형 |
| 🟡 **효율** | 20-200 | 중간 (수만 회) | Daily (질문 제외), 가족 |
| 🟠 **비효율** | 200-10,000 | 느림 (수십만 회) | Personality DNA, Ex-lover |
| 🔴 **매우 비효율** | 10,000+ | 불가능 | Love, Compatibility, Dream, 관상 |

### 2.2 상세 분석표

| 운세 타입 | 해시 구성 | 변수 | 조합 수 | 300개 도달 API 횟수 |
|----------|----------|------|---------|-------------------|
| **MBTI** | `mbti:${hashCode}` | MBTI 16종 | **16** | 4,800 |
| **Biorhythm** | `birthDate:${hashCode}` | 생년월일 | **~36,500** | 10,950,000 |
| **Personality DNA** | `mbti\|blood\|zodiac\|animal` | 16×4×12×12 | **9,216** | 2,764,800 |
| **Daily** | `period\|category\|emotion\|q` | 5×5×5×∞ | **∞ (질문)** | 무한 |
| **Daily (질문 제외)** | `period\|category\|emotion` | 5×5×5 | **125** | 37,500 |
| **Love** | 복합 (13개 필드) | 수백만 | **∞** | 무한 |
| **Compatibility** | `p1\|bd1\|p2\|bd2` | 이름×생일² | **∞** | 무한 |
| **Ex-lover** | `emotion\|time\|curiosity\|initiator\|contact` | 5×5×5×2×3 | **750** | 225,000 |
| **Talent** | `birth\|gender\|concerns\|interests\|style` | 복합 | **수천** | 수백만 |
| **Dream** | `dream:${hashCode}\|date` | 꿈내용×날짜 | **∞** | 무한 |
| **Face Reading** | `img:${hash}\|gender\|age` | 이미지×성별×나이 | **∞** | 무한 |
| **Moving** | `current\|target\|period\|purpose` | 복합 | **수백** | 수만 |
| **Health** | `concern\|symptoms\|sleep\|exercise\|stress\|meal` | 복합 | **수천** | 수백만 |
| **Lucky Exam** | `category\|date\|prep\|anxiety\|status\|timepoint` | 복합×날짜 | **∞** | 무한 |
| **Family** | `concern\|questions\|relationship` | 5×N×M | **수백** | 수만 |
| **Career Future** | `role\|goal\|time\|path\|skills` | 복합 | **수천** | 수백만 |
| **Blind Date** | `partner\|place\|expectations` | 텍스트³ | **∞** | 무한 |
| **Home Fengshui** | `address\|homeType\|floor\|doorDirection` | 복합 | **∞** | 무한 |

### 2.3 날짜 포함 여부 분석

| 날짜 제외 (풀 누적 가능) | 날짜 포함 (매일 리셋) |
|----------------------|-------------------|
| MBTI, Personality DNA, Biorhythm, Daily, Talent, Freelance, Family | E-sports, Lucky Exam, Startup, Career Seeker, Career Change, Tojeong, Salpuli |

---

## 3. API 호출 확률 계산

### 3.1 단계별 통과 확률

```
요청 100회 기준:

1단계 (개인 캐시)
├─ 히트: 30회 → 즉시 반환 (API 0회)
└─ 미스: 70회 → 다음 단계

2단계 (DB 풀 300개)
├─ 풀 충족: 35회 → DB 랜덤 (API 0회)
└─ 풀 미달: 35회 → 다음 단계

3단계 (30% 랜덤)
├─ 당첨: 10회 → DB 랜덤 (API 0회)
└─ 미당첨: 25회 → 다음 단계

4단계 (API 호출)
└─ API 호출: 25회

최종 API 호출률: 25/100 = 25%
(풀 축적 전 초기에는 약 28%)
```

### 3.2 풀 축적 단계별 API 호출률

| 풀 상태 | 개인 캐시 | DB 풀 | 랜덤 | API 호출률 |
|--------|----------|-------|------|----------|
| 초기 (0-50개) | 30% | 0% | 5% | **46%** |
| 성장 (50-150개) | 30% | 10% | 15% | **32%** |
| 중간 (150-250개) | 30% | 25% | 20% | **18%** |
| 성숙 (300개+) | 30% | 50% | 5% | **11%** |

---

## 4. 비용 시뮬레이션

### 4.1 LLM API 비용 기준

| 모델 | 입력 (1M tokens) | 출력 (1M tokens) | 평균/호출 (2K tokens) |
|------|-----------------|-----------------|---------------------|
| GPT-4o | $2.50 | $10.00 | $0.025 |
| GPT-4o-mini | $0.15 | $0.60 | $0.0015 |
| Claude 3.5 Sonnet | $3.00 | $15.00 | $0.036 |
| Gemini 1.5 Flash | $0.075 | $0.30 | $0.00075 |

### 4.2 월간 비용 예측 (DAU 1,000명)

**가정**:
- 일일 운세 요청: 5,000회 (인당 5회)
- 평균 토큰/호출: 2,000
- 모델: GPT-4o-mini + GPT-4o 혼합

| 항목 | 현재 시스템 | 최적화 후 |
|------|-----------|----------|
| 일일 운세 요청 | 5,000회 | 5,000회 |
| API 호출 비율 | 28% | 15% |
| 일일 API 호출 | 1,400회 | 750회 |
| 월간 API 호출 | 42,000회 | 22,500회 |
| 평균 비용/호출 | $0.01 | $0.01 |
| **월간 비용** | **$420** | **$225** |
| **절감액** | - | **$195/월 (46%)** |

### 4.3 운세 타입별 비용 비중

| 운세 | 월간 호출 비중 | 비용 비중 | 최적화 우선순위 |
|------|-------------|----------|--------------|
| Daily | 30% | 35% | 🔴 높음 |
| Personality DNA | 15% | 18% | 🔴 높음 |
| Love | 10% | 12% | 🟠 중간 |
| MBTI | 20% | 15% | 🟢 이미 효율 |
| 기타 | 25% | 20% | 🟡 검토 필요 |

---

## 5. 최적화 개선안

### 5.1 Personality DNA (9,216 → 1 조합)

**현재 문제**:
```dart
// 9,216개 조합 = 16 × 4 × 12 × 12
return 'mbti:${mbti!.hashCode}|blood:${bloodType!.hashCode}|zodiac:${zodiac!.hashCode}|animal:${animal!.hashCode}';
```

**개선안**:
```dart
// 전체 통합 1개 조합 → 300개 후 즉시 풀 재사용
return 'personality_dna';
```

**효과**: 2,764,800회 → 300회 (99.99% 감소)

### 5.2 Daily Fortune (∞ → 125 조합)

**현재 문제**:
```dart
// 질문 해시 포함 → 무한 조합
if (question != null && question!.isNotEmpty) 'q:${question!.hashCode}',
```

**개선안**:
```dart
// 질문 제외 → 5×5×5 = 125 조합
return 'period:${period.name}|category:${category?.name ?? "none"}|emotion:${emotion?.name ?? "none"}';
```

**효과**: ∞ → 37,500회 (125 조합 × 300개)

### 5.3 기타 운세 개선 제안

| 운세 | 현재 | 개선안 | 예상 효과 |
|------|------|--------|----------|
| Dream | 꿈내용 해시 | 키워드 카테고리화 | 90% 감소 |
| Face Reading | 이미지 해시 | 성별+나이 범위만 | 95% 감소 |
| Love | 13개 필드 | 핵심 3개만 | 80% 감소 |
| Compatibility | 이름+생일 | 띠+별자리만 | 99% 감소 |

---

## 6. 모니터링 메트릭

### 6.1 추적 지표

```sql
-- 일별 API 호출 통계
SELECT
  date,
  fortune_type,
  COUNT(*) as total_requests,
  SUM(CASE WHEN api_call THEN 1 ELSE 0 END) as api_calls,
  ROUND(SUM(CASE WHEN api_call THEN 1 ELSE 0 END)::decimal / COUNT(*) * 100, 2) as api_rate
FROM fortune_results
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY date, fortune_type
ORDER BY date DESC, api_calls DESC;
```

### 6.2 알림 임계값

| 지표 | 정상 | 경고 | 위험 |
|------|------|------|------|
| API 호출률 | < 20% | 20-35% | > 35% |
| 풀 성장률 | > 10개/일 | 5-10개/일 | < 5개/일 |
| 캐시 히트율 | > 40% | 30-40% | < 30% |

---

## 7. 관련 파일

### 7.1 핵심 서비스

- [fortune_optimization_service.dart](lib/core/services/fortune_optimization_service.dart) - 6단계 최적화 로직
- [unified_fortune_service.dart](lib/core/services/unified_fortune_service.dart) - 통합 운세 서비스

### 7.2 운세 조건 파일

- [personality_dna_fortune_conditions.dart](lib/features/fortune/domain/models/conditions/personality_dna_fortune_conditions.dart)
- [daily_fortune_conditions.dart](lib/features/fortune/domain/models/conditions/daily_fortune_conditions.dart)
- [love_fortune_conditions.dart](lib/features/fortune/domain/models/conditions/love_fortune_conditions.dart)
- 기타 26개 조건 파일

### 7.3 DB 테이블

- `fortune_results` - 캐시 결과 저장
- `fortune_history` - 조회 이력 저장

---

## 8. 버전 히스토리

| 버전 | 날짜 | 변경 사항 |
|------|------|----------|
| 1.0 | 2025-12-20 | 초기 문서 작성 |