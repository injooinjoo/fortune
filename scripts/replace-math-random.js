#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// List of files to update
const luckyFiles = [
  'src/app/fortune/lucky-food/page.tsx',
  'src/app/fortune/lucky-outfit/page.tsx',
  'src/app/fortune/lucky-items/page.tsx',
  'src/app/fortune/lucky-investment/page.tsx',
  'src/app/fortune/lucky-job/page.tsx',
  'src/app/fortune/lucky-sidejob/page.tsx',
  'src/app/fortune/lucky-realestate/page.tsx',
  'src/app/fortune/lucky-exam/page.tsx',
  'src/app/fortune/lucky-fishing/page.tsx',
  'src/app/fortune/lucky-cycling/page.tsx',
  'src/app/fortune/lucky-running/page.tsx',
  'src/app/fortune/lucky-swim/page.tsx'
];

const apiRoutes = [
  'src/app/api/fortune/wealth/route.ts',
  'src/app/api/fortune/startup/route.ts',
  'src/app/api/fortune/lucky-investment/route.ts',
  'src/app/api/fortune/celebrity/route.ts',
  'src/app/api/fortune/celebrity-match/route.ts'
];

const otherFiles = [
  'src/lib/services/fortune-service.ts',
  'src/lib/daily-fortune-service.ts',
  'src/lib/fortune-utils.ts',
  'src/components/AdLoadingScreen.tsx',
  'src/app/fortune/compatibility/page.tsx',
  'src/app/fortune/celebrity-match/page.tsx',
  'src/app/fortune/couple-match/page.tsx',
  'src/app/fortune/personality/page.tsx',
  'src/app/fortune/traditional-compatibility/page.tsx',
  'src/app/fortune/startup/page.tsx',
  'src/app/fortune/ex-lover/page.tsx',
  'src/app/fortune/chemistry/page.tsx',
  'src/app/fortune/celebrity/page.tsx',
  'src/app/fortune/blind-date/page.tsx',
  'src/app/fortune/wish/page.tsx',
  'src/app/fortune/timeline/page.tsx'
];

console.log('🔄 Math.random() Replacement Report\n');

// Check which files exist and have Math.random
function checkFile(filePath) {
  const fullPath = path.join(process.cwd(), filePath);
  
  if (!fs.existsSync(fullPath)) {
    return { exists: false, hasRandom: false, count: 0 };
  }
  
  const content = fs.readFileSync(fullPath, 'utf8');
  const matches = content.match(/Math\.random/g);
  const hasImport = content.includes('deterministic-random');
  
  return {
    exists: true,
    hasRandom: matches ? true : false,
    count: matches ? matches.length : 0,
    alreadyImported: hasImport
  };
}

// Report on all files
console.log('📁 Lucky Fortune Pages:');
luckyFiles.forEach(file => {
  const result = checkFile(file);
  const status = result.alreadyImported ? '✅' : (result.hasRandom ? '❌' : '⚪');
  console.log(`${status} ${file} - ${result.count} occurrences${result.alreadyImported ? ' (already updated)' : ''}`);
});

console.log('\n📁 API Routes:');
apiRoutes.forEach(file => {
  const result = checkFile(file);
  const status = result.alreadyImported ? '✅' : (result.hasRandom ? '❌' : '⚪');
  console.log(`${status} ${file} - ${result.count} occurrences`);
});

console.log('\n📁 Other Files:');
otherFiles.forEach(file => {
  const result = checkFile(file);
  const status = result.alreadyImported ? '✅' : (result.hasRandom ? '❌' : '⚪');
  console.log(`${status} ${file} - ${result.count} occurrences`);
});

// Count totals
const allFiles = [...luckyFiles, ...apiRoutes, ...otherFiles];
let totalFiles = 0;
let filesWithRandom = 0;
let totalOccurrences = 0;
let filesUpdated = 0;

allFiles.forEach(file => {
  const result = checkFile(file);
  if (result.exists) {
    totalFiles++;
    if (result.hasRandom && !result.alreadyImported) {
      filesWithRandom++;
      totalOccurrences += result.count;
    }
    if (result.alreadyImported) {
      filesUpdated++;
    }
  }
});

console.log('\n📊 Summary:');
console.log(`Total files checked: ${totalFiles}`);
console.log(`Files already updated: ${filesUpdated}`);
console.log(`Files still using Math.random(): ${filesWithRandom}`);
console.log(`Total Math.random() occurrences remaining: ${totalOccurrences}`);

console.log('\n💡 Next Steps:');
console.log('1. Update remaining files to import deterministic-random');
console.log('2. Replace Math.random() with appropriate deterministic methods');
console.log('3. Test to ensure consistent behavior');
console.log('4. Update API routes to accept userId parameter for seeding');