import * as fs from 'node:fs';
import * as path from 'node:path';
import { randomUUID } from 'node:crypto';

import {
  FORTUNE_CATALOG,
  fortuneTypesById,
  resolveFortuneEndpoint
} from '@fortune/product-contracts';

const { getChatSurveyDefinition } = await import(
  '../../apps/mobile-rn/src/features/chat-survey/registry.ts'
);
const { fortuneTypeToResultKind } = await import(
  '../../apps/mobile-rn/src/features/fortune-results/mapping.ts'
);

const root = path.resolve(import.meta.dirname, '../..');
const outDir = path.join(root, 'artifacts/qa/haneul-fortune-e2e');
fs.mkdirSync(outDir, { recursive: true });

function loadEnv() {
  const initial = new Set(Object.keys(process.env));
  const appEnv = process.env.EXPO_PUBLIC_APP_ENV ?? process.env.APP_ENV ?? process.env.NODE_ENV ?? 'development';
  for (const name of ['.env', `.env.${appEnv}`, '.env.local', `.env.${appEnv}.local`]) {
    const file = path.join(root, name);
    if (!fs.existsSync(file)) continue;
    for (const raw of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
      const line = raw.trim();
      if (!line || line.startsWith('#') || !line.includes('=')) continue;
      const idx = line.indexOf('=');
      const key = line.slice(0, idx).trim();
      if (initial.has(key)) continue;
      let value = line.slice(idx + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      } else {
        value = value.replace(/\s+#.*$/, '');
      }
      const normalizedValue = value.trim().toLowerCase();
      const isPlaceholder =
        !normalizedValue ||
        normalizedValue.includes('placeholder') ||
        normalizedValue.startsWith('your-dev-') ||
        normalizedValue.startsWith('your-prod-') ||
        normalizedValue === 'https://your-dev-project.supabase.co' ||
        normalizedValue === 'https://your-prod-project.supabase.co';
      if (isPlaceholder) continue;
      process.env[key] = value;
    }
  }
}

loadEnv();

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL ?? process.env.SUPABASE_URL ?? process.env.NEXT_PUBLIC_SUPABASE_URL ?? '';
const anonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? process.env.SUPABASE_ANON_KEY ?? process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? '';
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY ?? '';
const authMode = process.argv.find((a) => a.startsWith('--auth='))?.slice('--auth='.length) ?? 'anon';
const explicitAuthToken = process.env.SUPABASE_AUTH_TOKEN ?? process.env.QA_SUPABASE_AUTH_TOKEN ?? '';
const authKey = explicitAuthToken || (authMode === 'service-role' && serviceRoleKey ? serviceRoleKey : anonKey);
const qaUserId = process.env.TEST_USER_ID && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(process.env.TEST_USER_ID)
  ? process.env.TEST_USER_ID
  : randomUUID();
if (!supabaseUrl || !anonKey) {
  throw new Error('Missing Supabase URL/anon key in env');
}

const fixtureImagePath = path.join(root, 'pencil-profile-export.png');
const fixturePngBase64 = fs.existsSync(fixtureImagePath)
  ? fs.readFileSync(fixtureImagePath).toString('base64')
  : 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';
const fixtureImageDataUrl = `data:image/png;base64,${fixturePngBase64}`;

const profile = {
  displayName: '하늘이QA',
  birthDate: '1990-05-11',
  birthTime: '09:30',
  gender: 'female',
  mbti: 'ENFJ',
  bloodType: 'O',
};

function showWhenMatches(showWhen, answers) {
  if (!showWhen) return true;
  return Object.entries(showWhen).every(([key, expected]) => {
    const actual = answers[key];
    return Array.isArray(expected) ? expected.includes(actual) : actual === expected;
  });
}

function answerForStep(step) {
  const first = step.options?.find((o) => o.id !== 'skip') ?? step.options?.[0];
  switch (step.inputKind) {
    case 'chips':
    case 'deck-picker':
      return first?.id ?? 'default';
    case 'multi-select':
      return (step.options ?? []).filter((o) => o.id !== 'skip').slice(0, step.maxSelections ?? 2).map((o) => o.id);
    case 'date':
      return step.id.toLowerCase().includes('moving') ? '2026-06-01' : '1990-05-11';
    case 'card-draw':
      return [1, 5, 9];
    case 'image':
      return fixtureImageDataUrl;
    case 'mbti-axis':
      return 'ENFJ';
    case 'text-with-skip':
    case 'text':
    default: {
      const id = String(step.id).toLowerCase();
      if (id.includes('celebrity')) return '아이유';
      if (id.includes('chat')) return '상대: 오늘 시간 돼? 나: 응, 저녁에 보자!';
      if (id.includes('team')) return '서울 vs 부산';
      if (id.includes('area')) return '서울 강남구';
      if (id.includes('pet')) return '몽이';
      if (id.includes('name')) return '하늘이QA';
      if (id.includes('wish')) return '올해 건강하고 프로젝트가 잘 되게 해주세요';
      if (id.includes('dream')) return '푸른 하늘을 나는 꿈을 꾸었어요';
      if (id.includes('context')) return '첫 QA 스모크 테스트용 입력입니다';
      return 'QA 스모크 테스트용 입력입니다';
    }
  }
}

function buildAnswers(fortuneType) {
  const definition = getChatSurveyDefinition(fortuneType);
  const answers = {};
  if (!definition) return answers;
  for (const step of definition.steps) {
    if (!showWhenMatches(step.showWhen, answers)) continue;
    answers[step.id] = answerForStep(step);
  }
  return answers;
}

function labelFor(definition, answers, id) {
  const step = definition?.steps?.find((s) => s.id === id);
  const value = answers[id];
  if (!step || value == null) return typeof value === 'string' ? value : undefined;
  if (Array.isArray(value)) {
    return value.map((v) => step.options?.find((o) => o.id === v)?.label ?? String(v)).join(', ');
  }
  return step.options?.find((o) => o.id === value)?.label ?? String(value);
}

function copy(payload, value, ...keys) {
  if (value == null || value === '' || value === 'skip') return;
  const text = Array.isArray(value) ? value : String(value);
  for (const key of keys) payload[key] = text;
}

function buildBody(fortuneType, answers) {
  const definition = getChatSurveyDefinition(fortuneType);
  const labels = new Proxy({}, { get: (_t, p) => labelFor(definition, answers, p) });
  const body = {
    fortuneType,
    fortune_type: fortuneType,
    userId: qaUserId,
    user_id: qaUserId,
    name: profile.displayName,
    displayName: profile.displayName,
    birthDate: profile.birthDate,
    birth_date: profile.birthDate,
    birthTime: profile.birthTime,
    birth_time: profile.birthTime,
    gender: profile.gender,
    mbti: profile.mbti,
    bloodType: profile.bloodType,
    blood_type: profile.bloodType,
    date: new Date().toISOString().slice(0, 10),
    idempotencyKey: `hermes-qa:${fortuneType}:${Date.now()}`,
  };
  for (const [k, v] of Object.entries(answers)) copy(body, v, k);

  switch (fortuneType) {
    case 'tarot': body.selectedCards = [0, 19, 17]; body.selectedCardIndices = [0, 19, 17]; break;
    case 'palm-reading': body.posterType = 'palm-reading'; body.handImageBase64 = fixturePngBase64; body.imageBase64 = fixturePngBase64; break;
    case 'face-reading': body.faceImageBase64 = fixturePngBase64; break;
    case 'past-life': body.faceImageBase64 = fixturePngBase64; break;
    case 'beauty-simulation': body.posterType = 'beauty-simulation'; body.imageBase64 = fixturePngBase64; body.contextText = labels.styleGoal ?? '자연스럽고 밝은 이미지'; break;
    case 'hair-style-guide': body.posterType = 'hair-style-guide'; body.imageBase64 = fixturePngBase64; body.contextText = labels.hairGoal ?? '단정한 스타일 추천'; break;
    case 'face-reading-guide': body.posterType = 'face-reading-guide'; body.imageBase64 = fixturePngBase64; body.contextText = '관상 기반 스타일 가이드'; break;
    case 'ootd-guide': body.posterType = 'ootd-guide'; body.imageBase64 = fixturePngBase64; body.contextText = labels.lookContext ?? 'daily'; break;
    case 'blind-date-guide': body.posterType = 'blind-date-guide'; body.imageBase64 = fixturePngBase64; body.contextText = '소개팅 전 첫인상 가이드'; break;
    case 'past-life-guide': body.posterType = 'past-life-guide'; body.contextText = `${labels.eraVibe ?? '조선시대'} / 전생 가이드`; break;
    case 'mbti': body.mbti = 'ENFJ'; copy(body, labels.category, 'category'); break;
    case 'personality-dna': body.mbti = 'ENFJ'; body.zodiac = labels.zodiac ?? '쌍둥이자리'; break;
    case 'celebrity': copy(body, answers.celebrityName ?? '아이유', 'celebrityName', 'celebrity_name'); copy(body, labels.mode, 'mode', 'analysis_mode'); break;
    case 'chat-insight': copy(body, labels.relationship, 'relationship'); copy(body, labels.curiosity, 'curiosity'); copy(body, answers.chatContent, 'chatContent', 'chat_content'); break;
    case 'moving': body.currentArea = '서울 강남구'; body.current_area = '서울 강남구'; body.targetArea = '서울 마포구'; body.target_area = '서울 마포구'; body.movingDate = '2026-06-01'; break;
    case 'pet-compatibility': body.petName = '몽이'; body.pet_name = '몽이'; copy(body, labels.petType ?? '강아지', 'petType', 'pet_type'); break;
    case 'game-enhance': copy(body, labels.gameType ?? '롤', 'gameType', 'game_type'); copy(body, labels.goal ?? '랭크 상승', 'goal'); break;
    case 'birthstone': body.birthMonth = 5; body.birth_month = 5; body.month = 5; break;
    case 'naming': body.motherBirthDate = '1990-05-11'; body.expectedBirthDate = '2026-12-01'; body.babyGender = 'female'; body.familyName = '김'; body.nameStyle = 'modern'; break;
    case 'career': body.currentJob = labels.field ?? 'IT/개발'; body.current_job = body.currentJob; body.careerGoal = labels.concern ?? '성장'; body.career_goal = body.careerGoal; break;
    case 'love': body.age = 34; body.datingStyles = ['thoughtful', 'stable']; body.valueImportance = 'communication'; copy(body, labels.status ?? 'single', 'relationshipStatus', 'relationship_status'); copy(body, labels.concern, 'concern', 'relationshipGoal'); break;
    case 'compatibility': body.person1Name = profile.displayName; body.person2Name = '테스트상대'; body.person1_name = profile.displayName; body.person2_name = '테스트상대'; body.person1_birth_date = profile.birthDate; body.person2_birth_date = '1991-06-12'; body.person1 = { name: profile.displayName, birth_date: profile.birthDate, gender: profile.gender }; body.person2 = { name: '테스트상대', birth_date: '1991-06-12', gender: 'male' }; body.partnerName = '테스트상대'; body.partnerBirth = '1991-06-12'; body.partnerBirthDate = '1991-06-12'; body.partner_birth_date = '1991-06-12'; break;
    case 'ex-lover': body.time_since_breakup = 'recent'; body.breakup_initiator = 'mutual'; body.breakup_detail = '서로 바빠지면서 대화가 줄었고 감정이 식었다고 느껴져 헤어졌어요.'; body.contact_status = 'no_contact'; body.relationshipDepth = 'serious'; body.primaryGoal = 'closure'; body.coreReason = 'communication'; body.breakupTime = labels.breakupTime ?? '1달 이내'; body.breakup_time = body.breakupTime; body.breakupPeriod = body.breakupTime; break;
    case 'health': body.currentCondition = labels.currentCondition ?? '보통'; body.current_condition = body.currentCondition; copy(body, labels.concern, 'concern'); break;
    case 'decision': body.question = '이 프로젝트를 계속 밀어붙여도 될까요?'; body.options = ['계속 진행', '잠시 점검']; break;
    case 'family': copy(body, labels.concern ?? '건강', 'concern', 'family_type'); break;
    case 'dream': copy(body, answers.dreamContent ?? answers.dream ?? '푸른 하늘을 나는 꿈', 'dreamContent', 'dream_content', 'dream'); break;
    case 'wish': copy(body, answers.wish ?? '올해 건강과 성장을 원합니다', 'wish', 'wishText', 'wish_text'); break;
    case 'talisman': copy(body, answers.wish ?? '행운과 건강', 'wish', 'purpose'); body.category = 'love_relationship'; break;
    case 'talent': body.currentSkills = ['기획', '개발']; body.current_skills = body.currentSkills; break;
    case 'match-insight': body.sport = 'soccer'; body.homeTeam = '서울'; body.awayTeam = '부산'; body.gameDate = body.date; break;
  }
  return body;
}

function summarizeBody(data) {
  const text = JSON.stringify(data ?? '');
  const korean = /[가-힣]/.test(text);
  const hasErrorShape = Boolean(data?.error || data?.code === 'FUNCTIONS_HTTP_ERROR');
  return {
    bytes: text.length,
    korean,
    score: data?.fortune?.score ?? data?.score ?? data?.result?.score ?? null,
    hasFortune: Boolean(data?.success === true || data?.fortune || data?.data || data?.result || data?.cards || data?.summary || data?.content || data?.jobId),
    hasErrorShape,
  };
}

async function invoke(functionName, body, timeoutMs) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  const started = Date.now();
  try {
    const res = await fetch(`${supabaseUrl.replace(/\/$/, '')}/functions/v1/${functionName}`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        apikey: anonKey,
        authorization: `Bearer ${authKey}`,
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    const text = await res.text();
    let data = text;
    try { data = JSON.parse(text); } catch {}
    return { ok: res.ok, status: res.status, ms: Date.now() - started, data, bodyPreview: text.slice(0, 500) };
  } finally {
    clearTimeout(timer);
  }
}

const onlyArg = process.argv.find((a) => a.startsWith('--only='))?.slice('--only='.length);
const includeAsync = process.argv.includes('--include-async');
const live = process.argv.includes('--live');
const timeoutMs = Number(process.argv.find((a) => a.startsWith('--timeout-ms='))?.split('=')[1] ?? (includeAsync ? 90000 : 35000));

const catalogIds = new Set(FORTUNE_CATALOG.map((e) => e.id));
const executionIds = Object.keys(fortuneTypeToResultKind).filter((id) => !onlyArg || onlyArg.split(',').includes(id));
const rows = [];

for (const fortuneType of executionIds) {
  const answers = buildAnswers(fortuneType);
  const endpoint = resolveFortuneEndpoint(fortuneType, answers);
  const resultKind = (fortuneTypeToResultKind)[fortuneType];
  const isAsyncPoster = endpoint === '/generate-poster-guide';
  const localOnly = !endpoint;
  const row = {
    fortuneType,
    catalogExposed: catalogIds.has(fortuneType),
    resultKind,
    endpoint: endpoint ?? '(local)',
    path: localOnly ? 'local/no-edge' : isAsyncPoster ? 'async-poster' : 'edge',
    status: 'NOT_RUN',
  };
  if (localOnly) {
    row.status = 'SKIP_LOCAL';
    row.satisfactionScore = 3;
    row.note = '로컬/비 Edge 경로: 앱 렌더/대화 플로우에서 별도 확인 필요';
    rows.push(row);
    continue;
  }
  if (isAsyncPoster && !includeAsync) {
    row.status = 'SKIP_ASYNC_BY_DEFAULT';
    row.satisfactionScore = 3;
    row.note = '비동기 이미지 생성 경로: --include-async 필요';
    rows.push(row);
    continue;
  }
  if (!live) {
    row.status = 'DRY_RUN';
    row.requestKeys = Object.keys(buildBody(fortuneType, answers)).sort();
    rows.push(row);
    continue;
  }
  const functionName = endpoint.replace(/^\//, '');
  try {
    const response = await invoke(functionName, buildBody(fortuneType, answers), timeoutMs);
    const summary = summarizeBody(response.data);
    row.httpStatus = response.status;
    row.durationMs = response.ms;
    row.responseSummary = summary;
    row.status = response.ok && summary.hasFortune && !summary.hasErrorShape ? 'PASS' : 'FAIL';
    row.satisfactionScore = row.status === 'PASS'
      ? (summary.korean && summary.bytes > 500 ? 4 : 3)
      : 1;
    row.note = response.ok ? response.bodyPreview : response.bodyPreview;
  } catch (error) {
    row.status = error?.name === 'AbortError' ? 'TIMEOUT' : 'ERROR';
    row.satisfactionScore = 1;
    row.note = String(error?.message ?? error).slice(0, 500);
  }
  rows.push(row);
  const notePreview = row.status === 'PASS' ? '' : ` ${String(row.note ?? '').replace(/\s+/g, ' ').slice(0, 160)}`;
  console.log(`${row.status.padEnd(8)} ${fortuneType.padEnd(22)} ${row.endpoint} ${row.httpStatus ?? ''} ${row.durationMs ?? ''}ms${notePreview}`);
}

const stamp = new Date().toISOString().replace(/[:.]/g, '-');
const jsonPath = path.join(outDir, `edge-smoke-${stamp}.json`);
fs.writeFileSync(jsonPath, JSON.stringify({ generatedAt: new Date().toISOString(), live, includeAsync, authMode, rows }, null, 2));
const mdPath = path.join(outDir, `edge-smoke-${stamp}.md`);
const counts = rows.reduce((acc, r) => { acc[r.status] = (acc[r.status] ?? 0) + 1; return acc; }, {});
const md = [
  `# 하늘이 운세 Edge Smoke ${new Date().toISOString()}`,
  '',
  `- live: ${live}`,
  `- includeAsync: ${includeAsync}`,
  `- authMode: ${authMode}`,
  `- total: ${rows.length}`,
  `- counts: ${JSON.stringify(counts)}`,
  '',
  '| fortuneType | resultKind | path | endpoint | status | HTTP | ms | satisfaction | note |',
  '|---|---|---|---|---:|---:|---:|---:|---|',
  ...rows.map((r) => `| ${r.fortuneType} | ${r.resultKind} | ${r.path} | ${r.endpoint} | ${r.status} | ${r.httpStatus ?? ''} | ${r.durationMs ?? ''} | ${r.satisfactionScore ?? ''} | ${String(r.note ?? '').replace(/\|/g, '/').replace(/\s+/g, ' ').slice(0, 180)} |`),
  '',
  `JSON: ${jsonPath}`,
].join('\n');
fs.writeFileSync(mdPath, md);
console.log(`\nWrote ${mdPath}`);
console.log(`Wrote ${jsonPath}`);
console.log(JSON.stringify(counts, null, 2));
