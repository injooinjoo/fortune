/**
 * On-Device LLM Engine — llama.rn 기반 Gemma 4 E2B 추론 엔진
 *
 * GGUF 포맷의 Gemma 4 E2B Q4_K_M 모델(~3.1GB) + 비전 프로젝터 mmproj-F16.gguf
 * (~987MB) 두 파일을 다운로드 후 디바이스에서 직접 실행.
 * GPU 가속(iOS Metal, Android OpenCL) 자동 적용. 멀티모달(이미지 입력) 지원.
 * Chat 포맷은 Gemma 2/3/3n/4 동일 (<start_of_turn>user/model<end_of_turn>).
 */

import {
  addNativeLogListener,
  initLlama,
  toggleNativeLog,
  type LlamaContext,
} from 'llama.rn';
import * as FileSystem from 'expo-file-system/legacy';
import { Platform } from 'react-native';

import { OnDeviceNotReadyError } from './chat-provider-errors';
import {
  getCachedTierSync,
  resolveDeviceTier,
  type DeviceTier,
} from './device-tier';
import {
  getAllKnownFilenames,
  getVariant,
  type ModelVariant,
  type ModelVariantId,
} from './on-device-model-registry';
import { type ModelStatus } from './on-device-llm-status';

export { type ModelStatus } from './on-device-llm-status';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type DownloadStage = 'model' | 'mmproj';

export interface ModelDownloadProgress {
  /** 현재 단계의 파일 단독 진행 바이트 (디버그용). */
  bytesDownloaded: number;
  /** 현재 단계의 파일 단독 예상 총 바이트 (디버그용). */
  totalBytes: number;
  /**
   * 전체 다운로드 통합 퍼센트 (0-100). model+mmproj 두 파일을 한 덩어리로
   * 취급한 진행률. UI는 이 값만 보여 주는 게 "오르락 내리락" 없이 자연스럽다.
   */
  percentage: number;
  // 참고용 메타.
  stage: DownloadStage;
  currentStage: 1 | 2;
  totalStages: 1 | 2;
}

export interface OnDeviceGenerateOptions {
  temperature?: number;
  maxTokens?: number;
}

export type OnDeviceContentPart =
  | { type: 'text'; text: string }
  | { type: 'image_url'; image_url: { url: string } };

export interface OnDeviceMessage {
  role: 'system' | 'user' | 'assistant';
  content: string | OnDeviceContentPart[];
}

export interface OnDeviceLLMEngine {
  getStatus(): ModelStatus;
  getDownloadProgress(): ModelDownloadProgress | null;
  getLastLoadError(): string | null;
  isMultimodalReady(): boolean;
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
  /** 현재 기기 tier 로 선택된 모델 id. tier='off' 또는 미해석 시 null. */
  getActiveModelId(): ModelVariantId | null;
  /** 현재 variant (Registry 엔트리). UI 에서 라벨/크기 표기용. */
  getActiveVariant(): ModelVariant | null;
  /** 해석/캐시된 tier. 첫 호출 전에는 null 가능. */
  getDeviceTier(): DeviceTier | null;
  /** 다운로드/로드 전 tier 를 선행 해석. UI 부팅 시 호출 권장. */
  ensureTierResolved(): Promise<DeviceTier>;
}

type StatusListener = (status: ModelStatus) => void;

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

// 모든 tier 가 공유하는 저장 디렉토리. 실제 파일명/경로는 variant 별로 다르며
// 엔진 내부 `modelPath()` / `mmprojPath()` getter 가 계산한다.
const MODEL_DIR = `${FileSystem.documentDirectory}models/`;

const STOP_WORDS = [
  '</s>',
  '<end_of_turn>',
  '<eos>',
  '<|im_end|>',
  '<|eot_id|>',
];

// base64 → 임시 파일로 쓸 때의 디렉토리.
const IMAGE_TMP_DIR = `${FileSystem.cacheDirectory ?? FileSystem.documentDirectory}ondevice-images/`;

// ---------------------------------------------------------------------------
// Engine implementation
// ---------------------------------------------------------------------------

