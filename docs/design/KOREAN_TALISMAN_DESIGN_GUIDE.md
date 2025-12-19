# 한국 전통 부적(符籍) 디자인 가이드

## 📚 학술 기반 부적 연구

### 부적의 정의
부적(符籍)은 **종이나 나무에 글씨, 그림, 기호 등을 그려 악귀를 쫓거나 복을 비는 주술적 도구**입니다.

### 학술 참고 자료
- **한국의 벽사부적** (김영자 저, 2014, 대원사)
- **한국민속대백과사전** - 국립민속박물관
- **영부대사전류** - 부적 분류 체계

---

## 🎨 부적의 구성 요소 (Design Components)

### 1. **색상 시스템 (Color Palette)**

#### 기본 색상
```yaml
background:
  - 황색 한지 (Yellow Hanji Paper)
  - 의미: 악귀 퇴치, 신성함
  - Hex: #FFF4C4, #F9E79F

ink_color:
  - 주사(朱砂, Cinnabar Red)
  - 의미: 생명력, 혈기, 신성한 보호
  - Hex: #D32F2F, #C62828, #B71C1C
  - 제작: 경면주사나 영사를 곱게 갈아 기름이나 설탕물에 개어서 사용
```

#### 보조 색상
```yaml
accent_colors:
  - 금색 (Gold): 신성함, 부귀
  - 검정 (Black): 윤곽선, 강조
  - 파란색 (Blue): 물, 하늘 (드물게 사용)
```

---

### 2. **한자 문자 (Chinese Characters)**

#### 핵심 문자 (Core Characters)
```
천(天) - Heaven, Sky
일월(日月) - Sun and Moon
광(光) - Light, Radiance
왕(王) - King, Ruler
금(金) - Gold, Metal
신(神) - Spirit, God
화(火) - Fire
수(水) - Water
용(龍) - Dragon
복(福) - Fortune, Blessing
수(壽) - Longevity
강(康) - Health
녕(寧) - Peace
```

#### 파자(破字) 기법
- **파자**: 한자를 해체하여 여러 가지로 재조합
- **예시**:
  - 福 → 示 + 畐
  - 壽 → 老 + 寸
- **특징**: 줄을 긋거나 기하학적 형태로 변형

---

### 3. **동물 상징 (Animal Symbols)**

#### 주요 동물
```yaml
tiger:
  name: 호랑이 (Tiger)
  meaning: 악귀 퇴치, 액운 제거
  usage: 벽사부(辟邪符)
  visual: 세 발가락, 과장된 얼굴, 강렬한 눈빛

dragon:
  name: 용 (Dragon)
  meaning: 권력, 물, 풍요
  usage: 관직부, 재산부
  visual: 구름과 함께, 비늘 패턴, 여의주

three_headed_hawk:
  name: 삼족오 (Three-legged One-headed Hawk)
  meaning: 삼재(三災) 방어 - 화재, 수재, 풍재
  usage: 삼재부적
  visual: 세 개의 다리, 날개 펼친 형태

bat:
  name: 박쥐 (Bat)
  meaning: 행운, 복
  usage: 길상부(吉祥符)
  visual: 좌우 대칭, 날개 펼침

eagle:
  name: 독수리 (Eagle)
  meaning: 권위, 보호
  usage: 수호부
  visual: 날카로운 부리, 강렬한 발톱
```

---

### 4. **기하학적 도형 (Geometric Patterns)**

#### 추상 패턴
```yaml
spiral_pattern:
  name: 와문형(渦紋形)
  meaning: 에너지 순환, 우주의 흐름
  visual: 소용돌이, 나선형

tower_pattern:
  name: 탑형
  meaning: 승천, 상승
  visual: 층층이 쌓인 삼각형 또는 사각형

stairs_pattern:
  name: 계단형
  meaning: 점진적 상승, 발전
  visual: 지그재그 계단 형태

circle_square:
  name: 원방각(圓方角)
  meaning: 천원지방(天圓地方) - 하늘은 둥글고 땅은 네모
  visual: 원과 사각형의 조합

eight_trigrams:
  name: 팔괘(八卦)
  meaning: 주역의 8가지 기본 괘
  visual: ☰☱☲☳☴☵☶☷
```

