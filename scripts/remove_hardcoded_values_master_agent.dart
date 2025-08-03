import 'dart:io';

void main() async {
  print('🤖 Master,
    Agent: Removing hardcoded design values...');
  
  final updates = <String, int>{
    'padding': 0,
    'fontSize': 0,
    'iconSize': 0,
    'borderRadius': 0,
    'spacing': 0,
    'dimensions': 0,
  };
  
  // Process all dart files
  final projectDir = Directory('lib');
  final files = await projectDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  for (final file in files) {
    // Skip theme files and generated files
    if (file.path.contains('app_spacing.dart') ||
        file.path.contains('app_dimensions.dart') ||
        file.path.contains('app_colors.dart') ||
        file.path.contains('app_typography.dart') ||
        file.path.contains('.g.dart')) {
      continue;
    }
    
    var content = await file.readAsString();
    final originalContent = content;
    
    // Replace hardcoded paddings
    content = _replacePadding(content, updates);
    
    // Replace hardcoded font sizes
    content = _replaceFontSizes(content, updates);
    
    // Replace hardcoded icon sizes
    content = _replaceIconSizes(content, updates);
    
    // Replace hardcoded border radius
    content = _replaceBorderRadius(content, updates);
    
    // Replace hardcoded spacing (SizedBox)
    content = _replaceSpacing(content, updates);
    
    // Replace hardcoded dimensions
    content = _replaceDimensions(content, updates);
    
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Updated ${file.path}');
    }
  }
  
  // Print summary
  print('\n📊 Summary:');
  updates.forEach((type, count) {
    if (count > 0) {
      print('  - Replaced $count $type values');
    }
  });
  
  print('\n✅ Master Agent completed!');
}

String _replacePadding(String content, Map<String, int> updates) {
  // Replace EdgeInsets.all
  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.all\((\d+(?:\.\d+)?)\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      updates['padding'] = updates['padding']! + 1;
      return _getPaddingReplacement(value);
    }
  );
  
  // Replace EdgeInsets.symmetric
  content = content.replaceAllMapped(
    RegExp(r'EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*(?:,\s*vertical:\s*(\d+(?:\.\d+)?))?\s*\)'),
    (match) {
      final horizontal = double.parse(match.group(1)!);
      final vertical = match.group(2) != null ? double.parse(match.group(2)!) : null;
      updates['padding'] = updates['padding']! + 1;
      
      if (vertical != null) {
        return 'EdgeInsets.symmetric(horizontal: ${_getSpacingConstant(horizontal)}, vertical: ${_getSpacingConstant(vertical)})';
      } else {
        return 'EdgeInsets.symmetric(horizontal: ${_getSpacingConstant(horizontal)})';
      }
    }
  );
  
  return content;
}

String _replaceFontSizes(String content, Map<String, int> updates) {
  // Skip if in app_text_styles or typography files
  if (content.contains('class AppTextStyles') || 
      content.contains('class AppTypography')) {
    return content;
  }
  
  return content.replaceAllMapped(
    RegExp(r'fontSize:\s*(\d+(?:\.\d+)?)([,\s\)])'),
    (match) {
      final value = double.parse(match.group(1)!);
      final suffix = match.group(2)!;
      updates['fontSize'] = updates['fontSize']! + 1;
      
      // Use typography constants
      final typographySize = _getTypographySize(value);
      if (typographySize != null) {
        return 'fontSize: $typographySize$suffix';
      }
      return match.group(0)!;
    }
  );
}

String _replaceIconSizes(String content, Map<String, int> updates) {
  return content.replaceAllMapped(
    RegExp(r'(?:Icon|Icons\.[\w_]+)\s*\([^)]*size:\s*(\d+(?:\.\d+)?)([,\s\)])'),
    (match) {
      final value = double.parse(match.group(1)!);
      final suffix = match.group(2)!;
      updates['iconSize'] = updates['iconSize']! + 1;
      
      final iconSize = _getIconSizeConstant(value);
      return match.group(0)!.replaceFirst(
        'size: ${match.group(1)}$suffix',
        'size: $iconSize$suffix'
      );
    }
  );
}

String _replaceBorderRadius(String content, Map<String, int> updates) {
  return content.replaceAllMapped(
    RegExp(r'BorderRadius\.circular\((\d+(?:\.\d+)?)\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      updates['borderRadius'] = updates['borderRadius']! + 1;
      
      final radiusConstant = _getRadiusConstant(value);
      return 'BorderRadius.circular($radiusConstant)';
    }
  );
}

