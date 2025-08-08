#!/usr/bin/env python3
"""
Final fix for tarot_deck_spread_widget.dart
"""

import re

def fix_tarot_deck():
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/tarot/tarot_deck_spread_widget.dart', 'r') as f:
        lines = f.readlines()
    
    # Remove extra closing brace at line 80 (index 79)
    if lines[79].strip() == '}':
        lines[79] = ''
    
    # Remove extra closing brace at line 95 (index 94)
    if lines[94].strip() == '}':
        lines[94] = ''
    
    # Join lines and fix remaining issues
    content = ''.join(lines)
    
    # Fix setState in onHorizontalDragUpdate
    content = re.sub(
        r'_currentRotation = \(dragDistance / screenWidth\) \* math\.pi \* 0\.5;\s*\},\s*\);',
        r'_currentRotation = (dragDistance / screenWidth) * math.pi * 0.5;\n        });',
        content
    )
    
    # Fix setState in onHorizontalDragEnd
    content = re.sub(
        r'_currentRotation = 0;\s*\},\s*\);',
        r'_currentRotation = 0;\n        });',
        content
    )
    
    # Fix Stack children List.generate
    content = re.sub(
        r'return _buildFanCard\(index, screenWidth\);\s*\}\)\)\)\)\);',
        r'return _buildFanCard(index, screenWidth);\n          }),\n        ),\n      ),\n    );',
        content
    )
    
    # Fix TarotCardWidget closing parentheses
    content = re.sub(
        r'enableFlipAnimation: false\)\)\)\)\);',
        r'enableFlipAnimation: false,\n              ),\n            ),\n          ),\n        );',
        content
    )
    
    # Fix AnimatedBuilder
    content = re.sub(
        r'\},\s*\);',
        r'      },\n    );',
        content
    )
    
    # Fix TarotCardEntrance child
    content = re.sub(
        r'onTap: \(\) => _handleCardTap\(index\)\)\)\);',
        r'onTap: () => _handleCardTap(index),\n          ),\n        );',
        content
    )
    
    # Fix Transform in stack spread
    content = re.sub(
        r'onTap: isTop \? \(\) => _handleCardTap\(index\) : null,\s*\),\s*\);\s*\},\s*\);',
        r'onTap: isTop ? () => _handleCardTap(index) : null,\n                  ),\n                ),\n              );\n            },\n          );',
        content
    )
    
    # Fix Stack closing
    content = re.sub(
        r'\.reversed\.toList\(\)\)\)\);',
        r'.reversed.toList(),\n      ),\n    );',
        content
    )
    
    # Fix class closing brace
    if not content.rstrip().endswith('}'):
        # Find the last method and ensure class closes properly
        lines = content.split('\n')
        # Look for the _buildStackSpread method end
        for i in range(len(lines) - 1, -1, -1):
            if '  }' in lines[i] and i > 220:  # Approximate location
                # Check if next line starts enum
                if i < len(lines) - 1 and '/// Different spread types' in lines[i+1]:
                    lines.insert(i+1, '}')
                    lines.insert(i+2, '')
                    break
        content = '\n'.join(lines)
    
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/tarot/tarot_deck_spread_widget.dart', 'w') as f:
        f.write(content)
    
    print("Fixed tarot_deck_spread_widget.dart - final pass")

if __name__ == "__main__":
    fix_tarot_deck()