#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'r') as f:
    content = f.read()

# Fix the specific problematic patterns I saw
replacements = [
    # Fix double commas
    (',,', ','),
    # Fix patterns like ),)
    (')\n                    )\n                ])', '),\n                ],'),
    # Fix style patterns
    ('style: theme.textTheme.titleMedium?.copyWith(\n                            fontWeight: FontWeight.bold,\n                          ),,', 
     'style: theme.textTheme.titleMedium?.copyWith(\n                            fontWeight: FontWeight.bold,\n                          ),'),
    # Fix similar patterns
    ('style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.bold,\n                          ),,', 
     'style: theme.textTheme.titleLarge?.copyWith(\n                            fontWeight: FontWeight.bold,\n                          ),'),
    # Fix Text widget patterns
    ('        ),\n        style:', '        style:'),
    # Fix closing patterns
    ('),\n            ])', '),\n            ],'),
    # Fix patterns like ]]
    ('      ]]', '      ],'),
    # Fix patterns like );
    ('color: AppColors.error);', 'color: AppColors.error,'),
    ('color: AppColors.primary);', 'color: AppColors.primary,'),
    ('color: Colors.amber);', 'color: Colors.amber,'),
    # Fix Icon patterns
    ('    ),\n            SizedBox', '    ),\n            ),\n            SizedBox'),
    # Fix missing parentheses
    ('                          ),)),', '                          ),\n                        ),'),
    # Fix Text patterns
    ('              ),\n              style:', '              style:'),
    ('        ),\n        style:', '        style:'),
    # Fix extra parentheses
    ('),))', '),'),
    (']),)).toList()),', ']).toList(),'),
    # Fix closing patterns
    ('])\n        SizedBox', '],\n        ),\n        SizedBox'),
    # Fix alpha patterns
    ('color: theme.colorScheme.onSurface.withValues(alpha: 0.8,\n                          ),)', 
     'color: theme.colorScheme.onSurface.withValues(alpha: 0.8),'),
    # Fix bracket patterns
    ('              ),\n            ])\n        SizedBox', '              ),\n            ],\n          ),\n        SizedBox'),
    # Fix missing closing
    ('fontWeight: FontWeight.bold),\n                    ),', 'fontWeight: FontWeight.bold,\n                  ),'),
]

for old, new in replacements:
    content = content.replace(old, new)

# Write the file back
with open('lib/presentation/widgets/five_elements_explanation_bottom_sheet.dart', 'w') as f:
    f.write(content)

print("Fixed specific syntax errors in five_elements_explanation_bottom_sheet.dart")