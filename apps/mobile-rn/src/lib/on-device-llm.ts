/**
 * On-Device LLM Engine — llama.rn 기반 Gemma 4 E2B 추론 엔진
 *
 * GGUF 포맷의 Gemma 2B Q4_K_M 모델을 다운로드 후 디바이스에서 직접 실행합니다.
 * GPU 가속(iOS Metal, Android OpenCL) 자동 적용.
 */

import { initLlama, type LlamaContext } from 'llama.rn';
import * as FileSystem from 'expo-file-system/legacy';
import { Platform } from 'react-native';

import { OnDeviceNotReadyError } from './chat-provider-errors';
import { type ModelStatus } from './on-device-llm-status';

export { type ModelStatus } from './on-device-llm-status';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface ModelDownloadProgress {
  bytesDownloaded: number;
  totalBytes: number;
  percentage: number;
}

export interface OnDeviceGenerateOptions {
  temperature?: number;
  maxTokens?: number;
}

export interface OnDeviceMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface OnDeviceLLMEngine {
  getStatus(): ModelStatus;
  getDownloadProgress(): ModelDownloadProgress | null;
  startDownload(): Promise<void>;
  cancelDownload(): void;
  loadModel(): Promise<void>;
  generate(
    systemPrompt: string,
    messages: OnDeviceMessage[],
    options?: OnDeviceGenerateOptions,
  ): Promise<string>;
  unloadModel(): void;
  isDeviceCapable(): boolean;
}

type StatusListener = (status: ModelStatus) => void;

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const MODEL_FILENAME = 'gemma-2b-it-q4_k_m.gguf';
const MODEL_DIR = `${FileSystem.documentDirectory}models/`;
const MODEL_PATH = `${MODEL_DIR}${MODEL_FILENAME}`;

// Gemma 2B Q4_K_M from Hugging Face (bartowski quantized)
const MODEL_DOWNLOAD_URL =
  'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf';

const STOP_WORDS = [
  '</s>',
  '<end_of_turn>',
  '<eos>',
  '<|im_end|>',
  '<|eot_id|>',
];

// ---------------------------------------------------------------------------
// Engine implementation
// ---------------------------------------------------------------------------

class LlamaOnDeviceLLMEngine implements OnDeviceLLMEngine {
  private status: ModelStatus = 'not-downloaded';
  private downloadProgress: ModelDownloadProgress | null = null;
  private llamaContext: LlamaContext | null = null;
  private downloadResumable: FileSystem.DownloadResumable | null = null;
  private listeners: Set<StatusListener> = new Set();

  constructor() {
    this.checkModelExists().catch(() => undefined);
  }

  // -- Public API -----------------------------------------------------------

  getStatus(): ModelStatus {
    return this.status;
  }

  getDownloadProgress(): ModelDownloadProgress | null {
    return this.downloadProgress;
  }

