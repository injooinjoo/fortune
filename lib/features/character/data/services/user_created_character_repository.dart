import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user_created_character.dart';

class UserCreatedCharacterRepository {
  static const String _storageKey = 'user_created_characters_v1';

  Future<List<UserCreatedCharacter>> loadCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(UserCreatedCharacter.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      await prefs.remove(_storageKey);
      return const [];
    }
  }

  Future<void> saveCharacters(List<UserCreatedCharacter> characters) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      characters.map((character) => character.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
