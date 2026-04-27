import Constants from 'expo-constants';
import * as Updates from 'expo-updates';

export const APP_VERSION = Constants.expoConfig?.version ?? '1.0.0';

export const RUNTIME_VERSION =
  typeof Updates.runtimeVersion === 'string' ? Updates.runtimeVersion : null;

export const UPDATE_CHANNEL =
  typeof Updates.channel === 'string' && Updates.channel.length > 0
    ? Updates.channel
    : null;

export const UPDATE_ID =
  typeof Updates.updateId === 'string' && Updates.updateId.length > 0
    ? Updates.updateId.slice(0, 8)
    : null;

export const IS_EMBEDDED_LAUNCH = Updates.isEmbeddedLaunch === true;

function pad2(n: number): string {
  return String(n).padStart(2, '0');
}

// OTA 업데이트 생성 시각을 KST(Asia/Seoul) 기준 "YYYY.MM.DD HH:mm" 로 포맷.
// Intl.DateTimeFormat 은 RN Hermes 에서도 타임존 변환 지원.
function formatKst(date: Date): string {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Seoul',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).formatToParts(date);

  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? '';
  return `${get('year')}.${get('month')}.${get('day')} ${get('hour')}:${get('minute')}`;
}

export const UPDATE_CREATED_AT_KST =
  Updates.createdAt instanceof Date ? formatKst(Updates.createdAt) : null;

// profile 화면용 날짜 전용 라벨 (기존 동작 유지 — 로컬 시각 기준 YYYY-MM-DD).
export const UPDATE_CREATED_AT_DATE =
  Updates.createdAt instanceof Date
    ? `${Updates.createdAt.getFullYear()}-${pad2(Updates.createdAt.getMonth() + 1)}-${pad2(Updates.createdAt.getDate())}`
    : null;

// 스플래시/프로필에서 공통으로 쓰는 빌드 뱃지.
// OTA: "1.0.9 · 2026.04.22 12:43 KST"
// Embedded 프로덕션: "1.0.9 · embedded"
// Dev: "1.0.9 · dev"
export function formatVersionLabel(): string {
  if (__DEV__) {
    return `v${APP_VERSION} · dev`;
  }
  if (IS_EMBEDDED_LAUNCH) {
    return `v${APP_VERSION} · embedded`;
  }
  if (UPDATE_CREATED_AT_KST) {
    return `v${APP_VERSION} · ${UPDATE_CREATED_AT_KST} KST`;
  }
  return `v${APP_VERSION}`;
}

// 프로필 화면의 상세 빌드 뱃지 — 채널/업데이트 ID 까지 포함.
export function formatBuildBadge(): string {
  if (IS_EMBEDDED_LAUNCH) {
    return UPDATE_CHANNEL
      ? `embedded · ${UPDATE_CHANNEL}`
      : '개발 빌드 (embedded)';
  }
  const parts: string[] = [];
  if (UPDATE_CHANNEL) parts.push(UPDATE_CHANNEL);
  if (UPDATE_ID) parts.push(`#${UPDATE_ID}`);
  if (UPDATE_CREATED_AT_KST) parts.push(`${UPDATE_CREATED_AT_KST} KST`);
  return parts.length > 0 ? `OTA · ${parts.join(' · ')}` : 'OTA';
}
