export const ANALYTICS_EVENTS = [
  'page_view',
  'auth_started',
  'auth_completed',
  'fortune_started',
  'fortune_completed',
  'chat_started',
  'chat_completed',
  'payment_started',
  'payment_completed',
  'client_error',
] as const;

export type AnalyticsEvent = (typeof ANALYTICS_EVENTS)[number];
export type AnalyticsValue = string | number | boolean;

const ALLOWED_PROPERTY_KEYS = new Set([
  'anonymous',
  'character_id',
  'duration_ms',
  'error_kind',
  'fortune_type',
  'outcome',
  'path',
  'payment_method',
  'product_id',
  'provider',
  'source',
]);

export function sanitizeAnalyticsProperties(
  properties: Record<string, unknown> = {},
): Record<string, AnalyticsValue> {
  const safe: Record<string, AnalyticsValue> = {};

  for (const [key, value] of Object.entries(properties)) {
    if (!ALLOWED_PROPERTY_KEYS.has(key)) continue;
    if (typeof value === 'string') safe[key] = value.slice(0, 120);
    else if (typeof value === 'number' && Number.isFinite(value)) safe[key] = value;
    else if (typeof value === 'boolean') safe[key] = value;
  }

  return safe;
}
