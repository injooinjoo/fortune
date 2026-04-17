import { trackEvent } from './analytics';
import { appEnv } from './env';

// Hook point for a crash reporter (Sentry, Bugsnag, etc.). Register at app
// bootstrap (e.g. in a top-level provider) with:
//   import * as Sentry from '@sentry/react-native';
//   Sentry.init({ dsn: appEnv.crashReportingDsn });
//   setCrashReporter((err, ctx) => Sentry.captureException(err, { extra: ctx }));
//
// Keeping the integration as an opt-in adapter means `captureError` stays the
// single call site for the rest of the app. Swapping vendors is a one-line change.
type CrashReporter = (error: unknown, context: Record<string, unknown>) => void;
let registeredCrashReporter: CrashReporter | null = null;

export function setCrashReporter(reporter: CrashReporter | null): void {
  registeredCrashReporter = reporter;
}

function stringifyErrorMessage(error: unknown) {
  if (error instanceof Error) {
    return error.message;
  }

  if (error && typeof error === 'object') {
    const message =
      'message' in error && typeof error.message === 'string'
        ? error.message
        : null;
    const details =
      'details' in error && typeof error.details === 'string'
        ? error.details
        : null;
    const hint =
      'hint' in error && typeof error.hint === 'string'
        ? error.hint
        : null;
    const code =
      'code' in error && typeof error.code === 'string'
        ? error.code
        : null;

    const parts = [message, details, hint, code ? `code=${code}` : null].filter(
      (value): value is string => typeof value === 'string' && value.length > 0,
    );

    if (parts.length > 0) {
      return parts.join(' | ');
    }
  }

  return String(error);
}

function isExpectedEdgeFunctionError(error: unknown): boolean {
  const message = stringifyErrorMessage(error);
  return (
    message.includes('Edge Function returned a non-2xx status code') ||
    message.includes('Failed to send a request to the Edge Function') ||
    message.includes('edge function') ||
    message.includes('FunctionsHttpError') ||
    message.includes('FunctionsRelayError')
  );
}

export async function captureError(
  error: unknown,
  context: Record<string, unknown> = {},
) {
  const payload = {
    message: stringifyErrorMessage(error),
    ...context,
  };

  if (__DEV__ || !appEnv.isCrashReportingConfigured) {
    if (isExpectedEdgeFunctionError(error)) {
      console.warn('[error-reporting]', payload);
    } else {
      console.error('[error-reporting]', payload);
    }
  }

  if (registeredCrashReporter && !isExpectedEdgeFunctionError(error)) {
    try {
      registeredCrashReporter(error, context);
    } catch (reportingFailure) {
      console.warn('[error-reporting] crash reporter threw', reportingFailure);
    }
  }

  await trackEvent('app_error', payload);
}
