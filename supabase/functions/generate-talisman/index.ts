import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { GeminiProvider } from '../_shared/llm/providers/gemini.ts'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface TalismanRequest {
  userId: string
  category: string
  characters?: string[] // 선택적 - 없으면 카테고리 기본값 사용
}

interface TalismanPromptConfig {
  purpose: string
  purposeKr: string
  mood: string
  colorIntensity: string
  animalSymbol: string
  geometricPattern: string
  specialElements: string
  defaultCharacters: string[]
}

// 카테고리별 전문적 부적 설정
const CATEGORY_CONFIGS: Record<string, TalismanPromptConfig> = {
  disease_prevention: {
    purpose: 'disease prevention and healing (질병 퇴치)',
    purposeKr: '질병 퇴치',
    mood: 'powerful protective energy, fierce guardian spirit',
    colorIntensity: 'deep cinnabar red (#D32F2F) with bold, confident strokes',
    animalSymbol: 'a fierce tiger (호랑이) with exaggerated claws and intense eyes, facing forward in guardian stance',
    geometricPattern: 'spiral vortex patterns (와문형) representing life energy circulation, radiating from center',
    specialElements: 'protective barrier circles, healing energy symbols',
    defaultCharacters: ['病退散', '藥神降臨'],
  },
  love_relationship: {
    purpose: 'love and harmonious relationships (부부화합)',
    purposeKr: '사랑 성취',
    mood: 'gentle romantic energy, tender connection',
    colorIntensity: 'soft rose-tinted red (#EF5350) with graceful, flowing strokes',
    animalSymbol: 'a pair of mandarin ducks (원앙) or butterflies facing each other, symbolizing eternal love',
    geometricPattern: 'decorative Korean knot patterns (매듭), intertwining circles representing union',
    specialElements: 'heart motifs, flower decorations, clouds',
    defaultCharacters: ['夫婦和合', '百年好合'],
  },
  wealth_career: {
    purpose: 'wealth abundance and career success (재물운)',
    purposeKr: '재물운',
    mood: 'prosperous authoritative energy, ascending fortune',
    colorIntensity: 'bold cinnabar red with gold accent highlights (#FFD700)',
    animalSymbol: 'a majestic dragon (용) with cloud swirls and a treasure pearl (여의주)',
    geometricPattern: 'staircase ascending patterns representing promotion, layered tower shapes',
    specialElements: 'coin motifs, treasure symbols, upward-pointing arrows',
    defaultCharacters: ['財祿豊盈', '官運亨通'],
  },
  disaster_removal: {
    purpose: 'protection from three disasters - fire, water, wind (삼재소멸)',
    purposeKr: '삼재 소멸',
    mood: 'intensely protective barrier energy, cosmic shield',
    colorIntensity: 'intense deep red (#B71C1C) with heavy, commanding strokes',
    animalSymbol: 'a three-legged crow/hawk (삼족오) with spread wings, representing solar power',
    geometricPattern: 'eight trigrams (팔괘) arranged in circle, triangular repetitive patterns',
    specialElements: 'protective circle barriers, cosmic diagrams, elemental symbols',
    defaultCharacters: ['三災消滅', '厄運退散'],
  },
  home_protection: {
    purpose: 'home peace and family protection (가내평안)',
    purposeKr: '안택',
    mood: 'warm nurturing protection, stable foundation',
    colorIntensity: 'warm guardian red (#E53935) with steady, confident strokes',
    animalSymbol: 'a guardian tiger positioned as house protector, watchful but calm',
    geometricPattern: 'square and rectangular patterns symbolizing home structure, stable foundations',
    specialElements: 'four directional guardians symbols, doorway motifs, roof patterns',
    defaultCharacters: ['家內平安', '安宅大吉'],
  },
  academic_success: {
    purpose: 'academic achievement and examination success (급제)',
    purposeKr: '학업 성취',
    mood: 'intellectual ascending energy, focused clarity',
    colorIntensity: 'red with blue accents (#1976D2 touches) representing wisdom',
    animalSymbol: 'a crane (학) or eagle with spread wings, holding a calligraphy brush',
    geometricPattern: 'ascending staircase patterns, layered tower shapes representing achievement',
    specialElements: 'book motifs, ascending clouds, scholarly symbols',
    defaultCharacters: ['及第及第', '文昌帝君'],
  },
  health_longevity: {
    purpose: 'health and long life (무병장수)',
    purposeKr: '건강 장수',
    mood: 'majestic sacred vitality, eternal blessing',
    colorIntensity: 'red with gold highlights, sacred golden accents',
    animalSymbol: 'a crane and turtle (학과 거북이) together, traditional longevity symbols',
    geometricPattern: 'circular endless patterns representing completeness and cycles of life',
    specialElements: 'peach motifs (longevity), pine trees, clouds of blessing',
    defaultCharacters: ['無病長壽', '福祿壽康'],
  },
}

/**
 * 전문적인 한국 전통 부적 프롬프트 생성
 * 파자(破字) 스타일 - 한문처럼 보이지만 한문이 아닌 신비로운 문양
 */
