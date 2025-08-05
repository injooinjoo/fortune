#!/usr/bin/env python3

import os
import re

def fix_fortune_routes():
    """Fix fortune_routes.dart syntax errors"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove the extra comma and semicolon at the end
    content = re.sub(r'\]\);\s*,', ']);', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def fix_fortune_explanation_bottom_sheet():
    """Fix fortune_explanation_bottom_sheet.dart syntax errors"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Fix common issues
        # Fix property name issues
        if 'col:' in line and ('color' not in line or 'Color' not in line):
            line = line.replace('col:', 'color:')
        if 'heigh:' in line:
            line = line.replace('heigh:', 'height:')
        if 'widt:' in line:
            line = line.replace('widt:', 'width:')
        if 'lef:' in line and 'left:' not in line:
            line = line.replace('lef:', 'left:')
        if 'righ:' in line and 'right:' not in line:
            line = line.replace('righ:', 'right:')
        if 'botto:' in line and 'bottom:' not in line:
            line = line.replace('botto:', 'bottom:')
        if 'to,' in line and 'top:' not in line and 'const EdgeInsets.only(to' in line:
            line = line.replace('to,', 'top:')
        
        # Fix withValues issues
        if '.withValues(alpha' in line and 'a:' in line:
            line = re.sub(r'\.withValues\(alpha\s+a:', '.withValues(alpha:', line)
        if '.withValues(alp,' in line:
            line = line.replace('.withValues(alp,', '.withValues(alpha:')
        if 'ha:' in line and 'alpha' in line:
            line = line.replace('ha:', ':')
            
        # Fix other syntax issues
        if 'BoxConstraints(maxWidt,' in line:
            line = line.replace('BoxConstraints(maxWidt,', 'BoxConstraints(maxWidth:')
        if 'h: 180)' in line:
            line = line.replace('h: 180)', ': 180)')
            
        # Fix missing parentheses and brackets
        if line.strip().endswith('),') and i + 1 < len(lines):
            next_line = lines[i+1].strip()
            if next_line.startswith(']') or next_line.startswith(')'):
                line = line.rstrip()[:-1] + '\n'
                
        # Fix specific widget issues
        if 'error:' in line.lower() and 'err:' not in line:
            line = line.replace('err:', 'error:')
            
        fixed_lines.append(line)
    
    # Join and write back
    content = ''.join(fixed_lines)
    
    # Fix multiline issues
    content = re.sub(r'Theme\.of\(context,\.', 'Theme.of(context).', content)
    content = re.sub(r'MediaQuery\.of\(context,\.', 'MediaQuery.of(context).', content)
    content = re.sub(r'Navigator\.of\(context,\.', 'Navigator.of(context).', content)
    
    # Fix specific widget closing issues
    content = re.sub(r'\)\);\s*\)\);\s*\]\);\s*\)\);\s*\}\s*,', '))]),', content)
    
    # Fix missing closing parentheses
    content = re.sub(r'Icon\([^)]+\);\s*$', lambda m: m.group(0).replace(');', '),'), content, flags=re.MULTILINE)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def fix_physiognomy_fortune_page():
    """Fix physiognomy_fortune_page.dart syntax errors"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the eyebrowTypes closing bracket
    content = re.sub(
        r"final Map<String, String> _eyebrowTypes = \{[^}]+",
        lambda m: m.group(0) + '\n  };' if not m.group(0).endswith('}') else m.group(0),
        content,
        count=1
    )
    
    # Fix other issues
    lines = content.split('\n')
    fixed_lines = []
    in_map = False
    
    for i, line in enumerate(lines):
        if 'final Map<String, String>' in line and '{' in line:
            in_map = True
        elif in_map and '};' in line:
            in_map = False
            
        # Fix missing closing brackets
        if i > 0 and '_eyeTypes' in lines[i] and 'final Map' in lines[i]:
            if not lines[i-1].strip().endswith('};'):
                fixed_lines[-1] = fixed_lines[-1].rstrip() + '\n  };\n'
                
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def main():
    """Run all fixes"""
    print("Fixing all syntax errors...")
    
    try:
        fix_fortune_routes()
    except Exception as e:
        print(f"Error fixing fortune_routes.dart: {e}")
    
    try:
        fix_fortune_explanation_bottom_sheet()
    except Exception as e:
        print(f"Error fixing fortune_explanation_bottom_sheet.dart: {e}")
    
    try:
        fix_physiognomy_fortune_page()
    except Exception as e:
        print(f"Error fixing physiognomy_fortune_page.dart: {e}")
    
    print("All fixes completed!")

if __name__ == "__main__":
    main()