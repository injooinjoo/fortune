# Fortune 데이터 흐름 문서

## 전체 아키텍처

```
사용자 요청 (칩 탭)
      │
      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter 클라이언트                            │
├─────────────────────────────────────────────────────────────────┤
│  1. CacheService.getCachedFortune()  ← 캐시 확인                 │
│  2. FortuneApiDecisionService.shouldCallApi()  ← API 결정        │
│     ├─ true  → Edge Function 호출                               │
│     └─ false → getSimilarFortune() (fortune_history DB 검색)     │
└─────────────────────────────────────────────────────────────────┘
      │
      ▼ (API 호출 시)
┌─────────────────────────────────────────────────────────────────┐
│                    Edge Function (서버)                          │
├─────────────────────────────────────────────────────────────────┤
│  1. Cohort 추출 (나잇대, 띠, 오행 등)                             │
│  2. get_random_cohort_result RPC 호출                            │
│     ├─ Pool 있음 → 개인화 후 반환                                │
│     └─ Pool 없음 → LLM 호출 → Pool에 저장 → 반환                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. API 호출 결정 로직 (FortuneApiDecisionService)

### 확률 계산 공식
```
최종확률 = (사용자등급 × 0.4) + (운세중요도 × 0.3) + (시간대 × 0.2) + (랜덤 × 0.1)
```

### 사용자 등급 점수 (40%)
| 등급 | 조건 | 점수 |
|------|------|------|
| VIP | 7일 내 5회 이상 사용 | 100% |
| 신규 | 가입 7일 이내 | 80% |
| 일반 | 그 외 | 30% |
| 휴면 | 30일 이상 미사용 | 10% |

### 운세 중요도 점수 (30%)
| 중요도 | 운세 타입 | 점수 |
|--------|----------|------|
| 높음 | love, health, investment, exam | 50% |
| 중간 | dream, traditional_saju, family, moving, wish | 30% |
| 낮음 | fortune_cookie, talisman, biorhythm, person_to_avoid, ex_fortune, blind_date | 10% |
| 기타 | 그 외 | 20% |

### 시간대 점수 (20%)
| 시간대 | 시간 | 점수 |
|--------|------|------|
| 피크타임 | 12-14시, 19-22시 | 20% |
| 오프피크 | 그 외 | 50% |

### 항상 API 호출 타입 (예외)
```dart
const alwaysCallApiTypes = ['wish', 'dream', 'face-reading', 'ex-lover', 'blind-date'];
```

---

## 2. Cohort Pool 시스템 (Edge Function)

### Cohort 추출 요소 (타입별)
| 운세 타입 | Cohort 요소 | 예상 조합 수 |
|----------|-------------|-------------|
| daily | period + zodiac + element | 300 |
| love | ageGroup + gender + status + zodiac | 540 |
| career | ageGroup + gender + industry | 135 |
| compatibility | zodiac1 + zodiac2 + genderPair | 576 |
| mbti | mbti | 16 |
| dream | dreamCategory + emotion + zodiac | 540 |
| health | ageGroup + gender + season + element | 300 |
| tarot | spreadType + questionCategory + element | 75 |
| saju | dayMaster + elementBalance + questionCategory | 250 |
| talent | ageGroup + gender + talentArea | 120 |
| exam | examCategory + zodiac + element | 180 |
| moving | direction + zodiac + element | 240 |
| pet | petCategory + zodiac + element | 180 |
| new-year | goal + zodiac | 84 |
| talisman | zodiac + element | 60 |
| face-reading | faceShape + gender + ageGroup | 120 |
| ex-lover | emotionState + timeElapsed + contactStatus | 60 |
| wealth | goal + risk + urgency | 45 |

### Cohort Pool 사용 Edge Functions (28개)
- fortune-daily, fortune-love, fortune-compatibility, fortune-tarot
- fortune-career, fortune-health, fortune-dream, fortune-wealth
- fortune-talent, fortune-investment, fortune-ex-lover, fortune-blind-date
- fortune-avoid-people, fortune-exam, fortune-moving, fortune-pet-compatibility
- fortune-new-year, fortune-talisman, fortune-lucky-items
- fortune-face-reading, fortune-traditional-saju
- fortune-family-relationship, fortune-family-change, fortune-family-children
- fortune-family-health, fortune-family-wealth

---

## 3. 운세 타입별 데이터 소스 정리

### 분류 기준
- **A**: 항상 API (특수 입력 필요)
- **B**: Decision + Cohort (일반 최적화)
- **C**: 특수 처리 (이미지 생성/분석)
- **D**: DB 직접 조회 (API 없음)
- **E**: 특수 핸들러 (클라이언트 처리)

---

### 칩별 상세 매핑 (31개)

| 칩 ID | fortuneType | 분류 | 데이터 소스 | Edge Function | 비고 |
|-------|-------------|------|-------------|---------------|------|
| **daily** | daily | B | Decision+Cohort | fortune-daily | |
| **dailyCalendar** | daily_calendar | B | Decision+Cohort | fortune-time | 기간별 운세 |
| **newYear** | newYear | B | Decision+Cohort | fortune-new-year | |
| **love** | love | B | Decision+Cohort | fortune-love | |
| **compatibility** | compatibility | B | Decision+Cohort | fortune-compatibility | |
| **exLover** | exLover | A | 항상 API | fortune-ex-lover | 개인 입력 필요 |
| **yearlyEncounter** | yearlyEncounter | C | 항상 API | fortune-yearly-encounter | 이미지 생성 |
| **blindDate** | blindDate | A | 항상 API | fortune-blind-date | 개인 입력 필요 |
| **avoidPeople** | avoidPeople | B | Decision+Cohort | fortune-avoid-people | |
| **career** | career | B | Decision+Cohort | fortune-career | |
| **talent** | talent | B | Decision+Cohort | fortune-talent | |
| **money** | money | B | Decision+Cohort | fortune-wealth | |
| **luckyItems** | luckyItems | B | Decision+Cohort | fortune-lucky-items | |
| **lotto** | lotto | B | Decision+Cohort | fortune-lucky-lottery | |
| **tarot** | tarot | B | Decision+Cohort | fortune-tarot | |
| **traditional** | traditional | B | Decision+Cohort | fortune-traditional-saju | |
| **faceReading** | faceReading | C | 항상 API | fortune-face-reading | 이미지 분석 |
| **talisman** | talisman | C | 항상 API | generate-talisman | 이미지 생성 |
| **pastLife** | pastLife | C | 항상 API | fortune-past-life | 이미지 생성 (V2 리뉴얼) |
| **personalityDna** | personalityDna | B | Decision+Cohort | personality-dna | |
| **biorhythm** | biorhythm | B | Decision+Cohort | fortune-biorhythm | |
| **mbti** | mbti | B | Decision+Cohort | fortune-mbti | |
| **health** | health | B | Decision+Cohort | fortune-health | |
| **exercise** | exercise | B | Decision+Cohort | fortune-exercise | |
| **sportsGame** | sportsGame | B | Decision+Cohort | fortune-match-insight | |
| **dream** | dream | A | 항상 API | fortune-dream | 개인 입력 필요 |
| **wish** | wish | A | 항상 API | analyze-wish | 개인 입력 필요 |
| **fortuneCookie** | fortuneCookie | E | 클라이언트 | 없음 | 애니메이션 처리 |
| **celebrity** | celebrity | B | Decision+Cohort | fortune-celebrity | |
| **family** | family | B | Decision+Cohort | fortune-family | |
| **pet** | pet | B | Decision+Cohort | fortune-pet-compatibility | |
| **naming** | naming | B | Decision+Cohort | fortune-naming | |
| **ootdEvaluation** | ootdEvaluation | C | 항상 API | fortune-ootd | 이미지 분석 |
| **exam** | exam | B | Decision+Cohort | fortune-exam | |
| **moving** | moving | B | Decision+Cohort | fortune-moving | |
| **breathing** | breathing | E | 클라이언트 | 없음 | 명상 화면 이동 |
| **gratitude** | gratitude | D | 미구현 | 없음 | Edge Function 필요 |

---

## 4. 비용 절감 효과

### 전체 흐름에서의 절감
```
1단계: 캐시 확인           → 캐시 히트 시 100% 절감
2단계: Decision Service    → 72% 확률로 API 미호출
3단계: Similar Fortune     → fortune_history 재사용
4단계: Cohort Pool         → Pool 있으면 LLM 미호출
5단계: LLM 호출            → 최후의 수단
```

### 예상 비용 절감률
| 단계 | 절감률 | 누적 API 호출률 |
|------|--------|----------------|
| 캐시 | ~20% | 80% |
| Decision | ~57% | 23% |
| Cohort Pool | ~70% | 7% |
| **최종** | | **~7% API 호출** |

---

## 5. 특수 처리 운세

### 이미지 생성 (항상 API 필요)
| 타입 | Edge Function | 설명 | 최적화 |
|------|---------------|------|--------|
| yearlyEncounter | fortune-yearly-encounter | AI 인연 얼굴 이미지 | 없음 (항상 생성) |
| talisman | generate-talisman | 부적 이미지 | 없음 (항상 생성) |
| pastLife | fortune-past-life | 전생 초상화 (V2) | **이미지 Pool** (직업당 3개, 이후 재사용) |

### 이미지 분석 (항상 API 필요)
| 타입 | Edge Function | 설명 |
|------|---------------|------|
| faceReading | fortune-face-reading | 얼굴 사진 분석 |
| ootdEvaluation | fortune-ootd | 패션 사진 분석 |

### 개인 입력 필요 (항상 API 필요)
| 타입 | Edge Function | 설명 |
|------|---------------|------|
| dream | fortune-dream | 꿈 내용 텍스트 |
| wish | analyze-wish | 소원 텍스트 |
| exLover | fortune-ex-lover | 전 연인 정보 |
| blindDate | fortune-blind-date | 소개팅 상대 정보 |

### 클라이언트 특수 처리
| 타입 | 처리 방식 |
|------|----------|
| fortuneCookie | 애니메이션 후 랜덤 메시지 |
| breathing | /wellness/meditation 화면 이동 |
| viewAll | 전체 칩 목록 표시 |

---

## 6. 전생 운세 이미지 Pool 시스템 (pastLife)

### 개요
전생 운세(pastLife)는 이미지 생성 비용 절감을 위해 **이미지 Pool** 시스템을 사용합니다.
- 각 **status(직업) + gender(성별)**당 최대 3개 이미지 저장
- 3개 이상 존재 시 Pool에서 랜덤 재사용
- 얼굴 이미지 제공 시 항상 새로 생성 (개인화)

### 데이터베이스 테이블
```sql
past_life_portrait_pool
├─ id (UUID)
├─ status (TEXT)          -- STATUS_CONFIGS 키 (e.g., 'court_secretary')
├─ status_kr (TEXT)       -- 한글 직업명
├─ status_en (TEXT)       -- 영문 직업명
├─ gender (TEXT)          -- 'male' | 'female'
├─ portrait_url (TEXT)    -- Supabase Storage URL
├─ portrait_prompt (TEXT) -- 생성 프롬프트 (디버깅용)
├─ quality_score (DECIMAL)-- 품질 점수 (0-1)
├─ usage_count (INTEGER)  -- 재사용 횟수
├─ created_at, updated_at
```

### RPC 함수
| 함수 | 설명 |
|------|------|
| `get_portrait_count_for_status(status, gender)` | status+gender별 저장된 이미지 개수 |
| `get_random_portrait_for_status(status, gender)` | 랜덤 이미지 URL 반환 (usage_count 증가) |
| `save_portrait_to_pool(...)` | 새 이미지 저장 (3개 제한 체크) |
| `get_portrait_pool_stats()` | Pool 전체 통계 |

### 데이터 흐름
```
전생 운세 요청
      │
      ▼
