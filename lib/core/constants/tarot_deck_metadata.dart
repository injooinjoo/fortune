import 'package:flutter/material.dart';

class TarotDeckMetadata {
  // 사용 가능한 타로 덱 목록
  static const Map<String, TarotDeck> availableDecks = {
    'rider_waite': TarotDeck(
      id: 'rider_waite',
      code: 'RWSa',
      name: 'Rider-Waite-Smith',
      koreanName: '라이더-웨이트-스미스',
      description: '가장 인기 있고 널리 사용되는 타로 덱으로, 1909년 Arthur Edward Waite와 Pamela Colman Smith가 만들었습니다.',
      characteristics: [
        '직관적이고 상징적인 이미지',
        '초보자에게 적합한 명확한 상징',
        '모든 카드에 그림이 있어 해석이 용이',
        '전통적인 타로 의미를 따름',
      ],
      primaryColor: Color(0xFF4A5568),
      secondaryColor: Color(0xFFECC94B),
      artist: 'Pamela Colman Smith',
      year: 1909,
      style: TarotStyle.traditional,
      difficulty: TarotDifficulty.beginner,
      recommendedFor: ['일반적인 질문', '사랑과 관계', '일상적인 조언', '초보자'],
      previewCards: ['00_fool', '01_magician', '17_star'],
      isAvailable: true,
    ),
    'thoth': TarotDeck(
      id: 'thoth',
      code: 'Thot',
      name: 'Aleister Crowley Thoth',
      koreanName: '토트 타로',
      description: 'Aleister Crowley가 디자인하고 Lady Frieda Harris가 그린 신비주의적이고 복잡한 타로 덱입니다.',
      characteristics: [
        '깊은 상징과 신비주의적 요소',
        '카발라와 점성술 통합',
        '추상적이고 복잡한 이미지',
        '고급 사용자를 위한 깊이 있는 해석',
      ],
      primaryColor: Color(0xFF553C9A),
      secondaryColor: Color(0xFFD69E2E),
      artist: 'Lady Frieda Harris',
      year: 1969,
      style: TarotStyle.esoteric,
      difficulty: TarotDifficulty.advanced,
      recommendedFor: ['영적 탐구', '심층 분석', '명상과 성찰', '숙련자'],
      previewCards: ['00_fool', '03_empress', '20_judgement'],
      isAvailable: true,
    ),
    'ancient_italian': TarotDeck(
      id: 'ancient_italian',
      code: 'AncI',
      name: 'Ancient Italian Tarot',
      koreanName: '고대 이탈리아 타로',
      description: '19세기 이탈리아 전통 타로를 재현한 클래식한 덱으로, 역사적 가치가 높습니다.',
      characteristics: [
        '전통적인 이탈리아 스타일',
        '역사적 디자인과 상징',
        '클래식한 색상과 패턴',
        '유럽 타로의 원형',
      ],
      primaryColor: Color(0xFF975A16),
      secondaryColor: Color(0xFFDC2626),
      artist: 'Cartiera Italiana',
      year: 1880,
      style: TarotStyle.classic,
      difficulty: TarotDifficulty.intermediate,
      recommendedFor: ['전통적 해석', '역사적 관심', '클래식 리딩'],
      previewCards: ['00_fool', '13_death', '21_world'],
      isAvailable: true,
    ),
    'before_tarot': TarotDeck(
      id: 'before_tarot',
      code: 'BefT',
      name: 'Before Tarot',
      koreanName: '비포 타로',
      description: 'Rider-Waite-Smith의 장면들이 일어나기 직전의 순간을 그린 창의적인 덱입니다.',
      characteristics: [
        '시간적 내러티브 강조',
        '원인과 결과 탐구',
        '스토리텔링에 적합',
        '독특한 관점 제공',
      ],
      primaryColor: Color(0xFF065F46),
      secondaryColor: Color(0xFF7C2D12),
      artist: 'Eon Rossi & Simona Rossi',
      year: 2018,
      style: TarotStyle.narrative,
      difficulty: TarotDifficulty.intermediate,
      recommendedFor: ['과거 탐구', '원인 분석', '스토리텔링', '창의적 해석'],
      previewCards: ['00_fool', '06_lovers', '16_tower'],
      isAvailable: true,
    ),
    'after_tarot': TarotDeck(
      id: 'after_tarot',
      code: 'AftT',
      name: 'After Tarot',
      koreanName: '애프터 타로',
      description: 'Rider-Waite-Smith의 장면들이 일어난 직후의 순간을 그린 혁신적인 덱입니다.',
      characteristics: [
        '결과와 영향 탐구',
        '시간의 흐름 표현',
        '깊이 있는 내러티브',
        '확장된 의미 해석',
      ],
      primaryColor: Color(0xFF1E3A8A),
      secondaryColor: Color(0xFFF59E0B),
      artist: 'Giulia F. Massaglia',
      year: 2016,
      style: TarotStyle.narrative,
      difficulty: TarotDifficulty.intermediate,
      recommendedFor: ['미래 예측', '결과 분석', '행동의 영향', '심층 리딩'],
      previewCards: ['00_fool', '10_wheel_of_fortune', '19_sun'],
      isAvailable: true,
    ),
    'golden_dawn_cicero': TarotDeck(
      id: 'golden_dawn_cicero',
      code: 'Cice',
      name: 'Golden Dawn Magical Tarot',
      koreanName: '골든 던 매지컬 타로 (시세로)',
      description: 'Hermetic Order of the Golden Dawn의 전통을 따르는 정통 신비주의 타로 덱입니다.',
      characteristics: [
        '황금새벽회 전통',
        '카발라와 연금술 상징',
        '플래싱 컬러 사용',
        '의식 마법에 적합',
      ],
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFF0891B2),
      artist: 'Chic & Sandra Cicero',
      year: 1995,
      style: TarotStyle.ceremonial,
      difficulty: TarotDifficulty.advanced,
      recommendedFor: ['의식 작업', '카발라 연구', '신비주의 탐구', '전문가'],
      previewCards: ['00_fool', '04_emperor', '14_temperance'],
      isAvailable: true,
    ),
    'golden_dawn_wang': TarotDeck(
      id: 'golden_dawn_wang',
      code: 'GDaw',
      name: 'The Golden Dawn Tarot',
      koreanName: '골든 던 타로 (왕)',
      description: 'Israel Regardie의 감독 하에 제작된 Golden Dawn의 비밀 구전 전통을 담은 타로입니다.',
      characteristics: [
        '비밀 구전 전통',
        '순수한 상징 체계',
        '교육적 목적',
        '역사적 중요성',
      ],
      primaryColor: Color(0xFFB91C1C),
      secondaryColor: Color(0xFF059669),
      artist: 'Robert Wang',
      year: 1978,
      style: TarotStyle.ceremonial,
      difficulty: TarotDifficulty.expert,
      recommendedFor: ['학술 연구', '전통 보존', '깊은 명상', '전문가'],
      previewCards: ['00_fool', '11_justice', '21_world'],
      isAvailable: true,
    ),
    'grand_etteilla': TarotDeck(
      id: 'grand_etteilla',
      code: 'GrEt',
      name: 'Grand Etteilla',
      koreanName: '그랑 에테이야',
      description: '최초로 점술 목적으로 디자인된 역사적인 타로 덱으로, 1785년 Jean-Baptiste Alliette가 만들었습니다.',
      characteristics: [
        '최초의 점술 전용 타로',
        '카드에 의미가 직접 쓰여 있음',
        '정방향/역방향 의미 표시',
        '창조의 6일을 묘사',
      ],
      primaryColor: Color(0xFF92400E),
      secondaryColor: Color(0xFF4C1D95),
      artist: 'Jean-Baptiste Alliette (Etteilla)',
      year: 1785,
      style: TarotStyle.divinatory,
      difficulty: TarotDifficulty.unique,
      recommendedFor: ['역사적 관심', '전통 점술', '수집가', '연구자'],
      previewCards: ['00_fool', '01_magician', '17_star'],
      isAvailable: true,
    ),
  };

  // 기본 덱
  static const String defaultDeckId = 'rider_waite';

  // 덱 선택을 위한 헬퍼 메서드
  static TarotDeck getDeck(String deckId) {
    return availableDecks[deckId] ?? availableDecks[defaultDeckId]!;
  }

  static List<TarotDeck> getAllDecks() {
    return availableDecks.values.toList();
  }

  static List<TarotDeck> getDecksForLevel(TarotDifficulty difficulty) {
    return availableDecks.values
        .where((deck) => deck.difficulty == difficulty)
        .toList();
  }

  static List<TarotDeck> getDecksForStyle(TarotStyle style) {
    return availableDecks.values
        .where((deck) => deck.style == style)
        .toList();
  }
}

