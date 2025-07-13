import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const userController = new UserController();

// 모든 사용자 관련 라우트는 인증 필요
router.use(authMiddleware);

// 프로필 관리
router.get('/profile', (req, res) => userController.getProfile(req, res));
router.post('/profile', (req, res) => userController.updateProfile(req, res));
router.put('/profile', (req, res) => userController.updateProfile(req, res));

// 토큰 관리
router.get('/token-balance', (req, res) => userController.getTokenBalance(req, res));
router.get('/token-history', (req, res) => userController.getTokenHistory(req, res));

// 설정 관리
router.get('/settings', (req, res) => userController.getSettings(req, res));
router.put('/settings', (req, res) => userController.updateSettings(req, res));

// 계정 관리
router.delete('/account', (req, res) => userController.deleteUser(req, res));

export default router;