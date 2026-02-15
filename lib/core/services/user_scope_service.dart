import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// 사용자 스코프 식별자 관리 서비스
///
/// - 로그인: `user:<uid>`
/// - 비로그인: `guest:<persistent_device_uuid>`
class UserScopeService {
  UserScopeService._internal();

  static final UserScopeService _instance = UserScopeService._internal();
  factory UserScopeService() => _instance;

  static UserScopeService get instance => _instance;

  static const String _deviceIdKey = 'user_scope_device_id';
  static const String _lastKnownUserIdKey = 'user_scope_last_known_user_id';
  static const Uuid _uuid = Uuid();

  String? _cachedOwnerId;
  String? get cachedOwnerId => _cachedOwnerId;

  Future<void> initialize() async {
    await _ensureDeviceId();
    await refreshCurrentScope();
  }

  Future<void> refreshCurrentScope() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _cachedOwnerId = ownerIdForUser(user.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastKnownUserIdKey, user.id);
      return;
    }

    _cachedOwnerId = ownerIdForGuest(await _getDeviceId());
  }

  Future<String> getCurrentOwnerId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final ownerId = ownerIdForUser(user.id);
      if (_cachedOwnerId != ownerId) {
        _cachedOwnerId = ownerId;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastKnownUserIdKey, user.id);
      }
      return ownerId;
    }

    final ownerId = ownerIdForGuest(await _getDeviceId());
    _cachedOwnerId = ownerId;
    return ownerId;
  }

  Future<String> getGuestOwnerId() async {
    return ownerIdForGuest(await _getDeviceId());
  }

  static String ownerIdForUser(String userId) => 'user:$userId';
  static String ownerIdForGuest(String deviceId) => 'guest:$deviceId';

  Future<String?> getLastKnownUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastKnownUserIdKey);
  }

  Future<void> setLastKnownUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null || userId.isEmpty) {
      await prefs.remove(_lastKnownUserIdKey);
      return;
    }
    await prefs.setString(_lastKnownUserIdKey, userId);
  }

  Future<void> _ensureDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_deviceIdKey) != null) return;
    await prefs.setString(_deviceIdKey, _uuid.v4());
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final created = _uuid.v4();
    await prefs.setString(_deviceIdKey, created);
    return created;
  }
}
