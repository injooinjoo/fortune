# Flutter Integration Tests

This directory contains integration tests for the Fortune Flutter application.

## Test Structure

- `auth_flow_test.dart` - Authentication flow tests (login, signup, social auth, logout)
- `fortune_generation_test.dart` - Fortune generation and viewing tests
- `payment_flow_test.dart` - Token purchase and payment flow tests
- `profile_management_test.dart` - Profile management and settings tests
- `helpers/` - Reusable test utilities
  - `test_helpers.dart` - Common helper functions
  - `page_objects.dart` - Page Object pattern implementations

## Running Tests

### Run all integration tests:
```bash
./run_test.sh integration
```

### Run specific test file:
```bash
./run_test.sh integration auth_flow_test.dart
./run_test.sh integration fortune_generation_test.dart
```

### Run on specific device:
```bash
# Web (Chrome)
flutter test integration_test/ -d chrome

# iOS Simulator
flutter test integration_test/ -d iPhone

# Android Emulator
flutter test integration_test/ -d emulator
```

## Prerequisites

1. Ensure you have a device/emulator running or Chrome installed for web tests
2. The app should be properly configured with test environment settings
3. Test user accounts should be available in the test environment

## Writing New Integration Tests

1. Create a new test file in the `integration_test/` directory
2. Import necessary dependencies:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fortune/main.dart' as app;
```

3. Use the helper functions and page objects for better maintainability:
```dart
import 'helpers/test_helpers.dart';
import 'helpers/page_objects.dart';
```

4. Structure your tests with descriptive group and test names
5. Follow the existing patterns for consistency

## Best Practices

1. **Use Page Objects**: Encapsulate page-specific logic in page objects
2. **Reuse Helpers**: Use common helper functions to avoid duplication
3. **Wait for Animations**: Always use `pumpAndSettle()` after actions
4. **Handle Async Operations**: Use appropriate timeouts for network requests
5. **Clean Test Data**: Ensure tests don't interfere with each other
6. **Descriptive Names**: Use clear, descriptive test and group names

## Debugging Failed Tests

1. **Screenshots**: Take screenshots at failure points for debugging
2. **Verbose Output**: Run with `-v` flag for detailed output
3. **Single Test**: Isolate failing tests by running them individually
4. **Check Prerequisites**: Ensure test environment is properly set up

## CI/CD Integration

For CI/CD pipelines, use:
```bash
./run_test.sh ci
```

This will run all tests with coverage and generate machine-readable reports.
