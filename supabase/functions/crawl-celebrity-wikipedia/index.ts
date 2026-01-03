/**
 * Wikipedia 연예인 정보 크롤링 Edge Function
 *
 * @description Wikipedia API를 통해 연예인 정보(출생일, 직업 등)를 조회합니다.
 *
 * @endpoint POST /crawl-celebrity-wikipedia
 *
 * @requestBody
 * - celebrity_id: string - 크롤링할 연예인 ID
 * - name: string - 연예인 이름 (검색용)
 * - batch_size?: number - 배치 크롤링 시 한 번에 처리할 수 (기본 10)
 * - mode?: 'single' | 'batch' - 단일 또는 배치 모드
 *
 * @response
 * - success: boolean
 * - data: CrawledData
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

interface CrawledData {
  birth_date?: string
  birth_place?: string
  occupation?: string
  description?: string
  image_url?: string
  raw_data?: Record<string, unknown>
}

interface RequestBody {
  celebrity_id?: string
  name?: string
  batch_size?: number
  mode?: 'single' | 'batch'
}

interface WikiSearchResult {
  query?: {
    search?: Array<{ title: string; pageid: number }>
  }
}

interface WikiPageResult {
  query?: {
    pages?: Record<string, {
      title: string
      extract?: string
      thumbnail?: { source: string }
      pageprops?: { wikibase_item?: string }
    }>
  }
}

interface WikidataResult {
  entities?: Record<string, {
    claims?: Record<string, Array<{
      mainsnak?: {
        datavalue?: {
          value?: unknown
          type?: string
        }
      }
    }>>
  }>
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Wikipedia API로 검색
async function searchWikipedia(name: string): Promise<string | null> {
  const encodedName = encodeURIComponent(name)
  const url = `https://ko.wikipedia.org/w/api.php?action=query&list=search&srsearch=${encodedName}&format=json&utf8=1`

  try {
    const response = await fetch(url, {
      headers: { 'Accept': 'application/json' }
    })

    if (!response.ok) return null

    const data: WikiSearchResult = await response.json()
    const results = data.query?.search

    if (!results || results.length === 0) {
      // 한국어 위키 실패 시 영어 위키 시도
      const enUrl = `https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=${encodedName}&format=json&utf8=1`
      const enResponse = await fetch(enUrl, {
        headers: { 'Accept': 'application/json' }
      })

      if (!enResponse.ok) return null

      const enData: WikiSearchResult = await enResponse.json()
      const enResults = enData.query?.search

      if (!enResults || enResults.length === 0) return null
      return `en:${enResults[0].title}`
    }

    return results[0].title
  } catch (error) {
    console.error(`Wikipedia 검색 오류 (${name}):`, error)
    return null
  }
}

// Wikipedia 페이지 정보 가져오기
async function getWikipediaPage(title: string): Promise<CrawledData> {
  const result: CrawledData = { raw_data: {} }

  try {
    // 언어 확인
    let lang = 'ko'
    let actualTitle = title
    if (title.startsWith('en:')) {
      lang = 'en'
      actualTitle = title.substring(3)
    }

    const encodedTitle = encodeURIComponent(actualTitle)
    const url = `https://${lang}.wikipedia.org/w/api.php?action=query&titles=${encodedTitle}&prop=extracts|pageprops|pageimages&exintro=1&explaintext=1&pithumbsize=300&format=json&utf8=1`

    const response = await fetch(url, {
      headers: { 'Accept': 'application/json' }
    })

    if (!response.ok) return result

    const data: WikiPageResult = await response.json()
    const pages = data.query?.pages

    if (!pages) return result

    const pageId = Object.keys(pages)[0]
    if (pageId === '-1') return result

    const page = pages[pageId]

    result.description = page.extract?.substring(0, 500)
    result.image_url = page.thumbnail?.source

    // Wikidata ID가 있으면 추가 정보 조회
    const wikidataId = page.pageprops?.wikibase_item
    if (wikidataId) {
      const wikidataInfo = await getWikidataInfo(wikidataId)
      Object.assign(result, wikidataInfo)
    }

    result.raw_data = { title: page.title, wikidataId }

  } catch (error) {
    console.error('Wikipedia 페이지 조회 오류:', error)
  }

  return result
}

// Wikidata에서 상세 정보 조회
async function getWikidataInfo(wikidataId: string): Promise<Partial<CrawledData>> {
  const result: Partial<CrawledData> = {}

  try {
    const url = `https://www.wikidata.org/w/api.php?action=wbgetentities&ids=${wikidataId}&props=claims&format=json`

    const response = await fetch(url, {
      headers: { 'Accept': 'application/json' }
    })

    if (!response.ok) return result

    const data: WikidataResult = await response.json()
    const entity = data.entities?.[wikidataId]

    if (!entity?.claims) return result

    // P569 = 생년월일
    const birthDate = entity.claims['P569']?.[0]?.mainsnak?.datavalue?.value
    if (birthDate && typeof birthDate === 'object' && 'time' in birthDate) {
      const timeStr = (birthDate as { time: string }).time
      // +1993-05-16T00:00:00Z 형식에서 날짜 추출
      const match = timeStr.match(/\+?(\d{4})-(\d{2})-(\d{2})/)
      if (match) {
        result.birth_date = `${match[1]}-${match[2]}-${match[3]}`
      }
    }

    // P19 = 출생지 (ID로 반환되므로 추가 조회 필요)
    const birthPlaceId = entity.claims['P19']?.[0]?.mainsnak?.datavalue?.value
    if (birthPlaceId && typeof birthPlaceId === 'object' && 'id' in birthPlaceId) {
      const placeId = (birthPlaceId as { id: string }).id
      result.birth_place = placeId // 나중에 라벨 조회 가능
    }

    // P106 = 직업
    const occupation = entity.claims['P106']?.[0]?.mainsnak?.datavalue?.value
    if (occupation && typeof occupation === 'object' && 'id' in occupation) {
      result.occupation = (occupation as { id: string }).id
    }

  } catch (error) {
    console.error('Wikidata 조회 오류:', error)
  }

  return result
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    const body: RequestBody = await req.json()
    const { celebrity_id, name, batch_size = 10, mode = 'single' } = body

    // 배치 모드
    if (mode === 'batch') {
      const { data: celebrities, error: fetchError } = await supabase
        .from('celebrities')
        .select('id, name')
        .eq('crawl_status', 'pending')
        .order('popularity_score', { ascending: false })
        .limit(batch_size)

      if (fetchError) {
        throw new Error(`조회 오류: ${fetchError.message}`)
      }

      if (!celebrities || celebrities.length === 0) {
        return new Response(
          JSON.stringify({ success: true, message: '크롤링 대기 항목 없음', processed: 0 }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      console.log(`📥 Wikipedia 배치 조회 시작: ${celebrities.length}명`)

      const results = []
      for (const celeb of celebrities) {
        // Rate limiting: 500ms 대기 (Wikipedia API는 더 관대함)
        await new Promise(resolve => setTimeout(resolve, 500))

        // 상태를 in_progress로 변경
        await supabase
          .from('celebrities')
          .update({ crawl_status: 'in_progress' })
          .eq('id', celeb.id)

        const title = await searchWikipedia(celeb.name)

        if (!title) {
          await supabase
            .from('celebrities')
            .update({
              crawl_status: 'not_found',
              crawled_at: new Date().toISOString()
            })
            .eq('id', celeb.id)

          results.push({ id: celeb.id, name: celeb.name, success: false, reason: '위키피디아에 없음' })
          continue
        }

        const crawledData = await getWikipediaPage(title)

        // DB 업데이트
        const updateData: Record<string, unknown> = {
          crawl_status: 'completed',
          crawled_at: new Date().toISOString(),
          crawl_source: 'wikipedia'
        }

        // birth_date가 있고 기존 birth_date가 없으면 업데이트
        // (기존 데이터를 덮어쓰지 않음)

        await supabase
          .from('celebrities')
          .update(updateData)
          .eq('id', celeb.id)

        results.push({
          id: celeb.id,
          name: celeb.name,
          success: true,
          data: {
            description: crawledData.description?.substring(0, 100),
            image_url: crawledData.image_url,
            birth_date: crawledData.birth_date
          }
        })

        console.log(`  ✅ ${celeb.name}: Wikipedia 조회 완료`)
      }

      const successCount = results.filter(r => r.success).length

      return new Response(
        JSON.stringify({
          success: true,
          message: `${successCount}/${celebrities.length}명 조회 완료`,
          results
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 단일 모드
    if (!celebrity_id && !name) {
      return new Response(
        JSON.stringify({ error: 'celebrity_id 또는 name 필요' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    let targetName = name
    const targetId = celebrity_id

    // celebrity_id로 이름 조회
    if (celebrity_id && !name) {
      const { data: celeb, error } = await supabase
        .from('celebrities')
        .select('name')
        .eq('id', celebrity_id)
        .single()

      if (error || !celeb) {
        return new Response(
          JSON.stringify({ error: '연예인을 찾을 수 없습니다' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      targetName = celeb.name
    }

    console.log(`🔍 Wikipedia 조회: ${targetName}`)

    const title = await searchWikipedia(targetName!)

    if (!title) {
      return new Response(
        JSON.stringify({ success: false, error: '위키피디아에서 찾을 수 없습니다' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const crawledData = await getWikipediaPage(title)

    // DB 업데이트 (celebrity_id가 있는 경우)
    if (targetId) {
      await supabase
        .from('celebrities')
        .update({
          crawl_status: 'completed',
          crawled_at: new Date().toISOString(),
          crawl_source: 'wikipedia'
        })
        .eq('id', targetId)
    }

    return new Response(
      JSON.stringify({
        success: true,
        name: targetName,
        wikipedia_title: title,
        data: crawledData
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Wikipedia 조회 오류:', error)
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
