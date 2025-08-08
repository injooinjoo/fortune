#!/usr/bin/env python3

import re
import os

def fix_dart_syntax_errors(content):
    """Fix common Dart syntax errors in the content."""
    
    # Fix trailing commas and misplaced parentheses
    content = re.sub(r',\)', ')', content)
    content = re.sub(r',\]', ']', content)
    content = re.sub(r',\}', '}', content)
    
    # Fix TextStyle issues with copyWith
    content = re.sub(r'\.copyWith\(\)\s*([^)]+)\)', r'.copyWith(\1))', content)
    
    # Fix misplaced commas in widget trees
    content = re.sub(r'\]\)\),;', ']))', content)
    content = re.sub(r'\)\),;', '))', content)
    content = re.sub(r'\),;', ')', content)
    
    # Fix case statement issues
    content = re.sub(r'case,\s*(\d+):', r'case \1:', content)
    
    # Fix Korean text that should be in strings
    content = re.sub(r"'([^']+)',\)", r"'\1')", content)
    
    # Fix TextStyle copyWith patterns
    content = re.sub(r'style:\s*Theme\.of\(context\)\.textTheme\.\w+\?\.\s*copyWith\(\)\s*([^)]+)\)\s*,\s*([^)]+)\)', 
                    r'style: Theme.of(context).textTheme.\w+?.copyWith(\1, \2))', content)
    
    # Fix multiple closing brackets
    content = re.sub(r'\)\)\),;', ')))', content)
    content = re.sub(r'\]\)\]\)\),;', '])]))', content)
    
    # Fix missing closing parentheses for Curves
    content = re.sub(r'(Curves\.\w+);', r'\1))', content)
    
    # Fix missing commas in lists
    content = re.sub(r'(\])(\s+)([A-Z])', r'\1,\2\3', content)
    content = re.sub(r'(\))(\s+)(Expanded|Container|GestureDetector|AnimatedContainer|Row|Column|Text|Icon|SizedBox)', 
                    r'\1,\2\3', content)
    
    # Fix TextStyle issues
    content = re.sub(r'Theme\.of\(context\)\.textTheme\.(\w+)\]', r'Theme.of(context).textTheme.\1', content)
    
    # Fix list literal syntax
    content = re.sub(r"\\?\['?\[?'", "[", content)
    
    # Fix missing semicolons
    content = re.sub(r'(\w+)\(\)\s*}', r'\1();\n  }', content)
    
    # Fix if statement with wrong comma
    content = re.sub(r'if\s*\([^)]+\),\s*\.\.\.', r'if (\1) ...', content)
    
    # Fix widget tree ending issues
    content = re.sub(r'}\),\s*;', '})', content)
    content = re.sub(r'\)\]\)\),\s*;', ')])', content)
    
    # Fix duration issues
    content = re.sub(r'Duration\(days:\s*365\),\s*', r'Duration(days: 365))', content)
    content = re.sub(r'Duration\(days:\s*365\),;', r'Duration(days: 365))', content)
    
    # Fix return statement issues
    content = re.sub(r'}\s+}\s+}$', '  }\n}', content)
    
    # Fix misplaced closing brackets at the end of build methods
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Fix specific TextStyle patterns
        if 'textTheme.' in line and ']' in line and not '[' in line:
            line = line.replace(']', '')
            
        # Fix specific copyWith patterns  
        if '.copyWith()' in line and i + 1 < len(lines):
            next_line = lines[i + 1]
            if 'fontWeight:' in next_line or 'color:' in next_line:
                # Merge the lines properly
                indent = len(line) - len(line.lstrip())
                line = line.replace('.copyWith()', '.copyWith(')
                
        # Fix case statements
        if re.match(r'\s*case,\s*\d+:', line):
            line = re.sub(r'case,\s*(\d+):', r'case \1:', line)
            
        # Fix trailing commas in wrong places
        if line.strip().endswith(',;'):
            line = line.replace(',;', ';')
        if line.strip().endswith('),;'):
            line = line.replace('),;', ');')
        if line.strip().endswith(')),;'):
            line = line.replace(')),;', '));')
            
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    return content

def process_file(file_path):
    """Process a single Dart file to fix syntax errors."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Apply fixes
        fixed_content = fix_dart_syntax_errors(content)
        
        # Write back
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)
        
        print(f"✅ Fixed: {os.path.basename(file_path)}")
        return True
    except Exception as e:
        print(f"❌ Error processing {os.path.basename(file_path)}: {e}")
        return False

def main():
    """Main function to process all widget/chart files."""
    
    base_path = "/Users/jacobmac/Desktop/Dev/fortune"
    
    files = [
        "lib/features/fortune/presentation/widgets/blood_type_personality_chart.dart",
        "lib/features/fortune/presentation/pages/base_fortune_page.dart",
        "lib/features/fortune/presentation/widgets/mbti_compatibility_matrix.dart",
        "lib/features/fortune/presentation/widgets/zodiac_element_chart.dart",
        "lib/features/fortune/presentation/widgets/five_elements_balance_chart.dart",
        "lib/features/fortune/presentation/widgets/cognitive_functions_radar_chart.dart",
        "lib/features/fortune/presentation/widgets/hourly_fortune_chart.dart",
        "lib/features/fortune/presentation/widgets/career_fortune_selector.dart",
        "lib/features/fortune/presentation/widgets/fortune_display.dart"
    ]
    
    success_count = 0
    
    for file_path in files:
        full_path = os.path.join(base_path, file_path)
        if os.path.exists(full_path):
            if process_file(full_path):
                success_count += 1
        else:
            print(f"⚠️  File not found: {file_path}")
    
    print(f"\n✨ Processed {success_count}/{len(files)} files successfully")

if __name__ == "__main__":
    main()