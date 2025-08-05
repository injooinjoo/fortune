import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/tarot_deck_metadata.dart';

// 현재 선택된 타로 덱 ID를 관리하는 Provider
final selectedTarotDeckProvider = StateNotifierProvider<SelectedTarotDeckNotifier, String>((ref) {
  return SelectedTarotDeckNotifier();
});

class SelectedTarotDeckNotifier extends StateNotifier<String> {
  static const String _prefsKey = 'selected_tarot_deck';
  
  SelectedTarotDeckNotifier() : super(TarotDeckMetadata.defaultDeckId) {
    _loadSelectedDeck();
  }

  // SharedPreferences에서 저장된 덱 ID를 로드
  Future<void> _loadSelectedDeck() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeckId = prefs.getString(_prefsKey);
    
    if (savedDeckId != null && TarotDeckMetadata.availableDecks.containsKey(savedDeckId)) {
      state = savedDeckId;
    }
  }

  // 새로운 덱 선택
  Future<void> selectDeck(String deckId) async {
    if (TarotDeckMetadata.availableDecks.containsKey(deckId)) {
      state = deckId;
      
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, deckId);
    }
  }

  // 기본 덱으로 리셋
  Future<void> resetToDefault() async {
    state = TarotDeckMetadata.defaultDeckId;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

// 현재 선택된 덱의 전체 정보를 제공하는 Provider
final currentTarotDeckProvider = Provider<TarotDeck>((ref) {
  final deckId = ref.watch(selectedTarotDeckProvider);
  return TarotDeckMetadata.getDeck(deckId);
});

// 사용자의 타로 경험 레벨을 관리하는 Provider
final tarotExperienceLevelProvider = StateNotifierProvider<TarotExperienceLevelNotifier, TarotDifficulty>((ref) {
  return TarotExperienceLevelNotifier();
});

class TarotExperienceLevelNotifier extends StateNotifier<TarotDifficulty> {
  static const String _prefsKey = 'tarot_experience_level';
  
  TarotExperienceLevelNotifier() : super(TarotDifficulty.beginner) {
    _loadExperienceLevel();
  }

  Future<void> _loadExperienceLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getString(_prefsKey);
    
    if (savedLevel != null) {
      try {
        state = TarotDifficulty.values.firstWhere(
          (level) => level.toString() == savedLevel);
      } catch (_) {
        // 잘못된 값이 저장되어 있으면 기본값 유지
      }
    }
  }

  Future<void> setExperienceLevel(TarotDifficulty level) async {
    state = level;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, level.toString());
  }
}

// 사용자가 선호하는 타로 스타일을 관리하는 Provider
final preferredTarotStyleProvider = StateNotifierProvider<PreferredTarotStyleNotifier, TarotStyle?>((ref) {
  return PreferredTarotStyleNotifier();
});

class PreferredTarotStyleNotifier extends StateNotifier<TarotStyle?> {
  static const String _prefsKey = 'preferred_tarot_style';
  
  PreferredTarotStyleNotifier() : super(null) {
    _loadPreferredStyle();
  }

  Future<void> _loadPreferredStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStyle = prefs.getString(_prefsKey);
    
    if (savedStyle != null) {
      try {
        state = TarotStyle.values.firstWhere(
          (style) => style.toString() == savedStyle);
      } catch (_) {
        // 잘못된 값이 저장되어 있으면 null 유지
      }
    }
  }

  Future<void> setPreferredStyle(TarotStyle? style) async {
    state = style;
    
    final prefs = await SharedPreferences.getInstance();
    if (style != null) {
      await prefs.setString(_prefsKey, style.toString());
    } else {
      await prefs.remove(_prefsKey);
    }
  }
}

// 추천 덱 목록을 제공하는 Provider
final recommendedDecksProvider = Provider<List<TarotDeck>>((ref) {
  final experienceLevel = ref.watch(tarotExperienceLevelProvider);
  final preferredStyle = ref.watch(preferredTarotStyleProvider);
  
  final allDecks = TarotDeckMetadata.getAllDecks();
  
  // 필터링 로직
  return allDecks.where((deck) {
    // 경험 레벨에 맞는 덱인지 확인
    bool matchesLevel = false;
    switch (experienceLevel) {
      case TarotDifficulty.beginner:
        matchesLevel = deck.difficulty == TarotDifficulty.beginner ||
                       deck.difficulty == TarotDifficulty.intermediate;
        break;
      case TarotDifficulty.intermediate:
        matchesLevel = deck.difficulty != TarotDifficulty.expert;
        break;
      case TarotDifficulty.advanced:
      case TarotDifficulty.expert:
      case TarotDifficulty.unique:
        matchesLevel = true; // 모든 덱 사용 가능
        break;
    }
    
    // 선호 스타일이 있으면 해당 스타일 우선
    if (preferredStyle != null && deck.style == preferredStyle) {
      return true;
    }
    
    return matchesLevel;
  }).toList()
    ..sort((a, b) {
      // 선호 스타일 우선 정렬
      if (preferredStyle != null) {
        if (a.style == preferredStyle && b.style != preferredStyle) return -1;
        if (a.style != preferredStyle && b.style == preferredStyle) return 1;
      }
      // 난이도 순 정렬
      return a.difficulty.index.compareTo(b.difficulty.index);
    });
});

// 타로 덱 사용 통계를 관리하는 Provider
final tarotDeckStatsProvider = StateNotifierProvider<TarotDeckStatsNotifier, Map<String, int>>((ref) {
  return TarotDeckStatsNotifier();
});

class TarotDeckStatsNotifier extends StateNotifier<Map<String, int>> {
  static const String _prefsKey = 'tarot_deck_usage_stats';
  
  TarotDeckStatsNotifier() : super({}) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_prefsKey);
    
    if (statsJson != null) {
      try {
        final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          Uri.splitQueryString(statsJson));
        state = decoded.map((key, value) => MapEntry(key, int.parse(value.toString())));
      } catch (_) {
        state = {};
      }
    }
  }

  Future<void> incrementUsage(String deckId) async {
    state = {
      ...state,
      deckId: (state[deckId] ?? 0) + 1};
    
    final prefs = await SharedPreferences.getInstance();
    final statsString = state.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    await prefs.setString(_prefsKey, statsString);
  }
  
  // 가장 많이 사용한 덱 ID 반환
  String? getMostUsedDeck() {
    if (state.isEmpty) return null;
    
    return state.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}