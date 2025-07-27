# Flutter Project Cleanup Plan

## Files to Remove

### 1. Test/Demo Files in Root
- `test_payment_api.dart` - Testing script, should be in test directory
- `test_date_picker.dart` - Testing script, should be in test directory

### 2. Old/Deprecated Files
- `lib/features/fortune/presentation/pages/biorhythm_fortune_page_old.dart` - Old version with '_old' suffix
- `lib/features/fortune/presentation/pages/fortune_screenshot_example.dart` - Example file
- `lib/presentation/screens/fortune_detail_example.dart` - Example file
- `lib/presentation/screens/fortune_explanation_example.dart` - Example file
- `lib/presentation/widgets/fortune_explanation_example.dart` - Example file

### 3. Demo/Test Pages in Production Code
- `lib/screens/demo/soul_animation_demo_page.dart` - Demo page
- `lib/screens/demo/fortune_snap_scroll_demo.dart` - Demo page
- `lib/features/misc/presentation/pages/test_ads_page.dart` - Test page

### 4. Build Artifacts and Logs
- `flutter_01.log`
- `flutter_02.log`
- `flutter_run.log`
- `build/` directory (auto-generated)

### 5. Duplicate/Redundant Files
- Check for duplicate fortune page implementations (unified vs enhanced vs regular)
- Multiple error handling classes in different locations

## Code Cleanup Tasks

### 1. Remove Unused Imports
- Scan all Dart files for unused imports
- Common unused imports: `dart:io`, `dart:convert`, `package:http`

### 2. Remove Dead Code
- Commented out code blocks
- Unused variables and methods
- Unreachable code

### 3. Consolidate Duplicate Code
- Multiple fortune page base classes
- Duplicate API service implementations
- Similar widget implementations

### 4. File Organization
- Move test files to proper test directories
- Organize fortune pages by type
- Consolidate utility functions

## Recommended Actions

1. **Backup First**: Create a backup before cleanup
2. **Run Tests**: Ensure all tests pass before and after cleanup
3. **Version Control**: Commit changes incrementally
4. **Documentation**: Update docs to reflect removed files

## Safety Considerations

- Keep configuration files (.env.example, etc.)
- Preserve migration files
- Don't remove files referenced in pubspec.yaml
- Check for import dependencies before removing files
