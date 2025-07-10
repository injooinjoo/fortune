import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';

// Token consumption rates for different fortune types
const TOKEN_CONSUMPTION_RATES = {
  // Simple fortunes (1 token)
  'daily': 1,
  'today': 1,
  'tomorrow': 1,
  'lucky-color': 1,
  'lucky-number': 1,
  'lucky-food': 1,
  'lucky-outfit': 1,
  'birthstone': 1,
  'blood-type': 1,
  'zodiac': 1,
  'zodiac-animal': 1,
  
  // Medium complexity (2 tokens)
  'love': 2,
  'career': 2,
  'wealth': 2,
  'health': 2,
  'compatibility': 2,
  'tarot': 2,
  'dream': 2,
  'biorhythm': 2,
  'mbti': 2,
  'hourly': 2,
  'weekly': 2,
  'monthly': 2,
  
  // Complex fortunes (3 tokens)
  'saju': 3,
  'traditional-saju': 3,
  'saju-psychology': 3,
  'tojeong': 3,
  'past-life': 3,
  'destiny': 3,
  'marriage': 3,
  'couple-match': 3,
  'chemistry': 3,
  'palmistry': 3,
  'physiognomy': 3,
  'salpuli': 3,
  'traditional-compatibility': 3,
  
  // Premium fortunes (5 tokens)
  'startup': 5,
  'business': 5,
  'lucky-investment': 5,
  'lucky-realestate': 5,
  'celebrity-match': 5,
  'network-report': 5,
  'five-blessings': 5,
  'face-reading': 5,
  'new-year': 5,
  'yearly': 5,
  
  // Sports/hobby fortunes (2 tokens)
  'lucky-golf': 2,
  'lucky-baseball': 2,
  'lucky-tennis': 2,
  'lucky-running': 2,
  'lucky-cycling': 2,
  'lucky-swim': 2,
  'lucky-fishing': 2,
  'lucky-hiking': 2,
  'lucky-yoga': 2,
  'lucky-fitness': 2,
  
  // Financial fortunes (3 tokens)
  'lucky-stock': 3,
  'lucky-crypto': 3,
  'lucky-lottery': 3,
  'employment': 3,
  'lucky-sidejob': 3,
  'lucky-exam': 3,
  'lucky-job': 3,
  
  // Relationship fortunes (2 tokens)
  'ex-lover': 2,
  'blind-date': 2,
  'avoid-people': 2,
  'celebrity': 2,
  
  // Other fortunes (2 tokens)
  'moving': 2,
  'moving-date': 2,
  'personality': 2,
  'talent': 2,
  'wish': 2,
  'timeline': 2,
  'talisman': 2,
  'birth-season': 2,
  'birthdate': 2,
  'lucky-place': 2,
  'lucky-items': 2,
  'lucky-series': 2,
};

export async function GET(request: NextRequest) {
  try {
    return createSuccessResponse({
      rates: TOKEN_CONSUMPTION_RATES
    });
  } catch (error) {
    logger.error('Token consumption rates API error:', error);
    return createErrorResponse('Failed to load consumption rates', undefined, undefined, 500);
  }
}