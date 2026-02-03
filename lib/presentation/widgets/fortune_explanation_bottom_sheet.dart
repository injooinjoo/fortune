import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/providers.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'ads/interstitial_ad_helper.dart';
import '../../core/utils/logger.dart';
import '../../core/theme/fortune_design_system.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/date_picker/numeric_date_input.dart';

class FortuneExplanationBottomSheet extends ConsumerStatefulWidget {
  final String fortuneType;
  final Map<String, dynamic>? fortuneData;
  final VoidCallback? onFortuneButtonPressed;

  const FortuneExplanationBottomSheet({
    super.key,
    required this.fortuneType,
    this.fortuneData,
    this.onFortuneButtonPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String fortuneType,
    Map<String, dynamic>? fortuneData,
    VoidCallback? onFortuneButtonPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: TossDesignSystem.black.withValues(alpha: 0.0),
      barrierColor: DSColors.overlay,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => FortuneExplanationBottomSheet(
        fortuneType: fortuneType,
        fortuneData: fortuneData,
        onFortuneButtonPressed: onFortuneButtonPressed,
      ),
    );
  }

  @override
  ConsumerState<FortuneExplanationBottomSheet> createState() =>
      _FortuneExplanationBottomSheetState();
}

class _FortuneExplanationBottomSheetState
    extends ConsumerState<FortuneExplanationBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  // Form controllers for fortune settings
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedMbti;
  String? _selectedBloodType;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationMedium,
    );
    _animationController.forward();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile != null) {
      _nameController.text = profile.name;
      _selectedDate = profile.birthDate;
      _selectedGender = profile.gender.value;
      _selectedMbti = profile.mbtiType;
      _checkFormValidity();
    }
  }

  void _checkFormValidity() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _selectedDate != null &&
          _selectedGender != null;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark100
                : TossDesignSystem.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(theme),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFortuneTypeSection(theme),
                      const SizedBox(height: 24),
                      _buildFortuneSettingsSection(theme),
                      const SizedBox(height: 24),
                      _buildScoreGuideSection(theme),
                      const SizedBox(height: 24),
                      _buildCustomFortuneSection(theme),
                      const SizedBox(height: 100), // Extra space for button
                    ],
                  ),
                ),
              ),
              _buildBottomButton(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark300
            : TossDesignSystem.gray300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final fortuneName = _getFortuneTypeName(widget.fortuneType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.1),
            theme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFortuneIcon(widget.fortuneType),
                size: 32,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fortuneName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      _getFortuneDescription(widget.fortuneType),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? TossDesignSystem.grayDark600
                            : TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getDetailedDescription(widget.fortuneType),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTypeSection(ThemeData theme) {
    final recommendations = _getRecommendations(widget.fortuneType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이런 분께 추천해요',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildFortuneSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정확한 운세를 위한 정보 입력',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Name input
        TextField(
          controller: _nameController,
          onChanged: (_) => _checkFormValidity(),
          decoration: InputDecoration(
            labelText: '이름',
            hintText: '운세에 사용할 이름을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),

        const SizedBox(height: 16),

        // Birth date
        NumericDateInput(
          label: '생년월일',
          selectedDate: _selectedDate,
          onDateChanged: (date) {
            setState(() => _selectedDate = date);
            _checkFormValidity();
          },
          minDate: DateTime(1900),
          maxDate: DateTime.now(),
          showAge: true,
        ),

        const SizedBox(height: 16),

        // Gender selection
        Text(
          '성별',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: '남성',
                isSelected: _selectedGender == 'male',
                onTap: () {
                  setState(() {
                    _selectedGender = 'male';
                  });
                  _checkFormValidity();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceChip(
                label: '여성',
                isSelected: _selectedGender == 'female',
                onTap: () {
                  setState(() {
                    _selectedGender = 'female';
                  });
                  _checkFormValidity();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // MBTI selection (optional)
        Text(
          'MBTI (선택사항)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'INTJ',
            'INTP',
            'ENTJ',
            'ENTP',
            'INFJ',
            'INFP',
            'ENFJ',
            'ENFP',
            'ISTJ',
            'ISFJ',
            'ESTJ',
            'ESFJ',
            'ISTP',
            'ISFP',
            'ESTP',
            'ESFP'
          ]
              .map((mbti) => _buildChoiceChip(
                    label: mbti,
                    isSelected: _selectedMbti == mbti,
                    onTap: () {
                      setState(() {
                        _selectedMbti = _selectedMbti == mbti ? null : mbti;
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : (Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark100
                  : TossDesignSystem.gray100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : (Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark300
                    : TossDesignSystem.gray300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? TossDesignSystem.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark900
                    : TossDesignSystem.black),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreGuideSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운세 점수 가이드',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark50.withValues(alpha: 0.5)
                : TossDesignSystem.tossBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark200
                  : TossDesignSystem.tossBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              _buildScoreRow('90-100점', '최고운', TossDesignSystem.errorRed),
              _buildScoreRow('80-89점', '대길', TossDesignSystem.warningOrange),
              _buildScoreRow('70-79점', '길', TossDesignSystem.warningYellow),
              _buildScoreRow('60-69점', '평', TossDesignSystem.successGreen),
              _buildScoreRow('50-59점', '하', TossDesignSystem.tossBlue),
              _buildScoreRow('~49점', '흉', TossDesignSystem.gray500),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String score, String meaning, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$score - $meaning',
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFortuneSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '맞춤 운세 서비스',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      TossDesignSystem.grayDark100.withValues(alpha: 0.8),
                      TossDesignSystem.grayDark50.withValues(alpha: 0.8),
                    ]
                  : [
                      TossDesignSystem.purple.withValues(alpha: 0.1),
                      TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.purple.withValues(alpha: 0.7)
                        : TossDesignSystem.purple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '신령이 점지하는 개인 맞춤 운세',
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? TossDesignSystem.purple.withValues(alpha: 0.7)
                          : TossDesignSystem.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• 개인 정보를 바탕으로 한 정확한 운세 분석\n'
                '• 매일 업데이트되는 실시간 운세\n'
                '• 상세한 운세 해석과 조언 제공\n'
                '• 다양한 운세 카테고리별 상세 분석',
                style: context.bodySmall.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.white,
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark900
                    : TossDesignSystem.black)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isFormValid
                ? () async {
                    Navigator.of(context).pop();

                    // Collect form data
                    final fortuneParams = {
                      'name': _nameController.text,
                      'birthDate': _selectedDate?.toIso8601String(),
                      'gender': _selectedGender,
                      'mbtiType': _selectedMbti,
                      'bloodType': _selectedBloodType,
                    };

                    final fortuneRoute = _getFortuneRoute(widget.fortuneType);

                    // Premium/Frequency 체크 및 광고 표시 (Helper가 처리)
                    await InterstitialAdHelper.showInterstitialAdWithCallback(
                      ref,
                      onAdCompleted: () async {
                        Logger.debug(
                            '📺 [FortuneExplanationBottomSheet] Ad completed or skipped, navigating');
                        if (context.mounted)
                          context.go(fortuneRoute, extra: fortuneParams);
                      },
                      onAdFailed: () async {
                        Logger.debug(
                            '📺 [FortuneExplanationBottomSheet] Ad failed, navigating anyway');
                        if (context.mounted)
                          context.go(fortuneRoute, extra: fortuneParams);
                      },
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: TossDesignSystem.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getFortuneIcon(widget.fortuneType)),
                const SizedBox(width: 8),
                Text(
                  '${_getFortuneTypeName(widget.fortuneType)} 보기',
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFortuneTypeName(String fortuneType) {
    const names = {
      'today': '오늘의 운세',
      'love': '연애운',
      'career': '직업운',
      'money': '재물운',
      'health': '건강운',
      'tarot': '타로',
      'saju': '사주',
      'dream': '꿈해몽',
      'compatibility': '궁합',
      'lucky-number': '행운의 숫자',
      'lucky-color': '행운의 색깔',
      'zodiac': '별자리',
      'palmistry': '손금',
      'naming': '작명',
      'moving': '이사',
      'investment': '투자운',
    };
    return names[fortuneType] ?? '운세';
  }

  String _getFortuneDescription(String fortuneType) {
    const descriptions = {
      'today': '오늘 하루의 전반적인 운세를 확인하세요',
      'love': '사랑과 연애에 관한 운세',
      'career': '직업과 사업에 관한 운세',
      'money': '재물과 금전에 관한 운세',
      'health': '건강과 몸의 상태에 관한 운세',
      'tarot': '타로카드로 보는 운세',
      'saju': '사주팔자로 보는 운세',
      'dream': '꿈의 의미를 해석해드립니다',
      'compatibility': '상대방과의 궁합을 확인하세요',
      'lucky-number': '오늘의 행운의 숫자',
      'lucky-color': '오늘의 행운의 색깔',
      'zodiac': '별자리별 운세',
      'palmistry': '손금으로 보는 운세',
      'naming': '이름의 의미와 운세',
      'moving': '이사와 방향에 관한 운세',
      'investment': '투자와 재테크 운세',
    };
    return descriptions[fortuneType] ?? '당신의 운세를 확인해보세요';
  }

  String _getDetailedDescription(String fortuneType) {
    const detailed = {
      'today': '매일 변화하는 운세의 흐름을 파악하여 하루를 더욱 의미있게 보낼 수 있도록 도와드립니다.',
      'love': '현재의 연애 상황부터 미래의 만남까지, 사랑에 관한 모든 것을 알려드립니다.',
      'career': '직장 생활, 사업, 취업 등 일과 관련된 모든 운세를 확인하실 수 있습니다.',
      'money': '재물운, 투자운, 소비 패턴 등 금전과 관련된 운세를 상세히 분석해드립니다.',
      'health': '몸의 건강 상태와 주의해야 할 점들을 운세를 통해 알려드립니다.',
    };
    return detailed[fortuneType] ?? '정확하고 상세한 운세 분석을 제공합니다.';
  }

  List<String> _getRecommendations(String fortuneType) {
    const recommendations = {
      'today': [
        '매일 새로운 시작을 원하는 분',
        '하루 일정을 계획적으로 보내고 싶은 분',
        '작은 변화라도 긍정적으로 받아들이고 싶은 분'
      ],
      'love': ['새로운 만남을 기대하는 분', '연애 관계에서 고민이 있는 분', '결혼을 앞두고 있는 분'],
      'career': ['직장에서 승진을 원하는 분', '이직을 고려하고 있는 분', '새로운 사업을 시작하려는 분'],
      'money': ['재정 관리에 관심이 있는 분', '투자를 고려하고 있는 분', '경제적 안정을 원하는 분'],
    };
    return recommendations[fortuneType] ??
        ['운세에 관심이 있는 모든 분', '미래에 대한 조언이 필요한 분', '긍정적인 에너지를 얻고 싶은 분'];
  }

  String _getFortuneRoute(String fortuneType) {
    const routes = {
      'hourly': '/daily-calendar',
      'today': '/daily-calendar',
      'daily': '/daily-calendar',
      'tomorrow': '/daily-calendar',
      'weekly': '/daily-calendar',
      'monthly': '/daily-calendar',
      'yearly': '/yearly',
      'love': '/love',
      'career': '/career',
      'money': '/investment',
      'health': '/health-toss',
      'tarot': '/tarot',
      'saju': '/traditional-saju',
      'dream': '/interactive/dream',
      'compatibility': '/compatibility',
      'lucky-number': '/lucky-items',
      'lucky-color': '/lucky-items',
      'zodiac': '/daily-calendar',
      'palmistry': '/traditional',
      'naming': '/naming',
      'moving': '/moving',
      'investment': '/investment',
    };
    return routes[fortuneType] ?? '/fortune';
  }

  IconData _getFortuneIcon(String fortuneType) {
    const icons = {
      'today': Icons.today,
      'love': Icons.favorite,
      'career': Icons.work,
      'money': Icons.monetization_on,
      'health': Icons.health_and_safety,
      'tarot': Icons.style,
      'saju': Icons.account_balance,
      'dream': Icons.bedtime,
      'compatibility': Icons.favorite_border,
      'lucky-number': Icons.casino,
      'lucky-color': Icons.palette,
      'zodiac': Icons.star,
      'palmistry': Icons.back_hand,
      'naming': Icons.text_fields,
      'moving': Icons.home,
      'investment': Icons.trending_up,
    };
    return icons[fortuneType] ?? Icons.auto_awesome;
  }
}
