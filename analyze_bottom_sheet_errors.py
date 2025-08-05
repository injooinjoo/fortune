#!/usr/bin/env python3

import re

def analyze_bracket_issues():
    file_path = '/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Track bracket balance
    bracket_stack = []
    issues = []
    
    brackets = {
        '(': ')',
        '[': ']',
        '{': '}',
        '<': '>'
    }
    
    closing_brackets = set(brackets.values())
    
    for line_num, line in enumerate(lines, 1):
        # Skip comments
        if line.strip().startswith('//'):
            continue
            
        for char_idx, char in enumerate(line):
            if char in brackets:
                bracket_stack.append({
                    'bracket': char,
                    'line': line_num,
                    'col': char_idx + 1,
                    'context': line.strip()
                })
            elif char in closing_brackets:
                if not bracket_stack:
                    issues.append(f"Line {line_num}: Unexpected closing bracket '{char}' - {line.strip()}")
                else:
                    opening = bracket_stack[-1]
                    expected_closing = brackets[opening['bracket']]
                    if char == expected_closing:
                        bracket_stack.pop()
                    else:
                        issues.append(f"Line {line_num}: Expected '{expected_closing}' but found '{char}' - {line.strip()}")
                        issues.append(f"  Matching opening bracket at line {opening['line']}: {opening['context']}")
    
    # Check for unclosed brackets
    for item in bracket_stack:
        issues.append(f"Line {item['line']}: Unclosed '{item['bracket']}' - {item['context']}")
    
    return issues

def find_specific_errors():
    """Find specific error patterns mentioned in the Flutter errors"""
    file_path = '/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    error_lines = [215, 658, 896, 895, 893, 1274, 1273, 1259, 1245, 1357, 1348, 1347, 1344, 1318, 1316]
    
    print("\nSpecific error locations:")
    for line_num in sorted(error_lines):
        if line_num <= len(lines):
            print(f"\nLine {line_num}: {lines[line_num-1].strip()}")
            # Show context
            start = max(0, line_num - 3)
            end = min(len(lines), line_num + 2)
            for i in range(start, end):
                prefix = ">>> " if i == line_num - 1 else "    "
                print(f"{prefix}{i+1}: {lines[i].rstrip()}")

if __name__ == "__main__":
    print("Analyzing bracket issues...")
    issues = analyze_bracket_issues()
    
    if issues:
        print(f"\nFound {len(issues)} bracket issues:")
        for issue in issues[:20]:  # Show first 20 issues
            print(issue)
        if len(issues) > 20:
            print(f"... and {len(issues) - 20} more issues")
    else:
        print("No bracket issues found!")
    
    find_specific_errors()