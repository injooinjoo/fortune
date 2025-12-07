#!/usr/bin/env node
/**
 * Celebrity Notion-Style Avatar Generator
 *
 * Notion Avatar SVG 파츠를 조합하여 각 유명인별 고유 아바타 생성
 * GPT-4를 사용하여 유명인 특징 분석 → 파츠 추천
 *
 * 사용법:
 *   OPENAI_API_KEY=sk-xxx node scripts/generate_celebrity_avatars.js --limit 10
 *   OPENAI_API_KEY=sk-xxx node scripts/generate_celebrity_avatars.js --all
 *   OPENAI_API_KEY=sk-xxx node scripts/generate_celebrity_avatars.js --retry-failed
 *
 * 필요 패키지:
 *   npm install @supabase/supabase-js openai sharp
 */

const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
const OpenAI = require('openai');
const sharp = require('sharp');

// ============ Configuration ============

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const SUPABASE_URL = 'https://hayjukwfcsdmppairazc.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_KEY;

// SVG Parts 경로 (preview 폴더 사용 - 이미 1080x1080 좌표계로 정규화됨)
const PARTS_DIR = path.join(__dirname, '..', 'assets', 'avatar', 'preview');

// 파츠 개수 정의 (1-indexed, 실제 파일은 0-indexed)
// 예: face=16 → 파일은 face-0.svg ~ face-15.svg
const PART_COUNTS = {
  face: 16,       // 0-15
  hair: 59,       // 0-58
  eyes: 14,       // 0-13
  eyebrows: 16,   // 0-15
  nose: 14,       // 0-13
  mouth: 20,      // 0-19
  glasses: 15,    // 0-14
  beard: 17,      // 0-16
  accessories: 15, // 0-14
  details: 14     // 0-13
};

// 파츠 렌더링 순서 (원본 Notion Avatar 순서 - Object.keys 순서)
// face가 먼저, hair가 나중에 와야 머리카락이 얼굴 위에 덮임
const PART_ORDER = [
  'face', 'nose', 'mouth', 'eyes', 'eyebrows',
  'glasses', 'hair', 'accessories', 'details', 'beard'
];

// Celebrity Type별 특징 힌트 (GPT 분석용)
const TYPE_HINTS = {
  'pro_gamer': '프로게이머 - 20대, 게이밍 안경이나 헤드셋 착용 가능, 짧은 머리가 많음, 트렌디한 스타일',
  'streamer': '인터넷 방송인 - 20-30대, 개성있는 헤어스타일, 화려하거나 독특한 외모',
  'politician': '정치인 - 50-70대, 단정하고 보수적인 스타일, 정장, 안경 착용 많음, 회색/흰머리 가능',
  'business': 'CEO/기업인 - 40-60대, 단정하고 프로페셔널, 정장, 안경 착용 가능',
  'solo_singer': '솔로 가수 - 다양한 나이, 개성있는 스타일, 트렌디한 헤어',
  'idol_member': '아이돌 멤버 - 10-20대, 트렌디하고 화려한 스타일, 염색 머리 가능, 젊고 예쁜/잘생긴 외모',
  'actor': '배우 - 다양한 나이, 단정하거나 개성있음, 외모가 준수함',
  'athlete': '운동선수 - 20-30대, 활동적이고 건강한 이미지, 짧은 머리 많음, 근육질',
  'legacy_singer': '트로트/성인가요 가수 - 40-60대, 화려하지만 클래식한 스타일, 단정한 헤어',
  'comedian': '코미디언 - 다양한 나이, 친근하고 유머러스한 인상, 다양한 스타일',
  'mc': 'MC/진행자 - 30-50대, 단정하고 신뢰감 있는 인상, 정장 스타일',
};

// ============ Prompts ============

