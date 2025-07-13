#!/bin/bash

# Git History Cleanup Script for Fortune Project
# ⚠️ WARNING: This will rewrite git history! Make sure all team members are aware.

echo "🔒 Git History Security Cleanup Script"
echo "====================================="
echo ""
echo "⚠️  WARNING: This script will permanently rewrite git history!"
echo "⚠️  Make sure to:"
echo "   1. Backup your repository first"
echo "   2. Inform all team members"
echo "   3. Have everyone re-clone after this operation"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 1
fi

echo ""
echo "📋 Creating backup..."
cp -r .git .git-backup-$(date +%Y%m%d-%H%M%S)

echo ""
echo "🧹 Removing sensitive files from git history..."

# List of files to remove from history
SENSITIVE_FILES=(
    ".env"
    ".env.local"
    ".env.production"
    ".env.development"
    "client_secret.json"
    "client_secret*.json"
    "**/client_secret*.json"
    "service-account.json"
    "**/service-account*.json"
    "fortune-api-server/.env"
    "fortune_flutter/.env"
    "supabase/.env.local"
)

# Using BFG Repo-Cleaner (if installed) - Recommended
if command -v bfg &> /dev/null; then
    echo "Using BFG Repo-Cleaner..."
    
    # Create a file with patterns to remove
    echo "Creating patterns file..."
    cat > .bfg-patterns << EOF
.env
.env.*
client_secret*.json
service-account*.json
EOF
    
    # Run BFG
    bfg --delete-files .bfg-patterns
    
    # Clean up
    rm .bfg-patterns
    
else
    echo "BFG not found. Using git filter-branch (slower)..."
    
    # Remove each sensitive file
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "Removing $file from history..."
        git filter-branch --force --index-filter \
            "git rm --cached --ignore-unmatch $file" \
            --prune-empty --tag-name-filter cat -- --all
    done
fi

echo ""
echo "🔄 Cleaning up git objects..."
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo ""
echo "📊 Repository size comparison:"
echo "Before: $(du -sh .git-backup-* | cut -f1)"
echo "After:  $(du -sh .git | cut -f1)"

echo ""
echo "✅ Git history cleaned!"
echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo "   1. Review the changes: git log --oneline"
echo "   2. Force push to remote: git push origin --force --all"
echo "   3. Force push tags: git push origin --force --tags"
echo "   4. Have all team members delete their local repos and re-clone"
echo "   5. Update any CI/CD pipelines that might cache the repo"
echo ""
echo "🔐 Security Reminders:"
echo "   - Rotate all exposed API keys immediately"
echo "   - Update .gitignore to prevent future commits"
echo "   - Use .env.example files for configuration templates"
echo "   - Consider using git-secrets or similar tools"
echo ""
echo "Backup saved to: .git-backup-*"