---

### 5. **레이아웃 구조 (Layout Structure)**

#### 전통적 구성 (Traditional Composition)
```
┌─────────────────────┐
│   ☰ 상단 신명 ☰   │  ← 신의 이름 또는 천문 기호
├─────────────────────┤
│                     │
│   [중심 주문자]     │  ← 핵심 한자, 주술 문구
│   [Main Mantra]     │
│                     │
├─────────────────────┤
│ 🐅 동물 상징 🐅     │  ← 호랑이, 용 등
├─────────────────────┤
│  기하학 패턴       │  ← 소용돌이, 계단형 등
├─────────────────────┤
│   작성자 낙관       │  ← 무당, 도사, 스님 서명
└─────────────────────┘
```

#### 대칭 구조 (Symmetrical Design)
- **좌우 대칭**: 균형, 조화
- **상하 대칭**: 천지 조응
- **중심 집중**: 핵심 주문을 중앙에 배치

---

## 🎭 부적의 종류별 분류

### 1. **벽사부(辟邪符)** - Evil-Warding Talismans

```yaml
disease_prevention:
  name: 질병부 (Disease Prevention Talisman)
  characters: 病退散, 藥神降臨
  animals: 호랑이
  colors: 적색 주도

spirit_protection:
  name: 귀신불침부 (Spirit Protection Talisman)
  characters: 神將守護, 鬼不侵
  animals: 용, 독수리
  patterns: 팔괘

disaster_removal:
  name: 삼재소멸부 (Disaster Removal Talisman)
  characters: 三災消滅
  animals: 삼족오
  patterns: 삼각형 반복
```

---

### 2. **길상부(吉祥符)** - Fortune-Bringing Talismans

```yaml
general_fortune:
  name: 만사대길부 (All Affairs Fortune Talisman)
  characters: 萬事大吉, 福祿壽康
  animals: 박쥐, 용
  patterns: 원형, 소용돌이

home_peace:
  name: 안택부 (Home Peace Talisman)
  characters: 家內平安, 安宅
  animals: 호랑이 (수호자)
  patterns: 사각형 (집 상징)

love_marriage:
  name: 부부애정부 (Love & Marriage Talisman)
  characters: 夫婦和合, 百年好合
  animals: 원앙새, 나비
  patterns: 하트형, 매듭

wealth_career:
  name: 관직재산부 (Career & Wealth Talisman)
  characters: 財祿豊盈, 官運亨通
  animals: 용
  patterns: 계단형 (승진), 금괴 형태
```

---

## 🤖 AI 이미지 생성 프롬프트 시스템

### Gemini Imagen 3 프롬프트 엔지니어링

#### PTCF 프레임워크 적용
```yaml
persona: "You are a traditional Korean shaman (mudang) specializing in creating authentic bujeok talismans"
task: "Generate a highly detailed Korean bujeok talisman image"
context: "[specific talisman type, purpose, and symbolism]"
format: "Digital artwork, 2000x2800px, vertical orientation, high resolution"
```

---

### 기본 프롬프트 템플릿

#### Template 1: 벽사부 (Evil-Warding)
```
Traditional Korean bujeok talisman for [PURPOSE],
painted on yellow hanji paper with cinnabar red ink,
featuring:
- Classical Chinese characters: [SPECIFIC CHARACTERS]
- Animal symbol: [TIGER/DRAGON/HAWK] in traditional Korean style
- Geometric patterns: [SPIRAL/TOWER/STAIRS] patterns
- Taoist/Buddhist symbols and esoteric diagrams
- Hand-drawn calligraphy with flowing brushstrokes
- Symmetrical composition with central focus
- Aged paper texture, traditional Korean shamanic art style
- Red seal stamp at bottom (artist signature)

Style: Authentic Korean folk art, detailed linework,
mystical atmosphere, traditional color palette (yellow, red, black, gold)
```

