#!/usr/bin/env python3
import re

def fix_brackets(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Track opening and closing brackets
    stack = []
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Count brackets in this line
        opens = line.count('(') + line.count('[') + line.count('{')
        closes = line.count(')') + line.count(']') + line.count('}')
        
        # Check for specific patterns that need fixing
        # Pattern 1: Missing closing parentheses for widget calls
        if 'child: Text(' in line and line.count('(') > line.count(')'):
            # Add missing closing parentheses
            line = line.rstrip()
            missing = line.count('(') - line.count(')')
            line = line + ')' * missing + '\n'
        
        # Pattern 2: Missing closing for BoxDecoration
        if 'BoxDecoration(' in line and line.count('(') > line.count(')'):
            line = line.rstrip()
            missing = line.count('(') - line.count(')')
            line = line + ')' * missing + '\n'
            
        # Pattern 3: Missing closing for Container
        if 'Container(' in line or 'GlassContainer(' in line:
            if line.count('(') > line.count(')'):
                line = line.rstrip()
                missing = line.count('(') - line.count(')')
                line = line + ')' * missing + '\n'
        
        # Pattern 4: Fix lines ending with unmatched brackets
        if line.strip().endswith('),') or line.strip().endswith('));'):
            # Count all brackets in the line
            open_count = line.count('(')
            close_count = line.count(')')
            if open_count < close_count:
                # Too many closing parentheses
                excess = close_count - open_count
                # Remove excess closing parentheses from the end
                stripped = line.rstrip()
                for _ in range(excess):
                    if stripped.endswith('),'):
                        stripped = stripped[:-2] + ','
                    elif stripped.endswith('));'):
                        stripped = stripped[:-3] + ');'
                    elif stripped.endswith(')'):
                        stripped = stripped[:-1]
                line = stripped + '\n'
        
        fixed_lines.append(line)
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(fixed_lines)
    
    print(f"Fixed brackets in {file_path}")

if __name__ == "__main__":
    fix_brackets("/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/tarot_card_detail_modal.dart")