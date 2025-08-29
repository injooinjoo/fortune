import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { DOMParser } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts"

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
  debut?: string;
  agency?: string;
  occupation?: string;
  aliases?: string[];
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

    const { name, forceUpdate = false, masterItemId = null } = await req.json()

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

    // 데이터베이스 업데이트 (celebrities 테이블)
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
        additional_info: {
          debut: celebrityInfo.debut,
          agency: celebrityInfo.agency,
          occupation: celebrityInfo.occupation,
          aliases: celebrityInfo.aliases,
          crawled_at: new Date().toISOString(),
          source_url: `https://namu.wiki/w/${encodeURIComponent(name)}`,
        },
        popularity_score: 50, // 기본값
        updated_at: new Date().toISOString(),
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

    // celebrity_master_list 상태 업데이트 (masterItemId가 제공된 경우)
    if (masterItemId) {
      try {
        const { error: masterUpdateError } = await supabaseClient
          .from('celebrity_master_list')
          .update({
            is_crawled: true,
            updated_at: new Date().toISOString(),
          })
          .eq('id', masterItemId)

        if (masterUpdateError) {
          console.warn('마스터 리스트 업데이트 실패:', masterUpdateError)
          // 이건 크리티컬하지 않으므로 warning만 출력하고 계속 진행
        } else {
          console.log(`마스터 리스트 상태 업데이트 완료: ${masterItemId}`)
        }
      } catch (masterError) {
        console.warn('마스터 리스트 업데이트 중 오류:', masterError)
      }
    }

    return new Response(
      JSON.stringify({
        message: '성공적으로 크롤링되었습니다.',
        data: data,
        updated: true,
        masterItemUpdated: !!masterItemId
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
    const wikiUrl = `https://namu.wiki/w/${encodeURIComponent(name)}`
    
    console.log(`크롤링 시작: ${wikiUrl}`)
    
    const response = await fetch(wikiUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'ko-KR,ko;q=0.8,en-US;q=0.5,en;q=0.3',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      }
    })

    if (!response.ok) {
      console.log(`HTTP 오류: ${response.status} for ${name}`)
      return null
    }

    const html = await response.text()
    
    // DOM 파서 초기화
    const doc = new DOMParser().parseFromString(html, "text/html")
    
    if (!doc) {
      console.log(`HTML 파싱 실패: ${name}`)
      return null
    }

    // 나무위키 정보박스 파싱
    const infoBox = doc.querySelector('.wiki-table-wrap') || doc.querySelector('.wiki-macro-include')
    
    const info: CelebrityInfo = {
      name: name,
      description: extractDescription(doc, name),
      profile_image_url: extractProfileImage(doc),
      keywords: extractKeywords(doc, name),
      category: extractCategoryFromInfoBox(infoBox, html),
      gender: extractGenderFromInfoBox(infoBox, html),
      birth_date: extractBirthDateFromInfoBox(infoBox, html),
      birth_time: '12:00', // 기본값
      debut: extractDebut(infoBox, html),
      agency: extractAgency(infoBox, html),
      occupation: extractOccupation(infoBox, html),
      aliases: extractAliases(doc, name),
    }

    console.log(`크롤링 완료 - ${name}: ${JSON.stringify(info)}`)
    return info

  } catch (error) {
    console.error(`크롤링 오류 (${name}):`, error)
    return null
  }
}

