# 하늘이 전체 운세 E2E QA 계획 및 1차 정적 검증 리포트

- 작성: 2026-05-11 04:01:00
- 범위: 하늘이(`haneul_oracle`)가 노출/실행할 수 있는 전체 운세 타입
- 목적: 모든 운세가 선택 → 설문/입력 → 비용 확인 → 실행 → 결과 렌더링/만족도 평가까지 끊기지 않는지 검증

## 1. 1차 소스 기반 검증 결과

- `fortuneTypeToResultKind`: 54개 타입
- 결과 메타데이터/렌더러 resultKind: 43개 / 43개
- 카탈로그 노출 운세: 48개
- 설문 직접 정의 + lotto alias: 44개
- poster-guide 비동기 운세: 7개 (beauty-simulation, blind-date-guide, face-reading-guide, hair-style-guide, ootd-guide, palm-reading, past-life-guide)
- 정적 매핑 오류: 없음
- 실행한 게이트:
  - `npm run rn:test` → 5 files / 20 tests passed
  - `npm run typecheck --workspace @fortune/mobile-rn` → passed
  - `npm run lint --workspace @fortune/mobile-rn` → 0 errors, 137 existing warnings

> 주의: 이 단계는 소스 매핑/컴파일 기반 검증입니다. 실제 Supabase Edge 성공률, 이미지 업로드 권한, 결제/토큰 DB 차감, 푸시 알림은 아래 실기기 E2E에서 별도 확인해야 합니다.

## 2. 전체 QA 매트릭스

