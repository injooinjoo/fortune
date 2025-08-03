#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart', 'r') as f:
    content = f.read()

# Fix 1: Missing comma after ] on line 164
content = content.replace("                      ]\n                      SizedBox(height: AppSpacing.spacing10),", 
                         "                      ],\n                      SizedBox(height: AppSpacing.spacing10),")

# Fix 2: Fix closing parentheses/brackets on lines 166-167
content = content.replace("])).animate().fadeIn(duration: 400.ms, delay: 100.ms))))\n            ]))", 
                         "                    ],\n                  ),\n                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),\n              ),\n            ],\n          ),\n        );\n      },")

# Fix 3: Fix margin syntax on lines 174-175
content = content.replace("      margin: const EdgeInsets.only(to,\n      p: AppSpacing.small, bottom: AppSpacing.xSmall),", 
                         "      margin: const EdgeInsets.only(\n        top: AppSpacing.small,\n        bottom: AppSpacing.xSmall,\n      ),")

# Fix 4: Fix BoxDecoration syntax on line 178
content = content.replace("      decoration: BoxDecoration(,\n      color: AppColors.textSecondary,\n        ),", 
                         "      decoration: BoxDecoration(\n        color: AppColors.textSecondary,\n        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),\n      ),")

# Fix 5: Remove extra closing parenthesis on line 182
content = content.replace("        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),\n      )\n  }", 
                         "    );\n  }")

# Fix 6: Fix padding syntax on line 187
content = content.replace("      padding: AppSpacing.paddingAll20),", "      padding: AppSpacing.paddingAll20,")

# Fix 7: Fix BoxDecoration syntax on line 188
content = content.replace("        decoration: BoxDecoration(,", "      decoration: BoxDecoration(")

# Fix 8: Fix missing comma after gradient
content = re.sub(r"end: Alignment\.bottomCenter\)\)", "end: Alignment.bottomCenter,\n        ),\n      ),", content)

# Fix 9: Fix multiple syntax errors throughout the file
# This will be a comprehensive fix for all similar patterns

# Pattern 1: Fix BoxDecoration syntax errors
content = re.sub(r"BoxDecoration\(,", "BoxDecoration(", content)

# Pattern 2: Fix copyWith syntax errors
content = re.sub(r"copyWith\(,", "copyWith(", content)

# Pattern 3: Fix withValues syntax errors
content = re.sub(r"withValues\(alph,\s*a:", "withValues(alpha:", content)
content = re.sub(r"withValues\(alp,\s*ha:", "withValues(alpha:", content)

# Pattern 4: Fix EdgeInsets syntax errors
content = re.sub(r"EdgeInsets\.only\(botto,\s*m:", "EdgeInsets.only(bottom:", content)
content = re.sub(r"EdgeInsets\.symmetric\(vertica,\s*l:", "EdgeInsets.symmetric(vertical:", content)

# Pattern 5: Fix child widget syntax errors
content = re.sub(r"child: Row\(,", "child: Row(", content)
content = re.sub(r"child: Column\(,", "child: Column(", content)
content = re.sub(r"child: Text\(,", "child: Text(", content)

# Pattern 6: Fix Border.all syntax errors
content = re.sub(r"Border\.all\(,", "Border.all(", content)

# Pattern 7: Fix closing widget syntax
content = re.sub(r"\)\)\)\)\s*\n\s*\]\)\)\)\)", "),\n                ),\n              ),\n            ],\n          ),", content)

# Pattern 8: Fix Icon widget closing
content = re.sub(r"size: AppDimensions\.iconSize[^,]+\);", lambda m: m.group(0).replace(");", ",\n              ),"), content)

# Pattern 9: Fix Container width/height syntax
content = re.sub(r"height: AppSpacing\.spacing(\d+),\s*\),", r"height: AppSpacing.spacing\1,", content)

# Pattern 10: Fix Text widget style closing
content = re.sub(r"style: Theme\.of\(context\)\.textTheme\.[^,]+\)\s*(?!\.)", lambda m: m.group(0) + ",", content)

# Write back
with open('lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart', 'w') as f:
    f.write(content)

print("Comprehensively fixed syntax errors in saju_element_explanation_bottom_sheet.dart")