import { trackEvent } from './analytics';
import { appEnv } from './env';

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

export async function captureError(
  error: unknown,
  context: Record<string, unknown> = {},
) {
  const payload = {
    message: stringifyErrorMessage(error),
    ...context,
  };

  if (__DEV__ || !appEnv.isCrashReportingConfigured) {
    console.error('[error-reporting]', payload);
  }

  await trackEvent('app_error', payload);
}
