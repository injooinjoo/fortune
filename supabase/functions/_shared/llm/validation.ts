/**
 * Lightweight LLM response validator (no external dependency).
 *
 * Combines loose JSON parsing (tolerates code fences and prose wrappers that
 * LLMs often emit) with a typed schema builder. Designed to replace the
 * `JSON.parse(response.content)` calls scattered across 30+ fortune functions
 * that currently crash on any hallucinated format drift.
 *
 * Usage:
 *   const schema = v.object({
 *     score: v.number({ min: 0, max: 100 }),
 *     summary: v.string({ min: 1, max: 2000 }),
 *     recommendedNames: v.array(v.string(), { min: 1, max: 10 }),
 *   });
 *   const result = parseAndValidateLLMResponse(rawResponse, schema);
 *   if (!result.ok) return buildFallback(result.error);
 *   const { score, summary, recommendedNames } = result.value;
 */

export class ValidationError extends Error {
  constructor(message: string, public readonly path: string) {
    super(`${path}: ${message}`);
    this.name = 'ValidationError';
  }
}

export type Validator<T> = (value: unknown, path?: string) => T;

function ensureFinite(value: unknown, path: string): number {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw new ValidationError('expected finite number', path);
  }
  return value;
}

export const v = {
  string: (opts?: { min?: number; max?: number }): Validator<string> =>
    (value, path = '$') => {
      if (typeof value !== 'string') {
        throw new ValidationError('expected string', path);
      }
      if (opts?.min != null && value.length < opts.min) {
        throw new ValidationError(`string too short (< ${opts.min})`, path);
      }
      if (opts?.max != null && value.length > opts.max) {
        throw new ValidationError(`string too long (> ${opts.max})`, path);
      }
      return value;
    },

  number: (opts?: { min?: number; max?: number }): Validator<number> =>
    (value, path = '$') => {
      const n = ensureFinite(value, path);
      if (opts?.min != null && n < opts.min) {
        throw new ValidationError(`less than min ${opts.min}`, path);
      }
      if (opts?.max != null && n > opts.max) {
        throw new ValidationError(`greater than max ${opts.max}`, path);
      }
      return n;
    },

  integer: (opts?: { min?: number; max?: number }): Validator<number> =>
    (value, path = '$') => {
      const n = ensureFinite(value, path);
      if (!Number.isInteger(n)) {
        throw new ValidationError('expected integer', path);
      }
      if (opts?.min != null && n < opts.min) {
        throw new ValidationError(`less than min ${opts.min}`, path);
      }
      if (opts?.max != null && n > opts.max) {
        throw new ValidationError(`greater than max ${opts.max}`, path);
      }
      return n;
    },

  boolean: (): Validator<boolean> =>
    (value, path = '$') => {
      if (typeof value !== 'boolean') {
        throw new ValidationError('expected boolean', path);
      }
      return value;
    },

  array: <T>(
    item: Validator<T>,
    opts?: { min?: number; max?: number },
  ): Validator<T[]> =>
    (value, path = '$') => {
      if (!Array.isArray(value)) {
        throw new ValidationError('expected array', path);
      }
      if (opts?.min != null && value.length < opts.min) {
        throw new ValidationError(`array too short (< ${opts.min})`, path);
      }
      if (opts?.max != null && value.length > opts.max) {
        throw new ValidationError(`array too long (> ${opts.max})`, path);
      }
      return value.map((x, i) => item(x, `${path}[${i}]`));
    },

  object: <T extends Record<string, Validator<unknown>>>(
    shape: T,
    opts?: { strict?: boolean },
  ): Validator<{ [K in keyof T]: ReturnType<T[K]> }> =>
    (value, path = '$') => {
      if (!value || typeof value !== 'object' || Array.isArray(value)) {
        throw new ValidationError('expected object', path);
      }
      const record = value as Record<string, unknown>;
      const out: Record<string, unknown> = {};
      for (const key of Object.keys(shape)) {
        out[key] = shape[key](record[key], `${path}.${key}`);
      }
      if (opts?.strict) {
        for (const key of Object.keys(record)) {
          if (!(key in shape)) {
            throw new ValidationError(`unexpected key '${key}'`, path);
          }
        }
      }
      return out as { [K in keyof T]: ReturnType<T[K]> };
    },

  optional: <T>(inner: Validator<T>): Validator<T | undefined> =>
    (value, path = '$') => {
      if (value === undefined || value === null) return undefined;
      return inner(value, path);
    },

  nullable: <T>(inner: Validator<T>): Validator<T | null> =>
    (value, path = '$') => {
      if (value === null) return null;
      if (value === undefined) {
        throw new ValidationError('expected value or null', path);
      }
      return inner(value, path);
    },

  oneOf: <T extends string>(options: readonly T[]): Validator<T> =>
    (value, path = '$') => {
      if (typeof value !== 'string' || !options.includes(value as T)) {
        throw new ValidationError(
          `expected one of: ${options.join(', ')}`,
          path,
        );
      }
      return value as T;
    },

  record: <T>(valueValidator: Validator<T>): Validator<Record<string, T>> =>
    (value, path = '$') => {
      if (!value || typeof value !== 'object' || Array.isArray(value)) {
        throw new ValidationError('expected record/object', path);
      }
      const out: Record<string, T> = {};
      for (const [k, val] of Object.entries(value)) {
        out[k] = valueValidator(val, `${path}.${k}`);
      }
      return out;
    },

  union: <T extends Validator<unknown>[]>(
    ...options: T
  ): Validator<ReturnType<T[number]>> =>
    (value, path = '$') => {
      const errors: string[] = [];
      for (const validator of options) {
        try {
          return validator(value, path) as ReturnType<T[number]>;
        } catch (err) {
          errors.push(err instanceof Error ? err.message : String(err));
        }
      }
      throw new ValidationError(
        `no union branch matched (${errors.join(' | ')})`,
        path,
      );
    },

  passthrough: <T = unknown>(): Validator<T> => (value) => value as T,
};

