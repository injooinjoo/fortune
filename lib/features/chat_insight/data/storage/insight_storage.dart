import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_insight_result.dart';

/// 대화 분석 인사이트 로컬 저장소
/// SharedPreferences에 JSON으로 저장 (원문 미포함, 결과만)
class InsightStorage {
  static const _storageKey = 'chat_insight_results';
  static const _privacyKey = 'chat_insight_privacy';
  static const _maxSessions = 50;

  /// 분석 결과 저장
  static Future<void> save(ChatInsightResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();
    existing.insert(0, result);

    // 최대 세션 수 제한
    if (existing.length > _maxSessions) {
      existing.removeRange(_maxSessions, existing.length);
    }

    final jsonList = existing.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// 모든 분석 결과 로드
  static Future<List<ChatInsightResult>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final jsonList = jsonDecode(raw) as List<dynamic>;
      return jsonList
          .map((e) => ChatInsightResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// ID로 단일 결과 로드
  static Future<ChatInsightResult?> loadById(String id) async {
    final all = await loadAll();
    try {
      return all.firstWhere((r) => r.analysisMeta.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 개별 세션 삭제
  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();
    existing.removeWhere((r) => r.analysisMeta.id == id);

    final jsonList = existing.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// 전체 삭제
  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// 프라이버시 설정 저장
  static Future<void> savePrivacyConfig(PrivacyConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privacyKey, jsonEncode(config.toJson()));
  }

  /// 프라이버시 설정 로드
  static Future<PrivacyConfig> loadPrivacyConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_privacyKey);
    if (raw == null || raw.isEmpty) return const PrivacyConfig();

    try {
      return PrivacyConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PrivacyConfig();
    }
  }

  /// 저장된 세션 수
  static Future<int> count() async {
    final all = await loadAll();
    return all.length;
  }
}