function buildTalismanPrompt(config: TalismanPromptConfig): string {
  return `A traditional Korean bujeok (부적) talisman, vertical portrait orientation (9:16 aspect ratio),
hand-painted on aged yellow hanji paper (rice paper) with cinnabar vermillion red ink.

The talisman features:
- **Central mystical symbols** that resemble deconstructed Chinese characters (파자 style)
  but are actually esoteric shamanic glyphs - not readable as standard Chinese.
  These should appear as broken, reconstructed character-like shapes with overlapping
  components, ancient seal script inspired forms, and abstract mystical symbol patterns.
- **${config.animalSymbol}** drawn in traditional Korean folk art style with bold brushstrokes
- **${config.geometricPattern}** arranged symmetrically around the central symbols
- A red square seal stamp (낙관) at the bottom corner
- ${config.specialElements}
- Taoist/Buddhist mystical diagrams and protective circles

Purpose: ${config.purpose}

Visual qualities:
- Visible brushstroke texture with varying ink thickness
- Aged yellow paper with subtle grain and slight imperfections (#FFF4C4 base color)
- ${config.colorIntensity}
- Hand-drawn calligraphy appearance, NOT computer-generated fonts
- Traditional Korean shamanic (무속) art aesthetic
- Symmetrical composition with central vertical axis
- Vertical format optimized for mobile phone display

Mood and atmosphere: ${config.mood}

Style: Authentic Korean folk talisman art, detailed traditional brushwork,
mystical protective aesthetic, hand-painted appearance on aged paper.

DO NOT include: modern fonts, digital text, readable Chinese characters,
3D effects, photorealistic textures, anime style, English text,
Arabic numerals, gradients, shadows, glossy effects, western calligraphy.`
}

async function generateImageWithGemini(prompt: string): Promise<string> {
  console.log('🎨 Generating talisman with Gemini...')

  const provider = new GeminiProvider({
    apiKey: GEMINI_API_KEY,
    model: 'gemini-2.0-flash-exp', // 텍스트 모델 (이미지 생성 시에는 자동 전환)
  })

  const result = await provider.generateImage!(prompt)

  console.log('✅ Image generated successfully')
  console.log(`⏱️ Generation time: ${result.latency}ms`)

  return result.imageBase64
}

async function uploadToSupabase(
  imageBase64: string,
  userId: string,
  category: string
): Promise<string> {
  console.log('📤 Uploading to Supabase Storage...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Convert base64 to blob
  const imageBuffer = Uint8Array.from(atob(imageBase64), (c) => c.charCodeAt(0))

  const fileName = `${userId}/${category}_${Date.now()}.png`

  const { data, error } = await supabase.storage
    .from('talisman-images')
    .upload(fileName, imageBuffer, {
      contentType: 'image/png',
      upsert: false,
    })

  if (error) {
    console.error('❌ Upload error:', error)
    throw new Error(`Upload failed: ${error.message}`)
  }

  const { data: publicUrlData } = supabase.storage
    .from('talisman-images')
    .getPublicUrl(fileName)

  console.log('✅ Upload successful:', publicUrlData.publicUrl)
  return publicUrlData.publicUrl
}

async function saveTalismanRecord(
  userId: string,
  category: string,
  imageUrl: string,
  prompt: string,
  characters: string[]
): Promise<string> {
  console.log('💾 Saving talisman record to database...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { data, error } = await supabase
    .from('talisman_images')
    .insert({
      user_id: userId,
      category,
      image_url: imageUrl,
      prompt_used: prompt,
      characters,
      is_public: true, // 공용 풀에 포함
      model_used: 'gemini-2.0-flash-exp-image-generation',
      created_at: new Date().toISOString(),
    })
    .select('id')
    .single()

  if (error) {
    console.error('❌ Database insert error:', error)
    throw new Error(`Database insert failed: ${error.message}`)
  }

  console.log('✅ Talisman record saved, id:', data.id)
  return data.id
}

serve(async (req) => {
  try {
    const { userId, category, characters }: TalismanRequest = await req.json()

    console.log('🔮 Talisman generation request:', { userId, category })

    // Validate inputs
    if (!userId || !category) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, category' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Get category config
    const config = CATEGORY_CONFIGS[category]
    if (!config) {
      return new Response(
        JSON.stringify({ error: `Invalid category: ${category}` }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // 문자는 사용하지 않음 (파자 스타일로 자동 생성)
    const usedCharacters = characters || config.defaultCharacters

    // Build prompt
    const prompt = buildTalismanPrompt(config)

    // Generate image with Gemini
    const imageBase64 = await generateImageWithGemini(prompt)

    // Upload to storage
    const imageUrl = await uploadToSupabase(imageBase64, userId, category)

    // Save to database and get ID
    const recordId = await saveTalismanRecord(
      userId,
      category,
      imageUrl,
      prompt,
      usedCharacters
    )

    console.log('🎉 Talisman generation complete!')

    return new Response(
      JSON.stringify({
        success: true,
        id: recordId,
        imageUrl,
        category,
        characters: usedCharacters,
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    console.error('❌ Error generating talisman:', error)

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
