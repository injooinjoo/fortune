# 인사이트 데이터 흐름 분석

> 최종 업데이트: 2025.01.03
> 총 인사이트: 39개 (fortune Edge Functions 기준)

---

## 1. 개요

이 문서는 Fortune 앱의 모든 인사이트(운세) 기능에 대해 다음을 분석합니다:

1. **유저 입력** - Survey에서 수집하는 필드
2. **Edge Function** - API에 전달되는 필드
3. **LLM 응답** - API가 반환하는 필드
4. **결과 페이지** - UI에서 실제 사용하는 필드

### 범례

| 상태 | 의미 |
|------|------|
| ✅ | 정상 연동 (입력 → API → 결과 일치) |
| ⚠️ | 부분 불일치 (일부 필드 누락/미사용) |
| ❌ | 연동 안됨 또는 미구현 |
| 🔍 | 추가 확인 필요 |

---

## 2. 인사이트별 상세 분석

### 2.1 기본 인사이트 (6개)

#### fortune-daily (일일 인사이트) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | 없음 (설문 0단계) |
| **Edge Function 필수** | `userId`, `birthDate` |
| **Edge Function 선택** | `birthTime`, `gender`, `isPremium` |
| **응답** | `overall_score`, `summary`, `greeting`, `advice`, `caution`, `categories`, `lucky_items`, `lucky_numbers`, `personalActions`, `sajuInsight`, `celebrities_same_day` |
| **결과 페이지 사용** | 대부분 사용 |
| **미사용 필드** | `age_fortune`, `daily_predictions` |

---

#### fortune-career (커리어 인사이트) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `field`, `position`, `experience`, `concern` (4단계) |
| **Edge Function 필수** | `userId`, `birthDate`, `gender`, `careerField` |
| **Edge Function 선택** | `birthTime`, `currentPosition`, `goals`, `isPremium` |
| **응답** | `careerScore`, `nextStepsAdvice`, `skillsToFocus[]`, `careerPath`, `timelineAdvice`, `challenges` |
| **결과 페이지** | CareerCoachingResultPage |

**불일치 사항**:
- `field` → `careerField` 변환 필요
- `position` → `currentPosition` 변환 필요
- `concern` → `goals` 변환 필요

---

#### fortune-love (연애 인사이트) 🔍

| 단계 | 필드 |
|------|------|
| **Survey** | `gender`, `status`, `concern`, `datingStyle[]`, `idealLooks[]`, `idealPersonality[]` (6-7단계) |
| **Edge Function** | 🔍 fortune-love Edge Function 존재 여부 확인 필요 |
| **결과 페이지** | LoveFortuneResultPage |

**확인 필요**: Edge Function 매핑 확인 필요

---

#### fortune-talent (재능 인사이트) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `interest[]`, `workStyle`, `problemSolving` (3단계) |
| **Edge Function 필수** | `talentArea`, `currentSkills[]`, `goals`, `experience`, `timeAvailable`, `challenges[]` |
| **응답** | `overallScore`, `content`, `description`, `skillRecommendations[]`, `roadmap`, `challenges[]`, `advice` |
| **결과 페이지** | TalentFortuneResultsPage |

**🔴 심각한 불일치**:
- Survey에서 `experience` 수집 안함
- Survey에서 `timeAvailable` 수집 안함
- Survey에서 `challenges[]` 수집 안함
- `interest[]` → `talentArea` 변환 필요

---

#### fortune-mbti (MBTI 인사이트) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `mbtiConfirm`, `mbtiType?`, `category` (3단계) |
| **Edge Function 필수** | `mbti`, `name`, `birthDate` |
| **Edge Function 선택** | `userId`, `isPremium`, `category` |
| **응답** | `dimensions[]`, `overallScore`, `todayFortune`, `loveFortune`, `careerFortune`, `moneyFortune`, `healthFortune`, `luckyColor`, `luckyNumber`, `advice`, `compatibility[]` |
| **결과 페이지 사용** | 대부분 사용 |

---

#### tarot (타로) - 로컬 처리

| 단계 | 필드 |
|------|------|
| **Survey** | `purpose`, `selectedCards[]` (2단계) |
| **처리 방식** | 클라이언트 로컬 처리 |
| **비고** | Edge Function 없음, 카드 선택 + 해석 클라이언트에서 수행 |

---

### 2.2 시간 기반 (2개)

