#!/usr/bin/env python3

import re
import os

def fix_fortune_explanation_bottom_sheet():
    """Comprehensive fix for fortune_explanation_bottom_sheet.dart"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix common issues
    # Fix horizont: to horizontal:
    content = re.sub(r'horizont:', 'horizontal:', content)
    
    # Fix string interpolation
    content = re.sub(r'\\\${', '${', content)
    
    # Fix missing closing brackets
    content = re.sub(r'borderRadius: BorderRadius\.circular\(AppDimensions\.radiusXSmall\)\)\);\s*\},', 
                     'borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall)\n      )\n    );\n  }', content)
    
    # Fix border issues
    content = re.sub(r'width: 1\)\),', 'width: 1\n                  )\n                )\n              ),', content)
    
    # Fix IconButton closing
    content = re.sub(r'shape: const CircleBorder\(\)\)\);\s*\},', 
                     'shape: const CircleBorder()\n            )\n          )\n        ]\n      )\n    );\n  }', content)
    
    # Fix alp: to alpha:
    content = re.sub(r'\.withValues\(alp:', '.withValues(alpha:', content)
    
    # Fix checkmarkColor
    content = re.sub(r'checkmarkCol:', 'checkmarkColor:', content)
    
    # Fix missing closing for _buildSection
    lines = content.split('\n')
    fixed_lines = []
    in_build_section = False
    bracket_count = 0
    
    for i, line in enumerate(lines):
        # Track if we're in a _buildSection method
        if '_buildSection(' in line:
            in_build_section = True
            bracket_count = 0
        
        if in_build_section:
            bracket_count += line.count('(') - line.count(')')
            bracket_count += line.count('[') - line.count(']')
            bracket_count += line.count('{') - line.count('}')
            
            if bracket_count == 0 and i > 0:
                in_build_section = False
        
        # Fix specific issues
        if 'explanation[\'title\']' in line:
            line = line.replace('explanation[\\\'title\\\']', 'explanation[\'title\']')
        
        if 'horizonta,' in line:
            line = line.replace('horizonta,', 'horizontal')
        
        if 'foregroundCol:' in line:
            line = line.replace('foregroundCol:', 'foregroundColor:')
        
        if 'borderRadius: AppDimensions.borderRadiusMedium),' in line:
            line = line.replace('borderRadius: AppDimensions.borderRadiusMedium),', 
                              'borderRadius: AppDimensions.borderRadiusMedium),')
        
        # Fix missing closing brackets for specific widgets
        if line.strip() == '});' and i > 0 and 'map(' in lines[i-1]:
            line = '            }).toList()\n          ]\n        );\n      }'
        
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    # Fix specific widget trees
    content = re.sub(r'}\)\.toList\(\)\]', '}).toList()]', content)
    
    # Fix missing commas
    content = re.sub(r'AppSpacing\.paddingAll16\)', 'AppSpacing.paddingAll16', content)
    content = re.sub(r'AppSpacing\.paddingAll12\)', 'AppSpacing.paddingAll12', content)
    content = re.sub(r'AppSpacing\.paddingAll8\)', 'AppSpacing.paddingAll8', content)
    
    # Fix color issues
    content = re.sub(r"'수': null},;", "'수': Colors.blue},", content)
    
    # Fix specific syntax issues
    content = re.sub(r'job\[\'type\'\] \?\? \'\'\),', "job['type'] ?? '',", content)
    content = re.sub(r'job\[\'activity\'\] \?\? \'\'', "job['activity'] ?? ''", content)
    
    # Fix p: AppSpacing issues
    content = re.sub(r'top:\s*p: AppSpacing', 'top: AppSpacing', content)
    
    # Fix $1 placeholders
    content = re.sub(r"''\$1", "''", content)
    content = re.sub(r"''\$1'", "''", content)
    
    # Fix ha: issues
    content = re.sub(r'alpha\s*ha:', 'alpha:', content)
    content = re.sub(r':\s*ha:', ':', content)
    
    # Fix borderRadius issues
    content = re.sub(r'borderRadius: AppDimensions\.borderRadiusMedium\)\)', 
                     'borderRadius: AppDimensions.borderRadiusMedium)', content)
    
    # Fix l: AppSpacing issues
    content = re.sub(r'horizont,\s*l:', 'horizontal:', content)
    content = re.sub(r'horizont,\s*al:', 'horizontal:', content)
    
    # Fix : at the beginning of lines
    content = re.sub(r'\n\s*:', '\n                alpha:', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

if __name__ == "__main__":
    fix_fortune_explanation_bottom_sheet()