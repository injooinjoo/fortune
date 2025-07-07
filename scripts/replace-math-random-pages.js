#!/usr/bin/env node

const fs = require('fs').promises;
const path = require('path');

const filesToUpdate = [
  'src/app/fortune/blind-date/page.tsx',
  'src/app/fortune/chemistry/page.tsx',
  'src/app/fortune/compatibility/page.tsx',
  'src/app/fortune/couple-match/page.tsx',
  'src/app/fortune/ex-lover/page.tsx',
  'src/app/fortune/personality/page.tsx',
  'src/app/fortune/saju/page.tsx',
  'src/app/fortune/startup/page.tsx',
  'src/app/fortune/timeline/page.tsx',
  'src/app/fortune/traditional-compatibility/page.tsx',
  'src/app/fortune/wish/page.tsx',
  'src/components/ui/sidebar.tsx',
  'src/hooks/use-fortune-stream.ts',
];

async function replaceInFile(filePath) {
  try {
    const fullPath = path.join(process.cwd(), filePath);
    let content = await fs.readFile(fullPath, 'utf8');
    const originalContent = content;
    
    // Check if file already has DeterministicRandom import
    const hasDeterministicImport = content.includes('DeterministicRandom');
    
    // Add import if not present
    if (!hasDeterministicImport && content.includes('Math.random()')) {
      // Find the last import statement
      const importRegex = /^import.*from.*;$/gm;
      let lastImportIndex = 0;
      let match;
      while ((match = importRegex.exec(content)) !== null) {
        lastImportIndex = match.index + match[0].length;
      }
      
      // Add DeterministicRandom import after the last import
      const importStatement = "\nimport { DeterministicRandom } from '@/lib/deterministic-random';";
      content = content.slice(0, lastImportIndex) + importStatement + content.slice(lastImportIndex);
    }
    
    // Replace Math.random() patterns in pages
    if (filePath.includes('page.tsx')) {
      // Add deterministic random initialization near the component start
      const componentMatch = content.match(/export default function \w+\(\) \{/);
      if (componentMatch) {
        const insertPos = componentMatch.index + componentMatch[0].length;
        
        // Check if we need to add the initialization
        if (!content.includes('const deterministicRandom = new DeterministicRandom')) {
          const initialization = `
  // Initialize deterministic random for consistent results
  const userId = 'demo-user'; // TODO: Get actual user ID from context
  const today = new Date().toISOString().split('T')[0];
  const fortuneType = '${path.basename(filePath, '.tsx')}';
  const deterministicRandom = new DeterministicRandom(userId, today, fortuneType);
`;
          content = content.slice(0, insertPos) + initialization + content.slice(insertPos);
        }
      }
      
      // Replace Math.random() patterns
      content = content.replace(/Math\.random\(\)/g, 'deterministicRandom.random()');
      content = content.replace(/Math\.floor\(Math\.random\(\) \* (\d+)\)/g, 'deterministicRandom.randomInt(0, $1 - 1)');
      content = content.replace(/Math\.floor\(deterministicRandom\.random\(\) \* (\d+)\) \+ (\d+)/g, 'deterministicRandom.randomInt($2, $2 + $1 - 1)');
      
      // Handle array index patterns
      content = content.replace(/\[Math\.floor\(deterministicRandom\.random\(\) \* (\d+)\)\]/g, '[deterministicRandom.randomInt(0, $1 - 1)]');
    }
    
    // For non-page files, add TODO comments
    if (!filePath.includes('page.tsx') && content.includes('Math.random()')) {
      content = content.replace(/Math\.random\(\)/g, 'Math.random() // TODO: Replace with DeterministicRandom');
    }
    
    if (content !== originalContent) {
      await fs.writeFile(fullPath, content, 'utf8');
      console.log(`✅ Updated: ${filePath}`);
      return true;
    } else {
      console.log(`⏭️  Skipped: ${filePath} (no changes needed)`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error processing ${filePath}:`, error.message);
    return false;
  }
}

async function main() {
  console.log('🔄 Replacing Math.random() with DeterministicRandom...\n');
  
  let updatedCount = 0;
  
  for (const file of filesToUpdate) {
    const updated = await replaceInFile(file);
    if (updated) updatedCount++;
  }
  
  console.log(`\n✅ Complete! Updated ${updatedCount} files.`);
  console.log('\n📝 Next steps:');
  console.log('1. Review the changes to ensure they look correct');
  console.log('2. Update userId to get actual user from context/props');
  console.log('3. Test the fortune pages to ensure they work correctly');
  console.log('4. Run tests to verify no regressions');
}

main().catch(console.error);