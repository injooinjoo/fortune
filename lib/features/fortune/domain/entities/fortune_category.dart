import 'package:flutter/material.dart';
import '../../../../core/constants/soul_rates.dart';

/// 운세 카테고리 엔티티
/// Remote Config에서 동적으로 로드 가능
class FortuneCategory {
  final String title;
  final String route;
  final String type; // Fortune type for image mapping
  final IconData icon;
  final String? iconAsset; // 커스텀 아이콘 에셋 경로 (한국 전통 수묵화 스타일)
  final List<Color> gradientColors;
  final String description;
  final String category;
  final bool isNew;
  final bool isPremium;
  final bool hasViewedToday; // 오늘 조회 여부

  const FortuneCategory({
    required this.title,
    required this.route,
    required this.type,
    required this.icon,
    this.iconAsset,
    required this.gradientColors,
    required this.description,
    required this.category,
    this.isNew = false,
    this.isPremium = false,
    this.hasViewedToday = false,
  });

  // 영혼 정보 가져오기
  int get soulAmount => SoulRates.getSoulAmount(type);
  bool get isFreeFortune => soulAmount > 0;
  bool get isPremiumFortune => soulAmount < 0;
  String get soulDescription => SoulRates.getActionDescription(type);
  int get soulCost => soulAmount.abs(); // Convert to positive cost value

  // 빨간 dot 표시 여부 (오늘 안 본 운세만 표시, 조회하면 제거)
  bool get shouldShowRedDot => !hasViewedToday;

  // copyWith 메서드 (hasViewedToday 업데이트용)
  FortuneCategory copyWith({
    String? title,
    String? route,
    String? type,
    IconData? icon,
    String? iconAsset,
    List<Color>? gradientColors,
    String? description,
    String? category,
    bool? isNew,
    bool? isPremium,
    bool? hasViewedToday,
  }) {
    return FortuneCategory(
      title: title ?? this.title,
      route: route ?? this.route,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconAsset: iconAsset ?? this.iconAsset,
      gradientColors: gradientColors ?? this.gradientColors,
      description: description ?? this.description,
      category: category ?? this.category,
      isNew: isNew ?? this.isNew,
      isPremium: isPremium ?? this.isPremium,
      hasViewedToday: hasViewedToday ?? this.hasViewedToday,
    );
  }

  /// JSON에서 FortuneCategory 생성
  factory FortuneCategory.fromJson(Map<String, dynamic> json) {
    // gradientColors 파싱 (hex string → Color)
    final List<Color> colors = (json['gradientColors'] as List<dynamic>?)
            ?.map((c) => _parseColor(c.toString()))
            .toList() ??
        [const Color(0xFF7C3AED), const Color(0xFF3B82F6)];

    // icon 파싱 (codePoint → IconData)
    final iconData = json['iconCodePoint'] != null
        ? IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons')
        : _getDefaultIcon(json['type'] as String? ?? '');

    return FortuneCategory(
      title: json['title'] as String? ?? '',
      route: json['route'] as String? ?? '',
      type: json['type'] as String? ?? '',
      icon: iconData,
      iconAsset: json['iconAsset'] as String?,
      gradientColors: colors,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  /// FortuneCategory를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'route': route,
      'type': type,
      'iconCodePoint': icon.codePoint,
      'iconAsset': iconAsset,
      'gradientColors': gradientColors.map((c) => '0x${c.toARGB32().toRadixString(16).toUpperCase()}').toList(),
      'description': description,
      'category': category,
      'isNew': isNew,
      'isPremium': isPremium,
    };
  }