| # | fortuneType | 표시명 | 비용 | 코드 | resultKind / 화면 | 실행 경로 | endpoint | 설문 |
|---:|---|---|---:|---|---|---|---|---|
| 1 | `tarot` | 오늘의 타로 | 5 | F18 | `tarot` / `OndoTarotResult` | 동기 Edge/LLM | `/fortune-tarot` | 있음 |
| 2 | `traditional-saju` | 전통 사주 | 12 | F01 | `traditional-saju` / `OndoTraditionalSajuResult` | 동기 Edge/LLM | `/fortune-traditional-saju` | 있음 |
| 3 | `daily` | 오늘의 운세 | 1 | F02 | `daily-calendar` / `OndoDailyCalendarResult` | 동기 Edge/LLM | `/fortune-daily` | 없음/특수 |
| 4 | `daily-calendar` | 오늘의 만세력 | 1 | F02 | `daily-calendar` / `OndoDailyCalendarResult` | 동기 Edge/LLM | `/fortune-time` | 있음 |
| 5 | `naming` | 사주 작명 | 12 | F30 | `naming` / `OndoNamingResult` | 동기 Edge/LLM | `/fortune-naming` | 있음 |
| 6 | `new-year` | 새해 인사이트 | 25 | F36 | `new-year` / `OndoNewYearResult` | 동기 Edge/LLM | `/fortune-new-year` | 있음 |
| 7 | `love` | 연애운 | 5 | F08 | `love` / `OndoLoveResult` | 동기 Edge/LLM | `/fortune-love` | 있음 |
| 8 | `compatibility` | 궁합 | 5 | F22 | `compatibility` / `OndoCompatibilityResult` | 동기 Edge/LLM | `/fortune-compatibility` | 있음 |
| 9 | `blind-date` | 소개팅운 | 5 | F23 | `blind-date` / `OndoBlindDateResult` | 동기 Edge/LLM | `/fortune-blind-date` | 있음 |
| 10 | `ex-lover` | 재회운 | 5 | F25 | `ex-lover` / `OndoExLoverResult` | 동기 Edge/LLM | `/fortune-ex-lover` | 있음 |
| 11 | `avoid-people` | 피해야 할 인연 | 5 | F24 | `avoid-people` / `OndoAvoidPeopleResult` | 동기 Edge/LLM | `/fortune-avoid-people` | 있음 |
| 12 | `yearly-encounter` | 올해의 인연 | 50 | F26 | `yearly-encounter` / `OndoYearlyEncounterResult` | 동기 Edge/LLM | `/fortune-yearly-encounter` | 있음 |
| 13 | `celebrity` | 셀럽 궁합 | 25 | F32 | `celebrity` / `OndoCelebrityResult` | 동기 Edge/LLM | `/fortune-celebrity` | 있음 |
| 14 | `blind-date-guide` | 소개팅 가이드 | 5 | F43 | `blind-date-guide` / `OndoPosterGuideResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 15 | `family` | 가족운 | 5 | F11 | `family` / `OndoFamilyResult` | 동기 Edge/LLM | `/fortune-{apiType}` | 있음 |
| 16 | `pet-compatibility` | 반려동물 궁합 | 5 | F33 | `pet-compatibility` / `OndoPetCompatibilityResult` | 동기 Edge/LLM | `/fortune-pet-compatibility` | 있음 |
| 17 | `career` | 직업운 | 5 | F07 | `career` / `OndoCareerResult` | 동기 Edge/LLM | `/fortune-career` | 있음 |
| 18 | `exam` | 시험운 | 5 | F21 | `exam` / `OndoExamResult` | 동기 Edge/LLM | `/fortune-exam` | 있음 |
| 19 | `talent` | 숨은 재능 | 12 | F16 | `talent` / `OndoTalentResult` | 동기 Edge/LLM | `/fortune-talent` | 있음 |
| 20 | `wealth` | 재물운 | 5 | F15 | `wealth` / `OndoWealthResult` | 동기 Edge/LLM | `/fortune-wealth` | 있음 |
| 21 | `moving` | 이사 인사이트 | 5 | F35 | `moving` / `OndoMovingResult` | 동기 Edge/LLM | `/fortune-moving` | 있음 |
| 22 | `lucky-items` | 행운 아이템 | 1 | F34 | `lucky-items` / `OndoLuckyItemsResult` | 동기 Edge/LLM | `/fortune-lucky-items` | 있음 |
| 23 | `ootd-evaluation` | OOTD 점검 | 5 | F20 | `ootd-evaluation` / `OndoOotdResult` | 동기 Edge/LLM | `/fortune-ootd` | 있음 |
| 24 | `fortune-cookie` | 포춘 쿠키 | 1 | F02 | `daily-calendar` / `OndoDailyCalendarResult` | 로컬/특수 | `-` | 없음/특수 |
| 25 | `birthstone` | 탄생석 | 1 | F31 | `birthstone` / `OndoBirthstoneResult` | 동기 Edge/LLM | `/fortune-birthstone` | 없음/특수 |
| 26 | `face-reading` | 관상 분석 | 5 | F29 | `face-reading` / `OndoFaceReadingResult` | 동기 Edge/LLM | `/fortune-face-reading` | 있음 |
| 27 | `palm-reading` | 손금 가이드 | 5 | F38 | `palm-reading` / `OndoPalmReadingResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 28 | `beauty-simulation` | 뷰티 시뮬 | 5 | F39 | `beauty-simulation` / `OndoPosterGuideResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 29 | `hair-style-guide` | 헤어 가이드 | 5 | F40 | `hair-style-guide` / `OndoPosterGuideResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 30 | `face-reading-guide` | 얼굴 인상 | 5 | F41 | `face-reading-guide` / `OndoPosterGuideResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 31 | `ootd-guide` | OOTD 가이드 | 5 | F42 | `ootd-guide` / `OndoPosterGuideResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 32 | `past-life-guide` | 전생 리포트 | 25 | F44 | `past-life-guide` / `OndoPosterGuideResult` | 비동기 큐(poster-guide) | `/generate-poster-guide` | 있음 |
| 33 | `wish` | 소원 부적 | 5 | F13 | `wish` / `OndoWishResult` | 로컬/특수 | `/analyze-wish` | 있음 |
| 34 | `health` | 건강 흐름 | 5 | F09 | `health` / `OndoHealthResult` | 동기 Edge/LLM | `/fortune-health` | 있음 |
| 35 | `biorhythm` | 바이오리듬 | 5 | F09 | `health` / `OndoHealthResult` | 동기 Edge/LLM | `/fortune-biorhythm` | 있음 |
| 36 | `exercise` | 운동 인사이트 | 5 | F17 | `exercise` / `OndoExerciseResult` | 동기 Edge/LLM | `/fortune-exercise` | 있음 |
| 37 | `match-insight` | 경기 인사이트 | 5 | F37 | `match-insight` / `OndoMatchInsightResult` | 동기 Edge/LLM | `/fortune-match-insight` | 있음 |
| 38 | `game-enhance` | 게임 인사이트 | 5 | F19 | `game-enhance` / `OndoGameEnhanceResult` | 동기 Edge/LLM | `/fortune-game-enhance` | 있음 |
| 39 | `breathing` | 호흡 · 명상 | 1 | F09 | `health` / `OndoHealthResult` | 로컬/특수 | `-` | 없음/특수 |
| 40 | `personality-dna` | 성격 분석 | 5 | F14 | `personality-dna` / `OndoPersonalityDnaResult` | 동기 Edge/LLM | `/personality-dna` | 있음 |
| 41 | `mbti` | MBTI 운세 | 1 | F03 | `mbti` / `OndoMbtiResult` | 동기 Edge/LLM | `/fortune-mbti` | 있음 |
| 42 | `blood-type` | 혈액형 | 1 | F04 | `blood-type` / `OndoBloodTypeResult` | 동기 Edge/LLM | `/fortune-blood-type` | 있음 |
| 43 | `zodiac-animal` | 띠별 운세 | 1 | F05 | `zodiac-animal` / `OndoZodiacAnimalResult` | 동기 Edge/LLM | `/fortune-zodiac-animal` | 없음/특수 |
| 44 | `coaching` | 코치 분석 | 5 | F10 | `coaching` / `OndoCoachingResult` | 동기 Edge/LLM | `/fortune-coaching` | 있음 |
| 45 | `daily-review` | 오늘의 회고 | 5 | F28 | `daily-review` / `OndoDailyReviewResult` | 로컬/특수 | `-` | 없음/특수 |
| 46 | `weekly-review` | 주간 회고 | 5 | F28 | `daily-review` / `OndoDailyReviewResult` | 로컬/특수 | `-` | 없음/특수 |
| 47 | `decision` | 의사결정 | 5 | F27 | `decision` / `OndoDecisionResult` | 로컬/특수 | `/fortune-decision` | 없음/특수 |
| 48 | `past-life` | 전생 이야기 | 50 | F12 | `past-life` / `OndoPastLifeResult` | 동기 Edge/LLM | `/fortune-past-life` | 있음 |
| 49 | `zodiac` | (카탈로그 미노출/별칭) | 1 | F05 | `zodiac-animal` / `OndoZodiacAnimalResult` | 동기 Edge/LLM | `/fortune-daily` | 없음/특수 |
| 50 | `constellation` | (카탈로그 미노출/별칭) | 1 | F05 | `zodiac-animal` / `OndoZodiacAnimalResult` | 동기 Edge/LLM | `/fortune-constellation` | 없음/특수 |
| 51 | `chat-insight` | (카탈로그 미노출/별칭) | 1 | F10 | `coaching` / `OndoCoachingResult` | 동기 Edge/LLM | `/fortune-chat-insight` | 있음 |
| 52 | `talisman` | (카탈로그 미노출/별칭) | 25 | F13 | `wish` / `OndoWishResult` | 동기 Edge/LLM | `/generate-talisman` | 있음 |
| 53 | `lotto` | (카탈로그 미노출/별칭) | 1 | F15 | `wealth` / `OndoWealthResult` | 로컬/특수 | `/fortune-lucky-lottery` | 있음 |
| 54 | `dream` | (카탈로그 미노출/별칭) | 1 | F18 | `tarot` / `OndoTarotResult` | 동기 Edge/LLM | `/fortune-dream` | 있음 |

