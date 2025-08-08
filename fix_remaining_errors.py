#!/usr/bin/env python3
import re

def fix_daily_fortune_page():
    """Fix the daily_fortune_page.dart file completely"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/daily_fortune_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace the entire _buildTimeBasedFortune method
    old_method = """  Widget _buildTimeBasedFortune() {
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      '아침 (06:00-12:00)': {
        'score': 85,
        'description': '활력이 넘치는 아침입니다. 중요한 결정은 이 시간에 하세요.',
        'color': Colors.orange},
      '오후 (12:00-18:00)': {
        'score': 70,
        'description': '평온한 오후가 될 것입니다. 협업에 좋은 시간입니다.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
      '저녁 (18:00-24:00)': {
        'score': 90,
        'description': '행운이 가득한 저녁입니다. 사교 활동에 적합합니다.',
        'color': Colors.purple}};"""
    
    new_method = """  Widget _buildTimeBasedFortune() {
    final timeBasedData = {
      '아침 (06:00-12:00)': {
        'score': 85,
        'description': '활력이 넘치는 아침입니다. 중요한 결정은 이 시간에 하세요.',
        'color': Colors.orange},
      '오후 (12:00-18:00)': {
        'score': 70,
        'description': '평온한 오후가 될 것입니다. 협업에 좋은 시간입니다.',
        'color': Colors.blue},
      '저녁 (18:00-24:00)': {
        'score': 90,
        'description': '행운이 가득한 저녁입니다. 사교 활동에 적합합니다.',
        'color': Colors.purple}}"""
    
    content = content.replace(old_method, new_method)
    
    # Fix the duplicate copyWith lines
    content = re.sub(r'(\s+style: Theme\.of\(context\)\.textTheme\.\w+\?\.\w+\(\))\n\s+style: Theme\.of\(context\)\.textTheme\.\w+\?\.\w+\(', r'\1(', content)
    
    # Fix the ending of the _buildTimeBasedFortune method
    content = content.replace(
        "                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))])));\n            }).toList()]))));",
        "                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))])));\n            }).toList()])));"
    )
    
    # Fix the _buildDailyTips method issues
    old_tips = """                      style: Theme.of(context).textTheme.bodyMedium))]))).toList()])));)"""
    new_tips = """                      style: Theme.of(context).textTheme.bodyMedium))]))).toList()])))"""
    content = content.replace(old_tips, new_tips)
    
    # Remove "No newline at end of file" lines
    content = content.replace(" No newline at end of file", "")
    
    # Make sure file ends properly
    if not content.endswith('\n'):
        content += '\n'
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed {file_path}")

def fix_tarot_summary_page():
    """Fix tarot_summary_page.dart bracket issues"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_summary_page.dart"
    
    # Read file and manually fix the bracket issues
    # This is a complex fix that would require understanding the widget tree
    print(f"Needs manual fix: {file_path}")

def fix_tarot_deck_selection_page():
    """Fix tarot_deck_selection_page.dart bracket issues"""
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_deck_selection_page.dart"
    
    # Read file and manually fix the bracket issues
    print(f"Needs manual fix: {file_path}")

def main():
    fix_daily_fortune_page()
    # Other files need more investigation
    
if __name__ == "__main__":
    main()