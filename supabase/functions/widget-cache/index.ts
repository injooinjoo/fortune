/**
 * Widget Cache Edge Function
 *
 * @description 위젯용 운세 캐시 조회 - 백그라운드 갱신에서 사용
 * 앱 미접속 시에도 위젯이 오늘/어제 데이터를 표시할 수 있도록 캐시 제공
 *
 * @endpoint POST /widget-cache
 *
 * @auth
 * - Authorization: Bearer <supabase_access_token> (필수)
 *   body에서 userId를 받지 않는다. JWT의 user.id만 신뢰.
 *   iOS Widget extension이 호출할 때 App Group / Shared Keychain에서
 *   session access token을 꺼내 헤더로 첨부해야 한다.
 *
 * @response
 * - today: WidgetCacheData | null - 오늘 캐시 데이터
 * - yesterday: WidgetCacheData | null - 어제 캐시 데이터
 * - hasData: boolean - 데이터 존재 여부
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { authenticateUser } from '../_shared/auth.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface WidgetCacheData {
  fortune_date: string;
  overall_score: number;
  overall_grade: string;
  overall_message: string | null;
  categories: Record<string, { score: number; message: string }>;
  time_slots: Array<{ key: string; score: number; message: string }>;
  lotto_numbers: number[];
  lucky_items: Record<string, string>;
}

interface WidgetCacheResponse {
  today: WidgetCacheData | null;
  yesterday: WidgetCacheData | null;
  hasData: boolean;
}

serve(async (req: Request) => {
  // CORS preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // SECURITY: JWT 필수. body.userId 절대 신뢰하지 않음. iOS 위젯 extension이
    // 호출할 때도 Authorization: Bearer <session_access_token> 반드시 포함할 것.
    // (위젯 extension이 App Group / Shared Keychain 에서 access token 로드 필요)
    const { user, error: authError } = await authenticateUser(req)
    if (authError || !user) {
      return authError ?? new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    const userId = user.id

    // Service Role 클라이언트 생성 (백그라운드 접근용)
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 한국 시간 기준 오늘/어제 날짜 계산
    const now = new Date()
    const koreaOffset = 9 * 60 * 60 * 1000 // UTC+9
    const koreaTime = new Date(now.getTime() + koreaOffset)

    const today = koreaTime.toISOString().split('T')[0]
    const yesterday = new Date(koreaTime.getTime() - 24 * 60 * 60 * 1000)
      .toISOString().split('T')[0]

    // 최근 2일간의 캐시 조회
    const { data, error } = await supabase
      .from('widget_fortune_cache')
      .select('*')
      .eq('user_id', userId)
      .gte('fortune_date', yesterday)
      .order('fortune_date', { ascending: false })
      .limit(2)

    if (error) {
      console.error('[widget-cache] DB 조회 오류:', error)
      return new Response(
        JSON.stringify({ error: 'Database error', details: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 오늘/어제 데이터 분리
    const todayData = data?.find(d => d.fortune_date === today) || null
    const yesterdayData = data?.find(d => d.fortune_date === yesterday) || null

    const response: WidgetCacheResponse = {
      today: todayData ? formatCacheData(todayData) : null,
      yesterday: yesterdayData ? formatCacheData(yesterdayData) : null,
      hasData: !!(todayData || yesterdayData),
    }

    console.log(`[widget-cache] userId=${userId}, today=${!!todayData}, yesterday=${!!yesterdayData}`)

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('[widget-cache] 오류:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', message: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

function formatCacheData(row: any): WidgetCacheData {
  return {
    fortune_date: row.fortune_date,
    overall_score: row.overall_score,
    overall_grade: row.overall_grade,
    overall_message: row.overall_message,
    categories: row.categories || {},
    time_slots: row.time_slots || [],
    lotto_numbers: row.lotto_numbers || [],
    lucky_items: row.lucky_items || {},
  }
}