// 나무위키 정보박스에서 카테고리 추출
function extractCategoryFromInfoBox(infoBox: Element | null, html: string): string {
  if (infoBox) {
    const infoText = infoBox.textContent || ''
    // 정보박스에서 직업 정보 우선 확인
    if (infoText.includes('배우') || infoText.includes('연기자')) return 'actor'
    if (infoText.includes('가수') || infoText.includes('음악가') || infoText.includes('보컬')) return 'singer'
    if (infoText.includes('정치인') || infoText.includes('대통령') || infoText.includes('의원') || infoText.includes('시장') || infoText.includes('도지사')) return 'politician'
    if (infoText.includes('운동선수') || infoText.includes('축구선수') || infoText.includes('야구선수') || infoText.includes('골퍼')) return 'sports'
    if (infoText.includes('스트리머') || infoText.includes('BJ')) return 'streamer'
    if (infoText.includes('유튜버') || infoText.includes('크리에이터')) return 'youtuber'
    if (infoText.includes('개그맨') || infoText.includes('코미디언') || infoText.includes('방송인')) return 'entertainer'
    if (infoText.includes('프로게이머') || infoText.includes('게이머')) return 'pro_gamer'
    if (infoText.includes('기업인') || infoText.includes('CEO') || infoText.includes('회장') || infoText.includes('대표')) return 'business_leader'
  }
  
  // 전체 HTML에서 검색
  if (html.includes('배우') || html.includes('연기자')) return 'actor'
  if (html.includes('가수') || html.includes('음악가')) return 'singer'
  if (html.includes('정치인') || html.includes('대통령') || html.includes('의원')) return 'politician'
  if (html.includes('운동선수') || html.includes('선수')) return 'sports'
  if (html.includes('스트리머') || html.includes('BJ')) return 'streamer'
  if (html.includes('유튜버')) return 'youtuber'
  if (html.includes('개그맨') || html.includes('방송인')) return 'entertainer'
  if (html.includes('프로게이머')) return 'pro_gamer'
  if (html.includes('기업인') || html.includes('회장')) return 'business_leader'
  
  return 'entertainer'
}

// 나무위키 정보박스에서 성별 추출
function extractGenderFromInfoBox(infoBox: Element | null, html: string): 'male' | 'female' {
  const searchText = infoBox?.textContent || html
  
  // 여성 키워드 우선 검색 (더 구체적이므로)
  if (searchText.includes('여성') || searchText.includes('여배우') || searchText.includes('여가수') || 
      searchText.includes('그녀') || searchText.includes('걸그룹') || searchText.includes('여자') ||
      searchText.includes('언니') || searchText.includes('누나')) {
    return 'female'
  }
  
  return 'male' // 기본값
}

