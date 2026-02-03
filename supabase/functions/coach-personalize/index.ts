/**
 * Coach Personalize Edge Function
 *
 * @description AI 코치 개인화 설정 관리
 * ZPZG Decision Coach Pivot - Phase 1.2
 *
 * @endpoint POST /coach-personalize
 *
 * @actions
 * - get: 현재 코치 설정 조회
 * - update: 코치 설정 업데이트
 * - reset: 기본 설정으로 초기화
 * - getPromptContext: AI 프롬프트 컨텍스트 조회 (내부용)
 * - generateAnonymousId: 커뮤니티 익명 ID 생성
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Supabase Admin 클라이언트 생성
const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

// 코치 설정 인터페이스
interface CoachPreferences {
  tone_preference: 'friendly' | 'professional' | 'adaptive'
  response_length: 'concise' | 'balanced' | 'detailed'
  decision_style: 'logic' | 'empathy' | 'balanced'
  relationship_status?: string
  age_group?: string
  occupation_type?: string
  preferred_categories?: string[]
  follow_up_reminder_enabled?: boolean
  follow_up_days?: number
  push_notification_enabled?: boolean
  community_anonymous_prefix?: string
  community_participation_enabled?: boolean
}

// 기본 설정
const DEFAULT_PREFERENCES: Partial<CoachPreferences> = {
  tone_preference: 'adaptive',
  response_length: 'balanced',
  decision_style: 'balanced',
  preferred_categories: ['dating', 'career', 'lifestyle'],
  follow_up_reminder_enabled: true,
  follow_up_days: 7,
  push_notification_enabled: true,
  community_anonymous_prefix: 'animal',
  community_participation_enabled: true
}

// 요청 인터페이스
interface PersonalizeRequest {
  action: 'get' | 'update' | 'reset' | 'getPromptContext' | 'generateAnonymousId'
  userId: string
  data?: Partial<CoachPreferences>
}

// CORS 헤더
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 메인 핸들러
serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const request: PersonalizeRequest = await req.json()
    const { action, userId, data } = request

    if (!userId) {
      throw new Error('userId is required')
    }

    let result: any

    switch (action) {
      case 'get':
        result = await getPreferences(userId)
        break

      case 'update':
        result = await updatePreferences(userId, data!)
        break

      case 'reset':
        result = await resetPreferences(userId)
        break

      case 'getPromptContext':
        result = await getPromptContext(userId)
        break

      case 'generateAnonymousId':
        result = await generateAnonymousId(userId)
        break

      default:
        throw new Error(`Unknown action: ${action}`)
    }

    return new Response(JSON.stringify({ success: true, data: result }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })

  } catch (error) {
    console.error('Coach Personalize Error:', error)

    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : 'An error occurred'
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })
  }
})

// 설정 조회 (없으면 생성)
async function getPreferences(userId: string) {
  // 먼저 조회 시도
  const { data: existing, error: selectError } = await supabaseAdmin
    .from('user_coach_preferences')
    .select('*')
    .eq('user_id', userId)
    .single()

  if (existing) {
    return {
      ...existing,
      descriptions: getPreferenceDescriptions(existing)
    }
  }

  // 없으면 기본 설정으로 생성
  const { data: created, error: insertError } = await supabaseAdmin
    .from('user_coach_preferences')
    .insert({
      user_id: userId,
      ...DEFAULT_PREFERENCES
    })
    .select()
    .single()

  if (insertError) throw insertError

  return {
    ...created,
    descriptions: getPreferenceDescriptions(created),
    isNew: true
  }
}

// 설정 설명 생성
function getPreferenceDescriptions(prefs: any) {
  return {
    tone: getToneDescription(prefs.tone_preference),
    responseLength: getResponseLengthDescription(prefs.response_length),
    decisionStyle: getDecisionStyleDescription(prefs.decision_style)
  }
}

function getToneDescription(tone: string): string {
  const descriptions: Record<string, string> = {
    friendly: '🤝 친구 모드: 편하고 따뜻한 친구처럼 대화해요',
    professional: '📊 컨설턴트 모드: 전문적이고 객관적으로 분석해요',
    adaptive: '✨ 적응형: 상황에 맞게 톤을 조절해요'
  }
  return descriptions[tone] || descriptions.adaptive
}

function getResponseLengthDescription(length: string): string {
  const descriptions: Record<string, string> = {
    concise: '⚡ 간결하게: 핵심만 짧게',
    balanced: '📝 적당하게: 적절한 설명 포함',
    detailed: '📖 상세하게: 자세한 분석과 예시'
  }
  return descriptions[length] || descriptions.balanced
}

function getDecisionStyleDescription(style: string): string {
  const descriptions: Record<string, string> = {
    logic: '🧠 논리 중심: 데이터와 객관적 분석',
    empathy: '💗 감정 중심: 감정과 가치관 우선',
    balanced: '⚖️ 균형: 논리와 감정 모두 고려'
  }
  return descriptions[style] || descriptions.balanced
}

// 설정 업데이트
async function updatePreferences(userId: string, data: Partial<CoachPreferences>) {
  // 유효성 검사
  if (data.tone_preference && !['friendly', 'professional', 'adaptive'].includes(data.tone_preference)) {
    throw new Error('Invalid tone_preference')
  }
  if (data.response_length && !['concise', 'balanced', 'detailed'].includes(data.response_length)) {
    throw new Error('Invalid response_length')
  }
  if (data.decision_style && !['logic', 'empathy', 'balanced'].includes(data.decision_style)) {
    throw new Error('Invalid decision_style')
  }
  if (data.follow_up_days && (data.follow_up_days < 1 || data.follow_up_days > 30)) {
    throw new Error('follow_up_days must be between 1 and 30')
  }

  // 기존 설정 확인 (없으면 생성)
  await getPreferences(userId)

  // 업데이트
  const { data: updated, error } = await supabaseAdmin
    .from('user_coach_preferences')
    .update(data)
    .eq('user_id', userId)
    .select()
    .single()

  if (error) throw error

  console.log('Updated preferences for user:', userId)

  return {
    ...updated,
    descriptions: getPreferenceDescriptions(updated)
  }
}

// 설정 초기화
async function resetPreferences(userId: string) {
  const { data: reset, error } = await supabaseAdmin
    .from('user_coach_preferences')
    .update(DEFAULT_PREFERENCES)
    .eq('user_id', userId)
    .select()
    .single()

  if (error) throw error

  console.log('Reset preferences for user:', userId)

  return {
    ...reset,
    descriptions: getPreferenceDescriptions(reset),
    message: '설정이 기본값으로 초기화되었어요.'
  }
}

// AI 프롬프트 컨텍스트 조회 (Edge Functions 내부용)
async function getPromptContext(userId: string) {
  const { data, error } = await supabaseAdmin
    .rpc('get_ai_prompt_context', { p_user_id: userId })

  if (error) throw error

  return data
}

// 커뮤니티 익명 ID 생성
async function generateAnonymousId(userId: string) {
  // 사용자 설정에서 prefix type 조회
  const { data: prefs } = await supabaseAdmin
    .from('user_coach_preferences')
    .select('community_anonymous_prefix')
    .eq('user_id', userId)
    .single()

  const prefixType = prefs?.community_anonymous_prefix || 'animal'

  const { data, error } = await supabaseAdmin
    .rpc('generate_anonymous_id', { p_prefix_type: prefixType })

  if (error) throw error

  return {
    anonymousId: data,
    prefixType
  }
}
