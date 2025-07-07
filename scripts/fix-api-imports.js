#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// List of files that need the imports
const filesToFix = [
  '/src/app/api/fortune/lucky-tennis/route.ts',
  '/src/app/api/fortune/lucky-sidejob/route.ts',
  '/src/app/api/fortune/lucky-realestate/route.ts',
  '/src/app/api/fortune/lucky-job/route.ts',
  '/src/app/api/fortune/lucky-golf/route.ts',
  '/src/app/api/fortune/lucky-baseball/route.ts',
  '/src/app/api/fortune/generate/route.ts',
  '/src/app/api/fortune/ex-lover/route.ts',
  '/src/app/api/fortune/couple-match/route.ts',
  '/src/app/api/fortune/chemistry/route.ts',
  '/src/app/api/fortune/business/route.ts'
];

const requiredImports = `import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';`;

filesToFix.forEach(filePath => {
  const fullPath = path.join(process.cwd(), filePath);
  
  try {
    let content = fs.readFileSync(fullPath, 'utf8');
    
    // Check if imports already exist
    if (!content.includes("from '@/lib/security-api-utils'")) {
      // Find the last import statement
      const importMatch = content.match(/import.*from.*['"].*['"];?\n/g);
      if (importMatch) {
        const lastImport = importMatch[importMatch.length - 1];
        const lastImportIndex = content.lastIndexOf(lastImport);
        
        // Insert the required imports after the last import
        content = content.slice(0, lastImportIndex + lastImport.length) + 
                  requiredImports + '\n' + 
                  content.slice(lastImportIndex + lastImport.length);
      } else {
        // No imports found, add at the beginning
        content = requiredImports + '\n\n' + content;
      }
      
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ Fixed imports in ${filePath}`);
    } else {
      console.log(`⏭️  Skipping ${filePath} - imports already exist`);
    }
  } catch (error) {
    console.error(`❌ Error processing ${filePath}:`, error.message);
  }
});

// Fix the specific files that need only FortuneService
const fortuneServiceOnlyFiles = [
  '/src/app/api/fortune/marriage/route.ts',
  '/src/app/api/fortune/love/route.ts'
];

fortuneServiceOnlyFiles.forEach(filePath => {
  const fullPath = path.join(process.cwd(), filePath);
  
  try {
    let content = fs.readFileSync(fullPath, 'utf8');
    
    // Check if FortuneService import exists
    if (!content.includes("FortuneService } from '@/lib/services/fortune-service'")) {
      // Add the import if it doesn't exist
      if (content.includes("fortuneService } from '@/lib/services/fortune-service'")) {
        // Replace the lowercase import with both
        content = content.replace(
          "fortuneService } from '@/lib/services/fortune-service'",
          "fortuneService, FortuneService } from '@/lib/services/fortune-service'"
        );
      } else {
        // Find the last import statement and add after it
        const importMatch = content.match(/import.*from.*['"].*['"];?\n/g);
        if (importMatch) {
          const lastImport = importMatch[importMatch.length - 1];
          const lastImportIndex = content.lastIndexOf(lastImport);
          
          content = content.slice(0, lastImportIndex + lastImport.length) + 
                    "import { FortuneService } from '@/lib/services/fortune-service';\n" + 
                    content.slice(lastImportIndex + lastImport.length);
        }
      }
      
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ Fixed FortuneService import in ${filePath}`);
    } else {
      console.log(`⏭️  Skipping ${filePath} - FortuneService import already exists`);
    }
  } catch (error) {
    console.error(`❌ Error processing ${filePath}:`, error.message);
  }
});

console.log('\n✅ Import fixes completed!');