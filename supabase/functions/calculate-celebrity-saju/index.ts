import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { calculateSaju } from './saju-calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// JSON 파일 읽기
async function loadCelebrityData() {
  const data = await Deno.readTextFile('./celebrity-data.json');
  return JSON.parse(data);
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

    // celebrity-data.json 파일에서 데이터 로드
    const celebrityDataPath = new URL('../../../scripts/celebrity-data.json', import.meta.url).pathname;
    const celebrityDataText = await Deno.readTextFile(celebrityDataPath);
    const celebrityData = JSON.parse(celebrityDataText);
    
    const results = [];
    const errors = [];

    console.log(`총 ${celebrityData.celebrities.length}명의 유명인 데이터 처리 시작`);

    for (const celebrity of celebrityData.celebrities) {
      try {
        console.log(`처리중: ${celebrity.name} (${celebrity.real_name})`);
        
        // 생년월일 파싱
        const birthDate = new Date(celebrity.birth_date);
        
        // 사주 계산
        const sajuResult = calculateSaju(birthDate, celebrity.birth_time);
        
        // 오행 계산
        const woodCount = sajuResult.elementBalance['목'] || 0;
        const fireCount = sajuResult.elementBalance['화'] || 0;
        const earthCount = sajuResult.elementBalance['토'] || 0;
        const metalCount = sajuResult.elementBalance['금'] || 0;
        const waterCount = sajuResult.elementBalance['수'] || 0;
        
        // 데이터베이스 업데이트용 객체 생성
        const dbData = {
          id: `${celebrity.name}_${celebrity.birth_date}`,
          name: celebrity.name,
          name_en: celebrity.name_en || celebrity.name,
          birth_date: celebrity.birth_date,
          birth_time: celebrity.birth_time || '12:00',
          birth_place: celebrity.birth_place || '',
          gender: celebrity.gender,
          category: celebrity.category,
          real_name: celebrity.real_name || celebrity.name,
          
          // 사주 데이터
          year_pillar: sajuResult.yearPillarString,
          month_pillar: sajuResult.monthPillarString,
          day_pillar: sajuResult.dayPillarString,
          hour_pillar: sajuResult.hourPillarString || '',
          saju_string: sajuResult.sajuString,
          
          // 오행 데이터
          wood_count: woodCount,
          fire_count: fireCount,
          earth_count: earthCount,
          metal_count: metalCount,
          water_count: waterCount,
          dominant_element: sajuResult.dominantElement,
          
          // 전체 사주 데이터 (JSON)
          full_saju_data: JSON.stringify({
            year: {
              stem: sajuResult.year.stem,
              branch: sajuResult.year.branch,
              stemHanja: sajuResult.year.stemHanja,
              branchHanja: sajuResult.year.branchHanja
            },
            month: {
              stem: sajuResult.month.stem,
              branch: sajuResult.month.branch,
              stemHanja: sajuResult.month.stemHanja,
              branchHanja: sajuResult.month.branchHanja
            },
            day: {
              stem: sajuResult.day.stem,
              branch: sajuResult.day.branch,
              stemHanja: sajuResult.day.stemHanja,
              branchHanja: sajuResult.day.branchHanja
            },
            hour: sajuResult.hour ? {
              stem: sajuResult.hour.stem,
              branch: sajuResult.hour.branch,
              stemHanja: sajuResult.hour.stemHanja,
              branchHanja: sajuResult.hour.branchHanja
            } : null,
            elements: sajuResult.elementBalance
          }),
          
          data_source: 'manual_with_saju_calculated',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        
        // 데이터베이스에 저장 (upsert)
        const { data, error } = await supabaseClient
          .from('celebrities')
          .upsert(dbData, { onConflict: 'id' })
          .select()
          .single();
        
        if (error) {
          console.error(`${celebrity.name} 저장 실패:`, error);
          errors.push({
            name: celebrity.name,
            error: error.message
          });
        } else {
          console.log(`${celebrity.name} 저장 성공`);
          results.push({
            name: celebrity.name,
            saju: sajuResult.sajuString,
            dominant_element: sajuResult.dominantElement
          });
        }
        
      } catch (error) {
        console.error(`${celebrity.name} 처리 중 오류:`, error);
        errors.push({
          name: celebrity.name,
          error: error.message
        });
      }
    }

    // 결과 요약
    const summary = {
      total: celebrityData.celebrities.length,
      success: results.length,
      failed: errors.length,
      results: results,
      errors: errors
    };

    console.log('처리 완료:', summary);

    return new Response(
      JSON.stringify(summary),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )

  } catch (error) {
    console.error('전체 처리 오류:', error)
    return new Response(
      JSON.stringify({ 
        error: '처리 중 오류가 발생했습니다.', 
        details: error.message 
      }),
      { 
        status: 500, 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )
  }
})