#### fortune-new-year (새해 인사이트) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `goal?` (1단계, 선택) |
| **Edge Function 필수** | `userId`, `birthDate`, `gender` |
| **Edge Function 선택** | `name`, `birthTime`, `isLunar`, `zodiacSign`, `zodiacAnimal`, `goal`, `goalLabel`, `isPremium` |
| **응답** | `overallScore`, `summary`, `content`, `greeting`, `goalFortune`, `monthlyHighlights[]`, `luckyItems`, `recommendations[]`, `percentile` |

---

#### fortune-time (시간 인사이트) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | 미정의 |
| **Edge Function 필수** | `userId`, `name`, `birthDate`, `gender` |
| **Edge Function 선택** | `birthTime`, `mbti`, `bloodType`, `zodiacSign`, `zodiacAnimal`, `userLocation`, `period`, `date`, `isPremium` |
| **응답** | `score`, `content`, `summary`, `advice`, `timeSlots[]`, `cautionTimes[]`, `cautionActivities[]` |

---

### 2.3 전통 분석 (3개)

#### fortune-traditional-saju (전통 사주) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `birthDateTime` 기반 |
| **Edge Function 필수** | `userId`, `birthDate`, `birthTime`, `gender` |
| **Edge Function 선택** | `isLunar`, `question` |
| **응답** | `question`, `sections`, `summary` |

---

#### fortune-face-reading (AI 관상) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `focus?`, `faceImage` (2단계) |
| **Edge Function 필수** | `image` (Base64) 또는 `instagram_url`, `userGender` |
| **Edge Function 선택** | `analysis_source`, `userName`, `userAgeGroup`, `isPremium`, `useV2` |
| **응답 (v2)** | `priorityInsights`, `overallScore`, `summaryMessage`, `faceCondition`, `emotionAnalysis`, `celebrityMatches`, `makeupRecommendations`, `leadershipAnalysis` |
| **결과 페이지** | FaceReadingResultPageV2 |

---

#### fortune-talisman (부적) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `purpose`, `situation?` (2단계) |
| **Edge Function 필수** | `userId` |
| **Edge Function 선택** | `talismType`, `purpose` |

**확인 필요**: `purpose`, `situation` → `talismType`, `purpose` 변환 로직

---

### 2.4 성격/개성 (2개)

#### fortune-biorhythm (바이오리듬) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `targetDate?` (1단계, 선택) |
| **Edge Function 필수** | `userId`, `birthDate` |
| **Edge Function 선택** | `birthTime`, `gender`, `isPremium` |
| **응답** | `physicalRhythm`, `emotionalRhythm`, `intellectualRhythm`, `score`, `days[]`, `advice` |
| **결과 페이지** | BiorhythmResultPage |

---

#### personalityDna (성격 DNA) - 로컬 처리

| 단계 | 필드 |
|------|------|
| **Survey** | 없음 (설문 0단계) |
| **처리 방식** | 생년월일 기반 로컬 계산 |
| **비고** | Edge Function 없음 |

---

### 2.5 연애/관계 (4개)

#### fortune-compatibility (궁합) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `inputMethod`, `partner`/`partnerName`/`partnerBirth`, `relationship` (5단계) |
| **Edge Function 필수** | `person1_name`, `person1_birth_date`, `person2_name`, `person2_birth_date` |
| **Edge Function 선택** | `fortune_type`, `isPremium` |
| **응답** | `overall_compatibility`, `score`, `personality_match`, `love_match`, `marriage_match`, `communication_match`, `strengths[]`, `cautions[]` |

---

#### fortune-avoid-people (경계 대상) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `situation` (1단계) |
| **Edge Function 필수** | `userId`, `birthDate`, `gender`, `concernArea` |
| **응답** | `overallScore`, `cautionPeople[]`, `cautionTraits[]`, `relationshipTips`, `avoidReasons`, `warnings` |

**확인 필요**: `situation` → `concernArea` 매핑 로직

---

#### fortune-ex-lover (재회 인사이트) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `primaryGoal`, `breakupTime`, `exPartnerName`, `exPartnerMbti`, `breakupInitiator`, `relationshipDepth`, `coreReason`, `detailedStory`, `currentState`, `contactStatus` 등 (11단계) |
| **Edge Function 필수** | `name`, `primaryGoal`, `time_since_breakup`, `breakup_initiator`, `breakup_detail`, `contact_status` |
| **Edge Function 선택** | `relationshipDepth`, `coreReason`, `currentState`, `ex_name`, `ex_mbti`, `isPremium` |
| **응답** | `hardTruth`, `reunionAssessment`, `emotionalPrescription`, `theirPerspective`, `strategicAdvice`, `newBeginning`, `milestones`, `closingMessage` |
| **결과 페이지** | ExLoverEmotionalResultPage |

