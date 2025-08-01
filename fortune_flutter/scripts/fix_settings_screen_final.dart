import 'dart:io';

void main() async {
  final file = File('lib/screens/settings/settings_screen.dart');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  
  String content = await file.readAsString();
  int fixCount = 0;
  
  // Fix pattern 1: Container with missing child parameter
  content = content.replaceAll('              margin: AppSpacing.paddingHorizontal16,\n              decoration:', '              margin: AppSpacing.paddingHorizontal16,\n              decoration:');
  
  // Fix pattern 2: BoxShadow syntax errors
  final boxShadowPattern = RegExp(
    r'BoxShadow\(\s*color:\s*([^)]+)\)\s*blurRadius:',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(boxShadowPattern, (match) {
    fixCount++;
    final color = match.group(1)!;
    return 'BoxShadow(\n                    color: ${color},\n                    blurRadius:';
  });
  
  // Fix pattern 3: Container padding issues
  content = content.replaceAll('Container(\npadding:', 'Container(\n                    padding:');
  
  // Fix pattern 4: Color with missing comma
  final colorPattern = RegExp(
    r'\.withValues\(alpha:\s*[\d.]+\)\)\s*borderRadius:',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(colorPattern, (match) {
    fixCount++;
    return match.group(0)!.replaceFirst('))', '),');
  });
  
  // Fix pattern 5: Missing closing parenthesis for Padding
  content = content.replaceAll('Padding(\npadding:', 'Padding(\n              padding:');
  
  // Fix pattern 6: SizedBox with missing comma
  content = content.replaceAll('width: double.infinity)\n                child:', 'width: double.infinity,\n                child:');
  
  // Fix pattern 7: Missing closing parenthesis for style
  final stylePattern = RegExp(
    r'style:\s*Theme\.of\(context\)\.textTheme\.[^?]+\?\.copyWith\([^)]+\),\s*([^,)]+)\s*\]\s*\)\s*\)',
    multiLine: true,
  );
  
  content = content.replaceAllMapped(stylePattern, (match) {
    fixCount++;
    final base = match.group(0)!;
    return base.replaceAll(RegExp(r'\)\s*\]\s*\)\s*\)'), ')],\n                  ),');
  });
  
  // Fix pattern 8: Container missing comma
  content = content.replaceAll('color: _getIconBackgroundColor(icon))\n                borderRadius:', 'color: _getIconBackgroundColor(icon),\n                borderRadius:');
  
  // Fix pattern 9: Text widget with missing parenthesis
  content = content.replaceAll('Text(\n                \'Fortune v1.0.0\')', 'Text(\n                \'Fortune v1.0.0\',');
  
  // Fix pattern 10: Style outside Text widget
  content = content.replaceAll(
    'Text(\n                \'Fortune v1.0.0\',\n                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),',
    'Text(\n                \'Fortune v1.0.0\',\n                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),\n              ),',
  );
  
  // Fix pattern 11: Missing parenthesis and brackets
  content = content.replaceAll('),\n            SizedBox(height: AppSpacing.spacing8)])));', '),\n                ),\n              ),\n            ),\n            SizedBox(height: AppSpacing.spacing8),\n          ],\n        ),\n      ),\n    );');
  
  // Fix pattern 12: Fix the trailing comma issue
  content = content.replaceAll('fontWeight: FontWeight.w500, if (showBadge) ...[', 'fontWeight: FontWeight.w500,\n                        ),\n                      if (showBadge) ...[');
  
  // Write back
  await file.writeAsString(content);
  print('Fixed $fixCount issues in settings_screen.dart');
}