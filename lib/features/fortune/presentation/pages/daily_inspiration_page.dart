import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import '../../../../services/storage_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'dart:math' as math;

// Provider for daily inspiration
final dailyInspirationProvider = FutureProvider.autoDispose<DailyInspiration>((ref) async {
  final userProfileAsync = ref.watch(userProfileProvider);
  final storageService = StorageService();
  
  // Get user profile data
  Map<String, dynamic>? profile;
  userProfileAsync.when(
    data: (data) => profile = data?.toJson(),
    error: (_, __) => profile = null,
    loading: () => profile = null,
  );
  
  // If no profile, try local storage
  if (profile == null) {
    profile = await storageService.getUserProfile();
  }
  
  // Generate inspiration based on user profile
  return DailyInspiration.generate(profile);
});

class DailyInspiration {
  final String mainQuote;
  final String author;
  final String personalMessage;
  final List<String> luckyTips;
  final String affirmation;
  final Color themeColor;
  final IconData icon;
  final String zodiacAdvice;
  final String todayFocus;
  
  DailyInspiration({
    required this.mainQuote,
    required this.author,
    required this.personalMessage,
    required this.luckyTips,
    required this.affirmation,
    required this.themeColor,
    required this.icon,
    required this.zodiacAdvice,
    required this.todayFocus,
  });
  
  static DailyInspiration generate(Map<String, dynamic>? profile) {
    final random = math.Random();
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    
    // Get user's zodiac sign and MBTI if available
    final zodiacSign = profile?['zodiac_sign'] ?? '';
    final mbti = profile?['mbti'] ?? '';
    final name = profile?['name'] ?? '당신';
    
    // Quotes pool
    final quotes = [
      {'quote': '오늘 하루도 당신의 빛으로 세상을 밝히세요.', 'author': '포춘 앱'},
      {'quote': '작은 발걸음이 모여 큰 여정이 됩니다.', 'author': '노자'},
      {'quote': '매일 조금씩 나아가는 것이 성공의 비결입니다.', 'author': '벤저민 프랭클린'},
      {'quote': '당신의 잠재력은 무한합니다.', 'author': '포춘 앱'},
      {'quote': '오늘은 새로운 시작을 위한 완벽한 날입니다.', 'author': '무명'},
      {'quote': '긍정적인 마음이 긍정적인 결과를 만듭니다.', 'author': '부처'},
      {'quote': '도전은 성장의 기회입니다.', 'author': '포춘 앱'},
      {'quote': '믿음은 기적을 만드는 첫걸음입니다.', 'author': '헬렌 켈러'},
    ];
    
    // Personal messages based on day of week
    final personalMessages = {
      1: '$name님, 새로운 한 주의 시작입니다! 이번 주도 멋진 일들이 기다리고 있어요.',
      2: '어제보다 나은 오늘을 만들어가는 $name님, 정말 멋져요!',
      3: '한 주의 중간, $name님의 노력이 빛을 발하고 있습니다.',
      4: '목표에 가까워지고 있는 $name님, 조금만 더 힘내세요!',
      5: '불금을 앞둔 $name님, 오늘 하루도 활기차게!',
      6: '주말의 시작! $name님만의 특별한 시간을 만드세요.',
      7: '편안한 일요일, $name님의 마음도 쉬어가는 시간이 되길.',
    };
    
    // Lucky tips based on zodiac
    final zodiacTips = {
      '양자리': ['적극적인 행동이 행운을 부릅니다', '빨간색 소품을 활용해보세요', '오전 시간대가 행운의 시간입니다'],
      '황소자리': ['인내심을 가지고 기다리세요', '초록색이 오늘의 행운색입니다', '맛있는 음식이 기분을 좋게 합니다'],
      '쌍둥이자리': ['소통과 대화가 기회를 만듭니다', '노란색 물건이 행운을 가져옵니다', '새로운 정보를 접해보세요'],
      '게자리': ['가족과의 시간이 힐링이 됩니다', '흰색이나 은색이 좋습니다', '집에서 보내는 시간도 소중해요'],
      '사자자리': ['자신감 있는 모습이 매력적입니다', '금색 액세서리가 행운입니다', '리더십을 발휘해보세요'],
      '처녀자리': ['세심한 계획이 성공을 만듭니다', '네이비색이 안정감을 줍니다', '건강 관리에 신경쓰세요'],
      '천칭자리': ['균형잡힌 하루를 보내세요', '파스텔톤이 좋은 기운을 줍니다', '예술 활동이 영감을 줍니다'],
      '전갈자리': ['직관을 믿고 행동하세요', '검은색이 카리스마를 높입니다', '비밀스러운 계획이 성공합니다'],
      '사수자리': ['모험심을 발휘할 때입니다', '보라색이 행운을 부릅니다', '여행이나 학습이 좋습니다'],
      '염소자리': ['목표를 향해 꾸준히 나아가세요', '갈색이 안정감을 줍니다', '실용적인 선택이 좋습니다'],
      '물병자리': ['창의적인 아이디어가 빛납니다', '하늘색이 영감을 줍니다', '친구들과의 만남이 즐겁습니다'],
      '물고기자리': ['감성적인 활동이 힐링됩니다', '연한 파란색이 마음을 편안하게 합니다', '예술이나 음악이 도움됩니다'],
    };
    
    // MBTI-based affirmations
    final mbtiAffirmations = {
      'INTJ': '나의 전략적 사고가 오늘도 빛을 발합니다.',
      'INTP': '나의 분석력이 문제를 해결합니다.',
      'ENTJ': '나의 리더십이 모두를 이끕니다.',
      'ENTP': '나의 창의성이 새로운 기회를 만듭니다.',
      'INFJ': '나의 직관이 올바른 길을 보여줍니다.',
      'INFP': '나의 가치관이 세상을 더 나은 곳으로 만듭니다.',
      'ENFJ': '나의 따뜻함이 사람들을 행복하게 합니다.',
      'ENFP': '나의 열정이 꿈을 현실로 만듭니다.',
      'ISTJ': '나의 신뢰성이 모두에게 힘이 됩니다.',
      'ISFJ': '나의 배려심이 주변을 밝게 합니다.',
      'ESTJ': '나의 추진력이 목표를 달성합니다.',
      'ESFJ': '나의 친절함이 좋은 관계를 만듭니다.',
      'ISTP': '나의 실용성이 문제를 해결합니다.',
      'ISFP': '나의 감성이 아름다움을 만듭니다.',
      'ESTP': '나의 행동력이 기회를 잡습니다.',
      'ESFP': '나의 즐거움이 모두를 행복하게 합니다.',
    };
    
    // Today's focus based on day
    final todayFocuses = [
      '새로운 시작과 계획',
      '실행과 추진력',
      '소통과 네트워킹',
      '집중과 완성',
      '마무리와 정리',
      '휴식과 충전',
      '성찰과 준비',
    ];
    
    // Select random quote
    final selectedQuote = quotes[random.nextInt(quotes.length)];
    
    // Get zodiac tips
    final userZodiacTips = zodiacTips[zodiacSign] ?? [
      '긍정적인 마음가짐을 유지하세요',
      '오늘의 행운색은 파란색입니다',
      '새로운 만남에 열린 마음을 가지세요',
    ];
    
    // Colors and icons
    const colors = [
      TossDesignSystem.purple,
      TossDesignSystem.tossBlue,
      TossDesignSystem.teal,
      TossDesignSystem.warningOrange,
      TossDesignSystem.pinkPrimary,
      TossDesignSystem.purple,
    ];
    
    final icons = [
      Icons.auto_awesome,
      Icons.wb_sunny,
      Icons.star,
      Icons.favorite,
      Icons.psychology,
      Icons.spa,
    ];
    
    return DailyInspiration(
      mainQuote: selectedQuote['quote']!,
      author: selectedQuote['author']!,
      personalMessage: personalMessages[dayOfWeek] ?? personalMessages[1]!,
      luckyTips: userZodiacTips,
      affirmation: mbtiAffirmations[mbti] ?? '나는 오늘도 최선을 다합니다.',
      themeColor: colors[random.nextInt(colors.length)],
      icon: icons[random.nextInt(icons.length)],
      zodiacAdvice: zodiacSign.isNotEmpty 
          ? '$zodiacSign의 오늘은 특별합니다.' 
          : '오늘은 당신에게 특별한 날입니다.',
      todayFocus: todayFocuses[(dayOfWeek - 1) % todayFocuses.length],
    );
  }
}

