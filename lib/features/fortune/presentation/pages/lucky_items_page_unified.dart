import 'dart:ui'; // ✅ ImageFilter.blur용
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/lucky_items_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../presentation/providers/ad_provider.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import 'dart:math';

/// 행운 아이템 페이지
///
/// 로또 번호, 오늘의 색상, 쇼핑, 게임, 음식, 여행, 건강, 패션, 라이프스타일 등
/// 9개 카테고리의 행운 정보를 제공합니다.
class LuckyItemsPageUnified extends ConsumerStatefulWidget {
  const LuckyItemsPageUnified({super.key});

  @override
  ConsumerState<LuckyItemsPageUnified> createState() => _LuckyItemsPageUnifiedState();
}

class _LuckyItemsPageUnifiedState extends ConsumerState<LuckyItemsPageUnified> {
  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ✅ 입력 폼 상태
  DateTime? _selectedBirthDate;
  String? _selectedBirthTime;
  String? _selectedGender;
  List<String> _selectedInterests = [];
  List<AccordionInputSection> _sections = [];
  bool _isGenerating = false; // 운세 생성 중 플래그
  bool _hasUserUnlockedBlur = false; // 사용자가 광고를 보고 블러를 해제했는지 여부

  @override
  void initState() {
    super.initState();
    _initializeSections();
    _loadUserProfile();
  }

  // 9개 메인 카테고리
  static const List<CategoryModel> _categories = [
    CategoryModel(
      id: 'lotto',
      title: '로또/복권',
      icon: '🎰',
      description: '행운의 번호와 구매 장소',
      color: Color(0xFFFF6B6B),
    ),
    CategoryModel(
      id: 'shopping',
      title: '쇼핑/구매',
      icon: '🛍️',
      description: '쇼핑 운과 구매 타이밍',
      color: Color(0xFFAB47BC),
    ),
    CategoryModel(
      id: 'game',
      title: '게임/엔터',
      icon: '🎮',
      description: '게임과 엔터테인먼트',
      color: Color(0xFF45B7D1),
    ),
    CategoryModel(
      id: 'food',
      title: '음식/맛집',
      icon: '🍜',
      description: '행운의 음식과 맛집',
      color: Color(0xFF66BB6A),
    ),
    CategoryModel(
      id: 'travel',
      title: '여행/장소',
      icon: '✈️',
      description: '행운의 장소와 여행지',
      color: Color(0xFF4ECDC4),
    ),
    CategoryModel(
      id: 'health',
      title: '운동/건강',
      icon: '💪',
      description: '건강 운과 운동 가이드',
      color: Color(0xFF42A5F5),
    ),
    CategoryModel(
      id: 'fashion',
      title: '패션/뷰티',
      icon: '👗',
      description: '오늘의 스타일링',
      color: Color(0xFFEC407A),
    ),
    CategoryModel(
      id: 'lifestyle',
      title: '라이프',
      icon: '🌟',
      description: '일상 속 행운 가이드',
      color: Color(0xFF26A69A),
    ),
    CategoryModel(
      id: 'today_color',
      title: '오늘의 색상',
      icon: '🎨',
      description: '행운을 부르는 오늘의 컬러',
      color: Color(0xFFE91E63),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'lucky_items',
      title: '행운 아이템',
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
                    style: TypographyUnified.heading2.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '로또번호부터 오늘의 색상까지\n당신의 행운을 찾아보세요',
                    style: TypographyUnified.bodyMedium.copyWith(
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

        // ✅ TossFloatingProgressButton (로딩 상태 관리)
        TossFloatingProgressButtonPositioned(
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
          isVisible: _canGenerate(),
        ),
      ],
    );
  }

