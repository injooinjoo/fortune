#!/bin/bash

# Git History Secret Removal Script
# WARNING: This will rewrite git history!

echo "⚠️  WARNING: This script will rewrite git history!"
echo "Make sure you have a backup and coordinate with your team."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Patterns to remove
PATTERNS=(
    "SUPABASE_SERVICE_ROLE_KEY"
    "SUPABASE_SERVICE_KEY"
    "OPENAI_API_KEY"
    "JWT_SECRET"
    "STRIPE_SECRET_KEY"
    "REDIS_TOKEN"
    "UPSTASH_REDIS_REST_TOKEN"
    "INTERNAL_API_KEY"
    "CRON_SECRET"
    "ENCRYPTION_KEY"
    "GOOGLE_SERVICE_ACCOUNT"
    "APPLE_IAP_SHARED_SECRET"
    "TOSS_SECRET_KEY"
)

# Files that should never be in git
FILES_TO_REMOVE=(
    ".env"
    ".env.local"
    ".env.production"
    "service-account*.json"
    "client_secret*.json"
    "*.pem"
    "*.key"
)

echo "📋 Creating backup branch..."
git branch backup-before-cleanup

echo "📋 Removing sensitive files from history..."
for file in "${FILES_TO_REMOVE[@]}"; do
    echo "   Removing: $file"
    git filter-branch --force --index-filter \
        "git rm --cached --ignore-unmatch '$file'" \
        --prune-empty --tag-name-filter cat -- --all 2>/dev/null || true
done

echo "📋 Removing sensitive strings from history..."
# This requires BFG Repo-Cleaner for better performance
# Download from: https://rtyley.github.io/bfg-repo-cleaner/

echo ""
echo "To complete the cleanup:"
echo "1. Download BFG Repo-Cleaner"
echo "2. Run: java -jar bfg.jar --replace-text secrets.txt"
echo "3. Create secrets.txt with patterns like:"
echo "   SUPABASE_SERVICE_ROLE_KEY==>***REMOVED***"
echo "   sk_live_*==>***REMOVED***"
echo "4. Run: git reflog expire --expire=now --all"
echo "5. Run: git gc --prune=now --aggressive"
echo "6. Force push: git push --force --all"
echo "7. Force push tags: git push --force --tags"
echo ""
echo "⚠️  All team members must re-clone after this!"