/**
 * 디자인 토큰 → CSS 커스텀 프로퍼티 변환 (빌드 타임 codegen 전용).
 *
 * 소비자: `scripts/sync-web-tokens.mjs` → `apps/web/src/styles/tokens.css`.
 * 웹 런타임에서 이 파일을 import 하지 말 것 — 웹은 생성된 CSS 만 읽는다.
 *
 * import 가 `./index.js` 인 이유: sync 스크립트가 transpile 후 temp dir 에서
 * ESM 으로 import 하므로 emit 된 specifier 가 그대로 해석돼야 한다.
 * TypeScript 는 Bundler resolution 에서 `.js` → `.ts` 를 알아서 매핑한다.
 */
import { createFortuneTheme } from './index.js';

/**
 * 테마 그룹 → CSS 변수 prefix. 여기 없는 그룹은 출력하지 않는다.
 *
 * 제외 대상:
 *  - `shadows`: shadowOffset / elevation 등 React Native 전용 키. 웹 소비자 0.
 *  - `mode`: 토큰이 아니라 테마 식별자.
 */
const GROUP_PREFIXES = {
  colors: 'color',
  spacing: 'spacing',
  radius: 'radius',
  typography: 'typography',
} as const;

function kebab(key: string): string {
  return key.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
}

/** 숫자는 px, 문자열(색상 / fontWeight)은 그대로. */
function formatValue(value: string | number): string {
  return typeof value === 'number' ? `${value}px` : value;
}

/** 중첩 그룹(elemental.wood, typography.bodyLarge.fontSize)을 평탄화해서 push. */
function emitToken(name: string, value: unknown, lines: string[]): void {
  if (typeof value === 'string' || typeof value === 'number') {
    lines.push(`  --ondo-${name}: ${formatValue(value)};`);
    return;
  }
  if (value !== null && typeof value === 'object') {
    for (const [childKey, childValue] of Object.entries(value as Record<string, unknown>)) {
      emitToken(`${name}-${kebab(childKey)}`, childValue, lines);
    }
  }
}

/**
 * `:root { --ondo-* }` 블록 하나를 문자열로 반환.
 *
 * dark 전용 — `createFortuneTheme('light')` 는 repo 전체에서 호출부가 0 이라
 * 웹도 dark 만 생성한다.
 */
export function toCssVariables(mode: 'dark' = 'dark'): string {
  const theme = createFortuneTheme(mode) as unknown as Record<string, unknown>;
  const lines: string[] = [];

  for (const [group, prefix] of Object.entries(GROUP_PREFIXES)) {
    const groupValues = theme[group];
    if (groupValues === null || typeof groupValues !== 'object') continue;
    for (const [key, value] of Object.entries(groupValues as Record<string, unknown>)) {
      emitToken(`${prefix}-${kebab(key)}`, value, lines);
    }
  }

  return `:root {\n${lines.join('\n')}\n}\n`;
}
