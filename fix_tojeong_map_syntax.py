#!/usr/bin/env python3

import re

def fix_tojeong_map_syntax():
    file_path = '/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tojeong_fortune_page.dart'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix comma to colon in Map definitions
    # Look for patterns like 'key', 'value' and replace with 'key': 'value'
    
    # First, let's fix the specific hexagram definitions
    hexagram_pattern = r"'(name|symbol|meaning|description|element|color)', (.+?)([,}])"
    
    def replace_comma_with_colon(match):
        key = match.group(1)
        value = match.group(2)
        ending = match.group(3)
        return f"'{key}': {value}{ending}"
    
    content = re.sub(hexagram_pattern, replace_comma_with_colon, content)
    
    # Also fix the closing brackets for the hexagram map
    content = re.sub(r"'color': null\}\};\s*$", "'color': null}\n  };", content, flags=re.MULTILINE)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed map syntax in {file_path}")

if __name__ == "__main__":
    fix_tojeong_map_syntax()