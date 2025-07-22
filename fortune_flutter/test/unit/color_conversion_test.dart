import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test helper to simulate the color conversion logic
Color getColorFromName(BuildContext context, String colorName) {
  // First, check if it's a hex color
  if (colorName.startsWith('#')) {
    try {
      return Color(int.parse(colorName.replaceAll('#', '0xFF')));
    } catch (e) {
      // If hex parsing fails, continue to color name mapping
    }
  }

  // Korean color name to Flutter color mapping
  final colorMap = {
    '빨간색': Colors.red,
    '파란색': Colors.blue,
    '노란색': Colors.yellow,
    '초록색': Colors.green,
    '보라색': Colors.purple,
    '주황색': Colors.orange,
    '분홍색': Colors.pink,
    '하얀색': Colors.white,
    '검은색': Colors.black,
    '회색': Colors.grey,
    '갈색': Colors.brown,
    '금색': Colors.amber,
    '은색': Colors.grey[300]!,
    '하늘색': Colors.lightBlue,
    '남색': Colors.indigo,
    '청록색': Colors.teal,
  };
  
  // Return mapped color or default to primary color
  return colorMap[colorName] ?? Theme.of(context).colorScheme.primary;
}

void main() {
  testWidgets('Color conversion handles various inputs correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Builder(
          builder: (context) {
            // Test hex color
            final hexColor = getColorFromName(context, '#FF6B6B');
            expect(hexColor, equals(const Color(0xFFFF6B6B)));
            
            // Test Korean color names
            expect(getColorFromName(context, '청록색'), equals(Colors.teal));
            expect(getColorFromName(context, '빨간색'), equals(Colors.red));
            expect(getColorFromName(context, '파란색'), equals(Colors.blue));
            expect(getColorFromName(context, '노란색'), equals(Colors.yellow));
            expect(getColorFromName(context, '초록색'), equals(Colors.green));
            expect(getColorFromName(context, '보라색'), equals(Colors.purple));
            expect(getColorFromName(context, '주황색'), equals(Colors.orange));
            expect(getColorFromName(context, '분홍색'), equals(Colors.pink));
            expect(getColorFromName(context, '하얀색'), equals(Colors.white));
            expect(getColorFromName(context, '검은색'), equals(Colors.black));
            expect(getColorFromName(context, '회색'), equals(Colors.grey));
            expect(getColorFromName(context, '갈색'), equals(Colors.brown));
            expect(getColorFromName(context, '금색'), equals(Colors.amber));
            expect(getColorFromName(context, '은색'), equals(Colors.grey[300]));
            expect(getColorFromName(context, '하늘색'), equals(Colors.lightBlue));
            expect(getColorFromName(context, '남색'), equals(Colors.indigo));
            
            // Test unknown color name - should return primary color
            final unknownColor = getColorFromName(context, '알수없는색');
            expect(unknownColor, equals(Theme.of(context).colorScheme.primary));
            
            // Test invalid hex color - should fall back to primary color
            final invalidHex = getColorFromName(context, '#GGGGGG');
            expect(invalidHex, equals(Theme.of(context).colorScheme.primary));
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}