#### Template 2: 길상부 (Fortune-Bringing)
```
Korean bujeok fortune talisman for [BLESSING TYPE],
yellow paper background, vermillion red ink,
including:
- Auspicious characters: 福祿壽康 [ADDITIONAL CHARACTERS]
- [ANIMAL] symbol representing [MEANING]
- Decorative elements: [CLOUDS/FLOWERS/GEOMETRIC PATTERNS]
- Buddhist/Taoist mystical symbols
- Circular or symmetrical layout
- Intricate calligraphic details
- Traditional Korean shamanic design
- Gold accents on important elements

Artistic style: Traditional Korean talisman art,
spiritual and protective aesthetic,
detailed hand-painted appearance, authentic cultural symbolism
```

---

### 카테고리별 프롬프트 예시

#### 1. 질병 퇴치 부적 (Disease Prevention)
```
Korean bujeok talisman for disease prevention and healing,
yellow hanji paper, bright cinnabar red ink,
prominent characters: 病退散 (Disease Begone), 藥神降臨 (Medicine God Descends),
fierce tiger symbol with three claws facing forward,
geometric spiral patterns representing life energy circulation,
Taoist healing symbols and esoteric diagrams,
symmetrical composition with protective barrier design,
traditional Korean shamanic art,
mystical and powerful aesthetic,
hand-drawn calligraphy style, aged paper texture,
red seal stamp signature at bottom

Style: Authentic Korean folk talisman,
detailed traditional brushwork, protective and healing energy,
yellow (#FFF4C4) and red (#D32F2F) color scheme
```

#### 2. 사랑 성취 부적 (Love & Relationship)
```
Korean bujeok talisman for love and harmonious relationships,
soft yellow paper background, gentle red ink,
characters: 夫婦和合 (Marital Harmony), 百年好合 (100 Years Together),
mandarin ducks (원앙) or butterflies symbolizing love,
decorative knot patterns (매듭) and heart shapes,
flowing circular patterns representing connection,
Buddhist symbols for compassion and unity,
elegant and romantic composition,
traditional Korean talisman design,
delicate calligraphy with graceful strokes,
flowers and clouds as decorative elements,
red seal stamp at bottom

Style: Authentic Korean folk art,
gentle and loving aesthetic, traditional symbolism,
pastel yellow (#F9E79F) and soft red (#EF5350) palette
```

#### 3. 재물 운 부적 (Wealth & Prosperity)
```
Korean bujeok talisman for wealth and career success,
golden-yellow paper, bold cinnabar red ink,
prominent characters: 財祿豊盈 (Wealth Abundance), 官運亨通 (Career Success),
dragon symbol with clouds and treasure pearl (여의주),
staircase geometric patterns symbolizing promotion,
gold coin and ingot decorative elements,
Taoist prosperity symbols and lucky trigrams,
ascending composition representing upward movement,
traditional Korean shamanic design,
powerful and authoritative calligraphy,
gold metallic accents on key elements,
red seal stamp signature

Style: Authentic Korean talisman art,
prosperous and powerful aesthetic,
rich color scheme with yellow (#FFF4C4), red (#D32F2F), and gold
```

#### 4. 삼재 소멸 부적 (Three Disasters Removal)
```
Korean bujeok talisman for protection from three disasters (fire, water, wind),
pale yellow paper, intense red cinnabar ink,
characters: 三災消滅 (Three Disasters Eliminated),
three-headed one-legged hawk (삼족오) as central symbol,
triangular repetitive patterns representing stability,
eight trigrams (팔괘: ☰☱☲☳☴☵☶☷) surrounding design,
Taoist protective symbols and barrier formations,
strong symmetrical composition with protective circle,
traditional Korean shamanic art style,
bold and protective calligraphy,
mystical diagrams and esoteric symbols,
red seal stamp at bottom

Style: Authentic Korean folk talisman,
powerful protective aesthetic, traditional cultural symbolism,
classic yellow and red color palette
```

