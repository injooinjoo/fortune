import '../../domain/models/character_chat_message.dart';

/// Follow-up 시점에 이미지 첨부 맥락을 판정한 결과
class CharacterProactiveContextDecision {
  final CharacterMediaCategory category;
  final String contextText;
  final String timeSlot;
  final String? styleHint;

  const CharacterProactiveContextDecision({
    required this.category,
    required this.contextText,
    required this.timeSlot,
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

  static const List<String> _cafeKeywords = [
    '카페',
    '커피',
    '디저트',
    '브런치',
    'tea',
    'coffee',
    'cafe',
    'latte',
    'dessert',
    '티타임',
  ];

  static const List<String> _commuteKeywords = [
    '출근',
    '퇴근',
    '통근',
    '지하철',
    '버스',
    '회사 가',
    '집 가',
    '이동 중',
    'commute',
    'subway',
    'bus',
    'train',
    'office',
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

  static const List<String> _nightKeywords = [
    '밤',
    '야경',
    '늦었',
    '잠',
    '새벽',
    '잠이 안',
    'night',
    'late',
    'midnight',
    'insomnia',
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

    final timeSlot = _resolveTimeSlot(referenceTime);
    final mealScore = _scoreByKeywords(recentUserTexts, _mealKeywords);
    final cafeScore = _scoreByKeywords(recentUserTexts, _cafeKeywords);
    final commuteScore = _scoreByKeywords(recentUserTexts, _commuteKeywords);
    final workoutScore = _scoreByKeywords(recentUserTexts, _workoutKeywords);
    final nightScore = _scoreByKeywords(recentUserTexts, _nightKeywords);

    final selectedCategory = _selectCategory(
      timeSlot: timeSlot,
      mealScore: mealScore,
      cafeScore: cafeScore,
      commuteScore: commuteScore,
      workoutScore: workoutScore,
      nightScore: nightScore,
    );

    final keywords = _keywordsFor(selectedCategory);
    final matchedContext = _selectContextText(recentUserTexts, keywords);

    return CharacterProactiveContextDecision(
      category: selectedCategory,
      contextText: matchedContext,
      timeSlot: timeSlot,
      styleHint: _defaultStyleHint(
        selectedCategory,
        timeSlot: timeSlot,
      ),
    );
  }

  CharacterMediaCategory _selectCategory({
    required String timeSlot,
    required int mealScore,
    required int cafeScore,
    required int commuteScore,
    required int workoutScore,
    required int nightScore,
  }) {
    if (mealScore > 0 && _isMealTimeSlot(timeSlot)) {
      return CharacterMediaCategory.meal;
    }
    if (workoutScore > 0 && _isWorkoutTimeSlot(timeSlot)) {
      return CharacterMediaCategory.workout;
    }
    if (commuteScore > 0 && _isCommuteTimeSlot(timeSlot)) {
      return CharacterMediaCategory.commute;
    }
    if (cafeScore > 0 && !_isLateNightTimeSlot(timeSlot)) {
      return CharacterMediaCategory.cafe;
    }
    if (nightScore > 0 || _isLateNightTimeSlot(timeSlot)) {
      return CharacterMediaCategory.night;
    }
    if (_isCommuteTimeSlot(timeSlot)) {
      return CharacterMediaCategory.commute;
    }
    if (timeSlot == 'afternoon') {
      return CharacterMediaCategory.cafe;
    }
    if (_isMealTimeSlot(timeSlot)) {
      return CharacterMediaCategory.meal;
    }
    return CharacterMediaCategory.selfie;
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
    if (keywords.isEmpty) {
      return recentTexts.first;
    }

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

  List<String> _keywordsFor(CharacterMediaCategory category) {
    switch (category) {
      case CharacterMediaCategory.meal:
        return _mealKeywords;
      case CharacterMediaCategory.cafe:
        return _cafeKeywords;
      case CharacterMediaCategory.commute:
        return _commuteKeywords;
      case CharacterMediaCategory.workout:
        return _workoutKeywords;
      case CharacterMediaCategory.night:
        return _nightKeywords;
      case CharacterMediaCategory.selfie:
        return const <String>[];
    }
  }

  String _resolveTimeSlot(DateTime now) {
    final hour = now.hour;

    if (hour >= 6 && hour < 10) {
      return 'morning';
    }
    if (hour >= 11 && hour < 14) {
      return 'lunch';
    }
    if (hour >= 14 && hour < 17) {
      return 'afternoon';
    }
    if (hour >= 17 && hour < 21) {
      return 'evening';
    }
    if (hour >= 21 || hour < 2) {
      return 'night';
    }
    return 'late_night';
  }

  bool _isMealTimeSlot(String timeSlot) =>
      timeSlot == 'lunch' || timeSlot == 'evening';

  bool _isWorkoutTimeSlot(String timeSlot) =>
      timeSlot == 'morning' || timeSlot == 'evening';

  bool _isCommuteTimeSlot(String timeSlot) =>
      timeSlot == 'morning' || timeSlot == 'evening';

  bool _isLateNightTimeSlot(String timeSlot) =>
      timeSlot == 'night' || timeSlot == 'late_night';

  String _defaultStyleHint(
    CharacterMediaCategory category, {
    required String timeSlot,
  }) {
    switch (category) {
      case CharacterMediaCategory.selfie:
        return timeSlot == 'night' || timeSlot == 'late_night'
            ? 'natural phone selfie at home, cozy late-night mood, candid daily life'
            : 'natural phone selfie, candid daily life, realistic lighting';
      case CharacterMediaCategory.meal:
        return 'natural phone photo of today\'s meal, cozy candid mood';
      case CharacterMediaCategory.cafe:
        return 'natural phone photo in a quiet cafe, coffee or dessert on the table, candid daily life';
      case CharacterMediaCategory.commute:
        return 'natural smartphone snapshot while commuting, city transit vibe, candid everyday scene';
      case CharacterMediaCategory.workout:
        return 'post-workout phone selfie, candid gym vibe, natural lighting';
      case CharacterMediaCategory.night:
        return 'natural phone photo of a calm night outing or city lights, candid everyday mood';
    }
  }
}
