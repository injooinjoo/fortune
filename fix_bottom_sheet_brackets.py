#!/usr/bin/env python3

import re

def fix_fortune_explanation_bottom_sheet():
    """Comprehensive fix for fortune_explanation_bottom_sheet.dart bracket issues"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix common bracket issues
    fixes = [
        # Fix missing closing parentheses for methods
        (r'\.toList\(\)\n', r'.toList())\n'),
        
        # Fix string quotes issues
        (r"data\['icon'\] \?\? '''\n", r"data['icon'] ?? ''\n"),
        (r"job\['activity'\] \?\? '''\n", r"job['activity'] ?? ''\n"),
        (r"step\['description'\] \?\? '''\n", r"step['description'] ?? ''\n"),
        (r"signal\['note'\] \?\? '''\n", r"signal['note'] ?? ''\n"),
        
        # Fix common missing closing brackets
        (r'children: \[\n(.*?)\n(\s+)\]\);', r'children: [\n\1\n\2]);', re.DOTALL),
        
        # Fix specific Container issues at line 658
        (r'return Container\(\n(\s+)margin:', r'return Container(\n\1margin:'),
        
        # Fix specific Container issues at line 728
        (r'Container\(\n(\s+)width:', r'Container(\n\1width:'),
        
        # Fix onPressed callback
        (r'onPressed: _isFormValid \? \(\) async \{', r'onPressed: _isFormValid ? () async {'),
    ]
    
    for pattern, replacement in fixes[:2]:  # Apply non-regex fixes first
        content = content.replace(pattern, replacement)
    
    for pattern, replacement, *flags in fixes[2:]:  # Apply regex fixes
        if flags:
            content = re.sub(pattern, replacement, content, flags=flags[0])
        else:
            content = re.sub(pattern, replacement, content)
    
    # Count brackets to find mismatches
    lines = content.split('\n')
    bracket_stack = []
    bracket_positions = []
    
    for i, line in enumerate(lines):
        for j, char in enumerate(line):
            if char in '([{':
                bracket_stack.append((char, i, j))
                bracket_positions.append((char, i, j, 'open'))
            elif char in ')]}':
                if bracket_stack:
                    opening = bracket_stack[-1][0]
                    expected = {'(': ')', '[': ']', '{': '}'}
                    if char == expected.get(opening):
                        bracket_stack.pop()
                        bracket_positions.append((char, i, j, 'close'))
                    else:
                        print(f"Mismatch at line {i+1}, col {j+1}: expected {expected.get(opening)}, got {char}")
                else:
                    print(f"Extra closing bracket at line {i+1}, col {j+1}: {char}")
                    bracket_positions.append((char, i, j, 'extra'))
    
    # Report unclosed brackets
    for bracket, line_num, col_num in bracket_stack:
        print(f"Unclosed {bracket} at line {line_num+1}, col {col_num+1}")
    
    # Apply specific fixes based on known issues
    # Fix the Container at line 658
    if len(lines) > 657:
        if 'return Container(' in lines[657]:
            # Find the matching closing parenthesis
            bracket_count = 0
            for i in range(657, min(len(lines), 800)):
                bracket_count += lines[i].count('(') - lines[i].count(')')
                if bracket_count == 0 and ')' in lines[i]:
                    # Found the closing, make sure it's properly formatted
                    if not lines[i].strip().endswith(');'):
                        lines[i] = lines[i].rstrip() + ');'
                    break
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"Fixed {file_path}")
    print(f"Found {len(bracket_stack)} unclosed brackets")

if __name__ == "__main__":
    fix_fortune_explanation_bottom_sheet()