#### 5. 안택부 (Home Protection)
```
Korean bujeok talisman for home peace and family protection,
warm yellow hanji paper, vermillion red ink,
characters: 家內平安 (Family Peace), 安宅 (Safe Home),
guardian tiger positioned as house protector,
square and rectangular patterns symbolizing home structure,
four directions protective symbols (사방신: 青龍白虎朱雀玄武),
Taoist home blessing symbols,
architectural layout with central courtyard design,
traditional Korean shamanic talisman style,
protective and nurturing calligraphy,
decorative door and window motifs,
red seal stamp signature

Style: Authentic Korean folk art,
warm and protective aesthetic, traditional family symbolism,
cozy yellow (#F9E79F) and guardian red (#D32F2F) palette
```

---

## 🎯 프롬프트 최적화 가이드

### 1. **Iterative Refinement (반복 개선)**
```
Step 1: Generate 1-2 candidates (한번에 너무 많이 생성하지 않기)
Step 2: Inspect and evaluate (글씨 선명도, 동물 디테일, 색상 정확도)
Step 3: Isolate one variable (한 번에 하나씩 수정)
Step 4: Regenerate with constraints (구체적인 제약 조건 추가)
```

### 2. **텍스트 최적화**
- **글자 수 제한**: 한 번에 25자 이내 (가독성)
- **핵심 문구**: 2-3개 이하로 제한
- **배치**: 중앙 집중 또는 상하 배치

### 3. **스타일 일관성**
```yaml
consistent_elements:
  - Paper texture: "aged yellow hanji paper with subtle grain"
  - Ink quality: "hand-painted cinnabar red ink with varying thickness"
  - Brushwork: "traditional Korean calligraphy brushstrokes"
  - Composition: "symmetrical layout with central focus"
  - Seal: "red square seal stamp (낙관) at bottom corner"
```

### 4. **Negative Prompts (제외할 요소)**
```
Avoid: modern fonts, digital text, 3D effects, photorealistic textures,
western calligraphy, Arabic numerals, English text,
anime style, cartoon style, overly saturated colors,
gradients, shadows, glossy effects, metallic shine (except gold accents)
```

---

## 📊 카테고리별 프롬프트 매트릭스

| 부적 종류 | 핵심 한자 | 동물 상징 | 패턴 | 색상 강도 | 분위기 |
|----------|----------|-----------|------|----------|--------|
| 질병 퇴치 | 病退散, 藥神降臨 | 호랑이 | 소용돌이 | 진한 적색 | 강렬, 보호적 |
| 사랑 성취 | 夫婦和合, 百年好合 | 원앙, 나비 | 매듭, 하트 | 부드러운 적색 | 우아, 낭만적 |
| 재물 운 | 財祿豊盈, 官運亨通 | 용 | 계단형 | 금색 강조 | 권위, 상승 |
| 삼재 소멸 | 三災消滅 | 삼족오 | 삼각형 | 진한 적색 | 신비, 수호 |
| 안택 | 家內平安, 安宅 | 호랑이 | 사각형 | 따뜻한 적색 | 안정, 평화 |
| 학업 성취 | 及第及第, 文昌帝君 | 독수리, 붓 | 계단형 | 청색 강조 | 지성, 상승 |
| 건강 장수 | 無病長壽, 福祿壽 | 학, 거북이 | 원형 | 금색 강조 | 장엄, 신성 |

---

## 🛠️ 통합 시스템 설계

### Flutter 앱 통합 방안

#### 1. **이미지 생성 서비스 아키텍처**
```
User Request (부적 선택)
    ↓
Category Selection (질병/사랑/재물 등)
    ↓
Prompt Builder (프롬프트 자동 생성)
    ↓
Gemini Imagen 3 API Call
    ↓
Image Post-Processing (크기 조정, 워터마크)
    ↓
Display to User
```

