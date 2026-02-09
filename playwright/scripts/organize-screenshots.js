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

## Colors (DSColors - ChatGPT Style)

### Core Colors (Monochrome)
| Token | Light | Dark | Figma Variable |
|-------|-------|------|----------------|
| background | #FFFFFF | #000000 | \`core/background\` |
| surface | #F7F7F8 | #1A1A1A | \`core/surface\` |
| textPrimary | #000000 | #FFFFFF | \`core/text/primary\` |
| textSecondary | #6B7280 | #9CA3AF | \`core/text/secondary\` |
| divider | #E5E7EB | #374151 | \`core/divider\` |

### Semantic Colors
| Token | Color | Figma Variable |
|-------|-------|----------------|
| success | #10B981 | \`semantic/success\` |
| warning | #F59E0B | \`semantic/warning\` |
| error | #EF4444 | \`semantic/error\` |
| info | #3B82F6 | \`semantic/info\` |
| accentSecondary | #8B5CF6 | \`semantic/accent\` |

### Saju Colors (오행 - 시각화 전용)
| Token | Color | Figma Variable |
|-------|-------|----------------|
| wood (목) | #10B981 | \`saju/wood\` |
| fire (화) | #F43F5E | \`saju/fire\` |
| earth (토) | #FBBF24 | \`saju/earth\` |
| metal (금) | #94A3B8 | \`saju/metal\` |
| water (수) | #3B82F6 | \`saju/water\` |

## Typography (context extensions)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| heading1 | 30pt | Bold | Page main title |
| heading2 | 26pt | SemiBold | Section title |
| heading3 | 22pt | SemiBold | AppBar, subsection |
| heading4 | 20pt | Medium | Card title |
| body1 | 17pt | Regular | Body text |
| body2 | 15pt | Regular | Secondary text |
| bodySmall | 14pt | Regular | Small body |
| caption | 12pt | Regular | Caption, hints |

## Spacing (DSSpacing)

| Token | Value | Figma Variable |
|-------|-------|----------------|
| xxs | 2px | \`spacing/xxs\` |
| xs | 4px | \`spacing/xs\` |
| sm | 8px | \`spacing/sm\` |
| md | 16px | \`spacing/md\` |
| lg | 24px | \`spacing/lg\` |
| xl | 32px | \`spacing/xl\` |
| xxl | 48px | \`spacing/xxl\` |

## Border Radius (DSRadius)

| Token | Value | Figma Variable |
|-------|-------|----------------|
| xs | 4px | \`radius/xs\` |
| sm | 8px | \`radius/sm\` |
| md | 12px | \`radius/md\` |
| lg | 16px | \`radius/lg\` |
| xl | 24px | \`radius/xl\` |
| card | 16px | \`radius/card\` |
| button | 12px | \`radius/button\` |

## Shadow (DSShadows)

| Token | Usage | Figma Style |
|-------|-------|-------------|
| sm | Small shadow | \`Fortune/Shadow/sm\` |
| md | Medium shadow | \`Fortune/Shadow/md\` |
| lg | Large shadow | \`Fortune/Shadow/lg\` |
| card | Card shadow | \`Fortune/Shadow/card\` |
| elevated | Elevated shadow | \`Fortune/Shadow/elevated\` |

---

## 참조 파일

- \`lib/core/design_system/tokens/ds_colors.dart\` - ChatGPT 스타일 색상
- \`lib/core/design_system/tokens/ds_spacing.dart\` - 간격
- \`lib/core/design_system/tokens/ds_radius.dart\` - 반경
- \`lib/core/design_system/tokens/ds_saju_colors.dart\` - 사주 오행 색상
- \`lib/core/theme/typography_unified.dart\` - 타이포그래피
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
