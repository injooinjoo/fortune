import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/components/toss_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/auth_provider.dart';
import 'dart:math';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/lucky_items_fortune_conditions.dart';
import '../../../../core/widgets/accordion_input_section.dart';

class LuckyItemsUnifiedPage extends BaseFortunePage {
  const LuckyItemsUnifiedPage({
    super.key}) : super(
          title: '오늘의 행운 가이드',
          description: '로또부터 라이프스타일까지, 실용적인 행운 정보를 확인하세요',
          fortuneType: 'lucky_guide',
          requiresUserInfo: true
        );

  @override
  ConsumerState<LuckyItemsUnifiedPage> createState() => _LuckyItemsUnifiedPageState();
}

class _LuckyItemsUnifiedPageState extends BaseFortunePageState<LuckyItemsUnifiedPage> {
  Fortune? _fortuneResult;
  int _selectedCategoryIndex = 0;

  // Accordion input sections
  List<AccordionInputSection> _accordionSections = [];

  // User input data
  DateTime? _selectedBirthDate;
  String? _selectedBirthTime;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadProfileAndInitialize();
  }

  Future<void> _loadProfileAndInitialize() async {
    // 프로필 정보 불러오기
    final profile = await ref.read(userProfileProvider.future);

    setState(() {
      _selectedBirthDate = profile?.birthDate;
      _selectedBirthTime = profile?.birthTime;
      _selectedGender = profile?.gender;

      _accordionSections = [
        AccordionInputSection(
          id: 'birthDate',
          title: '생년월일',
          icon: Icons.cake_rounded,
          inputWidgetBuilder: (context, onComplete) => _buildBirthDateInput(onComplete),
          value: _selectedBirthDate,
          isCompleted: _selectedBirthDate != null,
        ),
        AccordionInputSection(
          id: 'birthTime',
          title: '출생 시간',
          icon: Icons.access_time_rounded,
          inputWidgetBuilder: (context, onComplete) => _buildBirthTimeInput(onComplete),
          value: _selectedBirthTime,
          isCompleted: _selectedBirthTime != null,
        ),
        AccordionInputSection(
          id: 'gender',
          title: '성별',
          icon: Icons.person_rounded,
          inputWidgetBuilder: (context, onComplete) => _buildGenderInput(onComplete),
          value: _selectedGender,
          isCompleted: _selectedGender != null,
        ),
      ];
    });
  }

  // 8개 메인 카테고리 정의 (투자/학습 제거)
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'lotto',
      'title': '로또/복권',
      'icon': '🎰',
      'description': '행운의 번호와 구매 장소',
      'color': const Color(0xFFFF6B6B),
      'subItems': ['추천번호', '구매장소', '구매시간', '복권종류']
    },
    {
      'id': 'shopping',
      'title': '쇼핑/구매',
      'icon': '🛍️',
      'description': '쇼핑 운과 구매 타이밍',
      'color': const Color(0xFFAB47BC),
      'subItems': ['행운아이템', '쇼핑장소', '온라인딜', '브랜드추천']
    },
    {
      'id': 'game',
      'title': '게임/엔터테인먼트',
      'icon': '🎮',
      'description': '게임과 엔터테인먼트 가이드',
      'color': const Color(0xFF45B7D1),
      'subItems': ['게임추천', '영화드라마', '음악', '취미활동']
    },
    {
      'id': 'food',
      'title': '음식/맛집',
      'icon': '🍜',
      'description': '행운의 음식과 맛집',
      'color': const Color(0xFF66BB6A),
      'subItems': ['행운음식', '맛집추천', '카페', '배달음식']
    },
    {
      'id': 'travel',
      'title': '여행/장소',
      'icon': '✈️',
      'description': '행운의 장소와 여행지',
      'color': const Color(0xFF4ECDC4),
      'subItems': ['데이트장소', '드라이브코스', '산책장소', '핫플레이스']
    },
    {
      'id': 'health',
      'title': '운동/건강',
      'icon': '💪',
      'description': '건강 운과 운동 가이드',
      'color': const Color(0xFF42A5F5),
      'subItems': ['운동종류', '운동시간', '헬스장요가', '건강관리']
    },
    {
      'id': 'fashion',
      'title': '패션/뷰티',
      'icon': '👗',
      'description': '오늘의 스타일링',
      'color': const Color(0xFFEC407A),
      'subItems': ['럭키컬러', '스타일링', '액세서리', '뷰티']
    },
    {
      'id': 'lifestyle',
      'title': '라이프스타일',
      'icon': '🌟',
      'description': '일상 속 행운 가이드',
      'color': const Color(0xFF26A69A),
      'subItems': ['취미활동', '만남', 'SNS', '일상팁']
    },
  ];

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // 사용자 프로필 정보 가져오기
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    final fortuneService = UnifiedFortuneService(Supabase.instance.client);

    final conditions = LuckyItemsFortuneConditions(
      date: DateTime.now(),
      category: params['category'] as String?,
    );

    final fortuneResult = await fortuneService.getFortune(
      fortuneType: 'lucky-items',
      dataSource: FortuneDataSource.api,
      inputConditions: params,
      conditions: conditions,
    );

    // 행운 가이드 데이터 생성
    final luckyGuide = await _generateLuckyGuide(userProfile, DateTime.now());

    setState(() {
      _fortuneResult = luckyGuide;
    });

    return luckyGuide;
  }
  
  /// 실용적인 행운 가이드 데이터 생성
  Future<Fortune> _generateLuckyGuide(dynamic userProfile, DateTime date) async {
    // 프로필 정보 추출
    final birthDate = userProfile.birthdate ?? DateTime.now();
    final birthTime = userProfile.birthTime;
    final name = userProfile.name ?? '';
    final gender = userProfile.gender;

    // 생년월일 기반 시드값 생성
    final birthDay = birthDate.day;
    final seedValue = (date.day + date.month + birthDay).toInt();
    final random = Random(seedValue);

    // 오늘의 운세에서 실제 점수 가져오기 (임시로 75 사용)
    int actualScore = 75;
    
    // 로또 번호 생성
    final lottoNumbers = _generateLottoNumbers(userProfile, date, random);
    
    // 각 카테고리별 데이터 생성
    final categoryData = <String, Map<String, dynamic>>{};
    
    for (final category in _categories) {
      categoryData[category['id']] = _generateCategoryData(category, userProfile, date, random);
    }
    
    // 오늘의 TOP 5 추천 생성
    final topRecommendations = _generateTopRecommendations(categoryData, random);
    
    // 현재 날짜 정보 생성
    final now = DateTime.now();
    final dateString = '${now.year}년 ${now.month}월 ${now.day}일';
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[now.weekday % 7];

    // 프로필 정보 표시
    final profileInfo = StringBuffer();
    if (name.isNotEmpty) {
      profileInfo.write('👤 $name님');
      if (gender != null) {
        profileInfo.write(' (${gender == 'male' ? '남' : '여'})');
      }
      profileInfo.write('\n');
    }
    if (birthDate != null) {
      profileInfo.write('🎂 ${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}');
      if (birthTime != null) {
        profileInfo.write(' $birthTime');
      }
      profileInfo.write(' 출생\n');
    }

    final description = '''$profileInfo
오늘은 $dateString ($weekday요일) 입니다.

🌟 오늘의 행운 가이드

${topRecommendations.join('\n')}

각 카테고리를 선택하여 더 자세한 정보를 확인하세요!''';
    
    return Fortune(
      id: 'lucky_guide_${date.millisecondsSinceEpoch}',
      userId: userProfile.id,
      type: 'lucky_guide',
      content: description,
      createdAt: date,
      category: 'lucky-guide',
      overallScore: actualScore,
      scoreBreakdown: {
        '종합 운세': actualScore,
        '로또 운': (actualScore * 0.9 + random.nextInt(10)).round(),
        '투자 운': (actualScore * 0.85 + random.nextInt(15)).round(),
        '만남 운': (actualScore * 1.1 - random.nextInt(5)).round().clamp(0, 100),
      },
      description: description,
      luckyItems: {
        'lotto_numbers': lottoNumbers,
        'categories': categoryData,
        'top_recommendations': topRecommendations,
      },
      recommendations: [
        '중요한 결정은 오후 2-4시 사이에 내리세요',
        '새로운 사람과의 만남을 적극적으로 시도하세요',
        '직감을 믿고 행동하는 것이 좋겠습니다',
        '작은 투자나 도전을 해보는 것을 추천합니다',
      ],
      metadata: {
        'generated_date': date.toIso8601String(),
        'user_name': name,
        'user_birth_date': birthDate.toIso8601String(),
        'user_birth_time': birthTime,
        'user_gender': gender,
        'categories': _categories.length,
      },
    );
  }
  
  /// 로또 번호 생성 (생년월일 + 오늘 날짜 기반)
  List<int> _generateLottoNumbers(dynamic userProfile, DateTime date, Random random) {
    final birthDate = userProfile.birthdate ?? DateTime.now();
    final birthTime = userProfile.birthTime;

    // 개인 행운수 계산
    final personalLucky = (birthDate.day + birthDate.month + birthDate.year % 100) % 45 + 1;

    // 오늘의 에너지
    final dailyLucky = (date.day + date.month + date.weekday) % 45 + 1;

    // 태어난 시간 기반 행운수 (있을 경우)
    int timeLucky = 14; // 기본값
    if (birthTime != null && birthTime.isNotEmpty) {
      // "14:30" 형식에서 시간 추출
      final parts = birthTime.split(':');
      if (parts.isNotEmpty) {
        final hour = int.tryParse(parts[0]) ?? 0;
        timeLucky = (hour * 2 + 1) % 45 + 1;
      }
    }

    // MBTI 기반 라켤 번호
    int mbtiLucky = 7; // 기본값
    if (userProfile.mbti != null) {
      final mbtiHash = userProfile.mbti.hashCode;
      mbtiLucky = (mbtiHash.abs() % 45) + 1;
    }

    // 혈액형 기반 에너지
    int bloodLucky = 21;
    if (userProfile.bloodType != null) {
      switch (userProfile.bloodType) {
        case 'A': bloodLucky = 3; break;
        case 'B': bloodLucky = 12; break;
        case 'AB': bloodLucky = 27; break;
        case 'O': bloodLucky = 33; break;
      }
    }

    Set<int> numbers = {personalLucky, dailyLucky, timeLucky, mbtiLucky, bloodLucky};
    
    // 6개 번호가 될 때까지 추가
    while (numbers.length < 6) {
      final newNumber = random.nextInt(45) + 1;
      if (!numbers.contains(newNumber)) {
        numbers.add(newNumber);
      }
    }
    
    final result = numbers.toList()..sort();
    return result;
  }
  
  /// 카테고리별 데이터 생성 (8개 카테고리)
  Map<String, dynamic> _generateCategoryData(Map<String, dynamic> category, dynamic userProfile, DateTime date, Random random) {
    switch (category['id']) {
      case 'lotto':
        return _generateLottoData(userProfile, date, random);
      case 'shopping':
        return _generateShoppingData(userProfile, date, random);
      case 'game':
        return _generateGameData(userProfile, date, random);
      case 'food':
        return _generateFoodData(userProfile, date, random);
      case 'travel':
        return _generateTravelData(userProfile, date, random);
      case 'health':
        return _generateHealthData(userProfile, date, random);
      case 'fashion':
        return _generateFashionData(userProfile, date, random);
      case 'lifestyle':
        return _generateLifestyleData(userProfile, date, random);
      default:
        return {};
    }
  }
  
  /// TOP 5 추천 생성 (8개 카테고리)
  List<String> _generateTopRecommendations(Map<String, Map<String, dynamic>> categoryData, Random random) {
    return [
      '🎰 로또 번호: ${(categoryData['lotto']?['numbers'] as List<int>?)?.take(5).join(', ') ?? '7, 14, 21, 28, 35'}',
      '🛍️ 행운 쇼핑: ${categoryData['shopping']?['lucky_item'] ?? '블루 톤 액세서리'}',
      '🎮 추천 콘텐츠: ${categoryData['game']?['content'] ?? '여행 다큐멘터리'}',
      '🍜 행운 메뉴: ${categoryData['food']?['lucky_food'] ?? '매콤한 국물 요리'}',
      '✈️ 추천 장소: ${categoryData['travel']?['spot'] ?? '한강공원 산책로'}',
    ];
  }

  // 생년월일 입력 위젯
  Widget _buildBirthDateInput(Function(dynamic) onComplete) {
    return _buildDatePickerWithNumpad(
      initialDate: _selectedBirthDate,
      onDateSelected: (date) {
        setState(() {
          _selectedBirthDate = date;
        });
        onComplete(date);
      },
    );
  }

  // 출생 시간 입력 위젯
  Widget _buildBirthTimeInput(Function(dynamic) onComplete) {
    return _buildTimePickerWithNumpad(
      initialTime: _selectedBirthTime,
      onTimeSelected: (time) {
        setState(() {
          _selectedBirthTime = time;
        });
        onComplete(time);
      },
    );
  }

  // 성별 입력 위젯
  Widget _buildGenderInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = 'male';
              });
              HapticFeedback.mediumImpact();
              onComplete('male');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _selectedGender == 'male'
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == 'male'
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
                  width: _selectedGender == 'male' ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.male,
                    size: 48,
                    color: _selectedGender == 'male'
                        ? TossDesignSystem.tossBlue
                        : TossDesignSystem.gray400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '남성',
                    style: TypographyUnified.buttonMedium.copyWith(
                      color: _selectedGender == 'male'
                          ? TossDesignSystem.tossBlue
                          : TossDesignSystem.gray600,
                      fontWeight: _selectedGender == 'male'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = 'female';
              });
              HapticFeedback.mediumImpact();
              onComplete('female');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _selectedGender == 'female'
                    ? const Color(0xFFEC407A).withValues(alpha: 0.1)
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == 'female'
                      ? const Color(0xFFEC407A)
                      : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
                  width: _selectedGender == 'female' ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.female,
                    size: 48,
                    color: _selectedGender == 'female'
                        ? const Color(0xFFEC407A)
                        : TossDesignSystem.gray400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '여성',
                    style: TypographyUnified.buttonMedium.copyWith(
                      color: _selectedGender == 'female'
                          ? const Color(0xFFEC407A)
                          : TossDesignSystem.gray600,
                      fontWeight: _selectedGender == 'female'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 숫자 패드로 날짜 입력 (YYYYMMDD)
  Widget _buildDatePickerWithNumpad({
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    final initialInput = initialDate != null
        ? '${initialDate.year}${initialDate.month.toString().padLeft(2, '0')}${initialDate.day.toString().padLeft(2, '0')}'
        : '';

    return StatefulBuilder(
      builder: (context, setState) {
        String input = initialInput;

        return Column(
          children: [
            // 입력 표시
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                input.isEmpty
                    ? 'YYYYMMDD'
                    : '${input.substring(0, 4)}.${input.substring(4, 6)}.${input.substring(6, 8)}',
                style: TypographyUnified.heading2.copyWith(
                  color: input.isEmpty ? TossDesignSystem.gray400 : TossDesignSystem.gray900,
                  fontFamily: 'TossFace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildNumpad(
              currentInput: input,
              maxLength: 8,
              onChanged: (value) {
                setState(() {
                  input = value;
                });
                if (value.length == 8) {
                  try {
                    final year = int.parse(value.substring(0, 4));
                    final month = int.parse(value.substring(4, 6));
                    final day = int.parse(value.substring(6, 8));
                    final date = DateTime(year, month, day);
                    onDateSelected(date);
                  } catch (e) {
                    // Invalid date
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 숫자 패드로 시간 입력 (HHMM)
  Widget _buildTimePickerWithNumpad({
    required String? initialTime,
    required Function(String) onTimeSelected,
  }) {
    final initialInput = initialTime?.replaceAll(':', '') ?? '';

    return StatefulBuilder(
      builder: (context, setState) {
        String input = initialInput;

        return Column(
          children: [
            // 입력 표시
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                input.isEmpty
                    ? 'HH:MM'
                    : '${input.substring(0, 2)}:${input.substring(2, 4)}',
                style: TypographyUnified.heading2.copyWith(
                  color: input.isEmpty ? TossDesignSystem.gray400 : TossDesignSystem.gray900,
                  fontFamily: 'TossFace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildNumpad(
              currentInput: input,
              maxLength: 4,
              onChanged: (value) {
                setState(() {
                  input = value;
                });
                if (value.length == 4) {
                  final hour = int.tryParse(value.substring(0, 2));
                  final minute = int.tryParse(value.substring(2, 4));
                  if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
                    onTimeSelected('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 숫자 패드 위젯
  Widget _buildNumpad({
    required String currentInput,
    required int maxLength,
    required Function(String) onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // 숫자 패드 (3x3 + 0)
            ...List.generate(3, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: List.generate(3, (col) {
                    final number = row * 3 + col + 1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildNumpadButton(
                          number.toString(),
                          () {
                            if (currentInput.length < maxLength) {
                              final newInput = currentInput + number.toString();
                              setState(() {
                                currentInput = newInput;
                              });
                              onChanged(newInput);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            // 0과 삭제 버튼
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildNumpadButton(
                      '0',
                      () {
                        if (currentInput.length < maxLength) {
                          final newInput = currentInput + '0';
                          setState(() {
                            currentInput = newInput;
                          });
                          onChanged(newInput);
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildNumpadButton(
                      '←',
                      () {
                        if (currentInput.isNotEmpty) {
                          final newInput = currentInput.substring(0, currentInput.length - 1);
                          setState(() {
                            currentInput = newInput;
                          });
                          onChanged(newInput);
                        }
                      },
                      isDelete: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumpadButton(String text, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDelete ? TossDesignSystem.errorRed.withValues(alpha: 0.1) : TossDesignSystem.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TypographyUnified.heading3.copyWith(
              color: isDelete ? TossDesignSystem.errorRed : TossDesignSystem.gray900,
              fontFamily: isDelete ? null : 'TossFace',
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // 카테고리 탭
        if (_fortuneResult != null)
          _buildCategoryTabs(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 32),

                if (_fortuneResult == null) ...[
                  // Accordion Input Sections
                  if (_accordionSections.isNotEmpty)
                    AccordionInputForm(
                      sections: _accordionSections,
                      onAllCompleted: () {
                        // 모든 입력이 완료되면 운세 생성
                        _onGenerateFortune();
                      },
                      completionButtonText: '🌟 행운 가이드 확인',
                    ),
                ] else ...[
                  // 선택된 카테고리 컨텐츠
                  _buildCategoryContent(),
                  const SizedBox(height: 24),

                  // Refresh Button
                  _buildRefreshButton(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 카테고리 탭 빌드
  Widget _buildCategoryTabs() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? category['color'].withValues(alpha: 0.2) 
                    : TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? category['color'] 
                      : const Color(0xFFE5E5E5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category['icon'],
                    style: TypographyUnified.displaySmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    category['title'],
                    style: TypographyUnified.labelSmall.copyWith(
                      fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                      color: isSelected 
                          ? category['color'] 
                          : const Color(0xFF666666),
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
  
  /// 선택된 카테고리 컨텐츠 빌드
  Widget _buildCategoryContent() {
    if (_fortuneResult?.luckyItems?['categories'] == null) {
      return const SizedBox.shrink();
    }
    
    final selectedCategory = _categories[_selectedCategoryIndex];
    final categoryId = selectedCategory['id'];
    final categoryData = _fortuneResult!.luckyItems!['categories'][categoryId] as Map<String, dynamic>?;
    
    if (categoryData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 헤더
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selectedCategory['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedCategory['color'].withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                selectedCategory['icon'],
                style: TypographyUnified.numberLarge,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCategory['title'],
                      style: TypographyUnified.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selectedCategory['color'],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      selectedCategory['description'],
                      style: TypographyUnified.bodySmall.copyWith(
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 카테고리별 상세 데이터
        _buildCategoryDetail(categoryId, categoryData, selectedCategory),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나만의 행운을\n확인해보세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '생년월일과 출생 시간을 입력하면 오늘의 행운 가이드를 확인할 수 있어요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return TossButton(
      text: '행운 가이드 확인하기',
      onPressed: _onGenerateFortune,
      style: TossButtonStyle.primary,
      size: TossButtonSize.large,
    );
  }

  Widget _buildRefreshButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _onGenerateFortune,
        icon: const Icon(Icons.refresh),
        label: const Text('다시 보기'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1F4EF5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null) {
      setState(() {
        _fortuneResult = null;
        _selectedCategoryIndex = 0; // 리셋
      });
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
      };
      generateFortuneAction(params: params);
    }
  }

  /// 카테고리별 상세 데이터 빌드
  Widget _buildCategoryDetail(String categoryId, Map<String, dynamic> data, Map<String, dynamic> category) {
    switch (categoryId) {
      case 'lotto':
        return _buildLottoDetail(data, category);
      case 'location':
        return _buildLocationDetail(data, category);
      case 'game':
        return _buildGameDetail(data, category);
      case 'finance':
        return _buildFinanceDetail(data, category);
      case 'food':
        return _buildFoodDetail(data, category);
      case 'transport':
        return _buildTransportDetail(data, category);
      case 'meeting':
        return _buildMeetingDetail(data, category);
      case 'shopping':
        return _buildShoppingDetail(data, category);
      case 'work':
        return _buildWorkDetail(data, category);
      case 'health':
        return _buildHealthDetail(data, category);
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// 로또 데이터 생성
  Map<String, dynamic> _generateLottoData(dynamic userProfile, DateTime date, Random random) {
    final numbers = _generateLottoNumbers(userProfile, date, random);
    final stores = ['백수 민럽점', 'GS25 강남대로점', '세븐일레븐 역삼점', '로또리아 선릉점'];
    final times = ['오전 10:00-11:00', '오후 2:00-3:00', '오후 6:00-7:00', '오후 8:00-9:00'];

    // 프로필 정보 기반 팁 생성
    final birthDate = userProfile.birthdate ?? DateTime.now();
    final birthTime = userProfile.birthTime;
    final name = userProfile.name ?? '';

    String tip = '개인 행운수 ${numbers.first}번이 특히 강한 날입니다';
    if (birthTime != null && birthTime.isNotEmpty) {
      tip += '\n⏰ 태어난 시간($birthTime)을 활용한 번호가 포함되었습니다';
    }

    return {
      'numbers': numbers,
      'store': stores[random.nextInt(stores.length)],
      'time': times[random.nextInt(times.length)],
      'confidence': 70 + random.nextInt(25),
      'tip': tip,
      'user_name': name,
      'birth_date': '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}',
      'birth_time': birthTime,
    };
  }
  
  /// 장소 데이터 생성
  
  /// 게임 데이터 생성
  Map<String, dynamic> _generateGameData(dynamic userProfile, DateTime date, Random random) {
    final onlineGames = ['리그오브레전드', '배틀그라운드', '오버워치', '에이팩스'];
    final mobileGames = ['원신', '쿠키런', '마블피컬공백전', '내여신에게 물어봐'];
    final strategies = ['공격적 전략', '수비적 전략', '밸런스 전략', '서포터 역할'];
    
    return {
      'online_game': onlineGames[random.nextInt(onlineGames.length)],
      'mobile_game': mobileGames[random.nextInt(mobileGames.length)],
      'strategy': strategies[random.nextInt(strategies.length)],
      'lucky_time': '${19 + random.nextInt(4)}:00-${21 + random.nextInt(2)}:00',
      'tip': '팀플레이보다는 솔로 플레이가 오늘 더 좋습니다',
    };
  }
  
  /// 금융 데이터 생성
  
  /// 음식 데이터 생성
  Map<String, dynamic> _generateFoodData(dynamic userProfile, DateTime date, Random random) {
    final restaurantTypes = ['일식 (초밥,라면)', '한식 (국밥,찌개)', '양식 (파스타,스테이크)', '중식 (지지장,탕수육)'];
    final drinks = ['소주 3병', '맥주 500cc x 4잔', '와인 (레드)', '위스키 드림'];
    final cafeMenus = ['아메리카노', '카페라떼', '디카페인', '거품만 스마트워터'];
    
    return {
      'restaurant_type': restaurantTypes[random.nextInt(restaurantTypes.length)],
      'drink': drinks[random.nextInt(drinks.length)],
      'cafe_menu': cafeMenus[random.nextInt(cafeMenus.length)],
      'discount_chance': 45 + random.nextInt(40),
      'tip': '오늘은 신메뉴보다 정통 메뉴가 더 맛있습니다',
    };
  }
  
  /// 교통 데이터 생성
  
  /// 만남 데이터 생성
  
  /// 쇼핑 데이터 생성
  Map<String, dynamic> _generateShoppingData(dynamic userProfile, DateTime date, Random random) {
    final items = ['전자제품 (이어폰, 케이스)', '의류 (청바지, 운동화)', '도서 (자기계발, 에세이)', '미용 (스킨케어, 화장품)'];
    final platforms = ['11번가', '쿠팡', '올리브', '당근마켓'];
    final timings = ['09:00', '15:00', '23:00'];
    
    return {
      'recommended_item': items[random.nextInt(items.length)],
      'platform': platforms[random.nextInt(platforms.length)],
      'best_time': timings[random.nextInt(timings.length)],
      'discount_chance': 35 + random.nextInt(40),
      'tip': '오늘은 중고거래에서의 발견이 좋습니다',
    };
  }
  
  /// 업무 데이터 생성
  
  /// 건강 데이터 생성
  Map<String, dynamic> _generateHealthData(dynamic userProfile, DateTime date, Random random) {
    final exercises = ['러닝 (5km)', '웨이트 트레이닝', '요가/필라테스', '수영', '자전거'];
    final timings = ['06:00-08:00', '18:00-20:00', '19:00-21:00'];
    final supplements = ['비타민D', '오메가3', '유산균', '마그네슘'];
    
    return {
      'exercise': exercises[random.nextInt(exercises.length)],
      'best_time': timings[random.nextInt(timings.length)],
      'supplement': supplements[random.nextInt(supplements.length)],
      'condition': 80 + random.nextInt(15),
      'steps_goal': 6000 + random.nextInt(6000),
      'tip': '오늘은 상체 운동보다 하체 운동이 더 효과적입니다',
    };
  }
  
  /// 로또 상세 카드
  Widget _buildLottoDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    final numbers = data['numbers'] as List<int>;
    final userName = data['user_name'] as String?;
    final birthDate = data['birth_date'] as String?;
    final birthTime = data['birth_time'] as String?;

    return Column(
      children: [
        // 프로필 정보 카드
        if (userName != null && birthDate != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF0F4FF), Color(0xFFFFF0F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5FF)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Color(0xFF1F4EF5), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$userName님의 행운 번호',
                        style: TypographyUnified.buttonSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F4EF5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '생년월일: $birthDate${birthTime != null ? ' $birthTime' : ''}',
                        style: TypographyUnified.labelSmall.copyWith(
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // 로또 번호 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number, color: Color(0xFFFF6B6B)),
                  SizedBox(width: 8),
                  Text(
                    '추천 번호',
                    style: TypographyUnified.buttonMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: category['color'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: numbers.map((number) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F4EF5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: const TextStyle(
                          color: TossDesignSystem.gray100,
                          
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['tip'] ?? '',
                        style: TypographyUnified.labelMedium.copyWith(
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // 구매 정보 카드
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('추천 매장', style: TypographyUnified.labelMedium.copyWith( color: Color(0xFF666666))),
                    Text(data['store'] ?? '', style: TypographyUnified.bodySmall.copyWith( fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('추천 시간', style: TypographyUnified.labelMedium.copyWith( color: Color(0xFF666666))),
                    Text(data['time'] ?? '', style: TypographyUnified.bodySmall.copyWith( fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 기본 카드 형태 (다른 카테고리에서 공통 사용)
  Widget _buildBasicCard(String title, Map<String, dynamic> data, Map<String, dynamic> category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: category['color'],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: category['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) {
            if (entry.key == 'tip') {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF666666)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TypographyUnified.labelMedium.copyWith(
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatFieldName(entry.key),
                      style: TypographyUnified.labelMedium.copyWith(
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191F28),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  
  String _formatFieldName(String key) {
    final nameMap = {
      'store': '매장',
      'time': '시간',
      'confidence': '신뢰도',
      'power_spot': '파워스팟',
      'cafe': '카페',
      'restaurant': '맛집',
      'direction': '방향',
      'online_game': '온라인',
      'mobile_game': '모바일',
      'strategy': '전략',
      'lucky_time': '행운타임',
      'sector': '섹터',
      'timing': '타이밍',
      'risk_level': '리스크',
      'restaurant_type': '음식종류',
      'drink': '술',
      'cafe_menu': '카페메뉴',
      'discount_chance': '할인확률',
      'taxi_app': '택시앱',
      'taxi_chance': '택시확률',
      'parking_tip': '주차팁',
      'travel_direction': '여행방향',
      'good_mbti': '좋은MBTI',
      'good_blood': '좋은혈액형',
      'industry': '업종',
      'meeting_time': '만남시간',
      'match_chance': '매칭확률',
      'recommended_item': '추천상품',
      'platform': '플랫폼',
      'best_time': '최적시간',
      'focus_time': '집중시간',
      'best_task': '추천업무',
      'meeting_type': '미팅종류',
      'productivity': '생산성',
      'exercise': '운동',
      'supplement': '보충제',
      'condition': '컨디션',
      'steps_goal': '방무목표',
    };
    return nameMap[key] ?? key;
  }
  
  // 나머지 카테고리별 상세 빌드 메서드들
  Widget _buildLocationDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('장소 가이드', data, category);
  }
  
  Widget _buildGameDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('게임 가이드', data, category);
  }
  
  Widget _buildFinanceDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('투자 가이드', data, category);
  }
  
  Widget _buildFoodDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('음식 가이드', data, category);
  }
  
  Widget _buildTransportDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('교통 가이드', data, category);
  }
  
  Widget _buildMeetingDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('만남 가이드', data, category);
  }
  
  Widget _buildShoppingDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('쇼핑 가이드', data, category);
  }
  
  Widget _buildWorkDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('업무 가이드', data, category);
  }
  
  Widget _buildHealthDetail(Map<String, dynamic> data, Map<String, dynamic> category) {
    return _buildBasicCard('건강 가이드', data, category);
  }

  /// 여행/장소 데이터 생성
  Map<String, dynamic> _generateTravelData(dynamic userProfile, DateTime date, Random random) {
    final dateSpots = ['한강공원 산책로', '남산타워 전망대', '경복궁 후원', '이태원 로시길'];
    final driveCourses = ['강변북로 드라이브', '올림픽대로 야간코스', '자유로 일몰드라이브', '동해안 해안도로'];
    final walkSpots = ['청계천 산책', '뚝섬유원지', '반포한강공원', '여의도공원'];
    final hotPlaces = ['성수동 카페거리', '홍대 놀거리', '강남 가로수길', '이태원 맛집거리'];
    
    return {
      'spot': dateSpots[random.nextInt(dateSpots.length)],
      'drive_course': driveCourses[random.nextInt(driveCourses.length)],
      'walk_spot': walkSpots[random.nextInt(walkSpots.length)],
      'hot_place': hotPlaces[random.nextInt(hotPlaces.length)],
      'best_time': '${14 + random.nextInt(4)}:00-${17 + random.nextInt(3)}:00',
      'tip': '오늘은 자연과 가까운 곳에서 더 좋은 에너지를 받을 수 있습니다',
    };
  }
  
  /// 패션/뷰티 데이터 생성
  Map<String, dynamic> _generateFashionData(dynamic userProfile, DateTime date, Random random) {
    final luckyColors = ['블루', '화이트', '네이비', '베이지', '그레이', '핑크', '그린'];
    final stylings = ['캐주얼 스타일', '비즈니스 캐주얼', '페미닌 스타일', '스트릿 패션'];
    final accessories = ['실버 액세서리', '골드 체인', '가죽 벨트', '스카프', '모자'];
    final beauty = ['자연스러운 메이크업', '포인트 립스틱', '아이라이너 강조', '글로우 베이스'];
    
    return {
      'lucky_color': luckyColors[random.nextInt(luckyColors.length)],
      'styling': stylings[random.nextInt(stylings.length)],
      'accessory': accessories[random.nextInt(accessories.length)],
      'beauty': beauty[random.nextInt(beauty.length)],
      'confidence': 85 + random.nextInt(10),
      'tip': '오늘은 밝은 톤의 색상이 운기를 상승시켜 줄 것입니다',
    };
  }
  
  /// 라이프스타일 데이터 생성
  Map<String, dynamic> _generateLifestyleData(dynamic userProfile, DateTime date, Random random) {
    final hobbies = ['독서', '요리', '그림그리기', '음악감상', '사진촬영', '원예'];
    final meetings = ['새로운 사람', '오랜 친구', '직장 동료', '가족'];
    final sns = ['인스타그램 포스팅', '페이스북 업데이트', '유튜브 시청', '블로그 작성'];
    final tips = ['새로운 루틴 시작', '정리 정돈', '감사 인사', '운동 습관'];
    
    return {
      'hobby': hobbies[random.nextInt(hobbies.length)],
      'meeting': meetings[random.nextInt(meetings.length)],
      'sns': sns[random.nextInt(sns.length)],
      'tip': tips[random.nextInt(tips.length)],
      'best_time': '${19 + random.nextInt(3)}:00-${21 + random.nextInt(2)}:00',
      'energy': 75 + random.nextInt(20),
    };
  }
}