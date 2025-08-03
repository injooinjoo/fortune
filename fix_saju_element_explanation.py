#!/usr/bin/env python3
import re

# Read the file
with open('lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart', 'r') as f:
    content = f.read()

# Fix 1: Column syntax on line 138
content = content.replace("    child: Column(,", "        child: Column(")

# Fix 2: SingleChildScrollView syntax on line 143
content = content.replace("                child: SingleChildScrollView(,", "                child: SingleChildScrollView(")

# Fix 3: padding syntax on lines 146-147
content = content.replace("              ),\n              padding: EdgeInsets.symmetric(horizonta,\n      l: AppSpacing.spacing5),", 
                         "                  controller: _scrollController,\n                  padding: EdgeInsets.symmetric(\n                    horizontal: AppSpacing.spacing5,\n                  ),")

# Fix 4: Column syntax on line 148
content = content.replace("                  child: Column(,", "                  child: Column(")

# Fix 5: CrossAxisAlignment syntax on lines 149-151
content = content.replace("      crossAxisAlignment: CrossAxisAlignment.start,\n              ),\n              children: [", 
                         "                    crossAxisAlignment: CrossAxisAlignment.start,\n                    children: [")

# Write back
with open('lib/presentation/widgets/saju_element_explanation_bottom_sheet.dart', 'w') as f:
    f.write(content)

print("Fixed syntax errors in saju_element_explanation_bottom_sheet.dart")