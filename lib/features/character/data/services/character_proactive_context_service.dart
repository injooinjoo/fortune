import '../../domain/models/character_chat_message.dart';

/// Follow-up 시점에 이미지 첨부 맥락을 판정한 결과
class CharacterProactiveContextDecision {
  final CharacterMediaCategory category;
  final String contextText;
  final String? styleHint;

  const CharacterProactiveContextDecision({
    required this.category,
    required this.contextText,
    this.styleHint,
  });
}

/// 최근 사용자 발화 + 현재 시간대로 proactive 이미지 카테고리를 판정
class CharacterProactiveContextService {
  static const int _maxRecentUserMessages = 6;

  static const List<String> _mealKeywords = [
    '밥',
    '식사',
    '점심',
    '저녁',
    '아침',
    '먹',
    '도시락',
    '배고',
    'meal',
    'lunch',
    'dinner',
    'breakfast',
    'eat',
    'food',
    '弁当',
    'ご飯',
    '食事',
  ];

  static const List<String> _workoutKeywords = [
    '운동',
    '헬스',
    '런닝',
    '러닝',
    '조깅',
    '근력',
    '유산소',
    'pt',
    '짐',
    'exercise',
    'workout',
    'run',
    'running',
    'gym',
    'training',
    'ワークアウト',
    '運動',
    'ジム',
  ];

  CharacterProactiveContextDecision? resolve({
    required List<CharacterChatMessage> messages,
    DateTime? now,
  }) {
    final referenceTime = now ?? DateTime.now();
    final recentUserTexts = messages
        .where((message) => message.type == CharacterChatMessageType.user)
        .map((message) => message.text.trim())
        .where((text) => text.isNotEmpty)
        .toList()
        .reversed
        .take(_maxRecentUserMessages)
        .toList();

    if (recentUserTexts.isEmpty) {
      return null;
    }

    final mealScore = _scoreByKeywords(recentUserTexts, _mealKeywords);
    final workoutScore = _scoreByKeywords(recentUserTexts, _workoutKeywords);

    final isMealMatch = mealScore > 0 && _isMealTime(referenceTime);
    final isWorkoutMatch = workoutScore > 0 && _isWorkoutTime(referenceTime);

    if (!isMealMatch && !isWorkoutMatch) {
      return null;
    }

    final selectedCategory = _selectCategory(
      isMealMatch: isMealMatch,
      isWorkoutMatch: isWorkoutMatch,
      mealScore: mealScore,
      workoutScore: workoutScore,
    );

    final keywords = selectedCategory == CharacterMediaCategory.meal
        ? _mealKeywords
        : _workoutKeywords;
    final matchedContext = _selectContextText(recentUserTexts, keywords);

    return CharacterProactiveContextDecision(
      category: selectedCategory,
      contextText: matchedContext,
      styleHint: _defaultStyleHint(selectedCategory),
    );
  }

  CharacterMediaCategory _selectCategory({
    required bool isMealMatch,
    required bool isWorkoutMatch,
    required int mealScore,
    required int workoutScore,
  }) {
    if (isMealMatch && !isWorkoutMatch) {
      return CharacterMediaCategory.meal;
    }
    if (!isMealMatch && isWorkoutMatch) {
      return CharacterMediaCategory.workout;
    }

    if (workoutScore > mealScore) {
      return CharacterMediaCategory.workout;
    }
    return CharacterMediaCategory.meal;
  }

  int _scoreByKeywords(List<String> texts, List<String> keywords) {
    var score = 0;
    for (final text in texts) {
      final lowered = text.toLowerCase();
      for (final keyword in keywords) {
        if (lowered.contains(keyword.toLowerCase())) {
          score += 1;
        }
      }
    }
    return score;
  }

  String _selectContextText(List<String> recentTexts, List<String> keywords) {
    for (final text in recentTexts) {
      final lowered = text.toLowerCase();
      final hasKeyword = keywords.any(
        (keyword) => lowered.contains(keyword.toLowerCase()),
      );
      if (hasKeyword) {
        return text;
      }
    }

    return recentTexts.first;
  }

  bool _isMealTime(DateTime now) {
    final hour = now.hour;
    final isLunch = hour >= 11 && hour < 15;
    final isDinner = hour >= 18 && hour < 21;
    return isLunch || isDinner;
  }

  bool _isWorkoutTime(DateTime now) {
    final hour = now.hour;
    final isMorningWorkout = hour >= 6 && hour < 10;
    final isEveningWorkout = hour >= 17 && hour < 23;
    return isMorningWorkout || isEveningWorkout;
  }

  String _defaultStyleHint(CharacterMediaCategory category) {
    if (category == CharacterMediaCategory.meal) {
      return 'natural phone photo of today\'s meal, cozy candid mood';
    }
    return 'post-workout phone selfie, candid gym vibe, natural lighting';
  }
}
