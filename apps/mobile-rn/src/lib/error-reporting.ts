import { trackEvent } from './analytics';
import { appEnv } from './env';

export async function captureError(
  error: unknown,
  context: Record<string, unknown> = {},
) {
  const payload = {
    message: error instanceof Error ? error.message : String(error),
    ...context,
  };

  if (__DEV__ || !appEnv.isCrashReportingConfigured) {
    console.error('[error-reporting]', payload);
  }

  await trackEvent('app_error', payload);
}
