#!/usr/bin/env python3

import re

def fix_physiognomy_comprehensive():
    """Comprehensive fix for physiognomy_fortune_page.dart syntax errors"""
    
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix Map syntax - : instead of ,
    content = re.sub(r"'(big|small|round|almond|droopy|upturned|high|low|straight|hooked|snub|wide|full|thin|heart|uneven|thick|narrow|pointed|rounded|square|receding|protruding|tall|short)',\s*'", r"'\1': '", content)
    
    # Fix missing closing brackets in Maps
    content = re.sub(r"('thin': '얇은 귀',)\n\s*('protruding', '돌출된 귀'\))", r"\1\n      \2", content)
    content = re.sub(r"'protruding', '돌출된 귀'\)", "'protruding': '돌출된 귀'\n    }", content)
    content = re.sub(r"'rounded', '둥근 이마'\)", "'rounded': '둥근 이마'\n    }", content)
    content = re.sub(r"'protruding', '나온 턱'\)", "'protruding': '나온 턱'\n    }", content)
    
    # Fix semicolons and parentheses issues
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Fix Icon syntax
        if 'Icons.face_rounded);' in line:
            line = line.replace('Icons.face_rounded);', 'Icons.face_rounded,')
        if 'size: 48),' in line:
            line = line.replace('size: 48),', 'size: 48,')
        if 'Icons.face_retouching_natural_rounded);' in line:
            line = line.replace('Icons.face_retouching_natural_rounded);', 'Icons.face_retouching_natural_rounded,')
        if 'Icons.psychology_rounded);' in line:
            line = line.replace('Icons.psychology_rounded);', 'Icons.psychology_rounded,')
        if 'Icons.auto_awesome_rounded);' in line:
            line = line.replace('Icons.auto_awesome_rounded);', 'Icons.auto_awesome_rounded,')
        if 'Icons.tips_and_updates_rounded);' in line:
            line = line.replace('Icons.tips_and_updates_rounded);', 'Icons.tips_and_updates_rounded,')
        
        # Fix widget closing issues
        if 'entry.value);' in line and 'Text(' in line:
            line = line.replace('entry.value);', 'entry.value,')
        if 'label);' in line and 'Text(' in line:
            line = line.replace('label);', 'label,')
        if 'description);' in line and 'Text(' in line:
            line = line.replace('description);', 'description,')
        
        # Fix style property issues
        if 'theme.textTheme.headlineSmall)' in line and not line.strip().endswith(','):
            line = line.replace('theme.textTheme.headlineSmall)', 'theme.textTheme.headlineSmall),')
        if 'fontWeight: FontWeight.bold))' in line and not line.strip().endswith(','):
            line = line.replace('fontWeight: FontWeight.bold))', 'fontWeight: FontWeight.bold)),')
        
        # Fix specific bracket issues
        if line.strip() == 'color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),':
            line = '                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),'
        if line.strip() == 'color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))))),':
            line = '                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))'
        
        # Fix trailing parentheses
        if line.strip() == 'padding: const EdgeInsets.symmetric(vertical: 12))))))):':
            line = '                          padding: const EdgeInsets.symmetric(vertical: 12)))'
        
        # Fix widget function parameter syntax
        if '_buildFeatureDropdown(' in line and ')' in line and ',' not in line:
            line = line.replace('_eyebrowTypes)', '_eyebrowTypes,')
            line = line.replace('_eyeTypes)', '_eyeTypes,')
            line = line.replace('_noseTypes)', '_noseTypes,')
            line = line.replace('_lipTypes)', '_lipTypes,')
        
        # Fix function parameter lines
        if 'Function(String?) onChanged,' in line:
            next_line_idx = i + 1
            if next_line_idx < len(lines) and 'Icons.' in lines[next_line_idx]:
                line = line.rstrip(',')
        
        # Fix hintText syntax
        if "hintText: '$label 형태를 선택하세요');" in line:
            line = line.replace("hintText: '$label 형태를 선택하세요');", "hintText: '$label 형태를 선택하세요',")
        if "hintText: '선택하세요');" in line:
            line = line.replace("hintText: '선택하세요');", "hintText: '선택하세요',")
        
        # Fix DropdownMenuItem syntax
        if 'value: entry.key);' in line:
            line = line.replace('value: entry.key);', 'value: entry.key,')
        if 'child: Text(entry.value));' in line:
            line = line.replace('child: Text(entry.value));', 'child: Text(entry.value));')
        if 'value: null);' in line:
            line = line.replace('value: null);', 'value: null,')
        if 'child: Text(\'선택 안함\'));' in line:
            line = line.replace('child: Text(\'선택 안함\'));', 'child: Text(\'선택 안함\')),')
        
        # Fix Map property syntax in traits
        if "'name', '리더십':" in line:
            line = line.replace("'name', '리더십':", "'name': '리더십',")
        if "'name', '창의성':" in line:
            line = line.replace("'name', '창의성':", "'name': '창의성',")
        if "'name', '공감능력':" in line:
            line = line.replace("'name', '공감능력':", "'name': '공감능력',")
        if "'name', '분석력':" in line:
            line = line.replace("'name', '분석력':", "'name': '분석력',")
        if "'name', '인내심'," in line:
            line = line.replace("'name', '인내심',", "'name': '인내심',")
        if "'name', '소통능력'," in line:
            line = line.replace("'name', '소통능력',", "'name': '소통능력',")
        
        # Fix color property
        if "'icon': Icons." in line and "'color'}" in line:
            line = re.sub(r"'color'\}", "'color': Colors.blue}", line)
        if "'color': Colors.orange}" in line and line.strip().endswith(';'):
            line = line.replace(';', ']')
        
        # Fix feature map syntax
        if "'feature', '눈'," in line:
            line = line.replace("'feature', '눈',", "'feature': '눈',")
        if "'feature', '코'," in line:
            line = line.replace("'feature', '코',", "'feature': '코',")
        if "'feature', '입'," in line:
            line = line.replace("'feature', '입',", "'feature': '입',")
        if "'feature', '이마'," in line:
            line = line.replace("'feature', '이마',", "'feature': '이마',")
        
        # Fix interpretation and fortune properties
        if "'interpretation'," in line:
            line = line.replace("'interpretation',", "'interpretation':")
        if "'fortune'," in line and ':' in line:
            line = re.sub(r"'fortune',\s*'([^']+)':\s*,", r"'fortune': '\1',", line)
        
        # Fix advice map syntax
        if "'category', '" in line:
            line = re.sub(r"'category',\s*'(\w+)',", r"'category': '\1',", line)
        if "'advice'," in line:
            line = line.replace("'advice',", "'advice':")
        if "'color': null," in line and '{' in line:
            line = line.replace("'color': null,", "'color': Colors.green},")
        elif "'color': null," in line:
            line = line.replace("'color': null,", "'color': Colors.orange},")
        if "'color': Colors.blue;" in line:
            line = line.replace("'color': Colors.blue;", "'color': Colors.blue}")
        
        # Fix specific syntax issues
        if 'trait[\'icon\'] as IconData);' in line:
            line = line.replace('trait[\'icon\'] as IconData);', 'trait[\'icon\'] as IconData,')
        if 'trait[\'name\'],' in line:
            line = line.replace('trait[\'name\'],', 'trait[\'name\'] as String,')
        if 'item[\'icon\'] as IconData);' in line:
            line = line.replace('item[\'icon\'] as IconData);', 'item[\'icon\'] as IconData,')
        if 'item[\'feature\'] as String);' in line:
            line = line.replace('item[\'feature\'] as String);', 'item[\'feature\'] as String,')
        if 'item[\'interpretation\'] as String);' in line:
            line = line.replace('item[\'interpretation\'] as String);', 'item[\'interpretation\'] as String,')
        if 'item[\'category\'] as String);' in line:
            line = line.replace('item[\'category\'] as String);', 'item[\'category\'] as String,')
        if 'item[\'advice\'] as String);' in line:
            line = line.replace('item[\'advice\'] as String);', 'item[\'advice\'] as String,')
        
        # Fix specific closing bracket issues
        if 'const EdgeInsets.symmetric(horizontal: 16,' in line:
            line = line.replace('const EdgeInsets.symmetric(horizontal: 16,', 'const EdgeInsets.symmetric(horizontal: 16),')
        if 'const EdgeInsets.all(20,' in line:
            line = line.replace('const EdgeInsets.all(20,', 'const EdgeInsets.all(20),')
        
        # Fix shrinkWrap syntax
        if 'shrinkWrap: true);' in line:
            line = line.replace('shrinkWrap: true);', 'shrinkWrap: true,')
        
        # Fix score display syntax
        if "'Fortune cached'," in line:
            line = line.replace("'Fortune cached',", "'${score}%',")
        if 'value: score / 100);' in line:
            line = line.replace('value: score / 100);', 'value: score / 100,')
        
        # Fix style property closing
        if 'theme.textTheme.bodySmall);' in line:
            line = line.replace('theme.textTheme.bodySmall);', 'theme.textTheme.bodySmall,')
        if 'fontWeight: FontWeight.w500))));' in line:
            line = line.replace('fontWeight: FontWeight.w500))));', 'fontWeight: FontWeight.w500)))')
        if 'fontWeight: FontWeight.bold);' in line:
            line = line.replace('fontWeight: FontWeight.bold);', 'fontWeight: FontWeight.bold),')
        
        # Fix closing bracket sequences
        if line.strip() == '.toList()))));':
            line = '              }).toList()\n            ]\n          )\n        );'
        if line.strip() == ',.toList())));':
            line = '            )).toList()\n          ]\n        )\n      );'
        
        # Fix missing closing brackets
        if '_buildAnalysisScore(\'' in line and not line.strip().endswith(')') and not line.strip().endswith(','):
            line = line.rstrip() + '),'
        
        # Fix method signature
        if 'Map<String, String> options);' in line:
            line = line.replace('Map<String, String> options);', 'Map<String, String> options,')
        
        fixed_lines.append(line)
    
    # Join content
    content = '\n'.join(fixed_lines)
    
    # Fix remaining issues
    content = re.sub(r'Icons\.lightbulb_rounded;', 'Icons.lightbulb_rounded}]', content)
    content = re.sub(r'color: theme\.colorScheme\.primary\);', 'color: theme.colorScheme.primary),', content)
    content = re.sub(r'color: trait\[\'color\'\]\),', 'color: trait[\'color\'] as Color),', content)
    
    # Fix Map closing brackets
    content = re.sub(r"('thin': '얇은 눈썹',)\n", r"\1\n  };\n", content)
    content = re.sub(r"('upturned': '올라간 눈',)\n", r"\1\n  };\n", content)
    content = re.sub(r"('wide': '넓은 코',)\n", r"\1\n  };\n", content)
    content = re.sub(r"('uneven': '비대칭 입술',)\n", r"\1\n  };\n", content)
    
    # Fix method calls with missing commas
    content = re.sub(r'_buildFeatureDropdown\(\n\s*\'([^\']+)\',\n\s*([^,]+),\n\s*([^)]+)\)\n\s*\(value\)', r'_buildFeatureDropdown(\n                \'\1\',\n                \2,\n                \3,\n                (value)', content)
    
    # Fix widget tree closing
    content = re.sub(r'\]\n\s*\)\n\s*\)\n\s*\)\n\s*\)\n\s*\)\n\s*\);', ']\n          )\n        ),', content)
    
    # Write the fixed content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Comprehensively fixed {file_path}")

if __name__ == "__main__":
    fix_physiognomy_comprehensive()