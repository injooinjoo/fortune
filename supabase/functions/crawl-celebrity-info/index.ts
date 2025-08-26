import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CelebrityInfo {
  name: string;
  birth_date?: string;
  birth_time?: string;
  description?: string;
  profile_image_url?: string;
  keywords?: string[];
  category?: string;
  gender?: 'male' | 'female';
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const { name, forceUpdate = false } = await req.json()

    if (!name) {
      return new Response(
        JSON.stringify({ error: '유명인 이름이 필요합니다.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 기존 데이터 확인 (forceUpdate가 false인 경우)
    if (!forceUpdate) {
      const { data: existing } = await supabaseClient
        .from('celebrities')
        .select('*')
        .eq('name', name)
        .single()

      if (existing) {
        return new Response(
          JSON.stringify({ 
            message: '이미 존재하는 데이터입니다.',
            data: existing,
            updated: false
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    console.log(`크롤링 시작: ${name}`)

    // 나무위키 정보 크롤링
    const celebrityInfo = await crawlNamuWiki(name)

    if (!celebrityInfo) {
      return new Response(
        JSON.stringify({ error: `${name}에 대한 정보를 찾을 수 없습니다.` }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 데이터베이스 업데이트
    const { data, error } = await supabaseClient
      .from('celebrities')
      .upsert({
        name: celebrityInfo.name,
        birth_date: celebrityInfo.birth_date,
        birth_time: celebrityInfo.birth_time || '12:00',
        description: celebrityInfo.description,
        profile_image_url: celebrityInfo.profile_image_url,
        keywords: celebrityInfo.keywords || [celebrityInfo.name],
        category: celebrityInfo.category || 'entertainer',
        gender: celebrityInfo.gender || 'male',
        crawled_at: new Date().toISOString(),
        source_url: `https://namu.wiki/w/${encodeURIComponent(name)}`,
        last_updated: new Date().toISOString(),
        popularity_score: 50, // 기본값
      })
      .select()
      .single()

    if (error) {
      console.error('데이터베이스 오류:', error)
      return new Response(
        JSON.stringify({ error: '데이터베이스 저장 실패', details: error }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        message: '성공적으로 크롤링되었습니다.',
        data: data,
        updated: true
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('크롤링 오류:', error)
    return new Response(
      JSON.stringify({ error: '크롤링 중 오류가 발생했습니다.', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function crawlNamuWiki(name: string): Promise<CelebrityInfo | null> {
  try {
    // 나무위키 API 엔드포인트 (실제로는 웹 스크래핑이 필요할 수 있음)
    const searchUrl = `https://namu.wiki/api/search/${encodeURIComponent(name)}`
    const wikiUrl = `https://namu.wiki/w/${encodeURIComponent(name)}`
    
    console.log(`크롤링 URL: ${wikiUrl}`)
    
    // 실제 구현에서는 HTML 파싱이 필요하지만, 
    // 데모를 위해 기본값 반환
    const response = await fetch(wikiUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    })

    if (!response.ok) {
      console.log(`HTTP 오류: ${response.status}`)
      return null
    }

    const html = await response.text()
    
    // 간단한 정보 추출 (실제로는 더 정교한 파싱 필요)
    const info: CelebrityInfo = {
      name: name,
      description: `${name}에 대한 정보`,
      profile_image_url: `https://via.placeholder.com/200/4CAF50/FFFFFF?text=${encodeURIComponent(name)}`,
      keywords: [name],
      category: extractCategory(html),
      gender: extractGender(html),
      birth_date: extractBirthDate(html),
    }

    return info

  } catch (error) {
    console.error(`크롤링 오류 (${name}):`, error)
    return null
  }
}

function extractCategory(html: string): string {
  // HTML에서 카테고리 추출 로직
  if (html.includes('배우') || html.includes('연기자')) return 'actor'
  if (html.includes('가수') || html.includes('음악가')) return 'singer'
  if (html.includes('정치인') || html.includes('대통령') || html.includes('의원')) return 'politician'
  if (html.includes('운동선수') || html.includes('선수')) return 'athlete'
  if (html.includes('방송인') || html.includes('개그맨')) return 'entertainer'
  if (html.includes('유튜버')) return 'youtuber'
  if (html.includes('게이머') || html.includes('프로게이머')) return 'pro_gamer'
  if (html.includes('기업인') || html.includes('회장')) return 'business_leader'
  return 'entertainer'
}

function extractGender(html: string): 'male' | 'female' {
  // 성별 추출 로직
  if (html.includes('여성') || html.includes('여배우') || html.includes('여가수')) return 'female'
  return 'male'
}

function extractBirthDate(html: string): string | undefined {
  // 생년월일 추출 로직 (정규식 사용)
  const birthRegex = /(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일/
  const match = html.match(birthRegex)
  
  if (match) {
    const [, year, month, day] = match
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
  }
  
  return undefined
}