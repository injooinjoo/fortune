#!/usr/bin/env python3

import re
import os

def fix_fortune_explanation_bottom_sheet():
    """Fix fortune_explanation_bottom_sheet.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart"
    
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix common syntax errors
    # Fix property names
    content = re.sub(r'\bcol:', 'color:', content)
    content = re.sub(r'\bheigh:', 'height:', content)
    content = re.sub(r'\bwidt:', 'width:', content)
    content = re.sub(r'\blef:', 'left:', content)
    content = re.sub(r'\brigh:', 'right:', content)
    content = re.sub(r'\bbotto:', 'bottom:', content)
    content = re.sub(r'\btop,', 'top:', content)
    
    # Fix withValues syntax
    content = re.sub(r'\.withValues\(alph,', '.withValues(alpha:', content)
    content = re.sub(r'\.withValues\(alp,', '.withValues(alpha:', content)
    content = re.sub(r'\.withValues\(alpha\s+a:', '.withValues(alpha:', content)
    
    # Fix method calls
    content = re.sub(r'Theme\.of\(context,\.', 'Theme.of(context).', content)
    content = re.sub(r'MediaQuery\.of\(context,\.', 'MediaQuery.of(context).', content)
    content = re.sub(r'Navigator\.of\(context,\.', 'Navigator.of(context).', content)
    
    # Fix DateTime.now()
    content = re.sub(r'DateTime\.now\(\);', 'DateTime.now(),', content)
    
    # Fix InputDecorator
    content = re.sub(r'child: InputDecorator\(,', 'child: InputDecorator(', content)
    
    # Fix ChoiceChip
    content = re.sub(r'child: ChoiceChip\(,', 'child: ChoiceChip(', content)
    content = re.sub(r'_buildChoiceChip\(,', '_buildChoiceChip(', content)
    
    # Fix style syntax
    content = re.sub(r'style: TextStyle\(,', 'style: TextStyle(', content)
    
    # Fix BoxConstraints
    content = re.sub(r'BoxConstraints\(maxWidt,', 'BoxConstraints(maxWidth:', content)
    content = re.sub(r'h: 180\)', ': 180)', content)
    
    # Fix MBTI items
    content = re.sub(r"items: \['INTJ': 'INTP': 'ENTJ'", "items: ['INTJ', 'INTP', 'ENTJ'", content)
    
    # Fix blood type items
    content = re.sub(r"\.\.\.?\['A': 'B': 'AB', 'O'\]", "...['A', 'B', 'AB', 'O']", content)
    
    # Fix date formatting
    content = re.sub(r"'\$\{([^}]+)\},년", r"'${\1}년", content)
    content = re.sub(r"'\$\{([^}]+)\},월", r"'${\1}월", content)
    content = re.sub(r"'\$\{([^}]+)\},일'", r"'${\1}일'", content)
    
    # Fix Map syntax
    content = re.sub(r"'required': \['name': 'birthDate'\]", "'required': ['name', 'birthDate']", content)
    content = re.sub(r"'optional': \['birthTime': 'gender', 'mbti'\]", "'optional': ['birthTime', 'gender', 'mbti']", content)
    
    # Fix score display
    content = re.sub(r"'\)\)\},%'", "'${score.toStringAsFixed(0)}%'", content)
    content = re.sub(r"'\)\)\},점'", "'${score.toStringAsFixed(0)}점'", content)
    
    # Fix color null issues
    content = re.sub(r"'수': null\},;", "'수': Colors.blue},", content)
    
    # Fix missing commas
    content = re.sub(r'shrinkWrap: true\)', 'shrinkWrap: true,', content)
    content = re.sub(r'\.join\(\':', ".join(',", content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def fix_physiognomy_fortune_page():
    """Fix physiognomy_fortune_page.dart"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    fixed_lines = []
    in_traits = False
    in_advices = False
    
    for i, line in enumerate(lines):
        # Remove duplicate ]; at end of traits
        if "{'name': '리더십', 'icon': Icons.star_rounded, 'color': Colors.blue}];" in line:
            line = "      {'name': '리더십', 'icon': Icons.star_rounded, 'color': Colors.blue},\n"
            in_traits = True
        elif in_traits and "];," in line:
            line = line.replace("];,", ",")
        elif in_traits and "];" in line:
            line = "    ];\n"
            in_traits = False
        
        # Fix widget tree structure
        if "padding: const EdgeInsets.all(20)," in line and i > 0 and "GlassCard(" in lines[i-1]:
            lines[i-1] = lines[i-1].replace("GlassCard(", "GlassCard(\n          padding: const EdgeInsets.all(20),")
            continue
        
        # Fix closing brackets
        if line.strip() == "));" and i > 0:
            context = ""
            for j in range(max(0, i-5), i):
                context += lines[j]
            if "buildAnalysisScore" in context:
                line = "          ]\n        )\n      );\n"
        
        # Fix _buildAnalysisScore calls
        if "_buildAnalysisScore('" in line and not line.strip().endswith("),"):
            line = line.rstrip()
            if line.endswith(","):
                line = line[:-1] + "),\n"
            else:
                line = line + "),\n"
        
        # Fix specific syntax issues
        if "description);" in line and "Text(" in line:
            line = line.replace("description);", "description,")
        
        # Fix Padding widget
        if "padding: const EdgeInsets.symmetric(horizontal: 16," in line:
            line = line.replace("const EdgeInsets.symmetric(horizontal: 16,", "const EdgeInsets.symmetric(horizontal: 16),")
        
        # Fix closing widget trees
        if line.strip() == ")))))):":
            line = "                )\n              )\n            ]\n          )\n        ),\n"
        
        # Fix specific Map syntax
        if "'fortune', '" in line:
            line = re.sub(r"'fortune',\s*'([^']+)'", r"'fortune': '\1'", line)
        
        # Fix specific widget closing
        if "fontWeight: FontWeight.w500))))),." in line:
            line = line.replace("fontWeight: FontWeight.w500))))),.", "fontWeight: FontWeight.w500)))")
        
        # Fix toList() calls
        if "}).toList()))))" in line:
            line = "              }).toList()\n            ]\n          )\n        );\n"
        
        # Fix advices list
        if "'color': Colors.blue}];" in line:
            line = line.replace("'color': Colors.blue}];", "'color': Colors.blue}];\n")
        
        # Fix missing closing brackets
        if "color: theme.colorScheme.onSurface.withValues(alpha: 0.8)))))))," in line:
            line = line.replace("color: theme.colorScheme.onSurface.withValues(alpha: 0.8))))))),", "color: theme.colorScheme.onSurface.withValues(alpha: 0.8)))")
        
        # Fix final toList() calls
        if "}).toList()))))" in line:
            line = "            }).toList()\n          ]\n        )\n      );\n"
        
        fixed_lines.append(line)
    
    # Join and write back
    content = ''.join(fixed_lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def main():
    print("Fixing Flutter syntax errors comprehensively...")
    
    fix_fortune_explanation_bottom_sheet()
    fix_physiognomy_fortune_page()
    
    print("All fixes completed!")

if __name__ == "__main__":
    main()