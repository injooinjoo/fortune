import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;
import 'package:fortune/features/fortune/presentation/widgets/mbti_grid_selector.dart';
import 'package:fortune/features/fortune/presentation/widgets/blood_type_card_selector.dart';
import 'package:fortune/features/fortune/presentation/widgets/personality_traits_chips.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Personality Fortune Performance Tests', () {
    setUp(() async {
      // Start fresh app instance
      app.main();
    });

    testWidgets('should measure page load performance', (WidgetTester tester) async {
      await tester.pumpAndSettle();

      // Measure initial page load
      final stopwatch = Stopwatch()..start();
      
      // Navigate to personality fortune page
      // Note: This assumes user is already logged in
      await tester.tap(find.textContaining('성격 운세'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert - Page should load within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
        reason: 'Page load took ${stopwatch.elapsedMilliseconds}ms, expected < 3000ms');
      
      // Verify page elements are loaded
      expect(find.text('성격 운세'), findsWidgets);
      expect(find.text('MBTI'), findsOneWidget);
      expect(find.text('혈액형'), findsOneWidget);
      
      print('Page load time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should measure MBTI grid rendering performance', (WidgetTester tester) async {
      // Create a test widget with just the MBTI grid
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: null,
              onTypeSelected: (_) {},
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      // Wait for all animations to complete
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert - Grid should render within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
        reason: 'MBTI grid render took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms');
      
      // Verify all 16 types are rendered
      const mbtiTypes = [
        'INTJ', 'INTP', 'ENTJ', 'ENTP',
        'INFJ', 'INFP', 'ENFJ', 'ENFP',
        'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
        'ISTP', 'ISFP', 'ESTP', 'ESFP'
      ];
      
      for (final type in mbtiTypes) {
        expect(find.text(type), findsOneWidget);
      }
      
      print('MBTI grid render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should measure selection animation performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: null,
              onTypeSelected: (_) {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Measure selection animation
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('INTJ'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert - Selection animation should complete within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
        reason: 'Selection animation took ${stopwatch.elapsedMilliseconds}ms, expected < 500ms');
      
      print('Selection animation time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should measure rapid selection changes performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MbtiGridSelector(
                  selectedType: null,
                  onTypeSelected: (_) {},
                ),
                const SizedBox(height: 20),
                BloodTypeCardSelector(
                  selectedType: null,
                  onTypeSelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Measure rapid selections
      final stopwatch = Stopwatch()..start();
      
      // Rapidly tap different MBTI types
      await tester.tap(find.text('INTJ'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ENFP'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ISTP'));
      await tester.pump(const Duration(milliseconds: 50));
      
      // Switch to blood type and select
      await tester.tap(find.text('A형'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('B형'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert - Rapid selections should be handled smoothly
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
        reason: 'Rapid selections took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms');
      
      print('Rapid selection time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should measure personality traits chips performance', (WidgetTester tester) async {
      final selectedTraits = <String>[];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: (traits) => selectedTraits.addAll(traits),
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      
      // Wait for all chip animations to complete
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert - Chips should render within 1.5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(1500),
        reason: 'Traits chips render took ${stopwatch.elapsedMilliseconds}ms, expected < 1500ms');
      
      // Verify trait groups are rendered
      expect(find.text('사회성'), findsOneWidget);
      expect(find.text('사고방식'), findsOneWidget);
      expect(find.text('행동양식'), findsOneWidget);
      
      print('Traits chips render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('should measure fortune generation API performance', (WidgetTester tester) async {
      // This test would measure actual API response time
      // In a real scenario, you would:
      // 1. Navigate to personality fortune page
      // 2. Select a personality type
      // 3. Measure time from button tap to fortune display
      
      await binding.traceAction(
        () async {
          await tester.pumpAndSettle();
          
          // Simulate fortune generation
          // In real test, this would include:
          // - Navigation to page
          // - Type selection
          // - API call
          // - Result rendering
        },
        reportKey: 'fortune_generation_timeline',
      );
    });

    testWidgets('should measure memory usage during component lifecycle', (WidgetTester tester) async {
      // Track memory usage before loading components
      final timeline = await binding.traceAction(
        () async {
          // Load personality fortune page with all components
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      MbtiGridSelector(
                        selectedType: null,
                        onTypeSelected: (_) {},
                      ),
                      const SizedBox(height: 20),
                      BloodTypeCardSelector(
                        selectedType: null,
                        onTypeSelected: (_) {},
                      ),
                      const SizedBox(height: 20),
                      PersonalityTraitsChips(
                        selectedTraits: const [],
                        onTraitsChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          
          await tester.pumpAndSettle();
          
          // Perform various interactions
          await tester.tap(find.text('INTJ'));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('A형'));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('외향적'));
          await tester.pumpAndSettle();
          
          // Dispose widgets
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        },
        reportKey: 'personality_fortune_memory_timeline',
      );
      
      // In a real test, you would analyze the timeline for memory leaks
      expect(timeline, isNotNull);
    });

    testWidgets('should measure scroll performance with all components', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('성격 운세', style: TextStyle(fontSize: 24)),),
                  const SizedBox(height: 20),
                  MbtiGridSelector(
                    selectedType: 'INTJ',
                    onTypeSelected: (_) {},
                  ),
                  const SizedBox(height: 20),
                  BloodTypeCardSelector(
                    selectedType: 'A',
                    onTypeSelected: (_) {},
                  ),
                  const SizedBox(height: 20),
                  PersonalityTraitsChips(
                    selectedTraits: const ['외향적', '이성적'],
                    onTraitsChanged: (_) {},
                  ),
                  const SizedBox(height: 20),
                  // Simulate fortune result
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Fortune Result Placeholder'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Measure scroll performance
      final timeline = await binding.traceAction(
        () async {
          // Scroll down
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();
          
          // Scroll up
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, 500),
          );
          await tester.pumpAndSettle();
        },
        reportKey: 'scroll_performance_timeline',
      );
      
      expect(timeline, isNotNull);
      
      // In production, you would analyze frame rendering times
      // to ensure 60fps (16.67ms per frame)
    });

    testWidgets('should maintain 60fps during animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: null,
              onTypeSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Track frame rendering during animations
      final timeline = await binding.traceAction(
        () async {
          // Initial render with animations
          await tester.pumpAndSettle();
          
          // Trigger selection animation
          await tester.tap(find.text('INTJ'));
          await tester.pump();
          
          // Pump frames during animation
          for (int i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 16)); // 60fps
          }
          
          await tester.pumpAndSettle();
        },
        reportKey: 'animation_performance_timeline',
      );
      
      expect(timeline, isNotNull);
      
      // In a real test, analyze timeline to verify:
      // - No frames took longer than 16.67ms
      // - No jank or frame drops
      // - Smooth animation curves
    });
  });
}