#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/profile_edit_dialogs/blood_type_edit_dialog.dart', 'r') as f:
    content = f.read()

# Fix 1: Column syntax on line 63
content = content.replace("      content: Column(,", "      content: Column(")

# Fix 2: copyWith syntax on lines 68-69
content = re.sub(r"copyWith\(,\s*color: AppColors\.textSecondary\);", 
                 "copyWith(\n                            color: AppColors.textSecondary,\n                          ),", content)

# Fix 3: Fix SizedBox syntax on lines 70-71
content = content.replace("          SizedBox(height: AppSpacing.spacing5,\n                          ),", 
                         "          SizedBox(height: AppSpacing.spacing5),")

# Fix 4: Fix GridView.builder syntax on lines 72-73
content = content.replace("          GridView.builder(\n            shrinkWrap: true),", 
                         "          GridView.builder(\n            shrinkWrap: true,")

# Fix 5: Fix gridDelegate syntax on line 75
content = content.replace("            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(,", 
                         "            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(")

# Fix 6: Fix childAspectRatio syntax on line 79
content = content.replace("              childAspectRatio: 2.5),", "              childAspectRatio: 2.5,\n            ),")

# Fix 7: Fix itemCount on line 80
content = content.replace("      itemCount: bloodTypes.length + 1,", "            itemCount: bloodTypes.length + 1,")

# Write back
with open('lib/presentation/widgets/profile_edit_dialogs/blood_type_edit_dialog.dart', 'w') as f:
    f.write(content)

print("Fixed syntax errors in blood_type_edit_dialog.dart")