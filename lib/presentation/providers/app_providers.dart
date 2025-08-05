import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'font_size_provider.dart';

/// Initialize app-wide provider overrides
/// This must be called before runApp
Future<List<Override>> initializeProviders() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  return [
    // Override the sharedPreferencesProvider with actual instance
    sharedPreferencesProvider.overrideWithValue(sharedPreferences)];
}