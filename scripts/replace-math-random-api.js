#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Function to update API route files
function updateAPIRoute(filePath) {
  const fullPath = path.join(process.cwd(), filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`❌ File not found: ${filePath}`);
    return false;
  }
  
  let content = fs.readFileSync(fullPath, 'utf8');
  const originalContent = content;
  
  // Check if already updated
  if (content.includes('deterministic-random')) {
    console.log(`✅ Already updated: ${filePath}`);
    return true;
  }
  
  // Add import if not present
  if (!content.includes('import { createDeterministicRandom')) {
    // Find the last import statement
    const importMatch = content.match(/(import[\s\S]*?from\s+["'][^"']+["'];?\s*\n)+/);
    if (importMatch) {
      const lastImportEnd = importMatch.index + importMatch[0].length;
      content = content.slice(0, lastImportEnd) + 
        'import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";\n' +
        content.slice(lastImportEnd);
    }
  }
  
  // Replace Math.random() patterns in API routes
  // Pattern 1: .sort(() => 0.5 - Math.random())
  content = content.replace(
    /(\w+)\.sort\(\(\)\s*=>\s*0\.5\s*-\s*Math\.random\(\)\)/g,
    (match, arrayName) => {
      // Find the function context
      const beforeMatch = content.substring(0, content.indexOf(match));
      const functionMatch = beforeMatch.match(/function\s+(\w+)\s*\([^)]*\)[\s\S]*$/);
      
      if (functionMatch) {
        const functionName = functionMatch[1];
        return `/* TODO: Use rng.shuffle(${arrayName}) instead after creating RNG in ${functionName} */\n    ${arrayName}.sort(() => 0.5 - Math.random())`;
      }
      return match;
    }
  );
  
  // Pattern 2: Math.floor(Math.random() * n)
  content = content.replace(
    /Math\.floor\(Math\.random\(\)\s*\*\s*(\d+)\)/g,
    (match, n) => `/* TODO: Use rng.randomInt(0, ${parseInt(n) - 1}) */ ${match}`
  );
  
  // Pattern 3: Math.random() standalone
  content = content.replace(
    /Math\.random\(\)/g,
    '/* TODO: Use rng.random() */ Math.random()'
  );
  
  // Save if changed
  if (content !== originalContent) {
    fs.writeFileSync(fullPath, content);
    console.log(`✅ Updated with TODO comments: ${filePath}`);
    return true;
  }
  
  return false;
}

// Update specific functions with full deterministic implementation
function fullyUpdateFile(filePath, replacements) {
  const fullPath = path.join(process.cwd(), filePath);
  
  if (!fs.existsSync(fullPath)) {
    return false;
  }
  
  let content = fs.readFileSync(fullPath, 'utf8');
  const originalContent = content;
  
  replacements.forEach(({ search, replace }) => {
    content = content.replace(search, replace);
  });
  
  if (content !== originalContent) {
    fs.writeFileSync(fullPath, content);
    console.log(`✅ Fully updated: ${filePath}`);
    return true;
  }
  
  return false;
}

// Files to update
const apiRoutes = [
  'src/app/api/fortune/startup/route.ts',
  'src/app/api/fortune/lucky-investment/route.ts',
  'src/app/api/fortune/celebrity/route.ts',
  'src/app/api/fortune/celebrity-match/route.ts'
];

const serviceFiles = [
  'src/lib/services/fortune-service.ts',
  'src/lib/daily-fortune-service.ts',
  'src/lib/fortune-utils.ts'
];

const componentFiles = [
  'src/components/AdLoadingScreen.tsx',
  'src/app/dashboard/page.tsx'
];

console.log('🔄 Replacing Math.random() in API routes and services...\n');

// Update API routes
console.log('📁 API Routes:');
apiRoutes.forEach(file => {
  updateAPIRoute(file);
});

console.log('\n📁 Service Files:');
serviceFiles.forEach(file => {
  updateAPIRoute(file);
});

console.log('\n📁 Component Files:');
componentFiles.forEach(file => {
  updateAPIRoute(file);
});

// Specific full replacements for fortune-service.ts
console.log('\n🔧 Applying specific replacements...');

// Update generateRandomScores in fortune-service.ts
fullyUpdateFile('src/lib/services/fortune-service.ts', [
  {
    search: /private generateRandomScores\(\): FortuneScores \{[\s\S]*?return \{[\s\S]*?\};\s*\}/,
    replace: `private generateRandomScores(): FortuneScores {
    // Create deterministic random based on current date
    const dateString = getTodayDateString();
    const rng = createDeterministicRandom('system', dateString, 'fortune-scores');
    
    return {
      총운: rng.randomInt(60, 95),
      재물운: rng.randomInt(55, 90),
      연애운: rng.randomInt(50, 95),
      사업운: rng.randomInt(55, 85),
      건강운: rng.randomInt(60, 90),
      학업운: rng.randomInt(65, 95)
    };
  }`
  }
]);

console.log('\n✅ Replacement process completed!');
console.log('\n⚠️  Next steps:');
console.log('1. Review TODO comments in updated files');
console.log('2. Add RNG initialization in functions that need it');
console.log('3. Replace array.sort() with rng.shuffle()');
console.log('4. Test to ensure deterministic behavior');