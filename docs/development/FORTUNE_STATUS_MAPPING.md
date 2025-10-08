# 운세 개발 상태 매핑표

> **생성일**: 2025-01-08
> **목적**: 41개 운세 파일의 Edge Function 구현 상태 및 마이그레이션 상태 추적

---

## 📊 전체 통계

**총 운세 파일**: 41개
**Edge Function 존재**: 6개 (14.6%)
**BaseFortunePage 마이그레이션 완료**: 18개 (43.9%)

---

## 🎯 우선순위별 분류

### ✅ 완료 (Edge Function + BaseFortunePage) - 5개

| fortuneType | 파일명 | 비고 |
|-------------|--------|------|
| `avoid-people` | avoid_people_fortune_page.dart | 2025-01-08 완료 |
| `dream` | dream_fortune_page.dart | 기존 구현 |
| `face-reading` | face_reading_fortune_page.dart | 기존 구현 (구조 확인 필요) |
| `lucky-series` | lucky_series_fortune_page.dart | 기존 구현 (구조 확인 필요) |
| `mbti` | mbti_fortune_page.dart | 기존 구현 |

### 🚧 Edge Function 필요 (BaseFortunePage 완료) - 13개

**우선순위 HIGH** (사용자 입력 단순):
1. `birth-season` - birth_season_fortune_page.dart
2. `birthdate` - birthdate_fortune_page.dart
3. `blind-date` - blind_date_fortune_page.dart

**우선순위 MEDIUM**:
4. `career-change` - career_change_fortune_page.dart
5. `career-future` - career_future_fortune_page.dart
6. `career_seeker` - career_seeker_fortune_page.dart
7. `daily_calendar` - daily_calendar_fortune_page.dart
8. `esports` / `lucky-esports` - esports_fortune_page.dart
9. `freelance` - freelance_fortune_page.dart
10. `salpuli` - salpuli_fortune_page.dart
11. `startup-career` - startup_career_fortune_page.dart
12. `talent` - talent_fortune_page.dart
13. `tojeong` - tojeong_fortune_page.dart
14. `traditional-saju` - traditional_saju_fortune_page.dart

### 📝 마이그레이션 필요 (BaseFortunePage 미적용) - 18개

**기본 마이그레이션**:
- `ai-comprehensive` - ai_comprehensive_fortune_page.dart
- `destiny` - destiny_fortune_page.dart
- `employment` - employment_fortune_page.dart
- `five-blessings` - five_blessings_fortune_page.dart
- `influencer` - influencer_fortune_page.dart
- `lucky-investment` - lucky_investment_fortune_page.dart
- `lucky-job` - lucky_job_fortune_page.dart
- `lucky-outfit` - lucky_outfit_fortune_page.dart
- `lucky-sidejob` - lucky_sidejob_fortune_page.dart
- `lucky-stock` - lucky_stock_fortune_page.dart
- `network-report` - network_report_fortune_page.dart
- `palmistry` - palmistry_fortune_page.dart
- `politician` - politician_fortune_page.dart
- `saju-psychology` - saju_psychology_fortune_page.dart
- `same-birthday-celebrity` - same_birthday_celebrity_fortune_page.dart

**특수 케이스** (fortuneType 없음):
- batch_fortune_page.dart
- biorhythm_fortune_page.dart
- lucky_exam_fortune_page.dart
- talisman_fortune_page.dart
- wish_fortune_page.dart

**시스템 파일** (제외):
- base_fortune_page.dart (Base 클래스)
- dynamic_fortune_page.dart (동적 생성용)

---

## 📋 전체 상세 매핑표

