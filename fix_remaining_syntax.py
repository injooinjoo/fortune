#!/usr/bin/env python3
"""
Fix remaining Flutter syntax errors including:
1. For loop ending with ) instead of closing }
2. Cast expressions ending with ) instead of ,
"""

import re
import os
import sys
from pathlib import Path

def fix_remaining_syntax(file_path):
    """Fix remaining syntax errors in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Fix for loop syntax: reader.read()) should be reader.read()
        pattern1 = r'(for \(int i = 0; i < numOfFields; i\+\+\) reader\.readByte\(\): reader\.read\(\))\)'
        replacement1 = r'\1'
        
        # Fix cast expressions that still have ) at the end of line
        # Pattern: )?.cast<type>()) at end of line
        pattern2 = r'(\)\.cast<[^>]+>\(\))\)(\s*,?\s*\n)'
        replacement2 = r'\1,\2'
        
        # Fix fields with cast that end with ) instead of ,
        # Pattern: as Type?)?.cast<type>()) followed by newline
        pattern3 = r'(as [^)]+\?\)\.cast<[^>]+>\(\))\)(\s*\n)'
        replacement3 = r'\1,\2'
        
        # Fix List cast expressions
        pattern4 = r'(as List\?\)\.cast<[^>]+>\(\))\)(\s*\n)'
        replacement4 = r'\1,\2'
        
        # Fix last parameter before closing parenthesis
        # Look for patterns where a parameter ends with ) and the next line has );
        pattern5 = r'(\s+[^,]+)\)(\s*\n\s*\);)'
        replacement5 = r'\1\2'
        
        # Apply fixes
        content = re.sub(pattern1, replacement1, content)
        content = re.sub(pattern2, replacement2, content)
        content = re.sub(pattern3, replacement3, content)
        content = re.sub(pattern4, replacement4, content)
        content = re.sub(pattern5, replacement5, content)
        
        # Check if content changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Process all Dart files in the lib directory"""
    lib_path = Path("/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter/lib")
    
    if not lib_path.exists():
        print(f"Error: {lib_path} does not exist")
        sys.exit(1)
    
    fixed_files = []
    error_files = []
    
    # Find all .dart files
    dart_files = list(lib_path.rglob("*.dart"))
    total_files = len(dart_files)
    
    print(f"Found {total_files} Dart files to process...")
    
    for i, file_path in enumerate(dart_files, 1):
        if i % 100 == 0:
            print(f"Processing file {i}/{total_files}...")
        
        if fix_remaining_syntax(file_path):
            fixed_files.append(file_path)
    
    print(f"\nFixed {len(fixed_files)} files")
    if fixed_files and len(fixed_files) < 50:
        print("\nFixed files:")
        for f in fixed_files:
            print(f"  - {f}")

if __name__ == "__main__":
    main()