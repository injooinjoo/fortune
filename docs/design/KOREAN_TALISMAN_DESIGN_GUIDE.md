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

**작성일**: 2025-01-08
**버전**: 1.0.0
**작성자**: Fortune App Development Team