| 번호 | 파일명 | fortuneType | Edge Function | Flutter 상태 | 우선순위 |
|------|--------|-------------|---------------|--------------|----------|
| 1 | `ai_comprehensive_fortune_page.dart` | `ai-comprehensive` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 2 | `avoid_people_fortune_page.dart` | `avoid-people` | ✅ 존재 | ✅ 완료 | ✅ DONE |
| 3 | `batch_fortune_page.dart` | N/A | N/A | ❓ 특수 케이스 | EXCLUDE |
| 4 | `biorhythm_fortune_page.dart` | N/A | N/A | ❓ 특수 케이스 | EXCLUDE |
| 5 | `birth_season_fortune_page.dart` | `birth-season` | ❌ 없음 | ✅ 완료 | **HIGH** |
| 6 | `birthdate_fortune_page.dart` | `birthdate` | ❌ 없음 | ✅ 완료 | **HIGH** |
| 7 | `blind_date_fortune_page.dart` | `blind-date` | ❌ 없음 | ✅ 완료 | **HIGH** |
| 8 | `career_change_fortune_page.dart` | `career-change` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 9 | `career_future_fortune_page.dart` | `career-future` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 10 | `career_seeker_fortune_page.dart` | `career_seeker` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 11 | `daily_calendar_fortune_page.dart` | `daily_calendar` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 12 | `destiny_fortune_page.dart` | `destiny` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 13 | `dream_fortune_page.dart` | `dream` | ✅ 존재 | ✅ 완료 | ✅ DONE |
| 14 | `employment_fortune_page.dart` | `employment` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 15 | `esports_fortune_page.dart` | `lucky-esports` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 16 | `face_reading_fortune_page.dart` | `face-reading` | ✅ 존재 | ❓ 구조 확인 | ✅ DONE? |
| 17 | `five_blessings_fortune_page.dart` | `five-blessings` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 18 | `freelance_fortune_page.dart` | `freelance` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 19 | `influencer_fortune_page.dart` | `influencer` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 20 | `lucky_exam_fortune_page.dart` | N/A | N/A | ❓ 특수 케이스 | EXCLUDE |
| 21 | `lucky_investment_fortune_page.dart` | `lucky-investment` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 22 | `lucky_job_fortune_page.dart` | `lucky-job` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 23 | `lucky_outfit_fortune_page.dart` | `lucky-outfit` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 24 | `lucky_series_fortune_page.dart` | `lucky-series` | ✅ 존재 | ❓ 구조 확인 | ✅ DONE? |
| 25 | `lucky_sidejob_fortune_page.dart` | `lucky-sidejob` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 26 | `lucky_stock_fortune_page.dart` | `lucky-stock` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 27 | `mbti_fortune_page.dart` | `mbti` | ✅ 존재 | ✅ 완료 | ✅ DONE |
| 28 | `network_report_fortune_page.dart` | `network-report` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 29 | `palmistry_fortune_page.dart` | `palmistry` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 30 | `politician_fortune_page.dart` | `politician` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 31 | `saju_psychology_fortune_page.dart` | `saju-psychology` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 32 | `salpuli_fortune_page.dart` | `salpuli` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 33 | `same_birthday_celebrity_fortune_page.dart` | `same-birthday-celebrity` | ❌ 없음 | ❓ 마이그레이션 필요 | LOW |
| 34 | `startup_career_fortune_page.dart` | `startup-career` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 35 | `talent_fortune_page.dart` | `talent` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 36 | `talisman_fortune_page.dart` | N/A | N/A | ❓ 특수 케이스 | EXCLUDE |
| 37 | `tojeong_fortune_page.dart` | `tojeong` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 38 | `traditional_saju_fortune_page.dart` | `traditional-saju` | ❌ 없음 | ✅ 완료 | MEDIUM |
| 39 | `wish_fortune_page.dart` | N/A | N/A | ❓ 특수 케이스 | EXCLUDE |
| 40 | `base_fortune_page.dart` | SYSTEM | SYSTEM | SYSTEM | EXCLUDE |
| 41 | `dynamic_fortune_page.dart` | SYSTEM | SYSTEM | SYSTEM | EXCLUDE |

---

## 🎯 다음 작업 추천 순서

### Phase 1: HIGH 우선순위 (3개)
1. `birth-season` Edge Function 개발
2. `birthdate` Edge Function 개발
3. `blind-date` Edge Function 개발

**예상 소요 시간**: 각 1-2시간, 총 3-6시간

### Phase 2: MEDIUM 우선순위 (11개)
4. `career-change`
5. `career-future`
6. `career_seeker`
7. `daily_calendar`
8. `esports` (lucky-esports)
9. `freelance`
10. `salpuli`
11. `startup-career`
12. `talent`
13. `tojeong`
14. `traditional-saju`

**예상 소요 시간**: 각 1-2시간, 총 11-22시간

### Phase 3: 마이그레이션 작업 (15개)
15. `ai-comprehensive`
16. `destiny`
17. `employment`
... (LOW 우선순위 전체)

**예상 소요 시간**: 각 2-3시간, 총 30-45시간

---

## 💡 작업 가이드

### 각 운세 개발 시 체크리스트
1. **Edge Function 개발** (1-1.5시간)
   - `supabase/functions/fortune-{타입}/index.ts` 작성
   - OpenAI Prompt 설계
   - 배포 및 테스트

2. **Flutter 마이그레이션** (0.5-1시간, 필요 시)
   - BaseFortunePage 상속
   - generateFortune() 구현
   - 커스텀 입력 UI 유지

3. **통합 테스트** (0.5시간)
   - 캐시 동작 확인
   - DB 저장 확인
   - 실제 디바이스 테스트

### 참고 문서
- [FORTUNE_API_DEVELOPMENT_CHECKLIST.md](./FORTUNE_API_DEVELOPMENT_CHECKLIST.md)

---

**마지막 업데이트**: 2025-01-08
**작성자**: Claude Code
