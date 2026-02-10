import 'dart:math';
import '../models/asset_pack.dart';

/// 자산 팩 설정 및 매핑
///
/// On-Demand 리소스 시스템의 핵심 설정 파일
/// - Tier 1: 앱 번들에 포함 (필수)
/// - Tier 2: 첫 실행 시 백그라운드 다운로드
/// - Tier 3: 필요 시 On-Demand 다운로드
class AssetPackConfig {
  AssetPackConfig._();

  // ============================================================
  // Supabase Storage 버킷 설정
  // ============================================================

  static const String storageBucket = 'fortune-assets';
  static const String tarotBucket = 'tarot-decks';
  static const String categoryBucket = 'category-assets';

  // ============================================================
  // 타로 덱 목록
  // ============================================================

  static const List<String> tarotDecks = [
    'rider_waite',
    'thoth',
    'ancient_italian',
    'before_tarot',
    'after_tarot',
    'golden_dawn_cicero',
    'golden_dawn_wang',
    'grand_etteilla',
  ];

  // ============================================================
  // 오늘의 랜덤 덱 선택
  // ============================================================

  /// 오늘 날짜 기반 랜덤 덱 선택 (하루 동안 동일)
  static String getTodaysDeck() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    return tarotDecks[random.nextInt(tarotDecks.length)];
  }

  /// 특정 날짜의 덱 선택
  static String getDeckForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return tarotDecks[random.nextInt(tarotDecks.length)];
  }

  /// 타로 덱 표시 이름 반환
  static String getTarotDeckDisplayName(String deckId) {
    final packId = 'tarot_$deckId';
    return packs[packId]?.displayName ?? _formatDeckName(deckId);
  }

  /// 덱 ID를 사람이 읽기 쉬운 이름으로 포맷
  static String _formatDeckName(String deckId) {
    // snake_case를 Title Case로 변환
    return deckId
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  // ============================================================
  // 자산 팩 정의
  // ============================================================

  /// 모든 자산 팩 정의
  static final Map<String, AssetPack> packs = {
    // --------------------------------------------------------
    // Tier 1: 앱 번들 필수 (15-20 MB)
    // --------------------------------------------------------
    'core': const AssetPack(
      id: 'core',
      displayName: '코어 자산',
      tier: AssetTier.bundled,
      localPaths: [
        'assets/images/zpzg_logo.webp',
        'assets/images/zpzg_logo_light.webp',
        'assets/images/zpzg_logo_dark.webp',
        'assets/fonts/',
        'assets/sounds/',
      ],
      estimatedSize: 5 * 1024 * 1024, // 5 MB
    ),

    'daily_fortune': const AssetPack(
      id: 'daily_fortune',
      displayName: '일일 운세',
      tier: AssetTier.bundled,
      localPaths: [
        'assets/images/fortune/heroes/daily/',
        'assets/images/fortune/icons/section/',
        'assets/images/fortune/mascot/daily/',
      ],
      estimatedSize: 8 * 1024 * 1024, // 8 MB
      fortuneType: 'daily',
    ),

    'chat_basic': const AssetPack(
      id: 'chat_basic',
      displayName: '채팅 기본',
      tier: AssetTier.bundled,
      localPaths: [
        'assets/images/chat/',
      ],
      estimatedSize: 3 * 1024 * 1024, // 3 MB
    ),

    // --------------------------------------------------------
    // Tier 2: 첫 실행 시 다운로드 (30-50 MB)
    // --------------------------------------------------------
    'fortune_icons': const AssetPack(
      id: 'fortune_icons',
      displayName: '운세 카테고리 아이콘',
      tier: AssetTier.essential,
      localPaths: ['assets/images/fortune/icons/categories/'],
      storagePath: 'icons/categories/',
      estimatedSize: 15 * 1024 * 1024, // 15 MB
    ),

    'minhwa_basic': const AssetPack(
      id: 'minhwa_basic',
      displayName: '기본 민화',
      tier: AssetTier.essential,
      localPaths: ['assets/images/minhwa/'],
      storagePath: 'minhwa/',
      estimatedSize: 10 * 1024 * 1024, // 10 MB
    ),

    'chat_backgrounds': const AssetPack(
      id: 'chat_backgrounds',
      displayName: '채팅 배경',
      tier: AssetTier.essential,
      localPaths: ['assets/images/chat/backgrounds/'],
      storagePath: 'chat/backgrounds/',
      estimatedSize: 8 * 1024 * 1024, // 8 MB
    ),

    // --------------------------------------------------------
    // Tier 3: On-Demand 다운로드 - 타로 덱
    // --------------------------------------------------------
    'tarot_rider_waite': const AssetPack(
      id: 'tarot_rider_waite',
      displayName: 'Rider-Waite-Smith 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/rider_waite/'],
      storagePath: 'tarot/rider_waite/',
      estimatedSize: 5 * 1024 * 1024, // 5 MB
      fortuneType: 'tarot',
    ),

    'tarot_thoth': const AssetPack(
      id: 'tarot_thoth',
      displayName: '토트 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/thoth/'],
      storagePath: 'tarot/thoth/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    'tarot_ancient_italian': const AssetPack(
      id: 'tarot_ancient_italian',
      displayName: '고대 이탈리아 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/ancient_italian/'],
      storagePath: 'tarot/ancient_italian/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    'tarot_before_tarot': const AssetPack(
      id: 'tarot_before_tarot',
      displayName: '비포 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/before_tarot/'],
      storagePath: 'tarot/before_tarot/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    'tarot_after_tarot': const AssetPack(
      id: 'tarot_after_tarot',
      displayName: '애프터 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/after_tarot/'],
      storagePath: 'tarot/after_tarot/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    'tarot_golden_dawn_cicero': const AssetPack(
      id: 'tarot_golden_dawn_cicero',
      displayName: '골든 던 Cicero 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/golden_dawn_cicero/'],
      storagePath: 'tarot/golden_dawn_cicero/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    'tarot_golden_dawn_wang': const AssetPack(
      id: 'tarot_golden_dawn_wang',
      displayName: '골든 던 Wang 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/golden_dawn_wang/'],
      storagePath: 'tarot/golden_dawn_wang/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    'tarot_grand_etteilla': const AssetPack(
      id: 'tarot_grand_etteilla',
      displayName: '그랑 에테이야 타로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/tarot/decks/grand_etteilla/'],
      storagePath: 'tarot/grand_etteilla/',
      estimatedSize: 5 * 1024 * 1024,
      fortuneType: 'tarot',
    ),

    // --------------------------------------------------------
    // Tier 3: On-Demand 다운로드 - 카테고리별 자산
    // --------------------------------------------------------
    'mbti_characters': const AssetPack(
      id: 'mbti_characters',
      displayName: 'MBTI 캐릭터',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/mbti/characters/'],
      storagePath: 'category/mbti/',
      estimatedSize: 21 * 1024 * 1024, // 21 MB
      fortuneType: 'mbti_compatibility',
    ),

    'zodiac_assets': const AssetPack(
      id: 'zodiac_assets',
      displayName: '띠별 이미지',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/zodiac/'],
      storagePath: 'category/zodiac/',
      estimatedSize: 20 * 1024 * 1024, // 20 MB
      fortuneType: 'zodiac',
    ),

    'saju_elements': const AssetPack(
      id: 'saju_elements',
      displayName: '사주/오행 이미지',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/saju/elements/'],
      storagePath: 'category/saju/',
      estimatedSize: 5 * 1024 * 1024, // 5 MB
      fortuneType: 'saju',
    ),

    'pet_assets': const AssetPack(
      id: 'pet_assets',
      displayName: '펫 이미지',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/pets/'],
      storagePath: 'category/pets/',
      estimatedSize: 11 * 1024 * 1024, // 11 MB
      fortuneType: 'pet_compatibility',
    ),

    'talisman_assets': const AssetPack(
      id: 'talisman_assets',
      displayName: '탈리스만/부적 이미지',
      tier: AssetTier.onDemand,
      localPaths: [
        'assets/images/fortune/talisman/',
        'assets/images/talismans/',
      ],
      storagePath: 'category/talisman/',
      estimatedSize: 6 * 1024 * 1024, // 6 MB
      fortuneType: 'talisman',
    ),

    'lucky_items': const AssetPack(
      id: 'lucky_items',
      displayName: '행운 아이템',
      tier: AssetTier.onDemand,
      localPaths: [
        'assets/images/fortune/icons/lucky/',
        'assets/images/fortune/items/lucky/',
      ],
      storagePath: 'category/lucky/',
      estimatedSize: 18 * 1024 * 1024, // 18 MB
    ),

    'infographic_assets': const AssetPack(
      id: 'infographic_assets',
      displayName: '인포그래픽',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/infographic/'],
      storagePath: 'category/infographic/',
      estimatedSize: 6 * 1024 * 1024, // 6 MB
    ),

    'video_content': const AssetPack(
      id: 'video_content',
      displayName: '비디오 콘텐츠',
      tier: AssetTier.onDemand,
      localPaths: ['assets/videos/'],
      storagePath: 'videos/',
      estimatedSize: 12 * 1024 * 1024, // 12 MB
    ),

    // --------------------------------------------------------
    // 운세 카테고리별 히어로 이미지
    // --------------------------------------------------------
    'heroes_love': const AssetPack(
      id: 'heroes_love',
      displayName: '애정 운세 히어로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/heroes/love/'],
      storagePath: 'heroes/love/',
      estimatedSize: 8 * 1024 * 1024,
      fortuneType: 'love',
    ),

    'heroes_career': const AssetPack(
      id: 'heroes_career',
      displayName: '직장 운세 히어로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/heroes/career/'],
      storagePath: 'heroes/career/',
      estimatedSize: 8 * 1024 * 1024,
      fortuneType: 'career',
    ),

    'heroes_health': const AssetPack(
      id: 'heroes_health',
      displayName: '건강 운세 히어로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/heroes/health/'],
      storagePath: 'heroes/health/',
      estimatedSize: 8 * 1024 * 1024,
      fortuneType: 'health',
    ),

    'heroes_investment': const AssetPack(
      id: 'heroes_investment',
      displayName: '투자 운세 히어로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/heroes/investment/'],
      storagePath: 'heroes/investment/',
      estimatedSize: 8 * 1024 * 1024,
      fortuneType: 'investment',
    ),

    'heroes_exam': const AssetPack(
      id: 'heroes_exam',
      displayName: '시험 운세 히어로',
      tier: AssetTier.onDemand,
      localPaths: ['assets/images/fortune/heroes/exam/'],
      storagePath: 'heroes/exam/',
      estimatedSize: 8 * 1024 * 1024,
      fortuneType: 'exam',
    ),
  };

  // ============================================================
  // 유틸리티 메서드
  // ============================================================

  /// 운세 타입에 필요한 자산 팩 목록 반환
  static List<AssetPack> getPacksForFortuneType(String fortuneType) {
    return packs.values
        .where((pack) => pack.fortuneType == fortuneType)
        .toList();
  }

  /// 타로 덱 ID로 자산 팩 반환
  static AssetPack? getTarotDeckPack(String deckId) {
    return packs['tarot_$deckId'];
  }

  /// 오늘의 타로 덱 자산 팩 반환
  static AssetPack? getTodaysTarotPack() {
    final todaysDeck = getTodaysDeck();
    return getTarotDeckPack(todaysDeck);
  }

  /// Tier별 자산 팩 목록 반환
  static List<AssetPack> getPacksByTier(AssetTier tier) {
    return packs.values.where((pack) => pack.tier == tier).toList();
  }

  /// Tier 1 (번들) 자산 팩 목록
  static List<AssetPack> get bundledPacks => getPacksByTier(AssetTier.bundled);

  /// Tier 2 (필수 다운로드) 자산 팩 목록
  static List<AssetPack> get essentialPacks =>
      getPacksByTier(AssetTier.essential);

  /// Tier 3 (On-Demand) 자산 팩 목록
  static List<AssetPack> get onDemandPacks =>
      getPacksByTier(AssetTier.onDemand);

  /// 전체 예상 용량 계산
  static int get totalEstimatedSize =>
      packs.values.fold(0, (sum, pack) => sum + pack.estimatedSize);

  /// Tier별 예상 용량 계산
  static int getEstimatedSizeByTier(AssetTier tier) {
    return getPacksByTier(tier)
        .fold(0, (sum, pack) => sum + pack.estimatedSize);
  }

  /// Supabase Storage 공개 URL 생성
  static String getStorageUrl(String storagePath) {
    // 실제 Supabase URL은 환경 변수에서 가져옴
    return 'https://your-project.supabase.co/storage/v1/object/public/$storageBucket/$storagePath';
  }

  /// 로컬 캐시 경로 생성
  static String getLocalCachePath(String packId) {
    return 'asset_packs/$packId/';
  }
}
