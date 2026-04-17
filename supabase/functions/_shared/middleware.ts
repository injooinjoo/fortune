/**
 * Shared request middleware for edge functions.
 *
 * Wraps a handler to guarantee:
 *   1. CORS preflight handling
 *   2. Stable requestId for tracing across logs
 *   3. Timeout enforcement (default 30s)
 *   4. Error boundary that never leaks internals to the client
 *   5. Structured success + failure logging via GcpLoggingService
 *   6. Consistent JSON response envelope
 *
 * Migration target: every edge function under `supabase/functions/` should
 * gradually adopt `withEdgeFunction` so that error handling, logging, and
 * cost guards stop drifting between 80 hand-rolled implementations.
 *
 * Example:
 *   serve((req) => withEdgeFunction(req, {
 *     functionName: 'fortune-naming',
 *     timeoutMs: 25_000,
 *     handler: async ({ body, requestId }) => {
 *       // do the work
 *       return { status: 200, payload: { ... } };
 *     },
 *   }));
 */

import { corsHeaders, handleCors } from './cors.ts';
import { GcpLoggingService } from './monitoring/gcp-logging.ts';

export interface EdgeHandlerContext<TBody> {
  req: Request;
  body: TBody;
  requestId: string;
  startedAt: number;
}

export interface EdgeHandlerResult<TPayload> {
  status?: number;
  payload: TPayload;
  /** Optional headers to merge into the response (cors always injected). */
  headers?: Record<string, string>;
}

export interface WithEdgeFunctionOptions<TBody, TPayload> {
  functionName: string;
  /** Timeout in milliseconds. Default 30_000. */
  timeoutMs?: number;
  /** Parses the request body. Default: `req.json()` or `{}` if no body. */
  parseBody?: (req: Request) => Promise<TBody> | TBody;
  /** Main handler. Must return `{ payload }`. */
  handler: (ctx: EdgeHandlerContext<TBody>) => Promise<EdgeHandlerResult<TPayload>>;
  /** Optional user-facing error message (default: generic Korean). */
  userFacingErrorMessage?: string;
  /** Extra keys to attach to the log entry (e.g. characterId, fortuneType). */
  buildLogMetadata?: (ctx: EdgeHandlerContext<TBody>) => Record<string, unknown>;
}

function generateRequestId(): string {
  // crypto.randomUUID is available in Deno Deploy + modern Node.
  try {
    return crypto.randomUUID();
  } catch {
    const rand = Math.random().toString(36).slice(2, 10);
    return `req_${Date.now().toString(36)}_${rand}`;
  }
}

async function defaultParseBody(req: Request): Promise<unknown> {
  if (req.method === 'GET') return {};
  const contentType = req.headers.get('content-type') ?? '';
  if (!contentType.includes('application/json')) return {};
  try {
    return await req.json();
  } catch {
    return {};
  }
}

function buildJsonResponse(
  status: number,
  payload: unknown,
  extraHeaders?: Record<string, string>,
): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
      ...(extraHeaders ?? {}),
    },
  });
}

export async function withEdgeFunction<TBody = unknown, TPayload = unknown>(
  req: Request,
  options: WithEdgeFunctionOptions<TBody, TPayload>,
): Promise<Response> {
  // 1. CORS preflight.
  const preflight = handleCors(req);
  if (preflight) return preflight;

  const requestId = generateRequestId();
  const startedAt = Date.now();
  const timeoutMs = options.timeoutMs ?? 30_000;
  const parseBody = options.parseBody ?? (defaultParseBody as (
    r: Request,
  ) => Promise<TBody>);

  let body: TBody;
  try {
    body = (await parseBody(req)) as TBody;
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    await logSafely({
      eventType: 'edge_bad_request',
      functionName: options.functionName,
      requestId,
      success: false,
      errorMessage: `body parse failed: ${message}`,
    });
    return buildJsonResponse(400, {
      error: '요청 형식이 올바르지 않습니다.',
      requestId,
    });
  }

  const ctx: EdgeHandlerContext<TBody> = {
    req,
    body,
    requestId,
    startedAt,
  };

  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(
      () => reject(new Error(`handler timed out after ${timeoutMs}ms`)),
      timeoutMs,
    );
  });

  try {
    const result = await Promise.race([options.handler(ctx), timeoutPromise]);
    const latencyMs = Date.now() - startedAt;
    const status = result.status ?? 200;

    await logSafely({
      eventType: 'edge_request_success',
      functionName: options.functionName,
      requestId,
      success: true,
      statusCode: status,
      latencyMs,
      metadata: options.buildLogMetadata?.(ctx),
    });

    return buildJsonResponse(
      status,
      {
        ...(result.payload as Record<string, unknown>),
        requestId,
      },
      result.headers,
    );
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    const latencyMs = Date.now() - startedAt;

    await logSafely({
      eventType: 'edge_request_failed',
      functionName: options.functionName,
      requestId,
      success: false,
      statusCode: 500,
      latencyMs,
      errorMessage: message,
      metadata: options.buildLogMetadata?.(ctx),
    });

    return buildJsonResponse(500, {
      error:
        options.userFacingErrorMessage ??
        '일시적인 오류가 발생했어요. 잠시 후 다시 시도해주세요.',
      requestId,
    });
  }
}

async function logSafely(data: Parameters<typeof GcpLoggingService.log>[0]) {
  try {
    await GcpLoggingService.log(data);
  } catch {
    // Logging failures must never interfere with request lifecycle.
  }
}

/**
 * Shortcut for functions that just want a JSON error response with the
 * shared envelope. Useful inside handler logic when a pre-flight check fails.
 */
export function buildEdgeErrorResponse(
  status: number,
  userMessage: string,
  requestId: string,
): Response {
  return buildJsonResponse(status, {
    error: userMessage,
    requestId,
  });
}
