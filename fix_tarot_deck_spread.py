#!/usr/bin/env python3
"""
Fix syntax errors in tarot_deck_spread_widget.dart
"""

import re

def fix_tarot_deck_spread():
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/tarot/tarot_deck_spread_widget.dart', 'r') as f:
        content = f.read()
    
    # Fix missing closing braces for methods
    # Fix initState
    content = re.sub(
        r'fanController\.forward\(\);\n\}',
        r'fanController.forward();\n  }',
        content
    )
    
    # Fix dispose
    content = re.sub(
        r'super\.dispose\(\);\n\}',
        r'super.dispose();\n  }',
        content
    )
    
    # Fix _handleCardTap
    content = re.sub(
        r'widget\.onCardSelected\(index\);\n\}',
        r'widget.onCardSelected(index);\n    }\n  }',
        content
    )
    
    # Fix build switch statement
    content = re.sub(
        r'return _buildStackSpread\(\);\n\}',
        r'return _buildStackSpread();\n    }\n  }',
        content
    )
    
    # Fix onHorizontalDragStart
    content = re.sub(
        r'_dragStartX = details\.globalPosition\.dx;\n\},',
        r'_dragStartX = details.globalPosition.dx;\n      },',
        content
    )
    
    # Fix onHorizontalDragUpdate setState
    content = re.sub(
        r'\(dragDistance / screenWidth\) \* math\.pi \* 0\.5;\n\}\);',
        r'(dragDistance / screenWidth) * math.pi * 0.5;\n        });',
        content
    )
    
    content = re.sub(
        r'\}\);\n\},',
        r'        });\n      },',
        content
    )
    
    # Fix onHorizontalDragEnd setState
    content = re.sub(
        r'_currentRotation = 0;\n\}\);',
        r'_currentRotation = 0;\n        });',
        content
    )
    
    # Fix Stack children
    content = re.sub(
        r'return _buildFanCard\(index, screenWidth\);\n\s*\}\)\)\)\)\);',
        r'return _buildFanCard(index, screenWidth);\n          }),\n        ),\n      ),\n    );',
        content
    )
    
    # Fix TarotCardWidget closing
    content = re.sub(
        r'enableFlipAnimation: false\)\)\)\)\);',
        r'enableFlipAnimation: false,\n              ),\n            ),\n          ),\n        );',
        content
    )
    
    # Fix AnimatedBuilder closing
    content = re.sub(
        r'\}\);',
        r'      },\n    );',
        content
    )
    
    # Fix crossAxisCount calculation
    content = re.sub(
        r'\(MediaQuery\.of\(context\)\.size\.width / \(widget\.cardWidth \+ 16\),\.floor\(\);',
        r'(MediaQuery.of(context).size.width / (widget.cardWidth + 16)).floor();',
        content
    )
    
    # Fix TarotCardEntrance closing
    content = re.sub(
        r'onTap: \(\) => _handleCardTap\(index\)\)\)\);',
        r'onTap: () => _handleCardTap(index),\n          ),\n        );',
        content
    )
    
    # Fix GridView.builder closing
    content = re.sub(
        r'itemBuilder: \(context, index\) \{[^}]+\}\s*\}\);',
        lambda m: m.group(0).replace('    });', '      },\n    );'),
        content,
        flags=re.DOTALL
    )
    
    # Fix Transform translate/scale
    content = re.sub(
        r'\.\.translate\(offset \* progress, offset \* progress, index\.toDouble\(\),\s*\.\.scale\(1\.0 - \(index \* 0\.02\), 1\.0 - \(index \* 0\.02\),',
        r'..translate(offset * progress, offset * progress, index.toDouble())\n                  ..scale(1.0 - (index * 0.02), 1.0 - (index * 0.02)),',
        content
    )
    
    # Fix TarotCardWidget in stack
    content = re.sub(
        r'onTap: isTop \? \(\) => _handleCardTap\(index\) : null\)\);',
        r'onTap: isTop ? () => _handleCardTap(index) : null,\n                  ),\n                );',
        content
    )
    
    # Fix AnimatedBuilder in stack
    content = re.sub(
        r'return Transform\([^}]+\}\);',
        lambda m: m.group(0).replace('            });', '            },\n          );') if 'Transform(' in m.group(0) else m.group(0),
        content,
        flags=re.DOTALL
    )
    
    # Fix Stack closing
    content = re.sub(
        r'reversed\.toList\(\)\)\)\);',
        r'reversed.toList(),\n      ),\n    );',
        content
    )
    
    # Fix the final closing brace for the class
    content = re.sub(
        r'\n\}\n\n/// Different spread types',
        r'\n  }\n}\n\n/// Different spread types',
        content
    )
    
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/widgets/tarot/tarot_deck_spread_widget.dart', 'w') as f:
        f.write(content)
    
    print("Fixed tarot_deck_spread_widget.dart")

if __name__ == "__main__":
    fix_tarot_deck_spread()