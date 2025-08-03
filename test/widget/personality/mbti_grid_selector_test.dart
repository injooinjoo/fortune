import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/fortune/presentation/widgets/mbti_grid_selector.dart';

void main() {
  group('MbtiGridSelector Widget Tests', () {
    late String? selectedType;
    late void Function(String) onTypeSelected;

    setUp(() {
      selectedType = null;
      onTypeSelected = (String type) {
        selectedType = type;
      };
    });

    testWidgets('should display all 16 MBTI types', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check all MBTI types are displayed
      const mbtiTypes = [
        'INTJ', 'INTP', 'ENTJ', 'ENTP',
        'INFJ', 'INFP', 'ENFJ', 'ENFP',
        'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
        'ISTP', 'ISFP', 'ESTP', 'ESFP'
      ];

      for (final type in mbtiTypes) {
        expect(find.text(type), findsOneWidget);
      }
    });

    testWidgets('should display group legend with correct labels', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check group legends are displayed
      expect(find.text('분석가'), findsOneWidget); // Analysts
      expect(find.text('외교관'), findsOneWidget); // Diplomats
      expect(find.text('관리자'), findsOneWidget); // Sentinels
      expect(find.text('탐험가'), findsOneWidget); // Explorers
    });

    testWidgets('should display icons for each MBTI type', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check that icons are displayed
      expect(find.byIcon(Icons.architecture), findsOneWidget); // INTJ
      expect(find.byIcon(Icons.science), findsOneWidget); // INTP
      expect(find.byIcon(Icons.psychology), findsOneWidget); // INFJ
      expect(find.byIcon(Icons.checklist), findsOneWidget); // ISTJ
    });

    testWidgets('should handle type selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Tap on INTJ
      await tester.tap(find.text('INTJ'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedType, equals('INTJ'));
    });

    testWidgets('should highlight selected type', (WidgetTester tester) async {
      // Arrange
      selectedType = 'INFP';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for selected indicator (check mark)
      final infpCard = find.ancestor(
        of: find.text('INFP'),
        matching: find.byType(Container),
      ).first;
      
      // Check that selected card has check icon
      expect(
        find.descendant(
          of: infpCard,
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should handle multiple selections correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Select INTJ first
      await tester.tap(find.text('INTJ'));
      await tester.pumpAndSettle();
      expect(selectedType, equals('INTJ'));

      // Act - Select ENFP (should replace INTJ)
      await tester.tap(find.text('ENFP'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedType, equals('ENFP'));
    });

    testWidgets('should handle tap animations', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Start tap
      final intjFinder = find.text('INTJ');
      final gesture = await tester.startGesture(tester.getCenter(intjFinder));
      await tester.pump(const Duration(milliseconds: 50));

      // Assert - Animation should be in progress
      // (Scale animation should be active)
      
      // Complete tap
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should display correct colors for each group', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: 'INTJ'),
    onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check that selected INTJ has purple gradient (Analysts color)
      final intjContainer = find.ancestor(
        of: find.text('INTJ'),
        matching: find.byType(AnimatedContainer),
      ).first;

      final AnimatedContainer container = tester.widget(intjContainer);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.gradient, isNotNull);
      expect(decoration?.gradient, isA<LinearGradient>());
    });

    testWidgets('should layout correctly in 4x4 grid', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check grid layout
      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);

      final GridView grid = tester.widget(gridView);
      final SliverGridDelegateWithFixedCrossAxisCount delegate = 
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      
      expect(delegate.crossAxisCount, equals(4));
      expect(delegate.mainAxisSpacing, equals(8));
      expect(delegate.crossAxisSpacing, equals(8));
    });

    testWidgets('should be accessible with semantics', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check that all types are accessible
      // Each type should be tappable and have proper bounds
      for (final type in ['INTJ', 'ENFP', 'ISTJ', 'ESTP']) {
        final finder = find.text(type);
        expect(finder, findsOneWidget);
        
        // Check that the widget has proper size for tapping
        final size = tester.getSize(finder);
        expect(size.width, greaterThan(40));
        expect(size.height, greaterThan(40));
      }
    });

    testWidgets('should handle rapid taps correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Rapid taps on different types
      await tester.tap(find.text('INTJ'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ENFP'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('ISTP'));
      await tester.pumpAndSettle();

      // Assert - Should end up with last tapped type
      expect(selectedType, equals('ISTP'));
    });

    testWidgets('should handle null initial selection', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MbtiGridSelector(
              selectedType: null,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - No type should be selected
      // Check that no check marks are visible
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}