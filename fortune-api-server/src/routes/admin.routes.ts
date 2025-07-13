import { Router } from 'express';
import { AdminController } from '../controllers/admin.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { adminMiddleware } from '../middleware/admin.middleware';

const router = Router();
const adminController = new AdminController();

// All admin routes require authentication and admin role
router.use(authMiddleware);
router.use(adminMiddleware);

// Statistics routes
router.get('/redis-stats', (req, res) => adminController.getRedisStats(req, res));
router.get('/token-stats', (req, res) => adminController.getTokenStats(req, res));
router.get('/token-usage', (req, res) => adminController.getTokenUsage(req, res));
router.get('/fortune-stats', (req, res) => adminController.getFortuneStats(req, res));
router.get('/revenue-stats', (req, res) => adminController.getRevenueStats(req, res));

// System management
router.get('/system-status', (req, res) => adminController.getSystemStatus(req, res));

// User management
router.get('/users', (req, res) => adminController.getUserList(req, res));
router.get('/users/:userId', (req, res) => adminController.getUserDetail(req, res));

// Admin actions
router.post('/log-action', (req, res) => adminController.logAdminAction(req, res));

export default router;