/**
 * Instagram Profile Image Scraper
 *
 * RapidAPI Instagram Scraper API를 사용하여 프로필 이미지를 가져옵니다.
 * API: https://rapidapi.com/restyler/api/instagram-scraper-api2
 */

interface InstagramProfileData {
  username: string
  full_name: string
  profile_pic_url: string
  profile_pic_url_hd: string
  is_private: boolean
  is_verified: boolean
}

interface InstagramScraperResponse {
  status: string
  data: InstagramProfileData
}

/**
 * Instagram URL에서 username 추출
 * @param url - Instagram URL 또는 username
 * @returns username
 */
export function extractUsername(url: string): string {
  // URL이 아닌 경우 그대로 반환
  if (!url.includes('/')) {
    return url.replace('@', '')
  }

  // https://www.instagram.com/username/ → username
  // https://instagram.com/username → username
  const match = url.match(/instagram\.com\/([^\/\?]+)/)
  if (match && match[1]) {
    return match[1].replace('@', '')
  }

  // 매칭 실패 시 원본 반환 (@ 제거)
  return url.replace('@', '')
}

/**
 * Instagram 프로필 이미지 URL 가져오기 (RapidAPI)
 * @param username - Instagram username (@ 제외)
 * @returns HD 프로필 이미지 URL
 */
export async function fetchInstagramProfileImage(username: string): Promise<string> {
  const apiKey = Deno.env.get('RAPIDAPI_KEY')

  if (!apiKey) {
    throw new Error('RAPIDAPI_KEY 환경변수가 설정되지 않았습니다.')
  }

  console.log(`📸 [Instagram] Fetching profile image for: ${username}`)

  try {
    const response = await fetch(
      `https://instagram-scraper-api2.p.rapidapi.com/v1/info?username_or_id_or_url=${username}`,
      {
        method: 'GET',
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': 'instagram-scraper-api2.p.rapidapi.com'
        }
      }
    )

    if (!response.ok) {
      throw new Error(`Instagram API 요청 실패: ${response.status} ${response.statusText}`)
    }

    const data: InstagramScraperResponse = await response.json()

    if (data.status !== 'ok' || !data.data) {
      throw new Error('Instagram 프로필을 찾을 수 없습니다.')
    }

    if (data.data.is_private) {
      throw new Error('비공개 계정입니다. 공개 계정만 분석 가능합니다.')
    }

    const profileImageUrl = data.data.profile_pic_url_hd || data.data.profile_pic_url

    if (!profileImageUrl) {
      throw new Error('프로필 이미지를 찾을 수 없습니다.')
    }

    console.log(`✅ [Instagram] Profile image found: ${data.data.full_name} (@${data.data.username})`)
    console.log(`   URL: ${profileImageUrl}`)

    return profileImageUrl
  } catch (error) {
    console.error(`❌ [Instagram] Error fetching profile image:`, error)
    throw error
  }
}

/**
 * 이미지 URL을 Base64로 변환
 * @param imageUrl - 이미지 URL
 * @returns Base64 인코딩된 이미지 문자열
 */
export async function downloadAndEncodeImage(imageUrl: string): Promise<string> {
  console.log(`⬇️  [Instagram] Downloading image: ${imageUrl}`)

  try {
    const response = await fetch(imageUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      }
    })

    if (!response.ok) {
      throw new Error(`이미지 다운로드 실패: ${response.status} ${response.statusText}`)
    }

    const imageBuffer = await response.arrayBuffer()
    const uint8Array = new Uint8Array(imageBuffer)

    // 이미지 크기 확인 (5MB 제한)
    const sizeMB = imageBuffer.byteLength / 1024 / 1024
    console.log(`📏 [Instagram] Image size: ${sizeMB.toFixed(2)} MB`)

    if (sizeMB > 5) {
      throw new Error('이미지 크기가 5MB를 초과합니다.')
    }

    // Base64 인코딩
    const base64 = btoa(String.fromCharCode(...uint8Array))

    console.log(`✅ [Instagram] Image encoded to Base64 (${base64.length} chars)`)

    return base64
  } catch (error) {
    console.error(`❌ [Instagram] Error downloading/encoding image:`, error)
    throw error
  }
}

/**
 * Instagram URL 유효성 검증
 * @param url - 검증할 URL
 * @returns 유효성 여부
 */
export function isValidInstagramUrl(url: string): boolean {
  // instagram.com 포함 여부
  if (!url.includes('instagram.com/')) {
    return false
  }

  // 게시물 URL 제외 (/p/, /reel/, /tv/)
  if (url.includes('/p/') || url.includes('/reel/') || url.includes('/tv/')) {
    return false
  }

  // 프로필 URL 패턴 매칭
  const profilePattern = /instagram\.com\/[a-zA-Z0-9._]+\/?$/
  return profilePattern.test(url)
}
