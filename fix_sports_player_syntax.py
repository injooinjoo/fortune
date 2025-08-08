#!/usr/bin/env python3
import re

def fix_syntax_errors(content):
    """Fix common syntax errors in the Dart file"""
    
    # Fix pattern: 'text': value -> 'text', value
    content = re.sub(r"'([^']+)':\s*([^,\n]+)([,\)])", r"'\1', \2\3", content)
    
    # Fix pattern: );semicolon -> ),
    content = re.sub(r'\);\s*([a-zA-Z])', r'), \1', content)
    
    # Fix pattern: color: Color) -> color: Color),
    content = re.sub(r'(color|size|fontSize|fontWeight):\s*([^)]+)\)\)(?!\))', r'\1: \2)),', content)
    
    # Fix pattern: Text('text',); -> Text('text',
    content = re.sub(r"(Text|Icon)\s*\(\s*([^)]+),\s*\);", r"\1(\2,", content)
    
    # Fix pattern: decoration: BoxDecoration( ... )); ... border: -> decoration: BoxDecoration( ... border:
    content = re.sub(r'(decoration:\s*BoxDecoration\([^}]+)\)\),\s*border:', r'\1, border:', content)
    
    # Fix pattern: Colors.xxx) -> Colors.xxx),
    content = re.sub(r'(Colors\.[a-zA-Z]+(?:\.\w+\([^)]+\))?)\)(?=[,\s]*[a-zA-Z])', r'\1),', content)
    
    # Fix pattern: style: TextStyle(...); -> style: TextStyle(...),
    content = re.sub(r'(style:\s*(?:const\s+)?TextStyle\([^)]+\));(?!\s*})', r'\1),', content)
    
    # Fix pattern: fontSize: 14); -> fontSize: 14,
    content = re.sub(r'(fontSize|fontWeight|fontStyle):\s*([^)]+)\);', r'\1: \2,', content)
    
    # Fix pattern: BorderRadius.circular(x))) -> BorderRadius.circular(x))
    content = re.sub(r'(BorderRadius\.circular\(\d+\))\)\)', r'\1)', content)
    
    # Fix mismatched parentheses around child widgets
    content = re.sub(r'\)\)\)\s*(?=child:)', r'), ', content)
    
    # Fix gradientColors line
    content = content.replace('    gradientColors: const [Color(0xFF00897B), Color(0xFF00BFA5)]),', 
                              '      gradientColors: const [Color(0xFF00897B), Color(0xFF00BFA5)],')
    content = content.replace('    delay: 0);', '      delay: 0);')
    
    # Fix decoration blocks
    content = content.replace('        color: AppColors.surface);', '        color: AppColors.surface,')
    content = content.replace('        borderRadius: BorderRadius.circular(16))),', '        borderRadius: BorderRadius.circular(16),')
    content = content.replace('    border: Border.all(color: const Color(0xFF00897B).withOpacity(0.3))\n      ),',
                              '        border: Border.all(color: const Color(0xFF00897B).withOpacity(0.3))),')
    
    # Fix child: Column indentation
    content = content.replace('    child: Column(', '      child: Column(')
    
    # Fix Text widget with emoji
    content = content.replace("'훈련 팁 🏃‍♂️');", "'훈련 팁 🏃‍♂️',")
    content = content.replace("'멘탈 코칭 🧠');", "'멘탈 코칭 🧠',")
    
    # Fix Icon widget
    content = content.replace('Icons.sports_score);', 'Icons.sports_score,')
    content = content.replace('size: 16),', 'size: 16,')
    content = content.replace('color: Color(0xFF00897B))', 'color: Color(0xFF00897B)),')
    
    # Fix style blocks
    content = re.sub(r'style:\s*TextStyle\(\s*fontSize:\s*(\d+);\s*fontWeight:\s*([^)]+)\),\s*color:\s*([^)]+)\)\)',
                     r'style: TextStyle(fontSize: \1, fontWeight: \2, color: \3))', content)
    
    # Fix list ending
    content = content.replace('    style: const TextStyle(fontSize: 14)))])))        ])',
                              '                    style: const TextStyle(fontSize: 14))),\n              ],\n            ),\n          )).toList(),\n        ],\n      ),')
    
    # Fix if conditions
    content = content.replace('if (\\1)', 'if (mental[\'motivation\'] != null)')
    
    # Fix final Text widgets
    content = content.replace("'💪 ${mental['motivation']}');", "'💪 ${mental['motivation']}',")
    content = content.replace("'🎯 ${mental['mindset']}');", "'🎯 ${mental['mindset']}',")
    content = content.replace('style: const TextStyle(fontSize: 14))]', 'style: const TextStyle(fontSize: 14)),\n          ],')
    content = content.replace('        ])\n    );', '        ],\n      ),\n    );')
    
    return content

# Read the file
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/sports_player_fortune_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix syntax errors
fixed_content = fix_syntax_errors(content)

# Write back
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/sports_player_fortune_page.dart', 'w', encoding='utf-8') as f:
    f.write(fixed_content)

print("Fixed sports_player_fortune_page.dart")