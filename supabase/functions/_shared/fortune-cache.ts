import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Cache duration by fortune type (in milliseconds)
export const CACHE_DURATIONS: Record<string, number> = {
  'daily': 24 * 60 * 60 * 1000,        // 24 hours
  'tomorrow': 24 * 60 * 60 * 1000,     // 24 hours
  'weekly': 7 * 24 * 60 * 60 * 1000,   // 7 days
  'monthly': 30 * 24 * 60 * 60 * 1000, // 30 days
  'yearly': 365 * 24 * 60 * 60 * 1000, // 365 days
  'hourly': 60 * 60 * 1000,            // 1 hour
  'default': 24 * 60 * 60 * 1000       // 24 hours default
}

// Get date range for fortune lookup
export function getDateRange(fortuneType: string): { start: Date; end: Date } {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  
  switch (fortuneType) {
    case 'daily':
    case 'today':
      return {
        start: today,
        end: new Date(today.getTime() + 24 * 60 * 60 * 1000 - 1)
      }
    
    case 'tomorrow':
      const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000)
      return {
        start: tomorrow,
        end: new Date(tomorrow.getTime() + 24 * 60 * 60 * 1000 - 1)
      }
    
    case 'weekly':
      const weekStart = new Date(today)
      weekStart.setDate(today.getDate() - today.getDay()) // Start of week (Sunday)
      const weekEnd = new Date(weekStart)
      weekEnd.setDate(weekStart.getDate() + 6)
      weekEnd.setHours(23, 59, 59, 999)
      return { start: weekStart, end: weekEnd }
    
    case 'monthly':
      const monthStart = new Date(today.getFullYear(), today.getMonth(), 1)
      const monthEnd = new Date(today.getFullYear(), today.getMonth() + 1, 0)
      monthEnd.setHours(23, 59, 59, 999)
      return { start: monthStart, end: monthEnd }
    
    case 'yearly':
      const yearStart = new Date(today.getFullYear(), 0, 1)
      const yearEnd = new Date(today.getFullYear(), 11, 31)
      yearEnd.setHours(23, 59, 59, 999)
      return { start: yearStart, end: yearEnd }
    
    default:
      return { start: today, end: today }
  }
}

// Check both cache and fortunes table
export async function checkExistingFortune(
  userId: string,
  fortuneType: string,
  supabaseUrl: string,
  supabaseKey: string
): Promise<{ found: boolean; data: any; source: 'cache' | 'database' | null }> {
  const supabase = createClient(supabaseUrl, supabaseKey)
  const { start, end } = getDateRange(fortuneType)
  const cacheKey = `${fortuneType}_${userId}_${start.toISOString().split('T')[0]}`
  
  // 1. Check fortune_cache table
  const { data: cached } = await supabase
    .from('fortune_cache')
    .select('fortune_data')
    .eq('cache_key', cacheKey)
    .single()
  
  if (cached) {
    return { found: true, data: cached.fortune_data, source: 'cache' }
  }
  
  // 2. Check fortunes table
  const { data: existingFortune } = await supabase
    .from('fortunes')
    .select('content, metadata')
    .eq('user_id', userId)
    .eq('type', fortuneType)
    .gte('created_at', start.toISOString())
    .lte('created_at', end.toISOString())
    .order('created_at', { ascending: false })
    .limit(1)
    .single()
  
  if (existingFortune) {
    // Re-populate cache with existing fortune
    const fortuneData = existingFortune.content
    const cacheDuration = CACHE_DURATIONS[fortuneType] || CACHE_DURATIONS.default
    
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: userId,
        fortune_type: fortuneType,
        fortune_data: fortuneData,
        expires_at: new Date(Date.now() + cacheDuration).toISOString()
      })
    
    return { found: true, data: fortuneData, source: 'database' }
  }
  
  return { found: false, data: null, source: null }
}