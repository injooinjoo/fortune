#!/usr/bin/env python3
import re

def fix_file(file_path, fixes):
    """Apply a list of fixes to a file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for line_num, replacement in fixes:
        if line_num < len(lines):
            lines[line_num] = replacement
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed {file_path}")

def main():
    # Fix tarot_storytelling_page.dart
    fixes_storytelling = [
        (219, "      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),\n"),
        (226, "              borderRadius: BorderRadius.circular(3)),\n"),
        (236, "                borderRadius: BorderRadius.circular(3),\n"),
        (241, "                    spreadRadius: 1)])),\n"),
        (256, "                    borderRadius: BorderRadius.circular(3))));\n"),
        (257, "            })])));\n"),
    ]
    
    # Fix daily_fortune_page.dart - the main issue is unclosed brackets in the map function
    fixes_daily = [
        (110, "            style: Theme.of(context).textTheme.bodyLarge?.copyWith(\n"),
        (118, "            style: Theme.of(context).textTheme.titleMedium?.copyWith(\n"),
        (133, "              style: Theme.of(context).textTheme.headlineSmall),\n"),
        (154, "                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(\n"),
        (155, "                            fontWeight: FontWeight.bold)),\n"),
        (159, "                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(\n"),
        (160, "                            color: data['color'],\n"),
        (165, "                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(\n"),
        (166, "                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))])));\n"),
    ]
    
    fix_file("/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/tarot_storytelling_page.dart", fixes_storytelling)
    fix_file("/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/daily_fortune_page.dart", fixes_daily)

if __name__ == "__main__":
    main()