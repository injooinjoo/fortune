#!/usr/bin/env python3
"""
Fix map literal and list literal syntax errors
"""

import re
import os
import sys
from pathlib import Path

def fix_map_and_list_literals(file_path):
    """Fix map and list literal syntax errors in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Fix map entries ending with ) instead of ,
        # Pattern: 'key': value) followed by newline and another 'key':
        pattern1 = r"('[\w]+': [^,\n]+)\)(\s*\n\s*'[\w]+':)"
        replacement1 = r'\1,\2'
        
        # Fix map entries ending with )) instead of ),
        pattern2 = r"('[\w]+': [^,\n]+\))\)(\s*\n\s*'[\w]+':)"
        replacement2 = r'\1,\2'
        
        # Fix map entries with quotes around keys
        pattern3 = r'("[\w]+": [^,\n]+)\)(\s*\n\s*"[\w]+":)'
        replacement3 = r'\1,\2'
        
        # Fix array/list entries ending with ) instead of ,
        # Pattern: value) followed by newline and another value
        pattern4 = r"(\s+)([^,\s]+)\)(\s*\n\s+[^}\]]*[^:]\s)"
        replacement4 = r'\1\2,\3'
        
        # Fix closing brackets/braces with wrong syntax
        # Pattern: }) at end of line where it should be }
        pattern5 = r'}\)(\s*;?\s*$)'
        replacement5 = r'}\1'
        
        # Fix cases where there's )) at end of line in constructors
        pattern6 = r'(\w+\([^)]*\))\)(\s*;)'
        replacement6 = r'\1\2'
        
        # Apply fixes
        content = re.sub(pattern1, replacement1, content)
        content = re.sub(pattern2, replacement2, content)
        content = re.sub(pattern3, replacement3, content)
        content = re.sub(pattern4, replacement4, content)
        content = re.sub(pattern5, replacement5, content)
        content = re.sub(pattern6, replacement6, content)
        
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
        
        if fix_map_and_list_literals(file_path):
            fixed_files.append(file_path)
    
    print(f"\nFixed {len(fixed_files)} files")
    if fixed_files and len(fixed_files) < 50:
        print("\nFixed files:")
        for f in fixed_files:
            print(f"  - {f}")

if __name__ == "__main__":
    main()