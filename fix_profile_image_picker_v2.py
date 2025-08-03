#!/usr/bin/env python3

def fix_file():
    file_path = "/Users/jacobmac/Desktop/Dev/fortune/lib/presentation/widgets/profile_image_picker.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix line 23: )});  -> );
    if len(lines) > 22 and lines[22].strip() == ')});':
        lines[22] = '  );\n'
    
    # Fix line 35: context: context), -> context: context,
    if len(lines) > 34 and 'context: context),' in lines[34]:
        lines[34] = '        context: context,\n'
    
    # Fix line 43-44: missing comma after }
    if len(lines) > 43 and lines[43].strip() == '}':
        lines[43] = '              },\n'
    
    # Fix line 49-50: missing comma after }
    if len(lines) > 49 and lines[49].strip() == '}':
        lines[49] = '              },\n'
    
    # Fix line 51: missing comma after ]
    if len(lines) > 50 and lines[50].strip() == ']':
        lines[50] = '          ],\n'
    
    # Fix line 53: isDefaultAction: true), -> isDefaultAction: true,
    if len(lines) > 52 and 'isDefaultAction: true),' in lines[52]:
        lines[52] = '            isDefaultAction: true,\n'
    
    # Fix line 55: child: const Text('취소'))))))  -> child: const Text('취소'),
    if len(lines) > 54 and "child: const Text('취소'))))))" in lines[54]:
        lines[54] = "            child: const Text('취소'),\n"
    
    # Add missing closing structures
    if len(lines) > 55:
        # Close CupertinoActionSheetAction
        lines.insert(55, '          ),\n')
        # Close CupertinoActionSheet  
        lines.insert(56, '        ),\n')
        # Close showCupertinoModalPopup
        lines.insert(57, '      );\n')
    
    # Fix line 58: context: context), -> context: context,
    for i in range(len(lines)):
        if 'context: context),' in lines[i] and 'showModalBottomSheet' in lines[i-1]:
            lines[i] = lines[i].replace('context: context),', 'context: context,')
    
    # Fix various syntax issues
    for i in range(len(lines)):
        # Fix Column that has mainAxisSize on wrong line
        if 'child: Column(' in lines[i]:
            if i+1 < len(lines) and 'mainAxisSize: MainAxisSize.min,' in lines[i+1]:
                if i+2 < len(lines) and '),' in lines[i+2]:
                    lines[i] = '          child: Column(\n'
                    lines[i+1] = '            mainAxisSize: MainAxisSize.min,\n'
                    lines[i+2] = '            children: [\n'
        
        # Fix missing commas after onTap closures
        if 'onTap: () {' in lines[i]:
            # Find the closing brace
            j = i + 1
            brace_count = 1
            while j < len(lines) and brace_count > 0:
                if '{' in lines[j]:
                    brace_count += lines[j].count('{')
                if '}' in lines[j]:
                    brace_count -= lines[j].count('}')
                j += 1
            # Check if there's a comma after the closing brace
            if j-1 < len(lines) and lines[j-1].strip() == '}':
                lines[j-1] = '                },\n'
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("Fixed syntax errors")

if __name__ == "__main__":
    fix_file()