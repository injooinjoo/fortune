#!/usr/bin/env node
/**
 * `apps/web` 유닛 테스트를 CI 에서 돌린다.
 *
 * 테스트 파일 8개가 저장소에 있는데 실행되는 곳이 어디에도 없었다. ci.yml 에는
 * typecheck / build / Playwright 만 있고 `node --test` 단계가 없다. 그래서
 * `lib/` 의 순수 로직(잔액 정규화, 분석 이벤트 화이트리스트, 운세 요약 투영,
 * 스냅샷 차단 키…)이 아무 게이트 없이 master 로 들어가고 있었다.
 *
 * 한 가지 걸림돌은 `.tsx` 다. Node 26 의 타입 스트리핑은 JSX 를 다루지 못해서
 * (`ERR_UNKNOWN_FILE_EXTENSION`) React 컴포넌트를 렌더하는 테스트는 그대로는
 * 못 돈다. 목록을 손으로 관리하면 새 테스트가 조용히 빠지므로, 여기서 각
 * 테스트의 import 를 보고 JSX 가 필요한 것만 자동으로 건너뛴다. 건너뛴 파일은
 * 이름을 출력해서 눈에 보이게 남긴다.
 */

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { glob } from 'node:fs/promises';
import { relative, resolve } from 'node:path';

const WEB_ROOT = resolve(import.meta.dirname, '..', 'apps', 'web');
const TSX_IMPORT = /from\s+['"][^'"]+\.tsx['"]/;

const all = [];
for await (const entry of glob('src/**/*.test.{ts,tsx}', { cwd: WEB_ROOT })) {
  all.push(entry);
}
all.sort();

const runnable = [];
const skipped = [];
for (const file of all) {
  const source = readFileSync(resolve(WEB_ROOT, file), 'utf8');
  if (file.endsWith('.tsx') || TSX_IMPORT.test(source)) skipped.push(file);
  else runnable.push(file);
}

if (skipped.length > 0) {
  console.log('JSX 가 필요해 Node 테스트 러너로는 건너뜁니다:');
  for (const file of skipped) console.log(`  - ${relative('.', file)}`);
  console.log('');
}

if (runnable.length === 0) {
  console.error('실행할 테스트 파일을 찾지 못했습니다. glob 이 잘못됐는지 확인하세요.');
  process.exit(1);
}

execFileSync(process.execPath, ['--test', ...runnable], {
  cwd: WEB_ROOT,
  stdio: 'inherit',
});
