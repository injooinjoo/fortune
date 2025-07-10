#!/usr/bin/env node

/**
 * Migration script to replace Sentry with custom error monitoring
 */

const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

// Files to remove
const filesToRemove = [
  'sentry.client.config.ts',
  'sentry.server.config.ts',
  'sentry.edge.config.ts',
  '.sentryclirc',
];

// Files that need Sentry imports replaced
const filesToMigrate = [
  'next.config.js',
  'next.config.mjs',
  'next.config.ts',
  'next.config.sentry.ts',
];

async function removesentryFiles() {
  console.log(`${colors.cyan}🗑️  Removing Sentry configuration files...${colors.reset}`);
  
  for (const file of filesToRemove) {
    try {
      await fs.unlink(file);
      console.log(`${colors.green}✅ Removed: ${file}${colors.reset}`);
    } catch (error) {
      if (error.code !== 'ENOENT') {
        console.log(`${colors.yellow}⚠️  Could not remove ${file}: ${error.message}${colors.reset}`);
      }
    }
  }
}

async function updateNextConfig() {
  console.log(`\n${colors.cyan}📝 Updating Next.js configuration...${colors.reset}`);
  
  // Check which next.config file exists
  let configFile = null;
  for (const file of filesToMigrate) {
    try {
      await fs.access(file);
      configFile = file;
      break;
    } catch {}
  }

  if (!configFile) {
    console.log(`${colors.yellow}⚠️  No Next.js config file found${colors.reset}`);
    return;
  }

  try {
    let content = await fs.readFile(configFile, 'utf-8');
    
    // Remove Sentry imports
    content = content.replace(/import.*from.*['"]@sentry\/nextjs['"];?\n?/g, '');
    content = content.replace(/const.*withSentryConfig.*\n?/g, '');
    
    // Remove withSentryConfig wrapper
    content = content.replace(/export default withSentryConfig\((.+?),\s*\{[\s\S]*?\}\);?/g, 'export default $1;');
    content = content.replace(/module\.exports = withSentryConfig\((.+?),\s*\{[\s\S]*?\}\);?/g, 'module.exports = $1;');
    
    await fs.writeFile(configFile, content);
    console.log(`${colors.green}✅ Updated: ${configFile}${colors.reset}`);
    
    // If it was next.config.sentry.ts, rename it
    if (configFile === 'next.config.sentry.ts') {
      await fs.rename(configFile, 'next.config.ts');
      console.log(`${colors.green}✅ Renamed: ${configFile} → next.config.ts${colors.reset}`);
    }
  } catch (error) {
    console.error(`${colors.red}❌ Failed to update config: ${error.message}${colors.reset}`);
  }
}

async function replaceSentryImports() {
  console.log(`\n${colors.cyan}🔄 Replacing Sentry imports in source files...${colors.reset}`);
  
  try {
    // Find all files with Sentry imports
    const { stdout } = await execAsync('grep -r "@sentry" . --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --exclude-dir=node_modules --exclude-dir=.next -l');
    const files = stdout.trim().split('\n').filter(f => f);
    
    for (const file of files) {
      if (filesToRemove.includes(path.basename(file))) continue;
      
      try {
        let content = await fs.readFile(file, 'utf-8');
        let modified = false;
        
        // Replace Sentry imports
        if (content.includes('@sentry/nextjs')) {
          content = content.replace(
            /import\s+\*\s+as\s+Sentry\s+from\s+['"]@sentry\/nextjs['"];?/g,
            "import { errorMonitor, captureException, captureMessage, setUser } from '@/lib/error-monitor';"
          );
          
          // Replace captureException
          content = content.replace(/Sentry\.captureException/g, 'captureException');
          
          // Replace captureMessage
          content = content.replace(/Sentry\.captureMessage/g, 'captureMessage');
          
          // Replace setUser
          content = content.replace(/Sentry\.setUser/g, 'setUser');
          
          // Remove Sentry.init calls
          content = content.replace(/Sentry\.init\({[\s\S]*?}\);?/g, '// Error monitoring initialized in error-monitor.ts');
          
          modified = true;
        }
        
        if (modified) {
          await fs.writeFile(file, content);
          console.log(`${colors.green}✅ Migrated: ${file}${colors.reset}`);
        }
      } catch (error) {
        console.error(`${colors.yellow}⚠️  Failed to migrate ${file}: ${error.message}${colors.reset}`);
      }
    }
  } catch (error) {
    console.log(`${colors.yellow}ℹ️  No files with Sentry imports found${colors.reset}`);
  }
}

async function updatePackageJson() {
  console.log(`\n${colors.cyan}📦 Updating package.json...${colors.reset}`);
  
  try {
    const packageJson = JSON.parse(await fs.readFile('package.json', 'utf-8'));
    
    // Remove Sentry dependency
    delete packageJson.dependencies['@sentry/nextjs'];
    delete packageJson.devDependencies['@sentry/nextjs'];
    
    await fs.writeFile('package.json', JSON.stringify(packageJson, null, 2) + '\n');
    console.log(`${colors.green}✅ Removed @sentry/nextjs from dependencies${colors.reset}`);
  } catch (error) {
    console.error(`${colors.red}❌ Failed to update package.json: ${error.message}${colors.reset}`);
  }
}

async function updateEnvExample() {
  console.log(`\n${colors.cyan}🔐 Updating .env.example...${colors.reset}`);
  
  try {
    let content = await fs.readFile('.env.example', 'utf-8');
    
    // Remove Sentry env variables
    content = content.replace(/^SENTRY_.*=.*\n/gm, '');
    content = content.replace(/^NEXT_PUBLIC_SENTRY_.*=.*\n/gm, '');
    
    // Remove empty lines
    content = content.replace(/\n\n+/g, '\n\n');
    
    await fs.writeFile('.env.example', content);
    console.log(`${colors.green}✅ Removed Sentry environment variables${colors.reset}`);
  } catch (error) {
    if (error.code !== 'ENOENT') {
      console.error(`${colors.yellow}⚠️  Failed to update .env.example: ${error.message}${colors.reset}`);
    }
  }
}

async function main() {
  console.log(`${colors.cyan}🚀 Starting Sentry to Error Monitor migration...${colors.reset}\n`);
  
  await removesentryFiles();
  await updateNextConfig();
  await replaceSentryImports();
  await updatePackageJson();
  await updateEnvExample();
  
  console.log(`\n${colors.green}✅ Migration complete!${colors.reset}`);
  console.log(`\n${colors.cyan}Next steps:${colors.reset}`);
  console.log(`1. Run: ${colors.yellow}npm uninstall @sentry/nextjs${colors.reset}`);
  console.log(`2. Run: ${colors.yellow}npm install${colors.reset}`);
  console.log(`3. Remove Sentry environment variables from .env.local`);
  console.log(`4. Test error monitoring with the new system`);
  console.log(`\n${colors.blue}The new error monitoring system:${colors.reset}`);
  console.log(`- Logs errors to: /logs/errors.log`);
  console.log(`- Provides the same API as Sentry for easy migration`);
  console.log(`- Free and self-hosted`);
  console.log(`- Can be extended with webhooks, email alerts, etc.`);
}

if (require.main === module) {
  main().catch(error => {
    console.error(`${colors.red}❌ Migration failed:${colors.reset}`, error);
    process.exit(1);
  });
}