#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'r') as f:
    content = f.read()

# Fix patterns of missing commas after Icons
content = re.sub(r'(Icons\.\w+)\);', r'\1,);', content)

# Fix patterns like color: elementColor);
content = re.sub(r'(color:\s*\w+(?:\.withValues\([^)]+\))?)\);', r'\1,);', content)

# Fix patterns like size: AppDimensions.iconSizeSmall,)
content = re.sub(r'(size:\s*AppDimensions\.\w+),\)', r'\1),', content)

# Fix patterns with misplaced closing parentheses
content = re.sub(r'(\s+)\)\)', r'\1),', content)

# Fix Container/BoxDecoration indentation patterns
# This is more complex and needs manual review

# Write the file back
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'w') as f:
    f.write(content)

print("Fixed syntax errors in five_elements_explanation_bottom_sheet.dart")