// 타로 덱 정보 클래스
class TarotDeck {
  final String id;
  final String code;
  final String name;
  final String koreanName;
  final String description;
  final List<String> characteristics;
  final Color primaryColor;
  final Color secondaryColor;
  final String artist;
  final int year;
  final TarotStyle style;
  final TarotDifficulty difficulty;
  final List<String> recommendedFor;
  final List<String> previewCards;
  final bool isAvailable;

  const TarotDeck({
    required this.id,
    required this.code,
    required this.name,
    required this.koreanName,
    required this.description,
    required this.characteristics,
    required this.primaryColor,
    required this.secondaryColor,
    required this.artist,
    required this.year,
    required this.style,
    required this.difficulty,
    required this.recommendedFor,
    required this.previewCards,
    required this.isAvailable,
  });

  String getCardImagePath(String cardFileName) {
    return 'assets/images/tarot/decks/$id/$cardFileName';
  }

  String getCardBackImagePath() {
    return 'assets/images/tarot/backs/${id}_back.jpg';
  }
}

// 타로 스타일 열거형
enum TarotStyle {
  traditional('전통적', '클래식한 상징과 의미'),
  esoteric('신비주의', '깊은 영적 상징'),
  classic('고전', '역사적 전통'),
  narrative('내러티브', '스토리텔링 중심'),
  ceremonial('의식용', '마법과 의식'),
  divinatory('점술용', '예언과 점술');
  
