import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../domain/models/conditions/lucky_items_fortune_conditions.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../../../../presentation/providers/ad_provider.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../presentation/providers/subscription_provider.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../core/widgets/accordion_input_section.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import 'widgets/widgets.dart';

/// 행운 아이템 페이지
///
/// 로또 번호, 오늘의 색상, 쇼핑, 게임, 음식, 여행, 건강, 패션, 라이프스타일 등
/// 9개 카테고리의 행운 정보를 제공합니다.
class LuckyItemsPage extends ConsumerStatefulWidget {
  const LuckyItemsPage({super.key});

  @override
  ConsumerState<LuckyItemsPage> createState() => _LuckyItemsPageState();
}

class _LuckyItemsPageState extends ConsumerState<LuckyItemsPage> {
  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ✅ 입력 폼 상태
  DateTime? _selectedBirthDate;
  String? _selectedBirthTime;
  String? _selectedGender;
  final List<String> _selectedInterests = [];
  List<AccordionInputSection> _sections = [];
  bool _isGenerating = false; // 운세 생성 중 플래그
  bool _hasUserUnlockedBlur = false; // 사용자가 광고를 보고 블러를 해제했는지 여부

  @override
  void initState() {
    super.initState();
    _initializeSections();
    _loadUserProfile();
  }

  // 9개 메인 카테고리 - ChatGPT 미니멀 스타일 (Material Icons)
  static const List<CategoryModel> _categories = [
    CategoryModel(
      id: 'lotto',
      title: '로또/복권',
      icon: Icons.casino_outlined,
      description: '행운의 번호와 구매 장소',
    ),
    CategoryModel(
      id: 'shopping',
      title: '쇼핑/구매',
      icon: Icons.shopping_bag_outlined,
      description: '쇼핑 운과 구매 타이밍',
    ),
    CategoryModel(
      id: 'game',
      title: '게임/엔터',
      icon: Icons.videogame_asset_outlined,
      description: '게임과 엔터테인먼트',
    ),
    CategoryModel(
      id: 'food',
      title: '음식/맛집',
      icon: Icons.restaurant_outlined,
      description: '행운의 음식과 맛집',
    ),
    CategoryModel(
      id: 'travel',
      title: '여행/장소',
      icon: Icons.flight_outlined,
      description: '행운의 장소와 여행지',
    ),
    CategoryModel(
      id: 'health',
      title: '운동/건강',
      icon: Icons.fitness_center_outlined,
      description: '건강 운과 운동 가이드',
    ),
    CategoryModel(
      id: 'fashion',
      title: '패션/뷰티',
      icon: Icons.checkroom_outlined,
      description: '오늘의 스타일링',
    ),
    CategoryModel(
      id: 'lifestyle',
      title: '라이프',
      icon: Icons.auto_awesome_outlined,
      description: '일상 속 행운 가이드',
    ),
    CategoryModel(
      id: 'today_color',
      title: '오늘의 색상',
      icon: Icons.palette_outlined,
      description: '행운을 부르는 오늘의 컬러',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'lucky_items',
      title: '행운아이템',
      description: '로또번호부터 오늘의 색상까지',
      inputBuilder: _buildInput,
      conditionsBuilder: _buildConditions,
      resultBuilder: _buildResult,
      dataSource: FortuneDataSource.api,
      enableOptimization: true, // ✅ 최적화 활성화 (블러 처리 포함)
    );
  }

  /// 섹션 초기화
  void _initializeSections() {
    _sections = [
      AccordionInputSection(
        id: 'birthDate',
        title: '생년월일',
        icon: Icons.cake,
        inputWidgetBuilder: (context, onValueChanged) => _buildDatePicker(onValueChanged),
      ),
      AccordionInputSection(
        id: 'birthTime',
        title: '태어난 시간',
        icon: Icons.access_time,
        inputWidgetBuilder: (context, onValueChanged) => _buildTimePicker(onValueChanged),
      ),
      AccordionInputSection(
        id: 'gender',
        title: '성별',
        icon: Icons.person,
        inputWidgetBuilder: (context, onValueChanged) => _buildGenderSelect(onValueChanged),
      ),
      AccordionInputSection(
        id: 'interests',
        title: '관심사',
        icon: Icons.favorite,
        inputWidgetBuilder: (context, onValueChanged) => _buildInterestsSelect(onValueChanged),
        isMultiSelect: true,
      ),
    ];
  }