  /// Hex 문자열을 Color로 파싱
  static Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      return Color(int.parse('0xFF$cleanHex'.substring(0, 10)));
    } catch (e) {
      return const Color(0xFF7C3AED); // 기본색
    }
  }

  /// 타입별 기본 아이콘
  static IconData _getDefaultIcon(String type) {
    const iconMap = {
      'daily_calendar': Icons.schedule_rounded,
      'traditional_saju': Icons.auto_awesome_rounded,
      'tarot': Icons.style_rounded,
      'dream': Icons.bedtime_rounded,
      'face-reading': Icons.face_rounded,
      'talisman': Icons.shield_rounded,
      'personality-dna': Icons.biotech_rounded,
      'mbti': Icons.psychology_rounded,
      'biorhythm': Icons.timeline_rounded,
      'love': Icons.favorite_rounded,
      'compatibility': Icons.people_rounded,
      'avoid-people': Icons.person_off_rounded,
      'ex_lover': Icons.heart_broken_rounded,
      'blind_date': Icons.waving_hand_rounded,
      'career': Icons.work_rounded,
      'exam': Icons.school_rounded,
      'investment': Icons.trending_up_rounded,
      'lucky_items': Icons.auto_awesome_rounded,
      'lucky-lottery': Icons.casino_rounded,
      'talent': Icons.stars_rounded,
      'wish': Icons.star_rounded,
      'health': Icons.favorite_rounded,
      'exercise': Icons.fitness_center_rounded,
      'sports_game': Icons.sports_rounded,
      'moving': Icons.home_work_rounded,
      'fortune-cookie': Icons.cookie_rounded,
      'celebrity': Icons.star_rounded,
      'pet': Icons.pets_rounded,
      'family': Icons.family_restroom_rounded,
    };
    return iconMap[type] ?? Icons.auto_awesome_rounded;
  }

  /// 기본 카테고리 목록 (오프라인 fallback용)
  static List<FortuneCategory> get defaults => _defaultCategories;
}

