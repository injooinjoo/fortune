import 'dart:async';

/// In-memory cache for user profiles to reduce repeated database queries
class ProfileCache {
  static final ProfileCache _instance = ProfileCache._internal();
  factory ProfileCache() => _instance;
  ProfileCache._internal();
  
  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  final Map<String, _CachedProfile> _cache = {};
  
  /// Get cached profile
  Map<String, dynamic>? get(String userId) {
    final cached = _cache[userId];
    if (cached == null) return null;
    
    // Check if cache is still valid
    if (DateTime.now().difference(cached.timestamp) > _cacheDuration) {
      _cache.remove(userId);
      return null;
    }
    
    return cached.data;
  }
  
  /// Set profile in cache
  void set(String userId, Map<String, dynamic> profile) {
    _cache[userId] = _CachedProfile(
      data: Map.from(profile),
      timestamp: DateTime.now(),
    );
  }
  
  /// Clear specific user's cache
  void clear(String userId) {
    _cache.remove(userId);
  }
  
  /// Clear all cache
  void clearAll() {
    _cache.clear();
  }
  
  /// Update specific fields in cached profile
  void updateFields(String userId, Map<String, dynamic> updates) {
    final existing = get(userId);
    if (existing != null) {
      existing.addAll(updates);
      set(userId, existing);
    }
  }
}

class _CachedProfile {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  _CachedProfile({required this.data, required this.timestamp});
}