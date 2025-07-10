/**
 * Free Error Monitoring Solution
 * Replaces Sentry with a custom error tracking system
 */

import { logger } from '@/lib/logger';

interface ErrorDetails {
  message: string;
  stack?: string;
  url?: string;
  userAgent?: string;
  timestamp: string;
  userId?: string;
  metadata?: Record<string, any>;
}

class ErrorMonitor {
  private static instance: ErrorMonitor;
  private errorQueue: ErrorDetails[] = [];
  private maxQueueSize = 100;

  private constructor() {
    // Setup global error handlers if in browser
    if (typeof window !== 'undefined') {
      this.setupBrowserHandlers();
    }
  }

  static getInstance(): ErrorMonitor {
    if (!ErrorMonitor.instance) {
      ErrorMonitor.instance = new ErrorMonitor();
    }
    return ErrorMonitor.instance;
  }

  private setupBrowserHandlers() {
    // Handle unhandled errors
    window.addEventListener('error', (event) => {
      this.captureError(event.error || new Error(event.message), {
        url: event.filename,
        line: event.lineno,
        column: event.colno,
      });
    });

    // Handle unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.captureError(
        new Error(`Unhandled Promise Rejection: ${event.reason}`),
        { promise: true }
      );
    });
  }

  captureError(error: Error | string, metadata?: Record<string, any>) {
    const errorDetails: ErrorDetails = {
      message: typeof error === 'string' ? error : error.message,
      stack: typeof error === 'object' ? error.stack : undefined,
      timestamp: new Date().toISOString(),
      metadata,
    };

    // Add browser context if available
    if (typeof window !== 'undefined') {
      errorDetails.url = window.location.href;
      errorDetails.userAgent = navigator.userAgent;
    }

    // Add to queue
    this.errorQueue.push(errorDetails);
    if (this.errorQueue.length > this.maxQueueSize) {
      this.errorQueue.shift(); // Remove oldest
    }

    // Log error
    logger.error('Error captured:', errorDetails);

    // Send to backend if critical
    if (this.isCriticalError(errorDetails)) {
      this.sendToBackend(errorDetails);
    }
  }

  private isCriticalError(error: ErrorDetails): boolean {
    // Define what constitutes a critical error
    const criticalKeywords = ['payment', 'auth', 'token', 'database', 'api'];
    return criticalKeywords.some(keyword => 
      error.message.toLowerCase().includes(keyword)
    );
  }

  private async sendToBackend(error: ErrorDetails) {
    try {
      // Send to your backend API
      await fetch('/api/errors/log', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(error),
      });
    } catch (err) {
      // Fail silently, don't create error loop
      logger.warn('Failed to send error to backend:', err);
    }
  }

  captureMessage(message: string, level: 'info' | 'warning' | 'error' = 'info') {
    logger[level](message);
    
    if (level === 'error') {
      this.captureError(new Error(message));
    }
  }

  setUser(userId: string, email?: string) {
    // Store user context for error tracking
    if (typeof window !== 'undefined') {
      window.__errorMonitorUser = { userId, email };
    }
  }

  clearUser() {
    if (typeof window !== 'undefined') {
      delete window.__errorMonitorUser;
    }
  }

  getRecentErrors(): ErrorDetails[] {
    return [...this.errorQueue];
  }

  clearErrors() {
    this.errorQueue = [];
  }
}

// Export singleton instance
export const errorMonitor = ErrorMonitor.getInstance();

// Helper functions for easy migration from Sentry
export const captureException = (error: Error | string, extra?: Record<string, any>) => {
  errorMonitor.captureError(error, extra);
};

export const captureMessage = (message: string, level?: 'info' | 'warning' | 'error') => {
  errorMonitor.captureMessage(message, level);
};

export const setUser = (user: { id: string; email?: string }) => {
  errorMonitor.setUser(user.id, user.email);
};

// Next.js error boundary component
export function ErrorBoundary({ children }: { children: React.ReactNode }) {
  return children;
}

// Extend window type
declare global {
  interface Window {
    __errorMonitorUser?: { userId: string; email?: string };
  }
}