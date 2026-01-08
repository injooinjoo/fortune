# Fortune 에셋 테스트 가이드 (Asset Testing Guide)

이 문서는 Gemini 2.5 Flash를 통해 생성된 233개의 에셋들이 앱 내 어느 페이지와 상황에서 노출되는지 정리한 가이드입니다. 테스트 시 참조하여 각 데이터 조건에 맞게 이미지가 올바르게 로드되는지 확인하시기 바랍니다.

---

## 1. 히어로 배경 (Heroes)

- **위치**: 결과 페이지 최상단 `FortuneHeroSection`의 배경
- **결정 로직**: `FortuneType`과 `Score`(점수)에 따라 3단계로 구분됩니다.

| 운세 카테고리          | 점수 구간 | 파일명 (예시)                | 노출 상황                   |
| :--------------------- | :-------- | :--------------------------- | :-------------------------- |
| **공통 (Daily)**       | 70점 이상 | `daily_hero_sunny.webp`      | 매우 좋은 운세일 때 (맑음)  |
|                        | 40~69점   | `daily_hero_cloudy.webp`     | 평이한 운세일 때 (구름)     |
|                        | 40점 미만 | `daily_hero_stormy.webp`     | 주의가 필요한 때 (폭풍우)   |
| **연애 (Love)**        | 70점 이상 | `love_hero_blooming.webp`    | 꽃이 만개한 따뜻한 무드     |
|                        | 40점 미만 | `love_hero_waiting.webp`     | 기다림이 필요한 차분한 무드 |
| **재물/직장**          | 70점 이상 | `career_hero_promotion.webp` | 승진, 성공의 화려한 배경    |
|                        | 40점 미만 | `career_hero_challenge.webp` | 도전이 필요한 거친 배경     |
| **기타 (MBTI, 꿈 등)** | 각 점수별 | `mbti_hero_energy.webp` 등   | 각 테마별 성격에 맞는 배경  |

---

## 2. 마스코트 캐릭터 (Mascots)

- **위치**: 히어로 배경 위에 떠 있는 원형 캐릭터 (`FortuneHeroSection` 내)
- **결정 로직**: 점수 대별 감정 상태(Mood)에 따라 캐릭터가 교체됩니다.

| 카테고리               | 상태 (Mood)  | 파일명                     | 노출 조건                 |
| :--------------------- | :----------- | :------------------------- | :------------------------ |
| **전 카테고리**        | **Happy**    | `mascot_dog_celebrate.png` | 70점 이상: 축하하는 포즈  |
| (Daily 개 캐릭터 중심) | **Calm**     | `mascot_dog_main.png`      | 40~69점: 편안한 기본 포즈 |
|                        | **Thinking** | `mascot_dog_thinking.png`  | 40점 미만: 고민하는 포즈  |
|                        | **Sad**      | `mascot_dog_sad.png`       | 특정 불운 시나리오        |

---

## 3. 섹션 아이콘 (Section Icons)

- **위치**: 각 상세 운세 정보 카드(`SectionCard`)의 좌측 상단 아이콘
- **특징**: 붓 터치(Brush Stroke) 무드의 먹화 스타일

| 아이콘 키      | 파일명                      | 사용 섹션                |
| :------------- | :-------------------------- | :----------------------- |
| `work`         | `section_work.webp`         | 직장운, 커리어 상세      |
| `money`        | `section_money.webp`        | 재물운, 금전 섹션        |
| `health`       | `section_health.webp`       | 건강운, 생활 수칙        |
| `relationship` | `section_relationship.webp` | 대인관계, 연애 상세      |
| `warning`      | `section_warning.webp`      | 주의해야 할 점 (Warning) |
| `lucky`        | `section_lucky.webp`        | 행운의 포인트            |
| `advice`       | `section_advice.webp`       | 조언 및 가이드           |

---

## 4. 행운의 아이템 관련 (Lucky Icons)

- **위치**: `LuckyItemsRow` (행운의 컬러, 숫자, 방향 등 가로 리스트)

| 종류            | 경로 / 파일명                                | 노출 상황                                     |
| :-------------- | :------------------------------------------- | :-------------------------------------------- |
| **컬러**        | `icons/lucky/lucky_color_red.webp` 등        | 행운의 색상 추천 시 (12종)                    |
| **전통 아이템** | `items/lucky/korean/lucky_kr_norigae.png` 등 | 한국적 행운 아이템 추천 (복주머니, 노리개 등) |
| **일반 아이템** | `items/lucky/lucky_clover.png` 등            | 글로벌 행운 아이템 (클로버, 말편자 등)        |

---

## 5. 특수 카테고리 전용 (Special Categorized)

- **MBTI**: `mbti/characters/mbti_intj.png` 등 (16종 캐릭터) - MBTI 결과 확인 페이지
- **십이간지**: `zodiac/zodiac_rat.png` 등 (12종) - 띠별 운세 상세
- **오행(Saju)**: `saju/elements/element_wood.png` 등 (5종) - 사주 원소 분석 섹션
- **부적**: `talisman/talisman_wealth.png` 등 (4종) - 행운의 부적 발급 상황
- **반려동물**: `pets/pet_dog.png` 등 (10종) - 반려동물 궁합 결과

---

## 6. 테스트 방법 (How to Test)

1. **Developer Menu**에서 **Fortune Result Test** 진입.
2. **Fortune Type**을 변경 (예: `daily` -> `love` -> `career`).
3. **Score** 값을 슬라이더로 조절 (20점, 50점, 90점).
   - 히어로 배경과 마스코트가 동시에 바뀌는지 확인.
4. **Section Icon**이 깨지지 않고 먹화 느낌으로 잘 나오는지 확인.
5. **Dark Mode** 전환 시 투명 배경(`PNG`) 에셋들이 이질감 없이 보이는지 확인.

---

## 7. 에셋 수량 검증 (Checklist)

- [ ] Heroes: 40개 이상 (타입별 3종씩)
- [ ] Mascots: 20개 이상 (카테고리별 메인 캐릭터)
- [ ] Section Icons: 10개 (먹화 스타일)
- [ ] MBTI Characters: 16개
- [ ] Zodiac & Elements: 17개
- [ ] Lucky Items: 30개 이상
- [ ] Background Gradients: 15개 이상
