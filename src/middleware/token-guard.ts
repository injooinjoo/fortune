import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { tokenService } from '@/lib/services/token-service';
import { FortuneCategory } from '@/lib/types/fortune-system';

export interface TokenGuardOptions {
  fortuneCategory: FortuneCategory;
  customCost?: number;
  skipDeduction?: boolean; // 테스트나 특수한 경우용
}

/**
 * 토큰 차감 미들웨어
 * 운세 API 호출 전에 토큰을 확인하고 차감합니다.
 */
export async function withTokenGuard(
  request: NextRequest,
  userId: string,
  options: TokenGuardOptions,
  handler: () => Promise<NextResponse>
): Promise<NextResponse> {
  try {
    // 토큰 비용 계산
    const tokenCost = options.customCost || getTokenCost(options.fortuneCategory);
    
    // 토큰 잔액 확인
    const tokenBalance = await tokenService.getTokenBalance(userId);
    
    // 무제한 사용자는 통과
    if (tokenBalance.isUnlimited) {
      logger.debug(`🎫 무제한 사용자: ${userId} (${tokenBalance.subscriptionPlan})`);
      
      // 차감 없이 사용 기록만
      if (!options.skipDeduction) {
        await tokenService.deductTokens(userId, options.fortuneCategory, 0);
      }
      
      const response = await handler();
      
      // 응답에 토큰 정보 추가
      if (response.status === 200) {
        const data = await response.json();
        return NextResponse.json({
          ...data,
          token_info: {
            cost: 0,
            remaining_balance: tokenBalance.balance,
            is_unlimited: true,
            subscription_plan: tokenBalance.subscriptionPlan
          }
        });
      }
      
      return response;
    }
    
    // 잔액 부족 체크
    if (tokenBalance.balance < tokenCost) {
      logger.debug(`❌ 토큰 부족: ${userId} (필요: ${tokenCost}, 보유: ${tokenBalance.balance})`);
      
      return NextResponse.json(
        {
          error: '토큰이 부족합니다.',
          error_code: 'INSUFFICIENT_TOKENS',
          required_tokens: tokenCost,
          current_balance: tokenBalance.balance,
          subscription_plan: tokenBalance.subscriptionPlan,
          purchase_url: '/payment/tokens'
        },
        { status: 402 } // Payment Required
      );
    }
    
    // 토큰 차감 (skipDeduction이 true가 아닌 경우에만)
    if (!options.skipDeduction) {
      const deductionResult = await tokenService.deductTokens(
        userId, 
        options.fortuneCategory,
        tokenCost
      );
      
      if (!deductionResult.success) {
        logger.error(`❌ 토큰 차감 실패: ${userId}`, deductionResult.error);
        
        return NextResponse.json(
          {
            error: deductionResult.error || '토큰 차감에 실패했습니다.',
            error_code: 'TOKEN_DEDUCTION_FAILED',
            current_balance: deductionResult.newBalance
          },
          { status: 500 }
        );
      }
      
      logger.debug(`✅ 토큰 차감 성공: ${userId} (-${tokenCost}, 잔액: ${deductionResult.newBalance})`);
    }
    
    // 핸들러 실행
    const response = await handler();
    
    // 성공 응답에 토큰 정보 추가
    if (response.status === 200) {
      const data = await response.json();
      const newBalance = await tokenService.getTokenBalance(userId);
      
      return NextResponse.json({
        ...data,
        token_info: {
          cost: options.skipDeduction ? 0 : tokenCost,
          remaining_balance: newBalance.balance,
          is_unlimited: newBalance.isUnlimited,
          subscription_plan: newBalance.subscriptionPlan
        }
      });
    }
    
    return response;
    
  } catch (error) {
    logger.error('토큰 가드 오류:', error);
    
    return NextResponse.json(
      {
        error: '토큰 처리 중 오류가 발생했습니다.',
        error_code: 'TOKEN_GUARD_ERROR'
      },
      { status: 500 }
    );
  }
}

/**
 * 운세 카테고리별 토큰 비용 (중앙화)
 */
function getTokenCost(fortuneCategory: FortuneCategory): number {
  const tokenCosts: Partial<Record<FortuneCategory, number>> = {
    // 간단한 운세 (1 토큰)
    'daily': 1,
    'today': 1,
    'tomorrow': 1,
    'hourly': 1,
    'lucky-color': 1,
    'lucky-number': 1,
    'lucky-food': 1,
    'lucky-outfit': 1,
    'lucky-items': 1,
    'birthstone': 1,
    'blood-type': 1,
    'zodiac': 1,
    'zodiac-animal': 1,
    'birth-season': 1,
    
    // 중간 복잡도 운세 (2 토큰)
    'love': 2,
    'career': 2,
    'wealth': 2,
    'health': 2,
    'compatibility': 2,
    'tarot': 2,
    'dream-interpretation': 2,
    'biorhythm': 2,
    'mbti': 2,
    'employment': 2,
    'avoid-people': 2,
    'worry-bead': 2,
    'birthdate': 2,
    'timeline': 2,
    
    // 복잡한 운세 (3 토큰)
    'saju': 3,
    'traditional-saju': 3,
    'saju-psychology': 3,
    'tojeong': 3,
    'past-life': 3,
    'destiny': 3,
    'marriage': 3,
    'couple-match': 3,
    'chemistry': 3,
    'ex-lover': 3,
    'blind-date': 3,
    'traditional-compatibility': 3,
    'salpuli': 3,
    'talent': 3,
    'palmistry': 3,
    'physiognomy': 3,
    'moving': 3,
    'moving-date': 3,
    'new-year': 3,
    
    // 프리미엄 운세 (5 토큰)
    'startup': 5,
    'business': 5,
    'lucky-investment': 5,
    'lucky-realestate': 5,
    'celebrity-match': 5,
    'network-report': 5,
    'five-blessings': 5,
    'lucky-job': 5,
    'lucky-sidejob': 5,
    'lucky-golf': 5,
    'lucky-tennis': 5,
    'lucky-baseball': 5,
    'lucky-fishing': 5,
    'lucky-hiking': 5,
    'lucky-cycling': 5,
    'lucky-swim': 5,
    'lucky-running': 5,
    'lucky-exam': 5,
    
    // 특수 운세
    'wish': 1,
    'talisman': 2,
    'personality': 2,
    'celebrity': 2,
    'face-reading': 3,
    'generate': 3
  };
  
  return tokenCosts[fortuneCategory] || 1;
}