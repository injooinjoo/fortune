import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/talisman_wish.dart';
import '../../domain/models/talisman_design.dart';
import '../../domain/models/talisman_effect.dart';
import '../../../../core/utils/logger.dart';

class TalismanService {
  static final TalismanService _instance = TalismanService._internal();
  factory TalismanService() => _instance;
  TalismanService._internal();

  final _supabase = Supabase.instance.client;

  /// 하루 부적 생성 제한 확인
  Future<bool> canCreateTalisman(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('user_talismans')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      final todayCount = (response as List).length;

      // TODO: 프리미엄 사용자 체크 로직 추가
      // final isProUser = await _checkPremiumStatus(userId);
      // if (isProUser) return true; // 프리미엄 사용자는 무제한

      return todayCount < 1; // 무료 사용자는 하루 1개
    } catch (e, stackTrace) {
      Logger.error('Failed to check talisman limit', e, stackTrace);
      return false;
    }
  }

  /// 부적 생성
  Future<TalismanDesign> generateTalisman({
    required TalismanCategory category,
    required String specificWish,
    String? userId,
    bool isPremium = false,
  }) async {
    try {
      Logger.info('Generating talisman for category: ${category.name}, wish: $specificWish');

      // AI API 호출을 시뮬레이션 (실제로는 Stable Diffusion이나 다른 AI 서비스 연동)
      await Future.delayed(const Duration(seconds: 3)); // 생성 시간 시뮬레이션

      final talismanDesign = TalismanDesign(
        id: _generateId(),
        userId: userId ?? '',
        designType: _selectDesignType(category),
        category: category,
        title: _generateTitle(category, specificWish),
        imageUrl: _generateImageUrl(category),
        colors: _generateColors(category),
        symbols: _generateSymbols(category),
        mantraText: _generateMantraText(category, specificWish),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isPremium: false, // TODO: 프리미엄 로직 추가
        effectScore: _generateEffectScore(),
        blessings: _generateBlessings(category),
      );

      // 데이터베이스에 저장
      if (userId != null && userId.isNotEmpty) {
        await _saveTalismanToDatabase(talismanDesign);
      }

      Logger.info('Talisman generated successfully: ${talismanDesign.id}');
      return talismanDesign;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate talisman', e, stackTrace);
      rethrow;
    }
  }

  /// 부적 효과 추적
  Future<void> trackTalismanEffect({
    required String talismanId,
    required String userId,
    required int dailyScore,
    List<String>? positiveSigns,
    List<String>? challenges,
    String? userNote,
  }) async {
    try {
      final effect = TalismanEffect(
        id: _generateId(),
        talismanId: talismanId,
        userId: userId,
        trackingDate: DateTime.now(),
        dailyScore: dailyScore,
        positiveSigns: positiveSigns ?? [],
        challenges: challenges ?? [],
        userNote: userNote,
        createdAt: DateTime.now(),
      );

      await _supabase.from('talisman_effects').insert(effect.toJson());
      Logger.info('Talisman effect tracked: ${effect.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to track talisman effect', e, stackTrace);
    }
  }

  /// 사용자의 부적 목록 조회
  Future<List<TalismanDesign>> getUserTalismans(String userId) async {
    try {
      final response = await _supabase
          .from('user_talismans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final talismans = (response as List)
          .map((item) => TalismanDesign.fromJson(item))
          .toList();

      Logger.info('Retrieved ${talismans.length} talismans for user: $userId');
      return talismans;
    } catch (e, stackTrace) {
      Logger.error('Failed to get user talismans', e, stackTrace);
      return [];
    }
  }

  /// 부적 통계 조회
  Future<TalismanStats> getTalismanStats(String talismanId) async {
    try {
      final response = await _supabase
          .from('talisman_effects')
          .select()
          .eq('talisman_id', talismanId)
          .order('tracking_date', ascending: false);

      final effects = (response as List)
          .map((item) => TalismanEffect.fromJson(item))
          .toList();

      final stats = _calculateStats(talismanId, effects);
      Logger.info('Retrieved stats for talisman: $talismanId');
      return stats;
    } catch (e, stackTrace) {
      Logger.error('Failed to get talisman stats', e, stackTrace);
      return TalismanStats(talismanId: talismanId);
    }
  }

  // Private helper methods

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  TalismanDesignType _selectDesignType(TalismanCategory category) {
    final random = Random();
    final types = TalismanDesignType.values;
    return types[random.nextInt(types.length)];
  }

  String _generateTitle(TalismanCategory category, String wish) {
    final titles = {
      TalismanCategory.wealth: ['금전운 부적', '재물 충만 부적', '경제 풍요 부적'],
      TalismanCategory.love: ['사랑 성취 부적', '인연 부적', '행복 결혼 부적'],
      TalismanCategory.career: ['성공 부적', '승진 부적', '사업 번영 부적'],
      TalismanCategory.health: ['건강 부적', '무병장수 부적', '생명력 부적'],
      TalismanCategory.study: ['학업 성취 부적', '합격 부적', '지혜 부적'],
      TalismanCategory.relationship: ['인간관계 부적', '소통 부적', '화합 부적'],
      TalismanCategory.goal: ['목표 달성 부적', '성취 부적', '의지력 부적'],
    };
    
    final categoryTitles = titles[category] ?? ['행운 부적'];
    final random = Random();
    return categoryTitles[random.nextInt(categoryTitles.length)];
  }

  String _generateImageUrl(TalismanCategory category) {
    // 로컬 에셋 경로 사용 - 전통 한국 부적 디자인
    final assetPaths = {
      TalismanCategory.wealth: 'assets/images/talismans/wealth.svg',
      TalismanCategory.love: 'assets/images/talismans/love.svg',
      TalismanCategory.career: 'assets/images/talismans/career.svg',
      TalismanCategory.health: 'assets/images/talismans/health.svg',
      TalismanCategory.study: 'assets/images/talismans/study.svg',
      TalismanCategory.relationship: 'assets/images/talismans/relationship.svg',
      TalismanCategory.goal: 'assets/images/talismans/goal.svg',
    };
    
    return assetPaths[category] ?? 'assets/images/talismans/wealth.svg';
  }

  Map<String, dynamic> _generateColors(TalismanCategory category) {
    final colorSchemes = {
      TalismanCategory.wealth: {
        'primary': '#FFD700',
        'secondary': '#FFA500',
        'accent': '#FF6347'
      },
      TalismanCategory.love: {
        'primary': '#FF69B4',
        'secondary': '#FF1493',
        'accent': '#DC143C'
      },
      TalismanCategory.career: {
        'primary': '#4169E1',
        'secondary': '#1E90FF',
        'accent': '#00BFFF'
      },
      TalismanCategory.health: {
        'primary': '#32CD32',
        'secondary': '#98FB98',
        'accent': '#90EE90'
      },
      TalismanCategory.study: {
        'primary': '#9400D3',
        'secondary': '#8A2BE2',
        'accent': '#9932CC'
      },
      TalismanCategory.relationship: {
        'primary': '#FF8C00',
        'secondary': '#FFD700',
        'accent': '#FFA500'
      },
      TalismanCategory.goal: {
        'primary': '#20B2AA',
        'secondary': '#48D1CC',
        'accent': '#40E0D0'
      },
    };
    
    return colorSchemes[category] ?? {'primary': '#000000', 'secondary': '#666666', 'accent': '#999999'};
  }

  Map<String, dynamic> _generateSymbols(TalismanCategory category) {
    final symbolSets = {
      TalismanCategory.wealth: {
        'main': '財',
        'secondary': ['錢', '富', '寶'],
        'elements': ['gold_coin', 'treasure', 'abundance']
      },
      TalismanCategory.love: {
        'main': '愛',
        'secondary': ['情', '戀', '姻'],
        'elements': ['heart', 'rose', 'couple']
      },
      TalismanCategory.career: {
        'main': '成',
        'secondary': ['功', '業', '昇'],
        'elements': ['ladder', 'crown', 'victory']
      },
      TalismanCategory.health: {
        'main': '健',
        'secondary': ['康', '壽', '命'],
        'elements': ['tree', 'mountain', 'vitality']
      },
      TalismanCategory.study: {
        'main': '學',
        'secondary': ['智', '才', '慧'],
        'elements': ['book', 'pen', 'wisdom']
      },
      TalismanCategory.relationship: {
        'main': '和',
        'secondary': ['友', '信', '義'],
        'elements': ['bridge', 'handshake', 'unity']
      },
      TalismanCategory.goal: {
        'main': '達',
        'secondary': ['成', '志', '標'],
        'elements': ['arrow', 'target', 'achievement']
      },
    };
    
    return symbolSets[category] ?? {'main': '運', 'secondary': ['福'], 'elements': ['luck']};
  }

  String _generateMantraText(TalismanCategory category, String wish) {
    final mantras = {
      TalismanCategory.wealth: '금전운이 날로 상승하고, 경제적 풍요가 삶에 가득하리라',
      TalismanCategory.love: '진실한 사랑을 만나고, 행복한 인연이 이어지리라',
      TalismanCategory.career: '모든 일이 순조롭고, 성공의 길이 활짝 열리리라',
      TalismanCategory.health: '몸과 마음이 건강하고, 무병장수하리라',
      TalismanCategory.study: '학습능력이 향상되고, 모든 시험에 합격하리라',
      TalismanCategory.relationship: '사람들과의 관계가 원만하고, 소통이 순조롭게 이루어지리라',
      TalismanCategory.goal: '목표가 차근차근 달성되고, 꿈이 현실이 되리라',
    };
    
    return mantras[category] ?? '행운이 가득하고, 모든 소원이 성취되리라';
  }

  int _generateEffectScore() {
    final random = Random();
    return 70 + random.nextInt(30); // 70-99 사이의 점수
  }

  List<String> _generateBlessings(TalismanCategory category) {
    final blessings = {
      TalismanCategory.wealth: [
        '예상치 못한 수입이 생깁니다',
        '투자나 사업에서 좋은 기회를 만납니다',
        '금전 관리 능력이 향상됩니다'
      ],
      TalismanCategory.love: [
        '운명적인 만남이 찾아옵니다',
        '기존 관계가 더욱 깊어집니다',
        '자신의 매력이 증가합니다'
      ],
      TalismanCategory.career: [
        '업무 능력이 인정받습니다',
        '새로운 기회가 주어집니다',
        '동료들과의 협력이 원활해집니다'
      ],
      TalismanCategory.health: [
        '면역력이 강화됩니다',
        '스트레스가 감소합니다',
        '활력과 에너지가 넘칩니다'
      ],
      TalismanCategory.study: [
        '집중력이 향상됩니다',
        '기억력이 좋아집니다',
        '학습 효율성이 증가합니다'
      ],
      TalismanCategory.relationship: [
        '소통 능력이 향상됩니다',
        '갈등이 해결됩니다',
        '새로운 인연을 만납니다'
      ],
      TalismanCategory.goal: [
        '의지력이 강화됩니다',
        '계획 실행 능력이 향상됩니다',
        '장애물을 극복할 힘을 얻습니다'
      ],
    };
    
    return blessings[category] ?? ['행운이 가득합니다'];
  }

  Future<void> _saveTalismanToDatabase(TalismanDesign talisman) async {
    await _supabase.from('user_talismans').insert({
      'id': talisman.id,
      'user_id': talisman.userId,
      'design_type': talisman.designType.name,
      'category': talisman.category.name,
      'title': talisman.title,
      'image_url': talisman.imageUrl,
      'colors': talisman.colors,
      'symbols': talisman.symbols,
      'mantra_text': talisman.mantraText,
      'created_at': talisman.createdAt.toIso8601String(),
      'expires_at': talisman.expiresAt?.toIso8601String(),
      'is_premium': talisman.isPremium,
      'effect_score': talisman.effectScore,
      'blessings': talisman.blessings,
    });
  }

  TalismanStats _calculateStats(String talismanId, List<TalismanEffect> effects) {
    if (effects.isEmpty) {
      return TalismanStats(talismanId: talismanId);
    }

    final totalDays = effects.length;
    final averageScore = effects.map((e) => e.dailyScore).reduce((a, b) => a + b) / totalDays;
    
    // Calculate streaks
    int currentStreak = 0;
    int bestStreak = 0;
    int tempStreak = 0;
    
    final sortedEffects = effects..sort((a, b) => a.trackingDate.compareTo(b.trackingDate));
    
    for (int i = 0; i < sortedEffects.length; i++) {
      if (sortedEffects[i].dailyScore >= 70) {
        tempStreak++;
        if (i == sortedEffects.length - 1) {
          currentStreak = tempStreak;
        }
      } else {
        bestStreak = max(bestStreak, tempStreak);
        tempStreak = 0;
      }
    }
    bestStreak = max(bestStreak, tempStreak);

    return TalismanStats(
      talismanId: talismanId,
      totalDays: totalDays,
      averageScore: averageScore,
      bestStreak: bestStreak,
      currentStreak: currentStreak,
      lastUpdated: DateTime.now(),
    );
  }
}