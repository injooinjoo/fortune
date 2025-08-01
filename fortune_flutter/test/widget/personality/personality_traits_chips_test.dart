import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/fortune/presentation/widgets/personality_traits_chips.dart';

void main() {
  group('PersonalityTraitsChips Widget Tests', () {
    late List<String> selectedTraits;
    late void Function(List<String>) onTraitsChanged;

    setUp(() {
      selectedTraits = [];
      onTraitsChanged = (List<String> traits) {
        selectedTraits = traits;
      };
    });

    testWidgets('should display all trait groups and traits', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
              ),
            ),
          ),
        ),
      );

      // Assert - Check trait groups
      expect(find.text('사회성'), findsOneWidget);
      expect(find.text('사고방식'), findsOneWidget);
      expect(find.text('행동양식'), findsOneWidget);
      expect(find.text('리더십'), findsOneWidget);
      expect(find.text('창의성'), findsOneWidget);
      expect(find.text('성향'), findsOneWidget);

      // Check some traits from each group
      expect(find.text('외향적'), findsOneWidget);
      expect(find.text('이성적'), findsOneWidget);
      expect(find.text('계획적'), findsOneWidget);
      expect(find.text('리더형'), findsOneWidget);
      expect(find.text('창의적'), findsOneWidget);
      expect(find.text('낙천적'), findsOneWidget);
    });

    testWidgets('should display selection counter', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalityTraitsChips(
              selectedTraits: selectedTraits,
              onTraitsChanged: onTraitsChanged,
              maxSelection: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('성격 특성을 선택하세요'), findsOneWidget);
      expect(find.text('0 / 5'), findsOneWidget);
    });

    testWidgets('should handle trait selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Act - Select a trait
      await tester.tap(find.text('외향적'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedTraits, contains('외향적'));
      expect(selectedTraits.length, equals(1));
    });

    testWidgets('should update counter when traits are selected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Act - Select multiple traits
      await tester.tap(find.text('외향적'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('이성적'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('계획적'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('3 / 5'), findsOneWidget);
      expect(selectedTraits.length, equals(3));
    });

    testWidgets('should enforce maximum selection limit', (WidgetTester tester) async {
      // Arrange - Pre-select 5 traits (max)
      selectedTraits = ['외향적', '이성적', '계획적', '리더형', '창의적'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Act - Try to select another trait
      await tester.tap(find.text('낙천적'));
      await tester.pumpAndSettle();

      // Assert - Should still have only 5 traits
      expect(selectedTraits.length, equals(5));
      expect(selectedTraits, isNot(contains('낙천적')));
      expect(find.text('5 / 5'), findsOneWidget);
    });

    testWidgets('should show error color when at max selection', (WidgetTester tester) async {
      // Arrange - Pre-select 5 traits (max)
      selectedTraits = ['외향적', '이성적', '계획적', '리더형', '창의적'];
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              error: Colors.red,
            ),
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Assert - Counter should have error color
      final counterContainer = find.ancestor(
        of: find.text('5 / 5'),
        matching: find.byType(Container),
      ).first;

      final Container container = tester.widget(counterContainer);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      
      // Check that background has error color with alpha
      expect(decoration?.color, equals(Colors.red.withValues(alpha: 0.1)));
    });

    testWidgets('should allow deselection of selected traits', (WidgetTester tester) async {
      // Arrange - Pre-select some traits
      selectedTraits = ['외향적', '이성적'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: List.from(selectedTraits),
                onTraitsChanged: (traits) => selectedTraits = traits,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Act - Deselect a trait
      await tester.tap(find.text('외향적'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedTraits, isNot(contains('외향적')));
      expect(selectedTraits, contains('이성적'));
      expect(selectedTraits.length, equals(1));
    });

    testWidgets('should show clear all button when traits are selected', (WidgetTester tester) async {
      // Arrange
      selectedTraits = ['외향적', '이성적'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: List.from(selectedTraits),
                onTraitsChanged: (traits) => selectedTraits = traits,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Assert - Clear button should be visible
      expect(find.text('모두 지우기'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear all selected traits when clear button is tapped', (WidgetTester tester) async {
      // Arrange
      selectedTraits = ['외향적', '이성적', '계획적'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: List.from(selectedTraits),
                onTraitsChanged: (traits) => selectedTraits = traits,
                maxSelection: 5,
              ),
            ),
          ),
        ),
      );

      // Act - Tap clear all button
      await tester.tap(find.text('모두 지우기'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedTraits, isEmpty);
      expect(find.text('0 / 5'), findsOneWidget);
      expect(find.text('모두 지우기'), findsNothing); // Button should disappear
    });

    testWidgets('should display group color indicators', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
              ),
            ),
          ),
        ),
      );

      // Assert - Check for colored bars next to group titles
      // Find containers that are 4x16 (the color bars)
      final colorBars = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final decoration = widget.decoration as BoxDecoration?;
          return decoration?.color != null && 
                 widget.constraints?.maxWidth == 4 &&
                 widget.constraints?.maxHeight == 16;
        }
        return false;
      });

      expect(colorBars, findsNWidgets(6)); // One for each group
    });

    testWidgets('should handle chip animations on selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
              ),
            ),
          ),
        ),
      );

      // Act - Start tap on a chip
      final chipFinder = find.text('외향적');
      final gesture = await tester.startGesture(tester.getCenter(chipFinder));
      await tester.pump(const Duration(milliseconds: 50));

      // Complete tap
      await gesture.up();
      await tester.pumpAndSettle();

      // Assert
      expect(selectedTraits, contains('외향적'));
    });

    testWidgets('should use FilterChip for trait selection', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
              ),
            ),
          ),
        ),
      );

      // Assert - Check that FilterChips are used
      expect(find.byType(FilterChip), findsWidgets);
      
      // Count total traits (4 traits * 6 groups = 24)
      expect(find.byType(FilterChip).evaluate().length, equals(24));
    });

    testWidgets('should handle custom max selection', (WidgetTester tester) async {
      // Arrange
      const customMax = 3;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
                maxSelection: customMax,
              ),
            ),
          ),
        ),
      );

      // Assert - Check counter shows custom max
      expect(find.text('0 / 3'), findsOneWidget);

      // Act - Select traits up to max
      await tester.tap(find.text('외향적'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('이성적'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('계획적'));
      await tester.pumpAndSettle();

      // Try to select one more
      await tester.tap(find.text('리더형'));
      await tester.pumpAndSettle();

      // Assert - Should only have 3 selected
      expect(selectedTraits.length, equals(customMax));
      expect(find.text('3 / 3'), findsOneWidget);
    });

    testWidgets('should show selected state visually on chips', (WidgetTester tester) async {
      // Arrange
      selectedTraits = ['외향적'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
              ),
            ),
          ),
        ),
      );

      // Assert - Selected chip should have different styling
      final selectedChip = find.ancestor(
        of: find.text('외향적'),
        matching: find.byType(FilterChip),
      ).first;

      final FilterChip chip = tester.widget(selectedChip);
      expect(chip.selected, isTrue);
      
      // Unselected chip
      final unselectedChip = find.ancestor(
        of: find.text('내향적'),
        matching: find.byType(FilterChip),
      ).first;

      final FilterChip unselected = tester.widget(unselectedChip);
      expect(unselected.selected, isFalse);
    });

    testWidgets('should maintain scroll position during selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalityTraitsChips(
                selectedTraits: selectedTraits,
                onTraitsChanged: onTraitsChanged,
              ),
            ),
          ),
        ),
      );

      // Act - Scroll to bottom
      await tester.dragUntil(
        find.text('성향'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Select a trait from the bottom group
      await tester.tap(find.text('낙천적'));
      await tester.pumpAndSettle();

      // Assert - The trait should still be visible (scroll position maintained)
      expect(find.text('낙천적'), findsOneWidget);
      expect(selectedTraits, contains('낙천적'));
    });
  });
}