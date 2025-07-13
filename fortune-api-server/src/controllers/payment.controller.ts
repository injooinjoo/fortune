import { Request, Response } from 'express';
import { z } from 'zod';
import logger from '../utils/logger';
import { PaymentService } from '../services/payment.service';
import { TokenService } from '../services/token.service';
import { supabaseAdmin } from '../config/supabase';

// 요청 검증 스키마
const VerifyPurchaseSchema = z.object({
  platform: z.enum(['android', 'ios']),
  productId: z.string(),
  purchaseToken: z.string().optional(), // Android
  receipt: z.string().optional(), // iOS
  orderId: z.string().optional(),
  transactionId: z.string().optional(),
});

// 토큰 수량 매핑
const TOKEN_AMOUNTS: Record<string, number> = {
  'com.fortune.tokens.10': 10,
  'com.fortune.tokens.50': 50,
  'com.fortune.tokens.100': 100,
  'com.fortune.tokens.200': 200,
};

export class PaymentController {
  private paymentService: PaymentService;
  private tokenService: TokenService;

  constructor() {
    this.paymentService = PaymentService.getInstance();
    this.tokenService = TokenService.getInstance();
  }

  // 구매 검증
  async verifyPurchase(req: Request, res: Response): Promise<void> {
    try {
      const validatedData = VerifyPurchaseSchema.parse(req.body);
      const userId = req.userId!;

      logger.info('[Payment] Verifying purchase', {
        userId,
        platform: validatedData.platform,
        productId: validatedData.productId,
      });

      let isValid = false;
      let purchaseInfo: any = {};

      // 플랫폼별 검증
      if (validatedData.platform === 'android') {
        const result = await this.paymentService.verifyGooglePurchase(
          validatedData.purchaseToken!,
          validatedData.productId
        );
        isValid = result.valid;
        purchaseInfo = result.purchaseInfo;
      } else if (validatedData.platform === 'ios') {
        const result = await this.paymentService.verifyAppleReceipt(
          validatedData.receipt!,
          validatedData.productId
        );
        isValid = result.valid;
        purchaseInfo = result.purchaseInfo;
      }

      if (!isValid) {
        logger.warn('[Payment] Invalid purchase detected', {
          userId,
          platform: validatedData.platform,
          productId: validatedData.productId,
        });
        
        res.status(400).json({
          success: false,
          error: '유효하지 않은 구매입니다.',
        });
        return;
      }

      // 중복 구매 확인
      const existingPurchase = await supabaseAdmin
        .from('purchases')
        .select('id')
        .eq('transaction_id', purchaseInfo.transactionId)
        .single();

      if (existingPurchase.data) {
        logger.info('[Payment] Duplicate purchase detected', {
          transactionId: purchaseInfo.transactionId,
        });
        
        res.json({
          success: true,
          valid: true,
          duplicate: true,
          message: '이미 처리된 구매입니다.',
        });
        return;
      }

      // 구매 기록 저장
      const { error: insertError } = await supabaseAdmin
        .from('purchases')
        .insert({
          user_id: userId,
          platform: validatedData.platform,
          product_id: validatedData.productId,
          transaction_id: purchaseInfo.transactionId,
          order_id: validatedData.orderId,
          purchase_date: purchaseInfo.purchaseDate,
          amount: purchaseInfo.amount,
          currency: purchaseInfo.currency || 'KRW',
          status: 'completed',
          raw_data: purchaseInfo,
        });

      if (insertError) {
        logger.error('[Payment] Failed to save purchase', insertError);
        throw new Error('구매 기록 저장 실패');
      }

      // 토큰 상품인 경우 토큰 추가
      const tokenAmount = TOKEN_AMOUNTS[validatedData.productId];
      if (tokenAmount) {
        await this.tokenService.addTokens(
          userId,
          tokenAmount,
          `인앱 구매: ${validatedData.productId}`,
          purchaseInfo.transactionId
        );

        logger.info('[Payment] Tokens added successfully', {
          userId,
          amount: tokenAmount,
          productId: validatedData.productId,
        });
      }

      // 구독 상품인 경우 구독 활성화
      if (validatedData.productId.includes('subscription')) {
        await this.paymentService.activateSubscription(
          userId,
          validatedData.productId,
          purchaseInfo
        );
      }

      res.json({
        success: true,
        valid: true,
        message: '구매가 성공적으로 처리되었습니다.',
        tokenAmount,
      });

    } catch (error) {
      logger.error('[Payment] Error verifying purchase:', error);

      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          error: '잘못된 요청 형식입니다.',
          details: error.errors,
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: '구매 검증 중 오류가 발생했습니다.',
      });
    }
  }

  // 구독 상태 확인
  async verifySubscription(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const { productId, platform } = req.body;

      const subscription = await this.paymentService.getActiveSubscription(userId);
      
      if (!subscription) {
        res.json({
          success: true,
          active: false,
          message: '활성 구독이 없습니다.',
        });
        return;
      }

      // 구독 만료 확인
      const now = new Date();
      const endDate = new Date(subscription.end_date);
      
      if (endDate < now) {
        await this.paymentService.expireSubscription(userId);
        res.json({
          success: true,
          active: false,
          message: '구독이 만료되었습니다.',
        });
        return;
      }

      res.json({
        success: true,
        active: true,
        subscription: {
          type: subscription.type,
          endDate: subscription.end_date,
          autoRenew: subscription.auto_renew,
        },
      });

    } catch (error) {
      logger.error('[Payment] Error verifying subscription:', error);
      res.status(500).json({
        success: false,
        error: '구독 확인 중 오류가 발생했습니다.',
      });
    }
  }

  // 구매 복원
  async restorePurchases(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.userId!;
      const { platform, receipts } = req.body;

      logger.info('[Payment] Restoring purchases', {
        userId,
        platform,
        receiptCount: receipts?.length || 0,
      });

      const restoredPurchases = [];
      let totalTokensRestored = 0;

      for (const receipt of receipts) {
        try {
          let purchaseInfo: any;
          
          if (platform === 'ios') {
            const result = await this.paymentService.verifyAppleReceipt(
              receipt.receiptData,
              receipt.productId
            );
            if (result.valid) {
              purchaseInfo = result.purchaseInfo;
            }
          } else if (platform === 'android') {
            const result = await this.paymentService.verifyGooglePurchase(
              receipt.purchaseToken,
              receipt.productId
            );
            if (result.valid) {
              purchaseInfo = result.purchaseInfo;
            }
          }

          if (purchaseInfo) {
            // 이미 처리된 구매인지 확인
            const existing = await supabaseAdmin
              .from('purchases')
              .select('id')
              .eq('transaction_id', purchaseInfo.transactionId)
              .single();

            if (!existing.data) {
              // 새로운 구매 복원
              const tokenAmount = TOKEN_AMOUNTS[receipt.productId] || 0;
              if (tokenAmount > 0) {
                totalTokensRestored += tokenAmount;
                await this.tokenService.addTokens(
                  userId,
                  tokenAmount,
                  '구매 복원',
                  purchaseInfo.transactionId
                );
              }

              restoredPurchases.push({
                productId: receipt.productId,
                transactionId: purchaseInfo.transactionId,
                restored: true,
              });
            }
          }
        } catch (error) {
          logger.error('[Payment] Error restoring single purchase:', error);
        }
      }

      res.json({
        success: true,
        restoredCount: restoredPurchases.length,
        totalTokensRestored,
        purchases: restoredPurchases,
      });

    } catch (error) {
      logger.error('[Payment] Error restoring purchases:', error);
      res.status(500).json({
        success: false,
        error: '구매 복원 중 오류가 발생했습니다.',
      });
    }
  }
}