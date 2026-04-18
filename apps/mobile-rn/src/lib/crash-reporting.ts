/**
 * Sentry initialization + integration with the app's captureError hook.
 *
 * Wire this up once at app bootstrap (before rendering the navigator).
 * When `appEnv.sentryDsn` is unset (local dev without secrets), initialize is
 * skipped so we don't churn noise into a dashboard.
 *
 * DSN must be provided via EAS secret (EXPO_PUBLIC_SENTRY_DSN) or equivalent
 * env var that `app.config.ts` forwards into `extra.sentryDsn`.
 */

import * as Sentry from '@sentry/react-native';

import { appEnv } from './env';
import { setCrashReporter } from './error-reporting';

let initialized = false;

export function initCrashReporting(): void {
  if (initialized) return;
  if (!appEnv.isCrashReportingConfigured) {
    if (__DEV__) {
      console.log(
        '[crash-reporting] Sentry DSN not set, skipping initialization.',
      );
    }
    return;
  }

  try {
    Sentry.init({
      dsn: appEnv.sentryDsn,
      environment: appEnv.environment,
      enableAutoSessionTracking: true,
      // Keep sample rates conservative in prod to control cost.
      tracesSampleRate: appEnv.environment === 'production' ? 0.1 : 1.0,
      // Strip sensitive breadcrumbs that could include user input.
      beforeBreadcrumb: (breadcrumb) => {
        if (
          breadcrumb.category === 'ui.input' ||
          breadcrumb.category === 'console'
        ) {
          return null;
        }
        return breadcrumb;
      },
    });

    setCrashReporter((error, context) => {
      Sentry.captureException(error, {
        extra: context,
      });
    });

    initialized = true;
  } catch (err) {
    console.warn('[crash-reporting] Sentry init failed:', err);
  }
}

export function identifyUserForCrashReporting(
  user: { id: string; email?: string | null } | null,
): void {
  if (!initialized) return;
  try {
    if (user) {
      Sentry.setUser({
        id: user.id,
        // Email is intentionally omitted to avoid PII in the crash reporter;
        // the user id alone is sufficient to correlate crashes with an account.
      });
    } else {
      Sentry.setUser(null);
    }
  } catch (err) {
    console.warn('[crash-reporting] setUser failed:', err);
  }
}
