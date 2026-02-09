// 인기 꿈 주제 60가지
//
// 사람들이 가장 많이 검색하고 궁금해하는 꿈 주제들
// 각 주제는 이모지와 한글 제목으로 구성
class PopularDreamTopics {
  PopularDreamTopics._();

  /// 전체 꿈 주제 목록 (60개)
  static const List<DreamTopic> all = [
    // 🐍 동물 관련 (12개)
    DreamTopic(id: 'snake', emoji: '🐍', title: '뱀 꿈', category: '동물'),
    DreamTopic(id: 'pig', emoji: '🐷', title: '돼지 꿈', category: '동물'),
    DreamTopic(id: 'dog', emoji: '🐕', title: '강아지 꿈', category: '동물'),
    DreamTopic(id: 'cat', emoji: '🐱', title: '고양이 꿈', category: '동물'),
    DreamTopic(id: 'tiger', emoji: '🐅', title: '호랑이 꿈', category: '동물'),
    DreamTopic(id: 'dragon', emoji: '🐉', title: '용 꿈', category: '동물'),
    DreamTopic(id: 'fish', emoji: '🐟', title: '물고기 꿈', category: '동물'),
    DreamTopic(id: 'bird', emoji: '🐦', title: '새 꿈', category: '동물'),
    DreamTopic(id: 'horse', emoji: '🐴', title: '말 꿈', category: '동물'),
    DreamTopic(id: 'cow', emoji: '🐄', title: '소 꿈', category: '동물'),
    DreamTopic(id: 'spider', emoji: '🕷️', title: '거미 꿈', category: '동물'),
    DreamTopic(id: 'elephant', emoji: '🐘', title: '코끼리 꿈', category: '동물'),

    // 💰 재물/행운 관련 (10개)
    DreamTopic(id: 'money', emoji: '💰', title: '돈 줍는 꿈', category: '재물'),
    DreamTopic(id: 'lottery', emoji: '🎰', title: '복권 당첨 꿈', category: '재물'),
    DreamTopic(id: 'gold', emoji: '🥇', title: '금 꿈', category: '재물'),
    DreamTopic(id: 'treasure', emoji: '💎', title: '보물 발견 꿈', category: '재물'),
    DreamTopic(id: 'poop', emoji: '💩', title: '똥 꿈', category: '재물'),
    DreamTopic(id: 'wallet', emoji: '👛', title: '지갑 꿈', category: '재물'),
    DreamTopic(id: 'gift', emoji: '🎁', title: '선물 받는 꿈', category: '재물'),
    DreamTopic(id: 'coin', emoji: '🪙', title: '동전 꿈', category: '재물'),
    DreamTopic(id: 'rice', emoji: '🍚', title: '쌀/곡식 꿈', category: '재물'),
    DreamTopic(id: 'fruit', emoji: '🍎', title: '과일 꿈', category: '재물'),

    // ✈️ 행동/상황 관련 (12개)
    DreamTopic(id: 'flying', emoji: '✈️', title: '하늘 나는 꿈', category: '행동'),
    DreamTopic(id: 'falling', emoji: '🌀', title: '떨어지는 꿈', category: '행동'),
    DreamTopic(id: 'chased', emoji: '🏃', title: '쫓기는 꿈', category: '행동'),
    DreamTopic(id: 'teeth', emoji: '🦷', title: '이빨 빠지는 꿈', category: '행동'),
    DreamTopic(id: 'naked', emoji: '😳', title: '알몸인 꿈', category: '행동'),
    DreamTopic(id: 'late', emoji: '⏰', title: '지각하는 꿈', category: '행동'),
    DreamTopic(id: 'lost', emoji: '🗺️', title: '길 잃는 꿈', category: '행동'),
    DreamTopic(id: 'swimming', emoji: '🏊', title: '수영하는 꿈', category: '행동'),
    DreamTopic(id: 'driving', emoji: '🚗', title: '운전하는 꿈', category: '행동'),
    DreamTopic(id: 'climbing', emoji: '🧗', title: '산 오르는 꿈', category: '행동'),
    DreamTopic(id: 'exam', emoji: '📝', title: '시험 보는 꿈', category: '행동'),
    DreamTopic(id: 'fighting', emoji: '🥊', title: '싸우는 꿈', category: '행동'),

    // 👨‍👩‍👧 사람 관련 (10개)
    DreamTopic(id: 'dead_person', emoji: '👻', title: '돌아가신 분 꿈', category: '사람'),
    DreamTopic(id: 'baby', emoji: '👶', title: '아기 꿈', category: '사람'),
    DreamTopic(id: 'ex', emoji: '💔', title: '전 애인 꿈', category: '사람'),
    DreamTopic(id: 'celebrity', emoji: '⭐', title: '연예인 꿈', category: '사람'),
    DreamTopic(id: 'stranger', emoji: '🧑', title: '모르는 사람 꿈', category: '사람'),
    DreamTopic(id: 'wedding', emoji: '💒', title: '결혼하는 꿈', category: '사람'),
    DreamTopic(id: 'pregnant', emoji: '🤰', title: '임신 꿈', category: '사람'),
    DreamTopic(id: 'parent', emoji: '👨‍👩‍👧', title: '부모님 꿈', category: '사람'),
    DreamTopic(id: 'friend', emoji: '🤝', title: '친구 꿈', category: '사람'),
    DreamTopic(id: 'enemy', emoji: '😠', title: '싫어하는 사람 꿈', category: '사람'),

    // 🌊 자연/환경 관련 (8개)
    DreamTopic(id: 'water', emoji: '🌊', title: '물/바다 꿈', category: '자연'),
    DreamTopic(id: 'fire', emoji: '🔥', title: '불 꿈', category: '자연'),
    DreamTopic(id: 'rain', emoji: '🌧️', title: '비 오는 꿈', category: '자연'),
    DreamTopic(id: 'snow', emoji: '❄️', title: '눈 오는 꿈', category: '자연'),
    DreamTopic(id: 'flower', emoji: '🌸', title: '꽃 꿈', category: '자연'),
    DreamTopic(id: 'mountain', emoji: '⛰️', title: '산 꿈', category: '자연'),
    DreamTopic(id: 'sun', emoji: '☀️', title: '해/태양 꿈', category: '자연'),
    DreamTopic(id: 'moon', emoji: '🌙', title: '달 꿈', category: '자연'),

    // 🏠 장소/물건 관련 (8개)
    DreamTopic(id: 'house', emoji: '🏠', title: '집 꿈', category: '장소'),
    DreamTopic(id: 'school', emoji: '🏫', title: '학교 꿈', category: '장소'),
    DreamTopic(id: 'elevator', emoji: '🛗', title: '엘리베이터 꿈', category: '장소'),
    DreamTopic(id: 'toilet', emoji: '🚽', title: '화장실 꿈', category: '장소'),
    DreamTopic(id: 'car', emoji: '🚙', title: '자동차 꿈', category: '장소'),
    DreamTopic(id: 'airplane', emoji: '✈️', title: '비행기 꿈', category: '장소'),
    DreamTopic(id: 'hospital', emoji: '🏥', title: '병원 꿈', category: '장소'),
    DreamTopic(id: 'mirror', emoji: '🪞', title: '거울 꿈', category: '장소'),
  ];