#### 2. **프롬프트 빌더 로직**
```dart
class TalismanPromptBuilder {
  String buildPrompt({
    required TalismanCategory category,
    required List<String> characters,
    required AnimalSymbol animal,
    required GeometricPattern pattern,
  }) {
    return '''
Traditional Korean bujeok talisman for ${category.purpose},
yellow hanji paper, cinnabar red ink,
characters: ${characters.join(', ')},
animal symbol: ${animal.name} representing ${animal.meaning},
geometric patterns: ${pattern.description},
traditional Korean shamanic art style,
symmetrical composition, hand-drawn calligraphy,
red seal stamp at bottom

Style: Authentic Korean folk talisman,
${category.mood} aesthetic, detailed brushwork
''';
  }
}
```

#### 3. **Supabase Edge Function**
```typescript
// supabase/functions/generate-talisman/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

serve(async (req) => {
  const { category, characters, animal, pattern } = await req.json()

  // 1. Build prompt
  const prompt = buildTalismanPrompt({ category, characters, animal, pattern })

  // 2. Call Gemini Imagen 3 API
  const imageUrl = await generateImageWithGemini(prompt)

  // 3. Store in Supabase Storage
  const storedUrl = await uploadToSupabase(imageUrl, userId)

  return new Response(JSON.stringify({ imageUrl: storedUrl }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

---

## 📚 추가 학습 자료

### 학술 자료
1. **한국의 벽사부적** (김영자 저, 2014)
2. **한국민속대백과사전** - 부적 항목
3. **영부대사전류** - 부적 분류 체계
4. **국립민속박물관** 민속현장조사 자료

### 온라인 자료
- Korean Shamanism - Talismans and Amulets
- Asiancustoms.eu - Korean Talisman Paper Guide
- Arkeonews - Bujeok: Korea's Ancient Magic

### AI 이미지 생성 가이드
- Gemini Imagen 3 API Documentation
- Prompt Engineering Guide - Gemini
- DataCamp - Imagen 3 Tutorial

---

## ✅ 체크리스트

### 부적 디자인 검증
- [ ] 황색 한지 배경 사용
- [ ] 적색 주사 잉크 사용
- [ ] 핵심 한자 포함 (최소 2개)
- [ ] 동물 상징 배치
- [ ] 기하학 패턴 포함
- [ ] 좌우 대칭 또는 중앙 집중 구도
- [ ] 하단 낙관(적색 도장) 표시
- [ ] 전통적 서예체 사용
- [ ] 과도한 현대적 효과 제거
- [ ] 문화적 상징성 정확도 확인

### AI 프롬프트 검증
- [ ] PTCF 프레임워크 적용
- [ ] 구체적인 색상 코드 명시
- [ ] 동물과 패턴의 의미 설명
- [ ] 스타일 키워드 포함 (authentic, traditional)
- [ ] Negative prompts 명시
- [ ] 해상도 및 비율 지정
- [ ] 반복 개선 전략 수립

---

## 🎉 결론

이 가이드는 **학술 자료 기반**의 전통 한국 부적 디자인 원리와 **최신 AI 이미지 생성 기술**을 결합하여,
문화적 진정성을 유지하면서도 현대적인 방식으로 부적을 생성할 수 있는 시스템을 제공합니다.

**핵심 원칙**:
1. 전통 문화 존중 (황색 한지 + 적색 주사)
2. 상징 정확성 (한자, 동물, 패턴의 의미 일치)
3. AI 프롬프트 최적화 (PTCF 프레임워크)
4. 반복적 개선 (1-2개씩 생성하며 개선)

---

## 🎨 민화 (Minhwa) 에셋 시스템

### 개요

Fortune App은 **30개의 민화 에셋**을 통해 한국 전통 미학을 시각적으로 구현합니다.
모든 민화 에셋은 `assets/images/minhwa/` 디렉토리에 위치합니다.

> **디자인 철학**: 민화는 부적과 함께 한국 전통 시각 문화의 핵심입니다.
> 각 민화는 오행(五行) 사상과 길상(吉祥) 의미를 담고 있습니다.

---

### 카테고리별 에셋 카탈로그

#### 1. 전체운 (Overall Fortune) - 6개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_overall_dragon.png` | 용 (龍) | 권위, 성공, 행운 | 메인 운세, 총운 |
| `minhwa_overall_tiger.png` | 호랑이 (虎) | 액운 방지, 수호 | 오늘의 운세 |
| `minhwa_overall_phoenix.png` | 봉황 (鳳凰) | 고귀함, 상서로움 | 특별 운세 |
| `minhwa_overall_turtle.png` | 거북 (龜) | 장수, 지혜 | 주간/월간 운세 |
| `minhwa_overall_sunrise.png` | 일출 (日出) | 새로운 시작, 희망 | 신년 운세, 아침 |
| `minhwa_overall_moon.png` | 달 (月) | 음기, 직감, 여성성 | 야간, 명상 |

