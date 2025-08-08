#!/usr/bin/env python3
import re

def fix_dart_syntax(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix Container() patterns that should be Container(
    content = re.sub(r'Container\(\)\s*(?=[a-z])', 'Container(\n            ', content)
    content = re.sub(r'GlassContainer\(\)\s*(?=[a-z])', 'GlassContainer(\n              ', content)
    content = re.sub(r'BoxDecoration\(\)\s*(?=[a-z])', 'BoxDecoration(\n              ', content)
    content = re.sub(r'AnimatedContainer\(\)\s*(?=[a-z])', 'AnimatedContainer(\n                          ', content)
    content = re.sub(r'Text\(\)\s*(?=[\'""])', 'Text(\n                ', content)
    
    # Fix specific patterns
    # Fix element data dictionary syntax
    content = content.replace("'meaning',", "'meaning':")
    content = content.replace("'description',", "'description':")
    
    # Fix color issues
    content = content.replace("(data['color'],", "data['color'] as Color,")
    content = content.replace("(data['color']]),", "(data['color'] as Color).withOpacity(0.1)],")
    
    # Fix element icon issue  
    content = content.replace("TarotHelper.getElementIcon(element ?? ''$1',", "TarotHelper.getElementIcon(element ?? ''),")
    
    # Fix missing closing parentheses
    content = re.sub(r'(\s+child: Text\([^)]+\))(?!\))', r'\1)', content)
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed syntax in {file_path}")

if __name__ == "__main__":
    fix_dart_syntax("/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/tarot_card_detail_modal.dart")