const ANALYSIS_PROMPT = `당신은 한국 유명인의 실제 외모와 특징을 잘 알고 있는 전문가입니다.
주어진 유명인에게 어울리는 Notion 스타일 아바타 파츠를 추천해주세요.

🎯 유명인 정보:
- 이름: {name}
- 직업: {celebrity_type}
- 직업 특성: {type_hint}
- 성별: {gender}

📋 파츠 가이드:
- face: 1-16 (1-8: 남성적/각진, 9-16: 여성적/둥근)
- hair: 1-59 (1-19: 짧은머리/남성, 20-40: 긴머리/여성, 41-50: 묶은머리, 51-59: 특이한스타일)
- eyes: 1-14 (1-7: 작은눈/날카로운눈, 8-14: 큰눈/둥근눈)
- eyebrows: 1-16 (1-8: 굵은눈썹/남성, 9-16: 가는눈썹/여성)
- nose: 1-14 (다양한 코 모양)
- mouth: 1-20 (1-7: 무표정, 8-14: 미소, 15-20: 활짝웃음)
- glasses: 0-15 (0=없음, 1-5: 뿔테, 6-10: 메탈, 11-15: 선글라스)
- beard: 0-17 (0=없음, 1-5: 수염짧음, 6-10: 콧수염, 11-17: 풍성한수염)
- accessories: 0-15 (0=없음, 이어폰/귀걸이 등)
- details: 0-14 (0=없음, 점/주근깨 등)

⚠️ 규칙:
1. "{name}"의 실제 알려진 외모 특징을 최대한 반영 (안경, 헤어스타일, 수염 등)
2. 성별이 female이면 beard는 반드시 0
3. 직업 특성에 맞는 전체적인 분위기 선택
4. 해당 유명인을 떠올렸을 때의 대표적인 이미지로 선택

JSON만 응답 (다른 텍스트 없이):
{"face":N,"hair":N,"eyes":N,"eyebrows":N,"nose":N,"mouth":N,"glasses":N,"beard":N,"accessories":N,"details":N}`;

// ============ Default Presets ============

const DEFAULT_PRESETS = {
  male: {
    face: 1, hair: 1, eyes: 1, eyebrows: 1,
    nose: 1, mouth: 1, glasses: 0, beard: 0,
    accessories: 0, details: 0
  },
  female: {
    face: 2, hair: 10, eyes: 3, eyebrows: 3,
    nose: 2, mouth: 3, glasses: 0, beard: 0,
    accessories: 0, details: 0
  },
  other: {
    face: 1, hair: 5, eyes: 2, eyebrows: 2,
    nose: 1, mouth: 2, glasses: 0, beard: 0,
    accessories: 0, details: 0
  }
};

// Helper to get preset by gender (with fallback)
function getDefaultPreset(gender) {
  return DEFAULT_PRESETS[gender] || DEFAULT_PRESETS['other'];
}

// ============ Helper Functions ============

function validateEnv() {
  if (!OPENAI_API_KEY) {
    console.error('❌ OPENAI_API_KEY 환경변수가 필요합니다.');
    process.exit(1);
  }
  if (!SUPABASE_SERVICE_KEY) {
    console.error('❌ SUPABASE_SERVICE_KEY 환경변수가 필요합니다.');
    process.exit(1);
  }
}

function parseArgs() {
  const args = process.argv.slice(2);
  return {
    limit: args.includes('--limit') ? parseInt(args[args.indexOf('--limit') + 1]) : null,
    all: args.includes('--all'),
    force: args.includes('--force'),
    retryFailed: args.includes('--retry-failed'),
    dryRun: args.includes('--dry-run'),
    delay: args.includes('--delay') ? parseInt(args[args.indexOf('--delay') + 1]) : 1000,
    names: args.includes('--names') ? args[args.indexOf('--names') + 1].split(',') : null,
    help: args.includes('--help') || args.includes('-h')
  };
}

function printHelp() {
  console.log(`
Celebrity Notion-Style Avatar Generator

사용법:
  OPENAI_API_KEY=sk-xxx SUPABASE_SERVICE_KEY=xxx node scripts/generate_celebrity_avatars.js [options]

옵션:
  --limit N       처음 N명만 처리
  --all           모든 유명인 처리 (character_image_url이 없는)
  --force         기존 아바타 무시하고 모두 재생성
  --retry-failed  실패한 것만 재시도
  --delay N       각 요청 사이 대기시간 (ms, 기본값: 1000)
  --dry-run       실제 생성/업로드 없이 시뮬레이션
  --help, -h      도움말 출력
`);
}

// ============ SVG Composition ============

