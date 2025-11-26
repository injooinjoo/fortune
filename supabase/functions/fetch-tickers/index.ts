import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface TickerRequest {
  category?: string;      // 특정 카테고리만 조회
  search?: string;        // 검색어 (이름, 심볼)
  popularOnly?: boolean;  // 인기 종목만
  limit?: number;         // 조회 개수 제한
}

interface Ticker {
  id: string;
  symbol: string;
  name: string;
  name_en: string | null;
  category: string;
  exchange: string | null;
  description: string | null;
  logo_url: string | null;
  is_popular: boolean;
  display_order: number;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    // GET 또는 POST 요청 모두 지원
    let requestData: TickerRequest = {}

    if (req.method === 'POST') {
      requestData = await req.json()
    } else if (req.method === 'GET') {
      const url = new URL(req.url)
      requestData = {
        category: url.searchParams.get('category') || undefined,
        search: url.searchParams.get('search') || undefined,
        popularOnly: url.searchParams.get('popularOnly') === 'true',
        limit: url.searchParams.get('limit') ? parseInt(url.searchParams.get('limit')!) : undefined,
      }
    }

    const { category, search, popularOnly, limit } = requestData

    console.log('📊 [Tickers] Request:', { category, search, popularOnly, limit })

    // 쿼리 빌드
    let query = supabaseClient
      .from('tickers')
      .select('*')
      .eq('is_active', true)
      .order('display_order', { ascending: true })

    // 카테고리 필터
    if (category) {
      query = query.eq('category', category)
    }

    // 인기 종목만
    if (popularOnly) {
      query = query.eq('is_popular', true)
    }

    // 검색어 필터 (이름, 영문명, 심볼에서 검색)
    if (search && search.trim().length > 0) {
      const searchTerm = search.trim().toLowerCase()
      query = query.or(`name.ilike.%${searchTerm}%,name_en.ilike.%${searchTerm}%,symbol.ilike.%${searchTerm}%`)
    }

    // 개수 제한
    if (limit && limit > 0) {
      query = query.limit(limit)
    }

    const { data: tickers, error } = await query

    if (error) {
      console.error('❌ [Tickers] DB Error:', error)
      throw new Error(`Database error: ${error.message}`)
    }

    // 카테고리별로 그룹화
    const tickersByCategory: Record<string, Ticker[]> = {}

    for (const ticker of tickers || []) {
      if (!tickersByCategory[ticker.category]) {
        tickersByCategory[ticker.category] = []
      }
      tickersByCategory[ticker.category].push(ticker)
    }

    // 카테고리 메타데이터
    const categoryMeta: Record<string, { label: string; description: string; icon: string }> = {
      crypto: { label: '코인', description: 'BTC, ETH 등 암호화폐', icon: 'currency_bitcoin' },
      krStock: { label: '국내주식', description: 'KOSPI, KOSDAQ 상장 종목', icon: 'trending_up' },
      usStock: { label: '해외주식', description: 'NYSE, NASDAQ 상장 종목', icon: 'show_chart' },
      etf: { label: 'ETF', description: '국내외 상장지수펀드', icon: 'pie_chart' },
      commodity: { label: '금/원자재', description: '금, 은, 원유 등', icon: 'diamond' },
      realEstate: { label: '부동산', description: '아파트, REITs 등', icon: 'home' },
    }

    const response = {
      tickers: tickers || [],
      tickersByCategory,
      categories: categoryMeta,
      total: tickers?.length || 0,
      timestamp: new Date().toISOString(),
    }

    console.log(`✅ [Tickers] Found ${response.total} tickers`)

    return new Response(
      JSON.stringify(response),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8',
          'Cache-Control': 'public, max-age=3600' // 1시간 캐시
        }
      }
    )

  } catch (error) {
    console.error('❌ [Tickers] Error:', error)

    return new Response(
      JSON.stringify({
        error: error.message,
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
