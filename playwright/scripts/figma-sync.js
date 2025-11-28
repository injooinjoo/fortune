/**
 * Fortune App - Figma Sync Script
 *
 * Figma API를 활용한 디자인 동기화 자동화
 *
 * 기능:
 * 1. 스크린샷 + 메타데이터를 Figma 구조로 준비
 * 2. Figma API로 프레임 생성/업데이트
 * 3. 메타데이터를 Figma 노트로 첨부
 *
 * 사전 요구사항:
 * - Figma Personal Access Token (환경변수: FIGMA_TOKEN)
 * - Figma 파일 ID (환경변수: FIGMA_FILE_ID)
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// =============================================================================
// Configuration
// =============================================================================

const CONFIG = {
  // Figma API
  figmaApiBase: 'https://api.figma.com/v1',
  figmaToken: process.env.FIGMA_TOKEN,
  figmaFileId: process.env.FIGMA_FILE_ID,

  // Local paths
  screenshotsDir: path.join(__dirname, '../../screenshots/figma_ready'),
  metadataDir: path.join(__dirname, '../../screenshots/metadata'),

  // Output
  outputDir: path.join(__dirname, '../../screenshots/figma_export'),
};

// =============================================================================
// Figma API Helpers
// =============================================================================

/**
 * Figma API 요청
 */
