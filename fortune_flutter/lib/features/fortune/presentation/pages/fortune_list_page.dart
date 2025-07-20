import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/fortune_list_card.dart';
import '../widgets/fortune_list_tile.dart';
import '../../../../presentation/widgets/simple_fortune_info_sheet.dart';
import '../../../../presentation/screens/ad_loading_screen.dart';
import '../../../../presentation/providers/providers.dart';
import '../widgets/tarot_fortune_list_card.dart';
import './tarot_enhanced_page.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../../../core/config/environment.dart';
import '../../../../presentation/providers/auth_provider.dart';

class FortuneCategory {
  final String title;
  final String route;
  final String type; // Fortune type for image mapping
  final IconData icon;
  final List<Color> gradientColors;
  final String description;
  final String category;
  final bool isNew;
  final bool isPremium;

  const FortuneCategory({
    required this.title,
    required this.route,
    required this.type,
    required this.icon,
    required this.gradientColors,
    required this.description,
    required this.category,
    this.isNew = false,
    this.isPremium = false,
  });
  
  // 영혼 정보 가져오기
  int get soulAmount => SoulRates.getSoulAmount(type);
  bool get isFreeFortune => soulAmount > 0;
  bool get isPremiumFortune => soulAmount < 0;
  String get soulDescription => SoulRates.getActionDescription(type);
  int get soulCost => soulAmount.abs(); // Convert to positive cost value
}

enum FortuneCategoryType {
  all,
  love,
  career,
  money,
  health,
  traditional,
  lifestyle,
  interactive,
  petFamily,
}

enum ViewMode {
  trend,
  list,
}

class FilterCategory {
  final FortuneCategoryType type;
  final String name;
  final IconData icon;
  final Color color;

