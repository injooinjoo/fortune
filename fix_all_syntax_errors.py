#\!/usr/bin/env python3
import os
import re

def fix_dart_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Fix common syntax errors
    # 1. Fix if statement with comma before widget  
    content = re.sub(r'if\s*\(([^)]+)\),\s*([A-Z])', r'if (\1) \2', content)
    
    # 2. Fix if statement with semicolon
    content = re.sub(r'if\s*\(([^)]+)\);', r'if (\1)', content)
    
    # Write back if changed
    if content \!= original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {filepath}")
        return True
    return False

def main():
    fixed_count = 0
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                if fix_dart_file(filepath):
                    fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
