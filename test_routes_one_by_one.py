#!/usr/bin/env python3
"""
Script to systematically re-enable fortune page imports one by one
to identify which page causes the infinite loop
"""

import os
import subprocess
import time

# List of all fortune page imports to test
IMPORTS_TO_TEST = [
    {
        'file': '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes.dart',
        'imports': [
            "import '../../features/fortune/presentation/pages/fortune_list_page.dart' as fortune_pages;",
            "import '../../features/fortune/presentation/pages/batch_fortune_page.dart' as fortune_pages;",
            "import '../../features/fortune/presentation/pages/fortune_snap_scroll_page.dart' as fortune_pages;",
            "import '../../features/fortune/presentation/pages/tarot_main_page.dart';",
            "import '../../features/fortune/presentation/pages/tarot_deck_selection_page.dart';"
        ]
    },
    {
        'file': '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/love_fortune_routes.dart',
        'imports': [
            "import '../../../features/fortune/presentation/pages/love_fortune_page.dart' as fortune_pages;",
            "import '../../../features/fortune/presentation/pages/compatibility_page.dart' as fortune_pages;",
            "import '../../../features/fortune/presentation/pages/marriage_fortune_page.dart' as fortune_pages;",
            "import '../../../features/fortune/presentation/pages/couple_match_page.dart' as fortune_pages;",
        ]
    },
    {
        'file': '/Users/jacobmac/Desktop/Dev/fortune/lib/routes/routes/fortune_routes/career_fortune_routes.dart',
        'imports': [
            "import '../../../features/fortune/presentation/pages/career_fortune_page.dart' as fortune_pages;",
            "import '../../../features/fortune/presentation/pages/business_fortune_page.dart' as fortune_pages;",
            "import '../../../features/fortune/presentation/pages/startup_fortune_page.dart' as fortune_pages;",
        ]
    }
]

def enable_import(file_path, import_line):
    """Enable a specific import in a file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    for line in lines:
        # Look for the commented version of this import
        if '// ' + import_line in line:
            new_lines.append(import_line + '\n')
        else:
            new_lines.append(line)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

def disable_import(file_path, import_line):
    """Disable a specific import in a file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    for line in lines:
        if import_line in line and not line.strip().startswith('//'):
            new_lines.append('// ' + line)
        else:
            new_lines.append(line)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

def test_app():
    """Test if the app runs without infinite loop"""
    print("Testing app...")
    try:
        # Run flutter with a timeout
        result = subprocess.run(
            ['flutter', 'run', '-d', 'chrome', '--verbose'],
            capture_output=True,
            text=True,
            timeout=30
        )
        # If it times out, likely infinite loop
        return False
    except subprocess.TimeoutExpired:
        print("App timed out - likely infinite loop!")
        return False
    except Exception as e:
        print(f"Error testing app: {e}")
        return False
    
    # Check if app started successfully
    if 'Syncing files to device' in result.stdout:
        print("App started successfully!")
        return True
    
    return False

def main():
    """Main function to test imports one by one"""
    problematic_imports = []
    
    print("Starting systematic import testing...")
    print("=" * 60)
    
    for file_group in IMPORTS_TO_TEST:
        file_path = file_group['file']
        imports = file_group['imports']
        
        print(f"\nTesting imports in {os.path.basename(file_path)}:")
        print("-" * 40)
        
        for import_line in imports:
            print(f"\nEnabling: {import_line[:50]}...")
            
            # Enable the import
            enable_import(file_path, import_line)
            
            # Test the app
            if test_app():
                print("✅ This import is OK")
            else:
                print("❌ This import causes infinite loop!")
                problematic_imports.append({
                    'file': file_path,
                    'import': import_line
                })
                # Disable it again
                disable_import(file_path, import_line)
            
            # Small delay between tests
            time.sleep(2)
    
    print("\n" + "=" * 60)
    print("TESTING COMPLETE")
    print("=" * 60)
    
    if problematic_imports:
        print("\n⚠️  PROBLEMATIC IMPORTS FOUND:")
        for item in problematic_imports:
            print(f"  File: {os.path.basename(item['file'])}")
            print(f"  Import: {item['import']}")
            print()
    else:
        print("\n✅ All imports tested successfully - no infinite loops found!")

if __name__ == "__main__":
    main()