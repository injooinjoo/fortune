import { Router } from 'express';
import { PaymentController } from '../controllers/payment.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const paymentController = new PaymentController();

// 모든 결제 관련 라우트는 인증 필요
router.use(authMiddleware);

// 구매 검증
router.post('/verify-purchase', (req, res) => paymentController.verifyPurchase(req, res));

// 구독 상태 확인
router.post('/verify-subscription', (req, res) => paymentController.verifySubscription(req, res));

// 구매 복원
router.post('/restore-purchases', (req, res) => paymentController.restorePurchases(req, res));

export default router;