  onStatusChange(listener: StatusListener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  async startDownload(): Promise<void> {
    if (this.status === 'downloading') return;
    if (this.status === 'ready') return;

    this.setStatus('downloading');
    this.downloadProgress = { bytesDownloaded: 0, totalBytes: 0, percentage: 0 };

    try {
      // Ensure directory exists
      const dirInfo = await FileSystem.getInfoAsync(MODEL_DIR);
      if (!dirInfo.exists) {
        await FileSystem.makeDirectoryAsync(MODEL_DIR, { intermediates: true });
      }

      this.downloadResumable = FileSystem.createDownloadResumable(
        MODEL_DOWNLOAD_URL,
        MODEL_PATH,
        {},
        (progress) => {
          this.downloadProgress = {
            bytesDownloaded: progress.totalBytesWritten,
            totalBytes: progress.totalBytesExpectedToWrite,
            percentage: progress.totalBytesExpectedToWrite > 0
              ? Math.round(
                  (progress.totalBytesWritten / progress.totalBytesExpectedToWrite) * 100,
                )
              : 0,
          };
        },
      );

      const result = await this.downloadResumable.downloadAsync();
      if (result?.uri) {
        console.log('[OnDeviceLLM] Model downloaded to:', result.uri);
        this.setStatus('not-downloaded'); // will become 'ready' after checkModelExists
        await this.checkModelExists();
      }
    } catch (error) {
      console.error('[OnDeviceLLM] Download failed:', error);
      this.setStatus('error');
      throw error;
    } finally {
      this.downloadResumable = null;
      this.downloadProgress = null;
    }
  }

  cancelDownload(): void {
    if (this.downloadResumable) {
      this.downloadResumable.pauseAsync().catch(() => undefined);
      this.downloadResumable = null;
      this.downloadProgress = null;
      this.setStatus('not-downloaded');
    }
  }

  async loadModel(): Promise<void> {
    if (this.llamaContext) return; // already loaded
    if (this.status !== 'ready' && this.status !== 'not-downloaded') {
      await this.checkModelExists();
    }
    if (this.status !== 'ready') {
      throw new Error('모델이 다운로드되지 않았어요');
    }

    this.setStatus('loading');
    try {
      this.llamaContext = await initLlama({
        model: MODEL_PATH,
        n_ctx: 2048,
        n_gpu_layers: Platform.OS === 'ios' ? 99 : 32,
        n_threads: 4,
        use_mlock: true,
        use_mmap: true,
      });
      this.setStatus('ready');
      console.log('[OnDeviceLLM] Model loaded, GPU:', this.llamaContext.gpu);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const isJsiInstallFailure =
        message.includes("property 'install'") ||
        message.includes('JSI bindings not installed');

      if (isJsiInstallFailure) {
        console.warn('[OnDeviceLLM] Native binding unavailable:', message);
        this.setStatus('unsupported');
        throw new OnDeviceNotReadyError('unsupported');
      }

      console.error('[OnDeviceLLM] Model load failed:', error);
      this.setStatus('error');
      throw error;
    }
  }

  async generate(
    systemPrompt: string,
    messages: OnDeviceMessage[],
    options?: OnDeviceGenerateOptions,
  ): Promise<string> {
    if (!this.llamaContext) {
      await this.loadModel();
    }
    if (!this.llamaContext) {
      throw new Error('모델을 로드할 수 없어요');
    }

    const chatMessages: Array<{ role: string; content: string }> = [
      { role: 'system', content: systemPrompt },
      ...messages.map((m) => ({ role: m.role, content: m.content })),
    ];

    const result = await this.llamaContext.completion({
      messages: chatMessages,
      n_predict: options?.maxTokens ?? 512,
      temperature: options?.temperature ?? 0.7,
      top_k: 40,
      top_p: 0.9,
      min_p: 0.05,
      stop: STOP_WORDS,
      penalty_repeat: 1.1,
    });

    return result.text.trim();
  }

  unloadModel(): void {
    if (this.llamaContext) {
      this.llamaContext.release().catch(() => undefined);
      this.llamaContext = null;
      this.checkModelExists().catch(() => undefined);
    }
  }

  isDeviceCapable(): boolean {
    // GGUF Q4_K_M 2B model needs ~2GB RAM. Most modern devices support this.
    // Platform-specific checks can be added later if needed.
    return true;
  }

  // -- Internal -------------------------------------------------------------

  private async checkModelExists(): Promise<void> {
    try {
      const info = await FileSystem.getInfoAsync(MODEL_PATH);
      if (info.exists && info.size && info.size > 100_000_000) {
        // File exists and is >100MB (sanity check)
        this.setStatus('ready');
      } else {
        this.setStatus('not-downloaded');
      }
    } catch {
      this.setStatus('not-downloaded');
    }
  }

  private setStatus(next: ModelStatus): void {
    if (this.status === next) return;
    this.status = next;
    for (const listener of this.listeners) {
      try { listener(next); } catch { /* ignore */ }
    }
  }
}

// ---------------------------------------------------------------------------
// Singleton export
// ---------------------------------------------------------------------------

export const onDeviceLLMEngine = new LlamaOnDeviceLLMEngine() as OnDeviceLLMEngine &
  Pick<LlamaOnDeviceLLMEngine, 'onStatusChange'>;
