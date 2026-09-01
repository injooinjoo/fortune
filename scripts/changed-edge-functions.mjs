#!/usr/bin/env node
/**
 * 두 커밋 사이에서 실제로 재배포가 필요한 엣지 함수 슬러그만 뽑는다.
 *
 * 저장소에는 함수가 92개 있고 Supabase 쪽에는 180개가 떠 있다(오래전에 지운
 * 함수들이 남아 있다). 그래서 `supabase/functions/**` 가 하나라도 바뀌었다고
 * 전부 재배포하면, 지금 저장소에 없거나 오래 방치돼 번들이 깨진 함수까지
 * 건드리게 된다. 바뀐 파일에 실제로 도달하는 함수만 고른다.
 *
 * 판정 방법은 역방향 도달성이다. 함수 디렉터리에서 시작해 `supabase/functions`
 * 안의 상대 import 를 전이적으로 따라가며 닿는 파일 집합을 만들고, 그 집합이
 * 변경 파일과 겹치면 배포 대상이다. `_shared/a.ts` 가 `_shared/b.ts` 를 부르는
 * 다단 경유도 이 방식이면 자동으로 잡힌다.
 *
 * 사용법:
 *   node scripts/changed-edge-functions.mjs <base-ref> <head-ref>
 *   node scripts/changed-edge-functions.mjs --files <path> [<path> ...]
 *
 * 배포할 게 없으면 아무것도 출력하지 않고 0 으로 끝난다.
 */

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';

const REPO_ROOT = resolve(new URL('..', import.meta.url).pathname);
const FUNCTIONS_ROOT = join(REPO_ROOT, 'supabase', 'functions');
const FUNCTIONS_PREFIX = 'supabase/functions/';
const SOURCE_EXTENSIONS = ['.ts', '.tsx', '.js', '.mjs', '.json'];

/** `from '...'` / `import('...')` 의 경로 리터럴. Deno 코드라 확장자가 명시돼 있다. */
const IMPORT_SPECIFIER = /(?:from|import)\s*\(?\s*['"]([^'"]+)['"]/g;

function changedFilesFromGit(baseRef, headRef) {
  const out = execFileSync(
    'git',
    ['diff', '--name-only', `${baseRef}..${headRef}`, '--', 'supabase/functions'],
    { cwd: REPO_ROOT, encoding: 'utf8' },
  );
  return out.split('\n').map((line) => line.trim()).filter(Boolean);
}

function listSourceFiles(dir) {
  const found = [];
  const walk = (current) => {
    for (const entry of readdirSync(current)) {
      const full = join(current, entry);
      if (statSync(full).isDirectory()) {
        walk(full);
      } else if (SOURCE_EXTENSIONS.some((ext) => entry.endsWith(ext))) {
        found.push(full);
      }
    }
  };
  walk(dir);
  return found;
}

/** 한 파일이 직접 부르는, `supabase/functions` 안의 상대 경로 import 들. */
function localImportsOf(absoluteFile) {
  let source;
  try {
    source = readFileSync(absoluteFile, 'utf8');
  } catch {
    return [];
  }

  const targets = [];
  for (const match of source.matchAll(IMPORT_SPECIFIER)) {
    const specifier = match[1];
    if (!specifier.startsWith('.')) continue; // npm:/jsr:/https: 는 배포 판정과 무관하다

    const resolved = resolve(dirname(absoluteFile), specifier);
    if (!resolved.startsWith(FUNCTIONS_ROOT)) continue;

    if (existsSync(resolved) && statSync(resolved).isFile()) {
      targets.push(resolved);
      continue;
    }
    // 확장자를 생략했거나 디렉터리를 가리키는 경우까지만 보정한다.
    for (const ext of SOURCE_EXTENSIONS) {
      if (existsSync(resolved + ext)) {
        targets.push(resolved + ext);
        break;
      }
      const asIndex = join(resolved, `index${ext}`);
      if (existsSync(asIndex)) {
        targets.push(asIndex);
        break;
      }
    }
  }
  return targets;
}

/** 함수 디렉터리에서 전이적으로 닿는 파일 전체를 repo 상대 경로로 돌려준다. */
function reachableFrom(functionDir) {
  const seen = new Set();
  const queue = listSourceFiles(functionDir);

  while (queue.length > 0) {
    const file = queue.pop();
    const key = relative(REPO_ROOT, file).replaceAll('\\', '/');
    if (seen.has(key)) continue;
    seen.add(key);
    for (const next of localImportsOf(file)) queue.push(next);
  }
  return seen;
}

function main() {
  const args = process.argv.slice(2);
  let changed;

  if (args[0] === '--files') {
    changed = args.slice(1);
  } else if (args.length === 2) {
    changed = changedFilesFromGit(args[0], args[1]);
  } else {
    process.stderr.write(
      'usage: changed-edge-functions.mjs <base-ref> <head-ref> | --files <path>...\n',
    );
    process.exit(2);
  }

  const changedSet = new Set(changed.filter((p) => p.startsWith(FUNCTIONS_PREFIX)));
  if (changedSet.size === 0) return;

  const slugs = readdirSync(FUNCTIONS_ROOT).filter((entry) => {
    if (entry.startsWith('_') || entry.startsWith('.')) return false;
    return statSync(join(FUNCTIONS_ROOT, entry)).isDirectory();
  });

  const affected = slugs.filter((slug) => {
    const reachable = reachableFrom(join(FUNCTIONS_ROOT, slug));
    for (const file of changedSet) {
      if (reachable.has(file)) return true;
    }
    return false;
  });

  if (affected.length > 0) process.stdout.write(`${affected.sort().join('\n')}\n`);
}

main();
