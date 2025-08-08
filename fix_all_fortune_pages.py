#!/usr/bin/env python3
import os
import glob
import re

def fix_common_bracket_issues(file_path):
    """Fix common bracket and parentheses issues in a Dart file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Fix common patterns
    # 1. Fix TextStyle closing parentheses
    content = re.sub(r'(height:\s*[\d.]+)\)\)', r'\1)', content)
    
    # 2. Fix missing closing parentheses for TextStyle
    content = re.sub(r'(style:\s*[^,\n]+\.textTheme\.[^,\n]+)\s*(?=,|\n)', r'\1)', content)
    
    # 3. Fix BoxDecoration missing closing parentheses
    content = re.sub(r'(borderRadius:\s*BorderRadius\.circular\([^)]+\)),\s*$', r'\1)),', content, flags=re.MULTILINE)
    
    # 4. Fix Container/GlassContainer/LiquidGlassContainer missing closing
    content = re.sub(r'(Colors\.[a-zA-Z]+\.shade\d+\]),\s*$', r'\1],', content, flags=re.MULTILINE)
    
    # 5. Fix Text widget with only one argument but missing closing
    content = re.sub(r'(\s+Text\(\s*\'[^\']+\',?\s*)$', r'\1),', content, flags=re.MULTILINE)
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {file_path}")
        return True
    return False

def main():
    # Find all Dart files in fortune pages
    fortune_pages = glob.glob("/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/*.dart")
    fortune_widgets = glob.glob("/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/*.dart")
    
    all_files = fortune_pages + fortune_widgets
    
    fixed_count = 0
    for file_path in all_files:
        if fix_common_bracket_issues(file_path):
            fixed_count += 1
    
    print(f"\nTotal files processed: {len(all_files)}")
    print(f"Files fixed: {fixed_count}")

if __name__ == "__main__":
    main()