## 3. 공통 E2E 시나리오

각 fortuneType마다 아래 항목을 체크한다.

1. 진입: 하늘이 채팅 → 전체 운세 시트/퀵액션에서 항목이 보이고 탭 가능하다.
2. 설문: 필요한 질문이 자연스럽게 표시되고 필수 입력 누락/조건부 질문(showWhen)이 막힘 없이 진행된다.
3. 비용 확인: 설문 완료 뒤 비용 확인 모달이 뜬다. 취소 시 Edge/queue 호출과 토큰 차감이 없어야 한다.
4. 실행: 확인 시 동기 Edge 또는 비동기 queue가 호출된다. 캐시 히트 케이스는 30분 TTL 내 같은 user/type/date에서 Edge 재호출이 없어야 한다.
5. 토큰: 성공/비동기 job 등록 뒤 정확한 비용이 차감된다. 부족 시 사용자 메시지와 무차감 보장이 필요하다.
6. 결과: embedded result 카드가 `resultKind`에 맞는 화면으로 렌더되고 fallback '등록되지 않은 결과 타입'이 나오면 실패다.
7. 만족도: 결과가 하늘이 말투/맥락과 맞고, 빈 섹션·placeholder·영문/JSON 노출·의학/투자 과잉단정이 없는지 평가한다.

