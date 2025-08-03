#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'r') as f:
    content = f.read()

# Fix double commas
content = re.sub(r',,', ',', content)

# Fix patterns with extra closing parentheses
content = re.sub(r'style:\s*theme\.textTheme\.\w+\?\.\w+\(([^)]+)\),,', r'style: theme.textTheme.\1?.copyWith(\2),', content)

# Fix wrong placements of style
content = re.sub(r'(\),)\s*style:\s*theme\.textTheme\.\w+\?\.\w+\(([^)]+)\),,', r'),', content)

# Fix missing closing parentheses in Text widgets
content = re.sub(r'(Text\(\s*[\'"][^\'"]+(\'"])\s*),\s*\),\s*style:', r'\1,\n              style:', content)

# Fix patterns like ],)
content = re.sub(r'\]\),', '],', content)

# Fix patterns like ]]
content = re.sub(r'\]\]', '],', content)

# Fix patterns where ); is missing a comma
content = re.sub(r'(Icons\.\w+),\);', r'\1,', content)

# Fix patterns like fontWeight: FontWeight.bold),
content = re.sub(r'(fontWeight:\s*FontWeight\.\w+)\),\s*\),', r'\1,\n                          ),', content)

# Fix patterns like color: elementColor,)
content = re.sub(r'(color:\s*\w+(?:\.withValues\([^)]+\))?),\)', r'\1),', content)

# Write the file back
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'w') as f:
    f.write(content)

print("Fixed more syntax errors in five_elements_explanation_bottom_sheet.dart")