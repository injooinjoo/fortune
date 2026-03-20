import 'package:flutter/foundation.dart';

import '../core/cache/cache_service.dart';
import '../core/utils/logger.dart';
import '../features/character/data/services/character_affinity_service.dart';
import '../features/character/data/services/character_chat_local_service.dart';
import 'social_auth_service.dart';
import 'storage_service.dart';

class SessionCleanupService {
  final Future<void> Function() _signOut;
  final Future<void> Function() _clearUserProfile;
  final Future<void> Function() _clearActiveProfileOverride;
  final Future<void> Function() _clearGuestMode;
  final Future<void> Function() _clearGuestId;
  final Future<dynamic> Function() _clearAllCache;
  final Future<dynamic> Function() _clearAllConversations;
  final Future<dynamic> Function() _clearAllAffinities;

  SessionCleanupService({
    required SocialAuthService socialAuthService,
    required StorageService storageService,
    CharacterChatLocalService? characterChatLocalService,
    CharacterAffinityService? characterAffinityService,
    CacheService? cacheService,
  })  : _signOut = socialAuthService.signOut,
        _clearUserProfile = storageService.clearUserProfile,
        _clearActiveProfileOverride = storageService.clearActiveProfileOverride,
        _clearGuestMode = storageService.clearGuestMode,
        _clearGuestId = storageService.clearGuestId,
        _clearAllCache = (cacheService ?? CacheService()).clearAllCache,
        _clearAllConversations =
            (characterChatLocalService ?? CharacterChatLocalService())
                .clearAllConversations,
        _clearAllAffinities =
            (characterAffinityService ?? CharacterAffinityService())
                .clearAllAffinities;

  @visibleForTesting
  SessionCleanupService.test({
    required Future<void> Function() signOut,
    required Future<void> Function() clearUserProfile,
    required Future<void> Function() clearActiveProfileOverride,
    required Future<void> Function() clearGuestMode,
    required Future<void> Function() clearGuestId,
    required Future<void> Function() clearAllCache,
    required Future<void> Function() clearAllConversations,
    required Future<void> Function() clearAllAffinities,
  })  : _signOut = signOut,
        _clearUserProfile = clearUserProfile,
        _clearActiveProfileOverride = clearActiveProfileOverride,
        _clearGuestMode = clearGuestMode,
        _clearGuestId = clearGuestId,
        _clearAllCache = clearAllCache,
        _clearAllConversations = clearAllConversations,
        _clearAllAffinities = clearAllAffinities;

  Future<void> signOutAndClearSession() async {
    Object? signOutError;
    StackTrace? signOutStackTrace;

    try {
      await _signOut();
    } catch (error, stackTrace) {
      signOutError = error;
      signOutStackTrace = stackTrace;
      Logger.error(
        '[SessionCleanupService] Sign out failed, continuing cleanup',
        error,
        stackTrace,
      );
    }

    await _runCleanupStep('clear user profile', _clearUserProfile);
    await _runCleanupStep(
        'clear active profile override', _clearActiveProfileOverride);
    await _runCleanupStep('clear guest mode', _clearGuestMode);
    await _runCleanupStep('clear guest id', _clearGuestId);
    await _runCleanupStep('clear cache', _clearAllCache);
    await _runCleanupStep(
        'clear character conversations', _clearAllConversations);
    await _runCleanupStep('clear character affinities', _clearAllAffinities);

    if (signOutError != null) {
      Error.throwWithStackTrace(signOutError, signOutStackTrace!);
    }
  }

  Future<void> _runCleanupStep(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      Logger.warning('[SessionCleanupService] Failed to $label', error);
      if (kDebugMode) {
        Logger.error(
            '[SessionCleanupService] $label stack trace', error, stackTrace);
      }
    }
  }
}
