import dotenv from 'dotenv';
import path from 'path';

// Load environment variables
dotenv.config();

import app from './app';
import logger from './utils/logger';
import { validateEnv } from './config/env';

// Validate environment variables
// NOTE: Temporarily disabled for Cloud Run deployment
// validateEnv();

const PORT = process.env.PORT || 3001;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Start server
const server = app.listen(PORT, () => {
  logger.info(`🚀 Fortune API Server is running!`);
  logger.info(`📍 Environment: ${NODE_ENV}`);
  logger.info(`🔗 URL: http://localhost:${PORT}`);
  logger.info(`📚 API Version: ${process.env.API_VERSION || 'v1'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received: closing HTTP server');
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Application specific logging, throwing an error, or other logic here
});

export default server;