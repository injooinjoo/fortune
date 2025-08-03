#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'r') as f:
    lines = f.readlines()

# Fix specific line issues
for i in range(len(lines)):
    # Fix semicolon instead of comma after Icon color
    if 'color: statusColor,);' in lines[i]:
        lines[i] = lines[i].replace('color: statusColor,);', 'color: statusColor,')
    
    # Fix semicolon instead of comma for other colors
    if 'color: AppColors.error);' in lines[i]:
        lines[i] = lines[i].replace('color: AppColors.error);', 'color: AppColors.error,')
    if 'color: AppColors.primary);' in lines[i]:
        lines[i] = lines[i].replace('color: AppColors.primary);', 'color: AppColors.primary,')
    if 'color: Colors.amber);' in lines[i]:
        lines[i] = lines[i].replace('color: Colors.amber);', 'color: Colors.amber,')
    
    # Fix missing closing parenthesis
    if 'color: AppColors.error,' in lines[i] and i+1 < len(lines) and '  SizedBox(width: AppSpacing.spacing2),' in lines[i+1]:
        lines[i] = lines[i].rstrip() + '),\n'
    if 'color: AppColors.primary,' in lines[i] and i+1 < len(lines) and '  SizedBox(width: AppSpacing.spacing2),' in lines[i+1]:
        lines[i] = lines[i].rstrip() + '),\n'
    if 'color: Colors.amber,' in lines[i] and i+1 < len(lines) and '  SizedBox(width: AppSpacing.spacing2),' in lines[i+1]:
        lines[i] = lines[i].rstrip() + '),\n'
    
    # Fix Text widget style placement
    if lines[i].strip() == 'style: theme.textTheme.titleLarge?.copyWith(':
        lines[i] = '              ' + lines[i].strip() + '\n'
    
    # Fix closing patterns for map operations
    if ']),.toList()),' in lines[i]:
        lines[i] = lines[i].replace(']),.toList()),', ']).toList(),')
    
    # Fix missing closing parentheses after Text widgets
    if ']),\n' in lines[i] and i > 0 and 'style: theme.textTheme' in lines[i-2]:
        lines[i] = '                  ),\n' + lines[i]
    
    # Fix Container child patterns
    if 'child: Text(' in lines[i] and i > 0 and 'borderRadius: AppDimensions.borderRadiusMedium),' in lines[i-1]:
        lines[i-1] = lines[i-1].replace('borderRadius: AppDimensions.borderRadiusMedium),', 'borderRadius: AppDimensions.borderRadiusMedium,')

# Write back
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'w') as f:
    f.writelines(lines)

print("Fixed all remaining syntax errors in five_elements_explanation_bottom_sheet.dart")