#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/profile_edit_dialogs/birth_time_edit_dialog.dart', 'r') as f:
    content = f.read()

# Fix TimePeriod constructor calls
# Pattern: TimePeriod(value: 'xxx': label: 'xxx': description: 'xxx',
# Should be: TimePeriod(value: 'xxx', label: 'xxx', description: 'xxx'),

pattern = r"TimePeriod\(value: '([^']+)': label: '([^']+)': description: '([^']+)',"
replacement = r"TimePeriod(value: '\1', label: '\2', description: '\3'),"

content = re.sub(pattern, replacement, content)

# Write back
with open('lib/presentation/widgets/profile_edit_dialogs/birth_time_edit_dialog.dart', 'w') as f:
    f.write(content)

print("Fixed TimePeriod constructor syntax in birth_time_edit_dialog.dart")