import { Request, Response } from 'express';
import { z } from 'zod';
import logger from '../utils/logger';
import { AdminService } from '../services/admin.service';
import { TokenMonitor } from '../utils/token-monitor';
import { RedisService } from '../services/redis.service';

// Query validation schemas
const TokenStatsQuerySchema = z.object({
  range: z.enum(['7d', '30d', '90d']).optional().default('7d'),
});

const TokenUsageQuerySchema = z.object({
  days: z.string().optional().transform(val => val ? parseInt(val) : 7),
});

export class AdminController {
  private adminService: AdminService;
  private tokenMonitor: TokenMonitor;
  private redisService: RedisService;

  constructor() {
    this.adminService = AdminService.getInstance();
    this.tokenMonitor = TokenMonitor.getInstance();
    this.redisService = RedisService.getInstance();
  }

  // Redis 통계
  async getRedisStats(req: Request, res: Response): Promise<void> {
    try {
      const stats = await this.redisService.getStats();

      res.json({
        success: true,
        data: {
          connection: {
            status: stats.connected,
            lastChecked: new Date().toISOString(),
          },
          operations: {
            reads: stats.operations.reads,
            writes: stats.operations.writes,
            errors: stats.operations.errors,
          },
          rateLimits: stats.rateLimits,
          cache: {
            hits: stats.cache.hits,
            misses: stats.cache.misses,
            hitRate: stats.cache.hitRate,
          },
          performance: {
            averageReadTime: stats.performance.averageReadTime,
            averageWriteTime: stats.performance.averageWriteTime,
          },
          lastUpdated: new Date().toISOString(),
        },
      });

    } catch (error) {
      logger.error('[AdminController] Error getting Redis stats:', error);
      res.status(500).json({
        success: false,
        error: 'Redis 통계 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 통계
  async getTokenStats(req: Request, res: Response): Promise<void> {
    try {
      const { range } = TokenStatsQuerySchema.parse(req.query);
      
      const stats = await this.adminService.getTokenStats(range);

      res.json({
        success: true,
        data: stats,
      });

    } catch (error) {
      logger.error('[AdminController] Error getting token stats:', error);
      
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
        error: '토큰 통계 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 토큰 사용량 상세
  async getTokenUsage(req: Request, res: Response): Promise<void> {
    try {
      const { days } = TokenUsageQuerySchema.parse(req.query);
      
      const usage = await this.tokenMonitor.getTokenUsageReport(days);

      res.json({
        success: true,
        data: usage,
      });

    } catch (error) {
      logger.error('[AdminController] Error getting token usage:', error);
      
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
        error: '토큰 사용량 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 사용자 목록
  async getUserList(req: Request, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
      const search = req.query.search as string;
      const filter = req.query.filter as string; // 'all', 'premium', 'active'

      const users = await this.adminService.getUserList({
        page,
        limit,
        search,
        filter,
      });

      res.json({
        success: true,
        data: users.data,
        metadata: {
          page: users.page,
          limit: users.limit,
          total: users.total,
          totalPages: users.totalPages,
        },
      });

    } catch (error) {
      logger.error('[AdminController] Error getting user list:', error);
      res.status(500).json({
        success: false,
        error: '사용자 목록 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 시스템 상태
  async getSystemStatus(req: Request, res: Response): Promise<void> {
    try {
      const status = await this.adminService.getSystemStatus();

      res.json({
        success: true,
        data: status,
      });

    } catch (error) {
      logger.error('[AdminController] Error getting system status:', error);
      res.status(500).json({
        success: false,
        error: '시스템 상태 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 운세 생성 통계
  async getFortuneStats(req: Request, res: Response): Promise<void> {
    try {
      const days = parseInt(req.query.days as string) || 7;
      
      const stats = await this.adminService.getFortuneGenerationStats(days);

      res.json({
        success: true,
        data: stats,
      });

    } catch (error) {
      logger.error('[AdminController] Error getting fortune stats:', error);
      res.status(500).json({
        success: false,
        error: '운세 생성 통계 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 수익 통계
  async getRevenueStats(req: Request, res: Response): Promise<void> {
    try {
      const startDate = req.query.startDate as string;
      const endDate = req.query.endDate as string;

      const stats = await this.adminService.getRevenueStats(startDate, endDate);

      res.json({
        success: true,
        data: stats,
      });

    } catch (error) {
      logger.error('[AdminController] Error getting revenue stats:', error);
      res.status(500).json({
        success: false,
        error: '수익 통계 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 사용자 상세 정보
  async getUserDetail(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.params.userId;

      const userDetail = await this.adminService.getUserDetail(userId);

      if (!userDetail) {
        res.status(404).json({
          success: false,
          error: '사용자를 찾을 수 없습니다.',
        });
        return;
      }

      res.json({
        success: true,
        data: userDetail,
      });

    } catch (error) {
      logger.error('[AdminController] Error getting user detail:', error);
      res.status(500).json({
        success: false,
        error: '사용자 정보 조회 중 오류가 발생했습니다.',
      });
    }
  }

  // 관리자 액션 로그
  async logAdminAction(req: Request, res: Response): Promise<void> {
    try {
      const { action, targetUserId, details } = req.body;
      const adminId = req.userId!;

      await this.adminService.logAdminAction({
        adminId,
        action,
        targetUserId,
        details,
      });

      res.json({
        success: true,
        message: '관리자 액션이 기록되었습니다.',
      });

    } catch (error) {
      logger.error('[AdminController] Error logging admin action:', error);
      res.status(500).json({
        success: false,
        error: '관리자 액션 기록 중 오류가 발생했습니다.',
      });
    }
  }
}