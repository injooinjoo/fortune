import type { PlatformProviderId } from './routing.ts';

const ECONOMY_FEATURES = new Set([
  'daily', 'today', 'tomorrow', 'hourly', 'time', 'daily-calendar',
  'love', 'career', 'wealth', 'health', 'compatibility', 'tarot', 'biorhythm',
  'mbti', 'zodiac', 'zodiac-animal', 'lucky-items', 'lucky-series', 'dream',
]);

/** Platform-paid basic readings never inherit a premium DB/AB/default model. */
export function economyRoute(feature: string, routedProvider: PlatformProviderId): {
  provider: PlatformProviderId;
  model: string;
  fallbackModel: string;
} | null {
  const normalized = feature.trim().toLowerCase().replace(/^fortune-/, '');
  if (!ECONOMY_FEATURES.has(normalized)) return null;
  const useOpenRouter = routedProvider === 'openrouter';
  return {
    provider: useOpenRouter ? 'openrouter' : 'gemini',
    model: useOpenRouter ? 'google/gemini-2.5-flash-lite' : 'gemini-2.5-flash-lite',
    fallbackModel: 'gemini-2.5-flash-lite',
  };
}
