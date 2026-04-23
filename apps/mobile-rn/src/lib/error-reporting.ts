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
      // Sentry.captureException 은 Error 인스턴스를 기대한다. Supabase
      // PostgrestError 같은 `{code,details,hint,message}` plain 객체를 그대로
      // 넘기면 Sentry 가 자체적으로 "Object captured as exception with keys..."
      // 예외를 던지고, 그 예외가 다시 crash reporter로 들어와 cascade 된다
      // (bootstrap 단계에서 `initCrashReporting` 자체가 반복 crash 로 올라오는
      // 실제 사례 확인됨). Error 인스턴스가 아니면 wrap 해서 원본을 cause 로
      // 보존한다.
      const normalized =
        error instanceof Error
          ? error
          : Object.assign(new Error(stringifyErrorMessage(error)), {
              cause: error,
              name:
                error &&
                typeof error === 'object' &&
                typeof (error as { code?: unknown }).code === 'string'
                  ? `SupabaseError(${(error as { code: string }).code})`
                  : 'NonErrorException',
            });
      registeredCrashReporter(normalized, {
        ...context,
        ...(error && typeof error === 'object' && !(error instanceof Error)
          ? { originalErrorKeys: Object.keys(error as object).join(',') }
          : null),
      });
    } catch (reportingFailure) {
      console.warn('[error-reporting] crash reporter threw', reportingFailure);
    }
  }

  await trackEvent('app_error', payload);
}
