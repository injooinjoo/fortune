#!/usr/bin/env python3

import re

def fix_file():
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/social_accounts_section.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix Container(width... height...) - missing comma between them
    content = re.sub(r'(height: AppDimensions\.buttonHeightSmall)\)', r'\1,', content)
    
    # Fix decoration: BoxDecoration(,
    content = re.sub(r'decoration: BoxDecoration\(\,', r'decoration: BoxDecoration(', content)
    
    # Fix color: providerInfo.color.withValues(alp, ha: 0.1)
    content = re.sub(r'color: providerInfo\.color\.withValues\(alp,\s*ha: 0\.1\)', r'color: providerInfo.color.withValues(alpha: 0.1)', content)
    
    # Fix borderRadius: AppDimensions.borderRadiusSmall) with missing comma
    content = re.sub(r'(borderRadius: AppDimensions\.borderRadiusSmall)\)', r'\1,', content)
    
    # Fix child: Center( child: _buildProviderIcon(providerInfo))))
    content = re.sub(r'child: Center\(\s*child: _buildProviderIcon\(providerInfo\)\)\)\)\)', r'child: Center(\n              child: _buildProviderIcon(providerInfo)\n            ),\n          ),', content)
    
    # Fix child: Column(,
    content = re.sub(r'child: Column\(\,', r'child: Column(', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed syntax errors")

if __name__ == "__main__":
    fix_file()