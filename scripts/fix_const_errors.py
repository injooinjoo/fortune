#!/usr/bin/env python3
"""
Fix const errors in migrated files
"""

import os
import re
from pathlib import Path

def fix_const_in_file(filepath):
    """Remove const from widgets using TypographyUnified.copyWith"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'TypographyUnified' not in content or 'const' not in content:
        return False

    original = content

    # Pattern 1: const Text(..., style: TypographyUnified...)
    content = re.sub(
        r'const\s+Text\s*\(\s*\n',
        r'Text(\n',
        content
    )

    # Pattern 2: const Row/Column with TypographyUnified inside
    if 'TypographyUnified' in content:
        content = re.sub(r'const\s+(Row|Column|Center)\s*\(\s*\n', r'\1(\n', content)

    # Pattern 3: const in widget with copyWith
    content = re.sub(
        r'const\s+(Text|Icon|SizedBox|Padding|Container)\s*\(',
        lambda m: m.group(1) + '(' if '.copyWith' in content[m.start():m.start()+200] else m.group(0),
        content
    )

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True

    return False

def main():
    os.chdir('/Users/jacobmac/Desktop/Dev/fortune')

    fixed = 0
    error_files = [
        'lib/features/fortune/presentation/pages/lucky_items_unified_page.dart',
        'lib/features/fortune/presentation/widgets/coin_throw_animation.dart',
        'lib/features/fortune/presentation/widgets/divine_response_widget.dart',
        'lib/shared/widgets/typography/app_text.dart',
    ]

    for filepath in error_files:
        if os.path.exists(filepath):
            if fix_const_in_file(filepath):
                print(f"✅ Fixed: {filepath}")
                fixed += 1

    # Also scan all modified files
    for dart_file in Path('lib').rglob('*.dart'):
        if str(dart_file) not in error_files:
            if fix_const_in_file(str(dart_file)):
                fixed += 1

    print(f"\n📊 Fixed {fixed} files")

if __name__ == '__main__':
    main()
