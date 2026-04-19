import { type ModelStatus } from './on-device-llm-status';

/**
 * Thrown when the user has explicitly chosen `aiMode='on-device'` but the
 * local model is not yet downloaded/loaded (or unsupported on this build).
 * Callers should surface a "preparing" UX instead of silently falling back
 * to the cloud.
 */
export class OnDeviceNotReadyError extends Error {
  constructor(public readonly status: ModelStatus) {
    super(`온디바이스 모델이 준비되지 않았어요 (status=${status})`);
    this.name = 'OnDeviceNotReadyError';
  }
}