#### 2. 연애운 (Love Fortune) - 4개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_love_mandarin.png` | 원앙 (鴛鴦) | 부부 금슬, 영원한 사랑 | 궁합, 연애운 |
| `minhwa_love_butterfly.png` | 나비 (蝶) | 자유로운 사랑, 변화 | 싱글 운세 |
| `minhwa_love_magpie_bridge.png` | 까치다리 | 만남, 인연 | 소개팅, 짝운 |
| `minhwa_love_peony.png` | 모란 (牡丹) | 부귀, 아름다움 | 결혼운, 애정 |

#### 3. 재물운 (Wealth Fortune) - 4개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_money_carp.png` | 잉어 (鯉) | 출세, 성공, 등용문 | 재물운, 사업 |
| `minhwa_money_pig.png` | 돼지 (豚) | 복, 재물, 풍요 | 금전운 |
| `minhwa_money_toad.png` | 두꺼비 (蟾蜍) | 재물 수호, 부 축적 | 저축, 투자 |
| `minhwa_money_treasure.png` | 보물 (寶物) | 부귀영화 | 복권, 횡재 |

#### 4. 직장운 (Career Fortune) - 4개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_work_crane.png` | 학 (鶴) | 청렴, 고결, 승진 | 승진운, 직장 |
| `minhwa_work_eagle.png` | 독수리 (鷲) | 권위, 통찰력 | 리더십, 결단 |
| `minhwa_work_bamboo.png` | 대나무 (竹) | 절개, 성장 | 성장, 발전 |
| `minhwa_work_waterfall.png` | 폭포 (瀑布) | 도약, 등용문 | 이직, 도전 |

#### 5. 학업운 (Study Fortune) - 4개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_study_magpie.png` | 까치 (鵲) | 기쁜 소식, 합격 | 시험운, 합격 |
| `minhwa_study_owl.png` | 부엉이 (梟) | 지혜, 학문 | 학습, 연구 |
| `minhwa_study_brush.png` | 붓 (筆) | 문장력, 창작 | 글쓰기, 예술 |
| `minhwa_study_plum.png` | 매화 (梅) | 선비정신, 인내 | 수험, 공부 |

#### 6. 건강운 (Health Fortune) - 4개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_health_crane_turtle.png` | 학과 거북 | 십장생, 장수 | 건강운, 장수 |
| `minhwa_health_deer.png` | 사슴 (鹿) | 장수, 신선 | 활력, 회복 |
| `minhwa_health_pine.png` | 소나무 (松) | 불변, 장수 | 면역, 강건 |
| `minhwa_health_mountain.png` | 산 (山) | 안정, 튼튼함 | 체력, 지구력 |

#### 7. 사주운 (Saju Fortune) - 4개

| 파일명 | 상징 | 의미 | 사용 위치 |
|--------|------|------|----------|
| `minhwa_saju_dragon.png` | 용 | 양기, 권력 | 사주 분석 |
| `minhwa_saju_tiger_dragon.png` | 용호상박 | 음양 조화 | 궁합, 상성 |
| `minhwa_saju_fourguardians.png` | 사신도 (四神圖) | 사방 수호 | 사주 팔자 |
| `minhwa_saju_yin_yang.png` | 태극 (太極) | 음양 조화 | 오행, 기운 |