/**
 * Strip common LLM wrappers (code fences, prose) and parse JSON.
 * Accepts raw strings like:
 *   ```json\n{"a":1}\n```
 *   Here is your result: {"a":1}
 *   {"a":1}
 */
export function parseLooseJson(raw: string): unknown {
  if (typeof raw !== 'string') {
    throw new ValidationError('expected raw string', '$');
  }

  let s = raw.trim();

  // Strip UTF-8 BOM if present.
  if (s.charCodeAt(0) === 0xfeff) {
    s = s.slice(1);
  }

  // Strip leading code fence.
  s = s.replace(/^```(?:json|javascript|js)?\s*\n?/i, '');
  // Strip trailing code fence.
  s = s.replace(/\n?```\s*$/i, '');

  // If there is prose before the JSON, locate the first { or [.
  const firstStructural = s.search(/[\[\{]/);
  if (firstStructural > 0) {
    s = s.slice(firstStructural);
  }

  // Trim trailing text after the last } or ].
  const lastStructural = Math.max(s.lastIndexOf('}'), s.lastIndexOf(']'));
  if (lastStructural >= 0 && lastStructural < s.length - 1) {
    s = s.slice(0, lastStructural + 1);
  }

  try {
    return JSON.parse(s);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    throw new ValidationError(`invalid JSON (${msg})`, '$');
  }
}

export interface ValidationSuccess<T> {
  ok: true;
  value: T;
}

export interface ValidationFailure {
  ok: false;
  error: string;
  rawPreview: string;
}

export type ValidationResult<T> = ValidationSuccess<T> | ValidationFailure;

/**
 * Parse an LLM response string and validate it against a schema.
 * Never throws; returns a discriminated union for the caller to handle.
 */
export function parseAndValidateLLMResponse<T>(
  raw: string,
  validator: Validator<T>,
): ValidationResult<T> {
  try {
    const parsed = parseLooseJson(raw);
    const validated = validator(parsed);
    return { ok: true, value: validated };
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return {
      ok: false,
      error: message,
      rawPreview: typeof raw === 'string' ? raw.slice(0, 500) : String(raw),
    };
  }
}