// 나무위키에서 생년월일 추출 (다양한 형식 지원)
function extractBirthDateFromInfoBox(infoBox: Element | null, html: string): string | undefined {
  const searchText = infoBox?.textContent || html
  
  // 다양한 생년월일 형식 시도
  const patterns = [
    /(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일/g, // 1990년 1월 1일
    /(\d{4})\.\s*(\d{1,2})\.\s*(\d{1,2})\./g, // 1990. 1. 1.
    /(\d{4})-(\d{1,2})-(\d{1,2})/g, // 1990-01-01
    /(\d{4})\/(\d{1,2})\/(\d{1,2})/g, // 1990/01/01
  ]
  
  for (const pattern of patterns) {
    const matches = Array.from(searchText.matchAll(pattern))
    for (const match of matches) {
      const [, year, month, day] = match
      const yearNum = parseInt(year)
      const monthNum = parseInt(month)
      const dayNum = parseInt(day)
      
      // 유효한 날짜인지 확인 (1900-2010 범위의 연예인 생년월일)
      if (yearNum >= 1900 && yearNum <= 2010 && monthNum >= 1 && monthNum <= 12 && dayNum >= 1 && dayNum <= 31) {
        return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
      }
    }
  }
  
  return undefined
}

// 프로필 이미지 추출
function extractProfileImage(doc: Document): string | undefined {
  // 나무위키 이미지 선택자들
  const imageSelectors = [
    '.wiki-image img',
    '.wiki-macro-include img',
    '.wiki-table-wrap img',
    'img[src*="namu.wiki"]',
    'img[alt*="프로필"]',
  ]
  
  for (const selector of imageSelectors) {
    const img = doc.querySelector(selector) as HTMLImageElement
    if (img && img.src) {
      // 상대 경로를 절대 경로로 변환
      if (img.src.startsWith('//')) {
        return `https:${img.src}`
      } else if (img.src.startsWith('/')) {
        return `https://namu.wiki${img.src}`
      } else if (img.src.startsWith('http')) {
        return img.src
      }
    }
  }
  
  return undefined
}

// 설명 추출 (첫 번째 문단)
function extractDescription(doc: Document, name: string): string {
  // 나무위키 문서의 첫 번째 문단 찾기
  const paragraphs = doc.querySelectorAll('.wiki-paragraph, .wiki-content p, .wiki-content > div')
  
  for (const p of paragraphs) {
    const text = p.textContent?.trim()
    if (text && text.length > 20 && !text.includes('분류:') && !text.includes('틀:')) {
      return text.length > 200 ? text.substring(0, 200) + '...' : text
    }
  }
  
  return `${name}에 대한 정보`
}

// 키워드 추출
function extractKeywords(doc: Document, name: string): string[] {
  const keywords = new Set([name])
  
  // 문서에서 자주 언급되는 키워드들 추출
  const text = doc.textContent || ''
  const commonKeywords = [
    '데뷔', '활동', '출연', '발매', '앨범', '드라마', '영화', '방송',
    '소속사', '레이블', '그룹', '멤버', '대표곡', '히트곡'
  ]
  
  commonKeywords.forEach(keyword => {
    if (text.includes(keyword)) {
      keywords.add(keyword)
    }
  })
  
  return Array.from(keywords).slice(0, 10) // 최대 10개
}

// 데뷔 정보 추출
function extractDebut(infoBox: Element | null, html: string): string | undefined {
  const searchText = infoBox?.textContent || html
  
  const debutPatterns = [
    /데뷔[:\s]*(\d{4}년?[^년\n\r]*)/g,
    /데뷔작[:\s]*([^\n\r]*)/g,
    /첫\s*앨범[:\s]*([^\n\r]*)/g,
  ]
  
  for (const pattern of debutPatterns) {
    const match = searchText.match(pattern)
    if (match && match[1]) {
      return match[1].trim()
    }
  }
  
  return undefined
}

// 소속사/에이전시 추출
function extractAgency(infoBox: Element | null, html: string): string | undefined {
  const searchText = infoBox?.textContent || html
  
  const agencyPatterns = [
    /소속사[:\s]*([^\n\r]*)/g,
    /소속[:\s]*([^\n\r]*)/g,
    /에이전시[:\s]*([^\n\r]*)/g,
    /레이블[:\s]*([^\n\r]*)/g,
  ]
  
  for (const pattern of agencyPatterns) {
    const match = searchText.match(pattern)
    if (match && match[1]) {
      const agency = match[1].trim()
      if (agency && agency.length > 1 && agency.length < 50) {
        return agency
      }
    }
  }
  
  return undefined
}

// 직업 추출
function extractOccupation(infoBox: Element | null, html: string): string | undefined {
  const searchText = infoBox?.textContent || html
  
  const occupationPatterns = [
    /직업[:\s]*([^\n\r]*)/g,
    /활동[:\s]*([^\n\r]*)/g,
    /분야[:\s]*([^\n\r]*)/g,
  ]
  
  for (const pattern of occupationPatterns) {
    const match = searchText.match(pattern)
    if (match && match[1]) {
      const occupation = match[1].trim()
      if (occupation && occupation.length > 1 && occupation.length < 30) {
        return occupation
      }
    }
  }
  
  return undefined
}

// 별명/예명 추출
function extractAliases(doc: Document, name: string): string[] {
  const aliases = new Set<string>()
  const text = doc.textContent || ''
  
  // 별명이나 예명 패턴 찾기
  const aliasPatterns = [
    /별명[:\s]*([^\n\r]*)/g,
    /애칭[:\s]*([^\n\r]*)/g,
    /예명[:\s]*([^\n\r]*)/g,
    /본명[:\s]*([^\n\r]*)/g,
  ]
  
  for (const pattern of aliasPatterns) {
    const matches = Array.from(text.matchAll(pattern))
    for (const match of matches) {
      if (match[1]) {
        const alias = match[1].trim()
        if (alias && alias !== name && alias.length > 1 && alias.length < 20) {
          aliases.add(alias)
        }
      }
    }
  }
  
  return Array.from(aliases).slice(0, 5) // 최대 5개
}