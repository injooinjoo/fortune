#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/profile_edit_dialogs/birth_time_edit_dialog.dart', 'r') as f:
    content = f.read()

# Fix 1: TimePeriod constructor calls
# Pattern: TimePeriod(value: 'xxx': label: 'xxx': description: 'xxx',
# Should be: TimePeriod(value: 'xxx', label: 'xxx', description: 'xxx'),
pattern = r"TimePeriod\(value: '([^']+)': label: '([^']+)': description: '([^']+)',"
replacement = r"TimePeriod(value: '\1', label: '\2', description: '\3'),"
content = re.sub(pattern, replacement, content)

# Fix 2: Malformed string in line 73
# Text('발생했습니다: ${e.toString(,
content = content.replace("Text('발생했습니다: ${e.toString(,", "Text('오류가 발생했습니다: ${e.toString()}'")

# Fix 3: Extra closing parenthesis on line 74
content = content.replace("  )}'),", "),")

# Fix 4: Missing closing parenthesis in line 77
content = content.replace("          )\n      }", "          ),\n        );\n      }")

# Fix 5: Syntax error on line 91 - Column(,
content = content.replace("      content: Column(,", "      content: Column(")

# Fix 6: Syntax error on lines 96-97 - copyWith(,
content = re.sub(r"copyWith\(,\s*color:", "copyWith(\n                            color:", content)

# Fix 7: Missing closing parenthesis after textAlign
content = content.replace("color: AppColors.textSecondary, textAlign: TextAlign.center);", 
                         "color: AppColors.textSecondary,\n                          ),\n                          textAlign: TextAlign.center,\n                        ),")

# Fix 8: Fix line 98 - SizedBox issue
content = content.replace("          SizedBox(height: AppSpacing.spacing4,\n                          ),", 
                         "          SizedBox(height: AppSpacing.spacing4),")

# Fix 9: Fix line 101-102 - BoxConstraints syntax
content = content.replace("            constraints: const BoxConstraints(maxHeigh,\n      t: 400),", 
                         "            constraints: const BoxConstraints(maxHeight: 400),")

# Fix 10: Fix line 103-106 - ListView.builder syntax
content = re.sub(r"child: ListView\.builder\(,\s*shrinkWrap: true\),\s*itemCount: timePeriods\.length \+ 1\),", 
                 "child: ListView.builder(\n              shrinkWrap: true,\n              itemCount: timePeriods.length + 1,", content)

# Fix 11: Fix closing brackets at end of itemBuilder
content = re.sub(r"  \)}\)\)\)\s*\]\s*\)\s*\}", 
                 "                );\n              },\n            ),\n          ),\n        ],\n      ),\n    );", content)

# Fix 12: Fix margin syntax on line 125-126
content = content.replace("      margin: const EdgeInsets.only(botto,\n      m: AppSpacing.xSmall),", 
                         "      margin: const EdgeInsets.only(bottom: AppSpacing.xSmall),")

# Fix 13: Fix Material widget syntax on line 127-128
content = content.replace("      child: Material(,\n      color: Colors.transparent),", 
                         "      child: Material(\n        color: Colors.transparent,")

# Fix 14: Fix InkWell syntax on line 129
content = content.replace("        child: InkWell(,", "        child: InkWell(")

# Fix 15: Fix missing comma after onTap closing brace
content = re.sub(r"}\s*borderRadius: AppDimensions\.borderRadiusSmall,", 
                 "},\n          borderRadius: AppDimensions.borderRadiusSmall,", content)

# Fix 16: Fix Container syntax on line 136
content = content.replace("          child: Container(,", "          child: Container(")

# Fix 17: Fix padding syntax on lines 137-138
content = content.replace("      padding: EdgeInsets.symmetric(horizont,\n      al: AppSpacing.spacing4, vertical: AppSpacing.spacing3),", 
                         "            padding: EdgeInsets.symmetric(\n              horizontal: AppSpacing.spacing4,\n              vertical: AppSpacing.spacing3,\n            ),")

