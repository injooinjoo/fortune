/**
 * 전생 운세 (Past Life Fortune) Edge Function V2
 *
 * @description 사용자의 전생 신분, 스토리, AI 초상화를 생성합니다.
 * V2: 얼굴 분석 → NanoBanana 이미지 생성, 30개 시나리오, 챕터 구조
 *
 * @endpoint POST /fortune-past-life
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 생시 (선택)
 * - gender: string - 현재 성별
 * - isPremium?: boolean - 프리미엄 여부
 * - faceImageBase64?: string - 얼굴 사진 (Base64)
 * - useProfilePhoto?: boolean - 프로필 사진 사용 여부
 *
 * @response PastLifeFortuneResponse (with chapters)
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 신분 설정
interface StatusConfig {
  kr: string
  en: string
  desc: string
  clothing: string
  accessories: string
}

const STATUS_CONFIGS: Record<string, StatusConfig> = {
  king: {
    kr: '왕',
    en: 'King',
    desc: 'a royal Korean king',
    clothing: 'ceremonial dragon robes (곤룡포) with gold dragon embroidery, royal crown (익선관)',
    accessories: 'jade belt, royal seal, ceremonial fan',
  },
  queen: {
    kr: '왕비',
    en: 'Queen',
    desc: 'a Korean queen',
    clothing: 'royal court attire (적의) with phoenix patterns, elaborate headdress (적관)',
    accessories: 'jade ornaments, royal jewelry, ceremonial fan',
  },
  gisaeng: {
    kr: '기생',
    en: 'Gisaeng',
    desc: 'a talented gisaeng entertainer',
    clothing: 'elegant colorful hanbok with flowing sleeves, elaborate hairstyle with ornaments',
    accessories: 'gayageum strings, flower hairpins, jade earrings',
  },
  scholar: {
    kr: '선비',
    en: 'Scholar',
    desc: 'a Confucian scholar',
    clothing: 'scholarly robes (도포) in muted colors, traditional gat hat (갓)',
    accessories: 'calligraphy brush, books, jade pendant',
  },
  warrior: {
    kr: '장군',
    en: 'General',
    desc: 'a military general',
    clothing: 'traditional armor (갑옷) with helmet (투구), military robes',
    accessories: 'sword, bow, military insignia, commander flag',
  },
  farmer: {
    kr: '농부',
    en: 'Farmer',
    desc: 'a dignified farmer',
    clothing: 'simple but clean hanbok in earth tones, straw hat (삿갓)',
    accessories: 'farming tools, grain basket, simple pipe',
  },
  merchant: {
    kr: '상인',
    en: 'Merchant',
    desc: 'a wealthy merchant',
    clothing: 'fine silk hanbok with subtle patterns, merchant hat',
    accessories: 'abacus, money pouch, trading goods',
  },
  noble: {
    kr: '양반',
    en: 'Noble',
    desc: 'a yangban aristocrat',
    clothing: 'formal hanbok with ceremonial hat (사모), jade decorations',
    accessories: 'folding fan, jade belt ornament, scholarly items',
  },
  monk: {
    kr: '승려',
    en: 'Buddhist Monk',
    desc: 'a Buddhist monk',
    clothing: 'gray monk robes (승복), prayer beads, shaved head',
    accessories: 'Buddhist prayer beads (염주), sutra, wooden fish drum',
  },
  artisan: {
    kr: '장인',
    en: 'Master Artisan',
    desc: 'a master craftsman',
    clothing: 'practical working hanbok, craftsman apron',
    accessories: 'craft tools, finished artwork, materials of trade',
  },
  shaman: {
    kr: '무당',
    en: 'Shaman',
    desc: 'a spiritual shaman',
    clothing: 'colorful ceremonial dress (무복) with flowing ribbons, spirit crown',
    accessories: 'spirit bells, ritual knife, shamanic fan',
  },
  servant: {
    kr: '하인',
    en: 'Servant',
    desc: 'a loyal household servant',
    clothing: 'simple modest hanbok in muted colors',
    accessories: 'serving tray, household items',
  },
}

// =====================================================
// 조선시대 자화상 스타일 프롬프트 (직업/성별별)
// 국립중앙박물관 자화상 컬렉션 스타일 참조
// =====================================================
interface PortraitPromptTemplate {
  basePrompt: string
  styleDetails: string
}

const PORTRAIT_PROMPTS: Record<string, Record<string, PortraitPromptTemplate>> = {
  king: {
    male: {
      basePrompt: `Traditional Joseon dynasty royal portrait (어진, 御眞) of a Korean king.
Subject wears the iconic gold dragon robe (곤룡포) with five-clawed dragon embroidery,
익선관 (winged crown), and sits on a royal throne with dignified expression.`,
      styleDetails: `Reference: Joseon royal portraits like those of King Yeongjo and King Jeongjo.
Formal frontal pose, stern yet benevolent expression, hands hidden in sleeves.
Background: Simple golden or red palace screen.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty portrait of a Queen Regent (대비).
Subject wears ceremonial court attire with phoenix embroidery, elaborate headdress (족두리),
and displays dignified yet compassionate expression.`,
      styleDetails: `Reference: Portraits of Queen Jeongsun, Queen Munjeong.
Formal seated pose, elegant posture, serene expression.`,
    },
  },
  queen: {
    male: {
      basePrompt: `Traditional Joseon dynasty portrait of a royal consort prince.
Subject wears refined silk court robes with subtle dragon patterns, ceremonial hat,
displaying cultivated nobility.`,
      styleDetails: `Formal pose with graceful bearing, scholarly yet royal demeanor.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty Queen portrait (왕비 초상화).
Subject wears 적의 (red ceremonial robe) with phoenix patterns, 대수머리 hairstyle
with elaborate ornaments, showing queenly grace and authority.`,
      styleDetails: `Reference: Queen Inmok portrait style.
Formal seated pose, hands folded, serene and dignified expression.`,
    },
  },
  scholar: {
    male: {
      basePrompt: `Traditional Joseon dynasty Confucian scholar self-portrait (선비 자화상).
Subject wears white 도포 (scholar's robe) and black 갓 (traditional hat),
seated in contemplative pose with scholarly items nearby.`,
      styleDetails: `Reference: 윤두서 (Yun Duseo) self-portrait, 강세황 (Kang Sehwang) style.
Sharp, intelligent eyes, thin scholarly mustache, dignified expression.
Simple background: study room with books, ink stone, brush holder.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty portrait of a learned noblewoman.
Subject wears elegant 저고리 and 치마 in refined colors, hair in traditional married woman style,
displaying quiet intelligence and inner strength.`,
      styleDetails: `Reference: Shin Saimdang portrait style.
Graceful seated pose, contemplative expression, artistic items nearby.`,
    },
  },
  warrior: {
    male: {
      basePrompt: `Traditional Joseon dynasty military general portrait (장군 초상화).
Subject wears ceremonial armor (갑옷) or military official robes,
with commanding presence and fierce yet noble expression.`,
      styleDetails: `Reference: General Yi Sun-sin portrait style.
Strong jawline, determined eyes, upright military bearing.
May include sword or military insignia.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty portrait of a female warrior or military leader's wife.
Subject wears modified hanbok suitable for archery, hair tied back practically,
displaying brave and resolute expression.`,
      styleDetails: `Inspired by tales of heroic women like Nongae.
Determined expression, strong posture, subtle warrior elements.`,
    },
  },
  gisaeng: {
    male: {
      basePrompt: `Traditional Joseon dynasty portrait of a male performer/entertainer (광대).
Subject wears colorful performer's attire, may hold musical instrument,
displaying artistic charisma and expressive features.`,
      styleDetails: `Reference: Genre paintings of performers.
Expressive face, artistic temperament, theatrical elements.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty gisaeng portrait (기생 초상화).
Subject wears elegant colorful hanbok with flowing sleeves, elaborate 기생 hairstyle
with decorative hairpins, displaying beauty and artistic refinement.`,
      styleDetails: `Reference: Shin Yun-bok's beauty paintings (미인도).
Graceful pose, subtle smile, artistic elements like gayageum or fan.
Delicate features, expressive eyes, refined elegance.`,
    },
  },
  noble: {
    male: {
      basePrompt: `Traditional Joseon dynasty yangban aristocrat portrait (양반 초상화).
Subject wears formal 심의 or 도포 with jade decorations, traditional 갓 hat,
displaying cultured nobility and scholarly refinement.`,
      styleDetails: `Reference: Joseon aristocrat portraits.
Dignified bearing, refined features, intellectual expression.
May hold folding fan or scholarly item.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty noblewoman portrait (양반 부인 초상화).
Subject wears finest silk hanbok in elegant colors, elaborate married woman's hairstyle,
displaying grace, dignity, and noble bearing.`,
      styleDetails: `Reference: Noble family ancestral portraits.
Composed expression, graceful posture, refined accessories.`,
    },
  },
  monk: {
    male: {
      basePrompt: `Traditional Joseon dynasty Buddhist monk portrait (승려 초상화).
Subject wears gray 승복 (monk's robe), shaved head, prayer beads around neck,
displaying spiritual serenity and enlightened wisdom.`,
      styleDetails: `Reference: Buddhist patriarch portraits (조사도).
Calm, penetrating gaze, serene expression, meditative pose.
Simple background: temple setting or plain backdrop.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty Buddhist nun portrait (비구니 초상화).
Subject wears simple gray robes, shaved head, prayer beads,
displaying spiritual depth and compassionate wisdom.`,
      styleDetails: `Serene expression, peaceful demeanor, spiritual atmosphere.
Simple temple background.`,
    },
  },
  shaman: {
    male: {
      basePrompt: `Traditional Joseon dynasty male shaman portrait (무당/박수 초상화).
Subject wears ceremonial 무복 with colorful ribbons, spirit bells,
displaying mystical presence and spiritual power.`,
      styleDetails: `Intense, penetrating gaze, spiritual aura.
Ritual elements: drums, bells, ceremonial implements.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty female shaman portrait (무당 초상화).
Subject wears vibrant ceremonial dress (무복) with flowing ribbons and spirit crown,
displaying powerful spiritual presence and mystical charisma.`,
      styleDetails: `Reference: Shamanic ritual paintings.
Intense eyes, commanding presence, ritual elements.
Colorful ceremonial attire, spiritual implements.`,
    },
  },
  merchant: {
    male: {
      basePrompt: `Traditional Joseon dynasty wealthy merchant portrait (상인 초상화).
Subject wears fine silk hanbok showing prosperity, merchant's hat,
displaying shrewd intelligence and successful bearing.`,
      styleDetails: `Reference: Genre paintings of merchants.
Confident expression, prosperous appearance, trading elements.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty merchant's wife portrait.
Subject wears quality hanbok indicating family wealth,
displaying capable management skills and prosperous bearing.`,
      styleDetails: `Practical yet elegant appearance, confident expression.`,
    },
  },
  farmer: {
    male: {
      basePrompt: `Traditional Joseon dynasty dignified farmer portrait (농부 초상화).
Subject wears clean, simple hanbok in earth tones, may wear 삿갓 (straw hat),
displaying honest, hardworking character with weathered dignity.`,
      styleDetails: `Reference: Genre paintings of common people (풍속화).
Honest face, tanned skin, strong hands, dignified expression.
Simple agricultural background.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty farmer's wife portrait.
Subject wears practical cotton hanbok, hair tied for work,
displaying hardworking nature and resilient spirit.`,
      styleDetails: `Honest expression, strong features, practical attire.`,
    },
  },
  artisan: {
    male: {
      basePrompt: `Traditional Joseon dynasty master craftsman portrait (장인 초상화).
Subject wears working hanbok, may hold craft tools or finished work,
displaying skilled artisan's pride and dedicated craftsmanship.`,
      styleDetails: `Reference: Artisan genre paintings.
Focused expression, skilled hands, craft workshop setting.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty female artisan portrait.
Subject wears practical hanbok, engaged in traditional craft,
displaying artistic skill and dedicated focus.`,
      styleDetails: `Skilled hands, focused expression, craft elements.`,
    },
  },
  servant: {
    male: {
      basePrompt: `Traditional Joseon dynasty loyal servant portrait (하인 초상화).
Subject wears simple, clean hanbok in muted colors,
displaying humble dignity and loyal character.`,
      styleDetails: `Reference: Genre paintings of household servants.
Humble bearing, honest expression, simple attire.`,
    },
    female: {
      basePrompt: `Traditional Joseon dynasty female servant portrait.
Subject wears simple hanbok suitable for household work,
displaying modest dignity and hardworking nature.`,
      styleDetails: `Modest expression, practical attire, humble bearing.`,
    },
  },
}

// =====================================================
// 30개 전생 시나리오 (6 카테고리 × 5개)
// =====================================================
interface PastLifeScenario {
  id: string
  category: string
  status: string
  trait: string
  storySeed: string
  weight: number
}

const PAST_LIFE_SCENARIOS: PastLifeScenario[] = [
  // 1. 권력층 (Power Class) - 5 scenarios
  { id: 'king_wise', category: 'royalty', status: 'king', trait: '현명한', storySeed: '태평성대를 이끈', weight: 1 },
  { id: 'queen_influential', category: 'royalty', status: 'queen', trait: '영향력 있는', storySeed: '왕을 보좌한', weight: 1 },
  { id: 'prince_rebellious', category: 'royalty', status: 'noble', trait: '반골의', storySeed: '새 시대를 꿈꾼', weight: 2 },
  { id: 'princess_artistic', category: 'royalty', status: 'noble', trait: '예술적인', storySeed: '예술을 사랑한', weight: 2 },
  { id: 'regent_ambitious', category: 'royalty', status: 'noble', trait: '야심찬', storySeed: '권력을 향해 나아간', weight: 2 },

  // 2. 학문/문화 (Scholar/Culture) - 5 scenarios
  { id: 'scholar_philosopher', category: 'scholarly', status: 'scholar', trait: '철학적인', storySeed: '진리를 탐구한', weight: 10 },
  { id: 'scholar_rebel', category: 'scholarly', status: 'scholar', trait: '혁신적인', storySeed: '봉건 사회에 맞선', weight: 8 },
  { id: 'court_painter', category: 'scholarly', status: 'artisan', trait: '재능 있는', storySeed: '궁중화원의', weight: 5 },
  { id: 'calligrapher', category: 'scholarly', status: 'artisan', trait: '섬세한', storySeed: '명필로 알려진', weight: 5 },
  { id: 'poet_hermit', category: 'scholarly', status: 'scholar', trait: '은둔의', storySeed: '산속에 숨어 살던', weight: 7 },

  // 3. 예술/연예 (Art/Entertainment) - 5 scenarios
  { id: 'gisaeng_legendary', category: 'entertainment', status: 'gisaeng', trait: '전설적인', storySeed: '시대를 풍미한', weight: 6 },
  { id: 'gisaeng_spy', category: 'entertainment', status: 'gisaeng', trait: '이중의 삶을 산', storySeed: '정보를 모으던', weight: 4 },
  { id: 'musician_prodigy', category: 'entertainment', status: 'artisan', trait: '천재적인', storySeed: '신동으로 불린', weight: 5 },
  { id: 'dancer_court', category: 'entertainment', status: 'gisaeng', trait: '우아한', storySeed: '왕 앞에서 춤추던', weight: 5 },
  { id: 'storyteller', category: 'entertainment', status: 'artisan', trait: '구수한', storySeed: '전국을 떠돌던', weight: 8 },

  // 4. 무사/군인 (Warrior/Military) - 5 scenarios
  { id: 'general_heroic', category: 'military', status: 'warrior', trait: '영웅적인', storySeed: '나라를 구한', weight: 4 },
  { id: 'guard_loyal', category: 'military', status: 'warrior', trait: '충성스러운', storySeed: '왕을 호위하던', weight: 6 },
  { id: 'spy_covert', category: 'military', status: 'warrior', trait: '은밀한', storySeed: '그림자 속에서 활동한', weight: 4 },
  { id: 'archer_legendary', category: 'military', status: 'warrior', trait: '백발백중의', storySeed: '명궁으로 이름난', weight: 5 },
  { id: 'sailor_adventurous', category: 'military', status: 'merchant', trait: '모험적인', storySeed: '바다를 누빈', weight: 7 },

  // 5. 종교/신비 (Religious/Mystical) - 5 scenarios
  { id: 'monk_enlightened', category: 'spiritual', status: 'monk', trait: '깨달은', storySeed: '산사에서 수행하던', weight: 5 },
  { id: 'shaman_powerful', category: 'spiritual', status: 'shaman', trait: '영험한', storySeed: '신내림을 받은', weight: 4 },
  { id: 'fortune_teller', category: 'spiritual', status: 'shaman', trait: '예언의', storySeed: '미래를 내다본', weight: 4 },
  { id: 'healer_wise', category: 'spiritual', status: 'monk', trait: '지혜로운', storySeed: '약초로 병을 고친', weight: 6 },
  { id: 'mystic_wanderer', category: 'spiritual', status: 'monk', trait: '방랑의', storySeed: '팔도를 떠돌던', weight: 5 },

  // 6. 서민/상인 (Common/Merchant) - 5 scenarios
  { id: 'merchant_wealthy', category: 'common', status: 'merchant', trait: '거부의', storySeed: '한양 제일 갑부인', weight: 8 },
  { id: 'farmer_righteous', category: 'common', status: 'farmer', trait: '의로운', storySeed: '농민 봉기를 이끈', weight: 10 },
  { id: 'craftsman_master', category: 'common', status: 'artisan', trait: '장인의', storySeed: '나라에서 알아주던', weight: 10 },
  { id: 'servant_clever', category: 'common', status: 'servant', trait: '영특한', storySeed: '주인을 능가한', weight: 6 },
  { id: 'innkeeper_hospitable', category: 'common', status: 'merchant', trait: '인심 좋은', storySeed: '나그네를 품던', weight: 10 },
]

// 시나리오 가중치 기반 랜덤 선택
function selectRandomScenario(): PastLifeScenario {
  const totalWeight = PAST_LIFE_SCENARIOS.reduce((sum, s) => sum + s.weight, 0)
  let random = Math.random() * totalWeight

  for (const scenario of PAST_LIFE_SCENARIOS) {
    random -= scenario.weight
    if (random <= 0) return scenario
  }
  return PAST_LIFE_SCENARIOS[0]
}

// =====================================================
// 얼굴 특징 인터페이스
// =====================================================
interface FaceFeatures {
  faceShape: string       // 둥근/각진/갸름한/하트형
  eyes: { shape: string; size: string }
  eyebrows: { shape: string; thickness: string }
  nose: { bridge: string; tip: string }
  mouth: { size: string; lips: string }
  overallImpression: string[]
}

// 조선시대 시대 구분
const ERAS = ['조선 초기 (15세기)', '조선 중기 (16-17세기)', '조선 후기 (18-19세기)']

// 전생 이름 생성용 성씨와 이름
const SURNAMES = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임', '한', '신', '권', '황', '안']
const MALE_NAMES = ['학문', '도윤', '성현', '태호', '재민', '건우', '정민', '승호', '현우', '진석', '명수', '철수', '영호', '기현', '동혁']
const FEMALE_NAMES = ['설희', '채원', '민지', '수아', '은지', '소연', '하나', '지은', '영숙', '순희', '옥분', '춘화', '미연', '정아', '혜진']

function generateName(gender: string): string {
  const surname = SURNAMES[Math.floor(Math.random() * SURNAMES.length)]
  const names = gender === 'male' ? MALE_NAMES : FEMALE_NAMES
  const name = names[Math.floor(Math.random() * names.length)]
  return `${surname}${name}`
}

function selectRandomGender(): string {
  return Math.random() > 0.5 ? 'male' : 'female'
}

function selectRandomEra(): string {
  return ERAS[Math.floor(Math.random() * ERAS.length)]
}

/**
 * Gemini Vision으로 얼굴 특징 분석
 */
