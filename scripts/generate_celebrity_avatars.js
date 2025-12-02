#!/usr/bin/env node
/**
 * Celebrity Avatar Generator
 * DALL-E 3 API를 사용하여 16종의 Notion 스타일 아바타 생성
 *
 * 사용법:
 *   OPENAI_API_KEY=sk-xxx node scripts/generate_celebrity_avatars.js
 *
 * 필요 패키지:
 *   npm install openai
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// OpenAI API 설정
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

if (!OPENAI_API_KEY) {
  console.error('❌ OPENAI_API_KEY 환경변수가 필요합니다.');
  console.error('사용법: OPENAI_API_KEY=sk-xxx node scripts/generate_celebrity_avatars.js');
  process.exit(1);
}

// 출력 디렉토리
const OUTPUT_DIR = path.join(__dirname, '..', 'assets', 'images', 'celebrities', 'avatars');

// 카테고리 및 성별 정의
const CATEGORIES = [
  { id: 'singer', label: 'K-pop idol singer', icon: 'microphone' },
  { id: 'actor', label: 'movie/TV actor', icon: 'film clapperboard' },
  { id: 'politician', label: 'politician in formal suit', icon: 'podium' },
  { id: 'athlete', label: 'professional athlete', icon: 'sports jersey' },
  { id: 'entertainer', label: 'TV show host/entertainer', icon: 'TV studio' },
  { id: 'youtuber', label: 'YouTuber/content creator', icon: 'camera and ring light' },
  { id: 'progamer', label: 'esports professional gamer', icon: 'gaming headset' },
  { id: 'business', label: 'business executive in formal attire', icon: 'briefcase' },
];

const GENDERS = ['male', 'female'];

// Notion 스타일 프롬프트 템플릿
function generatePrompt(category, gender) {
  const genderEn = gender === 'male' ? 'male' : 'female';
  const hairStyle = gender === 'male' ? 'short hair' : 'longer hair';

  return `Create a minimal Notion-style human character representing a ${genderEn} ${category.label}.
Use ultra-simple black line art on a pure white background.
The figure should be made of clean, thin vector-like strokes with no shading, no textures, and no colors.
Design the character with a round head (only tiny dot eyes, no other facial details), simple straight-line limbs, ${hairStyle}, and a compact, friendly posture.
Add a single tiny ${category.icon} icon or prop to indicate the profession.
Keep the proportions slightly cute and simplified, similar to Notion's mascot illustration style.
Overall mood: clean, minimal, modern, flat design.
No background elements, no shadows, no gradients.
Pure black lines on pure white background only.`;
}

// DALL-E 3 API 호출
async function generateImage(prompt, filename) {
  const requestBody = JSON.stringify({
    model: 'dall-e-3',
    prompt: prompt,
    n: 1,
    size: '1024x1024',
    quality: 'standard',
    response_format: 'url'
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.openai.com',
      port: 443,
      path: '/v1/images/generations',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.error) {
            reject(new Error(response.error.message));
          } else {
            resolve(response.data[0].url);
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.write(requestBody);
    req.end();
  });
}

// 이미지 다운로드
function downloadImage(url, filepath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(filepath);
    https.get(url, (response) => {
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(filepath, () => {});
      reject(err);
    });
  });
}

// 메인 실행
async function main() {
  console.log('🎨 Celebrity Avatar Generator');
  console.log('================================\n');

  // 출력 디렉토리 생성
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    console.log(`📁 Created directory: ${OUTPUT_DIR}\n`);
  }

  const total = CATEGORIES.length * GENDERS.length;
  let current = 0;
  let successful = 0;
  let failed = 0;

  console.log(`🖼️  Generating ${total} avatars...\n`);

  for (const category of CATEGORIES) {
    for (const gender of GENDERS) {
      current++;
      const filename = `${category.id}_${gender}.png`;
      const filepath = path.join(OUTPUT_DIR, filename);

      // 이미 존재하면 스킵
      if (fs.existsSync(filepath)) {
        console.log(`⏭️  [${current}/${total}] ${filename} - already exists, skipping`);
        successful++;
        continue;
      }

      console.log(`🔄 [${current}/${total}] Generating ${filename}...`);

      try {
        const prompt = generatePrompt(category, gender);

        // API 호출
        const imageUrl = await generateImage(prompt, filename);

        // 이미지 다운로드
        await downloadImage(imageUrl, filepath);

        console.log(`✅ [${current}/${total}] ${filename} - saved`);
        successful++;

        // Rate limiting (1초 대기)
        await new Promise(r => setTimeout(r, 1000));

      } catch (error) {
        console.error(`❌ [${current}/${total}] ${filename} - failed: ${error.message}`);
        failed++;
      }
    }
  }

  console.log('\n================================');
  console.log('📊 Generation Complete!');
  console.log(`   ✅ Successful: ${successful}`);
  console.log(`   ❌ Failed: ${failed}`);
  console.log(`   📁 Output: ${OUTPUT_DIR}`);

  if (successful === total) {
    console.log('\n🎉 All avatars generated successfully!');
    console.log('\n다음 단계:');
    console.log('1. Supabase Storage에 업로드');
    console.log('2. 마이그레이션 실행하여 character_image_url 업데이트');
  }
}

// 프롬프트만 출력 (dry-run)
function printPrompts() {
  console.log('📝 DALL-E 3 Prompts for Manual Generation\n');
  console.log('=========================================\n');

  for (const category of CATEGORIES) {
    for (const gender of GENDERS) {
      const filename = `${category.id}_${gender}.png`;
      const prompt = generatePrompt(category, gender);

      console.log(`\n--- ${filename} ---`);
      console.log(prompt);
      console.log('');
    }
  }
}

// 명령줄 인수 처리
if (process.argv.includes('--prompts-only')) {
  printPrompts();
} else {
  main().catch(console.error);
}
