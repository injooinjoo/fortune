#!/usr/bin/env python3
"""
Fix Flutter parameter syntax errors where parameters end with ) instead of ,
"""

import re
import os
import sys
from pathlib import Path

def fix_parameter_syntax(file_path):
    """Fix parameter syntax in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Pattern to match constructor parameters ending with ) instead of ,
        # This matches: parameterName) followed by newline and whitespace
        pattern1 = r'(\s+)(required this\.[a-zA-Z_]+[a-zA-Z0-9_]*)\)(\s*\n\s+)'
        replacement1 = r'\1\2,\3'
        
        # Pattern to match optional parameters ending with )
        pattern2 = r'(\s+)(this\.[a-zA-Z_]+[a-zA-Z0-9_]*(?:\s*=\s*[^)]+)?)\)(\s*\n\s+)'
        replacement2 = r'\1\2,\3'
        
        # Pattern to match function parameters ending with )
        pattern3 = r'(\s+)([a-zA-Z_]+[a-zA-Z0-9_]*\s+[a-zA-Z_]+[a-zA-Z0-9_]*)\)(\s*\n\s+)'
        replacement3 = r'\1\2,\3'
        
        # Pattern to match fields in constructors like: fields[0] as String)
        pattern4 = r'(:\s*fields\[[0-9]+\]\s*as\s*[^)]+)\)(\s*\n)'
        replacement4 = r'\1,\2'
        
        # Pattern to match cast expressions ending with )
        pattern5 = r'(\)\.cast<[^>]+>(?:\(\))?)\)(\s*\n)'
        replacement5 = r'\1,\2'
        
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
        
        if fix_parameter_syntax(file_path):
            fixed_files.append(file_path)
    
    print(f"\nFixed {len(fixed_files)} files")
    if fixed_files and len(fixed_files) < 50:
        print("\nFixed files:")
        for f in fixed_files:
            print(f"  - {f}")

if __name__ == "__main__":
    main()