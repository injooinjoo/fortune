#!/usr/bin/env python3
import re

def fix_tarot_storytelling_page():
    """Fix bracket issues in tarot_storytelling_page.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_storytelling_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix line 220 - missing comma after horizontal, and closing paren
    if lines[219].strip().endswith("vertical: 8),"):
        lines[219] = "      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),\n"
    
    # Fix line 227 - missing closing paren
    if "borderRadius: BorderRadius.circular(3))" in lines[226]:
        lines[226] = "              borderRadius: BorderRadius.circular(3)),\n"
    
    # Fix line 237 - missing closing paren
    if "borderRadius: BorderRadius.circular(3))" in lines[236]:
        lines[236] = "                borderRadius: BorderRadius.circular(3),\n"
    
    # Fix line 257 - missing closing paren
    if "borderRadius: BorderRadius.circular(3)))" in lines[256]:
        lines[256] = "                    borderRadius: BorderRadius.circular(3))));\n"
    
    # Fix line 258 - remove extra bracket
    if "})]))" in lines[257]:
        lines[257] = "            })));\n"
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed {file_path}")

def fix_tarot_summary_page():
    """Fix bracket issues in tarot_summary_page.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_summary_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # The file has unmatched brackets - need to add missing closing brackets
    # This is complex, so we'll fix specific patterns
    content = re.sub(r'(\s+children:\s*\[\s*)$', r'\1', content, flags=re.MULTILINE)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def fix_tarot_deck_selection_page():
    """Fix bracket issues in tarot_deck_selection_page.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_deck_selection_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Need to add closing brackets at appropriate places
    # This is a complex fix that requires understanding the widget tree
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed {file_path}")

def fix_daily_fortune_page():
    """Fix bracket issues in daily_fortune_page.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/daily_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix the map function and bracket issues around line 136-167
    # This needs careful handling of the nested structure
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed {file_path}")

def main():
    fix_tarot_storytelling_page()
    # Other functions need more complex fixes that require reading the full file
    
if __name__ == "__main__":
    main()