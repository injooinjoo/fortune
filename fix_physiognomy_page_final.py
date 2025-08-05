#!/usr/bin/env python3

import re

def fix_physiognomy_page():
    """Final comprehensive fix for physiognomy_fortune_page.dart"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the traits array closing issue
    content = re.sub(r"'color': Colors\.orange\}\s*\];\s*return", "'color': Colors.orange}\n    ];\n\n    return", content)
    
    # Fix missing closing brackets
    lines = content.split('\n')
    fixed_lines = []
    bracket_count = 0
    in_widget_tree = False
    
    for i, line in enumerate(lines):
        # Fix specific widget tree issues
        if 'children: [' in line:
            in_widget_tree = True
            bracket_count = 1
        
        if in_widget_tree:
            bracket_count += line.count('[') - line.count(']')
            bracket_count += line.count('(') - line.count(')')
            bracket_count += line.count('{') - line.count('}')
            
            if bracket_count == 0:
                in_widget_tree = False
        
        # Fix Icon widget
        if 'color: trait[\'color\'] as Color),' in line:
            line = line.replace('color: trait[\'color\'] as Color),', 'color: trait[\'color\'] as Color),')
        
        # Fix missing closing parentheses
        if line.strip() == 'textAlign: TextAlign.center)':
            line = '                        textAlign: TextAlign.center)\n                    )\n                  )\n                );'
        
        # Fix GridView.count syntax
        if 'shrinkWrap: true);' in line:
            line = line.replace('shrinkWrap: true);', 'shrinkWrap: true,')
        
        # Fix Map syntax in advices
        if "'color': Colors.blue}];" in line:
            line = line.replace("'color': Colors.blue}];", "'color': Colors.blue}\n    ];")
        
        # Fix widget closing
        if '}).toList()' in line and not line.strip().endswith(')'):
            if '_buildFortuneByFeature' in '\n'.join(lines[max(0,i-30):i]):
                line = '            }).toList()\n          ]\n        )\n      );'
            elif '_buildLifeAdvice' in '\n'.join(lines[max(0,i-30):i]):
                line = '            }).toList()\n          ]\n        )\n      );'
        
        # Fix specific method closing issues
        if 'fontWeight: FontWeight.w500))))' in line:
            line = line.replace('fontWeight: FontWeight.w500))))', 'fontWeight: FontWeight.w500)))')
        
        # Fix color issues
        if 'color: item[\'color\'])' in line:
            line = line.replace('color: item[\'color\'])', 'color: item[\'color\'] as Color)')
        
        # Fix Text widget closing
        if line.strip().endswith('style: theme.textTheme.bodyLarge?.copyWith('):
            if i+1 < len(lines) and 'fontWeight: FontWeight.bold))' in lines[i+1]:
                lines[i+1] = lines[i+1].replace('fontWeight: FontWeight.bold))', 'fontWeight: FontWeight.bold)),')
        
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    # Fix remaining issues
    content = re.sub(r'}\)\.toList\(\)\s*\]\s*\)\s*\);\s*}', '}).toList()\n            ]\n          )\n        );\n  }', content)
    
    # Ensure proper widget tree closing
    content = re.sub(r'textAlign: TextAlign\.center\)\)\)\)\);\s*}\)\.toList\(\)', 
                     'textAlign: TextAlign.center)\n                    )\n                  )\n                );\n              }).toList()', content)
    
    # Fix _buildAnalysisScore widget tree
    content = re.sub(r"_buildAnalysisScore\('직업운', 90, '리더십과 창의성이 뛰어납니다'\)\s*\]\s*\)\s*\);", 
                     "_buildAnalysisScore('직업운', 90, '리더십과 창의성이 뛰어납니다')\n          ]\n        )\n      );", content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

if __name__ == "__main__":
    fix_physiognomy_page()