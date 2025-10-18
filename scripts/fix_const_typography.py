#!/usr/bin/env python3
"""
Remove 'const' before TypographyUnified
"""

import os
import re
from pathlib import Path

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Remove 'const' before TypographyUnified
    content = re.sub(r'\bconst\s+(TypographyUnified\.\w+)', r'\1', content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    os.chdir('/Users/jacobmac/Desktop/Dev/fortune')

    fixed = 0
    for dart_file in Path('lib').rglob('*.dart'):
        if 'generated' in str(dart_file):
            continue
        if fix_file(str(dart_file)):
            fixed += 1
            print(f"✅ {dart_file}")

    print(f"\n📊 Fixed {fixed} files")

if __name__ == '__main__':
    main()
