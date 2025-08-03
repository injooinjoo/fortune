#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart', 'r') as f:
    lines = f.readlines()

# Process line by line to fix common patterns
fixed_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # Skip empty lines at the end
    if i == len(lines) - 1 and line.strip() == '':
        i += 1
        continue
    
    # Fix specific patterns
    
    # Fix line 39: enableDrag: true),
    if 'enableDrag: true),' in line:
        line = '      enableDrag: true,\n'
    
    # Fix line 40: builder: (context) => SajuElementExplanationBottomSheet(,
    elif 'builder: (context) => SajuElementExplanationBottomSheet(,' in line:
        line = '      builder: (context) => SajuElementExplanationBottomSheet(\n'
    
    # Fix line 45: ))
    elif i > 0 and 'elementType: elementType,' in lines[i-1] and line.strip() == '))':
        line = '      ),\n    );\n'
    
    # Fix line 61: vsync: this),
    elif 'vsync: this),' in line:
        line = '      vsync: this,\n'
    
    # Fix line 62-63
    elif 'duration: AppAnimations.durationMedium' in line and i > 0 and 'vsync: this,' in lines[i-1]:
        line = '      duration: AppAnimations.durationMedium,\n'
    
    # Fix line 121: animation: _animationController),
    elif 'animation: _animationController),' in line:
        line = '      animation: _animationController,\n'
    
    # Fix line 122: builder: (context, child) {
    elif 'builder: (context, child) {' in line and i > 0 and 'animation: _animationController,' in lines[i-1]:
        line = '      builder: (context, child) {\n'
    
    # Fix line 125-127: decoration syntax
    elif 'decoration: BoxDecoration(' in line and i > 0 and 'height: screenHeight * 0.85,' in lines[i-1]:
        line = '          decoration: BoxDecoration(\n'
    
    # Fix line 128: borderRadius: const BorderRadius.only(,
    elif 'borderRadius: const BorderRadius.only(,' in line:
        line = '            borderRadius: const BorderRadius.only(\n'
    
    # Fix line 131: boxShadow: [
    elif line.strip() == 'boxShadow: [' and i > 0 and 'topRight: Radius.circular(24),' in lines[i-1]:
        line = '            ),\n            boxShadow: [\n'
    
    # Fix line 136: offset: const Offset(0, -5))
    elif 'offset: const Offset(0, -5))' in line:
        line = '                offset: const Offset(0, -5),\n              ),\n'
    
    # Fix line 137: ]),
    elif line.strip() == ']),':
        line = '            ],\n          ),\n'
    
    # Fix line 138: child: Column(
    elif 'child: Column(' in line and i > 0 and '],' in lines[i-1]:
        line = '          child: Column(\n'
    
    # Fix line 139: children: [
    elif line.strip() == 'children: [' and i > 0 and 'child: Column(' in lines[i-1]:
        line = '            children: [\n'
    
    # Fix line 144: duplicate controller
    elif 'controller: _scrollController,' in line and i > 0 and 'controller: _scrollController,' in lines[i-1]:
        i += 1  # Skip duplicate line
        continue
    
    # Fix line 172: },)
    elif line.strip() == '},)':
        line = '    );\n'
    
    # Fix line 173: }
    elif line.strip() == '}' and i > 0 and '};' in lines[i-1]:
        i += 1  # Skip extra brace
        continue
    
    # Fix line 196: decoration: BoxDecoration(
    elif 'decoration: BoxDecoration(' in line and 'paddingAll20' in lines[i-1]:
        line = '      decoration: BoxDecoration(\n'
    
    # Fix line 197-204: gradient syntax
    elif 'gradient: LinearGradient(' in line:
        line = '        gradient: LinearGradient(\n'
    elif line.strip() == 'colors: [':
        line = '          colors: [\n'
    elif ']' in line and i > 0 and 'alpha: 0.05),' in lines[i-1]:
        line = '          ],\n'
    elif 'begin: Alignment.topCenter' in line:
        line = '          begin: Alignment.topCenter,\n'
    
    # Fix line 205: ,,
    elif line.strip() == '),,':
        line = '        ),\n      ),\n'
    
    # Fix IconButton.styleFrom syntax
    elif 'style: IconButton.styleFrom(,' in line:
        line = '                style: IconButton.styleFrom(\n'
    
    # Fix various closing parentheses patterns
    elif '))))' in line and not '.animate()' in line:
        # Count the context to determine proper closing
        line = line.replace('))))', '),\n              ),\n            ),\n          ),')
    
    # Fix withValues patterns
    line = re.sub(r'withValues\(alph,\s*a:', 'withValues(alpha:', line)
    line = re.sub(r'withValues\(alp,\s*ha:', 'withValues(alpha:', line)
    
    # Fix EdgeInsets patterns  
    line = re.sub(r'EdgeInsets\.only\(botto,\s*m:', 'EdgeInsets.only(bottom:', line)
    line = re.sub(r'EdgeInsets\.symmetric\(vertica,\s*l:', 'EdgeInsets.symmetric(vertical:', line)
    
    # Fix widget patterns
    line = re.sub(r'child: Row\(,', 'child: Row(', line)
    line = re.sub(r'child: Column\(,', 'child: Column(', line)
    line = re.sub(r'decoration: BoxDecoration\(,', 'decoration: BoxDecoration(', line)
    line = re.sub(r'Border\.all\(,', 'Border.all(', line)
    line = re.sub(r'Container\(,', 'Container(', line)
    line = re.sub(r'Padding\(,', 'Padding(', line)
    
    # Fix various style closing patterns
    if 'style: theme.textTheme' in line and line.strip().endswith(')'):
        if not line.strip().endswith('),') and not line.strip().endswith(');'):
            line = line.rstrip() + ',\n'
    
    # Fix Icon widget patterns
    if 'size: AppDimensions.iconSize' in line and line.strip().endswith(')'):
        if ');' in line:
            line = line.replace(');', ',\n              ),')
    
    # Fix missing commas after widgets
    if line.strip().endswith(')') and i + 1 < len(lines):
        next_line = lines[i + 1].strip()
        if next_line and not next_line.startswith(')') and not next_line.startswith(']') and not next_line.startswith('}') and not next_line.startswith('.') and not next_line.startswith(','):
            if not line.strip().endswith('),') and not line.strip().endswith(');'):
                line = line.rstrip() + ',\n'
    
    fixed_lines.append(line)
    i += 1

# Write back
with open('lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart', 'w') as f:
    f.writelines(fixed_lines)

print("Fixed syntax errors in saju_element_explanation_bottom_sheet.dart")