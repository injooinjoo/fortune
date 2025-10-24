import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { extractUsername, fetchInstagramProfileImage, downloadAndEncodeImage } from '../_shared/instagram/scraper.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const {
      image,
      instagram_url,
      analysis_source,
      include_fortune = true,
      userId,
      userName,
      userBirthDate,
      userBirthTime,
      userGender
    } = await req.json()

    console.log('📸 Face reading request received:', {
      hasImage: !!image,
      hasInstagramUrl: !!instagram_url,
      analysisSource: analysis_source,
      userId
    })

    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('face-reading')

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    let imageData: string | null = null

    // Handle different image sources
    if (analysis_source === 'instagram' && instagram_url) {
      console.log(`🔗 [FaceReading] Processing Instagram URL: ${instagram_url}`)

      try {
        // 1. Instagram URL에서 username 추출
        const username = extractUsername(instagram_url)
        console.log(`👤 [FaceReading] Extracted username: ${username}`)

        // 2. RapidAPI로 프로필 이미지 URL 가져오기
        const profileImageUrl = await fetchInstagramProfileImage(username)
        console.log(`✅ [FaceReading] Profile image URL: ${profileImageUrl}`)

        // 3. 이미지 다운로드 및 Base64 인코딩
        imageData = await downloadAndEncodeImage(profileImageUrl)
        console.log(`✅ [FaceReading] Image downloaded and encoded (${imageData.length} chars)`)
      } catch (error) {
        console.error(`❌ [FaceReading] Instagram processing error:`, error)
        throw new Error(`Instagram 프로필 이미지를 가져오는데 실패했습니다: ${error.message}`)
      }
    } else if (image) {
      imageData = image
      console.log(`✅ [FaceReading] Using directly uploaded image (${imageData.length} chars)`)
    }

    if (!imageData) {
      throw new Error('No image data provided')
    }

    // Create the face reading prompt
    const faceReadingPrompt = `당신은 한국의 전통 관상학 전문가입니다. 제공된 얼굴 사진을 분석하여 상세한 관상 분석과 운세를 제공해주세요.

사용자 정보:
- 이름: ${userName || '귀하'}
- 성별: ${userGender === 'male' ? '남성' : userGender === 'female' ? '여성' : '알 수 없음'}
${userBirthDate ? `- 생년월일: ${userBirthDate}` : ''}
${userBirthTime ? `- 생시: ${userBirthTime}` : ''}

다음 형식으로 관상 분석을 제공해주세요:

1. **전체적인 인상** (전반적인 얼굴 인상과 기운)
   - 첫인상과 전체적인 에너지
   - 얼굴형과 그 의미
   - 전반적인 복의 정도

2. **주요 부위별 분석**
   - 이마 (관록궁): 지혜, 학업운, 출세운
   - 눈썹 (형제궁): 인간관계, 형제운
   - 눈 (처자궁): 배우자운, 자녀운, 감정
   - 코 (재백궁): 재물운, 금전운
   - 입 (식록궁): 식복, 말복, 생활운
   - 턱 (노년궁): 노후운, 건강운
   - 귀 (복덕궁): 전반적인 복, 장수운
   - 광대뼈: 권력운, 리더십

3. **성격과 기질**
   - 타고난 성격 특성
   - 강점과 약점
   - 대인관계 스타일

4. **운세 분석**
   - 💰 재물운: 금전운과 사업운
   - ❤️ 애정운: 연애운과 결혼운
   - 💼 직업운: 적성과 성공 가능성
   - 🏥 건강운: 주의해야 할 건강 사항
   - 🍀 총운: 전반적인 행운도

5. **특별한 관상 특징**
   - 복이 많은 관상 포인트
   - 개선하면 좋을 점
   - 숨겨진 재능이나 가능성

6. **조언과 개운법**
   - 운을 높이는 방법
   - 피해야 할 것들
   - 행운의 색상, 방향, 숫자

모든 분석은 긍정적이고 희망적인 톤으로 작성하되, 구체적이고 개인화된 내용을 제공하세요.
전통 관상학의 지혜를 바탕으로 하되, 현대적인 해석을 가미하여 실용적인 조언을 제공하세요.`

    // ✅ LLM API 호출
    const response = await llm.generate([
      {
        role: "user",
        content: [
          { type: "text", text: faceReadingPrompt },
          {
            type: "image_url",
            image_url: {
              url: `data:image/jpeg;base64,${imageData}`,
              detail: "high"
            }
          }
        ]
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: false
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    const analysisResult = response.content

    if (!analysisResult) {
      throw new Error('Failed to generate face reading analysis')
    }

    // Parse the analysis result into structured format
    const sections = analysisResult.split(/\d+\.\s\*\*/).filter(s => s.trim())

    // Extract key information for the response
    const mainFortune = extractSection(analysisResult, '전체적인 인상') ||
                       '당신의 얼굴에서 밝은 기운이 느껴집니다.'

    const luckScore = Math.floor(Math.random() * 20) + 70 // 70-90 range

    // Extract different fortune categories
    const wealthFortune = extractSection(analysisResult, '재물운') ||
                         '재물운이 상승하는 시기입니다.'
    const loveFortune = extractSection(analysisResult, '애정운') ||
                       '인연이 다가오고 있습니다.'
    const healthFortune = extractSection(analysisResult, '건강운') ||
                         '건강 관리에 신경쓰면 좋은 결과가 있을 것입니다.'
    const careerFortune = extractSection(analysisResult, '직업운') ||
                         '새로운 기회가 찾아올 것입니다.'

    // Format the response
    const fortuneResponse = {
      fortuneType: 'face-reading',
      mainFortune: mainFortune,
      details: {
        face_type: extractFaceType(analysisResult),
        overall_fortune: mainFortune,
        personality: extractSection(analysisResult, '성격과 기질'),
        wealth_fortune: wealthFortune,
        love_fortune: loveFortune,
        health_fortune: healthFortune,
        career_fortune: careerFortune,
        special_features: extractSection(analysisResult, '특별한 관상 특징'),
        advice: extractSection(analysisResult, '조언과 개운법'),
        full_analysis: analysisResult
      },
      luckScore: luckScore,
      timestamp: new Date().toISOString()
    }

    // Save to database if user is logged in
    if (userId) {
      const { error: insertError } = await supabase
        .from('fortunes')
        .insert({
          user_id: userId,
          type: 'face-reading',
          result: fortuneResponse,
          metadata: {
            analysis_source,
            has_image: true
          }
        })

      if (insertError) {
        console.error('Error saving fortune:', insertError)
      }
    }

    return new Response(
      JSON.stringify(fortuneResponse),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )

  } catch (error) {
    console.error('Error in face-reading function:', error)

    return new Response(
      JSON.stringify({
        error: error.message || 'Failed to analyze face',
        details: error.toString()
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )
  }
})

// Helper function to extract sections from the analysis
function extractSection(text: string, sectionName: string): string | null {
  const regex = new RegExp(`${sectionName}[^:]*:([^\\n]+(?:\\n(?![\\d]+\\.|\\*\\*)[^\\n]+)*)`, 'i')
  const match = text.match(regex)
  if (match && match[1]) {
    return match[1].trim().replace(/^\s*[-•]\s*/, '')
  }

  // Try alternative format
  const altRegex = new RegExp(`\\*\\*${sectionName}\\*\\*[^:]*:?\\s*([^\\n]+)`, 'i')
  const altMatch = text.match(altRegex)
  if (altMatch && altMatch[1]) {
    return altMatch[1].trim()
  }

  return null
}

// Helper function to extract face type
function extractFaceType(text: string): string {
  const faceTypes = ['둥근형', '타원형', '각진형', '하트형', '긴형', '역삼각형']
  for (const type of faceTypes) {
    if (text.includes(type)) {
      return type + ' 얼굴'
    }
  }
  return '조화로운 얼굴형'
}