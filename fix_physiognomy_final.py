#!/usr/bin/env python3

import re

def fix_physiognomy_final():
    """Final comprehensive fix for physiognomy_fortune_page.dart"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix duplicate closing bracket
    content = content.replace("  };\n\n  };", "  };")
    
    # Fix missing closing brackets and parentheses
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Fix widget tree structure
        if 'mainAxisAlignment: MainAxisAlignment.center);' in line:
            line = line.replace('mainAxisAlignment: MainAxisAlignment.center);', 'mainAxisAlignment: MainAxisAlignment.center,')
        
        # Fix missing closing brackets in _buildAnalysisScore calls
        if "_buildAnalysisScore('복운', 85, '재물과 성공운이 강합니다'," in line:
            line = "_buildAnalysisScore('복운', 85, '재물과 성공운이 강합니다'),"
        if "_buildAnalysisScore('인연운', 75, '좋은 사람들과의 만남이 예상됩니다'," in line:
            line = "_buildAnalysisScore('인연운', 75, '좋은 사람들과의 만남이 예상됩니다'),"
        if "_buildAnalysisScore('건강운', 80, '타고난 건강 체질입니다'," in line:
            line = "_buildAnalysisScore('건강운', 80, '타고난 건강 체질입니다'),"
        if "_buildAnalysisScore('직업운', 90, '리더십과 창의성이 뛰어납니다')))" in line:
            line = "_buildAnalysisScore('직업운', 90, '리더십과 창의성이 뛰어납니다')"
        
        # Fix closing bracket sequence after _buildAnalysisScore
        if line.strip() == "_buildAnalysisScore('직업운', 90, '리더십과 창의성이 뛰어납니다')));),":
            line = "            _buildAnalysisScore('직업운', 90, '리더십과 창의성이 뛰어납니다')\n          ]\n        )\n      );"
        
        # Fix Text widget closing
        if 'label);' in line and 'Text(' in line:
            line = line.replace('label);', 'label,')
        if 'description);' in line and 'Text(' in line:
            line = line.replace('description);', 'description,')
        
        # Fix Map syntax in traits
        if "'name': '리더십',  , 'icon':" in line:
            line = line.replace("'name': '리더십',  , 'icon':", "'name': '리더십', 'icon':")
        if "'name': '창의성',  , 'icon':" in line:
            line = line.replace("'name': '창의성',  , 'icon':", "'name': '창의성', 'icon':")
        if "'name': '공감능력',  , 'icon':" in line:
            line = line.replace("'name': '공감능력',  , 'icon':", "'name': '공감능력', 'icon':")
        if "'name': '분석력',  , 'icon':" in line:
            line = line.replace("'name': '분석력',  , 'icon':", "'name': '분석력', 'icon':")
        
        # Fix closing bracket for traits list
        if "'color': Colors.orange}]" in line:
            line = line.replace("'color': Colors.orange}]", "'color': Colors.orange}];")
        
        # Fix Map syntax in features
        if "'fortune', '새로운 지식과 기회가 찾아올 것입니다.'," in line:
            line = line.replace("'fortune', '새로운 지식과 기회가 찾아올 것입니다.',", "'fortune': '새로운 지식과 기회가 찾아올 것입니다.',")
        
        # Fix closing bracket for features list
        if "'icon': Icons.lightbulb_rounded}]" in line:
            line = line.replace("'icon': Icons.lightbulb_rounded}]", "'icon': Icons.lightbulb_rounded}];")
        
        # Fix Map syntax in advices
        if "final advices = [" in line:
            line = "    final advices = ["
        if "'color': Colors.blue}" in line and '];' not in line:
            line = line.replace("'color': Colors.blue}", "'color': Colors.blue}];")
        
        # Fix padding issues
        if "const EdgeInsets.all(16," in line:
            line = line.replace("const EdgeInsets.all(16,", "const EdgeInsets.all(16),")
        if "const EdgeInsets.symmetric(horizontal: 16)," in line:
            line = line.replace("const EdgeInsets.symmetric(horizontal: 16),", "const EdgeInsets.symmetric(horizontal: 16,")
        
        # Fix style property closing
        if "style: theme.textTheme.bodyLarge?.copyWith(" in line and "fontWeight: FontWeight.bold)))" in lines[i+1] if i+1 < len(lines) else "":
            # Don't modify this line, handle in next iteration
            pass
        if "fontWeight: FontWeight.bold)))" in line and "," not in line:
            line = line.replace("fontWeight: FontWeight.bold)))", "fontWeight: FontWeight.bold)),")
        
        # Fix semicolon issues
        if "color: color);" in line and "," not in line:
            line = line.replace("color: color);", "color: color,")
        if "size: 28)," in line and "color: trait['color']" in lines[i+1] if i+1 < len(lines) else "":
            line = line.replace("size: 28),", "size: 28,")
        
        # Fix specific widget tree closing issues
        if ",.toList())));" in line:
            line = "            )).toList()\n          ]\n        )\n      );"
        
        # Fix specific Map access issues
        if "'→ ${item['fortune']}');" in line:
            line = line.replace("'→ ${item['fortune']}');", "'→ ${item['fortune']}',")
        
        # Fix widget property closing
        if "color: theme.colorScheme.primary)," in line and "fontWeight:" in lines[i+1] if i+1 < len(lines) else "":
            line = line.replace("color: theme.colorScheme.primary),", "color: theme.colorScheme.primary,")
        
        # Fix specific padding issue
        if "padding: const EdgeInsets.all(20)," in line and "child: Column(" in lines[i+1] if i+1 < len(lines) else "":
            line = "        padding: const EdgeInsets.all(20),"
        
        # Fix dropdown closing
        if "contentPadding: const EdgeInsets.symmetric(horizontal: 16), vertical: 12))," in line:
            line = line.replace("contentPadding: const EdgeInsets.symmetric(horizontal: 16), vertical: 12)),", "contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),")
        
        # Fix widget tree closing at end of methods
        if ",.toList())));" in line:
            line = "            )).toList()\n          ]\n        )\n      );"
        
        # Fix _buildAnalysisScore invocations
        if line.strip().startswith("_buildAnalysisScore(") and not line.strip().endswith("),") and not line.strip().endswith(")"):
            if "," in line:
                # This is a continuation
                pass
            else:
                line = line.rstrip() + "),"
        
        fixed_lines.append(line)
    
    # Join content
    content = '\n'.join(fixed_lines)
    
    # Final fixes
    content = re.sub(r'\)\)\)\)\),', '))\n          ]\n        )\n      );', content)
    content = re.sub(r'\)\)\)\)\)\),', '))\n            ]\n          )\n        );', content)
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Final comprehensive fix applied to {file_path}")

if __name__ == "__main__":
    fix_physiognomy_final()