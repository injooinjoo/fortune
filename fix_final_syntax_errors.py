#!/usr/bin/env python3

import re

def fix_fortune_explanation_bottom_sheet():
    """Final comprehensive fix for fortune_explanation_bottom_sheet.dart"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix line by line
    for i in range(len(lines)):
        line = lines[i]
        
        # Fix TextField and comma issues
        if 'controller: _nameController,,' in line:
            lines[i] = line.replace(',,', ',')
        if 'hintText: \'이름을 입력하세요\',,':
            lines[i] = line.replace('\',,', '\',')
        
        # Fix labelText issues
        if 'labelText: \'생년월일\',,':
            lines[i] = line.replace('\',,', '\',')
        if 'labelText: \'MBTI\',' in line:
            lines[i] = line.replace('labelText: \'MBTI\',', 'labelText: \'MBTI\'),')
        
        # Fix value and child issues
        if 'value: mbti,,' in line:
            lines[i] = line.replace(',,', ',')
        if 'child: Text(mbti),' in line and i+1 < len(lines) and '.toList()' in lines[i+1]:
            lines[i] = line.replace('child: Text(mbti),', 'child: Text(mbti))')
        
        # Fix decoration issues
        if 'fillCol: AppColors.surface),' in line:
            lines[i] = line.replace('fillCol:', 'fillColor:')
        
        # Fix specific syntax issues
        if 'EdgeInsets.symmetric(horizontal, AppSpacing' in line:
            lines[i] = line.replace('horizontal,', 'horizontal:')
        
        # Fix Container closing
        if 'boxShadow: [' in line and i > 0 and 'borderRadius:' in lines[i-1]:
            lines[i] = '                  ),\n' + line
        
        # Fix withValues issues
        if '.withValues(alpha: 0.' in line and 'color: theme.colorScheme.primary.withValues(alpha: 0.' in line:
            lines[i] = line.replace('.withValues(alpha: 0.', '.withValues(alpha: 0.')
        
        # Fix lucky item containsKey issues
        if 'luckyItemExplanations.containsKey(\'color\'),))' in line:
            lines[i] = line.replace(',))', '))')
        if 'luckyItemExplanations.containsKey(\'number\'),))' in line:
            lines[i] = line.replace(',))', '))')
        if 'luckyItemExplanations.containsKey(\'direction\'),))' in line:
            lines[i] = line.replace(',))', '))')
        if 'luckyItemExplanations.containsKey(\'time\'),))' in line:
            lines[i] = line.replace(',))', '))')
        if 'luckyItemExplanations.containsKey(\'food\', null,))' in line:
            lines[i] = line.replace('\'food\', null,))', '\'food\'))')
        if 'luckyItemExplanations.containsKey(\'person\'),))' in line:
            lines[i] = line.replace(',))', '))')
        
        # Fix ending brackets
        if '_buildEnhancedLuckyItem(theme, \'color\', Icons.palette, luckyItemExplanations[\'color\'],' in line:
            lines[i] = line.replace('],', '])')
        if '_buildEnhancedLuckyItem(theme, \'number\', Icons.looks_one, luckyItemExplanations[\'number\'],' in line:
            lines[i] = line.replace('],', '])')
        if '_buildEnhancedLuckyItem(theme, \'direction\', Icons.explore, luckyItemExplanations[\'direction\'],' in line:
            lines[i] = line.replace('],', '])')
        if '_buildEnhancedLuckyItem(theme, \'time\', Icons.access_time, luckyItemExplanations[\'time\'],' in line:
            lines[i] = line.replace('],', '])')
        if '_buildEnhancedLuckyItem(theme, \'food\', Icons.restaurant, luckyItemExplanations[\'food\'],' in line:
            lines[i] = line.replace('],', '])')
        if '_buildEnhancedLuckyItem(theme, \'person\', Icons.person, luckyItemExplanations[\'person\'])' in line:
            lines[i] = line.replace('])', '])')
        
        # Fix return issues
        if 'fontWeight: FontWeight.bold)' in line and i+1 < len(lines) and '          ]),' in lines[i+1]:
            lines[i] = line + ')\n'
        
        # Fix color alpha issues
        if 'border: Border.all(color' in line and i+1 < len(lines) and 'alpha: AppColors.divider),' in lines[i+1]:
            lines[i] = line.replace('color', 'color:')
            lines[i+1] = lines[i+1].replace('alpha:', '')
        
        # Fix function parameter issues
        if 'required List<String> content)},' in line:
            lines[i] = line.replace(')},', '),')
        
        # Fix text and color issues
        if 'color: AppColors.warning),' in line and i > 0 and 'size: AppDimensions.iconSizeSmall' in lines[i-1]:
            lines[i-1] = lines[i-1].replace('size: AppDimensions.iconSizeSmall', 'size: AppDimensions.iconSizeSmall,')
        
        # Fix dividerColor issues
        if 'data: theme.copyWith(dividerColor' in line and i+1 < len(lines) and 'alpha: Colors.transparent),' in lines[i+1]:
            lines[i] = line.replace('dividerColor', 'dividerColor:')
            lines[i+1] = lines[i+1].replace('alpha:', '')
        
        # Fix tilePadding
        if 'tilePadding: EdgeInsets.symmetric(horizontal' in line and i+1 < len(lines) and 'alpha: AppSpacing' in lines[i+1]:
            lines[i] = line.replace('horizontal', 'horizontal:')
            lines[i+1] = lines[i+1].replace('alpha:', '')
        
        # Fix color issues in Container
        if 'decoration: BoxDecoration(' in line and i+1 < len(lines) and 'color: AppColors.textPrimaryDark),' in lines[i+1]:
            lines[i+1] = lines[i+1].replace('color: AppColors.textPrimaryDark),', 'color: AppColors.textPrimaryDark,')
        
        # Fix EdgeInsets
        if 'padding: EdgeInsets.symmetric(horizontal:' in line and 'AppSpacing.spacing3' in line:
            lines[i] = line.replace('EdgeInsets.symmetric(horizontal:', 'EdgeInsets.symmetric(horizontal:')
        
        # Fix missing closing brackets
        if 'style: theme.textTheme.bodySmall?.copyWith(' in line and i+1 < len(lines) and 'color: AppColors.textSecondary)' in lines[i+1]:
            lines[i+1] = lines[i+1].replace('color: AppColors.textSecondary)', 'color: AppColors.textSecondary))')
        
        # Fix string issues
        if 'data[\'icon\'] ?? \'\'\'' in line:
            lines[i] = line.replace('\'\'\'', '\'\'')
        if 'job[\'activity\'] ?? \'\'\'' in line:
            lines[i] = line.replace('\'\'\'', '\'\'')
        if 'step[\'description\'] ?? \'\'\'' in line:
            lines[i] = line.replace('\'\'\'', '\'\'')
        if 'signal[\'note\'] ?? \'\'\'' in line:
            lines[i] = line.replace('\'\'\'', '\'\'')
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed {file_path}")

def fix_physiognomy_fortune_page():
    """Final comprehensive fix for physiognomy_fortune_page.dart"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix line by line
    for i in range(len(lines)):
        line = lines[i]
        
        # Fix Text widget issues
        if 'Text(label),' in line and i+1 < len(lines) and 'style: theme.textTheme' in lines[i+1]:
            lines[i] = line.replace('Text(label),', 'Text(label,')
        
        # Fix style ending issues
        if 'fontWeight: FontWeight.bold)),' in line and i+1 < len(lines) and ']' in lines[i+1]:
            lines[i] = line.replace(')),', ')),],')
        
        # Fix Row mainAxisAlignment
        if 'Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,' in line:
            lines[i] = line.replace('spaceBetween,', 'spaceBetween,\n')
        
        # Fix Text style issues
        if 'Text(label),' in line and i+1 < len(lines) and 'style: theme.textTheme.bodyLarge' in lines[i+1]:
            if 'fontWeight: FontWeight.bold)),,' in lines[i+1]:
                lines[i+1] = lines[i+1].replace(')),', '))')
        
        # Fix color list issues
        if "'color': Colors.blue},," in line:
            lines[i] = line.replace('},,', '},')
        
        # Fix Icon issues
        if 'size: 20, color: theme.colorScheme.primary),' in line:
            lines[i] = line.replace('size: 20, color:', 'size: 20,\n                        color:')
        
        # Fix children closing
        if 'children: [' in line and i > 0 and '_buildAnalysisScore' in lines[i-5:i]:
            # Track bracket count to find proper closing
            bracket_count = 1
            j = i + 1
            while j < len(lines) and bracket_count > 0:
                bracket_count += lines[j].count('[') - lines[j].count(']')
                bracket_count += lines[j].count('(') - lines[j].count(')')
                j += 1
            # Add missing closing if needed
            if bracket_count > 0 and j < len(lines):
                lines[j-1] = lines[j-1].rstrip() + '\n          ]\n        )\n      );\n'
        
        # Fix GlassCard missing padding
        if 'child: GlassCard(' in line and i+1 < len(lines) and 'child: Column(' in lines[i+1]:
            lines[i] = line.replace('child: GlassCard(', 'child: GlassCard(\n        padding: const EdgeInsets.all(20),')
        
        # Fix closing brackets for personality profile
        if 'textAlign: TextAlign.center)' in line and i > 0 and 'trait[\'name\']' in lines[i-2]:
            lines[i] = line.replace('textAlign: TextAlign.center)', 'textAlign: TextAlign.center)')
            if i+1 < len(lines) and ']' not in lines[i+1]:
                lines[i] = lines[i].rstrip() + '\n                    ]\n                  )\n                );\n'
        
        # Fix Row children closing
        if 'fontWeight: FontWeight.bold)),' in line and i > 0 and 'item[\'feature\']' in lines[i-2]:
            lines[i] = line.replace(')),', '))]')
        
        # Fix color issues in advices
        if 'color: item[\'color\'] as Color)),' in line:
            lines[i] = line.replace('))),', '))')
        
        # Fix Text style issues in _buildOptionalFeatureDropdown
        if 'Text(label),' in line and i > 0 and '_buildOptionalFeatureDropdown' in lines[i-10:i]:
            lines[i] = line.replace('Text(label),', 'Text(label,')
        if 'style: theme.textTheme.bodyLarge),' in line and i > 0 and 'Text(label' in lines[i-1]:
            lines[i] = line.replace('style: theme.textTheme.bodyLarge),', 'style: theme.textTheme.bodyLarge),')
        
        # Fix missing closing for Column
        if 'color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))),' in line:
            lines[i] = line.replace(')))),' , '))]')
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed {file_path}")

def main():
    print("Applying final syntax fixes...")
    
    fix_fortune_explanation_bottom_sheet()
    fix_physiognomy_fortune_page()
    
    print("All fixes completed!")

if __name__ == "__main__":
    main()