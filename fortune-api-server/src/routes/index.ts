import { Router } from 'express';
import fortuneRoutes from './fortune.routes';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import paymentRoutes from './payment.routes';
import adminRoutes from './admin.routes';
import tokenRoutes from './token.routes';

const router = Router();

// API version prefix
const API_VERSION = process.env.API_VERSION || 'v1';

// Mount routes
router.use(`/${API_VERSION}/fortune`, fortuneRoutes);
router.use(`/${API_VERSION}/auth`, authRoutes);
router.use(`/${API_VERSION}/user`, userRoutes);
router.use(`/${API_VERSION}/payment`, paymentRoutes);
router.use(`/${API_VERSION}/admin`, adminRoutes);
router.use(`/${API_VERSION}/token`, tokenRoutes);

// API documentation endpoint
router.get(`/${API_VERSION}/docs`, (req, res) => {
  res.json({
    message: 'API Documentation',
    version: API_VERSION,
    endpoints: {
      fortune: `/${API_VERSION}/fortune`,
      auth: `/${API_VERSION}/auth`,
      user: `/${API_VERSION}/user`,
      payment: `/${API_VERSION}/payment`,
      admin: `/${API_VERSION}/admin`,
      token: `/${API_VERSION}/token`,
    },
  });
});

// Root API endpoint
router.get('/', (req, res) => {
  res.json({
    message: 'Fortune API',
    version: API_VERSION,
    docs: `/api/${API_VERSION}/docs`,
  });
});

export default router;