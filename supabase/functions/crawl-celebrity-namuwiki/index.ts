/**
 * 나무위키 연예인 정보 크롤링 Edge Function
 *
 * @description 나무위키에서 연예인 정보(출생시간, MBTI, 혈액형 등)를 크롤링합니다.
 *
 * @endpoint POST /crawl-celebrity-namuwiki
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
  birth_time?: string
  birth_time_confirmed: boolean
  mbti?: string
  blood_type?: string
  real_name?: string
  education?: string
  agency?: string
  debut_date?: string
  profile_image_url?: string
  raw_profile?: Record<string, string>
}

interface RequestBody {
  celebrity_id?: string
  name?: string
  batch_size?: number
  mode?: 'single' | 'batch'
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 나무위키 프로필 표 파싱
function parseNamuWikiProfile(html: string): CrawledData {
  const result: CrawledData = {
    birth_time_confirmed: false,
    raw_profile: {}
  }

  try {
    // 프로필 표 찾기 (wikitable 또는 infobox)
    const tableRegex = /<table[^>]*class="[^"]*(?:wikitable|infobox)[^"]*"[^>]*>([\s\S]*?)<\/table>/gi
    const tables = html.match(tableRegex)

    if (!tables || tables.length === 0) {
      console.log('프로필 표를 찾을 수 없습니다')
      return result
    }

    // 첫 번째 테이블 파싱
    const tableHtml = tables[0]

    // 행 파싱
    const rowRegex = /<tr[^>]*>([\s\S]*?)<\/tr>/gi
    const rows = tableHtml.match(rowRegex) || []

    for (const row of rows) {
      // th와 td 추출
      const thMatch = row.match(/<th[^>]*>([\s\S]*?)<\/th>/i)
      const tdMatch = row.match(/<td[^>]*>([\s\S]*?)<\/td>/i)

      if (thMatch && tdMatch) {
        const key = stripHtml(thMatch[1]).trim()
        const value = stripHtml(tdMatch[1]).trim()

        if (key && value) {
          result.raw_profile![key] = value

          // 출생 정보 파싱
          if (key.includes('출생') || key.includes('생년월일')) {
            const timeMatch = value.match(/(\d{1,2})시\s*(\d{1,2})?분?/)
            if (timeMatch) {
              const hour = timeMatch[1].padStart(2, '0')
              const minute = (timeMatch[2] || '00').padStart(2, '0')
              result.birth_time = `${hour}:${minute}`
              result.birth_time_confirmed = true
            }

            // 오전/오후 표기
            const ampmMatch = value.match(/(오전|오후)\s*(\d{1,2})시/)
            if (ampmMatch) {
              let hour = parseInt(ampmMatch[2])
              if (ampmMatch[1] === '오후' && hour !== 12) hour += 12
              if (ampmMatch[1] === '오전' && hour === 12) hour = 0
              result.birth_time = `${hour.toString().padStart(2, '0')}:00`
              result.birth_time_confirmed = true
            }
          }

          // MBTI 파싱
          if (key === 'MBTI' || key.includes('MBTI')) {
            const mbtiMatch = value.match(/[IE][NS][TF][JP]/i)
            if (mbtiMatch) {
              result.mbti = mbtiMatch[0].toUpperCase()
            }
          }

          // 혈액형 파싱
          if (key.includes('혈액형')) {
            const bloodMatch = value.match(/([ABO]|AB)형?/i)
            if (bloodMatch) {
              result.blood_type = bloodMatch[1].toUpperCase()
            }
          }

          // 본명 파싱
          if (key === '본명' || key.includes('본명')) {
            result.real_name = value.replace(/\([^)]*\)/g, '').trim()
          }

          // 소속사 파싱
          if (key.includes('소속') || key.includes('소속사') || key.includes('레이블')) {
            result.agency = value
          }

          // 학력 파싱
          if (key.includes('학력') || key.includes('학교')) {
            result.education = value
          }

          // 데뷔 파싱
          if (key.includes('데뷔')) {
            result.debut_date = value
          }
        }
      }
    }

    // 이미지 URL 추출 시도
    const imgMatch = html.match(/<img[^>]*src="([^"]*namu\.wiki[^"]*)"[^>]*>/i)
    if (imgMatch) {
      result.profile_image_url = imgMatch[1]
    }

  } catch (error) {
    console.error('파싱 오류:', error)
  }

  return result
}

// HTML 태그 제거
function stripHtml(html: string): string {
  return html
    .replace(/<[^>]*>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/\s+/g, ' ')
    .trim()
}

// 나무위키 페이지 fetch
async function fetchNamuWikiPage(name: string): Promise<string | null> {
  const encodedName = encodeURIComponent(name)
  const url = `https://namu.wiki/w/${encodedName}`

  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Accept-Language': 'ko-KR,ko;q=0.9',
      },
    })

    if (!response.ok) {
      if (response.status === 404) {
        console.log(`페이지 없음: ${name}`)
        return null
      }
      throw new Error(`HTTP ${response.status}`)
    }

    return await response.text()
  } catch (error) {
    console.error(`Fetch 오류 (${name}):`, error)
    return null
  }
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

    // 배치 모드: 크롤링 대기 중인 연예인들 조회
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

      console.log(`📥 배치 크롤링 시작: ${celebrities.length}명`)

      const results = []
      for (const celeb of celebrities) {
        // Rate limiting: 1초 대기
        await new Promise(resolve => setTimeout(resolve, 1000))

        // 상태를 in_progress로 변경
        await supabase
          .from('celebrities')
          .update({ crawl_status: 'in_progress' })
          .eq('id', celeb.id)

        const html = await fetchNamuWikiPage(celeb.name)

        if (!html) {
          await supabase
            .from('celebrities')
            .update({
              crawl_status: 'failed',
              crawled_at: new Date().toISOString()
            })
            .eq('id', celeb.id)

          results.push({ id: celeb.id, name: celeb.name, success: false, reason: '페이지 없음' })
          continue
        }

        const crawledData = parseNamuWikiProfile(html)

        // DB 업데이트
        const updateData: Record<string, unknown> = {
          crawl_status: 'completed',
          crawled_at: new Date().toISOString(),
          crawl_source: 'namuwiki'
        }

        if (crawledData.birth_time) {
          updateData.birth_time = crawledData.birth_time
          updateData.birth_time_confirmed = crawledData.birth_time_confirmed
        }
        if (crawledData.mbti) updateData.mbti = crawledData.mbti
        if (crawledData.blood_type) updateData.blood_type = crawledData.blood_type

        await supabase
          .from('celebrities')
          .update(updateData)
          .eq('id', celeb.id)

        results.push({
          id: celeb.id,
          name: celeb.name,
          success: true,
          data: {
            birth_time: crawledData.birth_time,
            mbti: crawledData.mbti,
            blood_type: crawledData.blood_type
          }
        })

        console.log(`  ✅ ${celeb.name}: 크롤링 완료`)
      }

      const successCount = results.filter(r => r.success).length

      return new Response(
        JSON.stringify({
          success: true,
          message: `${successCount}/${celebrities.length}명 크롤링 완료`,
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
    let targetId = celebrity_id

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

    console.log(`🔍 크롤링: ${targetName}`)

    const html = await fetchNamuWikiPage(targetName!)

    if (!html) {
      return new Response(
        JSON.stringify({ success: false, error: '페이지를 찾을 수 없습니다' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const crawledData = parseNamuWikiProfile(html)

    // DB 업데이트 (celebrity_id가 있는 경우)
    if (targetId) {
      const updateData: Record<string, unknown> = {
        crawl_status: 'completed',
        crawled_at: new Date().toISOString(),
        crawl_source: 'namuwiki'
      }

      if (crawledData.birth_time) {
        updateData.birth_time = crawledData.birth_time
        updateData.birth_time_confirmed = crawledData.birth_time_confirmed
      }
      if (crawledData.mbti) updateData.mbti = crawledData.mbti
      if (crawledData.blood_type) updateData.blood_type = crawledData.blood_type

      await supabase
        .from('celebrities')
        .update(updateData)
        .eq('id', targetId)
    }

    return new Response(
      JSON.stringify({
        success: true,
        name: targetName,
        data: crawledData
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ 크롤링 오류:', error)
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