String _replaceSpacing(String content, Map<String, int> updates) {
  // Replace SizedBox with hardcoded values
  content = content.replaceAllMapped(
    RegExp(r'SizedBox\(\s*(?:width|height):\s*(\d+(?:\.\d+)?)\s*\)'),
    (match) {
      final value = double.parse(match.group(1)!);
      final isWidth = match.group(0)!.contains('width');
      updates['spacing'] = updates['spacing']! + 1;
      
      final spacing = _getSpacingConstant(value);
      return 'SizedBox(${isWidth ? "width" : "height"}: $spacing)';
    }
  );
  
  return content;
}

String _replaceDimensions(String content, Map<String, int> updates) {
  // Replace hardcoded width/height in Container, etc.
  content = content.replaceAllMapped(
    RegExp(r'(?<!Icon.*\s)(?:width|height):\s*(\d+(?:\.\d+)?)([,\s\)])'),
    (match) {
      final value = double.parse(match.group(1)!);
      final suffix = match.group(2)!;
      final property = match.group(0)!.contains('width') ? 'width' : 'height';
      
      // Skip small values (likely to be borders, etc.)
      if (value < 4) return match.group(0)!;
      
      updates['dimensions'] = updates['dimensions']! + 1;
      
      final dimension = _getDimensionConstant(value);
      return '$property: $dimension$suffix';
    }
  );
  
  return content;
}

// Helper functions to map values to constants
String _getPaddingReplacement(double value) {
  if (value <= 2) return 'AppSpacing.paddingAll0';
  if (value <= 4) return 'AppSpacing.paddingAll4';
  if (value <= 8) return 'AppSpacing.paddingAll8';
  if (value <= 12) return 'AppSpacing.paddingAll12';
  if (value <= 16) return 'AppSpacing.paddingAll16';
  if (value <= 20) return 'AppSpacing.paddingAll20';
  if (value <= 24) return 'AppSpacing.paddingAll24';
  if (value <= 32) return 'AppSpacing.paddingAll32';
  return 'EdgeInsets.all($value)'; // Keep original for unusual values
}

String _getSpacingConstant(double value) {
  if (value <= 0) return 'AppSpacing.spacing0';
  if (value <= 2) return 'AppSpacing.spacing0';
  if (value <= 4) return 'AppSpacing.spacing1';
  if (value <= 8) return 'AppSpacing.spacing2';
  if (value <= 12) return 'AppSpacing.spacing3';
  if (value <= 16) return 'AppSpacing.spacing4';
  if (value <= 20) return 'AppSpacing.spacing5';
  if (value <= 24) return 'AppSpacing.spacing6';
  if (value <= 32) return 'AppSpacing.spacing8';
  if (value <= 48) return 'AppSpacing.spacing12';
  return '$value'; // Keep original for unusual values
}

String? _getTypographySize(double value) {
  // Skip common non-typography sizes
  if (value == 1 || value == 2) return null;
  
  if (value >= 30) return 'AppTypography.displayLarge';
  if (value >= 26) return 'AppTypography.displayMedium';
  if (value >= 22) return 'AppTypography.displaySmall';
  if (value >= 20) return 'AppTypography.headlineLarge';
  if (value >= 18) return 'AppTypography.headlineMedium';
  if (value >= 16) return 'AppTypography.headlineSmall';
  if (value >= 14) return 'AppTypography.bodyLarge';
  if (value >= 12) return 'AppTypography.bodyMedium';
  if (value >= 10) return 'AppTypography.bodySmall';
  return null;
}

String _getIconSizeConstant(double value) {
  if (value <= 16) return 'AppDimensions.iconSizeXSmall';
  if (value <= 20) return 'AppDimensions.iconSizeSmall';
  if (value <= 24) return 'AppDimensions.iconSizeMedium';
  if (value <= 32) return 'AppDimensions.iconSizeLarge';
  if (value <= 48) return 'AppDimensions.iconSizeXLarge';
  return '$value'; // Keep original for unusual values
}

String _getRadiusConstant(double value) {
  if (value <= 4) return 'AppDimensions.radiusSmall';
  if (value <= 8) return 'AppDimensions.radiusMedium';
  if (value <= 12) return 'AppDimensions.radiusLarge';
  if (value <= 16) return 'AppDimensions.radiusXLarge';
  if (value <= 24) return 'AppDimensions.radiusXXLarge';
  return 'AppDimensions.radiusMedium'; // Default to medium
}

String _getDimensionConstant(double value) {
  // Common button heights
  if (value >= 44 && value <= 56) return 'AppDimensions.buttonHeight';
  
  // Common container sizes
  if (value >= 40 && value <= 50) return 'AppDimensions.containerSmall';
  if (value >= 60 && value <= 80) return 'AppDimensions.containerMedium';
  if (value >= 100 && value <= 120) return 'AppDimensions.containerLarge';
  
  // Keep original for other values
  return '$value';
}