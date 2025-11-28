/**
 * Fortune App - Screenshot Organizer
 *
 * 목적: 캡처된 스크린샷을 Figma 업로드용으로 조직화
 * 사용법: node playwright/scripts/organize-screenshots.js
 *
 * 기능:
 *   - 카테고리별 폴더 정리
 *   - 네이밍 컨벤션 적용
 *   - 메타데이터 JSON 생성
 *   - Figma 업로드 체크리스트 생성
 */

const fs = require('fs');
const path = require('path');

// =============================================================================
// Configuration
// =============================================================================

const CONFIG = {
  rawDir: path.join(__dirname, '../../screenshots/raw'),
  organizedDir: path.join(__dirname, '../../screenshots/organized'),
  figmaReadyDir: path.join(__dirname, '../../screenshots/figma_ready'),
  metadataDir: path.join(__dirname, '../../screenshots/metadata'),
};

// Figma 페이지 구조 매핑
const FIGMA_STRUCTURE = {
  '01-Auth-Onboarding': ['auth'],
  '02-Home-Navigation': ['home'],
  '03-Profile-Settings': ['profile'],
  '04-Fortune-Basic': ['fortune_basic'],
  '05-Fortune-Traditional': ['fortune_traditional'],
  '06-Fortune-Love': ['fortune_love'],
  '07-Fortune-Career': ['fortune_career'],
  '08-Fortune-Time': ['fortune_time'],
  '09-Fortune-Health': ['fortune_health'],
  '10-Fortune-Special': ['fortune_special'],
  '11-Interactive': ['interactive'],
  '12-Trend': ['trend'],
};

// =============================================================================
// Helper Functions
// =============================================================================

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function copyFile(src, dest) {
  fs.copyFileSync(src, dest);
}

function getFilesRecursively(dir, files = []) {
  const items = fs.readdirSync(dir);

  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      getFilesRecursively(fullPath, files);
    } else if (item.endsWith('.png')) {
      files.push(fullPath);
    }
  }

  return files;
}

// =============================================================================
// Main Functions
// =============================================================================

/**
 * 스크린샷을 Figma 구조로 조직화
 */
function organizeForFigma() {
  console.log('Organizing screenshots for Figma...\n');

  const stats = {
    total: 0,
    categories: {}
  };

  // Figma 구조별 폴더 생성 및 파일 복사
  for (const [figmaPage, categories] of Object.entries(FIGMA_STRUCTURE)) {
    const figmaDir = path.join(CONFIG.figmaReadyDir, figmaPage);
    ensureDir(path.join(figmaDir, 'light'));
    ensureDir(path.join(figmaDir, 'dark'));

    for (const category of categories) {
      const srcDir = path.join(CONFIG.rawDir, category);

      if (!fs.existsSync(srcDir)) {
        console.log(`  Skipping ${category} (not found)`);
        continue;
      }

      const files = fs.readdirSync(srcDir).filter(f => f.endsWith('.png'));

      for (const file of files) {
        const theme = file.includes('_dark') ? 'dark' : 'light';
        const destDir = path.join(figmaDir, theme);
        const destPath = path.join(destDir, file);

        copyFile(path.join(srcDir, file), destPath);
        stats.total++;

        if (!stats.categories[figmaPage]) {
          stats.categories[figmaPage] = { light: 0, dark: 0 };
        }
        stats.categories[figmaPage][theme]++;
      }
    }

    console.log(`  ${figmaPage}: ${stats.categories[figmaPage]?.light || 0} light, ${stats.categories[figmaPage]?.dark || 0} dark`);
  }

  return stats;
}

/**
 * 메타데이터 JSON 생성
 */
