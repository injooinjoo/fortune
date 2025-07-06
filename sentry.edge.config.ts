import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN || process.env.NEXT_PUBLIC_SENTRY_DSN,
  
  // Adjust this value in production
  tracesSampleRate: process.env.NODE_ENV === "production" ? 0.1 : 1.0,
  
  // Debug flag
  debug: false,
  
  // Edge-specific configuration
  environment: process.env.NEXT_PUBLIC_ENVIRONMENT || "development",
  
  beforeSend(event, hint) {
    // Don't send error reports in development
    if (process.env.NODE_ENV === "development") {
      console.error("Sentry Error (edge):", hint.originalException);
      return null;
    }
    
    // Filter out rate limit errors
    const error = hint.originalException as Error;
    if (error?.message?.includes("429") || error?.message?.includes("rate limit")) {
      return null;
    }
    
    return event;
  },
});