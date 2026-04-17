/**
 * Error response helpers for edge functions.
 *
 * Problem: ~30 functions currently return `error.message` directly in 500
 * responses, leaking implementation details like `"OPENAI_API_KEY missing"`,
 * `"Gemini circuit_open"`, or raw stack traces to any API consumer.
 *
 * These helpers provide a redacted envelope the caller can drop in until the
 * function migrates to the full `withEdgeFunction` middleware in middleware.ts.
 *
 * Usage:
 *   import { respondWithEdgeError } from '../_shared/error-response.ts';
 *   try { ... } catch (err) {
 *     return respondWithEdgeError(err, { functionName: 'fortune-foo' });
 *   }
 */

import { corsHeaders } from './cors.ts';

// Messages we never want leaked to the client. Substrings are matched
// case-insensitively. Anything matching is replaced with the generic copy.
const SENSITIVE_SUBSTRINGS = [
  'api_key',
  'api key',
  'apikey',
  'openai',
  'gemini',
  'anthropic',
  'grok',
  'service_role',
  'supabase_url',
  'supabase_service_role',
  'circuit_open',
  'preview_model_blocked',
  'high_cost_model_blocked',
  'rofan',
  'rohan',
  'bearer',
  'token',
];

export interface RespondWithErrorOptions {
  functionName?: string;
  requestId?: string;
  statusCode?: number;
  userFacingMessage?: string;
  headers?: Record<string, string>;
}

function isSensitive(message: string): boolean {
  const lower = message.toLowerCase();
  return SENSITIVE_SUBSTRINGS.some((pattern) => lower.includes(pattern));
}

export function redactErrorForClient(
  err: unknown,
  fallback = '일시적인 오류가 발생했어요. 잠시 후 다시 시도해주세요.',
): string {
  const raw = err instanceof Error ? err.message : String(err ?? '');
  if (!raw) return fallback;
  if (isSensitive(raw)) return fallback;
  // Keep short, human-ish messages; drop anything that looks like a stack frame
  // or contains a URL / file path.
  if (/https?:\/\/|\/[a-z_]+\.(ts|js)|\bat [A-Za-z]/.test(raw)) return fallback;
  if (raw.length > 160) return fallback;
  return raw;
}

export function generateRequestId(): string {
  try {
    return crypto.randomUUID();
  } catch {
    const rand = Math.random().toString(36).slice(2, 10);
    return `req_${Date.now().toString(36)}_${rand}`;
  }
}

export function respondWithEdgeError(
  err: unknown,
  options: RespondWithErrorOptions = {},
): Response {
  const requestId = options.requestId ?? generateRequestId();
  const status = options.statusCode ?? 500;
  const userMessage = options.userFacingMessage ??
    redactErrorForClient(err);

  // Log the full raw error server-side so we keep debuggability without
  // exposing it to the client.
  const raw = err instanceof Error ? (err.stack ?? err.message) : String(err);
  console.error(
    `[edge-error] ${options.functionName ?? 'unknown'} requestId=${requestId} ${raw}`,
  );

  return new Response(
    JSON.stringify({ error: userMessage, requestId }),
    {
      status,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
        ...(options.headers ?? {}),
      },
    },
  );
}
