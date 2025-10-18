#!/usr/bin/env python3
"""
fontSize to TypographyUnified migration script
Migrates all fontSize values to appropriate TypographyUnified styles
"""

import os
import re
from pathlib import Path

# fontSize mapping
FONTSIZE_MAPPING = {
    '48': 'TypographyUnified.displayLarge',
    '36': 'TypographyUnified.heading1',
    '32': 'TypographyUnified.numberLarge',
    '28': 'TypographyUnified.heading1',
    '24': 'TypographyUnified.displaySmall',
    '20': 'TypographyUnified.heading3',
    '18': 'TypographyUnified.heading4',
    '16': 'TypographyUnified.buttonMedium',
    '14': 'TypographyUnified.bodySmall',
    '13': 'TypographyUnified.bodySmall',
    '12': 'TypographyUnified.labelMedium',
    '11': 'TypographyUnified.labelSmall',
    '10': 'TypographyUnified.labelTiny',
    '60': 'TypographyUnified.displayLarge',
}

IMPORT_LINE = "import '../../../../core/theme/typography_unified.dart';"

def should_skip_file(filepath):
    """Check if file should be skipped"""
    skip_patterns = [
        'fontScale',
        'font_size_provider',
        'typography_unified',
        'toss_design_system',
        'font_size_system'
    ]

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        for pattern in skip_patterns:
            if pattern in content and 'fontSize:' in content:
                # Check if it's dynamic fontSize
                if re.search(r'fontSize:\s*\d+\s*\*\s*\w+', content):
                    return True
    return False

def add_import(content, filepath):
    """Add typography_unified import if not present"""
    if 'typography_unified' in content:
        return content

    # Count '../' needed based on file depth
    depth = len(Path(filepath).relative_to('lib').parts) - 1
    import_path = '../' * depth + 'core/theme/typography_unified.dart'
    import_line = f"import '{import_path}';"

    # Find last import line
    import_pattern = r"import ['\"].*['\"];"
    imports = list(re.finditer(import_pattern, content))

    if imports:
        last_import = imports[-1]
        insert_pos = last_import.end()
        return content[:insert_pos] + '\n' + import_line + content[insert_pos:]

    return content

def migrate_fontsize(content):
    """Migrate fontSize to TypographyUnified"""
    changes = 0

    # Pattern 1: const TextStyle(fontSize: X)
    pattern1 = r'const\s+TextStyle\(fontSize:\s*(\d+)\)'
    def replace1(match):
        nonlocal changes
        size = match.group(1)
        if size in FONTSIZE_MAPPING:
            changes += 1
            return FONTSIZE_MAPPING[size]
        return match.group(0)
    content = re.sub(pattern1, replace1, content)

    # Pattern 2: TextStyle(fontSize: X, ...)
    pattern2 = r'TextStyle\(\s*fontSize:\s*(\d+),([^)]+)\)'
    def replace2(match):
        nonlocal changes
        size = match.group(1)
        rest = match.group(2)
        if size in FONTSIZE_MAPPING:
            changes += 1
            return f'{FONTSIZE_MAPPING[size]}.copyWith({rest})'
        return match.group(0)
    content = re.sub(pattern2, replace2, content)

    # Pattern 3: fontSize: X (standalone in copyWith)
    pattern3 = r'fontSize:\s*(\d+),'
    def replace3(match):
        nonlocal changes
        size = match.group(1)
        if size in FONTSIZE_MAPPING:
            changes += 1
            return ''  # Remove fontSize line when using copyWith
        return match.group(0)
    content = re.sub(pattern3, replace3, content)

    # Remove const from widgets using copyWith - simpler approach
    if 'TypographyUnified' in content and 'const Text(' in content:
        content = content.replace('const Text(\n', 'Text(\n')
        content = content.replace('const Row(\n', 'Row(\n')
        content = content.replace('const Column(\n', 'Column(\n')

    return content, changes

def process_file(filepath):
    """Process a single file"""
    if should_skip_file(filepath):
        return 0

    with open(filepath, 'r', encoding='utf-8') as f:
        original = f.read()

    # Skip if no fontSize
    if 'fontSize:' not in original:
        return 0

    content = add_import(original, filepath)
    content, changes = migrate_fontsize(content)

    if changes > 0:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ {filepath}: {changes} changes")
        return changes

    return 0

def main():
    """Main migration function"""
    os.chdir('/Users/jacobmac/Desktop/Dev/fortune')

    total_changes = 0
    total_files = 0

    # Find all Dart files
    for dart_file in Path('lib').rglob('*.dart'):
        if 'generated' in str(dart_file) or 'build' in str(dart_file):
            continue

        changes = process_file(str(dart_file))
        if changes > 0:
            total_changes += changes
            total_files += 1

    print(f"\n📊 Total: {total_files} files, {total_changes} fontSize migrations")
    return total_files

if __name__ == '__main__':
    main()