# Fix 18: Fix decoration syntax on line 139
content = content.replace("            decoration: BoxDecoration(,", "            decoration: BoxDecoration(")

# Fix 19: Fix Border.all syntax on lines 140-143
content = re.sub(r"border: Border\.all\(,\s*color: isSelected[^,]+,\s*\),\s*width: isSelected[^)]+\),", 
                 "              border: Border.all(\n                color: isSelected ? AppColors.primary : AppColors.divider,\n                width: isSelected ? 2 : 1,\n              ),", content)

# Fix 20: Fix color syntax on lines 145-146
content = content.replace("              color: isSelected ? AppColors.primary.withValues(alp,\n      ha: 0.1) : null),", 
                         "              color: isSelected ? AppColors.primary.withOpacity(0.1) : null,\n            ),")

# Fix 21: Fix BoxDecoration syntax on lines 152-158
content = re.sub(r"decoration: BoxDecoration\(,\s*shape: BoxShape\.circle,\s*\),\s*border: Border\.all\(,\s*color: isSelected[^)]+\),\s*width: AppSpacing\.spacing0 \* 0\.5,\s*\)\),", 
                 "                  decoration: BoxDecoration(\n                    shape: BoxShape.circle,\n                    border: Border.all(\n                      color: isSelected ? AppColors.primary : AppColors.textSecondary,\n                      width: 1,\n                    ),\n                  ),", content)

# Fix 22: Fix Container syntax on line 161
content = content.replace("                          child: Container(,", "                          child: Container(")

# Fix 23: Fix BoxDecoration syntax on lines 164-167
content = content.replace("                            decoration: const BoxDecoration(,\n      shape: BoxShape.circle,\n                              color: AppColors.primary,\n    ),", 
                         "                            decoration: const BoxDecoration(\n                              shape: BoxShape.circle,\n                              color: AppColors.primary,\n                            ),\n                          ),")

# Fix 24: Fix conditional expression closing
content = content.replace("                      : null)", "                        )\n                      : null,\n                ),")

# Fix 25: Fix Column syntax on line 171
content = content.replace("                  child: Column(,", "                  child: Column(")

# Fix 26: Fix Text widget closing on lines 174-178
content = re.sub(r"Text\(\s*label,\s*\),\s*style: Theme\.of\(context\)\.textTheme\.titleMedium\?\.copyWith\(,\s*color: isSelected[^)]+\);", 
                 "                      Text(\n                        label,\n                        style: Theme.of(context).textTheme.titleMedium?.copyWith(\n                          color: isSelected ? AppColors.primary : AppColors.textPrimary,\n                        ),\n                      ),", content)

# Fix 27: Fix SizedBox syntax on line 180
content = content.replace("                        SizedBox(height: AppSpacing.xxxSmall,\n                          ),", 
                         "                        SizedBox(height: AppSpacing.xxxSmall),")

# Fix 28: Fix Text widget syntax on lines 183-185
content = re.sub(r"style: Theme\.of\(context\)\.textTheme\.bodyMedium\?\.copyWith\(,\s*color: AppColors\.textSecondary\)", 
                 "style: Theme.of(context).textTheme.bodyMedium?.copyWith(\n                            color: AppColors.textSecondary,\n                          )", content)

# Fix 29: Fix missing closing brackets at the end
content = content.replace("                      ]\n                    ],\n                          )))\n              ])))))))))", 
                         "                        ],\n                      ],\n                    ),\n                  ),\n                ],\n              ),\n            ),\n          ),\n        ),\n      ),\n    );")

# Write back
with open('lib/presentation/widgets/profile_edit_dialogs/birth_time_edit_dialog.dart', 'w') as f:
    f.write(content)

print("Comprehensively fixed syntax errors in birth_time_edit_dialog.dart")