/// 기본 하드코딩된 카테고리 (Remote Config 실패 시 fallback)
const List<FortuneCategory> _defaultCategories = [
  // ==================== Time-based Fortunes (통합) ====================
  FortuneCategory(
    title: '달력',
    route: '/time',
    type: 'daily_calendar',
    icon: Icons.schedule_rounded,
    iconAsset: 'assets/icons/fortune/daily.png',
    gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
    description: '오늘/내일/주간/월간/연간 운세',
    category: 'lifestyle',
    isNew: true,
  ),

  // ==================== Traditional Fortunes (통합) ====================
  FortuneCategory(
    title: '전통',
    route: '/traditional',
    type: 'traditional_saju',
    icon: Icons.auto_awesome_rounded,
    iconAsset: 'assets/icons/fortune/traditional.png',
    gradientColors: [Color(0xFFEF4444), Color(0xFFEC4899)],
    description: '사주/토정비결',
    category: 'traditional',
  ),

  // ==================== Tarot Fortune ====================
  FortuneCategory(
    title: '타로',
    route: '/tarot',
    type: 'tarot',
    icon: Icons.style_rounded,
    iconAsset: 'assets/icons/fortune/tarot.png',
    gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
    description: '카드가 전하는 오늘의 메시지',
    category: 'traditional',
    isNew: true,
  ),

  // ==================== Dream Interpretation ====================
  FortuneCategory(
    title: '해몽',
    route: '/dream',
    type: 'dream',
    icon: Icons.bedtime_rounded,
    iconAsset: 'assets/icons/fortune/dream.png',
    gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    description: '꿈이 전하는 숨겨진 의미',
    category: 'traditional',
    isNew: true,
  ),

  // ==================== Physiognomy ====================
  FortuneCategory(
    title: '관상',
    route: '/face-reading',
    type: 'face-reading',
    icon: Icons.face_rounded,
    iconAsset: 'assets/icons/fortune/face_reading.png',
    gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    description: '얼굴에 나타난 운명의 징표',
    category: 'traditional',
  ),

  // ==================== Talisman ====================
  FortuneCategory(
    title: '부적',
    route: '/lucky-talisman',
    type: 'talisman',
    icon: Icons.shield_rounded,
    iconAsset: 'assets/icons/fortune/talisman.png',
    gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    description: '액운을 막고 행운을 부르는 부적',
    category: 'traditional',
  ),

  // ==================== Personal/Character-based Fortunes (통합) ====================
  FortuneCategory(
    title: '나의 성격 탐구',
    route: '/personality-dna',
    type: 'personality-dna',
    icon: Icons.biotech_rounded,
    iconAsset: 'assets/icons/fortune/personality_dna.png',
    gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    description: 'MBTI × 혈액형 × 별자리 × 띠 조합 분석',
    category: 'lifestyle',
    isNew: true,
  ),
  FortuneCategory(
    title: 'MBTI',
    route: '/mbti',
    type: 'mbti',
    icon: Icons.psychology_rounded,
    iconAsset: 'assets/icons/fortune/mbti.png',
    gradientColors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    description: 'MBTI 성격별 오늘의 운세',
    category: 'lifestyle',
    isNew: true,
  ),
  FortuneCategory(
    title: '바이오리듬',
    route: '/biorhythm',
    type: 'biorhythm',
    icon: Icons.timeline_rounded,
    iconAsset: 'assets/icons/fortune/biorhythm.png',
    gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    description: '신체, 감정, 지성 리듬 분석',
    category: 'health',
    isNew: true,
  ),

  // ==================== Relationship/Love Fortunes ====================
  FortuneCategory(
    title: '연애',
    route: '/love',
    type: 'love',
    icon: Icons.favorite_rounded,
    iconAsset: 'assets/icons/fortune/love.png',
    gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    description: '사랑과 연애의 운세',
    category: 'love',
  ),
  FortuneCategory(
    title: '궁합',
    route: '/compatibility',
    type: 'compatibility',
    icon: Icons.people_rounded,
    iconAsset: 'assets/icons/fortune/compatibility.png',
    gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
    description: '두 사람의 궁합 보기',
    category: 'love',
  ),
  FortuneCategory(
    title: '경계대상',
    route: '/avoid-people',
    type: 'avoid-people',
    icon: Icons.person_off_rounded,
    iconAsset: 'assets/icons/fortune/avoid_people.png',
    gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
    description: '오늘 피해야 할 사람의 특징',
    category: 'love',
    isNew: true,
  ),
  FortuneCategory(
    title: '재회',
    route: '/ex-lover-simple',
    type: 'ex_lover',
    icon: Icons.heart_broken_rounded,
    iconAsset: 'assets/icons/fortune/ex_lover.png',
    gradientColors: [Color(0xFF6B7280), Color(0xFF374151)],
    description: '헤어진 연인과의 재회 가능성',
    category: 'love',
    isNew: true,
  ),
  FortuneCategory(
    title: '소개팅',
    route: '/blind-date',
    type: 'blind_date',
    icon: Icons.waving_hand_rounded,
    iconAsset: 'assets/icons/fortune/blind_date.png',
    gradientColors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
    description: '오늘의 소개팅 성공 가능성',
    category: 'love',
    isNew: true,
  ),

  // ==================== Career/Work Fortunes (통합) ====================
  FortuneCategory(
    title: '직업',
    route: '/career',
    type: 'career',
    icon: Icons.work_rounded,
    iconAsset: 'assets/icons/fortune/career.png',
    gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    description: '취업/직업/사업/창업 종합',
    category: 'career',
    isNew: true,
  ),
  FortuneCategory(
    title: '시험',
    route: '/lucky-exam',
    type: 'exam',
    icon: Icons.school_rounded,
    iconAsset: 'assets/icons/fortune/study.png',
    gradientColors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
    description: '시험과 자격증 합격 운세',
    category: 'career',
  ),

  // ==================== Investment/Money Fortunes (통합) ====================
  FortuneCategory(
    title: '재물',
    route: '/investment',
    type: 'investment',
    icon: Icons.trending_up_rounded,
    iconAsset: 'assets/icons/fortune/investment.png',
    gradientColors: [Color(0xFF16A34A), Color(0xFF15803D)],
    description: '주식/부동산/코인/경매 등 10개 섹터',
    category: 'money',
    isPremium: true,
    isNew: true,
  ),

  // ==================== Lifestyle/Lucky Items (통합) ====================
  FortuneCategory(
    title: '행운아이템',
    route: '/lucky-items',
    type: 'lucky_items',
    icon: Icons.auto_awesome_rounded,
    iconAsset: 'assets/icons/fortune/lucky_items.png',
    gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
    description: '색깔/숫자/음식/아이템',
    category: 'lifestyle',
  ),
  FortuneCategory(
    title: '로또',
    route: '/lotto',
    type: 'lucky-lottery',
    icon: Icons.casino_rounded,
    iconAsset: 'assets/icons/fortune/lotto.png',
    gradientColors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    description: '오늘의 행운 번호',
    category: 'lifestyle',
    isNew: true,
  ),
  FortuneCategory(
    title: '재능',
    route: '/talent-fortune-input',
    type: 'talent',
    icon: Icons.stars_rounded,
    iconAsset: 'assets/icons/fortune/talent.png',
    gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
    description: '사주팔자 기반 재능 분석',
    category: 'lifestyle',
  ),
  FortuneCategory(
    title: '소원',
    route: '/wish',
    type: 'wish',
    icon: Icons.star_rounded,
    iconAsset: 'assets/icons/fortune/wish.png',
    gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
    description: '신에게 소원을 빌어보세요',
    category: 'lifestyle',
  ),

  // ==================== Health & Sports Fortunes (분리) ====================
  FortuneCategory(
    title: '건강',
    route: '/health-toss',
    type: 'health',
    icon: Icons.favorite_rounded,
    iconAsset: 'assets/icons/fortune/health.png',
    gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
    description: '오늘의 건강 상태와 신체 부위별 운세',
    category: 'health',
    isNew: true,
  ),
  FortuneCategory(
    title: '운동',
    route: '/exercise',
    type: 'exercise',
    icon: Icons.fitness_center_rounded,
    iconAsset: 'assets/icons/fortune/exercise.png',
    gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    description: '피트니스, 요가, 런닝 운세',
    category: 'health',
  ),
  FortuneCategory(
    title: '스포츠경기',
    route: '/sports-game',
    type: 'sports_game',
    icon: Icons.sports_rounded,
    iconAsset: 'assets/icons/fortune/sports_game.png',
    gradientColors: [Color(0xFFEA580C), Color(0xFFDC2626)],
    description: '골프, 야구, 테니스 등 경기 운세',
    category: 'health',
  ),
  FortuneCategory(
    title: '이사',
    route: '/moving',
    type: 'moving',
    icon: Icons.home_work_rounded,
    iconAsset: 'assets/icons/fortune/moving.png',
    gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    description: '이사 길일과 방향, 손없는날 분석',
    category: 'lifestyle',
  ),

  // ==================== Interactive Fortunes ====================
  FortuneCategory(
    title: '포춘쿠키',
    route: '/fortune-cookie',
    type: 'fortune-cookie',
    icon: Icons.cookie_rounded,
    iconAsset: 'assets/icons/fortune/fortune_cookie.png',
    gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
    description: '오늘의 행운 메시지',
    category: 'interactive',
    isNew: true,
  ),
  FortuneCategory(
    title: '유명인',
    route: '/celebrity',
    type: 'celebrity',
    icon: Icons.star_rounded,
    iconAsset: 'assets/icons/fortune/celebrity.png',
    gradientColors: [Color(0xFFFF1744), Color(0xFFE91E63)],
    description: '좋아하는 유명인과 나의 오늘 운세',
    category: 'interactive',
    isNew: true,
  ),

  // ==================== Pet Fortunes (통합) ====================
  FortuneCategory(
    title: '반려동물',
    route: '/pet',
    type: 'pet',
    icon: Icons.pets_rounded,
    iconAsset: 'assets/icons/fortune/pet.png',
    gradientColors: [Color(0xFFE11D48), Color(0xFFBE123C)],
    description: '반려동물/반려견/반려묘/궁합',
    category: 'petFamily',
    isNew: true,
  ),
  // ==================== Family Fortunes (통합) ====================
  FortuneCategory(
    title: '가족',
    route: '/family',
    type: 'family',
    icon: Icons.family_restroom_rounded,
    iconAsset: 'assets/icons/fortune/family.png',
    gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    description: '자녀/육아/태교/가족화합',
    category: 'petFamily',
    isNew: true,
  ),
];
