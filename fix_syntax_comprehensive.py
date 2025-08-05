#!/usr/bin/env python3

import re
import os

def fix_fortune_explanation_bottom_sheet():
    """Fix fortune_explanation_bottom_sheet.dart syntax issues"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix escape issues in strings
    content = re.sub(r"\\\\'", "'", content)
    content = re.sub(r'\\\\\\$\{', '${', content)
    
    # Fix .withValues issues
    content = re.sub(r'\.withValues\s*\(\s*alp:', '.withValues(alpha:', content)
    content = re.sub(r'\.withValues\s*\(\s*alpha\s+alp:', '.withValues(alpha:', content)
    
    # Fix specific syntax issues
    content = re.sub(r'color: theme\.colorScheme\.primary\.withValues\(alpha\s+alp:', 
                     'color: theme.colorScheme.primary.withValues(alpha:', content)
    
    # Fix checkmarkCol
    content = re.sub(r'checkmarkCol:', 'checkmarkColor:', content)
    
    # Fix foregroundCol
    content = re.sub(r'foregroundCol:', 'foregroundColor:', content)
    content = re.sub(r'backgroundCol:', 'backgroundColor:', content)
    
    # Fix horizont
    content = re.sub(r'horizont,', 'horizontal', content)
    content = re.sub(r'horizontal:', 'horizontal,', content)
    content = re.sub(r'padding: EdgeInsets\.symmetric\(horizontal\s+alpha:', 
                     'padding: EdgeInsets.symmetric(horizontal:', content)
    
    # Fix specific widget issues
    content = re.sub(r"'\\$\{explanation\['title'\]\} 안내'", 
                     "'${explanation['title']} 안내'", content)
    
    # Fix missing commas and brackets
    content = re.sub(r'Text\(\s*label\);', 'Text(label),', content)
    content = re.sub(r'fontWeight: FontWeight\.bold\)\)\),', 'fontWeight: FontWeight.bold)),', content)
    
    # Fix dropdown issues
    content = re.sub(r'style: theme\.textTheme\.bodyLarge\?\.copyWith\(\s*fontWeight: FontWeight\.bold\)\)\),', 
                     'style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),', content)
    
    # Fix height issues
    content = re.sub(r'height: AppDimensions\.buttonHeightSmall\),', 
                     'height: AppDimensions.buttonHeightSmall,', content)
    
    # Fix borderRadius issues
    content = re.sub(r'borderRadius: AppDimensions\.borderRadiusMedium\),', 
                     'borderRadius: AppDimensions.borderRadiusMedium,', content)
    
    # Fix color issues
    content = re.sub(r"'수': null\}\,;", "'수': Colors.blue},", content)
    
    # Fix padding issues
    content = re.sub(r'padding: EdgeInsets\.symmetric\(horizont,\s*l:', 
                     'padding: EdgeInsets.symmetric(horizontal:', content)
    
    # Fix ha: issues
    content = re.sub(r'alpha\s+ha:', 'alpha:', content)
    content = re.sub(r':\s*ha:', ':', content)
    
    # Fix missing closing brackets
    lines = content.split('\n')
    fixed_lines = []
    bracket_stack = []
    
    for i, line in enumerate(lines):
        # Fix specific line issues
        if 'if (luckyItemExplanations.containsKey(' in line:
            if line.count('(') > line.count(')'):
                line = line.rstrip() + '))'
        
        if '_buildEnhancedLuckyItem(theme,' in line and line.count(']') > line.count('['):
            line = line.replace(']]', '])')
        
        if 'color: AppColors.warning),)' in line:
            line = line.replace('color: AppColors.warning),)', 'color: AppColors.warning),')
        
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def fix_physiognomy_fortune_page():
    """Fix physiognomy_fortune_page.dart syntax issues"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix Text widget issues
    content = re.sub(r'Text\(\s*label\);', 'Text(label),', content)
    
    # Fix style issues
    content = re.sub(r'style: theme\.textTheme\.bodyLarge\?\.copyWith\(\s*fontWeight: FontWeight\.bold\)\),\),', 
                     'style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),', content)
    
    # Fix Row widget issues
    content = re.sub(r'Row\(\s*mainAxisAlignment: MainAxisAlignment\.spaceBetween\);', 
                     'Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,', content)
    
    # Fix Icon widget issues
    content = re.sub(r'size: 20\),\s*color: theme\.colorScheme\.primary\),', 
                     'size: 20, color: theme.colorScheme.primary),', content)
    
    # Fix Map closing issues
    content = re.sub(r"'protruding': '돌출된 귀'\)\s*\(value\)", 
                     "'protruding': '돌출된 귀'},\n                (value)", content)
    content = re.sub(r"'rounded': '둥근 이마'\)\s*\(value\)", 
                     "'rounded': '둥근 이마'},\n                (value)", content)
    content = re.sub(r"'protruding': '나온 턱'\)\s*\(value\)", 
                     "'protruding': '나온 턱'},\n                (value)", content)
    
    # Fix Container issues
    content = re.sub(r'child: Container\(\s*children:', 'child: Container(\n        child: Column(\n          children:', content)
    
    # Fix color property
    content = re.sub(r'color: trait\[\\\'color\\\'\] as Color\),', 
                     'color: trait[\'color\'] as Color),', content)
    
    # Fix duplicate closing brackets in _buildPersonalityProfile
    content = re.sub(r'\)\s*\)\s*\);\s*\}\)\.toList\(\)\s*\]\s*\)\s*\);\s*\}', 
                     ');\n              }).toList()\n            ]\n          )\n        );\n  }', content)
    
    # Fix traits array closing
    content = re.sub(r"'color': Colors\.orange\}\s*\];", "'color': Colors.orange}\n    ];", content)
    
    # Fix specific widget tree issues
    lines = content.split('\n')
    fixed_lines = []
    in_personality_profile = False
    
    for i, line in enumerate(lines):
        # Track if we're in _buildPersonalityProfile
        if '_buildPersonalityProfile()' in line:
            in_personality_profile = True
        elif 'Widget _build' in line and in_personality_profile:
            in_personality_profile = False
        
        # Fix duplicate closing brackets in personality profile
        if in_personality_profile and line.strip() == ');' and i > 0:
            if fixed_lines[-1].strip() == ')':
                continue  # Skip duplicate closing parenthesis
        
        # Fix Icon size and color on separate lines
        if 'size: 28,' in line and i+1 < len(lines) and 'color: trait' in lines[i+1]:
            line = line.rstrip() + '\n                        color: trait[\'color\'] as Color),'
            lines[i+1] = ''  # Clear next line
        
        # Fix missing commas in advices list
        if "'color': Colors.blue}" in line and '];' not in line:
            line = line.rstrip() + ','
        
        # Fix Text style issues  
        if 'fontWeight: FontWeight.bold)),' in line and 'color:' in line:
            line = re.sub(r'fontWeight: FontWeight\.bold\)\),\s*color:', 
                         'fontWeight: FontWeight.bold,\n                            color:', line)
        
        # Fix duplicate widget tree closings
        if line.strip() == ')' and i > 0 and fixed_lines[-1].strip() == ')':
            if i+1 < len(lines) and lines[i+1].strip() == ');':
                continue
        
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def main():
    print("Applying comprehensive syntax fixes...")
    
    fix_fortune_explanation_bottom_sheet()
    fix_physiognomy_fortune_page()
    
    print("All fixes completed!")

if __name__ == "__main__":
    main()