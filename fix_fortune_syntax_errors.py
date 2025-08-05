#!/usr/bin/env python3
"""Fix common syntax errors in Dart files"""

import os
import re
import glob

def fix_syntax_errors(content):
    """Fix common syntax errors in Dart content"""
    
    # Fix pattern: CrossAxisAlignment.start);
    # Should be: CrossAxisAlignment.start,
    content = re.sub(r'(CrossAxisAlignment\.\w+)\);(?=\s*children:)', r'\1,', content)
    
    # Fix pattern: style: theme.textTheme.headlineSmall,\n    ))
    # Should be: style: theme.textTheme.headlineSmall,\n    ),
    content = re.sub(r'\)\)', '),', content)
    
    # Fix pattern: Text(\n            '날짜 선택');
    # Should be: Text(\n            '날짜 선택',
    content = re.sub(r"('[\w\s가-힣!?,.]+)'\);(?=\s*(style:|textAlign:|maxLines:|overflow:|softWrap:|\s*\)))", r"\1',", content)
    
    # Fix pattern: const SizedBox(height: 16))
    # Should be: const SizedBox(height: 16),
    content = re.sub(r'(SizedBox\((?:height|width):\s*\d+(?:\.\d+)?)\)\)(?=\s*[A-Z\w])', r'\1),', content)
    
    # Fix pattern: EdgeInsets.all(16)),
    # Should be: EdgeInsets.all(16),
    content = re.sub(r'(EdgeInsets\.(?:all|symmetric|only)\([^)]+\))\),', r'\1,', content)
    
    # Fix pattern: BorderRadius.circular(12)),
    # Should be: BorderRadius.circular(12),
    content = re.sub(r'(BorderRadius\.circular\(\d+(?:\.\d+)?\))\),', r'\1,', content)
    
    # Fix pattern: blur: 10),
    # Should be: blur: 10,
    content = re.sub(r'(blur:\s*\d+(?:\.\d+)?)\),', r'\1,', content)
    
    # Fix pattern: DateTime.now().subtract(const Duration(days: 30))),
    # Should be: DateTime.now().subtract(const Duration(days: 30)),
    content = re.sub(r'(Duration\((?:days|hours|minutes|seconds):\s*\d+\))\)\),', r'\1),', content)
    
    # Fix pattern: const Locale('ko': 'KR'))
    # Should be: const Locale('ko', 'KR'),
    content = re.sub(r"Locale\('(\w+)':\s*'(\w+)'\)", r"Locale('\1', '\2')", content)
    
    # Fix pattern: initialDate: _selectedDate),
    # Should be: initialDate: _selectedDate,
    content = re.sub(r'(initialDate:\s*\w+)\),', r'\1,', content)
    
    # Fix pattern: context: context);
    # Should be: context: context,
    content = re.sub(r'(context:\s*context)\);', r'\1,', content)
    
    # Fix pattern for lists in parameters
    content = re.sub(r"(\['[^']+)':\s*'([^']+)':\s*'([^']+)'", r"\['\1', '\2', '\3'", content)
    
    # Fix pattern: targetAudience: ['경력직': '이직 고민': '커리어 체인지',
    # Should be: targetAudience: ['경력직', '이직 고민', '커리어 체인지'],
    content = re.sub(r"(\[['\"][\w\s가-힣]+['\"]):\s*(['\"][\w\s가-힣]+['\"]):\s*(['\"][\w\s가-힣]+['\"])", r"\1, \2, \3", content)
    
    # Fix double commas
    content = re.sub(r',,', ',', content)
    
    # Fix Icon widget missing comma after closing parenthesis
    content = re.sub(r'(Icon\([^)]+\))\);', r'\1,', content)
    
    # Fix Text widget parameters with semicolon instead of comma
    content = re.sub(r"(Text\('[^']+')\);(?=\s*style:)", r"\1,", content)
    
    # Fix widget missing closing parenthesis patterns
    content = re.sub(r'(color: [^,]+)\)(?=\s*\),)', r'\1,', content)
    
    # Fix .map().toList() with wrong punctuation
    content = re.sub(r'\)\.toList\(\),', ').toList(),', content)
    content = re.sub(r'\),.toList\(\),', ').toList(),', content)
    
    # Fix Container widget property syntax
    content = re.sub(r'(width:\s*\d+)\);', r'\1,', content)
    content = re.sub(r'(height:\s*\d+)\);', r'\1,', content)
    
    # Fix missing comma in Colors.color)
    content = re.sub(r'(Colors\.\w+)\)(?=\s*\})', r'\1,', content)
    
    # Fix if statement missing closing semicolon/parenthesis
    content = re.sub(r'if \(([^;]+)\);(?=\s*[A-Z])', r'if (\1)', content)
    
    # Fix .scale() missing end parameter
    content = re.sub(r'\.scale\(begin: const Offset\(([^)]+)\), end: const Offset\(([^)]+)\),;', r'.scale(begin: const Offset(\1), end: const Offset(\2));', content)
    
    # Fix SportItem constructor calls with extra comma
    content = re.sub(r'(SportItem\([^)]+\),)(?=\s*SportItem)', r'\1', content)
    
    # Fix missing closing bracket in map() calls
    content = re.sub(r'(\.map\([^)]+\) => [^)]+)\),,', r'\1)),', content)
    
    # Fix join() syntax error  
    content = re.sub(r"\.join\(':\s*'\)", r".join(', ')", content)
    
    # Fix .animate(CurvedAnimation(...),;
    content = re.sub(r'(\)\),);', r'));', content)
    
    # Fix putIfAbsent with extra comma
    content = re.sub(r'(GlobalKey\(\),);', r'GlobalKey());', content)
    
    # Fix .withValues missing closing parenthesis
    content = re.sub(r'(Colors\.\w+\.withValues\(alpha:\s*[^)]+),', r'\1),', content)
    
    # Fix contains() with extra comma
    content = re.sub(r"(contains\('[^']+'),)\s*\{", r'\1 {', content)
    
    # Fix Future.delayed with extra comma
    content = re.sub(r'(Duration\(\w+:\s*\d+\)),;', r'\1);', content)
    
    # Fix missing semicolons on Icon widget
    content = re.sub(r'(Icons\.\w+_\w+)\);', r'\1,', content)
    
    # Fix Text widget with semicolon instead of comma  
    content = re.sub(r"(Text\('[^']+')\);(?=\s*style:)", r"\1,", content)
    
    # Fix missing closing parenthesis in lists
    content = re.sub(r"('[^']+')\)(?=\s*'[^']+')\)(?=\s*'[^']+')\)", r"\1,", content)
    
    # Fix SajuState() constructor with extra comma
    content = re.sub(r'(SajuState\(\)),;', r'\1);', content)
    
    # Fix exception handling syntax
    content = re.sub(r"(contains\('Exception: ')),\s*\{", r'\1) {', content)
    
    # Fix SliverPadding missing closing parenthesis
    content = re.sub(r'(SliverPadding\(padding:[^,]+),(?=\s*\))', r'\1)', content)
    
    # Fix multiple commas in map entries
    content = re.sub(r"(Colors\.\w+),\s*\}\)(?=\s*')", r'\1}),', content)
    
    return content

def process_file(filepath):
    """Process a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        content = fix_syntax_errors(content)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {filepath}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Main function"""
    fortune_files = glob.glob('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/**/*.dart', recursive=True)
    
    fixed_count = 0
    for filepath in fortune_files:
        if process_file(filepath):
            fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == '__main__':
    main()