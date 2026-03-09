#!/usr/bin/env node
/**
 * Fix Celebrity Avatar URLs
 * REST API로 character_image_url 일괄 업데이트
 */

const https = require('https');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error(
    'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables are required.',
  );
}

const STORAGE_BASE = `${SUPABASE_URL}/storage/v1/object/public/celebrities/avatars/`;

// 매핑 규칙
const TYPE_MAP = {
  'idol_member': 'singer',
  'solo_singer': 'singer',
  'pro_gamer': 'progamer',
  'streamer': 'youtuber',
};

function getAvatarFilename(celebrityType, gender) {
  const mappedType = TYPE_MAP[celebrityType] || celebrityType;
  const mappedGender = gender === 'other' ? 'male' : gender;
  return `${mappedType}_${mappedGender}.png`;
}

async function fetchJson(url, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const reqOptions = {
      hostname: urlObj.hostname,
      path: urlObj.pathname + urlObj.search,
      method: options.method || 'GET',
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': options.prefer || '',
        ...options.headers,
      },
    };

    const req = https.request(reqOptions, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(data ? JSON.parse(data) : {});
        } catch (e) {
          resolve(data);
        }
      });
    });

    req.on('error', reject);
    if (options.body) req.write(JSON.stringify(options.body));
    req.end();
  });
}

async function main() {
  console.log('🔄 Celebrity Avatar URL 업데이트 시작...\n');

  // 1. 모든 celebrity 조회
  const celebrities = await fetchJson(
    `${SUPABASE_URL}/rest/v1/celebrities?select=id,name,celebrity_type,gender,character_image_url&limit=2000`
  );

  if (!Array.isArray(celebrities)) {
    console.error('❌ 데이터 조회 실패:', celebrities);
    return;
  }

  console.log(`📊 총 ${celebrities.length}명의 연예인 발견\n`);

  // 2. 타입별 통계
  const stats = {};
  let needUpdate = 0;

  for (const celeb of celebrities) {
    const key = `${celeb.celebrity_type}_${celeb.gender}`;
    stats[key] = (stats[key] || 0) + 1;

    const correctUrl = STORAGE_BASE + getAvatarFilename(celeb.celebrity_type, celeb.gender);
    if (celeb.character_image_url !== correctUrl) {
      needUpdate++;
    }
  }

  console.log('📈 타입별 분포:');
  for (const [key, count] of Object.entries(stats).sort()) {
    const [type, gender] = key.split('_');
    const avatarFile = getAvatarFilename(type, gender);
    console.log(`   ${key}: ${count}명 → ${avatarFile}`);
  }

  console.log(`\n🔧 업데이트 필요: ${needUpdate}/${celebrities.length}명`);

  if (needUpdate === 0) {
    console.log('\n✅ 모든 URL이 이미 올바릅니다!');
    return;
  }

  // 3. 일괄 업데이트 (타입+성별 조합별로)
  const combinations = [...new Set(celebrities.map(c => `${c.celebrity_type}|${c.gender}`))];

  let updated = 0;
  for (const combo of combinations) {
    const [type, gender] = combo.split('|');
    const correctUrl = STORAGE_BASE + getAvatarFilename(type, gender);

    // PATCH로 일괄 업데이트
    const result = await fetchJson(
      `${SUPABASE_URL}/rest/v1/celebrities?celebrity_type=eq.${type}&gender=eq.${gender}`,
      {
        method: 'PATCH',
        prefer: 'return=representation',
        body: { character_image_url: correctUrl },
      }
    );

    const count = Array.isArray(result) ? result.length : 0;
    updated += count;
    console.log(`✅ ${type}_${gender}: ${count}명 → ${getAvatarFilename(type, gender)}`);
  }

  console.log(`\n🎉 완료! 총 ${updated}명 업데이트됨`);

  // 4. 검증
  const sample = await fetchJson(
    `${SUPABASE_URL}/rest/v1/celebrities?select=name,celebrity_type,gender,character_image_url&limit=5`
  );

  console.log('\n📝 샘플 확인:');
  for (const c of sample) {
    console.log(`   ${c.name} (${c.celebrity_type}/${c.gender}): ${c.character_image_url}`);
  }
}

main().catch(console.error);
