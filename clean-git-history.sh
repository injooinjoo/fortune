#!/bin/bash

# Git History Cleanup Script
# This script removes sensitive information from git history

echo "🔒 Git History Cleanup for Fortune Project"
echo "========================================="
echo ""
echo "⚠️  WARNING: This will permanently rewrite git history!"
echo "⚠️  Make sure you have:"
echo "   1. Pushed all important changes"
echo "   2. Notified all team members"
echo "   3. Made a backup of your repository"
echo ""
read -p "Are you ready to proceed? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Create backup branch
echo "📋 Creating backup branch..."
git checkout -b backup-before-cleanup-$(date +%Y%m%d-%H%M%S)
git checkout -

# Download BFG if not exists
if [ ! -f "bfg-1.14.0.jar" ]; then
    echo "📥 Downloading BFG Repo-Cleaner..."
    curl -o bfg-1.14.0.jar https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
fi

# Run BFG to remove secrets
echo "🧹 Removing secrets from history..."
java -jar bfg-1.14.0.jar --replace-text secrets.txt --no-blob-protection

# Remove specific files from history
echo "📂 Removing sensitive files..."
java -jar bfg-1.14.0.jar --delete-files "*.env" --no-blob-protection
java -jar bfg-1.14.0.jar --delete-files "*.pem" --no-blob-protection
java -jar bfg-1.14.0.jar --delete-files "*.key" --no-blob-protection
java -jar bfg-1.14.0.jar --delete-files "service-account*.json" --no-blob-protection
java -jar bfg-1.14.0.jar --delete-files "client_secret*.json" --no-blob-protection

# Clean up
echo "🗑️  Cleaning up git repository..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo ""
echo "✅ Git history cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git log --oneline"
echo "2. Force push to remote: git push --force-with-lease origin main"
echo "3. Force push all branches: git push --force-with-lease --all"
echo "4. Force push tags: git push --force-with-lease --tags"
echo ""
echo "⚠️  IMPORTANT: All team members must delete their local repos and clone fresh!"
echo ""
echo "Clean up commands for team members:"
echo "  rm -rf fortune"
echo "  git clone https://github.com/yourusername/fortune.git"