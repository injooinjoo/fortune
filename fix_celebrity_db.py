#!/usr/bin/env python3
import re

def fix_celebrity_database():
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/data/constants/celebrity_database.dart', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix patterns one by one
    # 1. Fix id: 'xxx'); to id: 'xxx',
    content = re.sub(r"id: '([^']+)'\);", r"id: '\1',", content)
    
    # 2. Fix name: 'xxx': null, to name: 'xxx',
    content = re.sub(r"name: '([^']+)': null,", r"name: '\1',", content)
    
    # 3. Fix nameEn: 'xxx'), to nameEn: 'xxx',
    content = re.sub(r"nameEn: '([^']+)'\),", r"nameEn: '\1',", content)
    
    # 4. Fix category: XXX), to category: XXX,
    content = re.sub(r"(category: [^,\)]+)\),", r"\1,", content)
    
    # 5. Fix gender: XXX), to gender: XXX,
    content = re.sub(r"(gender: [^,\)]+)\),", r"\1,", content)
    
    # 6. Fix birthDate: DateTime(...)), to birthDate: DateTime(...),
    content = re.sub(r"(birthDate: DateTime\([^)]+\))\),", r"\1,", content)
    
    # 7. Fix description: 'xxx'), to description: 'xxx',
    content = re.sub(r"(description: '[^']+')\),", r"\1,", content)
    
    # 8. Fix keywords arrays with colons to commas
    content = re.sub(r"\['([^']+)': '([^']+)': '([^']+)'\]", r"['\1', '\2', '\3']", content)
    content = re.sub(r"\['([^']+)': '([^']+)'\]", r"['\1', '\2']", content)
    
    # 9. Fix indentation - change all lines starting with 4 spaces to 6 spaces for properties
    lines = content.split('\n')
    fixed_lines = []
    in_celebrity = False
    
    for line in lines:
        if 'Celebrity(' in line:
            in_celebrity = True
            fixed_lines.append(line)
        elif in_celebrity and line.startswith('    ') and not line.strip().startswith('Celebrity'):
            # Change 4-space indent to 6-space for properties
            fixed_lines.append('  ' + line)
        else:
            if '),\n' in line or '),' in line:
                in_celebrity = False
            fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    # 10. Ensure all Celebrity objects end with ),
    content = re.sub(r"(keywords: \[[^\]]+\]),\n(\s+Celebrity\()", r"\1,\n    ),\n\2", content)
    
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/data/constants/celebrity_database.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed celebrity database file")

if __name__ == "__main__":
    fix_celebrity_database()