#!/usr/bin/env python3
import re

def analyze_brackets(file_path):
    """Analyze bracket matching in a file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Track bracket counts
    open_square = 0
    open_paren = 0
    open_curly = 0
    
    issues = []
    
    for i, line in enumerate(lines, 1):
        # Skip comments and strings (simplified)
        if '//' in line:
            line = line[:line.index('//')]
        
        for char in line:
            if char == '[':
                open_square += 1
            elif char == ']':
                open_square -= 1
                if open_square < 0:
                    issues.append(f"Line {i}: Extra closing square bracket")
                    open_square = 0
            elif char == '(':
                open_paren += 1
            elif char == ')':
                open_paren -= 1
                if open_paren < 0:
                    issues.append(f"Line {i}: Extra closing parenthesis")
                    open_paren = 0
            elif char == '{':
                open_curly += 1
            elif char == '}':
                open_curly -= 1
                if open_curly < 0:
                    issues.append(f"Line {i}: Extra closing curly bracket")
                    open_curly = 0
    
    if open_square > 0:
        issues.append(f"Missing {open_square} closing square bracket(s)")
    if open_paren > 0:
        issues.append(f"Missing {open_paren} closing parenthesis/es")
    if open_curly > 0:
        issues.append(f"Missing {open_curly} closing curly bracket(s)")
    
    return issues

def main():
    files_to_check = [
        "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_storytelling_page.dart",
        "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_summary_page.dart",
        "/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_deck_selection_page.dart"
    ]
    
    for file_path in files_to_check:
        print(f"\nAnalyzing {file_path.split('/')[-1]}:")
        issues = analyze_brackets(file_path)
        if issues:
            for issue in issues:
                print(f"  {issue}")
        else:
            print("  No bracket issues found")

if __name__ == "__main__":
    main()