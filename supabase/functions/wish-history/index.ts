/**
 * 소원 히스토리 조회 (Wish History) Edge Function
 *
 * @description 사용자의 전체 소원 빌기 히스토리를 조회합니다.
 *
 * @endpoint GET /wish-history
 *
 * @queryParams
 * - limit?: number - 조회할 개수 (기본값: 50)
 * - offset?: number - 시작 위치 (기본값: 0)
 *
 * @response
 * - wishes: WishHistoryItem[] - 소원 히스토리 목록
 * - total: number - 전체 소원 개수
 * - remaining_today: number - 오늘 남은 소원 횟수
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 하루 최대 소원 횟수
const DAILY_WISH_LIMIT = 3

serve(async (req) => {
  // CORS preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Supabase 클라이언트 생성
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // 사용자 인증 확인
    const { data: userData, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !userData?.user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '인증이 필요합니다',
          code: 'UNAUTHORIZED',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401,
        }
      )
    }

    const userId = userData.user.id

    // URL에서 쿼리 파라미터 추출
    const url = new URL(req.url)
    const limit = parseInt(url.searchParams.get('limit') || '50')
    const offset = parseInt(url.searchParams.get('offset') || '0')

    console.log(`📖 소원 히스토리 조회: userId=${userId}, limit=${limit}, offset=${offset}`)

    // 전체 소원 개수 조회
    const { count: totalCount, error: countError } = await supabaseClient
      .from('wish_fortunes')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)

    if (countError) {
      console.error('❌ 전체 개수 조회 오류:', countError)
      throw new Error('소원 히스토리 조회 중 오류가 발생했습니다')
    }

    // 소원 히스토리 조회 (최신순)
    const { data: wishes, error: fetchError } = await supabaseClient
      .from('wish_fortunes')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (fetchError) {
      console.error('❌ 소원 히스토리 조회 오류:', fetchError)
      throw new Error('소원 히스토리 조회 중 오류가 발생했습니다')
    }

    // 오늘 소원 횟수 조회
    const today = new Date().toISOString().split('T')[0]
    const { count: todayCount, error: todayError } = await supabaseClient
      .from('wish_fortunes')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('wish_date', today)

    if (todayError) {
      console.error('⚠️ 오늘 소원 횟수 조회 오류:', todayError)
    }

    const todayWishCount = todayCount ?? 0
    const remainingToday = Math.max(0, DAILY_WISH_LIMIT - todayWishCount)

    console.log(`✅ 조회 완료: total=${totalCount}, fetched=${wishes?.length}, remaining=${remainingToday}`)

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          wishes: wishes || [],
          total: totalCount || 0,
          remaining_today: remainingToday,
          daily_limit: DAILY_WISH_LIMIT,
        },
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('❌ 소원 히스토리 조회 오류:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        code: 'FETCH_ERROR',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
