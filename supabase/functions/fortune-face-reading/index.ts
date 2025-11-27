import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { extractUsername, fetchInstagramProfileImage, downloadAndEncodeImage } from '../_shared/instagram/scraper.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

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

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('face-reading')

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

    // Create the face reading prompt - 전통 관상학 기반 전문 프롬프트
    const faceReadingPrompt = `당신은 30년 경력의 한국 전통 관상학 최고 전문가입니다.
마의상법(麻衣相法)과 달마상법(達磨相法)을 깊이 연구했으며, 음양오행설을 기반으로 수천 명의 관상을 분석한 경험이 있습니다.

# 사용자 정보
- 이름: ${userName || '귀하'}
- 성별: ${userGender === 'male' ? '남성' : userGender === 'female' ? '여성' : '알 수 없음'}
${userBirthDate ? `- 생년월일: ${userBirthDate}` : ''}
${userBirthTime ? `- 생시: ${userBirthTime}` : ''}

# 분석 지침
제공된 얼굴 사진을 전통 관상학의 오관(五官), 삼정(三停), 십이궁(十二宮)을 기반으로 매우 상세하게 분석하세요.

## 1. 전체적인 인상 및 삼정(三停) 분석 (4-6문장)
먼저 얼굴의 전반적인 기운과 삼정의 균형을 분석하세요:

### 얼굴형과 기운
- 얼굴형 분류 (타원형/둥근형/각진형/역삼각형/긴형 중 택1) 및 그 의미
- 첫인상에서 느껴지는 에너지와 기질 (밝음/차분함/강인함 등)
- 전반적인 복의 정도 (70-95점으로 평가)

### 삼정(三停) 균형 분석
- **상정(上停)**: 이마~눈썹 (초년운 1-30세, 지혜와 학업)
- **중정(中停)**: 눈썹~코끝 (중년운 31-50세, 사회적 성공)
- **하정(下停)**: 인중~턱 (말년운 51세 이후, 복록과 안정)
- 삼정의 균형 상태 분석 및 시기별 운세 흐름

## 2. 오관(五官) 상세 분석 - 전통 관상학의 핵심
전통 관상학에서 가장 중요한 오관을 깊이 있게 분석하세요:

### 귀(耳) - 채청관(採聽官): 복록과 수명
- 크기, 위치, 색깔, 귓볼 두께를 실제로 관찰
- 타고난 복과 장수 가능성 평가 (복덕궁)
- 조상의 음덕과 초년운 (1-14세) 분석
- 구체적 조언 (예: "귀가 크고 귓볼이 두터워 복이 많고 장수할 상입니다")

### 눈썹(眉) - 보수관(保壽官): 형제와 친구
- 모양, 굵기, 길이, 색깔, 눈과의 간격을 관찰
- 형제운, 친구운, 인덕 평가 (형제궁)
- 성품과 감정 표현 방식 분석
- 구체적 조언 (예: "눈썹이 수려하고 적당한 간격으로 인덕이 많습니다")

### 눈(目) - 감찰관(監察官): 마음의 창
- 크기, 모양, 눈빛, 쌍꺼풀, 흰자와 검은자 비율 관찰
- 지혜, 총명함, 판단력 평가 (명궁 - 미간 포함)
- 배우자운과 자녀운 분석 (처첩궁/남녀궁)
- 감정과 의지력 평가
- 구체적 조언 (예: "눈이 맑고 정기가 있어 지혜롭고 좋은 배우자를 만날 상입니다")

### 코(鼻) - 심변관(審辨官): 재물의 중심
- 높이, 길이, 콧대, 콧구멍, 준두(코끝) 상태를 세밀히 관찰
- 재물운과 사업 수완 평가 (재백궁)
- 자존심과 리더십 분석
- 40대 중년운의 핵심
- 구체적 조언 (예: "코가 반듯하고 준두가 풍만해 재물이 모이고 사업 수완이 뛰어납니다")

### 입(口) - 출납관(出納官): 식복과 언변
- 크기, 모양, 입술 두께, 입꼬리, 치아 상태 관찰
- 식록운과 의식주 안정도 평가 (식록궁)
- 언변과 신용도 분석
- 만년의 복 평가
- 구체적 조언 (예: "입이 단정하고 입술이 붉어 평생 의식주 걱정 없고 언변이 좋습니다")

## 3. 십이궁(十二宮) 추가 분석
오관 외에 중요한 궁위들을 추가로 분석하세요:

### 명궁(命宮) - 미간 (운명의 중심)
- 미간의 넓이, 색깔, 주름, 인당의 밝기
- 전반적인 운명과 학업, 사회적 성공
- 명(命)의 길흉 판단

### 관록궁(官祿宮) - 이마 중앙 (사회적 지위)
- 이마의 넓이, 높이, 빛깔, 주름
- 직업운, 출세운, 권력운
- 사회적 성공 가능성

### 전택궁(田宅宮) - 눈썹 끝~눈꼬리 (재산과 주거)
- 눈썹과 눈 사이 부위의 상태
- 부동산운과 집안 운세
- 재산 축적 능력

### 천이궁(遷移宮) - 양쪽 관자놀이 (이동과 변화)
- 관자놀이의 상태와 빛깔
- 이사운, 해외운, 직장 이동운
- 환경 변화 적응력

### 질액궁(疾厄宮) - 코뿌리~미간 아래 (건강)
- 산근(코뿌리) 부위의 상태
- 건강 상태와 질병 가능성
- 주의해야 할 건강 부위

### 노복궁(奴僕宮) - 턱과 지각 (부하와 친구)
- 턱과 턱선의 상태
- 부하운, 친구의 도움
- 노년의 안정과 복록

### 인중 - 자녀궁 확장 (건강과 수명)
- 인중의 길이, 깊이, 선명도
- 자녀운 추가 분석
- 건강과 장수 가능성

## 4. 성격과 기질 분석 (5-7개 특성, 각 2-3문장)
오관과 십이궁에서 읽어낸 성격을 구체적으로 분석하세요:
- 핵심 성격 특성 3-4가지 (오관에서 도출, 예: "눈이 맑아 정직하고 직선적입니다")
- 주요 강점 2-3가지 (실제 관상에 근거, 구체적 예시)
- 성장 가능성과 보완점 1-2가지 (긍정적 표현)
- 대인관계 스타일 (적극성, 개방성 등)
- 리더십과 추진력
- 감정 표현 방식

## 5. 운세 분석 - 삼정과 오관 기반 (각 2-3문장, 70-95점 평가)
각 운세를 전통 관상학 이론에 근거하여 평가하세요:

### 💰 재물운 (재백궁 중심)
- 코의 상태로 본 금전운과 재물 축적력
- 사업 적성과 성공 시기 (40대 중년운 중심)
- 구체적 재물 증식 방법 조언

### ❤️ 애정운 (처첩궁/남녀궁 중심)
- 눈과 눈썹으로 본 연애운과 결혼운
- 어울리는 배우자의 특성
- 결혼 적령기와 결혼 생활 안정도
- 자녀운 (인중 포함)

### 💼 직업운 (관록궁 중심)
- 이마로 본 출세운과 사회적 성공
- 적성 직종 (오관의 균형으로 판단)
- 성공 가능성 높은 시기
- 리더십과 직장 생활 스타일

### 🏥 건강운 (질액궁 중심)
- 전반적인 체질과 건강 상태
- 주의해야 할 신체 부위 (오행 이론 적용)
- 장수 가능성 (귀와 인중으로 판단)
- 건강 관리 방법

### 🍀 총운 (삼정 균형으로 판단)
- 초년·중년·말년운의 흐름
- 인생의 전성기 시기 예측
- 전반적인 복록과 행운도
- 삶의 전반적인 방향성

## 6. 특별한 관상 특징 (4-6개 항목)
전통 관상학에서 특별히 주목할 만한 점을 찾으세요:
- **복 많은 관상**: 구체적 부위와 이유 (예: "귓볼이 두텁고 붉어 복이 많습니다")
- **귀한 상(貴相)**: 출세하거나 높은 지위에 오를 관상
- **부자 상(富相)**: 재물이 모이는 관상
- **장수 상(壽相)**: 건강하고 오래 살 관상
- 숨겨진 재능과 가능성 (구체적으로)
- 타고난 행운의 영역

## 7. 개운법과 실천 조언 (4-5개 카테고리)
전통 개운법과 현대적 실천 방법을 제공하세요:

### 일상 개운법
- 표정 관리와 미소 짓기 (관상 개선)
- 긍정적 마음가짐과 말씨 (입관 보완)
- 규칙적 생활과 건강 관리

### 외모 개선 조언
- 헤어스타일 (이마와 귀 고려)
- 메이크업 포인트 (눈과 눈썹 강조)
- 액세서리 활용 (귀걸이, 안경 등)

### 행운의 요소
- 행운의 색상 2-3가지 (오행 이론 기반, 구체적 이유)
- 행운의 방위 (동/서/남/북 중 1-2개, 관상과 연관 설명)
- 행운의 숫자와 상징물

### 시기별 주의사항
- 조심해야 할 시기 (삼정 기반)
- 피해야 할 습관 (관상 손상 요인)
- 중요 결정 시 고려사항

### 관상 보완법
- 안면 운동과 마사지
- 피부 관리와 혈색 개선
- 자세와 걸음걸이 교정

## 8. 닮은꼴 유명인 분석
제공된 얼굴 사진을 분석하여 관상학적으로 유사한 한국 유명인 3명을 찾아주세요.

### 분석 기준
- 전체적인 얼굴형과 이목구비 비율
- 인상과 표정에서 풍기는 분위기
- 한국 유명인 우선 (배우, 가수, 운동선수, 아이돌 등)
- 성별 일치 권장

### 각 유명인에 대해 아래 형식으로 작성:
**닮은 유명인 1**: [이름] ([직업])
- 닮은 부위: [눈, 코, 입, 전체 분위기 등 구체적으로]
- 이유: [왜 닮았는지 2-3문장으로 설명]

**닮은 유명인 2**: [이름] ([직업])
- 닮은 부위: [구체적 부위]
- 이유: [설명]

**닮은 유명인 3**: [이름] ([직업])
- 닮은 부위: [구체적 부위]
- 이유: [설명]

# 작성 원칙
1. **전통성**: 마의상법, 달마상법 등 전통 이론에 근거한 해석
2. **구체성**: 모호한 표현 금지, 관상 부위와 연결하여 설명
3. **전문성**: 오관, 삼정, 십이궁 용어를 정확하게 사용하되 쉽게 풀어쓰기
4. **균형성**: 장점과 보완점을 균형있게 제시
5. **긍정성**: 희망적 톤 유지 (부정적 단정 금지)
6. **개인화**: 실제 얼굴을 세밀히 관찰한 내용
7. **실용성**: 즉시 실천 가능한 조언

# 분량
- 전체 분석: 최소 2500자 이상 (전통 관상학은 상세할수록 좋음)
- 오관 분석: 각각 최소 3-4문장 (가장 중요)
- 십이궁: 각각 2-3문장
- 운세 분석: 각 영역당 3-4문장
- 반드시 실제 얼굴 사진을 면밀히 관찰하여 작성

이제 제공된 얼굴 사진을 전통 관상학의 정수(精髓)를 담아 전문가 수준으로 분석해주세요.`

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

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'face-reading',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { analysis_source, userName, userGender, isPremium }
    })

    const analysisResult = response.content

    if (!analysisResult) {
      throw new Error('Failed to generate face reading analysis')
    }

    // Parse the analysis result into structured format
    const sections = analysisResult.split(/\d+\.\s\*\*/).filter(s => s.trim())

    // Extract key information for the response
    const mainFortune = extractSection(analysisResult, '전체적인 인상') ||
                       extractSection(analysisResult, '삼정') ||
                       '당신의 얼굴에서 밝은 기운이 느껴집니다.'

    const luckScore = Math.floor(Math.random() * 20) + 70 // 70-90 range

    // ✅ 전통 관상학 섹션 추출 (오관, 삼정, 십이궁)
    const ogwan = {
      ear: extractSection(analysisResult, '귀') || extractSection(analysisResult, '채청관'),
      eyebrow: extractSection(analysisResult, '눈썹') || extractSection(analysisResult, '보수관'),
      eye: extractSection(analysisResult, '눈') || extractSection(analysisResult, '감찰관'),
      nose: extractSection(analysisResult, '코') || extractSection(analysisResult, '심변관'),
      mouth: extractSection(analysisResult, '입') || extractSection(analysisResult, '출납관')
    }

    const samjeong = extractSection(analysisResult, '삼정') ||
                     extractSection(analysisResult, '三停') ||
                     '상정, 중정, 하정의 균형이 좋습니다.'

    const sibigung = extractSection(analysisResult, '십이궁') ||
                     extractSection(analysisResult, '十二宮') ||
                     '십이궁이 조화롭게 배치되어 있습니다.'

    const overallAnalysis = extractSection(analysisResult, '종합 운세') ||
                           extractSection(analysisResult, '전체적인 분석') ||
                           mainFortune

    const advice = extractSection(analysisResult, '조언') ||
                  extractSection(analysisResult, '개운법') ||
                  '자신의 장점을 살리고 약점을 보완하세요.'

    // ✅ 유사 유명인 추출
    const similarCelebrities = extractSimilarCelebrities(analysisResult)
    console.log(`✅ [FaceReading] Similar celebrities found: ${similarCelebrities.length}`, similarCelebrities.map(c => c.name))

    // Format the response
    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['ogwan', 'samjeong', 'sibigung', 'advice', 'full_analysis']
      : []

    const fortuneResponse = {
      fortuneType: 'face-reading',
      mainFortune: mainFortune, // ✅ 무료: 공개
      details: {
        face_type: extractFaceType(analysisResult), // ✅ 무료: 공개
        overall_fortune: overallAnalysis, // ✅ 무료: 공개

        // ✅ 전통 관상학 구조
        ogwan: ogwan, // 🔒 프리미엄: 오관(五官) 분석
        samjeong: samjeong, // 🔒 프리미엄: 삼정(三停) 분석
        sibigung: sibigung, // 🔒 프리미엄: 십이궁(十二宮) 분석
        advice: advice, // 🔒 프리미엄: 조언과 개운법
        full_analysis: analysisResult, // 🔒 프리미엄: 전체 분석

        // ✅ 닮은꼴 유명인 (무료 공개 - 바이럴 효과)
        similar_celebrities: similarCelebrities
      },
      luckScore: luckScore, // ✅ 무료: 공개
      timestamp: new Date().toISOString(),
      isBlurred, // ✅ 블러 상태
      blurredSections // ✅ 블러된 섹션 목록
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'face-reading', fortuneResponse.luckScore)
    const fortuneResponseWithPercentile = addPercentileToResult(fortuneResponse, percentileData)

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
      JSON.stringify(fortuneResponseWithPercentile),
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

