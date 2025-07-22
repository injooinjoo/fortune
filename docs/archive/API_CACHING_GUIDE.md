# API Response Caching Guide

This guide explains the API response caching system implemented in the Fortune app.

## Overview

The caching system provides:
- Automatic HTTP response caching
- Configurable cache durations per endpoint
- Offline support with stale cache fallback
- Cache statistics and management
- Persistent storage using Hive

## Architecture

### Components

1. **CacheInterceptor**: Dio interceptor that handles caching logic
2. **CacheEntry**: Model for cached responses
3. **CacheConfig**: Configuration for different endpoints
4. **CacheManagementService**: Service for cache administration

### How It Works

1. **Request Interception**: 
   - Checks if request should be cached
   - Generates unique cache key
   - Returns cached data if available and valid

2. **Response Caching**:
   - Stores successful responses
   - Respects configured cache durations
   - Handles headers and status codes

3. **Error Handling**:
   - Returns stale cache on network errors
   - Configurable per endpoint

## Cache Configuration

### Default Configurations

```dart
// Fortune endpoints
'/fortune/daily': 24 hours
'/fortune/tomorrow': 12 hours
'/fortune/weekly': 7 days
'/fortune/monthly': 30 days
'/fortune/yearly': 365 days
'/fortune/saju': 365 days (permanent fortunes)
'/fortune/*': 1 hour (default)

// User data
'/user/profile': 5 minutes
'/user/token-balance': 1 minute

// Static data
'/config/*': 1 day
'/static/*': 7 days
```

### Custom Configuration

To add custom cache configuration:

```dart
_cacheConfigs[RegExp(r'/custom/endpoint')] = CacheConfig(
  duration: Duration(hours: 6),
  cacheOnError: true,
  validStatusCodes: [200, 201],
);
```

## Usage

### Basic Usage

The cache interceptor is automatically added to the API client:

```dart
_dio.addCacheInterceptor();
```

### Bypass Cache

To make a request without caching:

```dart
// Option 1: Using extension method
final response = await apiClient.dio.getNoCache('/endpoint');

// Option 2: Using extra parameter
final response = await apiClient.get(
  '/endpoint',
  options: Options(extra: {'noCache': true}),
);
```

### Cache Management

```dart
final cacheService = CacheManagementService.instance;

// Clear all cache
await cacheService.clearAllCache();

// Clear fortune cache only
await cacheService.clearFortuneCache();

// Clear user cache only
await cacheService.clearUserCache();

// Get cache statistics
final stats = await cacheService.getCacheStatistics();
print('Total cache size: ${stats.totalSizeMB} MB');

// Clear expired entries
await cacheService.clearExpiredCache();
```

## Cache Key Generation

Cache keys are generated using SHA256 hash of:
- Request URI
- Request headers
- Request body (for POST requests)

This ensures unique keys for different requests.

## Offline Support

When network requests fail, the cache interceptor:
1. Checks for cached data (even if expired)
2. Returns stale data if available
3. Marks response with `stale: true` flag

Example handling:
```dart
try {
  final response = await apiClient.get('/fortune/daily');
  if (response.extra?['stale'] == true) {
    // Show offline indicator
    showSnackBar('Showing cached data - offline mode');
  }
} catch (e) {
  // Handle complete failure
}
```

## Performance Benefits

1. **Reduced API Calls**: Up to 90% reduction for frequently accessed data
2. **Faster Load Times**: Instant response for cached data
3. **Bandwidth Savings**: Significant data usage reduction
4. **Offline Capability**: App remains functional without internet

## Best Practices

### 1. Cache Duration
- Short-lived data: 1-5 minutes
- User data: 5-30 minutes
- Daily fortunes: 24 hours
- Static fortunes: 1 year

### 2. Cache Invalidation
```dart
// After user action that changes data
await cacheService.clearUserCache();

// After fortune generation
await apiClient.dio.delete(cacheKey);
```

### 3. Memory Management
```dart
// Set cache size limit (50 MB)
await cacheService.setCacheSizeLimit(50);

// Periodic cleanup
Timer.periodic(Duration(hours: 24), (_) {
  cacheService.clearExpiredCache();
});
```

### 4. Error Handling
Always check for stale data:
```dart
if (response.extra?['cached'] == true) {
  final isStale = response.extra?['stale'] == true;
  if (isStale) {
    // Notify user about offline mode
  }
}
```

## Cache Statistics

Monitor cache usage:

```dart
final stats = await cacheService.getCacheStatistics();
debugPrint('''
Cache Statistics:
- API Cache: ${stats.apiCacheEntries} entries (${stats.apiCacheSizeMB} MB)
- Hive Cache: ${stats.hiveCacheEntries} entries (${stats.hiveCacheSizeMB} MB)
- Total: ${stats.totalEntries} entries (${stats.totalSizeMB} MB)
''');
```

## Troubleshooting

### Cache Not Working
1. Check if interceptor is added
2. Verify endpoint matches cache config
3. Ensure GET method is used
4. Check cache statistics

### Cache Too Large
1. Reduce cache durations
2. Implement size limits
3. Clear cache periodically
4. Use selective caching

### Stale Data Issues
1. Implement proper cache invalidation
2. Use shorter durations for dynamic data
3. Add refresh mechanisms
4. Show stale data indicators

## Future Improvements

1. **Smart Prefetching**: Preload likely-needed data
2. **Compression**: Compress cached data
3. **Partial Updates**: Cache only changed fields
4. **Background Sync**: Update cache in background
5. **Analytics**: Track cache hit/miss rates