class LlamaOnDeviceLLMEngine implements OnDeviceLLMEngine {
  private status: ModelStatus = 'not-downloaded';
  private downloadProgress: ModelDownloadProgress | null = null;
  private llamaContext: LlamaContext | null = null;
  private downloadResumable: FileSystem.DownloadResumable | null = null;
  private listeners: Set<StatusListener> = new Set();
  private lastLoadError: string | null = null;
  private multimodalReady = false;
  /** Native llama.cpp 로그 버퍼 — loadModel 실패 시 실제 원인 파악용. */
  private nativeLogTail: string[] = [];
  private nativeLogSubscription: { remove: () => void } | null = null;
  /** 현재 tier 에서 선택된 variant. `ensureVariant()` 가 최초 1회 해석. */
  private variant: ModelVariant | null = null;
  private tier: DeviceTier | null = null;
  /** 동시에 여러 generate() 가 loadModel 을 호출할 때 중복 실행 방지. */
  private loadPromise: Promise<void> | null = null;

  getLastLoadError(): string | null {
    return this.lastLoadError;
  }

  isMultimodalReady(): boolean {
    return this.multimodalReady;
  }

  getActiveModelId(): ModelVariantId | null {
    return this.variant?.id ?? null;
  }

  getActiveVariant(): ModelVariant | null {
    return this.variant;
  }

  getDeviceTier(): DeviceTier | null {
    return this.tier ?? getCachedTierSync();
  }

  async ensureTierResolved(): Promise<DeviceTier> {
    if (this.tier) return this.tier;
    const tier = await resolveDeviceTier();
    this.tier = tier;
    this.variant = getVariant(tier);
    return tier;
  }

  constructor() {
    // 부팅 시: tier 해석 + 파일 존재 체크만. 자동 loadModel 은 제거
    // (앱 시작 시 3GB 로드로 인한 렉 완화). 실제 로드는 generate() 에서 lazy.
    this.ensureTierResolved()
      .then(() => this.checkModelExists())
      .catch(() => undefined);
  }

  private modelPath(): string {
    if (!this.variant) throw new Error('variant not resolved');
    return `${MODEL_DIR}${this.variant.modelFilename}`;
  }

  private mmprojPath(): string | null {
    if (!this.variant?.mmproj) return null;
    return `${MODEL_DIR}${this.variant.mmproj.filename}`;
  }

  private totalApproxBytes(): number {
    if (!this.variant) return 0;
    return (
      this.variant.approxModelBytes + (this.variant.mmproj?.approxBytes ?? 0)
    );
  }