function generateMetadata() {
  console.log('\nGenerating metadata...');

  ensureDir(CONFIG.metadataDir);

  const allFiles = getFilesRecursively(CONFIG.figmaReadyDir);

  const metadata = {
    generated: new Date().toISOString(),
    totalScreenshots: allFiles.length,
    structure: {},
    screens: []
  };

  for (const filePath of allFiles) {
    const relativePath = path.relative(CONFIG.figmaReadyDir, filePath);
    const parts = relativePath.split(path.sep);

    const figmaPage = parts[0];
    const theme = parts[1];
    const fileName = parts[2];

    // 파일명 파싱: category_name_theme.png
    const nameParts = fileName.replace('.png', '').split('_');
    const screenTheme = nameParts.pop(); // light or dark
    const screenName = nameParts.slice(1).join('_'); // name without category
    const category = nameParts[0];

    metadata.screens.push({
      figmaPage,
      theme,
      category,
      screenName,
      fileName,
      path: relativePath
    });

    if (!metadata.structure[figmaPage]) {
      metadata.structure[figmaPage] = { light: [], dark: [] };
    }
    metadata.structure[figmaPage][theme].push(screenName);
  }

  // 메타데이터 저장
  const metadataPath = path.join(CONFIG.metadataDir, 'screens-metadata.json');
  fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));

  console.log(`  Saved: ${metadataPath}`);
  console.log(`  Total screens: ${metadata.totalScreenshots}`);

  return metadata;
}

/**
 * Figma 업로드 체크리스트 생성
 */
function generateChecklist(metadata) {
  console.log('\nGenerating Figma upload checklist...');

  let checklist = `# Fortune App → Figma 업로드 체크리스트

Generated: ${new Date().toISOString()}
Total Screenshots: ${metadata.totalScreenshots}

## Figma 파일 구조

`;

  for (const [figmaPage, themes] of Object.entries(metadata.structure)) {
    const lightCount = themes.light?.length || 0;
    const darkCount = themes.dark?.length || 0;

    checklist += `### ${figmaPage}
- [ ] Light Mode (${lightCount} screens)
- [ ] Dark Mode (${darkCount} screens)

`;
  }

  checklist += `
## 업로드 순서

1. **Foundation 먼저 설정**
   - [ ] Color Variables (Light/Dark modes)
   - [ ] Typography Styles
   - [ ] Spacing Variables

2. **Codia AI로 변환**
   - [ ] 각 카테고리별 배치 업로드
   - [ ] Auto Layout 확인
   - [ ] 레이어 정리

3. **컴포넌트 추출**
   - [ ] Buttons
   - [ ] Cards
   - [ ] AppBars
   - [ ] Input fields

4. **화면 조립**
   - [ ] 공통 컴포넌트 연결
   - [ ] Variables 바인딩
   - [ ] 프로토타입 연결

## 폴더 구조

\`\`\`
${CONFIG.figmaReadyDir}/
${Object.keys(metadata.structure).map(p => `├── ${p}/\n│   ├── light/\n│   └── dark/`).join('\n')}
\`\`\`
`;

  const checklistPath = path.join(CONFIG.metadataDir, 'figma-upload-checklist.md');
  fs.writeFileSync(checklistPath, checklist);

  console.log(`  Saved: ${checklistPath}`);
}

/**
 * 디자인 토큰 참조 파일 생성
 */
