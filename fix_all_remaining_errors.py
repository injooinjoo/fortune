#!/usr/bin/env python3

import re
import os

def fix_physiognomy_fortune_page_final():
    """Final fix for physiognomy_fortune_page.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix missing closing brackets and parentheses
    lines = content.split('\n')
    fixed_lines = []
    bracket_stack = []
    
    for i, line in enumerate(lines):
        # Track opening brackets
        for char in line:
            if char in '([{':
                bracket_stack.append(char)
            elif char in ')]}':
                if bracket_stack:
                    bracket_stack.pop()
        
        # Fix specific issues
        if 'Icons.lightbulb_rounded}];' in line:
            line = line.replace('Icons.lightbulb_rounded}];', 'Icons.lightbulb_rounded}\n    ];')
        
        # Fix widget tree closing
        if line.strip() == 'textAlign: TextAlign.center)));':
            line = '                        textAlign: TextAlign.center)\n                    )\n                  )\n                );'
        
        # Fix description semicolon
        if 'description);' in line and 'Text(' in line:
            line = line.replace('description);', 'description,')
        
        # Fix GridView.count issue
        if 'shrinkWrap: true);' in line:
            line = line.replace('shrinkWrap: true);', 'shrinkWrap: true,')
        
        # Fix Icon widget
        if 'size: 28,' in line and 'color: trait' in lines[i+1] if i+1 < len(lines) else False:
            line = line.replace('size: 28,', 'size: 28,')
            if i+1 < len(lines):
                lines[i+1] = lines[i+1].replace('color: trait[\'color\'] as Color),', '                        color: trait[\'color\'] as Color),')
        
        # Fix features map closing
        if "'fortune': '→ ${item['fortune']}','" in line:
            line = line.replace("'fortune': '→ ${item['fortune']}',", "'fortune': '→ ${item['fortune']}'")
        
        # Fix specific parentheses issues
        if 'fontWeight: FontWeight.bold)));' in line:
            line = line.replace('fontWeight: FontWeight.bold)));', 'fontWeight: FontWeight.bold));')
        
        # Fix Padding issue
        if 'padding: const EdgeInsets.all(16),' in line and 'child: GlassCard(' in lines[i+1] if i+1 < len(lines) else False:
            if i+1 < len(lines) and 'padding: const EdgeInsets.all(20),' not in lines[i+2]:
                lines[i+1] = lines[i+1].replace('child: GlassCard(', 'child: GlassCard(\n        padding: const EdgeInsets.all(20),')
        
        # Fix closing bracket for _buildFortuneByFeature
        if "}).toList()" in line and "_buildFortuneByFeature" in '\n'.join(lines[max(0,i-30):i]):
            line = "            }).toList()\n          ]\n        )\n      );"
        
        # Fix closing bracket for _buildLifeAdvice
        if "}).toList()" in line and "_buildLifeAdvice" in '\n'.join(lines[max(0,i-30):i]):
            line = "            }).toList()\n          ]\n        )\n      );"
        
        # Fix _buildAnalysisScore calls in widget tree
        if line.strip().startswith("_buildAnalysisScore('") and line.strip().endswith("'),"):
            # Already correct
            pass
        elif line.strip().startswith("_buildAnalysisScore('") and not line.strip().endswith("),"):
            line = line.rstrip()
            if line.endswith("')"):
                line = line[:-2] + "')"
        
        fixed_lines.append(line)
    
    # Join and write back
    content = '\n'.join(fixed_lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Final fix applied to {file_path}")

def fix_fortune_explanation_bottom_sheet_final():
    """Final fix for fortune_explanation_bottom_sheet.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix common issues
    # Fix checkmarkCol
    content = re.sub(r'checkmarkCol:', 'checkmarkColor:', content)
    
    # Fix $1 placeholders
    content = re.sub(r'\$1', '', content)
    
    # Fix .withValues issues
    content = re.sub(r'\.withValues\(alp:\s*', '.withValues(alpha: ', content)
    content = re.sub(r'ha:\s*0\.', ': 0.', content)
    
    # Fix BorderRadius issues
    content = re.sub(r'borderRadius: AppDimensions\.borderRadiusMedium,', 'borderRadius: AppDimensions.borderRadiusMedium),', content)
    
    # Fix specific syntax issues
    content = re.sub(r"'\\\$\{explanation\['title'\]\} 안내'", r"'${explanation[\'title\']} 안내'", content)
    
    # Fix missing commas
    content = re.sub(r'height: 100 \+ bottomPadding, // Add explicit height,', 'height: 100 + bottomPadding, // Add explicit height', content)
    
    # Fix barColor issues
    content = re.sub(r'barColor\);', 'barColor,', content)
    content = re.sub(r'barColor\.withValues\(alp: 0\.8\)\]\)', 'barColor.withValues(alpha: 0.8)])', content)
    
    # Fix specific widget issues
    content = re.sub(r'},\)\.toList\(\)\]', '}).toList()]', content)
    
    # Fix score display
    content = re.sub(r"'\\\$\{score\.toStringAsFixed\(0\)\}%'", r"'${score.toStringAsFixed(0)}%'", content)
    
    # Fix specific syntax errors
    content = re.sub(r'job\[\'type\'\] \?\? \'\'\),', 'job[\'type\'] ?? \'\',', content)
    content = re.sub(r'job\[\'activity\'\] \?\? \'\'', 'job[\'activity\'] ?? \'\'', content)
    
    # Fix Icon size
    content = re.sub(r'size: AppDimensions\.iconSizeXSmall\),', 'size: AppDimensions.iconSizeXSmall,', content)
    
    # Fix ha: issue
    content = re.sub(r'alpha\n\s*ha:', 'alpha:', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Final fix applied to {file_path}")

def main():
    print("Fixing all remaining Flutter syntax errors...")
    
    fix_physiognomy_fortune_page_final()
    fix_fortune_explanation_bottom_sheet_final()
    
    print("All fixes completed!")

if __name__ == "__main__":
    main()