import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN || process.env.NEXT_PUBLIC_SENTRY_DSN,
  
  // Adjust this value in production, or use tracesSampler for greater control
  tracesSampleRate: process.env.NODE_ENV === "production" ? 0.1 : 1.0,
  
  // Setting this option to true will print useful information to the console while you're setting up Sentry.
  debug: false,
  
  // Server-side specific options
  environment: process.env.NEXT_PUBLIC_ENVIRONMENT || "development",
  
  // Capture unhandled promise rejections
  captureUnhandledRejections: true,
  
  beforeSend(event, hint) {
    // Don't send error reports in development
    if (process.env.NODE_ENV === "development") {
      console.error("Sentry Error (server):", hint.originalException || hint.syntheticException);
      return null;
    }
    
    // Filter out certain errors
    const error = hint.originalException as Error;
    
    // Don't report API rate limit errors
    if (error?.message?.includes("429") || error?.message?.includes("rate limit")) {
      return null;
    }
    
    // Remove sensitive data from server errors
    if (event.contexts?.runtime) {
      delete event.contexts.runtime.env;
    }
    
    if (event.request) {
      // Remove sensitive headers
      if (event.request.headers) {
        delete event.request.headers["authorization"];
        delete event.request.headers["x-api-key"];
        delete event.request.headers["cookie"];
      }
      
      // Remove query strings that might contain sensitive data
      if (event.request.query_string) {
        event.request.query_string = "[FILTERED]";
      }
    }
    
    return event;
  },
  
  // Integrations
  integrations: [
    // Capture errors in API routes
    Sentry.nativeNodeFetchIntegration(),
  ],
});