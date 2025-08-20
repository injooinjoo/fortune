import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface AuspiciousDay {
  date: string;
  lunar_date: string;
  lunar_day: number;
  score: number;
  description: string;
  directions: {
    east: number;
    west: number;
    south: number;
    north: number;
    general: number;
  };
}

// 음력 변환 함수 (간단한 근사치 사용)
function getLunarDay(date: Date): number {
  // 실제 음력 변환은 복잡하므로, 여기서는 간단한 패턴 사용
  // 실제 구현시에는 정확한 음력 라이브러리 사용 필요
  const dayOfYear = Math.floor((date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / (1000 * 60 * 60 * 24));
  return (dayOfYear % 30) + 1; // 임시 계산
}

// 손없는날 점수 계산
function calculateAuspiciousScore(lunarDay: number, direction: 'east' | 'west' | 'south' | 'north' | 'general' = 'general'): number {
  const lastDigit = lunarDay % 10;
  
  // 손없는날은 음력 끝자리가 9, 0인 날
  if (lastDigit !== 9 && lastDigit !== 0) {
    return 0; // 손없는날이 아님
  }
  
  // 방위별 점수 계산
  const baseScore = lastDigit === 0 ? 100 : 95; // 0일이 더 좋음
  
  switch (direction) {
    case 'east':
      return Math.max(baseScore - 5, 85); // 동쪽 이사
    case 'west':
      return Math.max(baseScore - 3, 87); // 서쪽 이사  
    case 'south':
      return Math.max(baseScore - 7, 83); // 남쪽 이사
    case 'north':
      return Math.max(baseScore - 10, 80); // 북쪽 이사
    case 'general':
    default:
      return baseScore;
  }
}

// 특정 월의 모든 손없는날 계산
function calculateAuspiciousDaysForMonth(year: number, month: number): AuspiciousDay[] {
  const auspiciousDays: AuspiciousDay[] = [];
  const daysInMonth = new Date(year, month, 0).getDate();
  
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month - 1, day);
    const lunarDay = getLunarDay(date);
    const generalScore = calculateAuspiciousScore(lunarDay, 'general');
    
    // 손없는날인 경우만 추가
    if (generalScore > 0) {
      const dateString = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
      const lunarDateString = `음력 ${lunarDay}일`;
      
      const auspiciousDay: AuspiciousDay = {
        date: dateString,
        lunar_date: lunarDateString,
        lunar_day: lunarDay,
        score: generalScore,
        description: `손없는날 - 이사하기 ${generalScore >= 95 ? '매우 좋은' : '좋은'} 날`,
        directions: {
          east: calculateAuspiciousScore(lunarDay, 'east'),
          west: calculateAuspiciousScore(lunarDay, 'west'),
          south: calculateAuspiciousScore(lunarDay, 'south'),
          north: calculateAuspiciousScore(lunarDay, 'north'),
          general: generalScore,
        }
      };
      
      auspiciousDays.push(auspiciousDay);
    }
  }
  
  return auspiciousDays;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { year, month } = await req.json();

    if (!year || !month) {
      return new Response(
        JSON.stringify({ error: 'Year and month are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    console.log(`Calculating auspicious days for ${year}-${month}`);

    const auspiciousDays = calculateAuspiciousDaysForMonth(year, month);

    const response = {
      year,
      month,
      auspicious_days: auspiciousDays,
      calculated_at: new Date().toISOString(),
    };

    return new Response(
      JSON.stringify(response),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    console.error('Error calculating auspicious days:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
})