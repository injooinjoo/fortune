/**
 * Decision Receipt Edge Function
 *
 * @description 결정 기록 CRUD 및 관리
 * ZPZG Decision Coach Pivot - Phase 1.2
 *
 * @endpoint POST /decision-receipt
 *
 * @actions
 * - create: 새 결정 기록 생성
 * - update: 선택 옵션/확신도 업데이트
 * - get: 단일 결정 기록 조회
 * - list: 사용자 결정 기록 목록 조회
 * - delete: 결정 기록 삭제
 * - stats: 사용자 결정 통계 조회
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Supabase Admin 클라이언트 생성
const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)

// 요청 인터페이스
interface ReceiptRequest {
  action: 'create' | 'update' | 'get' | 'list' | 'delete' | 'stats'
  userId: string
  receiptId?: string
  data?: {
    decisionType?: string
    question?: string
    chosenOption?: string
    reasoning?: string
    optionsAnalyzed?: any
    aiRecommendation?: string
    confidenceLevel?: number
    emotionalState?: string
    followUpDays?: number
    tags?: string[]
  }
  filters?: {
    decisionType?: string
    outcomeStatus?: string
    limit?: number
    offset?: number
  }
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
    const request: ReceiptRequest = await req.json()
    const { action, userId, receiptId, data, filters } = request

    if (!userId) {
      throw new Error('userId is required')
    }

    let result: any

    switch (action) {
      case 'create':
        result = await createReceipt(userId, data!)
        break

      case 'update':
        if (!receiptId) throw new Error('receiptId is required for update')
        result = await updateReceipt(userId, receiptId, data!)
        break

      case 'get':
        if (!receiptId) throw new Error('receiptId is required for get')
        result = await getReceipt(userId, receiptId)
        break

      case 'list':
        result = await listReceipts(userId, filters)
        break

      case 'delete':
        if (!receiptId) throw new Error('receiptId is required for delete')
        result = await deleteReceipt(userId, receiptId)
        break

      case 'stats':
        result = await getStats(userId)
        break

      default:
        throw new Error(`Unknown action: ${action}`)
    }

    return new Response(JSON.stringify({ success: true, data: result }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })

  } catch (error) {
    console.error('Decision Receipt Error:', error)

    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : 'An error occurred'
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })
  }
})

// 결정 기록 생성
async function createReceipt(userId: string, data: ReceiptRequest['data']) {
  if (!data?.question || !data?.decisionType) {
    throw new Error('question and decisionType are required')
  }

  const followUpDays = data.followUpDays || 7
  const followUpDate = new Date(Date.now() + followUpDays * 24 * 60 * 60 * 1000)

  const { data: receipt, error } = await supabaseAdmin
    .from('decision_receipts')
    .insert({
      user_id: userId,
      decision_type: data.decisionType,
      question: data.question,
      chosen_option: data.chosenOption || '',
      reasoning: data.reasoning,
      options_analyzed: data.optionsAnalyzed,
      ai_recommendation: data.aiRecommendation,
      confidence_level: data.confidenceLevel,
      emotional_state: data.emotionalState,
      follow_up_date: followUpDate.toISOString(),
      tags: data.tags || []
    })
    .select()
    .single()

  if (error) throw error

  console.log('Created receipt:', receipt.id)
  return receipt
}

// 결정 기록 업데이트
async function updateReceipt(userId: string, receiptId: string, data: ReceiptRequest['data']) {
  const updateData: any = {}

  if (data?.chosenOption !== undefined) updateData.chosen_option = data.chosenOption
  if (data?.reasoning !== undefined) updateData.reasoning = data.reasoning
  if (data?.confidenceLevel !== undefined) updateData.confidence_level = data.confidenceLevel
  if (data?.emotionalState !== undefined) updateData.emotional_state = data.emotionalState
  if (data?.tags !== undefined) updateData.tags = data.tags

  const { data: receipt, error } = await supabaseAdmin
    .from('decision_receipts')
    .update(updateData)
    .eq('id', receiptId)
    .eq('user_id', userId)
    .select()
    .single()

  if (error) throw error

  console.log('Updated receipt:', receiptId)
  return receipt
}

// 단일 결정 기록 조회
async function getReceipt(userId: string, receiptId: string) {
  const { data: receipt, error } = await supabaseAdmin
    .from('decision_receipts')
    .select('*')
    .eq('id', receiptId)
    .eq('user_id', userId)
    .single()

  if (error) throw error

  return receipt
}

// 결정 기록 목록 조회
async function listReceipts(userId: string, filters?: ReceiptRequest['filters']) {
  let query = supabaseAdmin
    .from('decision_receipts')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (filters?.decisionType) {
    query = query.eq('decision_type', filters.decisionType)
  }

  if (filters?.outcomeStatus) {
    query = query.eq('outcome_status', filters.outcomeStatus)
  }

  if (filters?.limit) {
    query = query.limit(filters.limit)
  }

  if (filters?.offset) {
    query = query.range(filters.offset, filters.offset + (filters.limit || 20) - 1)
  }

  const { data: receipts, error } = await query

  if (error) throw error

  return receipts
}

// 결정 기록 삭제
async function deleteReceipt(userId: string, receiptId: string) {
  const { error } = await supabaseAdmin
    .from('decision_receipts')
    .delete()
    .eq('id', receiptId)
    .eq('user_id', userId)

  if (error) throw error

  return { deleted: true, id: receiptId }
}

// 사용자 통계 조회
async function getStats(userId: string) {
  const { data, error } = await supabaseAdmin
    .rpc('get_user_decision_stats', { p_user_id: userId })

  if (error) throw error

  return data?.[0] || {
    total_decisions: 0,
    positive_outcomes: 0,
    negative_outcomes: 0,
    pending_outcomes: 0,
    avg_confidence: null,
    avg_outcome_rating: null,
    most_common_type: null,
    decisions_by_type: {}
  }
}
