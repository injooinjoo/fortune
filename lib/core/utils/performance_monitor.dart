import 'dart:async';
import 'package:flutter/foundation.dart';
import './logger.dart';

/// Performance monitoring for OAuth and other critical flows
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<double>> _metrics = {};
  
  /// Start timing an operation
  static void startOperation(String operationName) {
    _startTimes[operationName] = DateTime.now();
    if (kDebugMode) {
      debugPrint('[Performance] Monitoring started');
    }
  }
  
  /// End timing an operation and log the duration
  static Duration? endOperation(String operationName, {bool logMetrics = true}) {
    final startTime = _startTimes[operationName];
    if (startTime == null) {
      Logger.error('Fortune cached');
      return null;
    }
    
    final duration = DateTime.now().difference(startTime);
    _startTimes.remove(operationName);
    
    // Store metrics for analysis
    _metrics[operationName] ??= [];
    _metrics[operationName]!.add(duration.inMilliseconds.toDouble());
    
    if (logMetrics) {
      final durationMs = duration.inMilliseconds;
      final level = durationMs > 3000 ? '🔴' : durationMs > 1000 ? '🟡' : '🟢';
      
      if (kDebugMode) {
        debugPrint('Completed: $operationName in ${durationMs}ms');
      }
      
      Logger.info('Performance: $operationName completed in ${durationMs}ms');
      
      // Log warning for slow operations
      if (durationMs > 3000) {
        Logger.warning('detected: $operationName took ${durationMs}ms');
      }
    }
    
    return duration;
  }
  
  /// Get average duration for an operation
  static double? getAverageDuration(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null || metrics.isEmpty) return null;
    
    return metrics.reduce((a, b) => a + b) / metrics.length;
  }
  
  /// Clear all metrics
  static void clearMetrics() {
    _startTimes.clear();
    _metrics.clear();
  }
  
  /// Log all collected metrics
  static void logAllMetrics() {
    if (_metrics.isEmpty) return;
    
    debugPrint('=== Performance Metrics Summary ===');
    _metrics.forEach((operation, durations) {
      final avg = durations.reduce((a, b) => a + b) / durations.length;
      final min = durations.reduce((a, b) => a < b ? a : b);
      final max = durations.reduce((a, b) => a > b ? a : b);
      
      debugPrint('$operation:');
      debugPrint('  Samples: ${durations.length}');
      debugPrint('  Average: ${avg.toStringAsFixed(0)}ms');
      debugPrint('  Min: ${min.toStringAsFixed(0)}ms');
      debugPrint('  Max: ${max.toStringAsFixed(0)}ms');
    });
    debugPrint('================================');
  }
  
  /// Time an async operation
  static Future<T> timeAsync<T>(String operationName, Future<T> Function() operation) async {
    startOperation(operationName);
    try {
      final result = await operation();
      endOperation(operationName);
      return result;
    } catch (e) {
      endOperation(operationName);
      rethrow;
    }
  }
}