import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fortune/core/cache/cache_service.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/presentation/providers/providers.dart';
import 'package:fortune/presentation/providers/auth_provider.dart';
import 'package:fortune/presentation/providers/fortune_provider.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final offlineModeProvider = StateNotifierProvider<OfflineModeNotifier, OfflineModeState>((ref) {
  return OfflineModeNotifier(ref);
});

class OfflineModeState {
  final bool isOffline;
  final bool isInitialized;
  final Map<String, dynamic> cacheStats;
  final List<String> pendingSyncItems;

  OfflineModeState({
    this.isOffline = false,
    this.isInitialized = false,
    this.cacheStats = const {},
    this.pendingSyncItems = const [],
  });

  OfflineModeState copyWith({
    bool? isOffline,
    bool? isInitialized,
    Map<String, dynamic>? cacheStats,
    List<String>? pendingSyncItems,
  }) {
    return OfflineModeState(
      isOffline: isOffline ?? this.isOffline,
      isInitialized: isInitialized ?? this.isInitialized,
      cacheStats: cacheStats ?? this.cacheStats,
      pendingSyncItems: pendingSyncItems ?? this.pendingSyncItems,
    );
  }
}

class OfflineModeNotifier extends StateNotifier<OfflineModeState> {
  final Ref ref;
  final CacheService _cacheService = CacheService();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  OfflineModeNotifier(this.ref) : super(OfflineModeState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize cache service
      await _cacheService.initialize();
      
      // Get initial cache stats
      final stats = await _cacheService.getOfflineStats();
      
      // Listen to connectivity changes
      _connectivitySubscription = ref.read(connectivityProvider.stream).listen((results) {
        final hasConnection = results.any((result) => 
          result != ConnectivityResult.none && 
          result != ConnectivityResult.bluetooth
        );
        
        if (hasConnection && state.isOffline) {
          // Coming back online - trigger sync
          _onConnectionRestored();
        } else if (!hasConnection && !state.isOffline) {
          // Going offline
          _onConnectionLost();
        }
        
        state = state.copyWith(isOffline: !hasConnection);
      });
      
      // Check initial connectivity
      final initialResults = await Connectivity().checkConnectivity();
      final hasInitialConnection = initialResults.any((result) => 
        result != ConnectivityResult.none && 
        result != ConnectivityResult.bluetooth
      );
      
      state = state.copyWith(
        isOffline: !hasInitialConnection,
        isInitialized: true,
        cacheStats: stats,
      );
      
      await _cacheService.setOfflineMode(!hasInitialConnection);
      
    } catch (e) {
      Logger.error('Failed to initialize offline mode', error: e);
    }
  }

  Future<void> refreshCacheStats() async {
    try {
      final stats = await _cacheService.getOfflineStats();
      state = state.copyWith(cacheStats: stats);
    } catch (e) {
      Logger.error('Failed to refresh cache stats', error: e);
    }
  }

  void _onConnectionLost() {
    Logger.info('Connection lost - entering offline mode');
    _cacheService.setOfflineMode(true);
    // Show notification to user about offline mode
  }

  Future<void> _onConnectionRestored() async {
    Logger.info('Connection restored - syncing pending data');
    await _cacheService.setOfflineMode(false);
    
    // Sync any pending data
    if (state.pendingSyncItems.isNotEmpty) {
      await _syncPendingData();
    }
  }

  Future<void> _syncPendingData() async {
    if (state.pendingSyncItems.isEmpty) return;
    
    try {
      Logger.info('Starting sync of ${state.pendingSyncItems.length} pending items');
      
      final cacheService = ref.read(cacheServiceProvider);
      final fortuneService = ref.read(fortuneServiceProvider);
      final user = ref.read(userProvider).value;
      
      if (user == null) {
        Logger.warning('Cannot sync: user not logged in');
        return;
      }
      
      final syncedItems = <String>[];
      
      for (final itemId in state.pendingSyncItems) {
        try {
          // Get cached fortune
          final cachedFortune = await cacheService.getCachedFortuneById(itemId);
          
          if (cachedFortune != null) {
            // Sync to server
            await fortuneService.syncOfflineFortune(
              userId: user.id,
              fortune: cachedFortune,
            );
            
            syncedItems.add(itemId);
            Logger.info('Synced fortune: $itemId');
          }
        } catch (e) {
          Logger.error('Failed to sync item $itemId', error: e);
          // Continue with other items even if one fails
        }
      }
      
      // Remove successfully synced items from pending list
      final remainingItems = state.pendingSyncItems
          .where((id) => !syncedItems.contains(id),
          .toList();
      
      Logger.info('Synced ${syncedItems.length} of ${state.pendingSyncItems.length} pending items');
      state = state.copyWith(pendingSyncItems: remainingItems);
      
    } catch (e) {
      Logger.error('Failed to sync pending data', error: e);
    }
  }

  void addPendingSyncItem(String itemId) {
    final updatedItems = [...state.pendingSyncItems, itemId];
    state = state.copyWith(pendingSyncItems: updatedItems);
  }

  Future<void> clearCache({String? userId}) async {
    try {
      await _cacheService.clearFortuneCache(userId: userId);
      await refreshCacheStats();
    } catch (e) {
      Logger.error('Failed to clear cache', error: e);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}