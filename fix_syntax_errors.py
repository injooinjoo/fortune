#!/usr/bin/env python3
"""Fix syntax errors in Flutter files"""

import os
import re
import glob

def fix_syntax_errors(content):
    """Fix common syntax errors in Dart content"""
    
    # Fix pattern: containsKey('key': null,
    # Should be: containsKey('key'))
    content = re.sub(r"containsKey\('([^']+)':\s*null,", r"containsKey('\1'))", content)
    content = re.sub(r'containsKey\("([^"]+)":\s*null,', r'containsKey("\1"))', content)
    
    # Fix pattern: containsKey('key',
    # Should be: containsKey('key'))
    content = re.sub(r"containsKey\('([^']+)',\s*$", r"containsKey('\1'))", content, flags=re.MULTILINE)
    
    # Fix pattern: _buildEnhancedLuckyItem(theme, 'key': Icons.icon,
    # Should be: _buildEnhancedLuckyItem(theme, 'key', Icons.icon,
    content = re.sub(r"(_buildEnhancedLuckyItem\([^,]+,\s*)'([^']+)':\s*(Icons\.\w+),", r"\1'\2', \3,", content)
    
    # Fix pattern: return Padding(}
    # Should be: return Padding(
    content = re.sub(r'return Padding\(\}', 'return Padding(', content)
    
    # Fix pattern: child: Column(,
    # Should be: child: Column(
    content = re.sub(r'child: Column\(,', 'child: Column(', content)
    
    # Fix pattern: 'oblong', '직사각형'$1;
    # Should be: 'oblong': '직사각형',
    content = re.sub(r"'(\w+)',\s*'([^']+)'\$\d+;", r"'\1': '\2',", content)
    
    # Fix pattern: const PhysiognomyFortunePage({Key? key},
    # Should be: const PhysiognomyFortunePage({Key? key})
    content = re.sub(r'({Key\? key}),', r'\1)', content)
    
    # Fix pattern: .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
    # Should be: .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
    content = re.sub(r'\.scale\(begin: ([^,]+), end: ([^,]+),\s*$', r'.scale(begin: \1, end: \2)', content, flags=re.MULTILINE)
    
    # Fix pattern: Missing closing brackets
    # Count brackets and try to balance them
    
    # Fix pattern: Invalid package URI 'package:%20flutter/material.dart'
    content = re.sub(r'package:%20flutter/material\.dart', 'package:flutter/material.dart', content)
    
    # Fix pattern: Future.delayed(const Duration(milliseconds: 100, () {
    # Should be: Future.delayed(const Duration(milliseconds: 100), () {
    content = re.sub(r'Future\.delayed\(const Duration\(([^)]+), \(\) \{', r'Future.delayed(const Duration(\1), () {', content)
    
    # Fix pattern: .animate(CurvedAnimation(
    # Ensure proper closing
    content = re.sub(r'\.animate\(CurvedAnimation\(([^)]+)\)\);', r'.animate(CurvedAnimation(\1)));', content)
    
    # Fix pattern: Color.lerp(const Color(0xFF6A5ACD), const Color(0xFFFF6B6B),
    # Ensure proper closing
    content = re.sub(r'Color\.lerp\(([^,]+),\s*([^,]+),\s*$', r'Color.lerp(\1, \2)', content, flags=re.MULTILINE)
    
    # Fix pattern: Wrap( at the end without closing
    # This needs context-aware fixing
    
    # Fix pattern: Transform( at the end without closing
    # This needs context-aware fixing
    
    # Fix double commas
    content = re.sub(r',,+', ',', content)
    
    # Fix trailing commas before closing brackets
    content = re.sub(r',\s*\)', ')', content)
    content = re.sub(r',\s*\]', ']', content)
    content = re.sub(r',\s*\}', '}', content)
    
    return content

def process_file(filepath):
    """Process a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        content = fix_syntax_errors(content)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {filepath}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Main function"""
    # Fix specific error files first
    error_files = [
        '/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/fortune_list_page.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_main_page.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_storytelling_page.dart',
    ]
    
    fixed_count = 0
    for filepath in error_files:
        if os.path.exists(filepath) and process_file(filepath):
            fixed_count += 1
    
    # Then process all dart files
    all_files = glob.glob('/Users/jacobmac/Desktop/Dev/fortune/lib/**/*.dart', recursive=True)
    for filepath in all_files:
        if filepath not in error_files and process_file(filepath):
            fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == '__main__':
    main()