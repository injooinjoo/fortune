#!/usr/bin/env python3

def check_specific_lines():
    file_path = '/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Check line 896 context
    print("Context around line 896 (children):")
    for i in range(893, 900):
        if i < len(lines):
            print(f"{i+1}: {lines[i].rstrip()}")
    
    # Count brackets in Row widget
    print("\n\nAnalyzing Row widget starting at line 895:")
    row_start = 894  # 0-indexed
    bracket_count = {'(': 0, ')': 0, '[': 0, ']': 0, '{': 0, '}': 0}
    
    for i in range(row_start, min(row_start + 50, len(lines))):
        line = lines[i]
        for char in line:
            if char in bracket_count:
                bracket_count[char] += 1
        
        # Check if Row is complete
        if '(' in bracket_count and bracket_count['('] == bracket_count[')']:
            print(f"Row widget completes at line {i+1}")
            print(f"Bracket counts: {bracket_count}")
            break

if __name__ == "__main__":
    check_specific_lines()