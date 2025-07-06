import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { centralizedFortuneService } from '@/lib/services/centralized-fortune-service';
import { BatchFortuneRequest } from '@/types/batch-fortune';

// 관리자 전용 Supabase 클라이언트
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

// 크론 작업 인증 키 확인
function verifyCronSecret(request: NextRequest): boolean {
  const authHeader = request.headers.get('authorization');
  const cronSecret = process.env.CRON_SECRET;
  
  if (!cronSecret) {
    console.error('CRON_SECRET이 설정되지 않았습니다.');
    return false;
  }
  
  return authHeader === `Bearer ${cronSecret}`;
}

export async function POST(request: NextRequest) {
  try {
    // 크론 작업 인증 확인
    if (!verifyCronSecret(request)) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    console.log('일일 배치 운세 생성 시작...');
    
    // 활성 사용자 목록 조회 (최근 7일 이내 로그인)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const { data: activeUsers, error: usersError } = await supabaseAdmin
      .from('profiles')
      .select('id, name, birth_date, birth_time, gender, mbti, zodiac_sign, relationship_status')
      .gte('last_seen_at', sevenDaysAgo.toISOString())
      .eq('is_active', true)
      .limit(100); // 배치 크기 제한

    if (usersError) {
      console.error('활성 사용자 조회 오류:', usersError);
      return NextResponse.json(
        { error: '사용자 조회 실패', details: usersError },
        { status: 500 }
      );
    }

    if (!activeUsers || activeUsers.length === 0) {
      console.log('활성 사용자가 없습니다.');
      return NextResponse.json({
        success: true,
        message: '활성 사용자가 없습니다.',
        processedCount: 0
      });
    }

    console.log(`${activeUsers.length}명의 활성 사용자 발견`);

    // 각 사용자별로 일일 운세 생성
    const results = [];
    const errors = [];
    
    for (const user of activeUsers) {
      try {
        // 오늘 이미 생성된 운세가 있는지 확인
        const today = new Date().toISOString().split('T')[0];
        const { data: existingBatch } = await supabaseAdmin
          .from('fortune_batches')
          .select('batch_id')
          .eq('user_id', user.id)
          .eq('request_type', 'daily_refresh')
          .gte('created_at', `${today}T00:00:00`)
          .single();

        if (existingBatch) {
          console.log(`사용자 ${user.id}는 오늘 이미 운세가 생성됨`);
          continue;
        }

        // 일일 운세 패키지 생성
        const batchRequest: BatchFortuneRequest = {
          request_type: 'daily_refresh',
          user_profile: {
            id: user.id,
            name: user.name || '사용자',
            birth_date: user.birth_date || '1990-01-01',
            birth_time: user.birth_time,
            gender: user.gender,
            mbti: user.mbti,
            zodiac_sign: user.zodiac_sign,
            relationship_status: user.relationship_status
          },
          fortune_types: ['daily', 'hourly', 'today', 'tomorrow'],
          target_date: today,
          generation_context: {
            cache_duration_hours: 24,
            is_daily_auto_generation: true
          }
        };

        const response = await centralizedFortuneService.callGenkitFortuneAPI(batchRequest);
        
        results.push({
          user_id: user.id,
          batch_id: response.request_id,
          token_usage: response.token_usage
        });

        // 사용자에게 알림 전송 (선택적)
        await sendDailyFortuneNotification(user.id);
        
        // Rate limiting을 위한 짧은 딜레이
        await new Promise(resolve => setTimeout(resolve, 100));
        
      } catch (error) {
        console.error(`사용자 ${user.id} 운세 생성 실패:`, error);
        errors.push({
          user_id: user.id,
          error: error instanceof Error ? error.message : '알 수 없는 오류'
        });
      }
    }

    // 작업 결과 로깅
    const { error: logError } = await supabaseAdmin
      .from('cron_logs')
      .insert({
        job_name: 'daily_batch_fortune',
        status: errors.length === 0 ? 'success' : 'partial_success',
        processed_count: results.length,
        error_count: errors.length,
        details: {
          results,
          errors
        },
        executed_at: new Date().toISOString()
      });

    if (logError) {
      console.error('크론 로그 저장 실패:', logError);
    }

    // 토큰 사용량 집계
    const totalTokens = results.reduce((sum, r) => sum + (r.token_usage?.total_tokens || 0), 0);
    const totalCost = results.reduce((sum, r) => sum + (r.token_usage?.estimated_cost || 0), 0);

    return NextResponse.json({
      success: true,
      message: '일일 배치 운세 생성 완료',
      processedCount: results.length,
      errorCount: errors.length,
      totalTokens,
      totalCost: totalCost.toFixed(4)
    });

  } catch (error) {
    console.error('일일 배치 운세 생성 오류:', error);
    
    // 오류 로깅
    await supabaseAdmin
      .from('cron_logs')
      .insert({
        job_name: 'daily_batch_fortune',
        status: 'error',
        error_message: error instanceof Error ? error.message : '알 수 없는 오류',
        executed_at: new Date().toISOString()
      });

    return NextResponse.json(
      { 
        error: '일일 배치 처리 실패',
        message: error instanceof Error ? error.message : '알 수 없는 오류'
      },
      { status: 500 }
    );
  }
}

// 일일 운세 알림 전송 함수 (구현 필요)
async function sendDailyFortuneNotification(userId: string): Promise<void> {
  try {
    // 푸시 알림 또는 이메일 전송 로직
    // 예: FCM, OneSignal, SendGrid 등 사용
    console.log(`사용자 ${userId}에게 일일 운세 알림 전송`);
    
    // 알림 설정 확인
    const { data: settings } = await supabaseAdmin
      .from('user_settings')
      .select('notifications_enabled, push_token')
      .eq('user_id', userId)
      .single();

    if (settings?.notifications_enabled && settings.push_token) {
      // 실제 알림 전송 로직 구현
      // await sendPushNotification(settings.push_token, {
      //   title: '오늘의 운세가 도착했습니다! 🔮',
      //   body: '당신만을 위한 특별한 운세를 확인해보세요.',
      //   data: { type: 'daily_fortune', date: new Date().toISOString() }
      // });
    }
  } catch (error) {
    console.error('알림 전송 실패:', error);
    // 알림 실패는 전체 프로세스를 중단시키지 않음
  }
}

// GET 요청으로 상태 확인
export async function GET(request: NextRequest) {
  // 크론 작업 상태 확인 (선택적)
  if (!verifyCronSecret(request)) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  try {
    // 최근 크론 실행 기록 조회
    const { data: recentLogs } = await supabaseAdmin
      .from('cron_logs')
      .select('*')
      .eq('job_name', 'daily_batch_fortune')
      .order('executed_at', { ascending: false })
      .limit(10);

    return NextResponse.json({
      status: 'healthy',
      recentExecutions: recentLogs || []
    });
  } catch (error) {
    return NextResponse.json(
      { error: '상태 조회 실패' },
      { status: 500 }
    );
  }
}