function readSvgPart(partType, partNum) {
  if (partNum < 0) return null;
  if (partNum === 0) return null; // 0 = 해당 파츠 없음

  // preview 폴더 파일명 형식: 0.svg, 1.svg (0-indexed)
  // partNum은 1-indexed로 받으므로 -1 해서 0-indexed로 변환
  const fileIndex = partNum - 1;
  const filename = `${fileIndex}.svg`;
  const filepath = path.join(PARTS_DIR, partType, filename);

  if (!fs.existsSync(filepath)) {
    console.warn(`  ⚠️ 파츠 없음: ${filepath}`);
    return null;
  }

  return fs.readFileSync(filepath, 'utf8');
}

// Notion Avatar 원본 캔버스 크기 (SVG 좌표계 기준)
// 각 파츠의 transform 값이 1080x1080 기준으로 설정되어 있음
const CANVAS_VIEWBOX = '0 0 1080 1080';
const OUTPUT_SIZE = 200;

// SVG 파일에서 내부 콘텐츠(path, g 등)만 추출
// preview 폴더 SVG는 이미 1080x1080 좌표계로 정규화됨 - transform 처리 불필요
function extractSvgContent(svgString) {
  // <svg ...> 태그 제거하고 내부 콘텐츠만 추출
  const match = svgString.match(/<svg[^>]*>([\s\S]*)<\/svg>/i);
  if (!match) return null;

  return match[1];
}

