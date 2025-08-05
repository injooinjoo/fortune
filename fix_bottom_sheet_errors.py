#!/usr/bin/env python3

import re
import os

def fix_bottom_sheet_syntax(file_path):
    """Fix syntax errors in fortune_explanation_bottom_sheet.dart"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix misplaced parentheses and brackets
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Fix common patterns
        line = re.sub(r'\)\)\]\)\)', '))', line)
        line = re.sub(r'\)\)\)\)', '))', line)
        line = re.sub(r'\]\]\)', '])', line)
        
        # Fix specific known issues
        if '_nameController)' in line and ',' not in line:
            line = line.replace('_nameController)', '_nameController,')
        
        if 'context)' in line and ', state' not in line and 'BuildContext' not in line:
            line = line.replace('context)', 'context,')
            
        if 'showDatePicker(' in line:
            line = line.replace('context)', 'context,')
            
        if 'DateTime.now();' in line:
            line = line.replace('DateTime.now();', 'DateTime.now(),')
            
        if 'child: InputDecorator(,' in line:
            line = line.replace('child: InputDecorator(,', 'child: InputDecorator(')
            
        if 'labelText: \'생년월일\')' in line:
            line = line.replace('labelText: \'생년월일\')', 'labelText: \'생년월일\',')
            
        if 'labelText: \'이름\',' in line:
            line = line.replace('labelText: \'이름\',', 'labelText: \'이름\',')
            
        if 'hintText: \'이름을 입력하세요\')' in line:
            line = line.replace('hintText: \'이름을 입력하세요\')', 'hintText: \'이름을 입력하세요\',')
            
        if 'fillColor: AppColors.surface)))' in line:
            line = line.replace('fillColor: AppColors.surface)))', 'fillColor: AppColors.surface),')
            
        if '}' in line and 'child: Text(' not in line:
            line = line.replace('}', '},')
            
        if 'style: TextStyle(,' in line:
            line = line.replace('style: TextStyle(,', 'style: TextStyle(')
            
        if ':' in line and ']\'' in line:
            line = re.sub(r"'([A-Z]+)':\s*'([A-Z]+)'", r"'\1', '\2'", line)
            
        if 'padding: const EdgeInsets.only(righ,' in line:
            line = line.replace('padding: const EdgeInsets.only(righ,', 'padding: const EdgeInsets.only(right')
            
        if 'child: ChoiceChip(,' in line:
            line = line.replace('child: ChoiceChip(,', 'child: ChoiceChip(')
            
        if 'theme.colorScheme.primary.withValues(alph,' in line:
            line = line.replace('theme.colorScheme.primary.withValues(alph,', 'theme.colorScheme.primary.withValues(alpha')
            
        if 'required bool selected);' in line:
            line = line.replace('required bool selected);', 'required bool selected,')
            
        if 'buildChoiceChip(,' in line:
            line = line.replace('buildChoiceChip(,', 'buildChoiceChip(')
            
        if 'selected: _selectedGender == \'male\')' in line:
            line = line.replace('selected: _selectedGender == \'male\')', 'selected: _selectedGender == \'male\',')
            
        if 'selected: _selectedGender == \'female\')' in line:
            line = line.replace('selected: _selectedGender == \'female\')', 'selected: _selectedGender == \'female\',')
            
        if 'child: _buildChoiceChip(,' in line:
            line = line.replace('child: _buildChoiceChip(,', 'child: _buildChoiceChip(')
            
        # Fix specific multiline issues
        if 'value: mbti)' in line:
            line = line.replace('value: mbti)', 'value: mbti,')
            
        if 'child: Text(mbti))' in line:
            line = line.replace('child: Text(mbti))', 'child: Text(mbti))')
            
        if 'style: theme.textTheme.bodyMedium);' in line:
            line = line.replace('style: theme.textTheme.bodyMedium);', 'style: theme.textTheme.bodyMedium),')
            
        if 't: AppSpacing.xSmall)' in line:
            line = line.replace('t: AppSpacing.xSmall)', ': AppSpacing.xSmall)')
            
        # Fix missing commas in various places
        if line.strip().endswith('))') and not line.strip().endswith('));') and not line.strip().endswith(')),'):
            if i + 1 < len(lines) and lines[i + 1].strip() and not lines[i + 1].strip().startswith(')'):
                line = line.rstrip() + ','
                
        fixed_lines.append(line)
    
    # Join lines and fix remaining issues
    content = '\n'.join(fixed_lines)
    
    # Fix specific multi-line patterns
    content = re.sub(
        r"items: \['INTJ': 'INTP': 'ENTJ'",
        "items: ['INTJ', 'INTP', 'ENTJ'",
        content
    )
    
    content = re.sub(
        r"\.\.\.?\['A': 'B': 'AB', 'O'\]",
        "...['A', 'B', 'AB', 'O']",
        content
    )
    
    # Fix date formatting string
    content = re.sub(
        r"\'\$\{_selectedDate!\.year\}년 \$\{_selectedDate!\.month\}월 \$\{_selectedDate!\.day\}일\'\)",
        "'${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'",
        content
    )
    
    # Fix missing closing brackets
    content = re.sub(
        r'labelText: \'MBTI\'\),\s*prefixIcon:',
        'labelText: \'MBTI\',\n              prefixIcon:',
        content
    )
    
    # Save the fixed content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed syntax errors in {file_path}")

if __name__ == "__main__":
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    fix_bottom_sheet_syntax(file_path)