async function analyzeFaceWithVision(imageBase64: string): Promise<FaceFeatures | null> {
  console.log('👤 [PastLife] Analyzing face with Gemini Vision...')

  try {
    const llm = LLMFactory.createFromConfig('fortune-face-reading')

    const prompt = `Analyze this face photo and extract the following features in JSON format:

{
  "faceShape": "둥근" | "각진" | "갸름한" | "하트형" | "타원형",
  "eyes": { "shape": "둥근눈" | "고양이눈" | "처진눈" | "올라간눈", "size": "큰" | "보통" | "작은" },
  "eyebrows": { "shape": "일자" | "아치형" | "각진", "thickness": "굵은" | "보통" | "가는" },
  "nose": { "bridge": "높은" | "보통" | "낮은", "tip": "뾰족한" | "둥근" | "넓은" },
  "mouth": { "size": "큰" | "보통" | "작은", "lips": "도톰한" | "보통" | "얇은" },
  "overallImpression": ["형용사1", "형용사2", "형용사3"]
}

Important: Return ONLY valid JSON, no explanation. Use Korean for values.`

    const response = await llm.generate([
      { role: 'system', content: '당신은 얼굴 특징 분석 전문가입니다. JSON 형식으로만 응답하세요.' },
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${imageBase64}` } }
        ]
      },
    ])

    const jsonMatch = response.content.match(/\{[\s\S]*\}/)
    if (!jsonMatch) {
      console.log('⚠️ [PastLife] Failed to parse face features JSON')
      return null
    }

    const features = JSON.parse(jsonMatch[0]) as FaceFeatures
    console.log('✅ [PastLife] Face features analyzed:', JSON.stringify(features).substring(0, 100))
    return features
  } catch (error) {
    console.error('❌ [PastLife] Face analysis error:', error)
    return null
  }
}

/**
 * 얼굴 특징을 반영한 조선시대 초상화 프롬프트 생성
 * 직업/성별별 미리 정의된 템플릿 사용
 */
function buildPortraitPrompt(
  status: string,
  gender: string,
  era: string,
  scenario: PastLifeScenario,
  faceFeatures?: FaceFeatures | null
): string {
  // 미리 정의된 직업/성별 템플릿 가져오기
  const template = PORTRAIT_PROMPTS[status]?.[gender] ||
    PORTRAIT_PROMPTS[status]?.['male'] ||  // fallback to male if gender not found
    {
      basePrompt: `Traditional Joseon dynasty ${STATUS_CONFIGS[status]?.kr || '인물'} portrait.`,
      styleDetails: 'Reference: Traditional Korean ancestral portraits.',
    }

  const config = STATUS_CONFIGS[status]
  const genderKo = gender === 'male' ? '남성' : '여성'

  // 얼굴 특징 설명 생성 (사용자 사진 분석 결과)
  let faceDescription = ''
  if (faceFeatures) {
    faceDescription = `

=== CRITICAL: INCORPORATE USER'S FACIAL FEATURES ===
The portrait MUST reflect these specific facial characteristics from the user's photo:
- Face shape: ${faceFeatures.faceShape}
- Eyes: ${faceFeatures.eyes.shape}, ${faceFeatures.eyes.size} size
- Eyebrows: ${faceFeatures.eyebrows.shape}, ${faceFeatures.eyebrows.thickness}
- Nose: ${faceFeatures.nose.bridge} bridge, ${faceFeatures.nose.tip} tip
- Mouth: ${faceFeatures.mouth.size}, ${faceFeatures.mouth.lips} lips
- Overall impression: ${faceFeatures.overallImpression.join(', ')}

The subject should look like a JOSEON-ERA VERSION of the person with these features.
Blend the user's distinctive facial characteristics with traditional portrait aesthetics.`
  }

  return `=== JOSEON DYNASTY PORTRAIT GENERATION ===

${template.basePrompt}

Character: ${scenario.trait} 인물 (${scenario.storySeed})
Era: ${era}
Gender: ${genderKo}
${faceDescription}

${template.styleDetails}

=== UNIVERSAL STYLE REQUIREMENTS ===

Art Style:
- Traditional Korean portrait painting technique (초상화법/肖像畫法)
- Authentic Joseon dynasty aesthetic (NOT anime, NOT modern, NOT Western)
- Ink and mineral pigments on silk appearance
- Museum-quality traditional Korean art

Color Palette:
- Muted, aged colors: ochre, burnt sienna, indigo, black ink
- Natural mineral pigments look
- Subtle earth tones with occasional rich color accents
- Aged patina effect

Composition:
- Formal frontal or subtle 3/4 pose
- Dignified seated or standing posture
- Simple, minimal background (warm-toned or subtle atmospheric)
- 3:4 portrait orientation

Technical Details:
- Visible brushstroke texture
- Meticulous attention to clothing folds and fabric patterns
- Soft, diffused lighting
- Fine detail in facial features and accessories

=== DO NOT INCLUDE ===
- Modern elements or clothing
- Anime, manga, or cartoon style
- Bright saturated colors
- Western painting techniques
- Fantasy or supernatural elements
- Text, watermarks, or signatures
- Photorealistic or digital rendering
- AI-generated artifacts`
}

/**
 * Gemini로 조선시대 자화상 스타일 초상화 생성
 * Gemini 2.0 Flash의 이미지 생성 기능 사용
 */
async function generatePortraitWithGemini(prompt: string): Promise<string | null> {
  console.log('🎨 [PastLife] Generating portrait with Gemini...')
  const startTime = Date.now()

  if (!GEMINI_API_KEY) {
    console.log('⚠️ [PastLife] Gemini API key not configured, using fallback')
    return null
  }

  try {
    // Gemini 2.0 Flash Experimental 이미지 생성 모델 사용
    const imageModel = 'gemini-2.0-flash-exp-image-generation'

    const requestBody = {
      contents: [
        {
          role: 'user',
          parts: [{ text: prompt }],
        },
      ],
      generationConfig: {
        responseModalities: ['TEXT', 'IMAGE'],
      },
    }

    console.log('🔄 [PastLife] Calling Gemini Image Generation API...')
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${imageModel}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify(requestBody),
      }
    )

    console.log('✅ [PastLife] API call completed, status:', response.status)

    if (!response.ok) {
      const errorText = await response.text()
      console.error(`⚠️ [PastLife] Gemini Image API error: ${response.status} - ${errorText}`)
      return null
    }

    const data = await response.json()

    if (!data.candidates || data.candidates.length === 0) {
      console.error('⚠️ [PastLife] No candidates in Gemini Image response')
      return null
    }

    // 이미지 데이터 추출
    const parts = data.candidates[0].content?.parts || []
    const imagePart = parts.find((p: any) => p.inlineData?.mimeType?.startsWith('image/'))

    if (!imagePart || !imagePart.inlineData) {
      console.error('⚠️ [PastLife] No image data in Gemini response')
      // Text 응답도 로그
      const textPart = parts.find((p: any) => p.text)
      if (textPart) {
        console.log('ℹ️ [PastLife] Gemini text response:', textPart.text?.substring(0, 200))
      }
      return null
    }

    const latency = Date.now() - startTime
    console.log(`✅ [PastLife] Portrait generated in ${latency}ms`)

    return imagePart.inlineData.data
  } catch (error) {
    console.error('⚠️ [PastLife] Gemini image generation error:', error)
    return null
  }
}

