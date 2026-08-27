'use client';

import { sanitizeAnalyticsProperties, type AnalyticsEvent } from './analytics';
import { getBrowserSupabase } from './supabase/client';

declare global {
  interface Window {
    dataLayer?: unknown[];
    gtag?: (...args: unknown[]) => void;
  }
}

const SESSION_KEY = 'ondo.analytics.session';

function analyticsSessionId(): string {
  const current = sessionStorage.getItem(SESSION_KEY);
  if (current) return current;
  const created = crypto.randomUUID();
  sessionStorage.setItem(SESSION_KEY, created);
  return created;
}

export function trackProductEvent(
  eventName: AnalyticsEvent,
  properties: Record<string, unknown> = {},
): void {
  if (typeof window === 'undefined') return;

  const safeProperties = sanitizeAnalyticsProperties(properties);
  window.gtag?.('event', eventName, safeProperties);

  const supabase = getBrowserSupabase();
  if (!supabase) return;

  void (async () => {
    const { error } = await supabase.rpc('record_web_analytics_event', {
      p_event_name: eventName,
      p_session_id: analyticsSessionId(),
      p_path: window.location.pathname.slice(0, 500) || '/',
      p_properties: safeProperties,
    });

    if (error && process.env.NODE_ENV !== 'production') {
      console.warn('Ondo analytics event was not recorded', { eventName, code: error.code });
    }
  })();
}