**불일치**: Survey 필드명(camelCase) ≠ API 필드명(snake_case)

---

#### fortune-blind-date (소개팅) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `dateType`, `expectation`, `meetingTime`, `isFirstBlindDate`, `hasPartnerInfo`, `partnerPhoto?`, `partnerInstagram?` (7단계) |
| **Edge Function 필수** | `userId`, `name`, `birthDate`, `gender` |
| **Edge Function 선택** | `birthTime`, `mbti`, `preferredType`, `isPremium` |
| **응답** | `fortuneScore`, `matchPotential`, `firstImpressionTips`, `conversationStarters`, `warnings`, `luckElements` |

**🔴 심각한 불일치**: Survey 필드 대부분 API에 전달되지 않음
- `dateType` 미전달
- `expectation` 미전달
- `meetingTime` 미전달
- `isFirstBlindDate` 미전달
- `hasPartnerInfo` 미전달
- `partnerPhoto`, `partnerInstagram` 미전달

---

### 2.6 재물 (2개)

#### fortune-investment (투자) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `category`, `ticker`, `style?` (3단계) |
| **Edge Function 필수** | `tickers` (symbol, name, category)[] |
| **Edge Function 선택** | `userId`, `isPremium`, `sajuData` |
| **응답** | `overall_score`, `market_luck`, `ticker_analysis[]`, `best_investment_time`, `cautions[]`, `percentile` |
| **결과 페이지** | InvestmentFortuneResultPage |

**확인 필요**: `category`, `ticker` → `tickers[]` 변환 로직

---

#### fortune-lucky-items (행운 아이템) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `category?` (1단계, 선택) |
| **Edge Function 필수** | `userId`, `name`, `birthDate` |
| **Edge Function 선택** | `birthTime`, `gender`, `interests[]`, `isPremium` |
| **응답** | `title`, `summary`, `keyword`, `color`, `fashion[]`, `numbers[]`, `food[]`, `jewelry[]`, `material[]`, `direction`, `places[]`, `relationships[]` |

**확인 필요**: `category` → `interests[]` 매핑 로직

---

### 2.7 건강/스포츠 (3개)

#### fortune-health (건강) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `concern?`, `sleepQuality`, `exerciseFrequency`, `stressLevel`, `mealRegularity` (5단계) |
| **Edge Function 필수** | `current_condition`, `concerned_body_parts[]` |
| **Edge Function 선택** | `sleepQuality`, `exerciseFrequency`, `stressLevel`, `mealRegularity`, `hasChronicCondition`, `chronicCondition`, `isPremium`, `health_app_data` |
| **응답** | `overall_score`, `element_balance`, `weak_organs[]`, `recommendations`, `cautions[]`, `seasonal_advice`, `percentile` |

**🔴 심각한 불일치**:
- `current_condition` 필수지만 Survey에서 수집 안함
- `concern` → `concerned_body_parts[]` 변환 필요

---

#### fortune-match-insight (스포츠 경기) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `sport`, `match`, `favoriteTeam?` (3단계) |
| **Edge Function 필수** | `userId`, `sport`, `homeTeam`, `awayTeam`, `gameDate` |
| **Edge Function 선택** | `favoriteTeam`, `birthDate` |
| **응답** | `score`, `summary`, `content`, `advice`, `prediction`, `favoriteTeamAnalysis`, `opponentAnalysis`, `fortuneElements` |
| **결과 카드** | ChatMatchInsightCard |

**확인 필요**: `match` → `homeTeam`, `awayTeam`, `gameDate` 분해 로직

---

#### exercise (운동) - 로컬 처리

| 단계 | 필드 |
|------|------|
| **Survey** | `goal`, `intensity` (2단계) |
| **처리 방식** | 로컬 추천 알고리즘 |
| **비고** | Edge Function 없음 |

---

### 2.8 인터랙티브 (2개)

#### fortune-dream (꿈 해몽) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `dreamContent`, `emotion` (2단계) |
| **Edge Function 필수** | `dream` |
| **Edge Function 선택** | `inputType`, `date`, `isPremium` |
| **응답** | `dream`, `inputType`, `dreamType`, `interpretation`, `analysis`, `todayGuidance`, `psychologicalState`, `emotionalBalance`, `luckyKeywords[]`, `avoidKeywords[]`, `actionAdvice[]` |

