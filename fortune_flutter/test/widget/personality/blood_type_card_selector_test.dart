import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/fortune/presentation/widgets/blood_type_card_selector.dart';

void main() {
  group('BloodTypeCardSelector Widget Tests', () {
    late String? selectedType;
    late void Function(String) onTypeSelected;

    setUp(() {
      selectedType = null;
      onTypeSelected = (String type) {
        selectedType = type;
      };
    });

    testWidgets('should display all 4 blood types', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check all blood types are displayed
      expect(find.text('A형'), findsOneWidget);
      expect(find.text('B형'), findsOneWidget);
      expect(find.text('O형'), findsOneWidget);
      expect(find.text('AB형'), findsOneWidget);
    });

    testWidgets('should display descriptions for each blood type', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check descriptions are displayed
      expect(find.text('신중하고\n꼼꼼한'), findsOneWidget); // A
      expect(find.text('자유롭고\n창의적인'), findsOneWidget); // B
      expect(find.text('사교적이고\n활발한'), findsOneWidget); // O
      expect(find.text('독특하고\n이성적인'), findsOneWidget); // AB
    });

    testWidgets('should display icons for each blood type', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check icons are displayed
      expect(find.byIcon(Icons.favorite), findsOneWidget); // A
      expect(find.byIcon(Icons.flash_on), findsOneWidget); // B
      expect(find.byIcon(Icons.public), findsOneWidget); // O
      expect(find.byIcon(Icons.stars), findsOneWidget); // AB
      expect(find.byIcon(Icons.water_drop), findsWidgets); // Background decoration
    });

    testWidgets('should handle type selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Tap on B type
      await tester.tap(find.text('B형'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedType, equals('B'));
    });

    testWidgets('should highlight selected type with visual feedback', (WidgetTester tester) async {
      // Arrange
      selectedType = 'O';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for selected indicator
      final oCard = find.ancestor(
        of: find.text('O형'),
        matching: find.byType(AnimatedContainer),
      ).first;
      
      // Check that selected card has gradient and check icon
      expect(
        find.descendant(
          of: find.ancestor(of: oCard, matching: find.byType(Stack)),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should use correct colors for each blood type', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: 'A',
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - A type should have blue color
      final aContainer = find.ancestor(
        of: find.text('A형'),
        matching: find.byType(AnimatedContainer),
      ).first;

      final AnimatedContainer container = tester.widget(aContainer);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.gradient, isNotNull);
      expect(decoration?.gradient, isA<LinearGradient>());
      
      // Check gradient contains blue color
      final gradient = decoration?.gradient as LinearGradient;
      expect(gradient.colors.first, equals(const Color(0xFF3B82F6)));
    });

    testWidgets('should handle tap animations correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Start tap on AB type
      final abFinder = find.text('AB형');
      final gesture = await tester.startGesture(tester.getCenter(abFinder));
      await tester.pump(const Duration(milliseconds: 50));

      // Animation should be active during tap
      
      // Complete tap
      await gesture.up();
      await tester.pumpAndSettle();
      
      // Assert
      expect(selectedType, equals('AB'));
    });

    testWidgets('should layout cards horizontally with proper spacing', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check horizontal layout
      final row = find.byType(Row).first;
      expect(row, findsOneWidget);

      // Check that cards are positioned horizontally
      final aPosition = tester.getCenter(find.text('A형'));
      final bPosition = tester.getCenter(find.text('B형'));
      final oPosition = tester.getCenter(find.text('O형'));
      final abPosition = tester.getCenter(find.text('AB형'));

      // Y positions should be similar (horizontal alignment)
      expect((aPosition.dy - bPosition.dy).abs(), lessThan(5));
      expect((bPosition.dy - oPosition.dy).abs(), lessThan(5));
      expect((oPosition.dy - abPosition.dy).abs(), lessThan(5));

      // X positions should be increasing (left to right)
      expect(bPosition.dx, greaterThan(aPosition.dx));
      expect(oPosition.dx, greaterThan(bPosition.dx));
      expect(abPosition.dx, greaterThan(oPosition.dx));
    });

    testWidgets('should handle rapid selection changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Act - Rapid taps
      await tester.tap(find.text('A형'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('B형'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('O형'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('AB형'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedType, equals('AB'));
    });

    testWidgets('should have minimum tap target size for accessibility', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - Check tap target sizes
      for (final bloodType in ['A형', 'B형', 'O형', 'AB형']) {
        final card = find.ancestor(
          of: find.text(bloodType),
          matching: find.byType(AnimatedContainer),
        ).first;
        
        final size = tester.getSize(card);
        // Minimum tap target should be 48x48 according to Material guidelines
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('should show shadow for selected card', (WidgetTester tester) async {
      // Arrange
      selectedType = 'B';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Selected card should have shadow
      final bContainer = find.ancestor(
        of: find.text('B형'),
        matching: find.byType(AnimatedContainer),
      ).first;

      final AnimatedContainer container = tester.widget(bContainer);
      final BoxDecoration? decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.boxShadow, isNotNull);
      expect(decoration?.boxShadow, isNotEmpty);
    });

    testWidgets('should display water drop background icon for selected card', (WidgetTester tester) async {
      // Arrange
      selectedType = 'O';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Selected card should have background water drop
      final oCard = find.ancestor(
        of: find.text('O형'),
        matching: find.byType(Stack),
      ).first;

      // Look for large water drop icon in the stack
      final waterDrops = find.descendant(
        of: oCard,
        matching: find.byIcon(Icons.water_drop),
      );
      
      // Should find at least 2 water drops (one in circle, one as background)
      expect(waterDrops, findsWidgets);
      expect(waterDrops.evaluate().length, greaterThanOrEqualTo(2));
    });

    testWidgets('should handle null initial selection', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: null,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Assert - No card should be selected
      expect(find.byIcon(Icons.check), findsNothing);
      
      // All cards should have grey background
      for (final bloodType in ['A형', 'B형', 'O형', 'AB형']) {
        final container = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.text(bloodType),
            matching: find.byType(AnimatedContainer),
          ).first,
        );
        
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.gradient, isNull);
        expect(decoration?.color, isNotNull);
      }
    });

    testWidgets('should animate fade in and slide for each card', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BloodTypeCardSelector(
              selectedType: selectedType,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ),
      );

      // Initial pump to start animations
      await tester.pump();
      
      // Pump through animation duration
      await tester.pump(const Duration(milliseconds: 150)); // Halfway through
      await tester.pump(const Duration(milliseconds: 150)); // Complete
      
      // Assert - All cards should be visible after animation
      expect(find.text('A형'), findsOneWidget);
      expect(find.text('B형'), findsOneWidget);
      expect(find.text('O형'), findsOneWidget);
      expect(find.text('AB형'), findsOneWidget);
    });
  });
}