┌─────────────────────────────────────────────────────┐
│         얼굴 이미지 있음?                            │
│         (faceImageBase64)                           │
└─────────────────────────────────────────────────────┘
        │                       │
       있음                    없음
        │                       │
        ▼                       ▼
  항상 새로 생성          get_portrait_count_for_status()
  (개인화 필요)                  │
        │                   ┌───┴───┐
        │                 ≥3개    <3개
        │                   │       │
        │                   ▼       ▼
        │           Pool에서 재사용   새로 생성
        │           (랜덤 선택)     + Pool에 저장
        │                   │       │
        └───────────────────┴───────┘
                            │
                            ▼
                    LLM으로 스토리 생성
                            │
                            ▼
                      결과 반환
```

### 예상 효과
- **STATUS_CONFIGS**: 80+ 직업
- **성별**: 2 (male/female)
- **최대 이미지 수**: 80 × 2 × 3 = **480개**
- **초기 생성 후**: 이미지 생성 API 호출 ~0% (LLM 스토리만 생성)
- **비용 절감**: 이미지 생성 비용 ~100% 절감 (Pool 가득 찬 후)

### 로깅 메타데이터
```typescript
metadata: {
  portraitFromPool: boolean,  // Pool에서 재사용 여부
  portraitStatus: string,     // 직업 코드
  portraitGender: string,     // 성별
}
```

---

## 7. 미구현/검토 필요 항목

| 칩 ID | 현재 상태 | 필요 작업 |
|-------|----------|----------|
| gratitude | Edge Function 없음 | fortune-gratitude 생성 필요 |
| lotto | lucky-lottery 사용 | 별도 lotto용 함수 검토 |

---

## 8. 데이터 흐름 다이어그램

```
[사용자] ──탭──▶ [ChatHomePage]
                      │
                      ▼
              _handleChipTap()
                      │
                      ▼
              ┌───────────────┐
              │ 특수 처리?    │
              └───────────────┘
                  │       │
          viewAll/breathing/fortuneCookie
                  │       │
                  ▼       ▼
              특수 핸들러   일반 운세
                          │
                          ▼
                   설문 진행 (있으면)
                          │
                          ▼
              _callFortuneApiWithCache()
                          │
                          ▼
              FortuneApiService.getFortune()
                          │
                  ┌───────┴───────┐
                  │               │
              캐시 히트       캐시 미스
                  │               │
                  ▼               ▼
              결과 반환    DecisionService.shouldCallApi()
                              │           │
                          true(28%)   false(72%)
                              │           │
                              ▼           ▼
                      Edge Function   getSimilarFortune()
                              │           │
                              ▼           ▼
                      Cohort Pool?   fortune_history
                        │     │           │
                      있음   없음         │
                        │     │           │
                        ▼     ▼           │
                      반환   LLM 호출     │
                              │           │
                              ▼           │
                      Pool에 저장        │
                              │           │
                              └─────┬─────┘
                                    │
                                    ▼
                            결과 반환 + 캐시 저장
                                    │
                                    ▼
                            ChatFortuneResultCard 표시
```
