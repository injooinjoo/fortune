#!/usr/bin/env python3
"""
Final fix for token_insufficient_modal.dart syntax errors
"""

import re

def fix_token_modal():
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/shared/components/token_insufficient_modal.dart', 'r') as f:
        lines = f.readlines()
    
    # Fix line 64 - missing semicolon
    if lines[63].strip().endswith('))'):
        lines[63] = lines[63].rstrip() + ';\n'
    
    # Fix line 71 - missing semicolon
    if lines[70].strip().endswith('))'):
        lines[70] = lines[70].rstrip() + ';\n'
    
    # Fix line 105 - child: Icon should be proper nested
    if 'child: Icon(' in lines[104]:
        lines[104] = lines[104].replace('      child: Icon(', '                  ),\n                  child: Icon(\n')
    
    # Fix lines with missing commas after closing parentheses
    for i in range(len(lines)):
        # Fix lines that end with ) and next line has SizedBox
        if i < len(lines) - 1:
            if lines[i].strip().endswith(')') and 'SizedBox' in lines[i+1]:
                if not lines[i].strip().endswith('),') and not lines[i].strip().endswith(');'):
                    lines[i] = lines[i].rstrip() + ',\n'
        
        # Fix lines that end with )) and then have something else
        if i < len(lines) - 1:
            if lines[i].strip().endswith('))') and not lines[i].strip().endswith(');'):
                next_line = lines[i+1].strip()
                if next_line and not next_line.startswith('//'):
                    # Check if it's a statement continuation
                    if not any(next_line.startswith(x) for x in ['.', '?', ':', 'else', 'catch']):
                        lines[i] = lines[i].rstrip() + ',\n'
    
    # Fix specific problem areas
    content = ''.join(lines)
    
    # Fix the Icon decoration issue
    content = re.sub(
        r'color: theme\.colorScheme\.error\.withValues\(alpha: 0\.2\),\s*child: Icon\(',
        r'color: theme.colorScheme.error.withValues(alpha: 0.2),\n                  ),\n                  child: Icon(',
        content
    )
    
    # Fix all instances where there's a closing parenthesis without comma before widget constructors
    patterns = [
        (r'\)\s*SizedBox\(', r'),\n                SizedBox('),
        (r'\)\s*Container\(', r'),\n                      Container('),
        (r'\)\s*Text\(', r'),\n                Text('),
        (r'\)\s*_buildTokenInfo\(', r'),\n                      _buildTokenInfo('),
        (r'\)\s*Icon\(', r'),\n                            Icon('),
        (r'\)\s*Expanded\(', r'),\n                    Expanded('),
        (r'\)\s*Row\(', r'),\n                Row('),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    # Fix the copyWith issues with extra commas
    content = re.sub(
        r'copyWith\(,\s*',
        r'copyWith(\n                    ',
        content
    )
    
    # Fix withValues(alpha: xxx))) patterns
    content = re.sub(
        r'\.withValues\(alpha: ([0-9.]+)\)\)\)',
        r'.withValues(alpha: \1),\n                      ),',
        content
    )
    
    # Fix the label text issue
    content = re.sub(
        r"Text\(\s*label\),\s*style:",
        r"Text(\n                  label,\n                  style:",
        content
    )
    
    # Fix ending parentheses
    content = re.sub(
        r'fontWeight: FontWeight\.bold\)\)\s*\]\)',
        r'fontWeight: FontWeight.bold,\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );',
        content
    )
    
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/shared/components/token_insufficient_modal.dart', 'w') as f:
        f.write(content)
    
    print("Fixed token_insufficient_modal.dart - final pass")

if __name__ == "__main__":
    fix_token_modal()