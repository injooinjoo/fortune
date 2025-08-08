#!/usr/bin/env python3
import re

# Read the file
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/sports_player_fortune_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix map literals - replace commas with colons for key-value pairs
# Pattern: {'name', 'value', ... } -> {'name': 'value', ... }
def fix_map_literals(text):
    lines = text.split('\n')
    fixed_lines = []
    
    for line in lines:
        # Check if line contains map literals with incorrect syntax
        if "{'name'," in line or "{'name', " in line:
            # Replace pattern {'key', 'value', ...} with {'key': 'value', ...}
            fixed_line = re.sub(r"'(name|sport|team|position)', '([^']+)'", r"'\1': '\2'", line)
            fixed_lines.append(fixed_line)
        else:
            fixed_lines.append(line)
    
    return '\n'.join(fixed_lines)

# Fix the map literals
content = fix_map_literals(content)

# Fix other syntax issues
# Fix: authProvider), return -> authProvider);\n    return
content = content.replace(
    "final authProvider = context.watch<AuthProvider>(), return BaseFortunePage(",
    "final authProvider = context.watch<AuthProvider>();\n    return BaseFortunePage("
)

# Fix double commas
content = re.sub(r'\)\),\s*,', r')),', content)
content = re.sub(r'\)\);,', r'));', content)

# Fix request data map
content = content.replace(
    "      'fortuneType', 'sports-player',",
    "      'fortuneType': 'sports-player',"
)
content = content.replace(
    "      'userId', authProvider.userId,",
    "      'userId': authProvider.userId,"
)
content = content.replace(
    "      'name', userProfile?.name ?? '선수',",
    "      'name': userProfile?.name ?? '선수',"
)
content = content.replace(
    "      'birthDate', userProfile?.birthDate ?? DateTime.now().toIso8601String(),",
    "      'birthDate': userProfile?.birthDate ?? DateTime.now().toIso8601String(),"
)
content = content.replace(
    "      'playerName', selectedPlayer,",
    "      'playerName': selectedPlayer,"
)
content = content.replace(
    "      'sport', player?['sport'],",
    "      'sport': player?['sport'],"
)
content = content.replace(
    "      'team', player?['team'],",
    "      'team': player?['team'],"
)
content = content.replace(
    "      'position', player?['position'],",
    "      'position': player?['position'],"
)

# Fix other syntax errors
content = content.replace(
    "final authProvider = context.read<AuthProvider>(), final fortuneProvider = context.read<FortuneProvider>(), final userProfile = authProvider.userProfile;",
    "final authProvider = context.read<AuthProvider>();\n    final fortuneProvider = context.read<FortuneProvider>();\n    final userProfile = authProvider.userProfile;"
)

content = content.replace(
    "?.firstWhere((p) => p['name'] == selectedPlayer), final requestData = {",
    "?.firstWhere((p) => p['name'] == selectedPlayer);\n    final requestData = {"
)

content = content.replace(
    "), if (result != null && mounted) {",
    ");\n      if (result != null && mounted) {"
)

content = content.replace(
    "if (analysis == null) return const SizedBox.shrink(), final stats = analysis is Map ? analysis : {};",
    "if (analysis == null) return const SizedBox.shrink();\n    final stats = analysis is Map ? analysis : {};"
)

content = content.replace(
    "if (content == null) return const SizedBox.shrink(), return FortuneContentCard(",
    "if (content == null) return const SizedBox.shrink();\n    return FortuneContentCard("
)

# Write the fixed content back
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/features/fortune/presentation/pages/sports_player_fortune_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed sports_player_fortune_page.dart map literals")