  final String label;
  final String description;
  
  const TarotStyle(this.label, this.description);
}

// 타로 난이도 열거형
enum TarotDifficulty {
  beginner('초급', '초보자에게 적합'),
  intermediate('중급', '어느 정도 경험 필요'),
  advanced('고급', '깊은 이해 필요'),
  expert('전문가', '전문 지식 필요'),
  unique('독특함', '특별한 접근 필요');
  
  final String label;
  final String description;
  
  const TarotDifficulty(this.label, this.description);
}

// 확장 메서드
extension TarotStyleExtension on TarotStyle {
  String get displayName {
    switch (this) {
      case TarotStyle.traditional:
        return '전통적';
      case TarotStyle.esoteric:
        return '신비주의';
      case TarotStyle.classic:
        return '고전';
      case TarotStyle.narrative:
        return '내러티브';
      case TarotStyle.ceremonial:
        return '의식용';
      case TarotStyle.divinatory:
        return '점술용';
    }
  }

  String get description {
    switch (this) {
      case TarotStyle.traditional:
        return '클래식한 상징과 의미';
      case TarotStyle.esoteric:
        return '깊은 영적 상징';
      case TarotStyle.classic:
        return '역사적 전통';
      case TarotStyle.narrative:
        return '스토리텔링 중심';
      case TarotStyle.ceremonial:
        return '마법과 의식';
      case TarotStyle.divinatory:
        return '예언과 점술';
    }
  }
}

extension TarotDifficultyExtension on TarotDifficulty {
  String get displayName {
    switch (this) {
      case TarotDifficulty.beginner:
        return '초급';
      case TarotDifficulty.intermediate:
        return '중급';
      case TarotDifficulty.advanced:
        return '고급';
      case TarotDifficulty.expert:
        return '전문가';
      case TarotDifficulty.unique:
        return '독특함';
    }
  }

  String get description {
    switch (this) {
      case TarotDifficulty.beginner:
        return '초보자에게 적합';
      case TarotDifficulty.intermediate:
        return '어느 정도 경험 필요';
      case TarotDifficulty.advanced:
        return '깊은 이해 필요';
      case TarotDifficulty.expert:
        return '전문 지식 필요';
      case TarotDifficulty.unique:
        return '특별한 접근 필요';
    }
  }

  Color get color {
    switch (this) {
      case TarotDifficulty.beginner:
        return Colors.green;
      case TarotDifficulty.intermediate:
        return Colors.orange;
      case TarotDifficulty.advanced:
        return Colors.red;
      case TarotDifficulty.expert:
        return Colors.purple;
      case TarotDifficulty.unique:
        return Colors.indigo;
    }
  }
}