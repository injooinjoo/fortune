import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { OpenAIProvider } from '../_shared/llm/providers/openai.ts'

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface TalismanRequest {
  userId: string
  category: string
  characters: string[]
  animal: string
  pattern: string
}

interface TalismanPromptConfig {
  purpose: string
  mood: string
  colorIntensity: string
  animalDescription: string
  patternDescription: string
}

const CATEGORY_CONFIGS: Record<string, TalismanPromptConfig> = {
  disease_prevention: {
    purpose: 'disease prevention and healing',
    mood: 'powerful and protective',
    colorIntensity: 'bright cinnabar red (#D32F2F)',
    animalDescription: 'fierce tiger with three claws facing forward',
    patternDescription: 'spiral patterns representing life energy circulation',
  },
  love_relationship: {
    purpose: 'love and harmonious relationships',
    mood: 'gentle and romantic',
    colorIntensity: 'soft red (#EF5350)',
    animalDescription: 'mandarin ducks or butterflies symbolizing love',
    patternDescription: 'decorative knot patterns and heart shapes',
  },
  wealth_career: {
    purpose: 'wealth and career success',
    mood: 'prosperous and powerful',
    colorIntensity: 'bold red (#D32F2F) with gold accents',
    animalDescription: 'dragon with clouds and treasure pearl',
    patternDescription: 'staircase patterns symbolizing promotion',
  },
  disaster_removal: {
    purpose: 'protection from three disasters (fire, water, wind)',
    mood: 'powerful protective',
    colorIntensity: 'intense red (#B71C1C)',
    animalDescription: 'three-headed one-legged hawk',
    patternDescription: 'triangular repetitive patterns with eight trigrams',
  },
  home_protection: {
    purpose: 'home peace and family protection',
    mood: 'warm and protective',
    colorIntensity: 'guardian red (#D32F2F)',
    animalDescription: 'guardian tiger positioned as house protector',
    patternDescription: 'square patterns symbolizing home structure',
  },
  academic_success: {
    purpose: 'academic achievement and wisdom',
    mood: 'intellectual and ascending',
    colorIntensity: 'red with blue accents',
    animalDescription: 'eagle or crane with calligraphy brush',
    patternDescription: 'ascending staircase patterns',
  },
  health_longevity: {
    purpose: 'health and long life',
    mood: 'majestic and sacred',
    colorIntensity: 'red with gold highlights',
    animalDescription: 'crane and turtle symbolizing longevity',
    patternDescription: 'circular patterns representing completeness',
  },
}

function buildTalismanPrompt(config: TalismanPromptConfig, characters: string[]): string {
  return `Traditional Korean bujeok talisman for ${config.purpose},
painted on yellow hanji paper with cinnabar red ink,
featuring:
- Classical Chinese characters: ${characters.join(', ')}
- Animal symbol: ${config.animalDescription}
- Geometric patterns: ${config.patternDescription}
- Taoist/Buddhist symbols and esoteric diagrams
- Hand-drawn calligraphy with flowing brushstrokes
- Symmetrical composition with central focus
- Aged paper texture, traditional Korean shamanic art style
- Red seal stamp at bottom (artist signature)

Color scheme: Yellow background (#FFF4C4), ${config.colorIntensity}

Style: Authentic Korean folk art, detailed linework,
${config.mood} aesthetic, traditional color palette,
mystical atmosphere, hand-painted appearance

Negative prompt: modern fonts, digital text, 3D effects, photorealistic,
western calligraphy, Arabic numerals, English text,
anime style, cartoon style, overly saturated colors,
gradients, shadows, glossy effects

Aspect ratio: 2:3 (vertical), High resolution, 2000x2800px`
}

async function generateImageWithLLM(prompt: string): Promise<string> {
  console.log('🎨 Generating talisman image with LLM module...')
  console.log('📝 Prompt:', prompt)

  // OpenAI Provider 초기화
  const provider = new OpenAIProvider({
    apiKey: OPENAI_API_KEY,
    model: 'gpt-4o', // 텍스트 모델 (이미지 생성 시에는 dall-e-3 자동 사용)
  })

  // 이미지 생성
  const result = await provider.generateImage!(prompt, {
    size: '1024x1792', // 2:3 비율 (세로형)
    quality: 'standard',
    style: 'natural',
  })

  console.log('✅ Image generated successfully')
  console.log(`⏱️ Generation time: ${result.latency}ms`)
  if (result.revisedPrompt) {
    console.log('📝 Revised prompt:', result.revisedPrompt)
  }

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
): Promise<void> {
  console.log('💾 Saving talisman record to database...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { error } = await supabase.from('talisman_images').insert({
    user_id: userId,
    category,
    image_url: imageUrl,
    prompt_used: prompt,
    characters,
    created_at: new Date().toISOString(),
  })

  if (error) {
    console.error('❌ Database insert error:', error)
    throw new Error(`Database insert failed: ${error.message}`)
  }

  console.log('✅ Talisman record saved')
}

serve(async (req) => {
  try {
    const { userId, category, characters, animal, pattern }: TalismanRequest =
      await req.json()

    console.log('🔮 Talisman generation request:', { userId, category, characters })

    // Validate inputs
    if (!userId || !category || !characters || characters.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
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

    // Build prompt
    const prompt = buildTalismanPrompt(config, characters)

    // Generate image
    const imageBase64 = await generateImageWithLLM(prompt)

    // Upload to storage
    const imageUrl = await uploadToSupabase(imageBase64, userId, category)

    // Save to database
    await saveTalismanRecord(userId, category, imageUrl, prompt, characters)

    console.log('🎉 Talisman generation complete!')

    return new Response(
      JSON.stringify({
        success: true,
        imageUrl,
        category,
        characters,
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
