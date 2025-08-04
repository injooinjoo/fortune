#!/usr/bin/env python3
import re
import os
import glob

def fix_enum_syntax(file_path):
    """Fix enum syntax errors in a file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all enum declarations
    enum_pattern = r'(enum\s+\w+\s*\{[^}]+\})'
    
    def fix_enum_values(match):
        enum_content = match.group(0)
        
        # Fix patterns like 'label': 'value':
        # Pattern to match enum values with colons instead of commas
        value_pattern = r"(\w+)\('([^']+)':\s*'([^']+)':\s*"
        
        # Replace with correct syntax
        fixed = re.sub(value_pattern, r"\1('\2', '\3', ", enum_content)
        
        # Also fix patterns without proper icon and color parameters
        # This is a simplified fix - in real cases we'd need to add proper icons and colors
        
        return fixed
    
    # Apply fixes
    fixed_content = re.sub(enum_pattern, fix_enum_values, content, flags=re.DOTALL)
    
    # Only write if content changed
    if fixed_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)
        return True
    
    return False

# Find all dart files with potential enum issues
dart_files = glob.glob('/Users/jacobmac/Desktop/Dev/fortune/lib/**/*.dart', recursive=True)

fixed_files = []
for file_path in dart_files:
    try:
        if fix_enum_syntax(file_path):
            fixed_files.append(file_path)
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

print(f"Fixed {len(fixed_files)} files with enum syntax errors")
for f in fixed_files:
    print(f"  - {f}")