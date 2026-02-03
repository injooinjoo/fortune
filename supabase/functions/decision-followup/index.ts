/**
 * Decision Follow-up Edge Function
 *
 * @description 결정 결과 기록 및 팔로업 관리
 * ZPZG Decision Coach Pivot - Phase 1.2
 *
 * @endpoint POST /decision-followup
 *
 * @actions
 * - recordOutcome: 결정 결과 기록
 * - getPending: 팔로업 대기 중인 결정 목록
 * - markFollowUpSent: 팔로업 알림 발송 표시
 * - getPatterns: 결정 패턴 분석
 * - reschedule: 팔로업 날짜 재설정
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Supabase Admin 클라이언트 생성
const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

// 요청 인터페이스
interface FollowUpRequest {
  action: 'recordOutcome' | 'getPending' | 'markFollowUpSent' | 'getPatterns' | 'reschedule'
  userId: string
  receiptId?: string
  data?: {
    outcomeStatus?: 'positive' | 'negative' | 'neutral' | 'mixed'
    outcomeNotes?: string
    outcomeRating?: number  // 1-5
    newFollowUpDate?: string
    newFollowUpDays?: number
  }
  limit?: number
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
    const request: FollowUpRequest = await req.json()
    const { action, userId, receiptId, data, limit } = request

    if (!userId) {
      throw new Error('userId is required')
    }

    let result: any

    switch (action) {
      case 'recordOutcome':
        if (!receiptId) throw new Error('receiptId is required')
        result = await recordOutcome(userId, receiptId, data!)
        break

      case 'getPending':
        result = await getPendingFollowUps(userId, limit)
        break

      case 'markFollowUpSent':
        if (!receiptId) throw new Error('receiptId is required')
        result = await markFollowUpSent(userId, receiptId)
        break

      case 'getPatterns':
        result = await getDecisionPatterns(userId, limit)
        break

      case 'reschedule':
        if (!receiptId) throw new Error('receiptId is required')
        result = await rescheduleFollowUp(userId, receiptId, data!)
        break

      default:
        throw new Error(`Unknown action: ${action}`)
    }

    return new Response(JSON.stringify({ success: true, data: result }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })

  } catch (error) {
    console.error('Decision Follow-up Error:', error)

    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : 'An error occurred'
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })
  }
})

// 결과 기록
async function recordOutcome(userId: string, receiptId: string, data: FollowUpRequest['data']) {
  if (!data?.outcomeStatus) {
    throw new Error('outcomeStatus is required')
  }

  const { data: receipt, error } = await supabaseAdmin
    .from('decision_receipts')
    .update({
      outcome_status: data.outcomeStatus,
      outcome_notes: data.outcomeNotes,
      outcome_rating: data.outcomeRating,
      outcome_recorded_at: new Date().toISOString(),
    })
    .eq('id', receiptId)
    .eq('user_id', userId)
    .select()
    .single()

  if (error) throw error

  // 코치 상호작용 요약 업데이트 (AI 학습용)
  try {
    await supabaseAdmin.rpc('update_coach_interaction_summary', {
      p_user_id: userId,
      p_confidence: receipt.confidence_level,
      p_outcome_positive: data.outcomeStatus === 'positive',
      p_topics: receipt.tags || []
    })
  } catch (updateError) {
    console.error('Failed to update interaction summary:', updateError)
    // 메인 기능은 성공했으므로 에러 무시
  }

  console.log('Recorded outcome for receipt:', receiptId, data.outcomeStatus)

  return {
    ...receipt,
    message: getOutcomeMessage(data.outcomeStatus)
  }
}

// 결과 메시지 생성
function getOutcomeMessage(status: string): string {
  const messages: Record<string, string> = {
    positive: '좋은 결과가 있었네요! 🎉 다음 결정에도 이 경험이 도움이 될 거예요.',
    negative: '아쉬운 결과지만, 이 경험은 다음 결정에 소중한 자산이 될 거예요. 💪',
    neutral: '결과를 기록해주셔서 감사해요. 시간이 지나면 더 명확해질 수도 있어요.',
    mixed: '복합적인 결과네요. 좋았던 점과 아쉬웠던 점 모두 기억해두세요. ✨'
  }

  return messages[status] || messages.neutral
}

// 팔로업 대기 목록 조회
async function getPendingFollowUps(userId: string, limit?: number) {
  const { data: receipts, error } = await supabaseAdmin
    .from('decision_receipts')
    .select('id, decision_type, question, chosen_option, follow_up_date, created_at, confidence_level')
    .eq('user_id', userId)
    .eq('outcome_status', 'pending')
    .eq('follow_up_sent', false)
    .lte('follow_up_date', new Date().toISOString())
    .order('follow_up_date', { ascending: true })
    .limit(limit || 10)

  if (error) throw error

  return receipts.map(receipt => ({
    ...receipt,
    daysAgo: Math.floor((Date.now() - new Date(receipt.created_at).getTime()) / (1000 * 60 * 60 * 24)),
    isOverdue: new Date(receipt.follow_up_date) < new Date()
  }))
}

// 팔로업 발송 표시
async function markFollowUpSent(userId: string, receiptId: string) {
  const { data: receipt, error } = await supabaseAdmin
    .from('decision_receipts')
    .update({
      follow_up_sent: true,
      follow_up_count: supabaseAdmin.sql`follow_up_count + 1`
    })
    .eq('id', receiptId)
    .eq('user_id', userId)
    .select('id, follow_up_count')
    .single()

  if (error) throw error

  console.log('Marked follow-up sent for receipt:', receiptId)

  return receipt
}

// 결정 패턴 분석
async function getDecisionPatterns(userId: string, limit?: number) {
  const { data: patterns, error } = await supabaseAdmin
    .rpc('get_decision_patterns', {
      p_user_id: userId,
      p_limit: limit || 20
    })

  if (error) throw error

  // 패턴 분석 추가
  const analysis = analyzePatterns(patterns || [])

  return {
    decisions: patterns,
    analysis
  }
}

// 패턴 분석 헬퍼
function analyzePatterns(decisions: any[]): any {
  if (decisions.length === 0) {
    return {
      totalDecisions: 0,
      insights: ['아직 기록된 결정이 없어요. 첫 결정을 기록해보세요!']
    }
  }

  const insights: string[] = []

  // 결과 분석
  const outcomes = decisions.filter(d => d.outcome_status && d.outcome_status !== 'pending')
  const positiveRate = outcomes.filter(d => d.outcome_status === 'positive').length / (outcomes.length || 1)

  if (positiveRate > 0.7) {
    insights.push('최근 결정들의 결과가 대체로 좋았어요! 🎯 결정력이 좋으시네요.')
  } else if (positiveRate < 0.3 && outcomes.length >= 3) {
    insights.push('최근 결정 결과가 아쉬웠나요? 결정 전 더 많은 정보를 수집해보세요.')
  }

  // 확신도 분석
  const avgConfidence = decisions.reduce((sum, d) => sum + (d.confidence_level || 3), 0) / decisions.length

  if (avgConfidence >= 4) {
    insights.push('결정에 대한 확신이 높은 편이에요. 자신감이 있어 좋아요! 💪')
  } else if (avgConfidence <= 2) {
    insights.push('결정이 어려우신가요? 선택지를 줄이거나 기한을 정해보세요.')
  }

  // 유형별 분석
  const typeCount: Record<string, number> = {}
  decisions.forEach(d => {
    typeCount[d.decision_type] = (typeCount[d.decision_type] || 0) + 1
  })

  const mostCommonType = Object.entries(typeCount)
    .sort(([, a], [, b]) => b - a)[0]

  if (mostCommonType) {
    const typeNames: Record<string, string> = {
      dating: '연애',
      career: '커리어',
      money: '재정',
      wellness: '건강',
      lifestyle: '라이프스타일',
      relationship: '관계'
    }
    insights.push(`${typeNames[mostCommonType[0]] || mostCommonType[0]} 관련 고민이 가장 많았어요.`)
  }

  return {
    totalDecisions: decisions.length,
    completedOutcomes: outcomes.length,
    positiveRate: Math.round(positiveRate * 100),
    avgConfidence: Math.round(avgConfidence * 10) / 10,
    mostCommonType: mostCommonType?.[0],
    insights
  }
}

// 팔로업 날짜 재설정
async function rescheduleFollowUp(userId: string, receiptId: string, data: FollowUpRequest['data']) {
  let newDate: Date

  if (data?.newFollowUpDate) {
    newDate = new Date(data.newFollowUpDate)
  } else if (data?.newFollowUpDays) {
    newDate = new Date(Date.now() + data.newFollowUpDays * 24 * 60 * 60 * 1000)
  } else {
    // 기본 7일 연장
    newDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  }

  const { data: receipt, error } = await supabaseAdmin
    .from('decision_receipts')
    .update({
      follow_up_date: newDate.toISOString(),
      follow_up_sent: false
    })
    .eq('id', receiptId)
    .eq('user_id', userId)
    .select('id, follow_up_date')
    .single()

  if (error) throw error

  console.log('Rescheduled follow-up for receipt:', receiptId, 'to', newDate)

  return receipt
}