## 4. 특수/위험 경로

- 이미지/비동기: `palm-reading`, `beauty-simulation`, `hair-style-guide`, `face-reading-guide`, `ootd-guide`, `blind-date-guide`, `past-life-guide`는 이미지 선택/권한 거절/queue placeholder/완료 알림/결과 재진입까지 확인.
- `face-reading`은 동기 vision 입력이므로 base64 이미지 payload와 5P 차감 확인.
- `fortune-cookie`, `breathing`, `daily-review`, `weekly-review`, `decision`은 로컬/특수 경로라 Edge 미호출 여부와 결과 카드 품질 확인.
- `blood-type`은 프로필 혈액형 존재 시 설문 skip/프리필 경로 확인.
- `mbti`는 프로필 MBTI 프리필로 질문 skip 여부 확인.
- `traditional-saju`는 사주 preview card와 birthDate 필수 누락 방어 확인.
- `lotto`, `zodiac`, `constellation`, `dream`, `chat-insight`, `talisman`, `biorhythm` 등은 다른 resultKind로 alias 렌더링되므로 제목/내용 mismatch 여부를 특히 확인.
- `family` endpoint는 `/fortune-{apiType}` 템플릿이므로 concern(children/health/wealth/relationship)별 endpoint/apiType 치환 확인.
- `tarot`은 selectedCards 매핑이 누락되면 400이 났던 이력 있음. 슬롯 선택 → selectedCards 생성 여부 확인.

## 5. 만족도 평가 기준(5점 척도)

- 실행 안정성: 오류/무한 로딩/중복 차감 없음
- 결과 완성도: 핵심 요약, 점수/타이밍/행동 팁이 충분함
- 개인화: 설문 답변·프로필·이미지 입력이 결과에 반영됨
- 하늘이 경험: 말투가 따뜻하고 과하지 않으며 채팅 흐름이 자연스러움
- 안전성: 건강/재물/관계 조언이 단정·위험 행동 유도 없이 표현됨

합격 기준: 각 운세 실행 안정성 Pass + 평균 만족도 4.0 이상. 3점 이하 항목은 UX/프롬프트 개선 이슈로 분리.

## 6. 실기기 실행 체크리스트

- [ ] 테스트 계정 로그인 및 토큰 잔액 충분/부족 계정 각각 준비
- [ ] 프로필 birthDate/birthTime/MBTI/bloodType 있는 계정과 없는 계정 준비
- [ ] 사진 권한 허용/거절 각각 테스트
- [ ] 각 운세 최초 실행 결과 스크린샷 저장
- [ ] 같은 운세 재실행으로 캐시/중복차감 확인
- [ ] 비동기 운세 long_running_jobs 생성/완료/알림/결과 로딩 확인
- [ ] 실패 케이스는 fortuneType, 입력값, 화면 녹화, Edge 로그, DB 차감 상태 기록