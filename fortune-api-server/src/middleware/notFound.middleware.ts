import { Request, Response } from 'express';

export function notFoundHandler(req: Request, res: Response): void {
  res.status(404).json({
    success: false,
    error: {
      message: 'Resource not found',
      path: req.path,
      method: req.method,
    },
    timestamp: new Date().toISOString(),
  });
}