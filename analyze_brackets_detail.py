#!/usr/bin/env python3

def analyze_method_brackets():
    file_path = '/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/fortune_explanation_bottom_sheet.dart'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Find _buildInfoItem method
    start_line = None
    for i, line in enumerate(lines):
        if '_buildInfoItem(' in line:
            start_line = i
            break
    
    if start_line is None:
        print("_buildInfoItem method not found")
        return
    
    print(f"_buildInfoItem method starts at line {start_line + 1}")
    
    # Track brackets
    bracket_stack = []
    brackets = {'(': ')', '[': ']', '{': '}'}
    closing = {v: k for k, v in brackets.items()}
    
    for i in range(start_line, min(start_line + 100, len(lines))):
        line = lines[i]
        for j, char in enumerate(line):
            if char in brackets:
                bracket_stack.append({
                    'char': char,
                    'line': i + 1,
                    'col': j + 1,
                    'expecting': brackets[char]
                })
            elif char in closing:
                if not bracket_stack:
                    print(f"Line {i+1}, col {j+1}: Unexpected closing '{char}'")
                else:
                    last = bracket_stack[-1]
                    if last['expecting'] == char:
                        bracket_stack.pop()
                    else:
                        print(f"Line {i+1}, col {j+1}: Expected '{last['expecting']}' but found '{char}'")
                        print(f"  Opening at line {last['line']}, col {last['col']}")
        
        # Check if method is complete
        if i > start_line and not bracket_stack and line.strip() == '}':
            print(f"\nMethod ends at line {i+1}")
            break
    
    if bracket_stack:
        print("\nUnclosed brackets:")
        for item in bracket_stack:
            print(f"  Line {item['line']}, col {item['col']}: '{item['char']}' expecting '{item['expecting']}'")

if __name__ == "__main__":
    analyze_method_brackets()