#!/bin/bash

echo "🔧 Final comprehensive syntax fix for all Dart files..."

# Fix all arrow function errors
echo "📝 Fixing arrow function syntax..."
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Fix (error, stack) { patterns
    sed -i '' 's/(error, stack) { /(error, stack) => /g' "$file"
    
    # Fix (error, stackTrace) { patterns  
    sed -i '' 's/(error, stackTrace) { /(error, stackTrace) => /g' "$file"
    
    # Fix (_, __) { patterns
    sed -i '' 's/(_, __) { /(_, __) => /g' "$file"
    
    # Fix (_, __) => { patterns (wrong arrow function)
    sed -i '' 's/(_, __) => {$/(_, __) => Container(/g' "$file"
    
    # Fix error: (_, __) => { patterns in async contexts
    sed -i '' 's/error: (_, __) => {$/error: (_, __) => {}/g' "$file"
    
    # Fix loading: () => { patterns
    sed -i '' 's/loading: () => {$/loading: () => Container(/g' "$file"
done

echo "🔍 Checking specific problem files..."

# Fix specific known issues in profile_screen.dart
if [ -f "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/profile/profile_screen.dart" ]; then
    echo "  Fixing profile_screen.dart..."
    # Ensure methods have proper structure
    sed -i '' 's/^  void initState() {/  @override\n  void initState() {/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/profile/profile_screen.dart"
    sed -i '' 's/^  void dispose() {/  @override\n  void dispose() {/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/profile/profile_screen.dart"
    sed -i '' 's/^  Widget build(/  @override\n  Widget build(/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/profile/profile_screen.dart"
fi

# Fix specific known issues in callback_page.dart
if [ -f "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/auth/callback_page.dart" ]; then
    echo "  Fixing callback_page.dart..."
    sed -i '' 's/^  void initState() {/  @override\n  void initState() {/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/auth/callback_page.dart"
    sed -i '' 's/^  Widget build(/  @override\n  Widget build(/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/auth/callback_page.dart"
fi

# Fix specific known issues in landing_page.dart
if [ -f "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/landing_page.dart" ]; then
    echo "  Fixing landing_page.dart..."
    sed -i '' 's/^  void initState() {/  @override\n  void initState() {/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/landing_page.dart"
    sed -i '' 's/^  void dispose() {/  @override\n  void dispose() {/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/landing_page.dart"
    sed -i '' 's/^  Widget build(/  @override\n  Widget build(/g' "/Users/jacobmac/Desktop/Dev/fortune/lib/screens/landing_page.dart"
fi

# Remove duplicate @override annotations
echo "🧹 Cleaning up duplicate @override annotations..."
find /Users/jacobmac/Desktop/Dev/fortune/lib -name "*.dart" -type f -print0 | while IFS= read -r -d '' file; do
    # Remove duplicate @override annotations
    perl -0777 -i -pe 's/\@override\s*\n\s*\@override/\@override/g' "$file"
done

echo "✅ Syntax fixes complete!"