import { Router } from 'express';
import * as authController from '../controllers/auth.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validation.middleware';
import { authSchemas } from '../utils/validation/auth.schemas';

const router = Router();

// Public routes
router.post('/register', validateRequest(authSchemas.register), authController.register);
router.post('/login', validateRequest(authSchemas.login), authController.login);
router.post('/refresh', validateRequest(authSchemas.refresh), authController.refreshToken);
router.get('/callback', authController.oauthCallback);

// Protected routes
router.use(authMiddleware);
router.post('/logout', authController.logout);
router.get('/session', authController.getSession);
router.post('/change-password', validateRequest(authSchemas.changePassword), authController.changePassword);

export default router;