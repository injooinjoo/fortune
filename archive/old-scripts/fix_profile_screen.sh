#!/bin/bash

echo "🔧 Fixing profile_screen.dart syntax errors..."

file="/Users/jacobmac/Desktop/Dev/fortune/lib/screens/profile/profile_screen.dart"

# Fix specific line issues
# Line 353-356: Missing ScaffoldMessenger
sed -i '' '353,356s/const SnackBar/ScaffoldMessenger.of(context).showSnackBar(const SnackBar/g' "$file"
sed -i '' '356s/}/)); }/g' "$file"

# Line 359: Missing context for text
sed -i '' "359s/'프리미엄 기능을 즉시 켜고 끌 수 있습니다.',/),\n                                      Text('프리미엄 기능을 즉시 켜고 끌 수 있습니다.',\n                                        style: TextStyle(fontSize: 14, color: TossDesignSystem.gray600),\n                                      ),/g" "$file"

# Line 367: Missing closing parentheses
sed -i '' '367s/TossDesignSystem.gray200,/TossDesignSystem.gray200),/g' "$file"
sed -i '' '368s/child: Row(/),\n                                        child: Row(/g' "$file"

# Line 374: Missing closing bracket for Icon
sed -i '' '374s/size: 20,/size: 20),/g' "$file"

# Line 380: Missing closing brackets
sed -i '' '380s/TossDesignSystem.tossBlue,/TossDesignSystem.tossBlue),/g' "$file"
sed -i '' '381a\                                                ),\n                                              ),\n                                            ],\n                                          ),\n                                        ),\n                                      ],\n                                    ),\n                                  ),\n                                ),\n                              ],\n                            ),\n                          ),\n                        );' "$file"

echo "✅ profile_screen.dart fixes complete!"