  /// 사용자 프로필 로드 및 자동 채우기
  void _loadUserProfile() {
    final profile = ref.read(userProfileProvider).value;
    if (profile != null) {
      setState(() {
        if (profile.birthDate != null) {
          _selectedBirthDate = profile.birthDate;
          final birthDateIndex = _sections.indexWhere((s) => s.id == 'birthDate');
          if (birthDateIndex != -1) {
            _sections[birthDateIndex].isCompleted = true;
            _sections[birthDateIndex].value = profile.birthDate;
            _sections[birthDateIndex].displayValue = '생년월일: ${profile.birthDate!.year}.${profile.birthDate!.month}.${profile.birthDate!.day}';
          }
        }

        if (profile.birthTime != null) {
          _selectedBirthTime = profile.birthTime;
          final birthTimeIndex = _sections.indexWhere((s) => s.id == 'birthTime');
          if (birthTimeIndex != -1) {
            _sections[birthTimeIndex].isCompleted = true;
            _sections[birthTimeIndex].value = profile.birthTime;
            _sections[birthTimeIndex].displayValue = '태어난 시간: ${profile.birthTime}';
          }
        }

        if (profile.gender != null) {
          _selectedGender = profile.gender;
          final genderIndex = _sections.indexWhere((s) => s.id == 'gender');
          if (genderIndex != -1) {
            _sections[genderIndex].isCompleted = true;
            _sections[genderIndex].value = profile.gender;
            _sections[genderIndex].displayValue = '성별: ${profile.gender == "male" ? "남성" : "여성"}';
          }
        }
      });
    }
  }

  /// 모든 필수 항목이 입력되었는지 확인
  bool _canGenerate() {
    return _selectedBirthDate != null && _selectedGender != null;
  }

