import { Request, Response } from 'express';
import { z } from 'zod';
import logger from '../utils/logger';
import { UserService } from '../services/user.service';
import { TokenService } from '../services/token.service';

// Profile validation schema
const ProfileSchema = z.object({
  name: z.string().min(1).max(100),
  birth_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  birth_time: z.string().optional(),
  gender: z.enum(['male', 'female', 'other']).optional(),
  mbti: z.string().length(4).optional(),
  blood_type: z.enum(['A', 'B', 'AB', 'O']).optional(),
  job: z.string().optional(),
  location: z.string().optional(),
  marital_status: z.enum(['single', 'married', 'divorced', 'other']).optional(),
  interests: z.array(z.string()).optional(),
});

// Token history query schema
const TokenHistoryQuerySchema = z.object({
  page: z.string().optional().transform(val => val ? parseInt(val) : 1),
  limit: z.string().optional().transform(val => val ? parseInt(val) : 20),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
  type: z.enum(['usage', 'purchase', 'all']).optional(),
});

export class UserController {
  private userService: UserService;
  private tokenService: TokenService;

  constructor() {
    this.userService = UserService.getInstance();
    this.tokenService = TokenService.getInstance();
  }

  // 프로필 조회
  async getProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const userEmail = req.userEmail!;

      const profile = await this.userService.getProfile(userId);

      if (!profile) {
        // 프로필이 없으면 기본 정보 반환
        res.json({
          success: true,
          data: {
            id: userId,
            email: userEmail,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          },
        });
        return;
      }

      res.json({
        success: true,
        data: profile,
      });

    } catch (error) {
      logger.error('[UserController] Error getting profile:', error);
      res.status(500).json({
        success: false,
        error: '프로필 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 프로필 생성/업데이트
  async updateProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const userEmail = req.userEmail!;
      
      const validatedData = ProfileSchema.parse(req.body);

      const profile = await this.userService.updateProfile(userId, userEmail, validatedData);

      res.json({
        success: true,
        data: profile,
        message: '프로필이 업데이트되었습니다.',
      });

    } catch (error) {
      logger.error('[UserController] Error updating profile:', error);

      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: '유효하지 않은 프로필 데이터입니다.',
          details: error.errors,
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: '프로필 업데이트 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 잔액 조회
  async getTokenBalance(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;

      const balance = await this.tokenService.getTokenBalance(userId);
      const stats = await this.userService.getTokenStats(userId);

      res.json({
        success: true,
        data: {
          ...balance,
          totalPurchased: stats.totalPurchased,
          totalUsed: stats.totalUsed,
          totalBonus: stats.totalBonus,
        },
      });

    } catch (error) {
      logger.error('[UserController] Error getting token balance:', error);
      res.status(500).json({
        success: false,
        error: '토큰 잔액 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 사용 내역 조회
  async getTokenHistory(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const query = TokenHistoryQuerySchema.parse(req.query);

      const history = await this.userService.getTokenHistory(userId, {
        page: query.page,
        limit: query.limit,
        startDate: query.startDate,
        endDate: query.endDate,
        type: query.type,
      });

      res.json({
        success: true,
        data: history.transactions,
        metadata: {
          page: history.page,
          limit: history.limit,
          total: history.total,
          totalPages: history.totalPages,
          summary: history.summary,
        },
      });

    } catch (error) {
      logger.error('[UserController] Error getting token history:', error);
      
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: '유효하지 않은 쿼리 파라미터입니다.',
          details: error.errors,
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: '토큰 내역 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 사용자 설정 조회
  async getSettings(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;

      const settings = await this.userService.getSettings(userId);

      res.json({
        success: true,
        data: settings,
      });

    } catch (error) {
      logger.error('[UserController] Error getting settings:', error);
      res.status(500).json({
        success: false,
        error: '설정 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 사용자 설정 업데이트
  async updateSettings(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const settings = req.body;

      const updatedSettings = await this.userService.updateSettings(userId, settings);

      res.json({
        success: true,
        data: updatedSettings,
        message: '설정이 업데이트되었습니다.',
      });

    } catch (error) {
      logger.error('[UserController] Error updating settings:', error);
      res.status(500).json({
        success: false,
        error: '설정 업데이트 중 오류가 발생했습니다.',
      });
    }
  }

  // 사용자 삭제 (탈퇴)
  async deleteUser(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const { password } = req.body;

      // 비밀번호 확인 로직은 AuthService에서 처리
      const success = await this.userService.deleteUser(userId);

      if (!success) {
        res.status(400).json({
          success: false,
          error: '사용자 삭제에 실패했습니다.',
        });
        return;
      }

      res.json({
        success: true,
        message: '계정이 성공적으로 삭제되었습니다.',
      });

    } catch (error) {
      logger.error('[UserController] Error deleting user:', error);
      res.status(500).json({
        success: false,
        error: '계정 삭제 중 오류가 발생했습니다.',
      });
    }
  }
}