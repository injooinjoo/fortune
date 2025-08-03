#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/profile_edit_dialogs/mbti_edit_dialog.dart', 'r') as f:
    content = f.read()

# Fix various syntax errors
replacements = [
    # Fix SizedBox patterns
    (r'SizedBox\(height: AppSpacing\.spacing\d+,\s*\),', 
     lambda m: m.group(0).replace(',\n                          ),', '),')),
    
    # Fix maxHeight typo
    ('maxHeigh,\n      t:', 'maxHeight:'),
    
    # Fix SingleChildScrollView pattern
    ('SingleChildScrollView(,\n      child:', 'SingleChildScrollView(\n              child:'),
    
    # Fix GridView.builder pattern
    ('GridView.builder(\n                    shrinkWrap: true,\n              ),', 
     'GridView.builder(\n                    shrinkWrap: true,'),
    
    # Fix SliverGridDelegateWithFixedCrossAxisCount pattern
    ('SliverGridDelegateWithFixedCrossAxisCount(,\n      crossAxisCount:', 
     'SliverGridDelegateWithFixedCrossAxisCount(\n                      crossAxisCount:'),
]

for old, new in replacements:
    if isinstance(new, str):
        content = content.replace(old, new)
    else:
        content = re.sub(old, new, content)

# Write back
with open('lib/presentation/widgets/profile_edit_dialogs/mbti_edit_dialog.dart', 'w') as f:
    f.write(content)

print("Fixed syntax errors in mbti_edit_dialog.dart")