import { Request, Response } from 'express';
import { z } from 'zod';
import logger from '../utils/logger';
import { TokenService } from '../services/token.service';

// Token charge schema
const ChargeTokensSchema = z.object({
  amount: z.number().positive(),
  reason: z.string(),
  referenceId: z.string().optional(),
});

export class TokenController {
  private tokenService: TokenService;

  constructor() {
    this.tokenService = TokenService.getInstance();
  }

  // 토큰 잔액 조회
  async getBalance(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;

      const balance = await this.tokenService.getTokenBalance(userId);

      res.json({
        success: true,
        data: balance,
      });

    } catch (error) {
      logger.error('[TokenController] Error getting balance:', error);
      res.status(500).json({
        success: false,
        error: '토큰 잔액 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 추가 (관리자 전용 또는 시스템 내부 사용)
  async addTokens(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.params.userId || req.userId!;
      const validatedData = ChargeTokensSchema.parse(req.body);

      const result = await this.tokenService.addTokens(
        userId,
        validatedData.amount,
        validatedData.reason,
        validatedData.referenceId
      );

      if (!result.success) {
        res.status(400).json({
          success: false,
          error: '토큰 추가에 실패했습니다.',
        });
        return;
      }

      res.json({
        success: true,
        data: {
          newBalance: result.newBalance,
          amount: validatedData.amount,
        },
        message: '토큰이 성공적으로 추가되었습니다.',
      });

    } catch (error) {
      logger.error('[TokenController] Error adding tokens:', error);

      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: '유효하지 않은 요청 데이터입니다.',
          details: error.errors,
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: '토큰 추가 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 사용 (시스템 내부 사용)
  async useTokens(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const { fortuneCategory, amount } = req.body;

      const result = await this.tokenService.deductTokens(
        userId,
        fortuneCategory || 'general',
        amount
      );

      if (!result.success) {
        res.status(400).json({
          success: false,
          error: result.error || '토큰이 부족합니다.',
        });
        return;
      }

      res.json({
        success: true,
        data: {
          newBalance: result.newBalance,
          deducted: amount,
        },
      });

    } catch (error) {
      logger.error('[TokenController] Error using tokens:', error);
      res.status(500).json({
        success: false,
        error: '토큰 사용 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 거래 내역 조회
  async getHistory(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const limit = parseInt(req.query.limit as string) || 50;

      const history = await this.tokenService.getTokenHistory(userId, limit);

      res.json({
        success: true,
        data: history,
      });

    } catch (error) {
      logger.error('[TokenController] Error getting history:', error);
      res.status(500).json({
        success: false,
        error: '토큰 내역 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 일일 무료 토큰 지급 (크론잡 또는 시스템 호출)
  async grantDailyTokens(req: Request, res: Response): Promise<void> {
    try {
      // 내부 API 키 검증
      const apiKey = req.headers['x-internal-api-key'];
      if (apiKey !== process.env.INTERNAL_API_KEY) {
        res.status(401).json({
          success: false,
          error: '권한이 없습니다.',
        });
        return;
      }

      // 모든 사용자에게 일일 무료 토큰 지급
      const result = await this.tokenService.grantDailyFreeTokens();

      res.json({
        success: true,
        data: {
          usersGranted: result.usersGranted,
          totalTokensGranted: result.totalTokensGranted,
        },
        message: '일일 무료 토큰이 지급되었습니다.',
      });

    } catch (error) {
      logger.error('[TokenController] Error granting daily tokens:', error);
      res.status(500).json({
        success: false,
        error: '일일 토큰 지급 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 환불 (관리자 전용)
  async refundTokens(req: Request, res: Response): Promise<void> {
    try {
      const { userId, amount, reason } = req.body;

      const result = await this.tokenService.addTokens(
        userId,
        amount,
        `환불: ${reason}`
      );

      if (!result.success) {
        res.status(400).json({
          success: false,
          error: '토큰 환불에 실패했습니다.',
        });
        return;
      }

      res.json({
        success: true,
        data: {
          newBalance: result.newBalance,
          refundedAmount: amount,
        },
        message: '토큰이 성공적으로 환불되었습니다.',
      });

    } catch (error) {
      logger.error('[TokenController] Error refunding tokens:', error);
      res.status(500).json({
        success: false,
        error: '토큰 환불 중 오류가 발생했습니다.',
      });
    }
  }
}