  const FilterCategory({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class FortuneListPage extends ConsumerStatefulWidget {
  const FortuneListPage({super.key});

  @override
  ConsumerState<FortuneListPage> createState() => _FortuneListPageState();
}

class _FortuneListPageState extends ConsumerState<FortuneListPage> 
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final Map<String, GlobalKey> _thumbnailKeys = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0, // Will be used as a progress indicator
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // No scaling for now, will calculate dynamically
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // Keep opacity at 1.0 (no fade)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  GlobalKey _getThumbnailKey(String categoryRoute) {
    return _thumbnailKeys.putIfAbsent(categoryRoute, () => GlobalKey());
  }

  void _showAnimatedThumbnail(BuildContext context, GlobalKey cardKey, String imagePath, VoidCallback onDismiss) {
    final RenderBox? renderBox = cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final cardSize = renderBox.size;
    final cardPosition = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate the height for the top portion (60% of screen to overlap with bottom sheet)
    final topPortionHeight = screenHeight * 0.6;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final progress = _slideAnimation.value;
            
            // Interpolate position
            final currentLeft = cardPosition.dx * (1 - progress);
            final currentTop = cardPosition.dy * (1 - progress);
            final currentWidth = cardSize.width + (screenWidth - cardSize.width) * progress;
            final currentHeight = cardSize.width + (topPortionHeight - cardSize.width) * progress;
            
            // Interpolate border radius
            final borderRadius = 12.0 * (1 - progress);
            
            return Positioned(
              left: currentLeft,
              top: currentTop,
              width: currentWidth,
              height: currentHeight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3 * (1 - progress * 0.5)),
                      blurRadius: 20 + (10 * progress),
                      offset: Offset(0, 10 * (1 - progress)),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    
    // Start the animation but don't remove the overlay
    _animationController.forward();
    
    // Store the dismiss callback to be called when bottom sheet closes
    _currentDismissCallback = () {
      // Play reverse animation with faster duration
      _animationController.duration = const Duration(milliseconds: 400);
      _animationController.reverse().then((_) {
        _removeOverlay();
        _animationController.reset();
        // Reset to original duration for next forward animation
        _animationController.duration = const Duration(milliseconds: 600);
        onDismiss();
      });
    };
  }
  
  VoidCallback? _currentDismissCallback;

  static const List<FilterCategory> _filterOptions = [
    FilterCategory(
      type: FortuneCategoryType.all,
      name: '전체',
      icon: Icons.star_rounded,
      color: Color(0xFF7C3AED),
    ),
    FilterCategory(
      type: FortuneCategoryType.love,
      name: '연애·인연',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEC4899),
    ),
    FilterCategory(
      type: FortuneCategoryType.career,
      name: '취업·사업',
      icon: Icons.work_rounded,
      color: Color(0xFF3B82F6),
    ),
    FilterCategory(
      type: FortuneCategoryType.money,
      name: '재물·투자',
      icon: Icons.attach_money_rounded,
      color: Color(0xFFF59E0B),
    ),
    FilterCategory(
      type: FortuneCategoryType.health,
      name: '건강·라이프',
      icon: Icons.spa_rounded,
      color: Color(0xFF10B981),
    ),
    FilterCategory(
      type: FortuneCategoryType.traditional,
      name: '전통·사주',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFEF4444),
    ),
    FilterCategory(
      type: FortuneCategoryType.lifestyle,
      name: '생활·운세',
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF06B6D4),
    ),
    FilterCategory(
      type: FortuneCategoryType.interactive,
      name: '인터랙티브',
      icon: Icons.touch_app_rounded,
      color: Color(0xFF9333EA),
    ),
    FilterCategory(
      type: FortuneCategoryType.petFamily,
      name: '반려·육아',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFFE11D48),
    ),
  ];

  static const List<FortuneCategory> _categories = [
    // ==================== Time-based Fortunes (통합) ====================
    FortuneCategory(
      title: '시간별 운세',
      route: '/fortune/time',
      type: 'daily',
      icon: Icons.schedule_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
      description: '오늘/내일/주간/월간/연간 운세',
      category: 'lifestyle',
      isNew: true,
    ),
    
    // ==================== Batch Fortune (새로 추가) ====================
    FortuneCategory(
      title: '운세 패키지',
      route: '/fortune/batch',
      type: 'batch',
      icon: Icons.dashboard_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      description: '여러 운세를 한 번에 받기',
      category: 'lifestyle',
      isNew: true,
      isPremium: true,
    ),

    // ==================== Traditional Fortunes ====================
    FortuneCategory(
      title: '정통 사주',
      route: '/fortune/saju',
      type: 'saju',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFEC4899)],
      description: '사주팔자/운명/전생 종합',
      category: 'traditional',
      isPremium: true,
    ),
    FortuneCategory(
      title: '사주 차트 해석',
      route: '/fortune/saju-chart',
      type: 'saju',
      icon: Icons.insights_rounded,
      gradientColors: [Color(0xFF5E35B1), Color(0xFF4527A0)],
      description: '시각적 사주 분석',
      category: 'traditional',
      isNew: true,
    ),
    FortuneCategory(
      title: '토정비결',
      route: '/fortune/traditional?type=tojeong',
      type: 'traditional',
      icon: Icons.menu_book_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      description: '전통 토정비결',
      category: 'traditional',
      isPremium: true,
    ),
    FortuneCategory(
      title: '타로 카드',
      route: '/fortune/traditional?type=tarot',
      type: 'tarot',
      icon: Icons.style_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '타로카드 점술',
      category: 'traditional',
      isPremium: true,
    ),
    FortuneCategory(
      title: '꿈 해몽',
      route: '/fortune/traditional?type=dream',
      type: 'dream',
      icon: Icons.bedtime_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '꿈의 의미 해석',
      category: 'traditional',
    ),
    FortuneCategory(
      title: '관상',
      route: '/fortune/traditional?type=physiognomy',
      type: 'default',
      icon: Icons.face_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '얼굴로 보는 운세',
      category: 'traditional',
      isNew: true,
    ),
    FortuneCategory(
      title: '부적',
      route: '/fortune/traditional?type=talisman',
      type: 'default',
      icon: Icons.shield_rounded,
      gradientColors: [Color(0xFF8D6E63), Color(0xFF6D4C41)],
      description: '액운을 막는 부적',
      category: 'traditional',
    ),

    // ==================== Personal/Character-based Fortunes ====================
    FortuneCategory(
      title: '생일 운세',
      route: '/fortune/lifestyle?type=birthdate',
      type: 'daily',
      icon: Icons.cake_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      description: '생일 기반 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '별자리 운세',
      route: '/fortune/lifestyle?type=zodiac',
      type: 'zodiac',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      description: '서양 별자리 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '띠 운세',
      route: '/fortune/lifestyle?type=zodiac-animal',
      type: 'zodiac',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
      description: '12간지 띠 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: 'MBTI 운세',
      route: '/fortune/lifestyle?type=mbti',
      type: 'daily',
      icon: Icons.psychology_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
      description: 'MBTI 성격 기반 운세',
      category: 'lifestyle',
      isNew: true,
    ),
    FortuneCategory(
      title: '혈액형 운세',
      route: '/fortune/lifestyle?type=blood-type',
      type: 'daily',
      icon: Icons.water_drop_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFEF4444)],
      description: '혈액형별 성격과 운세',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '바이오리듬',
      route: '/fortune/lifestyle?type=biorhythm',
      type: 'biorhythm',
      icon: Icons.timeline_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      description: '신체, 감정, 지성 리듬 분석',
      category: 'health',
      isNew: true,
    ),

    // ==================== Relationship/Love Fortunes ====================
    FortuneCategory(
      title: '연애운',
      route: '/fortune/relationship?type=love',
      type: 'love',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '사랑과 연애의 운세',
      category: 'love',
    ),
    FortuneCategory(
      title: '결혼운',
      route: '/fortune/relationship?type=marriage',
      type: 'marriage',
      icon: Icons.favorite_border_rounded,
      gradientColors: [Color(0xFFDB2777), Color(0xFFBE185D)],
      description: '결혼과 배우자 운',
      category: 'love',
      isPremium: true,
    ),
    FortuneCategory(
      title: '궁합',
      route: '/fortune/relationship?type=compatibility',
      type: 'compatibility',
      icon: Icons.people_rounded,
      gradientColors: [Color(0xFFBE185D), Color(0xFF9333EA)],
      description: '두 사람의 궁합 보기',
      category: 'love',
    ),
    FortuneCategory(
      title: '소울메이트',
      route: '/fortune/relationship?type=soulmate',
      type: 'relationship',
      icon: Icons.connect_without_contact_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '운명의 짝 찾기',
      category: 'love',
      isNew: true,
    ),
    FortuneCategory(
      title: '피해야 할 사람',
      route: '/fortune/relationship?type=avoid-people',
      type: 'relationship',
      icon: Icons.person_off_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '오늘 피해야 할 사람의 특징',
      category: 'love',
      isNew: true,
    ),

    // ==================== Career/Work Fortunes (통합) ====================
    FortuneCategory(
      title: '커리어 운세',
      route: '/fortune/career',
      type: 'career',
      icon: Icons.work_rounded,
      gradientColors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      description: '취업/직업/사업/창업 종합',
      category: 'career',
      isNew: true,
    ),
    FortuneCategory(
      title: '시험 운세',
      route: '/fortune/career?type=exam',
      type: 'study',
      icon: Icons.school_rounded,
      gradientColors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
      description: '시험과 자격증 합격 운세',
      category: 'career',
    ),

    // ==================== Investment/Money Fortunes ====================
    FortuneCategory(
      title: '재물운',
      route: '/fortune/investment?type=wealth',
      type: 'money',
      icon: Icons.attach_money_rounded,
      gradientColors: [Color(0xFF16A34A), Color(0xFF15803D)],
      description: '금전운과 재물운',
      category: 'money',
    ),
    FortuneCategory(
      title: '부동산운',
      route: '/fortune/investment?type=realestate',
      type: 'investment',
      icon: Icons.home_rounded,
      gradientColors: [Color(0xFF059669), Color(0xFF047857)],
      description: '부동산 투자 운세',
      category: 'money',
      isPremium: true,
    ),
    FortuneCategory(
      title: '주식 운세',
      route: '/fortune/investment?type=stock',
      type: 'investment',
      icon: Icons.trending_up_rounded,
      gradientColors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
      description: '오늘의 주식 투자 운세',
      category: 'money',
      isPremium: true,
    ),
    FortuneCategory(
      title: '암호화폐 운세',
      route: '/fortune/investment?type=crypto',
      type: 'investment',
      icon: Icons.currency_bitcoin_rounded,
      gradientColors: [Color(0xFFFF6F00), Color(0xFFE65100)],
      description: '암호화폐 투자 운세',
      category: 'money',
      isPremium: true,
    ),
    FortuneCategory(
      title: '로또 운세',
      route: '/fortune/investment?type=lottery',
      type: 'lottery',
      icon: Icons.confirmation_number_rounded,
      gradientColors: [Color(0xFFFFB300), Color(0xFFF57C00)],
      description: '행운의 로또 번호',
      category: 'money',
      isNew: true,
    ),

    // ==================== Lifestyle/Lucky Items ====================
    FortuneCategory(
      title: '행운의 색깔',
      route: '/fortune/lifestyle?type=lucky-color',
      type: 'color',
      icon: Icons.palette_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '오늘의 행운 색상',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '행운의 숫자',
      route: '/fortune/lifestyle?type=lucky-number',
      type: 'daily',
      icon: Icons.looks_one_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '행운을 부르는 숫자',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '행운의 음식',
      route: '/fortune/lifestyle?type=lucky-food',
      type: 'daily',
      icon: Icons.restaurant_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      description: '운을 높이는 음식',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '행운의 아이템',
      route: '/fortune/lifestyle?type=lucky-items',
      type: 'daily',
      icon: Icons.diamond_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      description: '행운을 부르는 물건',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '재능 발견',
      route: '/fortune/lifestyle?type=talent',
      type: 'daily',
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
      description: '숨겨진 재능 발견',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '소원 성취',
      route: '/fortune/lifestyle?type=wish',
      type: 'daily',
      icon: Icons.star_rounded,
      gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
      description: '소원 성취 가능성',
      category: 'lifestyle',
    ),
    FortuneCategory(
      title: '인생 타임라인',
      route: '/fortune/lifestyle?type=timeline',
      type: 'daily',
      icon: Icons.timeline_rounded,
      gradientColors: [Color(0xFF00897B), Color(0xFF00695C)],
      description: '인생의 중요한 시점들',
      category: 'lifestyle',
      isPremium: true,
    ),

    // ==================== Sports Fortunes (통합) ====================
    FortuneCategory(
      title: '스포츠 운세',
      route: '/fortune/sports',
      type: 'health',
      icon: Icons.sports_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '골프/테니스/런닝/낚시 등',
      category: 'health',
      isNew: true,
    ),

    // ==================== Health/Fitness Fortunes ====================
    FortuneCategory(
      title: '요가 운세',
      route: '/fortune/lifestyle?type=yoga',
      type: 'health',
      icon: Icons.self_improvement_rounded,
      gradientColors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      description: '요가 수행 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '피트니스 운세',
      route: '/fortune/lifestyle?type=fitness',
      type: 'health',
      icon: Icons.fitness_center_rounded,
      gradientColors: [Color(0xFFE91E63), Color(0xFFC2185B)],
      description: '운동 효과 운세',
      category: 'health',
    ),
    FortuneCategory(
      title: '건강운',
      route: '/fortune/lifestyle?type=health',
      type: 'health',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '오늘의 건강 상태',
      category: 'health',
    ),
    FortuneCategory(
      title: '이사운',
      route: '/fortune/lifestyle?type=moving',
      type: 'daily',
      icon: Icons.home_work_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '이사 길일과 방향',
      category: 'lifestyle',
    ),

    // ==================== Interactive Fortunes ====================
    FortuneCategory(
      title: '포춘 쿠키',
      route: '/fortune/interactive?type=fortune-cookie',
      type: 'daily',
      icon: Icons.cookie_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '오늘의 행운 메시지',
      category: 'interactive',
      isNew: true,
    ),
    FortuneCategory(
      title: '같은 생일 연예인',
      route: '/fortune/same-birthday-celebrity',
      type: 'celebrity',
      icon: Icons.cake_outlined,
      gradientColors: [Color(0xFFFF1744), Color(0xFFE91E63)],
      description: '나와 생일이 같은 연예인 운세',
      category: 'interactive',
      isNew: true,
    ),
    
    // ==================== AI/Smart Fortunes (새로 추가) ====================
    FortuneCategory(
      title: 'AI 종합 운세',
      route: '/fortune/ai-comprehensive',
      type: 'ai',
      icon: Icons.psychology_alt_rounded,
      gradientColors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      description: '모든 데이터를 분석한 AI 운세',
      category: 'lifestyle',
      isNew: true,
      isPremium: true,
    ),
    FortuneCategory(
      title: '운세 히스토리',
      route: '/fortune/history',
      type: 'history',
      icon: Icons.history_rounded,
      gradientColors: [Color(0xFF795548), Color(0xFF5D4037)],
      description: '과거 운세 기록 및 통계',
      category: 'lifestyle',
      isNew: true,
    ),

    // ==================== Pet & Family Fortunes ====================
    FortuneCategory(
      title: '반려동물 운세',
      route: '/fortune/pet',
      type: 'pet',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFFE11D48), Color(0xFFBE123C)],
      description: '반려동물과의 교감과 건강',
      category: 'petFamily',
      isNew: true,
    ),
    FortuneCategory(
      title: '반려견 운세',
      route: '/fortune/pet?type=dog',
      type: 'pet',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
      description: '강아지와의 특별한 하루',
      category: 'petFamily',
    ),
    FortuneCategory(
      title: '반려묘 운세',
      route: '/fortune/pet?type=cat',
      type: 'pet',
      icon: Icons.pets_rounded,
      gradientColors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
      description: '고양이와의 행복한 일상',
      category: 'petFamily',
    ),
    FortuneCategory(
      title: '반려동물 궁합',
      route: '/fortune/pet-compatibility',
      type: 'pet',
      icon: Icons.favorite_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      description: '나와 반려동물의 궁합',
      category: 'petFamily',
      isPremium: true,
    ),
    FortuneCategory(
      title: '자녀 운세',
      route: '/fortune/children',
      type: 'children',
      icon: Icons.child_care_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      description: '우리 아이의 운세와 성장',
      category: 'petFamily',
      isNew: true,
    ),
    FortuneCategory(
      title: '육아 운세',
      route: '/fortune/parenting',
      type: 'parenting',
      icon: Icons.family_restroom_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      description: '오늘의 육아 조언',
      category: 'petFamily',
    ),
    FortuneCategory(
      title: '태교 운세',
      route: '/fortune/pregnancy',
      type: 'pregnancy',
      icon: Icons.pregnant_woman_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      description: '예비 엄마를 위한 태교 가이드',
      category: 'petFamily',
      isPremium: true,
    ),
    FortuneCategory(
      title: '가족 화합 운세',
      route: '/fortune/family-harmony',
      type: 'family',
      icon: Icons.home_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      description: '가족 간의 조화와 행복',
      category: 'petFamily',
    ),
  ];

  List<FortuneCategory> _filterCategories(String searchQuery, FortuneCategoryType selectedType) {
    var filtered = _categories;
    
    // Apply category filter
    if (selectedType != FortuneCategoryType.all) {
      filtered = filtered.where((category) {
        return category.category == selectedType.name;
      }).toList();
    }
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               category.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchQuery = ref.watch(_searchQueryProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final viewMode = ref.watch(_viewModeProvider);
    final filteredCategories = _filterCategories(searchQuery, selectedCategory);

    return Scaffold(
      appBar: const AppHeader(
        showBackButton: false,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCategoryFilter(context, ref),
                  const SizedBox(height: 12),
                  _buildSearchBar(context, ref),
                ],
              ),
            ),
          ),
          // Banner Ad for non-premium users
          if (Environment.enableAds && !(ref.watch(userProfileProvider).value?.isPremiumActive ?? false))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CommonAdPlacements.listBottomAd(),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (selectedCategory != FortuneCategoryType.all)
                    TextButton(
                      onPressed: () {
                        ref.read(_selectedCategoryProvider.notifier).state = FortuneCategoryType.all;
                      },
                      child: const Text('전체 보기'),
                    )
                  else
                    const SizedBox.shrink(),
                  _buildViewModeToggle(context, ref),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = filteredCategories[index];
                  final isLastItem = index == filteredCategories.length - 1;
                  
                  return Column(
                    children: [
                      viewMode == ViewMode.trend
                          ? (category.type == 'tarot'
                              ? TarotFortuneListCard(
                                  title: category.title,
                                  description: category.description,
                                  onTap: () {
                                    // Navigate directly to enhanced tarot page with hero animation
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TarotEnhancedPage(
                                          heroTag: 'tarot-hero-${category.route}',
                                        ),
                                      ),
                                    );
                                  },
                                  isPremium: category.isPremium,
                                  soulCost: category.soulCost,
                                  route: category.route,
                                )
                              : FortuneListCard(
                                  category: category,
                                  thumbnailKey: _getThumbnailKey(category.route),
                                  onTap: () {
                              // Extract fortune type from route or use the type field
                              String fortuneType = category.type;
                              
                              // Handle special routes with query parameters
                              if (category.route.contains('?type=')) {
                                final queryPart = category.route.split('?type=').last;
                                fortuneType = queryPart;
                              } else if (category.route.contains('/fortune/')) {
                                // For simple routes like '/fortune/daily'
                                final segments = category.route.split('/');
                                if (segments.length > 2) {
                                  fortuneType = segments[2];
                                }
                              }
                              
                              print('[FortuneListPage] Tapped fortune: ${category.title}');
                              print('[FortuneListPage] Route: ${category.route}');
                              print('[FortuneListPage] Type: $fortuneType');
                              
                              // Get thumbnail image path and show animation
                              final thumbnailPath = FortuneCardImages.getRandomThumbnail(category.type);
                              final thumbnailKey = _getThumbnailKey(category.route);
                              
                              // Show animated thumbnail
                              _showAnimatedThumbnail(context, thumbnailKey, thumbnailPath, () {
                                // Callback when animation is dismissed
                              });
                              
                              // Show bottom sheet
                              SimpleFortunInfoSheet.show(
                                context,
                                fortuneType: fortuneType,
                                onDismiss: () {
                                  // Call the dismiss callback to remove the overlay
                                  _currentDismissCallback?.call();
                                },
                                onFortuneButtonPressed: () {
                                  print('[FortuneListPage] Fortune button pressed, navigating to AdLoadingScreen');
                                  
                                  // Navigate directly to AdLoadingScreen instead of fortune page
                                  final isPremium = ref.read(hasUnlimitedAccessProvider);
                                  
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AdLoadingScreen(
                                        fortuneType: fortuneType,
                                        fortuneTitle: category.title,
                                        fortuneRoute: category.route,
                                        isPremium: isPremium,
                                        onComplete: () {
                                          // This won't be called since we're using fortuneRoute
                                        },
                                        onSkip: () {
                                          // Navigate to premium page or handle skip
                                          context.push('/subscription');
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ))
                          : FortuneListTile(
                              category: category,
                              onTap: () {
                                // Handle tarot specially
                                if (category.type == 'tarot') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TarotEnhancedPage(
                                        heroTag: 'tarot-hero-${category.route}',
                                      ),
                                    ),
                                  );
                                } else {
                                  // Same logic as FortuneListCard
                                  String fortuneType = category.type;
                                  
                                  if (category.route.contains('?type=')) {
                                    final queryPart = category.route.split('?type=').last;
                                    fortuneType = queryPart;
                                  } else if (category.route.contains('/fortune/')) {
                                    final segments = category.route.split('/');
                                    if (segments.length > 2) {
                                      fortuneType = segments[2];
                                    }
                                  }
                                  
                                  // Get thumbnail image path and show animation
                                  final thumbnailPath = FortuneCardImages.getRandomThumbnail(category.type);
                                  final thumbnailKey = _getThumbnailKey(category.route);
                                  
                                  // For list view, we don't have a thumbnail key in the card, so create a temporary one
                                  final tempKey = GlobalKey();
                                  
                                  SimpleFortunInfoSheet.show(
                                    context,
                                    fortuneType: fortuneType,
                                    onDismiss: () {
                                      // No overlay to dismiss in list view
                                    },
                                    onFortuneButtonPressed: () {
                                      final isPremium = ref.read(hasUnlimitedAccessProvider);
                                      
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AdLoadingScreen(
                                            fortuneType: fortuneType,
                                            fortuneTitle: category.title,
                                            fortuneRoute: category.route,
                                            isPremium: isPremium,
                                            onComplete: () {},
                                            onSkip: () {
                                              context.push('/subscription');
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                      if (!isLastItem && viewMode == ViewMode.list) 
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                    ],
                  );
                },
                childCount: filteredCategories.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      child: TextField(
        onChanged: (value) {
          ref.read(_searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: '운세 검색...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewMode = ref.watch(_viewModeProvider);
    
    return GestureDetector(
      onTap: () {
        // Toggle between grid and list view
        if (viewMode == ViewMode.trend) {
          ref.read(_viewModeProvider.notifier).state = ViewMode.list;
        } else {
          ref.read(_viewModeProvider.notifier).state = ViewMode.trend;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sliding indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: viewMode == ViewMode.trend ? 2 : 42,
              top: 2,
              child: Container(
                width: 36,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            // Icons
            Row(
              children: [
                Expanded(
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: viewMode == ViewMode.trend
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: Icon(
                    Icons.list_rounded,
                    size: 20,
                    color: viewMode == ViewMode.list
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = selectedCategory == filter.type;
          
          return GestureDetector(
            onTap: () {
              ref.read(_selectedCategoryProvider.notifier).state = filter.type;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [filter.color, filter.color.withValues(alpha: 0.8)],
                      )
                    : null,
                color: isSelected ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter.icon,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _selectedCategoryProvider = StateProvider<FortuneCategoryType>((ref) => FortuneCategoryType.all);
final _viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.trend);