  /** tier + variant 를 확실히 해석. tier='off' 면 OnDeviceNotReadyError throw. */
  private async ensureVariant(): Promise<ModelVariant> {
    const tier = await this.ensureTierResolved();
    if (tier === 'off' || !this.variant) {
      this.setStatus('unsupported');
      throw new OnDeviceNotReadyError('unsupported');
    }
    return this.variant;
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

    const variant = await this.ensureVariant();
    const totalStages: 1 | 2 = variant.mmproj ? 2 : 1;
    const modelPath = this.modelPath();
    const mmprojPath = this.mmprojPath();

    this.setStatus('downloading');

    try {
      const dirInfo = await FileSystem.getInfoAsync(MODEL_DIR);
      if (!dirInfo.exists) {
        await FileSystem.makeDirectoryAsync(MODEL_DIR, { intermediates: true });
      }

      const modelInfo = await FileSystem.getInfoAsync(modelPath);
      const modelReady =
        modelInfo.exists &&
        modelInfo.size &&
        modelInfo.size > variant.minModelBytes;
      if (!modelReady) {
        await this.downloadFile({
          url: variant.modelUrl,
          destination: modelPath,
          stage: 'model',
          currentStage: 1,
          totalStages,
        });
      }

      if (variant.mmproj && mmprojPath) {
        const mmprojInfo = await FileSystem.getInfoAsync(mmprojPath);
        const mmprojReady =
          mmprojInfo.exists &&
          mmprojInfo.size &&
          mmprojInfo.size > variant.mmproj.minBytes;
        if (!mmprojReady) {
          await this.downloadFile({
            url: variant.mmproj.url,
            destination: mmprojPath,
            stage: 'mmproj',
            currentStage: 2,
            totalStages,
          });
        }
      }

      // 상태 갱신만 — 로드는 generate() 에서 lazy.
      await this.checkModelExists();
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
    if (this.llamaContext) return;
    if (this.loadPromise) return this.loadPromise;

    this.loadPromise = this.doLoadModel().finally(() => {
      this.loadPromise = null;
    });
    return this.loadPromise;
  }

  private async doLoadModel(): Promise<void> {
    const variant = await this.ensureVariant();
    if (this.status !== 'ready' && this.status !== 'not-downloaded') {
      await this.checkModelExists();
    }
    if (this.status !== 'ready') {
      throw new Error('모델이 다운로드되지 않았어요');
    }

    this.setStatus('loading');
    this.lastLoadError = null;
    this.attachNativeLogCapture();
    const mmprojPath = this.mmprojPath();
    try {
      this.llamaContext = await initLlama({
        model: this.modelPath(),
        n_ctx: variant.nCtx,
        n_gpu_layers:
          Platform.OS === 'ios'
            ? variant.nGpuLayersIOS
            : variant.nGpuLayersAndroid,
        n_threads: 4,
        // iOS 에서 mlock 은 entitlement/RAM 부족으로 실패하기 쉬워 기본 off.
        use_mlock: false,
        use_mmap: true,
      });
      this.setStatus('ready');
      console.log(
        `[OnDeviceLLM] Loaded ${variant.id}, GPU: ${this.llamaContext.gpu}`,
      );

      // Multimodal 초기화 — variant 가 mmproj 를 가진 경우만.
      if (variant.mmproj && mmprojPath) {
        try {
          const ctxAny = this.llamaContext as unknown as {
            initMultimodal?: (params: {
              path: string;
              use_gpu?: boolean;
              image_max_tokens?: number;
            }) => Promise<boolean>;
          };
          if (typeof ctxAny.initMultimodal === 'function') {
            const ok = await ctxAny.initMultimodal({
              path: mmprojPath,
              use_gpu: true,
              image_max_tokens: 256,
            });
            this.multimodalReady = ok !== false;
            console.log(
              '[OnDeviceLLM] Multimodal',
              this.multimodalReady ? 'enabled' : 'disabled',
            );
          } else {
            this.multimodalReady = false;
            console.warn(
              '[OnDeviceLLM] initMultimodal not available on this llama.rn',
            );
          }
        } catch (e) {
          this.multimodalReady = false;
          console.warn('[OnDeviceLLM] Multimodal init failed, text-only:', e);
        }
      } else {
        // 텍스트 전용 variant.
        this.multimodalReady = false;
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const isJsiInstallFailure =
        message.includes("property 'install'") ||
        message.includes('property install') ||
        message.includes('install of null') ||
        message.includes('install of undefined') ||
        message.includes('JSI bindings not installed');

      if (isJsiInstallFailure) {
        this.lastLoadError = message;
        console.warn('[OnDeviceLLM] Native binding unavailable:', message);
        this.setStatus('unsupported');
        this.detachNativeLogCapture();
        throw new OnDeviceNotReadyError('unsupported');
      }

      // 진단 정보 수집: 파일 크기 + native log tail.
      const diagnostics = await this.collectLoadDiagnostics();
      const detailed = `${message}\n${diagnostics}`;
      this.lastLoadError = detailed;
      console.error('[OnDeviceLLM] Model load failed:', detailed);
      this.setStatus('error');
      this.detachNativeLogCapture();
      throw new Error(detailed);
    } finally {
      // 성공 경로에서도 log capture 는 정리.
      if (this.status === 'ready') {
        this.detachNativeLogCapture();
      }
    }
  }

  private attachNativeLogCapture(): void {
    this.nativeLogTail = [];
    try {
      toggleNativeLog(true).catch(() => undefined);
      this.nativeLogSubscription = addNativeLogListener((level, text) => {
        const line = `[${level}] ${text}`;
        this.nativeLogTail.push(line);
        // 최근 40줄만 유지.
        if (this.nativeLogTail.length > 40) {
          this.nativeLogTail.splice(0, this.nativeLogTail.length - 40);
        }
      });
    } catch (e) {
      console.warn('[OnDeviceLLM] nativeLog capture unavailable:', e);
    }
  }

  private detachNativeLogCapture(): void {
    try {
      this.nativeLogSubscription?.remove();
    } catch {
      // no-op
    }
    this.nativeLogSubscription = null;
  }

  private async collectLoadDiagnostics(): Promise<string> {
    const lines: string[] = [];
    lines.push(
      `tier=${this.tier ?? 'unknown'} variant=${this.variant?.id ?? 'none'}`,
    );
    try {
      const modelPath = this.variant ? this.modelPath() : '(no variant)';
      if (this.variant) {
        const modelInfo = await FileSystem.getInfoAsync(modelPath);
        lines.push(
          `model: exists=${modelInfo.exists} size=${
            'size' in modelInfo ? modelInfo.size : 'n/a'
          } path=${modelPath}`,
        );
        const mmprojPath = this.mmprojPath();
        if (mmprojPath) {
          const mmprojInfo = await FileSystem.getInfoAsync(mmprojPath);
          lines.push(
            `mmproj: exists=${mmprojInfo.exists} size=${
              'size' in mmprojInfo ? mmprojInfo.size : 'n/a'
            }`,
          );
        }
      }
    } catch (e) {
      lines.push(`fs stat failed: ${e instanceof Error ? e.message : String(e)}`);
    }
    if (this.nativeLogTail.length > 0) {
      lines.push('— native log tail —');
      lines.push(...this.nativeLogTail.slice(-15));
    }
    return lines.join('\n');
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

    // 이미지 파트를 포함하는지 탐지.
    const hasImage = messages.some(
      (m) =>
        Array.isArray(m.content) &&
        m.content.some((c) => c.type === 'image_url'),
    );

    if (hasImage && this.multimodalReady) {
      return this.generateWithMultimodal(systemPrompt, messages, options);
    }

    // 텍스트 전용 경로 — Gemma raw prompt 포맷 유지.
    return this.generateTextOnly(systemPrompt, messages, options);
  }

  unloadModel(): void {
    if (this.llamaContext) {
      this.llamaContext.release().catch(() => undefined);
      this.llamaContext = null;
      this.multimodalReady = false;
      this.checkModelExists().catch(() => undefined);
    }
  }

  isDeviceCapable(): boolean {
    const tier = this.getDeviceTier();
    if (!tier) return true; // 아직 미해석 — 일단 true, generate 시 재확정.
    return tier !== 'off';
  }

  // -- Internal -------------------------------------------------------------

  private async downloadFile(params: {
    url: string;
    destination: string;
    stage: DownloadStage;
    currentStage: 1 | 2;
    totalStages: 1 | 2;
  }): Promise<void> {
    const { url, destination, stage, currentStage, totalStages } = params;
    if (!this.variant) throw new Error('variant not resolved');
    const totalApprox = this.totalApproxBytes();
    // 이전 단계들이 이미 디스크에 쌓아 둔 바이트 (mmproj 단계 진입 시 모델 크기만큼 선가산).
    const priorStagesBytes =
      stage === 'mmproj' ? this.variant.approxModelBytes : 0;

    const computeOverallPercentage = (bytesWritten: number) => {
      if (totalApprox <= 0) return 0;
      const combined = priorStagesBytes + bytesWritten;
      return Math.max(
        0,
        Math.min(100, Math.round((combined / totalApprox) * 100)),
      );
    };

    this.downloadProgress = {
      bytesDownloaded: 0,
      totalBytes: 0,
      percentage: computeOverallPercentage(0),
      stage,
      currentStage,
      totalStages,
    };
    this.downloadResumable = FileSystem.createDownloadResumable(
      url,
      destination,
      {},
      (progress) => {
        this.downloadProgress = {
          bytesDownloaded: progress.totalBytesWritten,
          totalBytes: progress.totalBytesExpectedToWrite,
          percentage: computeOverallPercentage(progress.totalBytesWritten),
          stage,
          currentStage,
          totalStages,
        };
      },
    );
    const result = await this.downloadResumable.downloadAsync();
    if (!result?.uri) {
      throw new Error(`Download did not complete: ${stage}`);
    }
    console.log(`[OnDeviceLLM] ${stage} downloaded to:`, result.uri);
  }

  private async generateTextOnly(
    systemPrompt: string,
    messages: OnDeviceMessage[],
    options?: OnDeviceGenerateOptions,
  ): Promise<string> {
    // Gemma raw prompt 포맷.
    const parts: string[] = [];
    let firstUserSeen = false;
    for (const m of messages) {
      const turnRole = m.role === 'user' ? 'user' : 'model';
      const rawContent = typeof m.content === 'string'
        ? m.content
        : flattenContentToText(m.content);
      const content = !firstUserSeen && m.role === 'user'
        ? `${systemPrompt}\n\n---\n\n${rawContent}`
        : rawContent;
      if (m.role === 'user') firstUserSeen = true;
      parts.push(`<start_of_turn>${turnRole}\n${content}<end_of_turn>`);
    }
    if (!firstUserSeen) {
      parts.unshift(`<start_of_turn>user\n${systemPrompt}<end_of_turn>`);
    }
    parts.push('<start_of_turn>model\n');
    const prompt = parts.join('\n');

    if (!this.llamaContext) throw new Error('no llama context');
    const result = await this.llamaContext.completion({
      prompt,
      n_predict: options?.maxTokens ?? 256,
      temperature: options?.temperature ?? 0.7,
      top_k: 40,
      top_p: 0.9,
      min_p: 0.05,
      stop: [...STOP_WORDS, '<start_of_turn>', '<end_of_turn>'],
      penalty_repeat: 1.15,
      penalty_last_n: 256,
    });
    return result.text.trim();
  }

  private async generateWithMultimodal(
    systemPrompt: string,
    messages: OnDeviceMessage[],
    options?: OnDeviceGenerateOptions,
  ): Promise<string> {
    if (!this.llamaContext) throw new Error('no llama context');

    // 이미지가 들어간 메시지들을 llama.rn `messages` API 형태로 변환.
    // base64 는 임시 파일로 내려쓰고, media_paths 배열에 file URI 를 모은다.
    const rnMessages: Array<{
      role: string;
      content: Array<{
        type: 'text' | 'image_url';
        text?: string;
        image_url?: { url: string };
      }>;
    }> = [];
    const mediaPaths: string[] = [];

    // 첫 user 메시지에 system prompt 를 prepend.
    let systemPrepended = false;

    for (const m of messages) {
      const parts: OnDeviceContentPart[] = Array.isArray(m.content)
        ? m.content
        : [{ type: 'text', text: m.content }];
      const rnParts: Array<{
        type: 'text' | 'image_url';
        text?: string;
        image_url?: { url: string };
      }> = [];
      for (const p of parts) {
        if (p.type === 'text') {
          let text = p.text;
          if (!systemPrepended && m.role === 'user') {
            text = `${systemPrompt}\n\n---\n\n${text}`;
            systemPrepended = true;
          }
          rnParts.push({ type: 'text', text });
        } else if (p.type === 'image_url') {
          const resolved = await this.resolveImageUrl(p.image_url.url);
          mediaPaths.push(resolved);
          rnParts.push({ type: 'image_url', image_url: { url: resolved } });
        }
      }
      rnMessages.push({
        role: m.role === 'user' ? 'user' : m.role === 'assistant' ? 'assistant' : 'user',
        content: rnParts,
      });
    }

    if (!systemPrepended) {
      rnMessages.unshift({
        role: 'user',
        content: [{ type: 'text', text: systemPrompt }],
      });
    }

    const result = await this.llamaContext.completion({
      // llama.rn 의 OAI 호환 messages + media_paths 조합.
      // 타입 정의에 'system' 이 강하게 제한돼 있지 않아 as any 로 우회.
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      messages: rnMessages as any,
      media_paths: mediaPaths,
      n_predict: options?.maxTokens ?? 512,
      temperature: options?.temperature ?? 0.7,
      top_k: 40,
      top_p: 0.9,
      min_p: 0.05,
      stop: [...STOP_WORDS],
      penalty_repeat: 1.15,
      penalty_last_n: 256,
    });
    return result.text.trim();
  }

  /**
   * image_url 이 base64 data URL 이면 임시 파일로 내려쓰고 그 경로 반환.
   * file:// 경로는 그대로 통과. 다른 형식(http 등) 은 예외.
   */
  private async resolveImageUrl(url: string): Promise<string> {
    if (url.startsWith('file://')) return url;
    if (url.startsWith('/')) return `file://${url}`;
    if (url.startsWith('data:')) {
      return this.writeBase64DataUrlToTempFile(url);
    }
    // http(s) 등은 llama.rn 이 지원 안 함. Gemma multimodal 은 로컬 파일 기반.
    throw new Error(`Unsupported image URL scheme: ${url.slice(0, 40)}...`);
  }

  private async writeBase64DataUrlToTempFile(dataUrl: string): Promise<string> {
    // 디렉토리 확보.
    const dirInfo = await FileSystem.getInfoAsync(IMAGE_TMP_DIR);
    if (!dirInfo.exists) {
      await FileSystem.makeDirectoryAsync(IMAGE_TMP_DIR, { intermediates: true });
    }
    // data:image/jpeg;base64,XXXX 파싱.
    const match = /^data:([^;]+);base64,(.+)$/.exec(dataUrl);
    if (!match) {
      throw new Error('Invalid base64 data URL');
    }
    const mime = match[1];
    const b64 = match[2];
    const ext = mime.includes('png') ? 'png'
      : mime.includes('webp') ? 'webp'
      : mime.includes('gif') ? 'gif'
      : 'jpg';
    const filename = `img-${Date.now()}-${Math.floor(Math.random() * 1e6)}.${ext}`;
    const path = `${IMAGE_TMP_DIR}${filename}`;
    await FileSystem.writeAsStringAsync(path, b64, {
      encoding: FileSystem.EncodingType.Base64,
    });
    return path;
  }

  private async checkModelExists(): Promise<void> {
    try {
      // tier 해석 선행 — 'off' 면 unsupported 상태로 고정.
      await this.ensureTierResolved();
      if (this.tier === 'off' || !this.variant) {
        this.setStatus('unsupported');
        return;
      }

      // 현재 variant 에 속하지 않는 낡은 모델 파일 정리.
      await this.cleanupLegacyModelFiles();

      const variant = this.variant;
      const modelInfo = await FileSystem.getInfoAsync(this.modelPath());
      const modelReady =
        modelInfo.exists &&
        modelInfo.size &&
        modelInfo.size > variant.minModelBytes;

      let mmprojReady = true;
      if (variant.mmproj) {
        const mmprojPath = this.mmprojPath();
        if (!mmprojPath) {
          mmprojReady = false;
        } else {
          const mmprojInfo = await FileSystem.getInfoAsync(mmprojPath);
          mmprojReady =
            !!mmprojInfo.exists &&
            !!mmprojInfo.size &&
            mmprojInfo.size > variant.mmproj.minBytes;
        }
      }

      if (modelReady && mmprojReady) {
        this.setStatus('ready');
      } else {
        this.setStatus('not-downloaded');
      }
    } catch {
      this.setStatus('not-downloaded');
    }
  }

  private async cleanupLegacyModelFiles(): Promise<void> {
    const active = new Set<string>();
    if (this.variant) {
      active.add(this.variant.modelFilename);
      if (this.variant.mmproj) active.add(this.variant.mmproj.filename);
    }
    const targets = getAllKnownFilenames().filter((name) => !active.has(name));
    for (const filename of targets) {
      const path = `${MODEL_DIR}${filename}`;
      try {
        const info = await FileSystem.getInfoAsync(path);
        if (info.exists) {
          await FileSystem.deleteAsync(path, { idempotent: true });
          console.log('[OnDeviceLLM] Removed stale model file:', filename);
        }
      } catch {
        // 무시 — 다음 부팅에서 다시 시도.
      }
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

/**
 * content parts 배열을 plain text 로 평탄화 (text-only 경로에서 이미지 메시지
 * 가 들어왔을 때 이미지 설명은 버리고 텍스트 부분만 사용).
 */
function flattenContentToText(parts: OnDeviceContentPart[]): string {
  return parts
    .map((p) => (p.type === 'text' ? p.text : ''))
    .filter((s) => s.length > 0)
    .join('\n');
}

// ---------------------------------------------------------------------------
// Singleton export
// ---------------------------------------------------------------------------

export const onDeviceLLMEngine = new LlamaOnDeviceLLMEngine() as OnDeviceLLMEngine &
  Pick<LlamaOnDeviceLLMEngine, 'onStatusChange'>;
