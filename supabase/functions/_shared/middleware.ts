import { corsHeaders } from './cors.ts'

// Request debouncing to prevent duplicate requests
const requestCache = new Map<string, Promise<Response>>()
const REQUEST_CACHE_TTL = 5000 // 5 seconds

export function debounceRequest(
  key: string,
  requestHandler: () => Promise<Response>
): Promise<Response> {
  // Check if there's already a pending request
  const cached = requestCache.get(key)
  if (cached) {
    console.log(`Debounced duplicate request: ${key}`)
    return cached
  }

  // Create new request promise
  const requestPromise = requestHandler()
    .finally(() => {
      // Clean up after TTL
      setTimeout(() => {
        requestCache.delete(key)
      }, REQUEST_CACHE_TTL)
    })

  requestCache.set(key, requestPromise)
  return requestPromise
}

// Compression middleware
export async function compressResponse(
  response: Response,
  acceptEncoding: string | null
): Promise<Response> {
  // Check if client accepts compression
  if (!acceptEncoding) return response
  
  const supportsGzip = acceptEncoding.includes('gzip')
  const supportsBrotli = acceptEncoding.includes('br')
  
  if (!supportsGzip && !supportsBrotli) return response
  
  // Get response body
  const body = await response.text()
  
  // Skip compression for small responses
  if (body.length < 1000) return response
  
  let compressedBody: Uint8Array
  let encoding: string
  
  if (supportsBrotli) {
    // Brotli compression (better ratio)
    const encoder = new TextEncoder()
    const data = encoder.encode(body)
    compressedBody = await compressData(data, 'br')
    encoding = 'br'
  } else {
    // Gzip compression (wider support)
    const encoder = new TextEncoder()
    const data = encoder.encode(body)
    compressedBody = await compressData(data, 'gzip')
    encoding = 'gzip'
  }
  
  // Create new response with compressed body
  return new Response(compressedBody, {
    status: response.status,
    headers: {
      ...Object.fromEntries(response.headers.entries()),
      'Content-Encoding': encoding,
      'Vary': 'Accept-Encoding',
      'Content-Length': compressedBody.length.toString()
    }
  })
}

async function compressData(data: Uint8Array, type: 'gzip' | 'br'): Promise<Uint8Array> {
  if (type === 'gzip') {
    const compressionStream = new CompressionStream('gzip')
    const writer = compressionStream.writable.getWriter()
    writer.write(data)
    writer.close()
    
    const chunks: Uint8Array[] = []
    const reader = compressionStream.readable.getReader()
    
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      chunks.push(value)
    }
    
    // Combine chunks
    const totalLength = chunks.reduce((sum, chunk) => sum + chunk.length, 0)
    const result = new Uint8Array(totalLength)
    let offset = 0
    for (const chunk of chunks) {
      result.set(chunk, offset)
      offset += chunk.length
    }
    
    return result
  }
  
  // For brotli, we'd need a proper library
  // For now, fallback to gzip
  return compressData(data, 'gzip')
}

// Rate limiting middleware
const rateLimitMap = new Map<string, number[]>()
const RATE_LIMIT_WINDOW = 60000 // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 30 // 30 requests per minute

export function checkRateLimit(clientId: string): { allowed: boolean; remaining: number } {
  const now = Date.now()
  const requests = rateLimitMap.get(clientId) || []
  
  // Filter out old requests
  const recentRequests = requests.filter(time => now - time < RATE_LIMIT_WINDOW)
  
  if (recentRequests.length >= RATE_LIMIT_MAX_REQUESTS) {
    return { allowed: false, remaining: 0 }
  }
  
  // Add current request
  recentRequests.push(now)
  rateLimitMap.set(clientId, recentRequests)
  
  // Clean up old entries periodically
  if (Math.random() < 0.01) { // 1% chance
    for (const [key, times] of rateLimitMap.entries()) {
      const recent = times.filter(time => now - time < RATE_LIMIT_WINDOW)
      if (recent.length === 0) {
        rateLimitMap.delete(key)
      } else {
        rateLimitMap.set(key, recent)
      }
    }
  }
  
  return { 
    allowed: true, 
    remaining: RATE_LIMIT_MAX_REQUESTS - recentRequests.length 
  }
}

// ETag support for caching
export function generateETag(content: string): string {
  // Simple hash function for ETag
  let hash = 0
  for (let i = 0; i < content.length; i++) {
    const char = content.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash // Convert to 32bit integer
  }
  return `"${Math.abs(hash).toString(36)}"`
}

export function handleETag(
  req: Request,
  content: string,
  headers: Record<string, string> = {}
): Response | null {
  const etag = generateETag(content)
  const ifNoneMatch = req.headers.get('If-None-Match')
  
  if (ifNoneMatch === etag) {
    // Content hasn't changed
    return new Response(null, {
      status: 304,
      headers: {
        ...corsHeaders,
        ...headers,
        'ETag': etag,
        'Cache-Control': 'private, max-age=3600'
      }
    })
  }
  
  // Add ETag to headers
  headers['ETag'] = etag
  return null
}