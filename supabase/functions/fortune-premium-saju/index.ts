/**
 * 프리미엄 사주명리서 Edge Function
 *
 * @description 215페이지 상세 사주 분석서 생성 및 관리
 *
 * @endpoint POST /fortune-premium-saju
 *
 * @actions
 * - initialize: 구매 확인 후 초기 데이터 생성
 * - get-status: 생성 상태 조회
 * - get-result: 전체 결과 조회
 * - generate-chapter: 특정 챕터 생성 (내부 호출)
 * - update-progress: 읽기 진행도 업데이트
 * - add-bookmark: 북마크 추가
 * - remove-bookmark: 북마크 삭제
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 챕터 구조 정의 (21개 챕터, 6개 Part)
const CHAPTER_STRUCTURE = [
  // Part 1: 사주 기초 (45p)
  { partNumber: 1, chapterNumber: 1, title: '사주팔자 해석', emoji: '📜', estimatedPages: 8 },
  { partNumber: 1, chapterNumber: 2, title: '천간/지지 분석', emoji: '🌓', estimatedPages: 10 },
  { partNumber: 1, chapterNumber: 3, title: '오행 분포', emoji: '🔥', estimatedPages: 8 },
  { partNumber: 1, chapterNumber: 4, title: '격국 분석', emoji: '⚖️', estimatedPages: 10 },
  { partNumber: 1, chapterNumber: 5, title: '용신 결정', emoji: '💎', estimatedPages: 9 },
  // Part 2: 성격과 운명 (35p)
  { partNumber: 2, chapterNumber: 1, title: '핵심 성격 특성', emoji: '🎭', estimatedPages: 12 },
  { partNumber: 2, chapterNumber: 2, title: '숨겨진 성향', emoji: '🔮', estimatedPages: 8 },
  { partNumber: 2, chapterNumber: 3, title: '인생 목적과 사명', emoji: '🎯', estimatedPages: 8 },
  { partNumber: 2, chapterNumber: 4, title: '강점과 성장 영역', emoji: '💪', estimatedPages: 7 },
  // Part 3: 재물과 직업 (40p)
  { partNumber: 3, chapterNumber: 1, title: '재물 패턴 분석', emoji: '💰', estimatedPages: 10 },
  { partNumber: 3, chapterNumber: 2, title: '직업 적성', emoji: '💼', estimatedPages: 12 },
  { partNumber: 3, chapterNumber: 3, title: '사업/창업 잠재력', emoji: '🚀', estimatedPages: 10 },
  { partNumber: 3, chapterNumber: 4, title: '투자 성향', emoji: '📈', estimatedPages: 8 },
  // Part 4: 애정과 가정 (35p)
  { partNumber: 4, chapterNumber: 1, title: '연애 스타일', emoji: '💕', estimatedPages: 10 },
  { partNumber: 4, chapterNumber: 2, title: '결혼 궁합', emoji: '💍', estimatedPages: 10 },
  { partNumber: 4, chapterNumber: 3, title: '가족 관계', emoji: '👨‍👩‍👧', estimatedPages: 8 },
  { partNumber: 4, chapterNumber: 4, title: '자녀운', emoji: '👶', estimatedPages: 7 },
  // Part 5: 건강과 수명 (25p)
  { partNumber: 5, chapterNumber: 1, title: '체질 건강 분석', emoji: '🏥', estimatedPages: 8 },
  { partNumber: 5, chapterNumber: 2, title: '취약점과 예방', emoji: '🛡️', estimatedPages: 10 },
  { partNumber: 5, chapterNumber: 3, title: '장수 지표', emoji: '🌱', estimatedPages: 7 },
  // Part 6: 인생 타임라인 (35p)
  { partNumber: 6, chapterNumber: 1, title: '대운 6주기 분석', emoji: '⏳', estimatedPages: 24 },
]

interface PremiumSajuRequest {
  action: 'initialize' | 'get-status' | 'get-result' | 'generate-chapter' | 'update-progress' | 'add-bookmark' | 'remove-bookmark'
  userId: string
  transactionId?: string
  birthDate?: string
  birthTime?: string
  isLunar?: boolean
  gender?: string
  resultId?: string
  chapterIndex?: number
  readingProgress?: {
    currentChapter: number
    currentSection: number
    scrollPosition: number
    totalReadingTimeSeconds: number
  }
  bookmark?: {
    chapterIndex: number
    sectionIndex: number
    title: string
    note?: string
  }
  bookmarkId?: string
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Service role for admin operations
    )

    const requestData: PremiumSajuRequest = await req.json()
    const { action, userId } = requestData

    console.log(`📚 [PremiumSaju] Action: ${action}, User: ${userId}`)

    switch (action) {
      case 'initialize':
        return await handleInitialize(supabaseClient, requestData)
      case 'get-status':
        return await handleGetStatus(supabaseClient, requestData)
      case 'get-result':
        return await handleGetResult(supabaseClient, requestData)
      case 'generate-chapter':
        return await handleGenerateChapter(supabaseClient, requestData)
      case 'update-progress':
        return await handleUpdateProgress(supabaseClient, requestData)
      case 'add-bookmark':
        return await handleAddBookmark(supabaseClient, requestData)
      case 'remove-bookmark':
        return await handleRemoveBookmark(supabaseClient, requestData)
      default:
        return new Response(
          JSON.stringify({ error: 'Invalid action' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
  } catch (error) {
    console.error('❌ [PremiumSaju] Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

/**
 * 초기화 - 구매 확인 후 결과 레코드 생성
 */
