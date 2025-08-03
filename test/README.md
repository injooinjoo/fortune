# Fortune Flutter Testing Guide

## Overview

This directory contains all tests for the Fortune Flutter application. We follow a structured approach to testing with comprehensive coverage requirements.

## Test Structure

```
test/
├── unit/                    # Unit tests for business logic
│   ├── services/           # Service class tests
│   ├── providers/          # State management tests
│   ├── models/            # Data model tests
│   └── utils/             # Utility function tests
├── widget/                  # Widget tests for UI components
│   ├── components/        # Reusable component tests
│   ├── pages/            # Page widget tests
│   └── layouts/          # Layout widget tests
├── integration/            # Integration tests for user flows
│   ├── flows/            # Complete user journey tests
│   ├── features/         # Feature-specific integration tests
│   └── e2e/             # End-to-end scenario tests
└── test_utils/            # Shared test utilities
    ├── mocks/            # Mock services and data
    ├── fixtures/         # Test data fixtures
    └── helpers/          # Test helper functions
```

## Running Tests

### Basic Commands

```bash
# Run all tests
./run_test.sh

# Run specific test types
./run_test.sh unit
./run_test.sh widget
./run_test.sh integration

# Run tests with coverage
./run_test.sh coverage

# Run specific test files
./run_test.sh specific auth
./run_test.sh specific token_balance

# Run tests in parallel
./run_test.sh unit --parallel
./run_test.sh --parallel --concurrency 8

# Check test quality
./run_test.sh quality
```

### Advanced Options

```bash
# Set custom coverage threshold
./run_test.sh coverage --threshold 90

# Run without generating reports
./run_test.sh --no-report

# Run in watch mode
./run_test.sh watch

# Run benchmarks
./run_test.sh benchmark
```

## Writing Tests

### Unit Tests

Unit tests focus on testing individual functions, classes, and services in isolation.

```dart
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fortune/services/auth_service.dart';
import '../test_utils/mocks/mock_services.dart';

void main() {
  late AuthService authService;
  late MockSupabaseClient mockClient;
  
  setUp(() {
    mockClient = MockSupabaseClient();
    authService = AuthService(mockClient);
  });
  
  group('AuthService', () {
    test('should authenticate user successfully', () async {
      // Arrange
      when(() => mockClient.auth.signIn(...))
          .thenAnswer((_) async => authResponse);
      
      // Act
      final result = await authService.signIn('email', 'password');
      
      // Assert
      expect(result.user, isNotNull);
      verify(() => mockClient.auth.signIn(...)).called(1);
    });
  });
}
```

### Widget Tests

Widget tests verify the UI behavior and appearance of individual widgets.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/presentation/widgets/fortune_card.dart';
import '../test_utils/helpers/test_helpers.dart';

void main() {
  testWidgets('FortuneCard displays content correctly', 
    (WidgetTester tester) async {
    // Arrange & Act
    await TestHelpers.pumpTestWidget(
      tester,
      FortuneCard(
        title: 'Daily Fortune',
        description: 'Check your fortune',
        onTap: () {},
      ),
    );
    
    // Assert
    expect(find.text('Daily Fortune'), findsOneWidget);
    expect(find.text('Check your fortune'), findsOneWidget);
  });
}
```

### Integration Tests

Integration tests verify complete user flows and feature interactions.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune_flutter/main.dart' as app;
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('User can generate daily fortune', 
    (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Login
    await TestHelpers.performLogin(tester);
    
    // Navigate and generate fortune
    await TestHelpers.navigateToTab(tester, Icons.auto_awesome);
    await tester.tap(find.text('Daily Fortune'));
    await tester.pumpAndSettle();
    
    // Verify result
    expect(find.textContaining('Your fortune'), findsOneWidget);
  });
}
```

## Test Utilities

### Mock Factory

Use `MockFactory` to create consistent test data:

```dart
final user = MockFactory.createUserProfile(
  name: 'Test User',
  email: 'test@example.com',
  tokenBalance: 100,
);

final fortune = MockFactory.createFortune(
  type: 'daily',
  content: 'Today is your lucky day!',
);
```

### Test Helpers

Common test operations are available in `TestHelpers`:

```dart
// Pump widget with providers
await TestHelpers.pumpTestWidget(tester, widget);

// Create authenticated state
final overrides = TestHelpers.createAuthenticatedState();

// Wait for async operations
await TestHelpers.waitForAsync(tester);

// Verify navigation
TestHelpers.verifyNavigation<HomePage>(tester);
```

### Test Keys

Use predefined test keys for consistent widget identification:

```dart
// In your widget
ElevatedButton(
  key: TestKeys.loginButton,
  onPressed: () {},
  child: Text('Login'),
)

// In your test
await tester.tap(find.byKey(TestKeys.loginButton));
```

## Coverage Requirements

- **Overall**: 85% minimum
- **Unit tests**: 90% target
- **Widget tests**: 80% target
- **Critical paths**: 100% required

Check coverage with:

```bash
./run_test.sh coverage
open coverage/html/index.html
```

## CI/CD Integration

Tests run automatically on:
- Every pull request
- Pushes to main/develop branches
- Nightly builds

The CI pipeline:
1. Runs all tests in parallel
2. Generates coverage reports
3. Creates test result artifacts
4. Comments on PRs with results
5. Updates coverage badges

## Best Practices

1. **Write tests first** - Follow TDD when possible
2. **Keep tests focused** - One test, one assertion
3. **Use descriptive names** - Test names should explain what they verify
4. **Mock external dependencies** - Don't make real API calls
5. **Test edge cases** - Include error scenarios and boundary conditions
6. **Maintain test data** - Use factories and fixtures for consistency
7. **Run tests frequently** - Before committing and pushing changes
8. **Keep tests fast** - Mock heavy operations, use test doubles
9. **Review test quality** - Ensure adequate assertions and coverage
10. **Update tests with code** - Keep tests in sync with implementation

## Troubleshooting

### Common Issues

**Tests timing out**
- Increase timeout in test configuration
- Check for missing `pumpAndSettle()` calls
- Verify async operations complete

**Flaky tests**
- Add proper waiting for animations
- Use `TestHelpers.waitForAsync()`
- Mock time-dependent operations

**Coverage not updating**
- Delete coverage folder and regenerate
- Check test file naming (must end with `_test.dart`)
- Verify tests are actually running

### Debug Tips

```dart
// Print widget tree
debugDumpApp();

// Take screenshot during test
await tester.takeScreenshot('test-screenshot');

// Slow down animations
timeDilation = 5.0;

// Print finder results
print(find.byType(Widget).evaluate());
```

## Contributing

When adding new tests:

1. Follow the existing structure
2. Add tests for all new features
3. Maintain or improve coverage
4. Update this documentation
5. Ensure CI passes before merging

For questions or improvements, please open an issue or pull request.