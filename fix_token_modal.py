#!/usr/bin/env python3
"""
Fix syntax errors in token_insufficient_modal.dart
"""

import re

def fix_token_modal():
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/shared/components/token_insufficient_modal.dart', 'r') as f:
        content = f.read()
    
    # Fix constructor parameter syntax
    content = re.sub(
        r'const TokenInsufficientModal\(\s*\{\s*Key\? key,\s*required this\.requiredTokens,\s*required this\.fortuneType\)\}\)',
        r'const TokenInsufficientModal({\n    Key? key,\n    required this.requiredTokens,\n    required this.fortuneType,\n  })',
        content
    )
    
    # Fix static Future<bool> show method
    content = re.sub(
        r'static Future<bool> show\(\s*\{\s*required BuildContext context,\s*required int,\s*requiredTokens,\s*required String fortuneType\)\}\)',
        r'static Future<bool> show({\n    required BuildContext context,\n    required int requiredTokens,\n    required String fortuneType,\n  })',
        content
    )
    
    # Fix TokenInsufficientModal instantiation with extra comma
    content = re.sub(
        r'TokenInsufficientModal\(,\s*requiredTokens:',
        r'TokenInsufficientModal(\n        requiredTokens:',
        content
    )
    
    # Fix missing parenthesis
    content = re.sub(
        r'fortuneType: fortuneType\)\)',
        r'fortuneType: fortuneType,\n      ),\n    );',
        content
    )
    
    # Fix AnimationController
    content = re.sub(
        r'AnimationController\(\s*vsync: this\),\s*duration:',
        r'AnimationController(\n      vsync: this,\n      duration:',
        content
    )
    
    # Fix closing for AnimationController  
    content = re.sub(
        r'duration: AppAnimations\.medium\s*\);',
        r'duration: AppAnimations.medium,\n    );',
        content
    )
    
    # Fix Tween animations
    content = re.sub(
        r'end: 1\.0\)\)\.animate\(CurvedAnimation\(,',
        r'end: 1.0,\n    ).animate(CurvedAnimation(',
        content
    )
    
    content = re.sub(
        r'parent: _animationController\),\s*curve:',
        r'parent: _animationController,\n      curve:',
        content
    )
    
    content = re.sub(
        r'curve: Curves\.easeOutBack\)',
        r'curve: Curves.easeOutBack,\n    ))',
        content
    )
    
    content = re.sub(
        r'curve: Curves\.easeIn\)',
        r'curve: Curves.easeIn,\n    ))',
        content
    )
    
    # Fix ScaleTransition and Dialog
    content = re.sub(
        r'ScaleTransition\(,\s*scale:',
        r'ScaleTransition(\n        scale:',
        content
    )
    
    content = re.sub(
        r'Dialog\(,\s*backgroundColor: Colors\.transparent\),\s*child: GlassContainer\(,',
        r'Dialog(\n          backgroundColor: Colors.transparent,\n          child: GlassContainer(',
        content
    )
    
    # Fix BoxDecoration issues
    content = re.sub(
        r'decoration: BoxDecoration\(,\s*shape: BoxShape\.circle\),\s*color:',
        r'decoration: BoxDecoration(\n                    shape: BoxShape.circle,\n                    color:',
        content
    )
    
    # Fix withValues issues - replace alp,ha with alpha
    content = re.sub(r'\.withValues\(alp,\s*ha:\s*([0-9.]+)\)', r'.withValues(alpha: \1)', content)
    content = re.sub(r'\.withValues\(alph,\s*a:\s*([0-9.]+)\)', r'.withValues(alpha: \1)', content)
    
    # Fix Icon closing
    content = re.sub(
        r'color: theme\.colorScheme\.error\)\)',
        r'color: theme.colorScheme.error,\n                  ),\n                )',
        content
    )
    
    # Fix Text issues
    content = re.sub(
        r"Text\(\s*'영혼이 부족합니다'\),\s*style:",
        r"Text(\n                  '영혼이 부족합니다',\n                  style:",
        content
    )
    
    content = re.sub(
        r"copyWith\(,\s*fontWeight: FontWeight\.bold\)\)\)",
        r"copyWith(\n                    fontWeight: FontWeight.bold,\n                  ),\n                )",
        content
    )
    
    # Fix textAlign
    content = re.sub(
        r'textAlign: TextAlign\.center\);',
        r'textAlign: TextAlign.center,\n                )',
        content
    )
    
    # Fix Container with padding
    content = re.sub(
        r'padding: AppSpacing\.paddingAll16\),\s*decoration: BoxDecoration\(,\s*color:',
        r'padding: AppSpacing.paddingAll16,\n                  decoration: BoxDecoration(\n                    color:',
        content
    )
    
    content = re.sub(
        r'borderRadius: AppDimensions\.borderRadiusMedium\),\s*child: Row\(,\s*mainAxisAlignment:',
        r'borderRadius: AppDimensions.borderRadiusMedium,\n                  ),\n                  child: Row(\n                    mainAxisAlignment:',
        content
    )
    
    # Fix _buildTokenInfo calls
    content = re.sub(
        r"color: theme\.colorScheme\.primary\);",
        r"color: theme.colorScheme.primary,\n                      )",
        content
    )
    
    content = re.sub(
        r"color: theme\.colorScheme\.error\);",
        r"color: theme.colorScheme.error,\n                      )",
        content
    )
    
    # Fix Container height issues
    content = re.sub(
        r'height: AppDimensions\.buttonHeightSmall\),\s*color:',
        r'height: AppDimensions.buttonHeightSmall,\n                        color:',
        content
    )
    
    # Fix the closing of Row
    content = re.sub(
        r"label: '부족'\),\s*value: \(widget\.requiredTokens - remainingTokens\)\.toString\(\),\s*color: theme\.colorScheme\.error\)\s*\]\)\)\)",
        r"label: '부족',\n                        value: '${widget.requiredTokens - remainingTokens}개',\n                        color: theme.colorScheme.error,\n                      ),\n                    ],\n                  ),\n                )",
        content
    )
    
    # Fix bodyLarge style
    content = re.sub(
        r"style: theme\.textTheme\.bodyLarge\);",
        r"style: theme.textTheme.bodyLarge,\n                )",
        content
    )
    
    # Fix _buildActionButton calls
    content = re.sub(
        r"_buildActionButton\(,\s*icon:",
        r"_buildActionButton(\n                        icon:",
        content
    )
    
    content = re.sub(
        r"color: theme\.colorScheme\.primary\),\s*onTap:",
        r"color: theme.colorScheme.primary,\n                        onTap:",
        content
    )
    
    content = re.sub(
        r"color: AppColors\.success\),\s*onTap:",
        r"color: AppColors.success,\n                        onTap:",
        content
    )
    
    content = re.sub(
        r"}\)\)\)",
        r"},\n                      ),\n                    )",
        content, count=2
    )
    
    # Fix Row children closing
    content = re.sub(
        r"\]\)",
        r"],\n                )",
        content, count=1
    )
    
    # Fix gradient BoxDecoration
    content = re.sub(
        r'decoration: BoxDecoration\(,\s*gradient:',
        r'decoration: BoxDecoration(\n                    gradient:',
        content
    )
    
    content = re.sub(
        r'\.withValues\(alpha: 0\.2\)\]\),\s*borderRadius:',
        r'.withValues(alpha: 0.2),\n                      ],\n                    ),\n                    borderRadius:',
        content
    )
    
    content = re.sub(
        r'border: Border\.all\(,\s*color:',
        r'border: Border.all(\n                      color:',
        content
    )
    
    content = re.sub(
        r'\.withValues\(alpha: 0\.5\)\)\),\s*child: Material\(,\s*color: Colors\.transparent\),\s*child: InkWell\(,',
        r'.withValues(alpha: 0.5),\n                    ),\n                  ),\n                  child: Material(\n                    color: Colors.transparent,\n                    child: InkWell(',
        content
    )
    
    # Fix InkWell
    content = re.sub(
        r'}\s*borderRadius: AppDimensions\.borderRadiusMedium,\s*child: Padding\(,\s*padding:',
        r'},\n                      borderRadius: AppDimensions.borderRadiusMedium,\n                      child: Padding(\n                        padding:',
        content
    )
    
    content = re.sub(
        r'child: Row\(,\s*children:',
        r'child: Row(\n                          children:',
        content
    )
    
    # Fix Icon in subscription option
    content = re.sub(
        r"color: theme\.colorScheme\.primary\);",
        r"color: theme.colorScheme.primary,\n                            )",
        content
    )
    
    # Fix Column
    content = re.sub(
        r'child: Column\(\s*crossAxisAlignment:',
        r'child: Column(\n                                crossAxisAlignment:',
        content
    )
    
    # Fix Text for unlimited subscription
    content = re.sub(
        r"Text\(\s*'무제한 이용권'\),\s*style:",
        r"Text(\n                                    '무제한 이용권',\n                                    style:",
        content
    )
    
    # Fix the nested parentheses at the end
    content = re.sub(
        r'\]\)\)\)\)\)\)\)\)\)',
        r'],\n                        ),\n                      ),\n                    ),\n                  ),\n                )',
        content
    )
    
    content = re.sub(
        r'style: AppTypography\.button\)\)\s*\]\)\)\)\)\)\)\)\)\)',
        r'style: AppTypography.button,\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );',
        content
    )
    
    # Fix _buildTokenInfo parameter definition
    content = re.sub(
        r'Widget _buildTokenInfo\(\s*\{\s*required String label,\s*required String value,\s*required Color color\)\}\)',
        r'Widget _buildTokenInfo({\n    required String label,\n    required String value,\n    required Color color,\n  })',
        content
    )
    
    # Fix the body of _buildTokenInfo
    content = re.sub(
        r"Text\(\s*label,\s*style: theme\.textTheme\.bodySmall\?\.copyWith\(,\s*color:",
        r"Text(\n                          label,\n                          style: theme.textTheme.bodySmall?.copyWith(\n                            color:",
        content
    )
    
    content = re.sub(
        r"\.withValues\(alpha: 0\.6\)\)\s*SizedBox",
        r".withValues(alpha: 0.6),\n                          ),\n                        ),\n        SizedBox",
        content
    )
    
    content = re.sub(
        r"Text\(\s*value\),\s*style: theme\.textTheme\.headlineSmall\?\.copyWith\(,\s*color: color\),\s*fontWeight: FontWeight\.bold\)\)\s*\]\)",
        r"Text(\n          value,\n          style: theme.textTheme.headlineSmall?.copyWith(\n            color: color,\n            fontWeight: FontWeight.bold,\n          ),\n        ),\n      ],\n    );",
        content
    )
    
    # Fix _buildActionButton definition
    content = re.sub(
        r'Widget _buildActionButton\(\s*\{\s*required IconData icon,\s*required String label,\s*required Color color,\s*required VoidCallback onTap\)\}\)',
        r'Widget _buildActionButton({\n    required IconData icon,\n    required String label,\n    required Color color,\n    required VoidCallback onTap,\n  })',
        content
    )
    
    # Fix _buildActionButton body
    content = re.sub(
        r'decoration: BoxDecoration\(,\s*color: color\.withValues\(alp,\s*ha:',
        r'decoration: BoxDecoration(\n        color: color.withValues(alpha:',
        content
    )
    
    content = re.sub(
        r'border: Border\.all\(,\s*color: color\.withValues\(alp,\s*ha:',
        r'border: Border.all(\n          color: color.withValues(alpha:',
        content
    )
    
    content = re.sub(
        r'0\.5\)\)\),\s*child: Material\(,\s*color: Colors\.transparent,\s*child: InkWell\(,\s*onTap:',
        r'0.5),\n        ),\n      ),\n      child: Material(\n        color: Colors.transparent,\n        child: InkWell(\n          onTap:',
        content
    )
    
    content = re.sub(
        r'borderRadius: AppDimensions\.borderRadiusMedium\),\s*child: Padding\(,\s*padding: EdgeInsets\.symmetric\(vertic,\s*al:',
        r'borderRadius: AppDimensions.borderRadiusMedium,\n          child: Padding(\n            padding: EdgeInsets.symmetric(vertical:',
        content
    )
    
    content = re.sub(
        r'AppSpacing\.spacing3\),\s*child: Column\(\s*children:',
        r'AppSpacing.spacing3),\n            child: Column(\n              children:',
        content
    )
    
    content = re.sub(
        r"Text\(\s*label\),\s*style: theme\.textTheme\.bodySmall\?\.copyWith\(,\s*color: color\),\s*fontWeight: FontWeight\.bold\)\)\s*\]\)\)\)\)\)\)\)\)",
        r"Text(\n                  label,\n                  style: theme.textTheme.bodySmall?.copyWith(\n                    color: color,\n                    fontWeight: FontWeight.bold,\n                  ),\n                ),\n              ],\n            ),\n          ),\n        ),\n      ),\n    );",
        content
    )
    
    # Fix the showSnackBar
    content = re.sub(
        r'SnackBar\(\s*content:',
        r'SnackBar(\n        content:',
        content
    )
    
    content = re.sub(
        r"'무료 영혼 받기에 실패했습니다'\s*\),\s*backgroundColor: theme\.colorScheme\.error,\s*behavior: SnackBarBehavior\.floating\)\)\)",
        r"'무료 영혼 받기에 실패했습니다',\n        ),\n        backgroundColor: theme.colorScheme.error,\n        behavior: SnackBarBehavior.floating,\n      ),\n    );",
        content
    )
    
    # Fix height for icon container (was using AppSpacing.spacing20 instead of 80)
    content = re.sub(
        r'height: AppSpacing\.spacing20,',
        r'height: 80,',
        content
    )
    
    with open('/Users/jacobmac/Desktop/Dev/fortune/lib/shared/components/token_insufficient_modal.dart', 'w') as f:
        f.write(content)
    
    print("Fixed token_insufficient_modal.dart")

if __name__ == "__main__":
    fix_token_modal()