  /// 생년월일 선택기
  Widget _buildDatePicker(Function(dynamic) onValueChanged) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(_selectedBirthDate == null
              ? '생년월일을 선택하세요'
              : '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedBirthDate ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
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
            }
          },
        ),
      ],
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

      print('[LuckyItems] 🔒 블러 상태 동기화 (최초): $_isBlurred');
      print('[LuckyItems] 🔒 블러 섹션: $_blurredSections');
    }

    final lottoNumbers = _generateLottoNumbers();

    return Stack(
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

        // ✅ 전체보기 버튼 (블러가 있을 때만 표시)
        if (_isBlurred)
          FloatingBottomButton(
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
        _CategoryHeader(category: category),
        const SizedBox(height: 16),

        // 카테고리별 상세 정보 (블러 처리 포함)
        _buildCategoryDetails(category.id, lottoNumbers),
      ],
    );
  }

  /// 광고 보고 블러 제거
  Future<void> _showAdAndUnblur() async {
    print('[LuckyItems] 🎬 광고 시청 후 블러 해제 시작');

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
      print('[LuckyItems] 🎬 광고 표시 시작');
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, rewardItem) {
          print('[LuckyItems] ✅ 광고 보상 획득, 블러 해제');

          if (mounted) {
            setState(() {
              _hasUserUnlockedBlur = true; // 사용자가 블러를 해제했음을 표시
              _isBlurred = false;
              _blurredSections = [];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('행운 아이템이 잠금 해제되었습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      print('[LuckyItems] ❌ 광고 표시 실패: $e');

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

  /// 블러 wrapper
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      return child;
    }

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  /// 카테고리별 상세 정보
  Widget _buildCategoryDetails(String categoryId, List<int> lottoNumbers) {
    switch (categoryId) {
      case 'lotto':
        // ✅ 로또는 마지막 번호만 블러 처리
        return _LottoContent(
          numbers: lottoNumbers,
          isBlurred: _isBlurred && _blurredSections.contains('lotto'),
        );
      case 'shopping':
        return _buildBlurWrapper(
          sectionKey: 'shopping',
          child: const _ShoppingContent(),
        );
      case 'game':
        return _buildBlurWrapper(
          sectionKey: 'game',
          child: const _GameContent(),
        );
      case 'food':
        return _buildBlurWrapper(
          sectionKey: 'food',
          child: const _FoodContent(),
        );
      case 'travel':
        return _buildBlurWrapper(
          sectionKey: 'travel',
          child: const _TravelContent(),
        );
      case 'health':
        return _buildBlurWrapper(
          sectionKey: 'health',
          child: const _HealthContent(),
        );
      case 'fashion':
        return _buildBlurWrapper(
          sectionKey: 'fashion',
          child: const _FashionContent(),
        );
      case 'lifestyle':
        return _buildBlurWrapper(
          sectionKey: 'lifestyle',
          child: const _LifestyleContent(),
        );
      case 'today_color':
        return _buildBlurWrapper(
          sectionKey: 'today_color',
          child: _TodayColorContent(
            birthDate: _selectedBirthDate ?? DateTime.now(),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 사주 기반 오늘의 색상 생성
  Map<String, dynamic> _generateTodayColor() {
    final birthDate = _selectedBirthDate ?? DateTime.now();
    final now = DateTime.now();

    // 사주 기반 시드
    final seed = birthDate.day + birthDate.month * 10 + now.day + now.month * 100;
    final random = Random(seed);

    // RGB 생성
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);

    final hex = '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';

    return {
      'hex': hex,
      'color': Color.fromARGB(255, r, g, b),
      'rgb': {'r': r, 'g': g, 'b': b},
    };
  }
}

// ==================== 모델 ====================

class CategoryModel {
  final String id;
  final String title;
  final String icon;
  final String description;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });
}

// ==================== 위젯 컴포넌트 ====================

/// 카테고리 탭 리스트
class _CategoryTabs extends StatelessWidget {
  final List<CategoryModel> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color.withValues(alpha: 0.2)
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? category.color : TossDesignSystem.gray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    category.title,
                    style: TypographyUnified.labelSmall.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? category.color : TossDesignSystem.gray600,
                    ),
                    textAlign: TextAlign.center,
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

/// 카테고리 헤더
class _CategoryHeader extends StatelessWidget {
  final CategoryModel category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: TypographyUnified.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: TossDesignSystem.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 아이템 위젯
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TypographyUnified.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 카테고리별 컨텐츠 ====================

/// 로또/복권
class _LottoContent extends StatelessWidget {
  final List<int> numbers;
  final bool isBlurred;

  const _LottoContent({
    required this.numbers,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 행운 번호',
              style: TypographyUnified.heading4.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numbers.asMap().entries.map((entry) {
                final index = entry.key;
                final number = entry.value;
                final isLastNumber = index == numbers.length - 1;

                // ✅ 마지막 번호만 블러 처리
                Widget numberWidget = Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TypographyUnified.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );

                // 마지막 번호이고 블러 상태면 블러 처리
                if (isLastNumber && isBlurred) {
                  numberWidget = Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: numberWidget,
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_outline,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return numberWidget;
              }).toList(),
            ),
            const SizedBox(height: 24),
            const _InfoItem(label: '구매 시간', value: '오후 2시~4시'),
            const _InfoItem(label: '구매 장소', value: '집 근처 편의점'),
            const _InfoItem(label: '행운 번호', value: '1, 7, 21번'),
          ],
        ),
      ),
    );
  }
}

/// 쇼핑/구매
class _ShoppingContent extends StatelessWidget {
  const _ShoppingContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '행운 아이템', value: '블루 톤 액세서리'),
            _InfoItem(label: '쇼핑 장소', value: '온라인 쇼핑몰'),
            _InfoItem(label: '추천 브랜드', value: '자연 친화적 브랜드'),
            _InfoItem(label: '구매 시간', value: '저녁 8시 이후'),
          ],
        ),
      ),
    );
  }
}

