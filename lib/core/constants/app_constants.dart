class AppConstants {
  // App Information
  static const String appName = 'my morrow';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.fortune.app';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Feature Flags
  static const bool enableAds = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Ad Configuration
  static const int adFrequency = 3; // Show ad every 3 fortune readings
  static const Duration adCooldown = Duration(minutes: 5);

  // Fortune Types
  static const List<String> fortuneTypes = [
    'daily',
    'tarot',
    'zodiac',
    'face_reading',
    'palm_reading',
    'dream',
    'name',
    'compatibility'];

  // Limits
  static const int maxDailyFortunes = 10;
  static const int maxHistoryItems = 50;
  static const int maxFavorites = 100;
}
