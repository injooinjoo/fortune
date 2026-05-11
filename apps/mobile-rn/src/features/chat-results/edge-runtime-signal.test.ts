import { fetchEmbeddedEdgeResultPayload } from './edge-runtime';

// Type-level regression: user-cancel must be plumbed into Edge fortune generation.
// Before the implementation this fails because `signal` is not accepted in options.
void fetchEmbeddedEdgeResultPayload('daily', {}, {
  signal: new AbortController().signal,
  userId: 'typecheck-user',
});
