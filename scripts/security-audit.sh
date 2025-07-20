#!/bin/bash

# Fortune Project Security Audit Script
# This script checks for common security issues

echo "🔒 Fortune Project Security Audit"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for exposed secrets in git history
echo -e "\n📋 Checking git history for secrets..."
SECRETS_PATTERN="SUPABASE_SERVICE_ROLE_KEY|OPENAI_API_KEY|JWT_SECRET|STRIPE_SECRET_KEY|password|token|secret"
if git log -p | grep -E "$SECRETS_PATTERN" > /dev/null 2>&1; then
    echo -e "${RED}❌ Found potential secrets in git history${NC}"
    echo "   Run: git filter-branch or BFG Repo-Cleaner to remove them"
else
    echo -e "${GREEN}✅ No obvious secrets found in git history${NC}"
fi

# Check for .env files
echo -e "\n📋 Checking for .env files..."
ENV_FILES=$(find . -name ".env*" -not -name "*.example" -not -path "*/node_modules/*" 2>/dev/null)
if [ -n "$ENV_FILES" ]; then
    echo -e "${YELLOW}⚠️  Found .env files (make sure they're in .gitignore):${NC}"
    echo "$ENV_FILES"
else
    echo -e "${GREEN}✅ No .env files found${NC}"
fi

# Check if .env files are in .gitignore
echo -e "\n📋 Checking .gitignore..."
if grep -q "^\.env" .gitignore; then
    echo -e "${GREEN}✅ .env files are ignored${NC}"
else
    echo -e "${RED}❌ .env files are NOT in .gitignore${NC}"
fi

# Check for hardcoded secrets in code
echo -e "\n📋 Checking for hardcoded secrets in code..."
HARDCODED=$(grep -r -E "sk_live_|pk_live_|AIza|eyJ" --include="*.ts" --include="*.js" --include="*.dart" --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null | grep -v ".example" | grep -v "// Example")
if [ -n "$HARDCODED" ]; then
    echo -e "${RED}❌ Found potential hardcoded secrets:${NC}"
    echo "$HARDCODED" | head -10
else
    echo -e "${GREEN}✅ No hardcoded secrets found${NC}"
fi

# Check API endpoints for authentication
echo -e "\n📋 Checking API authentication..."
AUTH_CHECK=$(grep -r "router\.\(get\|post\|put\|delete\)" fortune-api-server/src/routes --include="*.ts" | grep -v "authMiddleware" | wc -l)
if [ $AUTH_CHECK -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $AUTH_CHECK routes that might lack authentication${NC}"
else
    echo -e "${GREEN}✅ All routes appear to have authentication${NC}"
fi

# Check for HTTPS enforcement
echo -e "\n📋 Checking HTTPS enforcement..."
if grep -q "forceSSL\|requireHTTPS\|secure: true" fortune-api-server/src/app.ts 2>/dev/null; then
    echo -e "${GREEN}✅ HTTPS enforcement found${NC}"
else
    echo -e "${YELLOW}⚠️  No explicit HTTPS enforcement found${NC}"
fi

# Check for rate limiting
echo -e "\n📋 Checking rate limiting..."
if grep -q "rate-limit\|rateLimit" fortune-api-server/package.json 2>/dev/null; then
    echo -e "${GREEN}✅ Rate limiting package installed${NC}"
else
    echo -e "${RED}❌ No rate limiting package found${NC}"
fi

# Check for security headers
echo -e "\n📋 Checking security headers (Helmet)..."
if grep -q "helmet" fortune-api-server/package.json 2>/dev/null; then
    echo -e "${GREEN}✅ Helmet.js installed for security headers${NC}"
else
    echo -e "${RED}❌ Helmet.js not found${NC}"
fi

# Check for vulnerable dependencies
echo -e "\n📋 Checking for vulnerable dependencies..."
cd fortune-api-server && npm audit --audit-level=high 2>/dev/null
cd ../fortune_flutter && flutter pub outdated 2>/dev/null | grep -E "OUTDATED|SECURITY"

echo -e "\n================================="
echo "🔒 Security Audit Complete"
echo ""
echo "Recommendations:"
echo "1. Rotate all API keys and secrets immediately"
echo "2. Use environment-specific keys (dev/staging/prod)"
echo "3. Enable Supabase RLS (Row Level Security) on all tables"
echo "4. Set up automated security scanning in CI/CD"
echo "5. Use Supabase Secrets for production keys"