/**
 * Supabase Storage에 이미지 업로드
 */
async function uploadPortraitToStorage(
  imageBase64: string,
  userId: string
): Promise<string> {
  console.log('📤 [PastLife] Uploading portrait to storage...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Base64를 Blob으로 변환
  const imageBuffer = Uint8Array.from(atob(imageBase64), (c) => c.charCodeAt(0))
  const fileName = `${userId}/past_life_${Date.now()}.png`

  const { data, error } = await supabase.storage
    .from('past-life-portraits')
    .upload(fileName, imageBuffer, {
      contentType: 'image/png',
      upsert: false,
    })

  if (error) {
    console.error('❌ [PastLife] Upload error:', error)
    throw new Error(`Upload failed: ${error.message}`)
  }

  const { data: publicUrlData } = supabase.storage
    .from('past-life-portraits')
    .getPublicUrl(fileName)

  console.log('✅ [PastLife] Portrait uploaded:', publicUrlData.publicUrl)
  return publicUrlData.publicUrl
}

/**
 * 스토리 챕터 인터페이스
 */
interface StoryChapter {
  title: string
  content: string
  emoji: string
}

/**
 * LLM으로 전생 스토리 생성 (챕터 구조)
 */
async function generatePastLifeStory(
  scenario: PastLifeScenario,
  statusKr: string,
  gender: string,
  era: string,
  name: string,
  userName: string,
  userBirthDate: string,
  faceFeatures?: FaceFeatures | null
): Promise<{
  story: string
  summary: string
  advice: string
  score: number
  chapters: StoryChapter[]
  llmResponse: any  // LLMResponse for usage logging
}> {
  console.log('📝 [PastLife] Generating story with chapters...')

  const llm = LLMFactory.createFromConfig('fortune-past-life')
  const genderKo = gender === 'male' ? '남성' : '여성'

  // 얼굴 특징 기반 성격 힌트
  let personalityHint = ''
  if (faceFeatures) {
    personalityHint = `
## 외모 기반 성격 힌트 (초상화에 반영된 특징)
- 얼굴형: ${faceFeatures.faceShape}
- 눈: ${faceFeatures.eyes.shape}, ${faceFeatures.eyes.size}
- 전체 인상: ${faceFeatures.overallImpression.join(', ')}
이 외모적 특징이 전생의 성격과 운명에 어떻게 반영되었는지 자연스럽게 포함해주세요.`
  }

  const prompt = `당신은 전생 운세 전문가입니다. 사용자의 전생 이야기를 챕터별로 생성해주세요.

## 사용자 정보
- 이름: ${userName}
- 생년월일: ${userBirthDate}

## 전생 정보
- 신분: ${statusKr} (${scenario.status})
- 성별: ${genderKo}
- 시대: ${era}
- 전생 이름: ${name}
- 시나리오: ${scenario.trait} 인물, ${scenario.storySeed}
- 카테고리: ${scenario.category}
${personalityHint}

## 작성 지침

### chapters (4개 챕터)
각 챕터는 80-120자로 작성. 몰입감 있는 스토리텔링.

1. **탄생과 유년 시절** (emoji: 👶)
   - 태어난 환경, 어린 시절 특별한 재능이나 사건

2. **이름을 알리다** (emoji: ⭐)
   - 성장 후 두각을 나타낸 사건, ${scenario.storySeed}와 연결

3. **시련과 극복** (emoji: ⚔️)
   - 인생의 가장 큰 시련과 이를 극복한 이야기

4. **남긴 유산** (emoji: 🌟)
   - 삶의 마무리, 후세에 남긴 영향

### summary (FREE 콘텐츠)
1-2문장의 핵심 요약. "당신의 전생은 ${scenario.trait} ${statusKr}이었습니다..." 형식.

### advice (BLUR 콘텐츠)
150-200자. 현생과의 연결점과 조언.

### score
1-100 사이. 신분별 기본 점수:
- 왕/왕비: 90-100
- 양반/선비/장군: 75-90
- 기생/상인/장인: 65-85
- 농부/하인: 60-80

## JSON 응답 형식
{
  "summary": "당신의 전생은...",
  "chapters": [
    { "title": "탄생과 유년 시절", "content": "...", "emoji": "👶" },
    { "title": "이름을 알리다", "content": "...", "emoji": "⭐" },
    { "title": "시련과 극복", "content": "...", "emoji": "⚔️" },
    { "title": "남긴 유산", "content": "...", "emoji": "🌟" }
  ],
  "advice": "현생과의 연결점...",
  "score": 85
}`

  const response = await llm.generate([
    { role: 'system', content: '전생 운세 전문가로서 JSON 형식으로 응답합니다. 감동적이고 몰입감 있는 이야기를 만들어주세요.' },
    { role: 'user', content: prompt },
  ])

  // JSON 파싱
  const content = response.content
  const jsonMatch = content.match(/\{[\s\S]*\}/)
  if (!jsonMatch) {
    throw new Error('Failed to parse LLM response as JSON')
  }

  const parsed = JSON.parse(jsonMatch[0])

  // story는 chapters를 합친 전체 이야기
  const fullStory = parsed.chapters
    .map((ch: StoryChapter) => `${ch.emoji} ${ch.title}\n${ch.content}`)
    .join('\n\n')

  return {
    story: fullStory,
    summary: parsed.summary || '',
    advice: parsed.advice || '',
    score: parsed.score || 75,
    chapters: parsed.chapters || [],
    llmResponse: response,  // Include LLMResponse for usage logging
  }
}

/**
 * 결과를 DB에 저장
 */
async function savePastLifeResult(
  userId: string,
  scenario: PastLifeScenario,
  statusKr: string,
  statusEn: string,
  gender: string,
  era: string,
  name: string,
  story: string,
  summary: string,
  portraitUrl: string,
  portraitPrompt: string,
  advice: string,
  score: number,
  chapters: StoryChapter[],
  faceFeatures?: FaceFeatures | null
): Promise<string> {
  console.log('💾 [PastLife] Saving result to database...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { data, error } = await supabase
    .from('past_life_results')
    .insert({
      user_id: userId,
      past_life_status: statusKr,
      past_life_status_en: statusEn,
      past_life_gender: gender,
      past_life_era: era,
      past_life_name: name,
      story_text: story,
      story_summary: summary,
      portrait_url: portraitUrl,
      portrait_prompt: portraitPrompt,
      advice: advice,
      score: score,
      // V2 추가 필드
      scenario_id: scenario.id,
      scenario_category: scenario.category,
      scenario_trait: scenario.trait,
      chapters: chapters,
      face_features: faceFeatures || null,
    })
    .select('id')
    .single()

  if (error) {
    console.error('❌ [PastLife] Database insert error:', error)
    throw new Error(`Database insert failed: ${error.message}`)
  }

  console.log('✅ [PastLife] Result saved, id:', data.id)
  return data.id
}

/**
 * 블러 처리 적용
 * FREE: summary, status, score
 * BLUR: chapters, advice, portrait (full quality)
 */
function applyBlurring(fortune: any, isPremium: boolean): any {
  if (isPremium) {
    return { ...fortune, isBlurred: false, blurredSections: [] }
  }

  return {
    ...fortune,
    isBlurred: true,
    blurredSections: ['chapters', 'advice', 'portrait_full'],
  }
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()

  try {
    const requestData = await req.json()
    const {
      userId,
      name: userName = '사용자',
      birthDate: userBirthDate,
      birthTime,
      gender: userGender,
      isPremium = false,
      // V2: 얼굴 이미지 관련
      faceImageBase64,
      useProfilePhoto = false,
    } = requestData

    console.log('🔮 [PastLife] V2 전생 운세 요청 시작')
    console.log(`   - 사용자: ${userName}`)
    console.log(`   - 생년월일: ${userBirthDate}`)
    console.log(`   - Premium: ${isPremium}`)
    console.log(`   - 얼굴 이미지: ${faceImageBase64 ? '있음' : '없음'}`)

    // 필수 필드 검증
    if (!userId || !userBirthDate) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, birthDate' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 1. 얼굴 분석 (이미지가 있는 경우)
    let faceFeatures: FaceFeatures | null = null
    if (faceImageBase64) {
      faceFeatures = await analyzeFaceWithVision(faceImageBase64)
    }

    // 2. 전생 시나리오 선택 (30개 중 랜덤)
    const scenario = selectRandomScenario()
    const statusConfig = STATUS_CONFIGS[scenario.status]
    const pastLifeGender = selectRandomGender()
    const pastLifeEra = selectRandomEra()
    const pastLifeName = generateName(pastLifeGender)

    console.log(`   - 시나리오: ${scenario.id} (${scenario.category})`)
    console.log(`   - 전생 신분: ${statusConfig.kr} (${scenario.status})`)
    console.log(`   - 특성: ${scenario.trait}, ${scenario.storySeed}`)
    console.log(`   - 전생 성별: ${pastLifeGender}`)
    console.log(`   - 전생 시대: ${pastLifeEra}`)
    console.log(`   - 전생 이름: ${pastLifeName}`)

    // 3. 초상화 프롬프트 생성 (얼굴 특징 포함)
    const portraitPrompt = buildPortraitPrompt(
      scenario.status,
      pastLifeGender,
      pastLifeEra,
      scenario,
      faceFeatures
    )

    // 4. Gemini로 조선시대 자화상 스타일 초상화 생성 (없으면 fallback)
    const imageBase64 = await generatePortraitWithGemini(portraitPrompt)

    // 5. Storage에 업로드 (이미지가 없으면 기본 이미지 사용)
    let portraitUrl: string
    if (imageBase64) {
      portraitUrl = await uploadPortraitToStorage(imageBase64, userId)
    } else {
      // Fallback: 신분별 기본 초상화 이미지
      const statusFallbacks: Record<string, string> = {
        king: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-king.jpg',
        queen: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-queen.jpg',
        gisaeng: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-gisaeng.jpg',
        scholar: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-scholar.jpg',
        warrior: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-warrior.jpg',
        noble: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-noble.jpg',
        merchant: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-merchant.jpg',
        farmer: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-farmer.jpg',
        monk: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-monk.jpg',
        artisan: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-artisan.jpg',
        shaman: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-shaman.jpg',
        servant: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-servant.jpg',
      }
      portraitUrl = statusFallbacks[scenario.status] ||
        'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-portrait.jpg'
      console.log(`📷 [PastLife] Using fallback portrait for ${scenario.status}`)
    }

    // 6. LLM으로 챕터 기반 스토리 생성
    const { story, summary, advice, score, chapters, llmResponse } = await generatePastLifeStory(
      scenario,
      statusConfig.kr,
      pastLifeGender,
      pastLifeEra,
      pastLifeName,
      userName,
      userBirthDate,
      faceFeatures
    )

    // 7. DB에 저장
    const recordId = await savePastLifeResult(
      userId,
      scenario,
      statusConfig.kr,
      statusConfig.en,
      pastLifeGender,
      pastLifeEra,
      pastLifeName,
      story,
      summary,
      portraitUrl,
      portraitPrompt,
      advice,
      score,
      chapters,
      faceFeatures
    )

    // 8. 응답 구성
    const fortune = {
      id: recordId,
      fortuneType: 'past-life',
      // 기본 정보
      pastLifeStatus: statusConfig.kr,
      pastLifeStatusEn: statusConfig.en,
      pastLifeGender: pastLifeGender,
      pastLifeEra: pastLifeEra,
      pastLifeName: pastLifeName,
      // 시나리오 정보
      scenarioId: scenario.id,
      scenarioCategory: scenario.category,
      scenarioTrait: scenario.trait,
      // 콘텐츠
      story: story,
      summary: summary,
      chapters: chapters,
      portraitUrl: portraitUrl,
      advice: advice,
      score: score,
      // 얼굴 특징 (있는 경우)
      faceFeatures: faceFeatures,
      timestamp: new Date().toISOString(),
    }

    // 블러 처리
    const processedFortune = applyBlurring(fortune, isPremium)

    // 사용량 로깅 - 올바른 패턴 (fortune-tarot 참조)
    UsageLogger.log({
      userId,
      fortuneType: 'past-life',
      provider: llmResponse.provider,
      model: llmResponse.model,
      response: llmResponse,
      metadata: {
        hasImage: !!faceImageBase64,
        hasFaceAnalysis: !!faceFeatures,
        isPremium,
        scenarioId: scenario.id,
        scenarioCategory: scenario.category,
      },
    }).catch(console.error)

    console.log(`🎉 [PastLife] V2 완료! 총 소요시간: ${Date.now() - startTime}ms`)

    return new Response(
      JSON.stringify({ fortune: processedFortune }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
      }
    )
  } catch (error) {
    console.error('❌ [PastLife] Error:', error)

    // 에러 로깅 - UsageLogger.logError 사용
    UsageLogger.logError(
      'past-life',
      'gemini',
      'gemini-2.0-flash',
      error instanceof Error ? error.message : 'Unknown error',
      undefined,
      { latencyMs: Date.now() - startTime }
    ).catch(console.error)

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
