import 'dart:io';

void main() async {
  print('🔍 Finding all hardcoded design values...');
  
  final projectDir = Directory('lib');
  final files = await projectDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  final Map<String, List<String>> hardcodedValues = {
    'padding': [],
    'margin': [],
    'fontSize': [],
    'iconSize': [],
    'borderRadius': [],
    'colors': [],
    'dimensions': [],
    'spacing': [],
  };
  
  // Patterns to find hardcoded values
  final patterns = {
    'padding': RegExp(r'padding:\s*(?:EdgeInsets\.all\(|EdgeInsets\.symmetric\([^)]*\))\s*(\d+(?:\.\d+)?)\)'),
    'margin': RegExp(r'margin:\s*(?:EdgeInsets\.all\(|EdgeInsets\.symmetric\([^)]*\))\s*(\d+(?:\.\d+)?)\)'),
    'fontSize': RegExp(r'fontSize:\s*(\d+(?:\.\d+)?)'),
    'iconSize': RegExp(r'size:\s*(\d+(?:\.\d+)?)[,\s\)]'),
    'borderRadius': RegExp(r'BorderRadius\.circular\((\d+(?:\.\d+)?)\)'),
    'hardcodedColors': RegExp(r'Color\(0x[A-Fa-f0-9]+\)|Colors\.\w+(?:\[\d+\])?'),
    'hardcodedSpacing': RegExp(r'(?:SizedBox|Container)\([^)]*(?:width|height):\s*(\d+(?:\.\d+)?)[,\)]'),
    'hardcodedDimensions': RegExp(r'(?:width|height|size):\s*(\d+(?:\.\d+)?)[,\s\)]'),
  };
  
  for (final file in files) {
    final content = await file.readAsString();
    final relativePath = file.path.replaceFirst('lib/', '');
    
    // Skip generated files and tests
    if (relativePath.contains('.g.dart') || 
        relativePath.contains('test/') ||
        relativePath.contains('app_spacing.dart') ||
        relativePath.contains('app_dimensions.dart') ||
        relativePath.contains('app_colors.dart') ||
        relativePath.contains('app_typography.dart')) {
      continue;
    }
    
    patterns.forEach((type, pattern) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        final line = _getLineNumber(content, match.start);
        final context = _getLineContext(content, match.start);
        
        // Filter out valid theme references
        if (!_isValidThemeReference(context)) {
          hardcodedValues[type]?.add('$relativePath:$line - $context');
        }
      }
    });
  }
  
  // Print results
  print('\n📊 Summary of hardcoded design values:\n');
  
  hardcodedValues.forEach((type, occurrences) {
    if (occurrences.isNotEmpty) {
      print('$type: ${occurrences.length} occurrences');
      // Print first 5 examples
      occurrences.take(5).forEach((occurrence) {
        print('  - $occurrence');
      });
      if (occurrences.length > 5) {
        print('  ... and ${occurrences.length - 5} more');
      }
      print('');
    }
  });
  
  // Create a report file
  final report = StringBuffer();
  report.writeln('# Hardcoded Design Values Report');
  report.writeln('Generated on: ${DateTime.now()}');
  report.writeln('');
  
  hardcodedValues.forEach((type, occurrences) {
    if (occurrences.isNotEmpty) {
      report.writeln('## $type (${occurrences.length} occurrences)');
      occurrences.forEach((occurrence) {
        report.writeln('- $occurrence');
      });
      report.writeln('');
    }
  });
  
  await File('HARDCODED_VALUES_REPORT.md').writeAsString(report.toString());
  print('✅ Report saved to HARDCODED_VALUES_REPORT.md');
}

int _getLineNumber(String content, int position) {
  return '\n'.allMatches(content.substring(0, position)).length + 1;
}

String _getLineContext(String content, int position) {
  final start = content.lastIndexOf('\n', position - 1) + 1;
  final end = content.indexOf('\n', position);
  final line = content.substring(start, end == -1 ? content.length : end);
  return line.trim();
}

bool _isValidThemeReference(String context) {
  // Check if it's using theme references
  return context.contains('AppSpacing.') ||
         context.contains('AppDimensions.') ||
         context.contains('AppColors.') ||
         context.contains('AppTypography.') ||
         context.contains('Theme.of(context)');
}