/// 게임/엔터
class _GameContent extends StatelessWidget {
  const _GameContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '추천 게임', value: 'RPG, 전략 게임'),
            _InfoItem(label: '추천 콘텐츠', value: '여행 다큐멘터리'),
            _InfoItem(label: '음악', value: '재즈, 클래식'),
            _InfoItem(label: '행운 시간', value: '밤 10시 이후'),
          ],
        ),
      ),
    );
  }
}

/// 음식/맛집
class _FoodContent extends StatelessWidget {
  const _FoodContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '행운 메뉴', value: '매콤한 국물 요리'),
            _InfoItem(label: '추천 장소', value: '한식당, 분식집'),
            _InfoItem(label: '카페', value: '조용한 동네 카페'),
            _InfoItem(label: '식사 시간', value: '점심 12시~1시'),
          ],
        ),
      ),
    );
  }
}

/// 여행/장소
class _TravelContent extends StatelessWidget {
  const _TravelContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '데이트 장소', value: '한강공원 산책로'),
            _InfoItem(label: '드라이브', value: '북한산 둘레길'),
            _InfoItem(label: '산책 장소', value: '남산 타워 주변'),
            _InfoItem(label: '추천 시간', value: '오후 3시~6시'),
          ],
        ),
      ),
    );
  }
}

/// 운동/건강
class _HealthContent extends StatelessWidget {
  const _HealthContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '추천 운동', value: '조깅, 요가'),
            _InfoItem(label: '운동 시간', value: '아침 7시~9시'),
            _InfoItem(label: '운동 장소', value: '헬스장, 요가 스튜디오'),
            _InfoItem(label: '건강 팁', value: '충분한 수분 섭취'),
          ],
        ),
      ),
    );
  }
}

/// 패션/뷰티
class _FashionContent extends StatelessWidget {
  const _FashionContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '럭키 컬러', value: '네이비, 화이트'),
            _InfoItem(label: '스타일링', value: '캐주얼 시크'),
            _InfoItem(label: '액세서리', value: '실버 톤 귀걸이'),
            _InfoItem(label: '뷰티', value: '자연스러운 메이크업'),
          ],
        ),
      ),
    );
  }
}

/// 라이프스타일
class _LifestyleContent extends StatelessWidget {
  const _LifestyleContent();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _InfoItem(label: '취미 활동', value: '독서, 영화 감상'),
            _InfoItem(label: '만남', value: '친구와 카페에서'),
            _InfoItem(label: 'SNS 시간', value: '저녁 7시~9시'),
            _InfoItem(label: '일상 팁', value: '새로운 시도를 해보세요'),
          ],
        ),
      ),
    );
  }
}

/// 오늘의 색상
class _TodayColorContent extends StatelessWidget {
  final DateTime birthDate;

  const _TodayColorContent({required this.birthDate});

  Map<String, dynamic> _generateTodayColor() {
    final now = DateTime.now();

    // 사주 기반 시드
    final seed = birthDate.day + birthDate.month * 10 + now.day + now.month * 100;
    final random = Random(seed);

    // RGB 생성
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);

    final hex = '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';

    return {
      'hex': hex,
      'color': Color.fromARGB(255, r, g, b),
      'r': r,
      'g': g,
      'b': b,
    };
  }

  String _getColorMeaning(int r, int g, int b) {
    // RGB 값에 따른 색상 의미
    if (r > 200 && g < 100 && b < 100) return '열정과 에너지의 빨간색 계열';
    if (r < 100 && g < 100 && b > 200) return '평온과 안정의 파란색 계열';
    if (r < 100 && g > 200 && b < 100) return '성장과 희망의 녹색 계열';
    if (r > 200 && g > 200 && b < 100) return '활력과 기쁨의 노란색 계열';
    if (r > 200 && g < 100 && b > 200) return '창의성의 보라색 계열';
    if (r > 150 && g > 150 && b > 150) return '순수함과 청명함의 밝은 색';
    if (r < 100 && g < 100 && b < 100) return '세련됨과 우아함의 어두운 색';
    return '균형과 조화의 중간 톤';
  }

  @override
  Widget build(BuildContext context) {
    final colorData = _generateTodayColor();
    final color = colorData['color'] as Color;
    final hex = colorData['hex'] as String;
    final r = colorData['r'] as int;
    final g = colorData['g'] as int;
    final b = colorData['b'] as int;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 큰 색상 프리뷰
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  hex,
                  style: TypographyUnified.heading2.copyWith(
                    color: (r + g + b) > 382 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 색상 정보
            _InfoItem(label: 'HEX 코드', value: hex),
            _InfoItem(label: 'RGB', value: 'R:$r, G:$g, B:$b'),
            _InfoItem(label: '색상 의미', value: _getColorMeaning(r, g, b)),
            const _InfoItem(
              label: '활용 팁',
              value: '오늘 이 색상의 옷이나 소품을 착용하면 행운이 따릅니다',
            ),
            const _InfoItem(
              label: '추천 아이템',
              value: '액세서리, 가방, 양말, 스마트폰 케이스',
            ),
          ],
        ),
      ),
    );
  }
}
