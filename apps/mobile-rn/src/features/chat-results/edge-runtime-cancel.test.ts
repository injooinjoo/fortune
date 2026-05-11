import { fetchEmbeddedEdgeResultPayload, startAsyncPosterJob } from './edge-runtime';

// Type-level regression: all fortune generation entry points must accept AbortSignal
// so a user-initiated cancel can stop network/LLM work before tokens are charged.
const controller = new AbortController();

void fetchEmbeddedEdgeResultPayload('daily', {}, {
  signal: controller.signal,
  userId: 'typecheck-user',
});

void startAsyncPosterJob({
  fortuneType: 'palm-reading',
  characterId: 'haneul-oracle',
  characterName: '하늘이',
  signal: controller.signal,
});
