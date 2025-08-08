#!/usr/bin/env python3
"""
Script to temporarily comment out all fortune routes to identify which one causes the infinite loop
"""

import os
import re

def comment_out_routes(file_path):
    """Comment out all routes in a route file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the routes array
    if 'Routes = [' in content:
        # Find the start and end of the routes array
        start_idx = content.find('Routes = [')
        if start_idx == -1:
            return False
            
        # Find the matching closing bracket
        bracket_count = 0
        in_array = False
        end_idx = -1
        
        for i in range(start_idx, len(content)):
            if content[i] == '[':
                bracket_count += 1
                in_array = True
            elif content[i] == ']':
                bracket_count -= 1
                if bracket_count == 0 and in_array:
                    end_idx = i + 1
                    break
        
        if end_idx == -1:
            return False
            
        # Extract the routes array content
        routes_content = content[start_idx:end_idx]
        
        # Comment out all GoRoute entries except empty arrays
        if 'GoRoute' in routes_content:
            # Replace the array content with empty array
            new_content = content[:start_idx] + content[start_idx:content.find('[', start_idx)+1] + '\n  // TEMPORARILY DISABLED - ALL ROUTES COMMENTED OUT FOR DEBUGGING\n' + content[end_idx-1:end_idx] + content[end_idx:]
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"Commented out routes in {file_path}")
            return True
    
    return False

def main():
    """Main function to comment out all routes"""
    route_files = [
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/career_fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/love_fortune_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/lucky_item_routes.dart',
        '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/traditional_fortune_routes.dart'
    ]
    
    for file_path in route_files:
        if os.path.exists(file_path):
            comment_out_routes(file_path)
        else:
            print(f"File not found: {file_path}")
    
    print("\nAll routes have been commented out. You can now test the app and uncomment routes one by one.")

if __name__ == "__main__":
    main()