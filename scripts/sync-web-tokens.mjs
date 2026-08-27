#!/usr/bin/env node
/**
 * 디자인 토큰 SoT → 웹 CSS 변수 동기화.
 *
 * Source: packages/design-tokens/src/index.ts (createFortuneTheme('light'))
 * Logic:  packages/design-tokens/src/css.ts   (toCssVariables)
 * Output: apps/web/src/styles/tokens.css
 *
 * 실행: pnpm sync:web-tokens  (root package.json)
 * CI 가 `check:web-tokens` 로 generated 파일이 SoT 와 sync 되어 있는지 검증.
 *
 * 왜 css.ts 를 직접 import 하지 않나:
 *   CI 는 Node 20 이라 `--experimental-strip-types` (22.6+) 를 못 쓴다.
 *   design-tokens 가 이미 devDependency 로 가진 typescript 로 transpile 한 뒤
 *   temp dir 에서 ESM 으로 import 한다. 새 의존성 추가 없음.
 */
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath, pathToFileURL } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SRC_DIR = path.join(ROOT, 'packages', 'design-tokens', 'src');
const OUT = path.join(ROOT, 'apps', 'web', 'src', 'styles', 'tokens.css');

const HEADER = `/* AUTO-GENERATED FILE — DO NOT EDIT DIRECTLY.
 *
 * Source: packages/design-tokens/src/index.ts (createFortuneTheme('light'))
 * Regenerate: pnpm sync:web-tokens
 *
 * 본 파일을 직접 수정하면 CI 가 fail. 토큰 변경은 design-tokens SoT 에서.
 */
`;

for (const name of ['index.ts', 'css.ts']) {
  const file = path.join(SRC_DIR, name);
  if (!fs.existsSync(file)) {
    console.error(`ERROR: SoT 파일 없음: ${file}`);
    process.exit(1);
  }
}

const requireFromTokens = createRequire(path.join(ROOT, 'packages', 'design-tokens', 'package.json'));
const ts = requireFromTokens('typescript');

const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'ondo-web-tokens-'));
let css;
try {
  // temp dir 을 ESM 으로 강제 — 없으면 Node 가 .js 를 CJS 로 읽어서 import 문이 깨진다.
  fs.writeFileSync(path.join(tmpDir, 'package.json'), JSON.stringify({ type: 'module' }));

  for (const name of ['index', 'css']) {
    const source = fs.readFileSync(path.join(SRC_DIR, `${name}.ts`), 'utf8');
    const { outputText } = ts.transpileModule(source, {
      fileName: `${name}.ts`,
      compilerOptions: {
        target: ts.ScriptTarget.ES2022,
        module: ts.ModuleKind.ESNext,
      },
    });
    fs.writeFileSync(path.join(tmpDir, `${name}.js`), outputText);
  }

  const { toCssVariables } = await import(pathToFileURL(path.join(tmpDir, 'css.js')).href);
  css = toCssVariables('light');
} finally {
  fs.rmSync(tmpDir, { recursive: true, force: true });
}

fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, `${HEADER}\n${css}`);

console.log(`✓ Synced: ${OUT}`);