// Helper function to extract similar celebrities
function extractSimilarCelebrities(text: string): Array<{
  name: string;
  occupation: string;
  similar_parts: string;
  reason: string;
}> {
  const celebrities: Array<{
    name: string;
    occupation: string;
    similar_parts: string;
    reason: string;
  }> = []

  // 정규식으로 유명인 정보 추출
  const regex = /\*\*닮은 유명인 \d+\*\*:\s*(.+?)\s*\((.+?)\)\s*\n-?\s*닮은 부위:\s*(.+?)\n-?\s*이유:\s*(.+?)(?=\n\n|\n\*\*닮은 유명인|\n#|$)/gis

  let match
  while ((match = regex.exec(text)) !== null && celebrities.length < 3) {
    celebrities.push({
      name: match[1].trim(),
      occupation: match[2].trim(),
      similar_parts: match[3].trim(),
      reason: match[4].trim().replace(/\n/g, ' ')
    })
  }

  // 정규식으로 못 찾으면 대체 방법 시도
  if (celebrities.length === 0) {
    const altRegex = /닮은 유명인[^:]*:\s*([가-힣a-zA-Z]+)\s*\(?([^)\n]*)\)?/gi
    let altMatch
    while ((altMatch = altRegex.exec(text)) !== null && celebrities.length < 3) {
      celebrities.push({
        name: altMatch[1].trim(),
        occupation: altMatch[2]?.trim() || '연예인',
        similar_parts: '전체적인 인상',
        reason: '얼굴형과 분위기가 비슷합니다.'
      })
    }
  }

  return celebrities
}