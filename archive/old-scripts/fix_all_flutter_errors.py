#!/usr/bin/env python3

import os
import re
from pathlib import Path

def fix_flutter_errors(content):
    """Fix common Flutter/Dart syntax errors"""
    
    # Fix double semicolons
    content = re.sub(r';;+', ';', content)
    
    # Fix trailing commas in LinearGradient
    content = re.sub(r'(colors:\s*\[[^\]]+\]),\s*,', r'\1)', content)
    
    # Fix NeverScrollableScrollPhysics
    content = re.sub(r'NeverScrollableScrollPhysics\(,', 'NeverScrollableScrollPhysics(),', content)
    
    # Fix borderRadius patterns
    content = re.sub(r'borderRadius:\s*BorderRadius\.circular\((\d+)\)\),', 
                     r'borderRadius: BorderRadius.circular(\1),', content)
    
    # Fix copyWith() patterns
    content = re.sub(r'\.copyWith\(\),\s*\n\s*(\w)', r'.copyWith(\n            \1', content)
    
    # Fix map literal patterns {'id': 'value': 'name'} -> {'id': 'value', 'name': ...}
    content = re.sub(r"\{'id':\s*'([^']+)':\s*'name',\s*'([^']+)'", 
                     r"{'id': '\1', 'name': '\2'", content)
    
    # Fix ending patterns ))), -> )),
    content = re.sub(r'\)\)\)\),', '))),', content)
    content = re.sub(r'\)\)\),(?!\s*\))', ')),', content)
    
    # Fix bracket issues with widgets
    content = re.sub(r'\)\]\)\)', ')]])', content)
    
    # Fix TextStyle endings
    content = re.sub(r'(fontWeight:\s*[^)]+)\)\]\);', r'\1),\n                ),\n              ],\n            ),\n          ),\n        );', content)
    
    # Fix missing brackets in BoxDecoration
    content = re.sub(r'(borderRadius:\s*BorderRadius\.circular\(\d+\)),\s*\n\s*child:', 
                     r'\1,\n            ),\n            child:', content)
    
    # Fix isSelected comparisons
    content = re.sub(r"== ([a-zA-Z_]+)\['id'\s*\n\s*\];", r"== \1['id'];", content)
    
    # Fix Icon widget patterns
    content = re.sub(r"Icon\(\s*([a-zA-Z_]+)\['icon'\],", 
                     r"Icon(\n                  \1['icon'] as IconData,", content)
    
    # Fix Text widget patterns  
    content = re.sub(r"Text\(\s*([a-zA-Z_]+)\['name'\],",
                     r"Text(\n                  \1['name'] as String,", content)
    
    # Fix GlassContainer endings
    content = re.sub(r'(borderRadius:\s*BorderRadius\.circular\(\d+\)),\s*\n\s*(padding|child):', 
                     r'\1,\n      \2:', content)
    
    # Fix ShimmerGlass patterns
    content = re.sub(r'(borderRadius:\s*BorderRadius\.circular\(\d+\)),\s*\n\s*child:\s*GlassContainer', 
                     r'\1,\n          child: GlassContainer', content)
    
    # Fix style patterns
    content = re.sub(r'(style:\s*[^.]+\.copyWith\(),\s*\n\s*(\w)', r'\1\n              \2', content)
    
    # Fix empty map patterns
    content = re.sub(r"\{'\\1':\s*'\\2':", "{'id':", content)
    
    return content

def process_dart_files(directory):
    """Process all Dart files in the directory"""
    dart_files = Path(directory).rglob('*.dart')
    
    fixed_count = 0
    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            fixed_content = fix_flutter_errors(original_content)
            
            if fixed_content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                fixed_count += 1
                print(f"Fixed: {file_path}")
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    return fixed_count

if __name__ == "__main__":
    lib_dir = "/Users/jacobmac/Desktop/Dev/fortune/lib"
    
    print("Starting Flutter error fixes...")
    count = process_dart_files(lib_dir)
    print(f"\nFixed {count} files")