**불일치**: `emotion` 필드 API 미전달

---

#### fortune-celebrity (유명인 궁합) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `celebrity`, `connectionType`, `interest?` (3단계) |
| **Edge Function 필수** | `userId`, `userBirthDate`, `userGender`, `celebrityName` |
| **Edge Function 선택** | `userBirthTime`, `isPremium` |
| **응답** | `compatibilityScore`, `summary`, `detailedAnalysis`, `strengths[]`, `challenges[]`, `advice` |

**불일치**: `connectionType`, `interest` API 미전달

---

### 2.9 가족/반려동물 (6개)

#### fortune-family-* (가족 운세 5종) ✅

| 종류 | 설명 |
|------|------|
| `fortune-family-relationship` | 가족 관계 |
| `fortune-family-health` | 가족 건강 |
| `fortune-family-wealth` | 가족 재물 |
| `fortune-family-children` | 자녀 |
| `fortune-family-change` | 가족 변화 |

**공통 필드**:

| 단계 | 필드 |
|------|------|
| **Survey** | `concern`, `detailedQuestions[]`, `familyMemberCount`, `relationship` (4단계) |
| **Edge Function 필수** | `userId`, `concern`, `concern_label`, `detailed_questions[]`, `family_member_count`, `relationship` |
| **Edge Function 선택** | `name`, `birthDate`, `birthTime`, `gender`, `special_question`, `isPremium`, `sajuData` |

**비고**: camelCase → snake_case 변환 적용

---

#### fortune-pet-compatibility (반려동물) ⚠️

| 단계 | 필드 |
|------|------|
| **Survey** | `pet`, `interest?` (2단계) |
| **Edge Function 필수** | `userId`, `petName`, `petType`, `ownerBirthDate` |
| **Edge Function 선택** | `petBirthDate`, `petGender`, `isPremium` |
| **응답** | `daily_condition`, `owner_bond`, `lucky_items`, `pets_voice`, `health_insight`, `recommendations[]`, `warnings[]` |

**확인 필요**: `pet` 객체에서 개별 필드 추출 로직

---

#### fortune-naming (작명) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | `motherBirth`, `expectedBirth`, `gender`, `familyName`, `nameStyle?` (4-5단계) |
| **Edge Function 필수** | `userId`, `motherBirthDate`, `expectedBirthDate`, `babyGender`, `familyName` |
| **Edge Function 선택** | `motherBirthTime`, `familyNameHanja`, `nameStyle`, `avoidSounds[]`, `desiredMeanings[]`, `isPremium` |
| **응답** | `fortuneType`, `ohaengAnalysis`, `recommendedNames[]`, `namingTips[]`, `warnings[]` |

---

### 2.10 기타 (5개)

#### fortune-past-life (전생) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | 미정의 |
| **Edge Function 필수** | `userId`, `name`, `birthDate`, `gender` |
| **Edge Function 선택** | `birthTime`, `isPremium` |
| **응답** | `portrait`, `pastLifeDesc`, `carryOver[]`, `lessonsLearned[]`, `currentMission`, `relatedCauses[]`, `advice` |
| **결과 카드** | ChatPastLifeResultCard |

---

#### fortune-moving (이사) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | 미정의 |
| **Edge Function 필수** | `current_area`, `target_area`, `purpose` |
| **Edge Function 선택** | `moving_period`, `isPremium` |
| **응답** | `overallScore`, `directionAnalysis`, `timingAdvice`, `areaCompatibility`, `warnings[]`, `recommendations[]`, `advice` |

---

#### fortune-home-fengshui (풍수) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | 미정의 |
| **Edge Function 필수** | `address` |
| **Edge Function 선택** | `home_type`, `floor`, `door_direction`, `isPremium` |
| **응답** | `title`, `score`, `overall_analysis`, `baesan_imsu`, `yangtaek_analysis`, `room_analysis`, `lucky_items[]`, `avoid_items[]`, `final_recommendations` |

---

#### fortune-ootd (OOTD) ✅

| 단계 | 필드 |
|------|------|
| **Survey** | 미정의 |
| **Edge Function 필수** | `userId`, `imageBase64`, `tpo` |
| **Edge Function 선택** | `userGender`, `userName` |
| **응답** | `overallScore`, `overallGrade`, `overallComment`, `tpoScore`, `tpoFeedback`, `categories`, `highlights[]`, `softSuggestions[]`, `recommendedItems[]`, `styleKeywords[]`, `celebrityMatch` |