class DailyInspirationPage extends ConsumerStatefulWidget {
  const DailyInspirationPage({super.key});

  @override
  ConsumerState<DailyInspirationPage> createState() => _DailyInspirationPageState();
}

class _DailyInspirationPageState extends ConsumerState<DailyInspirationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _shareInspiration(DailyInspiration inspiration) {
    HapticUtils.lightImpact();
    final text = '''
[오늘의 영감]
"${inspiration.mainQuote}"
- ${inspiration.author}

${inspiration.personalMessage}

오늘의 긍정확언:
${inspiration.affirmation}

#포춘앱 #오늘의영감 #긍정에너지
    ''';
    
    Share.share(text);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final inspirationAsync = ref.watch(dailyInspirationProvider);
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR');
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: AppBar(
        backgroundColor: TossDesignSystem.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '오늘의 영감',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          inspirationAsync.when(
            data: (inspiration) => IconButton(
              icon: Icon(Icons.share_outlined, color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
              onPressed: () => _shareInspiration(inspiration),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: inspirationAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TossDesignSystem.tossBlue),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '영감을 불러올 수 없습니다',
                style: TextStyle(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '잠시 후 다시 시도해주세요',
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
              ),
            ],
          ),
        ),
        data: (inspiration) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Column(
              children: [
                // Main Quote Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              inspiration.themeColor.withOpacity(0.8),
                              inspiration.themeColor.withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: inspiration.themeColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              inspiration.icon,
                              size: 48,
                              color: TossDesignSystem.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              dateFormat.format(now),
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                color: TossDesignSystem.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '"${inspiration.mainQuote}"',
                              style: TextStyle(
                                fontSize: 22 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: TossDesignSystem.white,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '- ${inspiration.author}',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                color: TossDesignSystem.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Personal Message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: TossDesignSystem.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: TossDesignSystem.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.tossBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: TossDesignSystem.tossBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '개인 메시지',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          inspiration.personalMessage,
                          style: TextStyle(
                            fontSize: 15 * fontScale,
                            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Today's Focus
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TossDesignSystem.tossBlue.withOpacity(0.1),
                          TossDesignSystem.purple.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: TossDesignSystem.tossBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.center_focus_strong,
                              color: TossDesignSystem.tossBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '오늘의 포커스',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: TossDesignSystem.tossBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          inspiration.todayFocus,
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Lucky Tips
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: TossDesignSystem.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: TossDesignSystem.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.warningYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: TossDesignSystem.warningYellow,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '오늘의 행운 팁',
                              style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...inspiration.luckyTips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: TossDesignSystem.warningYellow,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: 14 * fontScale,
                                    color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Affirmation Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TossDesignSystem.tossBlue.withOpacity(0.1),
                          TossDesignSystem.tossBlue.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: TossDesignSystem.tossBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: TossDesignSystem.tossBlue,
                          size: 32,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '오늘의 긍정 확언',
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: TossDesignSystem.tossBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          inspiration.affirmation,
                          style: TextStyle(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}