async function figmaRequest(endpoint, method = 'GET', body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(`${CONFIG.figmaApiBase}${endpoint}`);

    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method,
      headers: {
        'X-Figma-Token': CONFIG.figmaToken,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve(data);
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

/**
 * Figma 파일 정보 가져오기
 */
async function getFigmaFile() {
  return figmaRequest(`/files/${CONFIG.figmaFileId}`);
}

/**
 * Figma 파일의 페이지 목록 가져오기
 */
async function getFigmaPages() {
  const file = await getFigmaFile();
  return file.document?.children || [];
}

// =============================================================================
// Metadata Processing
// =============================================================================

/**
 * 스크린 메타데이터를 Figma 노트 형식으로 변환
 */
function formatMetadataForFigma(screen) {
  return `
📱 ${screen.nameKo} (${screen.name})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Route: ${screen.path}
📁 Dart: ${screen.dartFile}

📝 설명
${screen.descriptionKo}

🔄 UX Flow
• 이전: ${screen.uxFlow?.prev?.join(', ') || '없음'}
• 다음: ${screen.uxFlow?.next?.join(', ') || '없음'}
• 트리거: ${screen.uxFlow?.trigger || '없음'}

🧩 Components
${screen.components?.map(c => `• ${c}`).join('\n') || '없음'}

📐 States
${screen.states?.map(s => `• ${s}`).join('\n') || '없음'}

💡 Design Notes
${screen.designNotes?.map(n => `• ${n}`).join('\n') || '없음'}
`.trim();
}

/**
 * Figma 업로드용 구조 생성
 */
function prepareFigmaStructure() {
  const { SCREEN_METADATA, getScreensByFigmaPage } = require('./screen-metadata');

  const figmaPages = getScreensByFigmaPage();
  const structure = [];

  for (const [pageName, pageData] of Object.entries(figmaPages)) {
    const page = {
      name: pageName,
      nameKo: pageData.categoryKo,
      frames: [],
    };

    for (const screen of pageData.screens) {
      // Light mode frame
      page.frames.push({
        name: `${screen.nameKo} - Light`,
        screenKey: screen.screenKey,
        theme: 'light',
        screenshotPath: path.join(
          CONFIG.screenshotsDir,
          pageName,
          'light',
          `*_${screen.screenKey}_light.png`
        ),
        metadata: formatMetadataForFigma(screen),
        width: 393,
        height: 852,
      });

      // Dark mode frame
      page.frames.push({
        name: `${screen.nameKo} - Dark`,
        screenKey: screen.screenKey,
        theme: 'dark',
        screenshotPath: path.join(
          CONFIG.screenshotsDir,
          pageName,
          'dark',
          `*_${screen.screenKey}_dark.png`
        ),
        metadata: formatMetadataForFigma(screen),
        width: 393,
        height: 852,
      });
    }

    structure.push(page);
  }

  return structure;
}

// =============================================================================
// Export Functions
// =============================================================================

/**
 * Figma 업로드용 JSON 생성
 * (Figma REST API로 직접 프레임 생성은 제한적이므로,
 *  Figma Plugin이나 수동 작업을 위한 구조화된 데이터 생성)
 */
function generateFigmaImportData() {
  console.log('Generating Figma import data...\n');

  const structure = prepareFigmaStructure();

  // 출력 디렉토리 생성
  if (!fs.existsSync(CONFIG.outputDir)) {
    fs.mkdirSync(CONFIG.outputDir, { recursive: true });
  }

  // 구조 JSON 저장
  const structurePath = path.join(CONFIG.outputDir, 'figma-import-structure.json');
  fs.writeFileSync(structurePath, JSON.stringify(structure, null, 2));
  console.log(`  Saved: ${structurePath}`);

  // 페이지별 메타데이터 TXT 생성 (Figma에 복사/붙여넣기용)
  for (const page of structure) {
    const pagePath = path.join(CONFIG.outputDir, `${page.name}-metadata.txt`);
    let content = `# ${page.name} (${page.nameKo})\n\n`;

    for (const frame of page.frames) {
      content += `${'='.repeat(60)}\n`;
      content += `${frame.name}\n`;
      content += `${'='.repeat(60)}\n\n`;
      content += frame.metadata;
      content += '\n\n';
    }

    fs.writeFileSync(pagePath, content);
  }

  console.log(`  Generated ${structure.length} page metadata files`);

  return structure;
}

/**
 * Claude Code + Figma MCP 사용을 위한 프롬프트 생성
 */
function generateFigmaMCPPrompts() {
  console.log('\nGenerating Figma MCP prompts...\n');

  const { getScreensByFigmaPage } = require('./screen-metadata');
  const figmaPages = getScreensByFigmaPage();

  const prompts = [];

  for (const [pageName, pageData] of Object.entries(figmaPages)) {
    const prompt = `
## Figma MCP: ${pageName} 페이지 생성

다음 화면들을 Figma에 생성해주세요:

${pageData.screens.map((s, i) => `
### ${i + 1}. ${s.nameKo} (${s.name})
- Route: ${s.path}
- 설명: ${s.descriptionKo}
- 상태: ${s.states?.join(', ')}
- 컴포넌트: ${s.components?.join(', ')}
`).join('\n')}

각 화면은 Light/Dark 모드 두 가지 버전으로 생성해주세요.
Auto Layout을 적용하고, 컴포넌트는 재사용 가능하게 만들어주세요.
`.trim();

    prompts.push({
      page: pageName,
      prompt,
    });
  }

  // 프롬프트 저장
  const promptsPath = path.join(CONFIG.outputDir, 'figma-mcp-prompts.json');
  fs.writeFileSync(promptsPath, JSON.stringify(prompts, null, 2));

  // 마크다운 버전 생성
  let mdContent = '# Figma MCP Prompts\n\n';
  mdContent += 'Claude Code + Figma MCP를 사용하여 디자인을 생성할 때 사용하는 프롬프트입니다.\n\n';

  for (const { page, prompt } of prompts) {
    mdContent += `---\n\n${prompt}\n\n`;
  }

  fs.writeFileSync(path.join(CONFIG.outputDir, 'figma-mcp-prompts.md'), mdContent);

  console.log(`  Saved: ${prompts.length} prompts`);

  return prompts;
}

// =============================================================================
// Main Execution
// =============================================================================

async function main() {
  console.log('='.repeat(60));
  console.log('Fortune App - Figma Sync');
  console.log('='.repeat(60));

  // 환경 변수 체크
  if (!CONFIG.figmaToken) {
    console.log('\n⚠️  FIGMA_TOKEN 환경변수가 설정되지 않았습니다.');
    console.log('   Figma API 연동 없이 로컬 데이터만 생성합니다.\n');
  }

  // 1. Figma 임포트 데이터 생성
  generateFigmaImportData();

  // 2. Figma MCP 프롬프트 생성
  generateFigmaMCPPrompts();

  // 3. Figma API 연동 (토큰이 있는 경우)
  if (CONFIG.figmaToken && CONFIG.figmaFileId) {
    console.log('\nFetching Figma file info...');
    try {
      const pages = await getFigmaPages();
      console.log(`  Found ${pages.length} pages in Figma file`);

      // 페이지 목록 출력
      pages.forEach((page, i) => {
        console.log(`  ${i + 1}. ${page.name}`);
      });
    } catch (error) {
      console.error('  Error fetching Figma file:', error.message);
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log('SYNC PREPARATION COMPLETE');
  console.log('='.repeat(60));
  console.log(`\nOutput: ${CONFIG.outputDir}`);
  console.log('\nNext steps:');
  console.log('  1. Figma에서 프로젝트 생성');
  console.log('  2. Codia AI로 스크린샷 변환');
  console.log('  3. 메타데이터 TXT를 Figma 노트로 추가');
  console.log('  4. 또는 Claude Code + Figma MCP 사용');
}

main().catch(console.error);

// =============================================================================
// Figma MCP 설정 가이드 출력
// =============================================================================

console.log(`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Figma MCP 설정 가이드
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Figma MCP 서버 추가 (Claude Code에서 실행):
   claude mcp add --transport http figma https://mcp.figma.com/mcp

2. 또는 로컬 MCP 서버 설정 (~/.claude.json):
   {
     "mcpServers": {
       "figma": {
         "command": "npx",
         "args": ["-y", "figma-developer-mcp", "--stdio"],
         "env": {
           "FIGMA_API_KEY": "your-figma-token"
         }
       }
     }
   }

3. Figma Personal Access Token 발급:
   https://www.figma.com/developers/api#access-tokens

4. 사용 예시 (Claude Code에서):
   "Figma 파일 https://figma.com/file/xxx 에서
    Home 화면을 Flutter 코드로 변환해줘"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`);
