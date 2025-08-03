#!/usr/bin/env python3

# Read the file
with open('lib/presentation/widgets/profile_edit_dialogs/mbti_edit_dialog.dart', 'r') as f:
    lines = f.readlines()

# Fix line by line
fixed_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # Fix line 84
    if 'SizedBox(height: AppSpacing.spacing5),' in line:
        line = '          SizedBox(height: AppSpacing.spacing5),\n'
    
    # Fix line 92
    elif 'physics: const NeverScrollableScrollPhysics(),' in line:
        line = '                    physics: const NeverScrollableScrollPhysics(),\n'
    
    # Fix line 98
    elif 'childAspectRatio: 1.8),' in line:
        line = '                      childAspectRatio: 1.8,\n                    ),\n'
    
    # Fix line 99
    elif 'itemCount: mbtiTypes.length,' in line:
        line = '                    itemCount: mbtiTypes.length,\n'
    
    # Fix line 103
    elif 'return _buildMbtiOption(mbti);' in line and '})' in line:
        line = '                      return _buildMbtiOption(mbti);\n                    },\n                  ),\n'
    
    # Fix line 106 - the complex closing
    elif ']))))))' in line:
        line = '                ],\n              ),\n            ),\n          ),\n'
    
    # Fix line 107-109 - closing brackets
    elif line.strip() == ']':
        line = '        ],\n'
    elif line.strip() == ')':
        if i+1 < len(lines) and lines[i+1].strip() == '}':
            line = '      ),\n    );\n'
            i += 1  # Skip the next }
    
    # Fix line 116
    elif 'color: Colors.transparent),' in line:
        line = '      color: Colors.transparent,\n'
    
    # Fix line 117
    elif 'child: InkWell(,' in line:
        line = '      child: InkWell(\n'
    
    # Fix line 118-122 - onTap function
    elif 'onTap: () {' in line:
        fixed_lines.append(line)
        # Get the next few lines for the function body
        j = i + 1
        while j < len(lines) and not 'borderRadius:' in lines[j]:
            fixed_lines.append(lines[j])
            j += 1
        line = '        },\n'
        i = j - 1
    
    # Fix line 124
    elif 'child: Container(,' in line:
        line = '        child: Container(\n'
    
    # Fix line 125
    elif 'padding: AppSpacing.paddingVertical8),' in line:
        line = '          padding: AppSpacing.paddingVertical8,\n'
    
    # Fix line 126
    elif 'decoration: BoxDecoration(,' in line:
        line = '          decoration: BoxDecoration(\n'
    
    # Fix line 127
    elif 'border: Border.all(,' in line:
        line = '            border: Border.all(\n'
    
    # Fix line 128-130
    elif 'color: isSelected ? AppColors.primary : AppColors.divider,' in line:
        fixed_lines.append('              color: isSelected ? AppColors.primary : AppColors.divider,\n')
        if i+1 < len(lines) and 'width: isSelected' in lines[i+1]:
            line = '              width: isSelected ? 2 : 1,\n            ),\n'
            i += 1  # Skip the next line
    
    # Fix line 131-132
    elif 'borderRadius: AppDimensions.borderRadiusSmall,' in line:
        fixed_lines.append(line)
        if i+1 < len(lines) and 'color: isSelected' in lines[i+1]:
            line = '            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,\n          ),\n'
            i += 1
    
    # Fix line 134-135
    elif 'child: Text(' in line:
        fixed_lines.append('          child: Center(\n')
        fixed_lines.append('            child: Text(\n')
        if i+1 < len(lines) and 'label),' in lines[i+1]:
            line = '              label,\n'
            i += 1
    
    # Fix line 136
    elif 'style: Theme.of(context).textTheme.titleSmall,' in line:
        line = '              style: Theme.of(context).textTheme.titleSmall?.copyWith(\n'
        line += '                color: isSelected ? AppColors.textDark : AppColors.textPrimary,\n'
        line += '                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,\n'
        line += '              ),\n'
        line += '            ),\n'
        line += '          ),\n'
        line += '        ),\n'
        line += '      ),\n'
        line += '    );\n'
    
    # Skip lines that were already processed
    elif 'No newline at end of file' in line:
        continue
        
    fixed_lines.append(line)
    i += 1

# Write back
with open('lib/presentation/widgets/profile_edit_dialogs/mbti_edit_dialog.dart', 'w') as f:
    f.writelines(fixed_lines)

print("Comprehensively fixed syntax errors in mbti_edit_dialog.dart")