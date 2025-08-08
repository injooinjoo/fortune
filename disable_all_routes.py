#!/usr/bin/env python3
"""
Script to temporarily disable all fortune route imports to get a clean baseline
"""

import os

def disable_routes_in_file(file_path):
    """Comment out all imports of fortune pages in router files"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    modified = False
    new_lines = []
    
    for line in lines:
        # Comment out any import that includes 'fortune/presentation/pages'
        if 'import ' in line and 'fortune/presentation/pages' in line and not line.strip().startswith('//'):
            new_lines.append('// ' + line)
            modified = True
        else:
            new_lines.append(line)
    
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f"Disabled imports in {os.path.basename(file_path)}")
    
    return modified

def main():
    """Main function"""
    route_files = [
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/basic_fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/career_fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/love_fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/lucky_item_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/traditional_fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/health_sports_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/personality_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/time_based_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/special_fortune_routes.dart'
    ]
    
    for file_path in route_files:
        if os.path.exists(file_path):
            disable_routes_in_file(file_path)
    
    print("\nAll fortune page imports have been disabled. The app should now run without infinite loops.")
    print("You can now systematically re-enable imports one by one to identify the problematic page.")

if __name__ == "__main__":
    main()