// 모든 파츠를 하나의 SVG로 합성
function composeSvgParts(selection) {
  const layers = [];

  for (const partType of PART_ORDER) {
    const partNum = selection[partType];
    const svgContent = readSvgPart(partType, partNum);

    if (svgContent) {
      // SVG 내부 콘텐츠 추출 (원본 transform 유지)
      const innerContent = extractSvgContent(svgContent);
      if (innerContent) {
        // Face 파츠는 흰색 채우기 필요 (원본 Notion Avatar 코드 참조)
        // Face SVG는 stroke만 있고 fill이 없어서 투명하게 렌더링됨
        if (partType === 'face') {
          layers.push(`<g fill="#ffffff">${innerContent}</g>`);
        } else if (partType === 'eyes') {
          // 눈 위치 미세 조정 (왼쪽으로 -30, 아래로 +20)
          layers.push(`<g transform="translate(-30, 20)">${innerContent}</g>`);
        } else if (partType === 'nose') {
          // 코 위치 미세 조정 (왼쪽으로 -30)
          layers.push(`<g transform="translate(-30, 0)">${innerContent}</g>`);
        } else {
          layers.push(innerContent);
        }
      }
    }
  }

  // 모든 파츠를 하나의 SVG로 합성
  // Notion Avatar 원본 좌표계 사용 (1080x1080)
  const combinedSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="${CANVAS_VIEWBOX}" width="1080" height="1080">
  <rect width="1080" height="1080" fill="white"/>
  ${layers.join('\n  ')}
</svg>`;

  return combinedSvg;
}

async function composeParts(selection) {
  // 1. 모든 파츠를 하나의 SVG로 합성
  const combinedSvg = composeSvgParts(selection);

  // 2. 합성된 SVG를 PNG로 변환
  try {
    const pngBuffer = await sharp(Buffer.from(combinedSvg))
      .resize(OUTPUT_SIZE, OUTPUT_SIZE)
      .png()
      .toBuffer();
    return pngBuffer;
  } catch (error) {
    console.error('  ❌ SVG→PNG 변환 실패:', error.message);
    return null;
  }
}

async function resizePng(pngBuffer, size = OUTPUT_SIZE) {
  try {
    const resizedBuffer = await sharp(pngBuffer)
      .resize(size, size)
      .png()
      .toBuffer();
    return resizedBuffer;
  } catch (error) {
    console.error('  ❌ 리사이즈 실패:', error.message);
    return null;
  }
}

// ============ GPT Analysis ============

async function getPartRecommendation(openai, celebrity) {
  const typeKey = celebrity.celebrity_type?.replace(/-/g, '_') || 'actor';
  const typeHint = TYPE_HINTS[typeKey] || '다양한 스타일 가능';
  const gender = celebrity.gender || 'male';

  const prompt = ANALYSIS_PROMPT
    .replace('{name}', celebrity.name)
    .replace('{celebrity_type}', typeKey)
    .replace('{type_hint}', typeHint)
    .replace('{gender}', gender);

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7,
      max_tokens: 200,
      response_format: { type: 'json_object' }
    });

    const content = response.choices[0]?.message?.content?.trim();
    const selection = JSON.parse(content);

    // 유효성 검사 및 범위 제한
    const defaultPreset = getDefaultPreset(gender);
    const validated = {};
    for (const [key, max] of Object.entries(PART_COUNTS)) {
      const val = selection[key];
      if (typeof val === 'number') {
        validated[key] = Math.max(0, Math.min(val, max));
      } else {
        validated[key] = defaultPreset[key];
      }
    }

    // 성별 규칙 적용
    if (gender === 'female') {
      validated.beard = 0;
    }

    return validated;
  } catch (error) {
    console.warn(`  ⚠️ GPT 분석 실패, 기본값 사용: ${error.message}`);
    return getDefaultPreset(gender);
  }
}

// ============ Supabase Operations ============

async function ensureBucketExists(supabase) {
  // 버킷 존재 여부 확인
  const { data: buckets, error: listError } = await supabase.storage.listBuckets();

  if (listError) {
    console.warn(`  ⚠️ 버킷 목록 조회 실패: ${listError.message}`);
    return;
  }

  const exists = buckets?.some(b => b.name === 'celebrities');

  if (!exists) {
    console.log('  📦 celebrities 버킷 생성 중...');
    const { error: createError } = await supabase.storage.createBucket('celebrities', {
      public: true,
      fileSizeLimit: 1024 * 1024 * 2 // 2MB
    });

    if (createError && !createError.message.includes('already exists')) {
      console.warn(`  ⚠️ 버킷 생성 실패: ${createError.message}`);
    } else {
      console.log('  ✅ celebrities 버킷 생성 완료');
    }
  }
}

// Celebrity ID를 안전한 파일명으로 변환
function toSafeFilename(id) {
  // URL-safe Base64 인코딩
  const buffer = Buffer.from(id, 'utf8');
  return buffer.toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

async function uploadToStorage(supabase, celebrityId, pngBuffer) {
  const safeId = toSafeFilename(celebrityId);
  const filepath = `avatars/${safeId}.png`;

  const { error } = await supabase.storage
    .from('celebrities')
    .upload(filepath, pngBuffer, {
      contentType: 'image/png',
      upsert: true
    });

  if (error) {
    throw new Error(`Storage 업로드 실패: ${error.message}`);
  }

  const { data } = supabase.storage
    .from('celebrities')
    .getPublicUrl(filepath);

  return data.publicUrl;
}

async function updateCelebrityImage(supabase, celebrityId, imageUrl) {
  const { error } = await supabase
    .from('celebrities')
    .update({ character_image_url: imageUrl })
    .eq('id', celebrityId);

  if (error) {
    throw new Error(`DB 업데이트 실패: ${error.message}`);
  }
}

async function getCelebritiesWithoutAvatar(supabase, limit = null) {
  let query = supabase
    .from('celebrities')
    .select('id, name, celebrity_type, gender')
    .or('character_image_url.is.null,character_image_url.eq.');

  if (limit) {
    query = query.limit(limit);
  }

  const { data, error } = await query;

  if (error) {
    throw new Error(`유명인 조회 실패: ${error.message}`);
  }

  return data || [];
}

async function getAllCelebrities(supabase, limit = null) {
  let query = supabase
    .from('celebrities')
    .select('id, name, celebrity_type, gender, character_image_url');

  if (limit) {
    query = query.limit(limit);
  }

  const { data, error } = await query;

  if (error) {
    throw new Error(`유명인 조회 실패: ${error.message}`);
  }

  return data || [];
}

// ============ Main Process ============

async function generateAvatarForCelebrity(openai, supabase, celebrity, dryRun = false) {
  console.log(`\n🎯 ${celebrity.name} (${celebrity.celebrity_type}, ${celebrity.gender})`);

  // 1. GPT로 파츠 추천 받기
  console.log('  📊 파츠 분석 중...');
  const partSelection = await getPartRecommendation(openai, celebrity);
  console.log(`  → 선택: face=${partSelection.face}, hair=${partSelection.hair}, ` +
              `eyes=${partSelection.eyes}, glasses=${partSelection.glasses}, beard=${partSelection.beard}`);

  if (dryRun) {
    console.log('  ⏭️ [DRY-RUN] 실제 생성 건너뜀');
    return { success: true, dryRun: true };
  }

  // 2. 파츠 합성 (SVG 합성 → PNG 변환)
  console.log('  🎨 파츠 합성 중...');
  const pngBuffer = await composeParts(partSelection);

  if (!pngBuffer) {
    throw new Error('파츠 합성 실패');
  }

  // 3. Supabase Storage 업로드
  console.log('  ☁️ Storage 업로드 중...');
  const imageUrl = await uploadToStorage(supabase, celebrity.id, pngBuffer);

  // 4. DB 업데이트
  console.log('  💾 DB 업데이트 중...');
  await updateCelebrityImage(supabase, celebrity.id, imageUrl);

  console.log(`  ✅ 완료: ${imageUrl}`);
  return { success: true, url: imageUrl };
}

async function main() {
  const args = parseArgs();

  if (args.help) {
    printHelp();
    return;
  }

  validateEnv();

  console.log('🎨 Celebrity Notion-Style Avatar Generator');
  console.log('==========================================\n');

  // 클라이언트 초기화
  const openai = new OpenAI({ apiKey: OPENAI_API_KEY });
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  // Storage 버킷 확인/생성
  console.log('📦 Storage 버킷 확인 중...');
  await ensureBucketExists(supabase);

  // 유명인 목록 조회
  console.log('\n📋 유명인 목록 조회 중...');

  let celebrities;
  if (args.force) {
    // 기존 아바타 무시하고 모두 재생성
    celebrities = await getAllCelebrities(supabase, args.limit);
    console.log(`   (--force 모드: 기존 아바타 무시)`);
  } else if (args.all) {
    celebrities = await getAllCelebrities(supabase, args.limit);
    // character_image_url이 없거나 빈 것만 필터링
    celebrities = celebrities.filter(c => !c.character_image_url || c.character_image_url === '');
  } else if (args.retryFailed) {
    // 실패한 것들 (빈 URL이지만 다시 시도)
    celebrities = await getCelebritiesWithoutAvatar(supabase, args.limit);
  } else {
    celebrities = await getCelebritiesWithoutAvatar(supabase, args.limit || 10);
  }

  // 이름 필터 적용
  if (args.names && args.names.length > 0) {
    celebrities = celebrities.filter(c => args.names.includes(c.name));
    console.log(`   (--names 필터: ${args.names.join(', ')})`);
  }

  console.log(`📊 처리할 유명인: ${celebrities.length}명`);

  if (celebrities.length === 0) {
    console.log('✅ 모든 유명인이 이미 아바타를 가지고 있습니다.');
    return;
  }

  // 처리 시작
  let successful = 0;
  let failed = 0;
  const failedList = [];

  for (let i = 0; i < celebrities.length; i++) {
    const celebrity = celebrities[i];
    console.log(`\n[${i + 1}/${celebrities.length}]`);

    try {
      await generateAvatarForCelebrity(openai, supabase, celebrity, args.dryRun);
      successful++;
    } catch (error) {
      console.error(`  ❌ 실패: ${error.message}`);
      failed++;
      failedList.push({ id: celebrity.id, name: celebrity.name, error: error.message });
    }

    // Rate limiting
    if (i < celebrities.length - 1) {
      await new Promise(r => setTimeout(r, args.delay));
    }
  }

  // 결과 출력
  console.log('\n==========================================');
  console.log('📊 처리 완료!');
  console.log(`   ✅ 성공: ${successful}`);
  console.log(`   ❌ 실패: ${failed}`);

  if (failedList.length > 0) {
    console.log('\n실패 목록:');
    failedList.forEach(f => console.log(`   - ${f.name} (${f.id}): ${f.error}`));
  }

  if (args.dryRun) {
    console.log('\n⚠️ DRY-RUN 모드로 실행됨 - 실제 변경 없음');
  }
}

// 실행
main().catch(error => {
  console.error('❌ 치명적 오류:', error);
  process.exit(1);
});
