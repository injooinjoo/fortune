import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_flutter/presentation/widgets/fortune_card.dart';

void main() {
  group('FortuneCard Widget Tests', () {
    testWidgets('should display all required elements', (WidgetTester tester) async {
      // Arrange
      const testIcon = Icons.star;
      const testTitle = 'Daily Fortune';
      const testDescription = 'Check your fortune for today';
      var tapCount = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: testIcon,
              title: testTitle,
              description: testDescription,
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testDescription), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      var tapCount = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FortuneCard));
      await tester.pump();

      // Assert
      expect(tapCount, 1);

      // Tap again
      await tester.tap(find.byType(FortuneCard));
      await tester.pump();

      expect(tapCount, 2);
    });

    testWidgets('should display badge when provided', (WidgetTester tester) async {
      // Arrange
      const testBadge = 'NEW';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
              badge: testBadge,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testBadge), findsOneWidget);
      
      // Verify badge container exists
      final badgeContainer = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.grey.shade100,
      );
      expect(badgeContainer, findsOneWidget);
    });

    testWidgets('should not display badge when not provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      // Should not find any badge containers
      final badgeContainer = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.padding == const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      );
      expect(badgeContainer, findsNothing);
    });

    testWidgets('should apply custom icon color', (WidgetTester tester) async {
      // Arrange
      const customIconColor = Colors.red;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
              iconColor: customIconColor,
            ),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(customIconColor));
    });

    testWidgets('should apply custom background color', (WidgetTester tester) async {
      // Arrange
      const customBackgroundColor = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
              backgroundColor: customBackgroundColor,
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customBackgroundColor));
    });

    testWidgets('should handle long text with ellipsis', (WidgetTester tester) async {
      // Arrange
      const longDescription = 'This is a very long description that should be truncated with ellipsis when it exceeds the maximum number of lines allowed in the widget';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: FortuneCard(
                icon: Icons.star,
                title: 'Test Card',
                description: longDescription,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Assert
      final descriptionText = tester.widget<Text>(
        find.text(longDescription),
      );
      expect(descriptionText.maxLines, equals(2));
      expect(descriptionText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should apply proper styling to elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
            textTheme: const TextTheme(
              titleMedium: TextStyle(fontSize: 16),
              bodySmall: TextStyle(fontSize: 12),
              labelSmall: TextStyle(fontSize: 10),
            ),
          ),
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
              badge: 'NEW',
            ),
          ),
        ),
      );

      // Assert icon container styling
      final iconContainer = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius == BorderRadius.circular(24),
        ),
      );
      expect(iconContainer.width, equals(48));
      expect(iconContainer.height, equals(48));

      // Assert title text styling
      final titleText = tester.widget<Text>(find.text('Test Card'));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.textAlign, equals(TextAlign.center));

      // Assert description text styling
      final descriptionText = tester.widget<Text>(find.text('Test Description'));
      expect(descriptionText.textAlign, equals(TextAlign.center));

      // Assert badge text styling
      final badgeText = tester.widget<Text>(find.text('NEW'));
      expect(badgeText.style?.fontWeight, equals(FontWeight.w500));
    });

    testWidgets('should have proper border and shadow', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      
      // Check border
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, equals(1));
      
      // Check border radius
      expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
      
      // Check shadow
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
      expect(decoration.boxShadow!.first.blurRadius, equals(8));
      expect(decoration.boxShadow!.first.offset, equals(const Offset(0, 2)));
    });

    testWidgets('should have correct padding', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Container),
          matching: find.byType(Padding),
        ).first,
      );
      
      expect(padding.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Test Card',
              description: 'Test Description',
              onTap: () {},
              badge: 'NEW',
            ),
          ),
        ),
      );

      // Assert
      final sizedBoxes = find.byType(SizedBox).evaluate().toList();
      
      // Should have 3 SizedBox widgets for spacing
      expect(sizedBoxes.length, equals(3));
      
      // Check heights
      final sizedBox1 = tester.widget<SizedBox>(find.byType(SizedBox).at(0));
      expect(sizedBox1.height, equals(12)); // After icon
      
      final sizedBox2 = tester.widget<SizedBox>(find.byType(SizedBox).at(1));
      expect(sizedBox2.height, equals(4)); // After title
      
      final sizedBox3 = tester.widget<SizedBox>(find.byType(SizedBox).at(2));
      expect(sizedBox3.height, equals(8)); // Before badge
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FortuneCard(
              icon: Icons.star,
              title: 'Daily Fortune',
              description: 'Check your fortune for today',
              onTap: () {},
              badge: 'NEW',
            ),
          ),
        ),
      );

      // Assert
      // Check that all text is accessible
      expect(find.bySemanticsLabel('Daily Fortune'), findsOneWidget);
      expect(find.bySemanticsLabel('Check your fortune for today'), findsOneWidget);
      expect(find.bySemanticsLabel('NEW'), findsOneWidget);
      
      // Check that the card is tappable
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNotNull);
    });
  });
}