async function handleInitialize(supabaseClient: any, request: PremiumSajuRequest) {
  const { userId, transactionId, birthDate, birthTime, isLunar, gender } = request

  if (!transactionId || !birthDate || !gender) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields: transactionId, birthDate, gender' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  console.log(`🎫 [PremiumSaju] Initializing for transaction: ${transactionId}`)

  // 이미 존재하는지 확인
  const { data: existing } = await supabaseClient
    .from('premium_saju_results')
    .select('id')
    .eq('transaction_id', transactionId)
    .single()

  if (existing) {
    return new Response(
      JSON.stringify({ resultId: existing.id, message: 'Already initialized' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 사주 계산 (user_saju 테이블에서 가져오거나 새로 계산)
  const sajuData = await calculateSaju(supabaseClient, userId, birthDate, birthTime, isLunar)

  // 프리미엄 결과 레코드 생성
  const { data: result, error } = await supabaseClient
    .from('premium_saju_results')
    .insert({
      user_id: userId,
      birth_date: birthDate,
      birth_time: birthTime || null,
      is_lunar: isLunar || false,
      gender: gender,
      saju_pillars: sajuData.pillars,
      element_distribution: sajuData.elements,
      format_analysis: sajuData.format,
      yongshin_analysis: sajuData.yongshin,
      grand_luck_cycles: sajuData.grandLuckCycles,
      shin_sal_list: sajuData.shinSalList,
      transaction_id: transactionId,
      purchased_at: new Date().toISOString(),
      generation_status: {
        totalChapters: CHAPTER_STRUCTURE.length,
        completedChapters: 0,
        currentChapterIndex: 0,
        isComplete: false,
        startedAt: new Date().toISOString(),
      },
    })
    .select('id')
    .single()

  if (error) {
    console.error('❌ [PremiumSaju] Insert error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 챕터 레코드 생성 (pending 상태)
  const chapterInserts = CHAPTER_STRUCTURE.map((ch, index) => ({
    result_id: result.id,
    part_number: ch.partNumber,
    chapter_number: ch.chapterNumber,
    chapter_index: index,
    title: ch.title,
    emoji: ch.emoji,
    status: 'pending',
    estimated_pages: ch.estimatedPages,
  }))

  await supabaseClient.from('premium_saju_chapters').insert(chapterInserts)

  console.log(`✅ [PremiumSaju] Initialized with ID: ${result.id}`)

  // 첫 번째 챕터 생성 시작 (비동기)
  EdgeRuntime.waitUntil(
    generateChapterAsync(supabaseClient, result.id, 0, sajuData)
  )

  return new Response(
    JSON.stringify({
      resultId: result.id,
      totalChapters: CHAPTER_STRUCTURE.length,
      message: 'Initialization complete, generation started',
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 생성 상태 조회
 */
async function handleGetStatus(supabaseClient: any, request: PremiumSajuRequest) {
  const { resultId, userId } = request

  if (!resultId) {
    return new Response(
      JSON.stringify({ error: 'Missing resultId' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const { data, error } = await supabaseClient
    .from('premium_saju_results')
    .select('generation_status')
    .eq('id', resultId)
    .eq('user_id', userId)
    .single()

  if (error || !data) {
    return new Response(
      JSON.stringify({ error: 'Result not found' }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 챕터별 상태도 조회
  const { data: chapters } = await supabaseClient
    .from('premium_saju_chapters')
    .select('chapter_index, status, title, emoji')
    .eq('result_id', resultId)
    .order('chapter_index')

  return new Response(
    JSON.stringify({
      generationStatus: data.generation_status,
      chapters: chapters || [],
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 전체 결과 조회
 */
async function handleGetResult(supabaseClient: any, request: PremiumSajuRequest) {
  const { resultId, userId } = request

  if (!resultId) {
    return new Response(
      JSON.stringify({ error: 'Missing resultId' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 메인 결과 조회
  const { data: result, error } = await supabaseClient
    .from('premium_saju_results')
    .select('*')
    .eq('id', resultId)
    .eq('user_id', userId)
    .single()

  if (error || !result) {
    return new Response(
      JSON.stringify({ error: 'Result not found' }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 완료된 챕터만 조회
  const { data: chapters } = await supabaseClient
    .from('premium_saju_chapters')
    .select('*')
    .eq('result_id', resultId)
    .eq('status', 'completed')
    .order('chapter_index')

  // 북마크 조회
  const { data: bookmarks } = await supabaseClient
    .from('premium_saju_bookmarks')
    .select('*')
    .eq('result_id', resultId)
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  return new Response(
    JSON.stringify({
      ...result,
      chapters: chapters || [],
      bookmarks: bookmarks || [],
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 특정 챕터 생성 (수동 트리거)
 */
async function handleGenerateChapter(supabaseClient: any, request: PremiumSajuRequest) {
  const { resultId, chapterIndex, userId } = request

  if (!resultId || chapterIndex === undefined) {
    return new Response(
      JSON.stringify({ error: 'Missing resultId or chapterIndex' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 결과 조회
  const { data: result } = await supabaseClient
    .from('premium_saju_results')
    .select('*')
    .eq('id', resultId)
    .eq('user_id', userId)
    .single()

  if (!result) {
    return new Response(
      JSON.stringify({ error: 'Result not found' }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const sajuData = {
    pillars: result.saju_pillars,
    elements: result.element_distribution,
    format: result.format_analysis,
    yongshin: result.yongshin_analysis,
    grandLuckCycles: result.grand_luck_cycles,
    shinSalList: result.shin_sal_list,
  }

  // 동기적으로 생성
  await generateChapterAsync(supabaseClient, resultId, chapterIndex, sajuData)

  return new Response(
    JSON.stringify({ success: true, chapterIndex }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 읽기 진행도 업데이트
 */
async function handleUpdateProgress(supabaseClient: any, request: PremiumSajuRequest) {
  const { resultId, userId, readingProgress } = request

  if (!resultId || !readingProgress) {
    return new Response(
      JSON.stringify({ error: 'Missing resultId or readingProgress' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const { error } = await supabaseClient
    .from('premium_saju_results')
    .update({
      reading_progress: {
        ...readingProgress,
        lastReadAt: new Date().toISOString(),
      },
    })
    .eq('id', resultId)
    .eq('user_id', userId)

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  return new Response(
    JSON.stringify({ success: true }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 북마크 추가
 */
async function handleAddBookmark(supabaseClient: any, request: PremiumSajuRequest) {
  const { resultId, userId, bookmark } = request

  if (!resultId || !bookmark) {
    return new Response(
      JSON.stringify({ error: 'Missing resultId or bookmark' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const { data, error } = await supabaseClient
    .from('premium_saju_bookmarks')
    .insert({
      result_id: resultId,
      user_id: userId,
      chapter_index: bookmark.chapterIndex,
      section_index: bookmark.sectionIndex,
      title: bookmark.title,
      note: bookmark.note || null,
    })
    .select('id')
    .single()

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  return new Response(
    JSON.stringify({ bookmarkId: data.id }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 북마크 삭제
 */
async function handleRemoveBookmark(supabaseClient: any, request: PremiumSajuRequest) {
  const { bookmarkId, userId } = request

  if (!bookmarkId) {
    return new Response(
      JSON.stringify({ error: 'Missing bookmarkId' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const { error } = await supabaseClient
    .from('premium_saju_bookmarks')
    .delete()
    .eq('id', bookmarkId)
    .eq('user_id', userId)

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  return new Response(
    JSON.stringify({ success: true }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

/**
 * 사주 계산 (기존 데이터 활용 또는 새로 계산)
 */
async function calculateSaju(
  supabaseClient: any,
  userId: string,
  birthDate: string,
  birthTime: string | undefined,
  isLunar: boolean | undefined
) {
  // 기존 user_saju 데이터 확인
  const { data: existingSaju } = await supabaseClient
    .from('user_saju')
    .select('*')
    .eq('user_id', userId)
    .single()

  if (existingSaju) {
    console.log('📋 [PremiumSaju] Using existing saju data')
    return {
      pillars: {
        yearPillar: {
          heavenlyStem: existingSaju.year_cheongan,
          earthlyBranch: existingSaju.year_jiji,
          element: getElement(existingSaju.year_cheongan),
          yinYang: getYinYang(existingSaju.year_cheongan),
        },
        monthPillar: {
          heavenlyStem: existingSaju.month_cheongan,
          earthlyBranch: existingSaju.month_jiji,
          element: getElement(existingSaju.month_cheongan),
          yinYang: getYinYang(existingSaju.month_cheongan),
        },
        dayPillar: {
          heavenlyStem: existingSaju.day_cheongan,
          earthlyBranch: existingSaju.day_jiji,
          element: getElement(existingSaju.day_cheongan),
          yinYang: getYinYang(existingSaju.day_cheongan),
        },
        hourPillar: existingSaju.hour_cheongan ? {
          heavenlyStem: existingSaju.hour_cheongan,
          earthlyBranch: existingSaju.hour_jiji,
          element: getElement(existingSaju.hour_cheongan),
          yinYang: getYinYang(existingSaju.hour_cheongan),
        } : null,
      },
      elements: {
        wood: existingSaju.element_wood || 0,
        fire: existingSaju.element_fire || 0,
        earth: existingSaju.element_earth || 0,
        metal: existingSaju.element_metal || 0,
        water: existingSaju.element_water || 0,
        dominant: existingSaju.strong_element || '목',
        lacking: existingSaju.weak_element || '화',
      },
      format: {
        format: '정재격', // TODO: 실제 격국 계산
        formatType: '정격',
        strength: '신강',
        description: '사주 격국 분석 결과입니다.',
      },
      yongshin: {
        yongshin: existingSaju.weak_element || '화',
        heeshin: '토',
        gishin: '수',
        chousin: '금',
        method: '억부법',
        description: '용신 분석 결과입니다.',
      },
      grandLuckCycles: existingSaju.daewoon_list || [],
      shinSalList: [
        ...(existingSaju.sinsal_gilsin || []).map((name: string) => ({
          name,
          type: '길신',
          position: '년주',
          description: `${name}이 있어 귀인의 도움을 받습니다.`,
          effect: '긍정적',
        })),
        ...(existingSaju.sinsal_hyungsin || []).map((name: string) => ({
          name,
          type: '흉신',
          position: '년주',
          description: `${name}이 있어 주의가 필요합니다.`,
          effect: '주의',
        })),
      ],
    }
  }

  // 새로 계산 (기본 템플릿)
  console.log('🧮 [PremiumSaju] Calculating new saju data')
  // TODO: 실제 만세력 계산 로직 구현
  return {
    pillars: {
      yearPillar: { heavenlyStem: '갑', earthlyBranch: '자', element: '목', yinYang: '양' },
      monthPillar: { heavenlyStem: '을', earthlyBranch: '축', element: '목', yinYang: '음' },
      dayPillar: { heavenlyStem: '병', earthlyBranch: '인', element: '화', yinYang: '양' },
      hourPillar: birthTime ? { heavenlyStem: '정', earthlyBranch: '묘', element: '화', yinYang: '음' } : null,
    },
    elements: { wood: 2, fire: 2, earth: 1, metal: 1, water: 2, dominant: '목', lacking: '토' },
    format: { format: '정재격', formatType: '정격', strength: '신강', description: '' },
    yongshin: { yongshin: '토', heeshin: '금', gishin: '수', chousin: '목', method: '억부법', description: '' },
    grandLuckCycles: [],
    shinSalList: [],
  }
}

/**
 * 천간 → 오행 매핑
 */
function getElement(stem: string): string {
  const map: Record<string, string> = {
    '갑': '목', '을': '목',
    '병': '화', '정': '화',
    '무': '토', '기': '토',
    '경': '금', '신': '금',
    '임': '수', '계': '수',
  }
  return map[stem] || '목'
}

/**
 * 천간 → 음양 매핑
 */
function getYinYang(stem: string): string {
  const yang = ['갑', '병', '무', '경', '임']
  return yang.includes(stem) ? '양' : '음'
}

/**
 * 비동기 챕터 생성
 */
async function generateChapterAsync(
  supabaseClient: any,
  resultId: string,
  chapterIndex: number,
  sajuData: any
) {
  const chapter = CHAPTER_STRUCTURE[chapterIndex]
  if (!chapter) {
    console.log(`⚠️ [PremiumSaju] Invalid chapter index: ${chapterIndex}`)
    return
  }

  console.log(`📝 [PremiumSaju] Generating chapter ${chapterIndex}: ${chapter.title}`)

  try {
    // 상태 업데이트: generating
    await supabaseClient
      .from('premium_saju_chapters')
      .update({ status: 'generating' })
      .eq('result_id', resultId)
      .eq('chapter_index', chapterIndex)

    // LLM으로 콘텐츠 생성
    const content = await generateChapterContent(chapter, sajuData, chapterIndex)

    // 챕터 저장
    await supabaseClient
      .from('premium_saju_chapters')
      .update({
        status: 'completed',
        sections: content.sections,
        word_count: content.wordCount,
        generated_at: new Date().toISOString(),
      })
      .eq('result_id', resultId)
      .eq('chapter_index', chapterIndex)

    // 생성 상태 업데이트
    const { data: result } = await supabaseClient
      .from('premium_saju_results')
      .select('generation_status')
      .eq('id', resultId)
      .single()

    const currentStatus = result?.generation_status || {}
    const completedChapters = (currentStatus.completedChapters || 0) + 1
    const isComplete = completedChapters >= CHAPTER_STRUCTURE.length

    await supabaseClient
      .from('premium_saju_results')
      .update({
        generation_status: {
          ...currentStatus,
          completedChapters,
          currentChapterIndex: chapterIndex + 1,
          isComplete,
          completedAt: isComplete ? new Date().toISOString() : null,
        },
      })
      .eq('id', resultId)

    console.log(`✅ [PremiumSaju] Chapter ${chapterIndex} completed (${completedChapters}/${CHAPTER_STRUCTURE.length})`)

    // 다음 챕터 생성 (아직 완료되지 않은 경우)
    if (!isComplete && chapterIndex + 1 < CHAPTER_STRUCTURE.length) {
      // 약간의 딜레이 후 다음 챕터 생성
      await new Promise(resolve => setTimeout(resolve, 1000))
      await generateChapterAsync(supabaseClient, resultId, chapterIndex + 1, sajuData)
    }
  } catch (error) {
    console.error(`❌ [PremiumSaju] Chapter ${chapterIndex} error:`, error)
    await supabaseClient
      .from('premium_saju_chapters')
      .update({
        status: 'error',
        error_message: error.message,
      })
      .eq('result_id', resultId)
      .eq('chapter_index', chapterIndex)
  }
}

/**
 * 챕터 콘텐츠 생성 (LLM)
 */
async function generateChapterContent(
  chapter: typeof CHAPTER_STRUCTURE[0],
  sajuData: any,
  chapterIndex: number
) {
  const llm = LLMFactory.createFromConfig('fortune-premium-saju')

  const systemPrompt = `당신은 전문 사주명리학자입니다. 다음 사주 데이터를 바탕으로 "${chapter.title}" 챕터의 상세한 분석을 작성해주세요.

사주 데이터:
- 사주팔자: ${JSON.stringify(sajuData.pillars)}
- 오행 분포: ${JSON.stringify(sajuData.elements)}
- 격국: ${JSON.stringify(sajuData.format)}
- 용신: ${JSON.stringify(sajuData.yongshin)}

작성 지침:
1. 약 ${chapter.estimatedPages * 400}자 분량으로 상세하게 작성
2. 전문적이지만 이해하기 쉬운 언어 사용
3. 구체적인 조언과 실천 방안 포함
4. 마크다운 형식 사용 (제목, 소제목, 목록 등)
5. 긍정적이고 희망적인 톤 유지

응답 형식:
## ${chapter.title}

### [소제목1]
[내용]

### [소제목2]
[내용]

...`

  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Part ${chapter.partNumber}, Chapter ${chapter.chapterNumber}: ${chapter.title}를 작성해주세요.` },
  ], {
    temperature: 0.7,
    maxTokens: 4000,
  })

  const content = response.content || ''
  const wordCount = content.length

  // 콘텐츠를 섹션으로 분리
  const sections = parseContentToSections(content, chapter)

  // 사용량 로깅
  await UsageLogger.log({
    fortuneType: 'premium-saju',
    userId: 'system',
    provider: response.provider || 'google',
    model: response.model || 'gemini-2.0-flash-lite',
    inputTokens: response.inputTokens || 0,
    outputTokens: response.outputTokens || 0,
    totalTokens: response.totalTokens || 0,
    latencyMs: response.latencyMs || 0,
    cached: false,
    success: true,
    metadata: {
      chapterIndex,
      chapterTitle: chapter.title,
    },
  })

  return { sections, wordCount }
}

/**
 * 콘텐츠를 섹션으로 파싱
 */
function parseContentToSections(content: string, chapter: typeof CHAPTER_STRUCTURE[0]) {
  const sections: any[] = []
  const lines = content.split('\n')
  let currentSection: any = null
  let currentContent: string[] = []

  for (const line of lines) {
    if (line.startsWith('### ')) {
      // 이전 섹션 저장
      if (currentSection) {
        currentSection.content = currentContent.join('\n').trim()
        sections.push(currentSection)
      }
      // 새 섹션 시작
      currentSection = {
        id: crypto.randomUUID(),
        title: line.replace('### ', '').trim(),
        type: 'llm',
        content: '',
        subsectionTitles: [],
        isGenerated: true,
        generatedAt: new Date().toISOString(),
      }
      currentContent = []
    } else if (line.startsWith('## ')) {
      // 메인 제목은 스킵 (챕터 제목)
      continue
    } else {
      currentContent.push(line)
    }
  }

  // 마지막 섹션 저장
  if (currentSection) {
    currentSection.content = currentContent.join('\n').trim()
    sections.push(currentSection)
  }

  // 섹션이 없으면 전체를 하나의 섹션으로
  if (sections.length === 0) {
    sections.push({
      id: crypto.randomUUID(),
      title: chapter.title,
      type: 'llm',
      content: content.trim(),
      subsectionTitles: [],
      isGenerated: true,
      generatedAt: new Date().toISOString(),
    })
  }

  return sections
}