  /// 입력 화면 (헤더 카드 + 아코디언)
  Widget _buildInput(BuildContext context, VoidCallback onSubmit) {
    return Stack(
      children: [
        // ✅ AccordionInputForm이 자체 스크롤 가능하므로 SingleChildScrollView 제거
        AccordionInputForm(
          sections: _sections,
          header: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // 금색 그라디언트
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    '행운 아이템',
                    style: DSTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '로또번호부터 오늘의 색상까지\n당신의 행운을 찾아보세요',
                    style: DSTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ✅ UnifiedButton.floating (로딩 상태 관리)
        if (_canGenerate())
          UnifiedButton.floating(
            text: '🍀 행운 아이템 확인하기',
            onPressed: _canGenerate() && !_isGenerating ? () async {
              // 로딩 상태 시작
              setState(() {
                _isGenerating = true;
              });

              // 실제 운세 생성 호출
              onSubmit();

              // 2초 후 로딩 해제 (운세 생성이 완료되면 자동으로 결과 화면으로 전환됨)
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _isGenerating = false;
                  });
                }
              });
            } : null,
            isEnabled: _canGenerate() && !_isGenerating,
            showProgress: _isGenerating,
            isLoading: _isGenerating,
          ),
      ],
    );
  }

  /// 생년월일 선택기
  Widget _buildDatePicker(Function(dynamic) onValueChanged) {
    return NumericDateInput(
      label: '생년월일',
      selectedDate: _selectedBirthDate,
      onDateChanged: (date) {
        setState(() {
          _selectedBirthDate = date;
          final index = _sections.indexWhere((s) => s.id == 'birthDate');
          if (index != -1) {
            _sections[index] = _sections[index].copyWith(
              isCompleted: true,
              value: date,
              displayValue: '생년월일: ${date.year}.${date.month}.${date.day}',
            );
          }
        });
        onValueChanged(date);
      },
      minDate: DateTime(1900),
      maxDate: DateTime.now(),
      showAge: true,
    );
  }

  /// 태어난 시간 선택기
  Widget _buildTimePicker(Function(dynamic) onValueChanged) {
    final times = ['자시 (23:00-01:00)', '축시 (01:00-03:00)', '인시 (03:00-05:00)', '묘시 (05:00-07:00)',
                   '진시 (07:00-09:00)', '사시 (09:00-11:00)', '오시 (11:00-13:00)', '미시 (13:00-15:00)',
                   '신시 (15:00-17:00)', '유시 (17:00-19:00)', '술시 (19:00-21:00)', '해시 (21:00-23:00)'];

    return Column(
      children: times.map((time) {
        return RadioListTile<String>(
          title: Text(time),
          value: time,
          groupValue: _selectedBirthTime,
          onChanged: (value) {
            setState(() {
              _selectedBirthTime = value;
              final index = _sections.indexWhere((s) => s.id == 'birthTime');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: true,
                  value: value,
                  displayValue: '태어난 시간: $value',
                );
              }
            });
            onValueChanged(value);
          },
        );
      }).toList(),
    );
  }

  /// 성별 선택기
  Widget _buildGenderSelect(Function(dynamic) onValueChanged) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('남성'),
          value: 'male',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
              final index = _sections.indexWhere((s) => s.id == 'gender');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: true,
                  value: value,
                  displayValue: '성별: 남성',
                );
              }
            });
            onValueChanged(value);
          },
        ),
        RadioListTile<String>(
          title: const Text('여성'),
          value: 'female',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
              final index = _sections.indexWhere((s) => s.id == 'gender');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: true,
                  value: value,
                  displayValue: '성별: 여성',
                );
              }
            });
            onValueChanged(value);
          },
        ),
      ],
    );
  }

  /// 관심사 선택기 (다중 선택)
  Widget _buildInterestsSelect(Function(dynamic) onValueChanged) {
    final interests = ['로또/복권', '쇼핑/구매', '게임/엔터', '음식/맛집', '여행/장소', '운동/건강', '패션/뷰티', '라이프스타일'];

    return Column(
      children: interests.map((interest) {
        return CheckboxListTile(
          title: Text(interest),
          value: _selectedInterests.contains(interest),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedInterests.add(interest);
              } else {
                _selectedInterests.remove(interest);
              }

              final index = _sections.indexWhere((s) => s.id == 'interests');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: _selectedInterests.isNotEmpty,
                  value: _selectedInterests,
                  displayValue: _selectedInterests.isEmpty
                      ? '관심사'
                      : '관심사: ${_selectedInterests.join(", ")}',
                );
              }
            });
            onValueChanged(_selectedInterests);
          },
        );
      }).toList(),
    );
  }

  /// Conditions 생성
  Future<LuckyItemsFortuneConditions> _buildConditions() async {
    return LuckyItemsFortuneConditions(
      birthDate: _selectedBirthDate ?? DateTime.now(),
      birthTime: _selectedBirthTime,
      gender: _selectedGender,
      interests: _selectedInterests.isNotEmpty ? _selectedInterests : null,
    );
  }

  /// 결과 화면 (원페이지 스크롤 + 블러 적용)
  Widget _buildResult(BuildContext context, FortuneResult result) {
    // ✅ 사용자가 블러를 해제하지 않았을 때만 result.isBlurred와 동기화
    if (!_hasUserUnlockedBlur && (_isBlurred != result.isBlurred || _blurredSections.length != result.blurredSections.length)) {
      // 즉시 상태 업데이트
      _isBlurred = result.isBlurred;
      _blurredSections = List<String>.from(result.blurredSections);

      // ✅ 결과 최초 표시 시 햅틱 피드백
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      });

      Logger.debug('[LuckyItems] 🔒 블러 상태 동기화 (최초): $_isBlurred');
      Logger.debug('[LuckyItems] 🔒 블러 섹션: $_blurredSections');
    }

    final lottoNumbers = _generateLottoNumbers();

    // ✅ fit: StackFit.expand 추가 - 전체 화면을 채워서 버튼이 하단에 고정되도록 함
    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ 원페이지 스크롤 (모든 카테고리 세로로 배치)
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // bottom padding for button
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 전체 섹션을 세로로 나열
              for (var category in _categories) ...[
                _buildCategorySection(category, lottoNumbers),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),

        // ✅ 전체보기 버튼 (블러가 있을 때만, 구독자 제외)
        if (_isBlurred && !ref.watch(isPremiumProvider))
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
          ),
      ],
    );
  }

  /// 로또 번호 생성 (사주 기반)
  List<int> _generateLottoNumbers() {
    final now = DateTime.now();
    final birthDate = _selectedBirthDate ?? DateTime.now();

    // 사주 기반 시드 (생년월일 + 오늘 날짜)
    final seed = birthDate.day +
                 birthDate.month * 10 +
                 birthDate.year % 100 * 100 +
                 now.day +
                 now.month * 100;

    final random = Random(seed);
    final numbers = <int>{};

    while (numbers.length < 6) {
      numbers.add(random.nextInt(45) + 1);
    }

    return numbers.toList()..sort();
  }

  /// 카테고리 섹션 (헤더 + 컨텐츠)
  Widget _buildCategorySection(CategoryModel category, List<int> lottoNumbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        CategoryHeader(category: category),
        const SizedBox(height: 16),

        // 카테고리별 상세 정보 (블러 처리 포함)
        _buildCategoryDetails(category.id, lottoNumbers),
      ],
    );
  }

  /// 광고 보고 블러 제거
  Future<void> _showAdAndUnblur() async {
    Logger.debug('[LuckyItems] 🎬 광고 시청 후 블러 해제 시작');

    try {
      final adService = ref.read(adServiceProvider);

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // 광고 로드 시작
        await adService.loadRewardedAd();

        // 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        // 타임아웃 처리
        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고 로드에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      // 광고 표시
      Logger.debug('[LuckyItems] 🎬 광고 표시 시작');
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, rewardItem) async {
          Logger.debug('[LuckyItems] ✅ 광고 보상 획득, 블러 해제');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          if (mounted) {
            setState(() {
              _hasUserUnlockedBlur = true; // 사용자가 블러를 해제했음을 표시
              _isBlurred = false;
              _blurredSections = [];
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e) {
      Logger.debug('[LuckyItems] ❌ 광고 표시 실패: $e');

      // 에러 발생 시에도 블러 해제 (사용자 경험 우선)
      if (mounted) {
        setState(() {
          _hasUserUnlockedBlur = true; // 에러 시에도 해제 플래그 설정
          _isBlurred = false;
          _blurredSections = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 로드에 실패했지만 내용을 보여드립니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 카테고리별 상세 정보
  Widget _buildCategoryDetails(String categoryId, List<int> lottoNumbers) {
    switch (categoryId) {
      case 'lotto':
        // ✅ 로또는 마지막 번호만 블러 처리
        return LottoContent(
          numbers: lottoNumbers,
          isBlurred: _isBlurred && _blurredSections.contains('lotto'),
        );
      case 'shopping':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'shopping',
          child: const ShoppingContent(),
        );
      case 'game':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'game',
          child: const GameContent(),
        );
      case 'food':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'food',
          child: const FoodContent(),
        );
      case 'travel':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'travel',
          child: const TravelContent(),
        );
      case 'health':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'health',
          child: const HealthContent(),
        );
      case 'fashion':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'fashion',
          child: const FashionContent(),
        );
      case 'lifestyle':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'lifestyle',
          child: const LifestyleContent(),
        );
      case 'today_color':
        return UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          blurredSections: _blurredSections,
          sectionKey: 'today_color',
          child: TodayColorContent(
            birthDate: _selectedBirthDate ?? DateTime.now(),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
