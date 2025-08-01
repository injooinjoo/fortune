#!/usr/bin/env python3
import os
import re

def fix_syntax_errors(file_path):
    """Fix common syntax errors in a Dart file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 1. Fix semicolon followed by comma (;, → ;)
        content = re.sub(r';\s*,', ';', content)
        
        # 2. Fix missing commas in common patterns
        # Fix: ) followed by identifier or keyword (add comma)
        content = re.sub(r'\)\s+([a-zA-Z_][a-zA-Z0-9_]*\s*:)', r'),\n                \1', content)
        
        # 3. Fix double closing with comma patterns
        content = re.sub(r'\)\)\);,', '));', content)
        content = re.sub(r'\]\];,', ']];', content)
        content = re.sub(r'\}\};,', '}};', content)
        
        # 4. Fix createState patterns
        content = re.sub(r'createState\(\)\s*=>\s*([^;]+);,', r'createState() => \1;', content)
        
        # 5. Fix CurvedAnimation missing commas
        content = re.sub(r'(parent:\s*[^,)]+)\)\s*([a-zA-Z_])', r'\1,\n      \2', content)
        
        # 6. Fix trailing commas after statements
        content = re.sub(r'(super\.dispose\(\)|widget\.\w+\(\)|setState\(\{[^}]*\}\));,', r'\1;', content)
        
        # 7. Fix color constant missing semicolon
        content = re.sub(r"(Color\([^)]+\));,", r"\1,", content)
        
        # 8. Fix method body endings
        content = re.sub(r'\}\);,\s*\}', r'});\n  }', content)
        
        # 9. Fix array/list declarations with wrong ending
        content = re.sub(r'\]\);,', r']);', content)
        
        # 10. Fix builder pattern with missing commas
        content = re.sub(r'(\.\.\w+\s*=\s*[^,;)]+)\s+([a-zA-Z_])', r'\1,\n      \2', content)
        
        # 11. Fix Hero tag patterns
        content = re.sub(r'(tag:\s*[^,)]+)\)\s*(child:)', r'\1,\n              \2', content)
        
        # 12. Fix missing closing parentheses followed by comma
        content = re.sub(r'([^)]);,\s*\)', r'\1);', content)
        
        # 13. Fix async method bodies
        content = re.sub(r'(async\s*\{[^}]+\});,', r'\1;', content)
        
        # 14. Fix Widget build return patterns
        content = re.sub(r'(\)\s*\)\s*);,', r'\1;', content)
        
        # 15. Fix enum value declarations
        content = re.sub(r'(\([^)]+\));,\s*$', r'\1;', content, flags=re.MULTILINE)
        
        # 16. Fix constructor initialization lists
        content = re.sub(r'(:\s*super\([^)]*\));,', r'\1;', content)
        
        # Write back only if changes were made
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {str(e)}")
        return False

def main():
    # Read the file list
    file_list_path = '/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter/error_files_part2_v7.txt'
    
    try:
        with open(file_list_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: Could not find {file_list_path}")
        return
    
    # Extract file paths
    files = []
    for line in lines:
        line = line.strip()
        if line and line.endswith('.dart'):
            files.append(line)
    
    print(f"Found {len(files)} files to process")
    
    # Process each file
    fixed_count = 0
    for i, file_path in enumerate(files, 1):
        full_path = os.path.join('/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter', file_path)
        
        if os.path.exists(full_path):
            if fix_syntax_errors(full_path):
                fixed_count += 1
                print(f"[{i}/{len(files)}] Fixed: {file_path}")
            else:
                print(f"[{i}/{len(files)}] No changes: {file_path}")
        else:
            print(f"[{i}/{len(files)}] Not found: {file_path}")
    
    print(f"\nCompleted! Fixed {fixed_count}/{len(files)} files")

if __name__ == "__main__":
    main()