---

### 민화 사용 가이드

#### Flutter 코드 예시

```dart
// 1. 직접 에셋 참조
Image.asset('assets/images/minhwa/minhwa_overall_dragon.png')

// 2. 카테고리별 랜덤 선택
String getRandomMinhwa(String category) {
  final minhwaMap = {
    'overall': ['dragon', 'tiger', 'phoenix', 'turtle', 'sunrise', 'moon'],
    'love': ['mandarin', 'butterfly', 'magpie_bridge', 'peony'],
    'money': ['carp', 'pig', 'toad', 'treasure'],
    'work': ['crane', 'eagle', 'bamboo', 'waterfall'],
    'study': ['magpie', 'owl', 'brush', 'plum'],
    'health': ['crane_turtle', 'deer', 'pine', 'mountain'],
    'saju': ['dragon', 'tiger_dragon', 'fourguardians', 'yin_yang'],
  };

  final items = minhwaMap[category] ?? minhwaMap['overall']!;
  final random = items[Random().nextInt(items.length)];
  return 'assets/images/minhwa/minhwa_${category}_$random.png';
}

// 3. HanjiCard와 함께 사용
HanjiCard(
  style: HanjiCardStyle.scroll,
  colorScheme: HanjiColorScheme.fortune,
  child: Stack(
    children: [
      // 민화 배경
      Positioned.fill(
        child: Opacity(
          opacity: 0.15,
          child: Image.asset(
            'assets/images/minhwa/minhwa_overall_dragon.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      // 콘텐츠
      YourContent(),
    ],
  ),
)
```

#### 오방색과 민화 매핑

| 오행 | 민화 카테고리 | 대표 에셋 | 색상 |
|------|-------------|----------|------|
| 목(木) | work, study | 대나무, 매화 | 청색 (#1E3A5F) |
| 화(火) | love | 모란, 나비 | 적색 (#B91C1C) |
| 토(土) | money, overall | 잉어, 보물 | 황색 (#B8860B) |
| 금(金) | health | 학, 소나무 | 백색 (#F5F5DC) |
| 수(水) | saju | 태극, 거북 | 흑색 (#1C1C1C) |

---

### 민화 스타일 가이드

#### 시각적 특성

```yaml
visual_style:
  색조: 톤다운된 전통색 (muted traditional colors)
  선: 부드러운 붓터치 (soft brush strokes)
  구도: 좌우 대칭 또는 자연스러운 배치
  배경: 투명 또는 한지색 (미색 #F7F3E9)

opacity_guide:
  배경 장식: 10-20% (콘텐츠 가독성 유지)
  카드 아이콘: 80-100% (명확한 시각 요소)
  로딩 화면: 30-50% (시선 집중)

size_recommendations:
  아이콘: 48-64px
  카드 배경: 200-400px
  전체 화면: 원본 크기 유지
```

#### 다크모드 대응

```dart
// 민화 오버레이 투명도 조정
double getMinhwaOpacity(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? 0.08 : 0.15;  // 다크모드에서 더 투명하게
}

// 민화 색상 필터 (다크모드용)
ColorFilter? getMinhwaColorFilter(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (!isDark) return null;

  return ColorFilter.mode(
    Colors.white.withOpacity(0.1),
    BlendMode.overlay,
  );
}
```

---

### 민화 에셋 체크리스트

#### 품질 검증
- [ ] PNG 포맷, 투명 배경 지원
- [ ] 최소 해상도 1024px 이상
- [ ] 전통색 팔레트 준수
- [ ] 문화적 상징성 정확도 확인
- [ ] 라이트/다크 모드 호환성

#### 사용 검증
- [ ] HanjiCard와 통합 테스트
- [ ] 오방색 매핑 일관성
- [ ] 카테고리별 적절성
- [ ] 로딩 성능 최적화
- [ ] 메모리 사용량 확인

---

**작성일**: 2025-01-08
**버전**: 2.0.0 (민화 섹션 추가)
**작성자**: Fortune App Development Team
