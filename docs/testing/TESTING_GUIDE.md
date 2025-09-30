# Fortune Flutter Testing Guide

## Overview

This guide covers the testing strategy and implementation for the Fortune Flutter application. Our goal is to maintain a minimum of 80% code coverage while ensuring robust and reliable functionality.

## Test Structure

```
test/
├── unit_test/
│   ├── cache_service_test.dart
│   └── fortune_api_service_test.dart
├── widget_test/
│   └── fortune_card_test.dart
└── integration_test/
    └── app_test.dart
```

## Running Tests

### All Tests
```bash
./run_test.sh
```

### Specific Test Types
```bash
# Unit tests only
./run_test.sh unit

# Widget tests only
./run_test.sh widget

# Integration tests
./run_test.sh integration

# Tests with coverage report
./run_test.sh coverage

# Watch mode (auto-run on file changes)
./run_test.sh watch

# CI mode (for GitHub Actions)
./run_test.sh ci
```

## Test Types

### 1. Unit Tests

Unit tests focus on testing individual classes and functions in isolation.

**Location**: `test/unit_test/`

**Coverage**: 
- Services (API, Cache, Auth)
- Models and entities
- Utilities and helpers
- State management logic

**Example**:
```dart
test('should cache fortune successfully', () async {
  // Arrange
  final fortune = FortuneModel(...);
  when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
  
  // Act
  await cacheService.cacheFortune('daily', params, fortune);
  
  // Assert
  verify(() => mockBox.put(any(), fortune)).called(1);
});
```

### 2. Widget Tests

Widget tests verify the UI components render correctly and handle user interactions.

**Location**: `test/widget_test/`

**Coverage**:
- Individual widgets
- Widget interactions
- Widget state changes
- Accessibility

**Example**:
```dart
testWidgets('should display all required elements', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FortuneCard(
        icon: Icons.star,
        title: 'Daily Fortune',
        description: 'Check your fortune',
        onTap: () {},
      ),
    ),
  );
  
  expect(find.text('Daily Fortune'), findsOneWidget);
  expect(find.byIcon(Icons.star), findsOneWidget);
});
```

### 3. Integration Tests

Integration tests verify complete user flows and app functionality.

**Location**: `test/integration_test/`

**Coverage**:
- Complete user journeys
- Navigation flows
- API integration
- State persistence

**Example**:
```dart
testWidgets('complete fortune generation flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // Login
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  
  // Navigate to fortune
  await tester.tap(find.text('Daily Fortune'));
  await tester.pumpAndSettle();
  
  // Verify fortune displayed
  expect(find.textContaining('Your fortune'), findsOneWidget);
});
```

## Mocking Strategy

We use `mocktail` for creating mocks:

```dart
// Create mock
class MockApiClient extends Mock implements ApiClient {}

// Set up mock behavior
when(() => mockApiClient.get(any())).thenAnswer(
  (_) async => Response(data: testData),
);

// Verify interactions
verify(() => mockApiClient.get('/api/fortune')).called(1);
```

## Coverage Requirements

- **Minimum Coverage**: 80%
- **Target Coverage**: 90%
- **Critical Paths**: 95%

### Viewing Coverage Reports

1. Run tests with coverage:
   ```bash
   ./run_test.sh coverage
   ```

2. Open HTML report:
   ```bash
   open coverage/html/index.html
   ```

## Best Practices

### 1. Test Naming
```dart
test('should [expected behavior] when [condition]', () {
  // Test implementation
});
```

### 2. Test Organization
- Group related tests using `group()`
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

### 3. Mock Data
Create reusable test data:
```dart
final testUser = User(
  id: 'test-123',
  email: 'test@example.com',
  name: 'Test User',
);
```

### 4. Async Testing
Always use `async/await`:
```dart
test('async operation', () async {
  final result = await service.fetchData();
  expect(result, isNotNull);
});
```

### 5. Widget Testing Tips
- Use `pumpAndSettle()` for animations
- Test accessibility with semantics
- Verify gesture handling
- Check error states

## CI/CD Integration

Tests run automatically on:
- Every push to main/develop branches
- All pull requests
- Manual workflow dispatch

GitHub Actions workflow includes:
1. Code analysis
2. Unit & widget tests
3. Integration tests (iOS/Android)
4. Coverage verification
5. Build verification

## Debugging Tests

### Run Single Test
```dart
flutter test test/unit_test/cache_service_test.dart
```

### Run with Debugging
```dart
flutter test --dart-define=DEBUG=true
```

### Verbose Output
```dart
flutter test -v
```

## Common Issues

### 1. Mock Setup
**Problem**: "type 'Null' is not a subtype of type 'Future<Response>'"
**Solution**: Ensure all mock methods return appropriate values

### 2. Widget Test Timeouts
**Problem**: Test times out waiting for animations
**Solution**: Use `tester.pumpAndSettle()` or increase timeout

### 3. Integration Test Failures
**Problem**: Tests fail on CI but pass locally
**Solution**: Check for environment differences, add explicit waits

## Adding New Tests

1. Create test file in appropriate directory
2. Import necessary packages and mocks
3. Write tests following existing patterns
4. Run locally to verify
5. Check coverage meets requirements
6. Submit PR with passing tests

## Test Checklist

Before submitting PR:
- [ ] All tests pass locally
- [ ] Coverage >= 80%
- [ ] New features have tests
- [ ] Bug fixes include regression tests
- [ ] Integration tests updated if needed
- [ ] No skipped or commented tests

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)
- [Coverage Tool](https://github.com/linux-test-project/lcov)