function generateTokenReference() {
  console.log('\nGenerating design token reference...');

  const tokenRef = `# Fortune Design Tokens → Figma Variables

## Colors (TossDesignSystem)

### Semantic Colors
| Token | Light | Dark | Figma Variable |
|-------|-------|------|----------------|
| background/primary | #FFFFFF | #17171C | \`semantic/background/primary\` |
| background/secondary | #F9FAFB | #1D1D24 | \`semantic/background/secondary\` |
| text/primary | #191F28 | #FFFFFF | \`semantic/text/primary\` |
| text/secondary | #4E5968 | #8B95A1 | \`semantic/text/secondary\` |
| border/default | #E5E8EB | #3A3D46 | \`semantic/border/default\` |
| brand/primary | #1F4EF5 | #1E5EDB | \`semantic/brand/primary\` |

### Saju Colors (오행)
| Token | Color | Figma Variable |
|-------|-------|----------------|
| wuxing/wood | #10B981 | \`saju/wuxing/wood\` |
| wuxing/fire | #F43F5E | \`saju/wuxing/fire\` |
| wuxing/earth | #FBBF24 | \`saju/wuxing/earth\` |
| wuxing/metal | #94A3B8 | \`saju/wuxing/metal\` |
| wuxing/water | #3B82F6 | \`saju/wuxing/water\` |

## Typography (TypographyUnified)

| Style | Size | Weight | Line Height | Figma Style |
|-------|------|--------|-------------|-------------|
| Display/Large | 48px | 700 | 1.17 | \`Fortune/Display/Large\` |
| Heading/1 | 28px | 700 | 1.29 | \`Fortune/Heading/1\` |
| Heading/2 | 24px | 700 | 1.33 | \`Fortune/Heading/2\` |
| Heading/3 | 20px | 600 | 1.4 | \`Fortune/Heading/3\` |
| Body/Large | 17px | 400 | 1.65 | \`Fortune/Body/Large\` |
| Body/Medium | 15px | 400 | 1.6 | \`Fortune/Body/Medium\` |
| Body/Small | 13px | 400 | 1.54 | \`Fortune/Body/Small\` |
| Label/Large | 14px | 500 | 1.43 | \`Fortune/Label/Large\` |
| Label/Medium | 12px | 500 | 1.5 | \`Fortune/Label/Medium\` |
| Button/Large | 18px | 600 | 1.33 | \`Fortune/Button/Large\` |
| Button/Medium | 16px | 600 | 1.5 | \`Fortune/Button/Medium\` |

## Spacing

| Token | Value | Figma Variable |
|-------|-------|----------------|
| spacing/xxs | 2px | \`spacing/xxs\` |
| spacing/xs | 4px | \`spacing/xs\` |
| spacing/s | 8px | \`spacing/s\` |
| spacing/m | 16px | \`spacing/m\` |
| spacing/l | 24px | \`spacing/l\` |
| spacing/xl | 32px | \`spacing/xl\` |
| spacing/xxl | 48px | \`spacing/xxl\` |

## Border Radius

| Token | Value | Figma Variable |
|-------|-------|----------------|
| radius/xs | 4px | \`radius/xs\` |
| radius/s | 8px | \`radius/s\` |
| radius/m | 12px | \`radius/m\` |
| radius/l | 16px | \`radius/l\` |
| radius/xl | 24px | \`radius/xl\` |
| radius/full | 9999px | \`radius/full\` |

## Shadow

| Token | Value | Figma Style |
|-------|-------|-------------|
| shadow/xs | 0 1px 2px rgba(0,0,0,0.05) | \`Fortune/Shadow/XS\` |
| shadow/s | 0 2px 8px rgba(0,0,0,0.04) | \`Fortune/Shadow/S\` |
| shadow/m | 0 4px 16px rgba(0,0,0,0.08) | \`Fortune/Shadow/M\` |
| shadow/l | 0 8px 24px rgba(0,0,0,0.12) | \`Fortune/Shadow/L\` |

---

## 참조 파일

- \`lib/core/theme/toss_design_system.dart\` - 색상, 간격, 반경
- \`lib/core/theme/typography_unified.dart\` - 타이포그래피
- \`lib/core/theme/saju_colors.dart\` - 사주 전용 색상
`;

  const tokenPath = path.join(CONFIG.metadataDir, 'figma-token-reference.md');
  fs.writeFileSync(tokenPath, tokenRef);

  console.log(`  Saved: ${tokenPath}`);
}

// =============================================================================
// Main Execution
// =============================================================================

async function main() {
  console.log('='.repeat(60));
  console.log('Fortune App - Screenshot Organizer');
  console.log('='.repeat(60));

  // 1. 스크린샷 조직화
  const stats = organizeForFigma();

  // 2. 메타데이터 생성
  const metadata = generateMetadata();

  // 3. 체크리스트 생성
  generateChecklist(metadata);

  // 4. 토큰 참조 생성
  generateTokenReference();

  console.log('\n' + '='.repeat(60));
  console.log('ORGANIZATION COMPLETE');
  console.log('='.repeat(60));
  console.log(`\nTotal organized: ${stats.total} screenshots`);
  console.log(`\nOutput locations:`);
  console.log(`  - Figma Ready: ${CONFIG.figmaReadyDir}`);
  console.log(`  - Metadata: ${CONFIG.metadataDir}`);
  console.log(`\nNext steps:`);
  console.log(`  1. Open Figma and create Fortune Design System project`);
  console.log(`  2. Subscribe to Codia AI Pro`);
  console.log(`  3. Upload screenshots by category`);
  console.log(`  4. Follow figma-upload-checklist.md`);
}

main().catch(console.error);