  /// 랜덤으로 n개의 꿈 주제 선택
  static List<DreamTopic> getRandomTopics(int count) {
    final shuffled = List<DreamTopic>.from(all)..shuffle();
    return shuffled.take(count).toList();
  }

  /// 카테고리별 꿈 주제 가져오기
  static List<DreamTopic> getByCategory(String category) {
    return all.where((topic) => topic.category == category).toList();
  }

  /// ID로 꿈 주제 찾기
  static DreamTopic? findById(String id) {
    try {
      return all.firstWhere((topic) => topic.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 꿈 주제 모델
class DreamTopic {
  final String id;
  final String emoji;
  final String title;
  final String category;

  /// 직접 입력한 커스텀 꿈 내용 (선택적)
  final String? customContent;

  const DreamTopic({
    required this.id,
    required this.emoji,
    required this.title,
    required this.category,
    this.customContent,
  });

  /// 커스텀 입력용 생성자
  factory DreamTopic.custom(String content) {
    return DreamTopic(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      emoji: '✨',
      title: '직접 입력한 꿈',
      category: '기타',
      customContent: content,
    );
  }

  /// 이모지와 제목을 합친 전체 텍스트
  String get fullTitle => '$emoji $title';

  /// API에 전달할 꿈 내용 텍스트
  String get dreamContentForApi => customContent ?? '$title을 꾸었습니다.';

  /// 커스텀 입력인지 여부
  bool get isCustom => customContent != null;
}
