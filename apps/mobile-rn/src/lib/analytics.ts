import type { AnalyticsEventName } from '@fortune/product-contracts';

import { appEnv } from './env';

export async function trackEvent(
  eventName: AnalyticsEventName,
  params: Record<string, unknown> = {},
) {
  if (!appEnv.isAnalyticsConfigured && __DEV__) {
    console.info('[analytics]', eventName, params);
  }
}