---

#### fortune-premium-saju (프리미엄 사주) ✅

| 단계 | 필드 |
|------|------|
| **Edge Function 필수** | `userId`, `action` (initialize/get-status/get-result/generate-chapter/update-progress/add-bookmark/remove-bookmark) |
| **Edge Function 선택** | `transactionId`, `birthDate`, `birthTime`, `isLunar`, `gender`, `resultId`, `chapterIndex`, `readingProgress`, `bookmark` |
| **응답** | `generationStatus`, `chapters[]`, `overallProgress`, `readingProgress`, `bookmarks[]`, `totalPages` |
| **결과 페이지** | PremiumSajuReaderPage |

---

## 3. 로컬 처리 인사이트 (3개)

Edge Function 없이 클라이언트에서 직접 처리하는 인사이트:

| 인사이트 | 처리 방식 | 비고 |
|----------|----------|------|
| **tarot** | 클라이언트 카드 선택 + 해석 | TarotCardModel 사용 |
| **exercise** | 로컬 추천 알고리즘 | ExerciseFortuneModel 사용 |
| **personalityDna** | 생년월일 기반 로컬 계산 | PersonalityDnaFortuneConditions 사용 |

---

## 4. 발견된 문제점

### 4.1 심각한 필드 불일치 (🔴 높음)

| 인사이트 | 문제 | 영향 |
|----------|------|------|
| **fortune-talent** | Survey에서 `experience`, `timeAvailable`, `challenges[]` 수집 안함 | LLM 맞춤 응답 불가 |
| **fortune-blind-date** | Survey 필드 대부분 API에 미전달 | 수집한 정보 활용 안됨 |
| **fortune-health** | `current_condition` 필수지만 수집 안함 | API 호출 실패 가능성 |

### 4.2 중간 불일치 (🟡 중간)

| 인사이트 | 문제 |
|----------|------|
| **fortune-dream** | `emotion` 필드 API 미전달 |
| **fortune-celebrity** | `connectionType`, `interest` API 미전달 |
| **fortune-ex-lover** | 필드명 케이스 불일치 (camelCase vs snake_case) |

### 4.3 미사용 응답 필드

| 인사이트 | 미사용 필드 |
|----------|------------|
| fortune-daily | `age_fortune`, `daily_predictions` |
| FortuneResult (공통) | `totalTodayViewers`, `percentile` (일부만 사용) |

### 4.4 확인 필요

| 인사이트 | 상태 |
|----------|------|
| fortune-love | Edge Function 존재 여부 재확인 필요 |

---

## 5. 향후 개선 권고사항

### 5.1 즉시 수정 권고

1. **fortune-talent**: Survey에 누락된 필드 추가
   - `experience` (경력/경험)
   - `timeAvailable` (투자 가능 시간)
   - `challenges[]` (현재 어려움)

2. **fortune-blind-date**: Survey 필드 API 전달 로직 추가
   - `dateType`, `expectation`, `meetingTime` 등

3. **fortune-health**: `current_condition` Survey 단계 추가

### 5.2 개선 권고

1. **필드명 표준화**: camelCase 또는 snake_case 일관성 유지
2. **미사용 필드 정리**: API 응답에서 사용하지 않는 필드 제거 또는 UI 추가
3. **매핑 문서화**: Survey 필드 → API 필드 변환 로직 명시

### 5.3 문서화 유지

- 새 인사이트 추가 시 이 문서 업데이트
- 필드 변경 시 영향 분석 후 반영

---

## 부록: 인사이트 분류 요약

### API 연동 (33개)

| 카테고리 | 인사이트 |
|----------|----------|
| 기본 | daily, career, talent, mbti |
| 시간 | new-year, time |
| 전통 | traditional-saju, face-reading, talisman |
| 성격 | biorhythm |
| 연애 | compatibility, avoid-people, ex-lover, blind-date |
| 재물 | investment, lucky-items |
| 건강 | health, match-insight |
| 인터랙티브 | dream, celebrity |
| 가족 | family-relationship, family-health, family-wealth, family-children, family-change, pet-compatibility, naming |
| 기타 | past-life, moving, home-fengshui, ootd, premium-saju, recommend |

### 로컬 처리 (3개)

| 인사이트 | 처리 방식 |
|----------|----------|
| tarot | 클라이언트 카드 선택 + 해석 |
| exercise | 로컬 추천 알고리즘 |
| personalityDna | 생년월일 기반 로컬 계산 |