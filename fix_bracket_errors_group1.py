#!/usr/bin/env python3
"""Fix bracket matching errors in Flutter files - Group 1"""

import re
import os

def fix_bracket_errors(file_path):
    """Fix common bracket matching errors in Flutter files"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    fixed_lines = []
    
    for i, line in enumerate(lines):
        fixed_line = line
        
        # Fix pattern: Missing closing parenthesis after method calls
        # Fix setState(() { ... }); pattern
        if 'setState(() {' in fixed_line and fixed_line.strip().endswith('});'):
            indent = len(fixed_line) - len(fixed_line.lstrip())
            if i + 1 < len(lines) and lines[i + 1].strip() == '},':
                # The closing bracket is on the next line, merge them
                fixed_line = fixed_line.rstrip() + '\n'
                lines[i + 1] = ''  # Clear the next line
                fixed_lines.append(fixed_line)
                continue
                
        # Fix .map() patterns with missing parentheses
        if '.map(' in fixed_line or '.map<' in fixed_line:
            # Count parentheses
            open_parens = fixed_line.count('(')
            close_parens = fixed_line.count(')')
            if open_parens > close_parens:
                # Look ahead for the closing
                if i + 1 < len(lines):
                    next_line = lines[i + 1]
                    if ').toList()' in next_line or '}).toList()' in next_line:
                        fixed_line = fixed_line.rstrip() + '\n'
        
        # Fix color/Map patterns with wrong syntax
        # Pattern: 'color': Colors.red, should be 'color': Colors.red,
        fixed_line = re.sub(r"'(color|meaning|description)':\s*([^,]+),\s*$", r"'\1': '\2',", fixed_line)
        
        # Fix Map initialization patterns
        if re.search(r"'[^']+'\s*:\s*\{\s*\}", fixed_line):
            # Pattern like '불': {} on one line
            fixed_line = re.sub(r"'([^']+)'\s*:\s*\{\s*\}", r"'\1': {", fixed_line)
        
        # Fix lines that have orphaned commas at the start
        if fixed_line.strip().startswith(', '):
            # This should be part of previous line or Map entry
            fixed_line = re.sub(r"^\s*,\s*'", "        '", fixed_line)
        
        # Fix if conditions with missing commas
        if 'if (' in fixed_line and fixed_line.strip().endswith('),'):
            # Pattern: if (condition), should be if (condition)
            fixed_line = fixed_line.replace('),', ')')
            
        # Fix TextStyle missing closing parenthesis
        if 'style: Theme.of(context).textTheme' in fixed_line and not fixed_line.strip().endswith('),') and not fixed_line.strip().endswith('))'):
            if fixed_line.strip().endswith(','):
                fixed_line = fixed_line.rstrip()[:-1] + '),\n'
            elif not fixed_line.strip().endswith(')'):
                fixed_line = fixed_line.rstrip() + '),\n'
        
        # Fix missing closing brackets in Widget arrays
        if fixed_line.strip().endswith('])),') or fixed_line.strip().endswith('])'),'):
            # These patterns are usually correct
            pass
        elif '].toList()' in fixed_line:
            # Check if brackets are balanced
            open_brackets = fixed_line.count('[')
            close_brackets = fixed_line.count(']')
            if open_brackets > close_brackets:
                fixed_line = fixed_line.replace('].toList()', ')].toList()')
        
        # Fix case statements with commas
        if re.match(r'\s*case\s*,', fixed_line):
            fixed_line = re.sub(r'case\s*,', 'case', fixed_line)
            
        # Fix lines with numeric cases
        if re.match(r'\s*case\s*\d+:', fixed_line):
            # These should be fine
            pass
        elif re.match(r'\s*\d+:', fixed_line):
            fixed_line = re.sub(r'^(\s*)(\d+):', r'\1case \2:', fixed_line)
        
        fixed_lines.append(fixed_line)
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(fixed_lines)
    
    print(f"Fixed bracket errors in {file_path}")

def main():
    """Main function to fix all files in Group 1"""
    
    base_path = "/Users/jacobmac/Desktop/Dev/fortune"
    
    files_to_fix = [
        "lib/features/fortune/presentation/widgets/tarot_card_detail_modal.dart",
        "lib/features/fortune/presentation/pages/network_report_fortune_page.dart",
        "lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart",
        "lib/features/fortune/presentation/pages/wealth_fortune_page.dart",
        "lib/features/fortune/presentation/pages/mbti_fortune_page.dart",
        "lib/features/fortune/presentation/pages/saju_page.dart",
        "lib/features/fortune/presentation/pages/blood_type_fortune_page.dart"
    ]
    
    for file_path in files_to_fix:
        full_path = os.path.join(base_path, file_path)
        if os.path.exists(full_path):
            fix_bracket_errors(full_path)
        else:
            print(f"File not found: {full_path}")

if __name__ == "__main__":
    main()