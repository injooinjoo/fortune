#!/usr/bin/env python3
"""
Batch update all test files to use test_mode=true URL
"""
import os
import re
import glob

# Directory containing test files
TEST_DIR = os.path.dirname(os.path.abspath(__file__))

# Files to skip (already fixed or special)
SKIP_FILES = ['TC004_Home_Dashboard.py', 'fix_all_tests.py']

def fix_test_file(filepath):
    """Fix a single test file to use test_mode=true"""
    filename = os.path.basename(filepath)
    if filename in SKIP_FILES:
        print(f"⏭️ Skipping {filename}")
        return False

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if already fixed
    if '?test_mode=true' in content:
        print(f"✅ Already fixed: {filename}")
        return False

    # Check if it has the old URL pattern
    if 'goto("http://localhost:3000"' not in content:
        print(f"⚠️ No standard URL pattern found: {filename}")
        return False

    original_content = content

    # 1. Fix URL to include test_mode=true
    content = content.replace(
        'goto("http://localhost:3000"',
        'goto("http://localhost:3000/?test_mode=true"'
    )

    # 2. Increase default timeout
    content = content.replace(
        'context.set_default_timeout(5000)',
        'context.set_default_timeout(10000)  # Increased for test_mode'
    )

    # 3. Add wait for URL redirect after goto
    # Find the goto line and add wait for /home after it
    goto_pattern = r'(await page\.goto\("http://localhost:3000/\?test_mode=true".*?\))'

    def add_wait_for_home(match):
        goto_line = match.group(1)
        return f'''{goto_line}

        # Wait for test_mode auto-redirect to /home
        await page.wait_for_url("**/home**", timeout=15000)'''

    content = re.sub(goto_pattern, add_wait_for_home, content)

    # 4. Remove the problematic '시작하기' button click (it's no longer needed with test_mode)
    # Pattern: Click the '시작하기' button section
    start_button_pattern = r"""# -> Click the '시작하기'.*?await.*?\.click\(timeout=\d+\)\s*"""
    content = re.sub(start_button_pattern,
                     '# Skipped: 시작하기 button click not needed with test_mode (auto-login)\n        ',
                     content, flags=re.DOTALL)

    # Also remove other variants
    start_button_pattern2 = r"""# Click the '시작하기'.*?elem = frame\.locator.*?\n.*?await.*?\.click\(timeout=\d+\)\s*"""
    content = re.sub(start_button_pattern2,
                     '# Skipped: 시작하기 button click not needed with test_mode (auto-login)\n        ',
                     content, flags=re.DOTALL)

    # 5. Fix frame references that might cause issues
    # Replace 'frame = context.pages[-1]' with safer access
    content = content.replace(
        'frame = context.pages[-1]',
        'frame = page  # Use main page after test_mode redirect'
    )

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Fixed: {filename}")
        return True
    else:
        print(f"⚠️ No changes needed: {filename}")
        return False

def main():
    """Main function to fix all test files"""
    test_files = glob.glob(os.path.join(TEST_DIR, 'TC*.py'))

    print(f"Found {len(test_files)} test files")
    print("=" * 50)

    fixed_count = 0
    for filepath in sorted(test_files):
        if fix_test_file(filepath):
            fixed_count += 1

    print("=" * 50)
    print(f"Fixed {fixed_count} files")

if __name__ == '__main__':
    main()
