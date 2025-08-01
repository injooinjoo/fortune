import { connect } from 'https://deno.land/x/redis@v0.32.3/mod.ts'

// Redis client singleton
let redisClient: any = null

export async function getRedisClient() {
  if (!redisClient) {
    const redisUrl = Deno.env.get('REDIS_URL')
    if (!redisUrl) {
      console.warn('Redis URL not configured, caching disabled')
      return null
    }

    try {
      redisClient = await connect({
        hostname: new URL(redisUrl).hostname,
        port: parseInt(new URL(redisUrl).port || '6379'),
        password: new URL(redisUrl).password || undefined,
      })
    } catch (error) {
      console.error('Failed to connect to Redis:', error)
      return null
    }
  }
  
  return redisClient
}

export async function getCachedData(key: string): Promise<any | null> {
  try {
    const client = await getRedisClient()
    if (!client) return null
    
    const data = await client.get(key)
    if (data) {
      return JSON.parse(data)
    }
    return null
  } catch (error) {
    console.error('Redis get error:', error)
    return null
  }
}

export async function setCachedData(
  key: string, 
  data: any, 
  ttlSeconds: number = 86400 // 24 hours default
): Promise<boolean> {
  try {
    const client = await getRedisClient()
    if (!client) return false
    
    await client.setex(key, ttlSeconds, JSON.stringify(data))
    return true
  } catch (error) {
    console.error('Redis set error:', error)
    return false
  }
}

export async function invalidateCache(pattern: string): Promise<boolean> {
  try {
    const client = await getRedisClient()
    if (!client) return false
    
    const keys = await client.keys(pattern)
    if (keys.length > 0) {
      await client.del(...keys)
    }
    return true
  } catch (error) {
    console.error('Redis invalidate error:', error)
    return false
  }
}

// Performance monitoring helpers
export async function incrementCounter(key: string): Promise<number | null> {
  try {
    const client = await getRedisClient()
    if (!client) return null
    
    return await client.incr(key)
  } catch (error) {
    console.error('Redis incr error:', error)
    return null
  }
}

export async function recordMetric(
  metricName: string, 
  value: number,
  tags: Record<string, string> = {}
): Promise<void> {
  try {
    const client = await getRedisClient()
    if (!client) return
    
    const timestamp = Date.now()
    const metricKey = `metric:${metricName}:${timestamp}`
    const metricData = {
      value,
      timestamp,
      tags
    }
    
    // Store metric with 7 day TTL
    await client.setex(metricKey, 604800, JSON.stringify(metricData))
    
    // Update aggregated metrics
    await client.zadd(`metrics:${metricName}:sorted`, timestamp, metricKey)
  } catch (error) {
    console.error('Redis metric error:', error)
  }
}