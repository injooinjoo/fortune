#!/usr/bin/env python3

import re
import os

def fix_bottom_sheet_comprehensive(file_path):
    """Comprehensive fix for fortune_explanation_bottom_sheet.dart syntax errors"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Skip empty lines at the end of arrays that cause issues
        if i > 0 and line.strip() == '' and i < len(lines) - 1:
            if 'No newline at end of file' in lines[i+1]:
                continue
                
        # Fix common patterns
        line = re.sub(r'\)\)\]\)\)', '))', line)
        line = re.sub(r'\)\)\)\)', '))', line)
        line = re.sub(r'\]\]\)', '])', line)
        line = re.sub(r'\)\),$', '),', line)
        line = re.sub(r'\]\),$', ']),', line)
        
        # Fix specific issues with parentheses and brackets
        line = re.sub(r'builder: \(context, =>', 'builder: (context) =>', line)
        line = re.sub(r'\.of\(context,;', '.of(context);', line)
        line = re.sub(r'\.of\(context,\)', '.of(context)', line)
        line = re.sub(r'Navigator\.of\(context,\.', 'Navigator.of(context).', line)
        line = re.sub(r'Theme\.of\(context,\.', 'Theme.of(context).', line)
        line = re.sub(r'MediaQuery\.of\(context,\.', 'MediaQuery.of(context).', line)
        
        # Fix list items with colon instead of comma
        line = re.sub(r"'([A-Z]+)': '([A-Z]+)'", r"'\1', '\2'", line)
        line = re.sub(r"'([a-z]+)': '([a-z]+)'", r"'\1', '\2'", line)
        
        # Fix method calls with misplaced commas
        line = re.sub(r'controller: _nameController\)', 'controller: _nameController,', line)
        line = re.sub(r'DateTime\.now\(\);', 'DateTime.now(),', line)
        line = re.sub(r'child: InputDecorator\(,', 'child: InputDecorator(', line)
        line = re.sub(r'child: ChoiceChip\(,', 'child: ChoiceChip(', line)
        line = re.sub(r'_buildChoiceChip\(,', '_buildChoiceChip(', line)
        
        # Fix widget property syntax
        line = re.sub(r'hintText: \'([^\']+)\'\)', 'hintText: \'\g<1>\',', line)
        line = re.sub(r'labelText: \'([^\']+)\'\)', 'labelText: \'\g<1>\',', line)
        line = re.sub(r'fillColor: ([^)]+)\)\)\)', 'fillColor: \g<1>),', line)
        line = re.sub(r'fillColor: ([^)]+)\)\)', 'fillColor: \g<1>),', line)
        
        # Fix style property syntax
        line = re.sub(r'style: TextStyle\(,', 'style: TextStyle(', line)
        line = re.sub(r'style: ([^;]+);', 'style: \g<1>,', line)
        
        # Fix padding syntax
        line = re.sub(r'padding: const EdgeInsets\.only\(righ,', 'padding: const EdgeInsets.only(right', line)
        line = re.sub(r'padding: const EdgeInsets\.only\(botto,', 'padding: const EdgeInsets.only(bottom', line)
        line = re.sub(r't: AppSpacing', ': AppSpacing', line)
        line = re.sub(r'm: AppSpacing', ': AppSpacing', line)
        
        # Fix withValues syntax
        line = re.sub(r'\.withValues\(alph,', '.withValues(alpha', line)
        line = re.sub(r'\.withValues\(alp,', '.withValues(alpha', line)
        
        # Fix function parameter issues
        line = re.sub(r'required bool selected\);', 'required bool selected,', line)
        line = re.sub(r'required Function\(bool\) onSelected\}\)', 'required Function(bool) onSelected})', line)
        line = re.sub(r'bool isOptional = false\},\)', 'bool isOptional = false})', line)
        line = re.sub(r'required List<String> content\},\)', 'required List<String> content})', line)
        line = re.sub(r'required Widget child\)\},\)', 'required Widget child})', line)
        
        # Fix Container/Widget closing syntax
        line = re.sub(r'Container\($', 'Container(', line)
        line = re.sub(r'Stack\(,$', 'Stack(', line)
        line = re.sub(r'Center\(,$', 'Center(', line)
        
        # Fix missing commas in lists
        if "'optional':" in line and not line.strip().endswith(',') and not line.strip().endswith('}'):
            line = line.rstrip() + ',\n'
        if "'required':" in line and not line.strip().endswith(',') and not line.strip().endswith('}'):
            line = line.rstrip() + ',\n'
            
        # Fix specific multiline issues
        if 'value: mbti)' in line:
            line = line.replace('value: mbti)', 'value: mbti,')
        if 'child: Text(mbti))' in line:
            line = line.replace('child: Text(mbti))', 'child: Text(mbti))')
            
        # Fix border and decoration issues
        line = re.sub(r'border: Border\.all\(,$', 'border: Border.all(', line)
        line = re.sub(r'border: Border\.all\(col,$', 'border: Border.all(color', line)
        line = re.sub(r'or: ([^)]+)\)', ': \g<1>)', line)
        
        # Fix specific widget issues
        line = re.sub(r'Row\($', 'Row(', line)
        line = re.sub(r'Column\($', 'Column(', line)
        line = re.sub(r'child: Text\($', 'child: Text(', line)
        
        # Fix string interpolation issues
        line = re.sub(r"'\$\{([^}]+)\},([^']+)'", r"'\${\1}\2'", line)
        
        # Fix BoxConstraints syntax
        line = re.sub(r'BoxConstraints\(maxWidt,$', 'BoxConstraints(maxWidth', line)
        line = re.sub(r'h: ([0-9]+)\)', ': \g<1>)', line)
        
        # Fix Map syntax
        line = re.sub(r"'name': ''", "'name': '',", line)
        line = re.sub(r"'birthDate': ([^,]+)$", "'birthDate': \\1,", line)
        line = re.sub(r"'birthTime': ([^,]+)$", "'birthTime': \\1,", line)
        line = re.sub(r"'gender': ([^,]+)$", "'gender': \\1,", line)
        line = re.sub(r"'mbti': ([^,]+)$", "'mbti': \\1,", line)
        line = re.sub(r"'bloodType': ([^,]+)$", "'bloodType': \\1,", line)
        line = re.sub(r"'zodiacSign': ([^,]+)$", "'zodiacSign': \\1,", line)
        line = re.sub(r"'chineseZodiac': ([^,]+)$", "'chineseZodiac': \\1,", line)
        line = re.sub(r"'location': ([^,]+)$", "'location': \\1,", line)
        
        # Fix return statement issues
        if 'return {};' in line and not line.strip().endswith(','):
            line = line.replace('return {};', 'return {},')
            
        # Fix case statement syntax
        if line.strip().endswith('};') and 'return {' in line:
            line = line.replace('};', '},')
            
        # Fix specific widget tree issues
        line = re.sub(r'SizedBox\(height: ([^)]+)\)$', 'SizedBox(height: \\1),', line)
        line = re.sub(r'Icon\(([^)]+)\)$', 'Icon(\\1),', line)
        line = re.sub(r'Text\(([^)]+)\)$', 'Text(\\1),', line)
        
        # Fix Color issues
        line = re.sub(r"'수': null\},;", "'수': Colors.blue},", line)
        
        # Fix specific syntax issues
        line = re.sub(r'shrinkWrap: true\)', 'shrinkWrap: true,', line)
        line = re.sub(r'\.join\(\':', ".join(',", line)
        
        # Fix DateTime formatting
        line = re.sub(r"'\$\{([^}]+)\},년", r"'\${\1}년", line)
        line = re.sub(r"'\$\{([^}]+)\},월", r"'\${\1}월", line)
        line = re.sub(r"'\$\{([^}]+)\},일'", r"'\${\1}일'", line)
        
        # Fix percentage display
        line = re.sub(r"'\)\)\},%'", "'\${score.toStringAsFixed(0)}%'", line)
        line = re.sub(r"'\$\{([^}]+)\},%\)'", r"'\${\1}%'", line)
        line = re.sub(r"'\)\)\},점'", "'\${score.toStringAsFixed(0)}점'", line)
        
        # Fix widget nesting issues
        line = re.sub(r'\]\)$', ']),', line)
        line = re.sub(r'\)\)$', ')),', line)
        
        # Fix specific method call issues
        line = re.sub(r'\.toList\(\)$', '.toList(),', line)
        
        # Fix Container decoration issues
        line = re.sub(r'Container\(margin', 'Container(\n              margin', line)
        line = re.sub(r'Container\(padding', 'Container(\n              padding', line)
        
        # Fix Theme data issues
        line = re.sub(r'Theme\(,$', 'Theme(', line)
        line = re.sub(r'data: theme\.copyWith\(dividerColo,$', 'data: theme.copyWith(dividerColor', line)
        line = re.sub(r'r: Colors\.transparent\)', ': Colors.transparent)', line)
        
        # Fix ExpansionTile issues
        line = re.sub(r'child: Theme\(,$', 'child: Theme(', line)
        line = re.sub(r'child: ExpansionTile\(,$', 'child: ExpansionTile(', line)
        line = re.sub(r'tilePadding: EdgeInsets\.symmetric\(horizont,$', 'tilePadding: EdgeInsets.symmetric(horizontal', line)
        line = re.sub(r'al: ([^,]+), vertical: ([^)]+)\)', ': \\1, vertical: \\2)', line)
        
        # Fix Icon color issues
        line = re.sub(r'Icon\(([^)]+)\);', 'Icon(\\1),', line)
        line = re.sub(r'size: ([^)]+)\);', 'size: \\1),', line)
        
        # Fix specific return issues
        if "loading: () => {}," in line:
            line = line.replace("loading: () => {},", "loading: () => {},")
            
        # Fix specific Map syntax
        line = re.sub(r"'required': \['name': 'birthDate'\]", "'required': ['name', 'birthDate'],", line)
        line = re.sub(r"'optional': \['birthTime': 'gender', 'mbti'\]", "'optional': ['birthTime', 'gender', 'mbti'],", line)
        
        # Fix widget property lists
        line = re.sub(r'fontWeight: FontWeight\.bold\)\)\)', 'fontWeight: FontWeight.bold))', line)
        line = re.sub(r'fontWeight: FontWeight\.bold\)\)', 'fontWeight: FontWeight.bold),', line)
        
        # Fix Container height/width issues
        line = re.sub(r'height: ([^)]+)\),$', 'height: \\1),', line)
        line = re.sub(r'width: ([^)]+)\),$', 'width: \\1),', line)
        
        # Fix gradient issues
        line = re.sub(r'colors: \[([^]]+)\]$', 'colors: [\\1],', line)
        
        # Fix final issues
        line = re.sub(r'fontSize: Theme\.of\(context,\.', 'fontSize: Theme.of(context).', line)
        line = re.sub(r'style: Theme\.of\(context,\.', 'style: Theme.of(context).', line)
        
        # Fix comparison operators in conditional
        line = re.sub(r'color: score >= 50 \? AppColors\.textPrimaryDark : AppColors\.textPrimary\.withValues\(alp,$', 
                     'color: score >= 50 ? AppColors.textPrimaryDark : AppColors.textPrimary.withValues(alpha', line)
        line = re.sub(r'ha: ([^,]+), fontWeight:', ': \\1), fontWeight:', line)
        
        # Fix specific widget ending issues
        if line.strip() == '))' and i + 1 < len(lines) and lines[i+1].strip() != '' and not lines[i+1].strip().startswith(')'):
            line = ')),\n'
            
        fixed_lines.append(line)
    
    # Join and fix remaining issues
    content = ''.join(fixed_lines)
    
    # Fix multi-line string interpolation
    content = re.sub(
        r"'\$\{_selectedDate!\.year\}년 \$\{_selectedDate!\.month\}월 \$\{_selectedDate!\.day\}일'\)",
        "'${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'",
        content
    )
    
    # Fix specific score display issues
    content = re.sub(r"'\)\)\},%'", "'${score.toStringAsFixed(0)}%'", content)
    content = re.sub(r"'\)\)\},점'", "'${score.toStringAsFixed(0)}점'", content)
    
    # Save the fixed content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Comprehensively fixed syntax errors in {file_path}")

if __name__ == "__main__":
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    fix_bottom_sheet_comprehensive(file_path)