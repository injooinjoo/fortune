#!/usr/bin/env python3
import re

def fix_syntax_errors(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix pattern: Constructor(, or method(,
    content = re.sub(r'(\w+)\(\,', r'\1(', content)
    
    # Fix specific patterns where there might be whitespace
    content = re.sub(r'Stack\(\s*,', 'Stack(', content)
    content = re.sub(r'Container\(\s*,', 'Container(', content)
    content = re.sub(r'BoxDecoration\(\s*,', 'BoxDecoration(', content)
    content = re.sub(r'Border\.all\(\s*,', 'Border.all(', content)
    content = re.sub(r'IconButton\(\s*,', 'IconButton(', content)
    content = re.sub(r'LinearGradient\(\s*,', 'LinearGradient(', content)
    content = re.sub(r'CircularProgressIndicator\(\s*,', 'CircularProgressIndicator(', content)
    content = re.sub(r'Center\(\s*,', 'Center(', content)
    content = re.sub(r'Column\(\s*,', 'Column(', content)
    content = re.sub(r'CupertinoActionSheet\(\s*,', 'CupertinoActionSheet(', content)
    content = re.sub(r'SafeArea\(\s*,', 'SafeArea(', content)
    content = re.sub(r'CupertinoActionSheetAction\(\s*,', 'CupertinoActionSheetAction(', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed syntax errors in {file_path}")

if __name__ == "__main__":
    fix_syntax_errors("/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/profile_image_picker.dart")