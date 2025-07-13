import { Router } from 'express';
import { TokenController } from '../controllers/token.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { adminMiddleware } from '../middleware/admin.middleware';

const router = Router();
const tokenController = new TokenController();

// Public routes (require authentication)
router.get('/balance', authMiddleware, (req, res) => tokenController.getBalance(req, res));
router.get('/history', authMiddleware, (req, res) => tokenController.getHistory(req, res));
router.post('/use', authMiddleware, (req, res) => tokenController.useTokens(req, res));

// Admin routes
router.post('/add/:userId', authMiddleware, adminMiddleware, (req, res) => tokenController.addTokens(req, res));
router.post('/refund', authMiddleware, adminMiddleware, (req, res) => tokenController.refundTokens(req, res));

// System routes (internal API key required)
router.post('/grant-daily', (req, res) => tokenController.grantDailyTokens(req, res));

export default router;