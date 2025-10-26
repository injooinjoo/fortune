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
    // ✅ 요청 파싱 (한 번만!)
    const requestBody = await req.json()

    console.log('📸 [DEBUG] Face reading request received:', {
      requestKeys: Object.keys(requestBody),
      hasImage: !!requestBody.image,
      imageLength: requestBody.image?.length || 0,
      hasInstagramUrl: !!requestBody.instagram_url,
      analysisSource: requestBody.analysis_source,
      userId: requestBody.userId,
      isPremium: requestBody.isPremium
    })

    const {
      image,
      instagram_url,
      analysis_source,
      include_fortune = true,
      userId,
      userName,
      userBirthDate,
      userBirthTime,
      userGender,
      isPremium = false
    } = requestBody

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

    // Create the face reading prompt - 상세하고 전문적인 프롬프트
    const faceReadingPrompt = `당신은 30년 경력의 한국 전통 관상학 최고 전문가입니다.
동양 관상학의 12궁위론과 삼정론을 정확히 이해하고 있으며, 수천 명의 관상을 분석한 경험이 있습니다.

# 사용자 정보
- 이름: ${userName || '귀하'}
- 성별: ${userGender === 'male' ? '남성' : userGender === 'female' ? '여성' : '알 수 없음'}
${userBirthDate ? `- 생년월일: ${userBirthDate}` : ''}
${userBirthTime ? `- 생시: ${userBirthTime}` : ''}

# 분석 지침
제공된 얼굴 사진을 매우 상세하게 분석하여, 아래 형식을 정확히 따라 전문적인 관상 분석을 제공하세요.

## 1. 전체적인 인상 (3-5문장, 구체적으로)
얼굴의 전반적인 인상과 기운을 분석하세요:
- 첫인상과 전체적인 에너지 (밝은지, 차분한지, 강한지 등)
- 얼굴형 분류 (타원형/둥근형/각진형/역삼각형/긴형/하트형 중 택1) 및 그 의미
- 삼정(상정/중정/하정)의 균형과 복의 정도 (70-95점 사이로 평가)
- 전반적인 운의 흐름 (상승/안정/변동 등)

## 2. 12궁위 상세 분석 (각 부위마다 2-3문장씩 작성)
각 부위를 실제로 사진에서 관찰하여 구체적으로 분석하세요:

### 이마 (관록궁 - 사회적 성공운)
- 넓이, 높이, 빛깔, 주름 등을 관찰
- 지혜, 학업운, 출세운, 리더십 평가
- 구체적인 조언 (예: "이마가 넓고 밝아 학업과 출세에 유리합니다")

### 눈썹 (형제궁 - 인간관계)
- 모양, 굵기, 길이, 눈과의 거리를 관찰
- 형제운, 친구운, 인덕 평가
- 구체적인 조언 (예: "눈썹이 짙고 힘이 있어 주변의 도움을 많이 받습니다")

### 눈 (처자궁 - 배우자/자녀운)
- 크기, 모양, 눈빛, 쌍꺼풀 유무를 관찰
- 배우자운, 자녀운, 감정 표현 방식 평가
- 구체적인 조언 (예: "눈이 크고 맑아 좋은 배우자를 만날 인연이 있습니다")

### 코 (재백궁 - 재물운)
- 높이, 모양, 콧구멍 크기, 준두(코끝) 상태를 관찰
- 금전운, 사업운, 재물 축적 능력 평가
- 구체적인 조언 (예: "코가 반듯하고 준두가 풍만해 재물운이 좋습니다")

### 입 (식록궁 - 의식주운)
- 크기, 모양, 입술 두께, 입꼬리를 관찰
- 식복, 말복, 생활 안정도 평가
- 구체적인 조언 (예: "입이 적당하고 입술이 도톰해 평생 먹고 사는 걱정이 없습니다")

### 턱 (노년궁 - 말년운)
- 모양, 크기, 지각(턱선) 상태를 관찰
- 노후운, 건강운, 가정 안정도 평가
- 구체적인 조언 (예: "턱이 단정하고 풍만해 노년이 편안할 것입니다")

### 귀 (복덕궁 - 복록)
- 크기, 위치, 색깔, 귓볼 상태를 관찰
- 전반적인 복, 장수운, 조상 덕 평가
- 구체적인 조언 (예: "귀가 크고 귓볼이 두터워 타고난 복이 있습니다")

### 광대뼈 (권력운)
- 높이, 돌출 정도를 관찰
- 권력운, 리더십, 사회적 영향력 평가
- 구체적인 조언 (예: "광대가 적당히 있어 리더로서 인정받을 상입니다")

## 3. 성격과 기질 (4-6개 특성, 각각 1-2문장)
얼굴에서 드러나는 성격 특성을 구체적으로 분석하세요:
- 핵심 성격 특성 3-4가지 (예: 친화력, 추진력, 세심함 등)
- 주요 강점 2-3가지 (실제 관상에 근거)
- 보완하면 좋을 점 1-2가지 (부정적이지 않게)
- 대인관계 스타일 (적극적/수동적, 개방적/폐쇄적 등)

## 4. 세부 운세 분석 (각 항목 2-3문장)
각 영역의 운을 구체적으로 평가하세요:

### 💰 재물운 (70-95점 평가)
- 금전운의 강도와 시기
- 사업 적성과 성공 가능성
- 재물 축적 방법 조언

### ❤️ 애정운 (70-95점 평가)
- 연애운과 결혼 시기
- 이상형과 어울리는 배우자상
- 결혼 생활의 안정도

### 💼 직업운 (70-95점 평가)
- 적성과 재능 분야
- 성공 가능성이 높은 직종
- 직장 생활 스타일

### 🏥 건강운 (70-95점 평가)
- 주의해야 할 건강 부위
- 체질과 건강 관리 방법
- 장수 가능성

### 🍀 총운 (70-95점 평가)
- 전반적인 행운도
- 인생의 전성기 시기
- 전반적인 삶의 흐름

## 5. 특별한 관상 특징 (3-5개 항목)
다른 사람과 차별화되는 특징을 찾으세요:
- 복이 많은 관상 포인트 (예: "귀가 크고 귓볼이 두터워 복이 많습니다")
- 숨겨진 재능이나 가능성 (구체적으로)
- 개선하면 더 좋을 점 (긍정적으로 표현)
- 타고난 행운의 영역

## 6. 조언과 개운법 (3-5개 카테고리)
실용적이고 구체적인 조언을 제공하세요:

### 운을 높이는 방법
- 일상에서 실천할 수 있는 구체적인 행동 3가지
- 관상을 보완하는 외적 요소 (헤어스타일, 메이크업 등)

### 피해야 할 것들
- 관상학적으로 좋지 않은 습관 2-3가지
- 주의해야 할 시기나 상황

### 행운의 요소
- 행운의 색상 2-3가지 (구체적인 이유와 함께)
- 행운의 방향 (동/서/남/북 중 택1-2, 이유 설명)
- 행운의 숫자 2-3개 (근거 제시)
- 행운을 부르는 아이템이나 상징

### 개운 팁
- 관상을 개선하는 안면 운동이나 표정 관리
- 메이크업이나 헤어스타일 조언
- 액세서리 착용 팁

# 작성 원칙
1. **구체성**: "좋다", "나쁘다" 같은 모호한 표현 금지. 반드시 근거와 함께 구체적으로 설명
2. **전문성**: 12궁위, 삼정, 오관 등 전문 용어를 적절히 사용하되 쉽게 설명
3. **긍정성**: 모든 분석을 희망적이고 긍정적인 톤으로 작성 (단, 거짓말은 금지)
4. **개인화**: 실제 얼굴 사진을 바탕으로 개인화된 내용 제공
5. **실용성**: 실생활에 적용 가능한 조언 제공
6. **문화적 감수성**: 한국 문화와 전통에 맞는 해석 제공

# 분량
- 전체 분석: 최소 2000자 이상
- 각 섹션은 충분히 상세하게 작성 (3-5문장씩)
- 부위별 분석은 반드시 실제 얼굴을 관찰한 내용 포함

이제 제공된 얼굴 사진을 위 지침에 따라 전문가 수준으로 분석해주세요.`

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
    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['personality', 'wealth_fortune', 'love_fortune', 'health_fortune', 'career_fortune', 'special_features', 'advice', 'full_analysis']
      : []

    const fortuneResponse = {
      fortuneType: 'face-reading',
      mainFortune: mainFortune, // ✅ 무료: 공개
      details: {
        face_type: extractFaceType(analysisResult), // ✅ 무료: 공개
        overall_fortune: mainFortune, // ✅ 무료: 공개
        personality: extractSection(analysisResult, '성격과 기질'), // ✅ 항상 실제 데이터 생성
        wealth_fortune: wealthFortune, // ✅ 항상 실제 데이터 생성
        love_fortune: loveFortune, // ✅ 항상 실제 데이터 생성
        health_fortune: healthFortune, // ✅ 항상 실제 데이터 생성
        career_fortune: careerFortune, // ✅ 항상 실제 데이터 생성
        special_features: extractSection(analysisResult, '특별한 관상 특징'), // ✅ 항상 실제 데이터 생성
        advice: extractSection(analysisResult, '조언과 개운법'), // ✅ 항상 실제 데이터 생성
        full_analysis: analysisResult // ✅ 항상 실제 데이터 생성
      },
      luckScore: luckScore, // ✅ 무료: 공개
      timestamp: new Date().toISOString(),
      isBlurred, // ✅ 블러 상태
      blurredSections // ✅ 블러된 섹션 목록
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
          'Content-Type': 'application/json; charset=utf-8'
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
          'Content-Type': 'application/json; charset=utf-8'
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