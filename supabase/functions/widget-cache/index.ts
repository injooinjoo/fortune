/**
 * Widget Cache Edge Function
 *
 * @description 위젯용 운세 캐시 조회 - 백그라운드 갱신에서 사용
 * 앱 미접속 시에도 위젯이 오늘/어제 데이터를 표시할 수 있도록 캐시 제공
 *
 * @endpoint POST /widget-cache
 *
 * @requestBody
 * - userId: string - 사용자 ID
 *
 * @response
 * - today: WidgetCacheData | null - 오늘 캐시 데이터
 * - yesterday: WidgetCacheData | null - 어제 캐시 데이터
 * - hasData: boolean - 데이터 존재 여부
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
    const { userId } = await req.json()

    if (!userId) {
      return new Response(
        JSON.stringify({ error: 'userId is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

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
