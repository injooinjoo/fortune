#!/usr/bin/env python3
import re
import sys

def fix_brackets(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix patterns where there are too many closing brackets
    # Pattern: ))), at end of lines
    content = re.sub(r'\)\)\),\s*$', ')),', content, flags=re.MULTILINE)
    
    # Pattern: ))); at end of lines
    content = re.sub(r'\)\)\);\s*$', '));', content, flags=re.MULTILINE)
    
    # Pattern: )])); at end of lines  
    content = re.sub(r'\)\]\]\)\);\s*$', ')]);', content, flags=re.MULTILINE)
    
    # Pattern: BorderRadius.circular(12)))
    content = re.sub(r'BorderRadius\.circular\((\d+)\)\)\),', r'BorderRadius.circular(\1)),', content)
    content = re.sub(r'BorderRadius\.circular\((\d+)\)\)\)\)', r'BorderRadius.circular(\1))', content)
    
    # Pattern: .withOpacity(0.x)))
    content = re.sub(r'\.withOpacity\(([\d.]+)\)\)\),', r'.withOpacity(\1)),', content)
    content = re.sub(r'\.withOpacity\(([\d.]+)\)\)\)\)', r'.withOpacity(\1))', content)
    
    # Pattern: style: theme.textTheme.xxx)))
    content = re.sub(r'(style: theme\.textTheme\.\w+)\)\)\),', r'\1)),', content)
    content = re.sub(r'(style: theme\.textTheme\.\w+)\)\)\)\)', r'\1))', content)
    
    # Pattern: ])))
    content = re.sub(r'\]\)\)\),', r']),', content)
    content = re.sub(r'\]\)\)\);', r']);', content)
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed brackets in {file_path}")

if __name__ == "__main__":
    fix_brackets('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/marriage_fortune_page.dart')