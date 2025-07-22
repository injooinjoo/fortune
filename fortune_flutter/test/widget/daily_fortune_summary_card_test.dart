import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/presentation/widgets/daily_fortune_summary_card.dart';
import 'package:fortune/domain/entities/fortune.dart';

void main() {
  // Ensure animations are properly handled in tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DailyFortuneSummaryCard Color Handling', () {
    testWidgets('handles hex color correctly', (WidgetTester tester) async {
      final fortune = DailyFortune(
        score: 85,
        keywords: ['행운', '기회', '성장'],
        summary: 'Test fortune',
        luckyColor: '#FF6B6B',
        luckyNumber: 7,
        energy: 80,
        mood: '평온함',
        advice: '좋은 하루 되세요',
        caution: '조심하세요',
        bestTime: '오후 2시',
        compatibility: '좋음',
        elements: FortuneElements(
          love: 80,
          career: 85,
          money: 75,
          health: 90,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyFortuneSummaryCard(
              fortune: fortune,
              isLoading: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      // The widget should render without errors
      expect(find.byType(DailyFortuneSummaryCard), findsOneWidget);
    });

    testWidgets('handles Korean color name correctly', (WidgetTester tester) async {
      final fortune = DailyFortune(
        score: 85,
        keywords: ['행운', '기회', '성장'],
        summary: 'Test fortune',
        luckyColor: '청록색', // Korean color name
        luckyNumber: 7,
        energy: 80,
        mood: '평온함',
        advice: '좋은 하루 되세요',
        caution: '조심하세요',
        bestTime: '오후 2시',
        compatibility: '좋음',
        elements: FortuneElements(
          love: 80,
          career: 85,
          money: 75,
          health: 90,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyFortuneSummaryCard(
              fortune: fortune,
              isLoading: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      // Allow animations to complete
      await tester.pumpAndSettle();
      
      // The widget should render without errors
      expect(find.byType(DailyFortuneSummaryCard), findsOneWidget);
      
      // Verify that no FormatException is thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles unknown color name with fallback', (WidgetTester tester) async {
      final fortune = DailyFortune(
        score: 85,
        keywords: ['행운', '기회', '성장'],
        summary: 'Test fortune',
        luckyColor: '알수없는색', // Unknown color name
        luckyNumber: 7,
        energy: 80,
        mood: '평온함',
        advice: '좋은 하루 되세요',
        caution: '조심하세요',
        bestTime: '오후 2시',
        compatibility: '좋음',
        elements: FortuneElements(
          love: 80,
          career: 85,
          money: 75,
          health: 90,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyFortuneSummaryCard(
              fortune: fortune,
              isLoading: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();
      
      // The widget should render without errors and use the fallback color
      expect(find.byType(DailyFortuneSummaryCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}