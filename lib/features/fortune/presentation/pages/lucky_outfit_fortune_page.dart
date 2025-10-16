import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/theme/toss_design_system.dart';

class LuckyOutfitFortunePage extends ConsumerStatefulWidget {
  const LuckyOutfitFortunePage({super.key});

  @override
  ConsumerState<LuckyOutfitFortunePage> createState() => _LuckyOutfitFortunePageState();
}

class _LuckyOutfitFortunePageState extends ConsumerState<LuckyOutfitFortunePage> {
  DateTime? _selectedDate;
  String? _occasion;
  String? _personalStyle;
  String? _zodiacSign;
  
  final List<Map<String, dynamic>> occasions = [
    {
      'id': 'business',
      'title': '비즈니스/업무',
      'icon': Icons.business_center,
      'color': TossDesignSystem.tossBlue,
      'description': '중요한 미팅, 프레젠테이션, 면접',
    },
    {
      'id': 'date',
      'title': '데이트/만남',
      'icon': Icons.favorite,
      'color': TossDesignSystem.pinkPrimary,
      'description': '연인과의 데이트, 소개팅',
    },
    {
      'id': 'party',
      'title': '파티/모임',
      'icon': Icons.celebration,
      'color': TossDesignSystem.purple,
      'description': '친구 모임, 파티, 경조사',
    },
    {
      'id': 'casual',
      'title': '일상/캐주얼',
      'icon': Icons.wb_sunny,
      'color': TossDesignSystem.warningOrange,
      'description': '평상시, 쇼핑, 산책',
    },
    {
      'id': 'sports',
      'title': '운동/활동',
      'icon': Icons.sports,
      'color': TossDesignSystem.successGreen,
      'description': '운동, 야외활동, 레저',
    },
    {
      'id': 'formal',
      'title': '격식/행사',
      'icon': Icons.stars,
      'color': TossDesignSystem.bluePrimary,
      'description': '결혼식, 공식 행사, 시상식',
    },
  ];
  
  final List<Map<String, dynamic>> styleTypes = [
    {'id': 'classic', 'label': '클래식', 'icon': Icons.star},
    {'id': 'modern', 'label': '모던', 'icon': Icons.star},
    {'id': 'casual', 'label': '캐주얼', 'icon': Icons.star},
    {'id': 'romantic', 'label': '로맨틱', 'icon': Icons.star},
    {'id': 'sporty', 'label': '스포티', 'icon': Icons.star},
    {'id': 'unique', 'label': '유니크', 'icon': Icons.star},
  ];
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile?.birthDate != null) {
      _zodiacSign = _getZodiacSign(profile!.birthDate!);
    }
  }
  
  String _getZodiacSign(DateTime birthdate) {
    final month = birthdate.month;
    final day = birthdate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'aquarius';
    return 'pisces';
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '행운의 의상',
      fortuneType: 'lucky-outfit',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result),
    );
  }
  
  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return Stack(
      children: [
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            '오늘의 럭키 스타일링',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '날짜와 상황에 맞는 행운의 의상을 추천해드립니다.',
            style: TextStyle(
              fontSize: 14,
              color: TossDesignSystem.gray400,
            ),
          ),
          const SizedBox(height: 24),
          
          // Date selection
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TossDesignSystem.gray300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: TossDesignSystem.gray400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '날짜 선택',
                          style: TextStyle(
                            fontSize: 12,
                            color: TossDesignSystem.gray400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: TossDesignSystem.gray400),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Occasion selection
          const Text(
            '어떤 상황인가요?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: occasions.length,
            itemBuilder: (context, index) {
              final occasion = occasions[index];
              final isSelected = _occasion == occasion['id'];
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _occasion = occasion['id'];
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? occasion['color']
                        : TossDesignSystem.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? occasion['color']
                          : TossDesignSystem.gray300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        occasion['icon'],
                        size: 32,
                        color: isSelected
                            ? TossDesignSystem.white
                            : TossDesignSystem.gray600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        occasion['title'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? TossDesignSystem.white
                              : TossDesignSystem.gray700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          if (_occasion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark700
                    : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: TossDesignSystem.gray600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      occasions.firstWhere((o) => o['id'] == _occasion)['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: TossDesignSystem.gray600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Personal style
          const Text(
            '평소 스타일',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: styleTypes.map((style) {
              final isSelected = _personalStyle == style['id'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      style['icon'],
                      size: 16,
                      color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray600,
                    ),
                    const SizedBox(width: 4),
                    Text(style['label']),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _personalStyle = selected ? style['id'] : null;
                  });
                },
                selectedColor: TossDesignSystem.pinkPrimary,
                labelStyle: TextStyle(
                  color: isSelected ? TossDesignSystem.white : null,
                ),
              );
            }).toList(),
          ),
              
              const SizedBox(height: 24),
              
              // 하단 버튼 공간만큼 여백 추가
              const BottomButtonSpacing(),
            ],
          ),
        ),
        
        // Floating 버튼
        FloatingBottomButton(
          text: '행운의 스타일 확인하기',
          onPressed: _occasion != null && _personalStyle != null
              ? () => onSubmit({
                    'date': _selectedDate!.toIso8601String(),
                    'occasion': _occasion,
                    'personal_style': _personalStyle,
                    'zodiac_sign': _zodiacSign,
                  })
              : null,
          style: TossButtonStyle.primary,
          size: TossButtonSize.large,
          icon: Icon(Icons.checkroom),
        ),
      ],
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Widget _buildResult(BuildContext context, FortuneResult result) {
    final data = result.details ?? {};
    
    return Column(
      children: [
        // Lucky Color of the Day
        if (data['lucky_color'] != null) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorFromName(data['lucky_color']),
                  _getColorFromName(data['lucky_color']).withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getColorFromName(data['lucky_color']),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getColorFromName(data['lucky_color']).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '오늘의 행운의 색',
                  style: TextStyle(
                    fontSize: 14,
                    color: TossDesignSystem.gray400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['lucky_color'] ?? '분석 중',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (data['color_meaning'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    data['color_meaning'],
                    style: TextStyle(
                      fontSize: 14,
                      color: TossDesignSystem.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Main outfit recommendation
        if (result.mainFortune != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark800
                  : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark600
                  : TossDesignSystem.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.checkroom, color: TossDesignSystem.pinkPrimary),
                    SizedBox(width: 8),
                    Text(
                      '추천 스타일링',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.mainFortune!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Specific Items
        if (data['recommended_items'] != null && data['recommended_items'] is List) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark800
                  : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark600
                  : TossDesignSystem.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_bag, color: TossDesignSystem.warningOrange),
                    SizedBox(width: 8),
                    Text(
                      '아이템별 추천',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(data['recommended_items'] as List).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: TossDesignSystem.pinkPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getItemIcon(item['type'] ?? ''),
                          size: 18,
                          color: TossDesignSystem.pinkPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['type'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item['description'] != null)
                              Text(
                                item['description'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: TossDesignSystem.gray400,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Lucky Accessories
        if (result.luckyItems != null && result.luckyItems!['accessories'] != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withValues(alpha: 0.1),
                  TossDesignSystem.pinkPrimary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.diamond, color: TossDesignSystem.purple),
                    SizedBox(width: 8),
                    Text(
                      '행운의 액세서리',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  result.luckyItems!['accessories'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Styling Tips
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.warningYellow.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: TossDesignSystem.warningYellow),
                    SizedBox(width: 8),
                    Text(
                      '스타일링 팁',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.recommendations!.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: TossDesignSystem.warningYellow,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Avoid Items
        if (data['avoid_items'] != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.errorRed.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.block, color: TossDesignSystem.errorRed),
                    SizedBox(width: 8),
                    Text(
                      '피해야 할 스타일',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['avoid_items'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Color _getColorFromName(String colorName) {
    final colorMap = {
      '빨강': TossDesignSystem.errorRed,
      '파랑': TossDesignSystem.tossBlue,
      '노랑': TossDesignSystem.warningYellow,
      '초록': TossDesignSystem.successGreen,
      '보라': TossDesignSystem.purple,
      '핑크': TossDesignSystem.pinkPrimary,
      '주황': TossDesignSystem.warningOrange,
      '흰색': TossDesignSystem.white,
      '검정': TossDesignSystem.black,
      '회색': TossDesignSystem.gray400,
      '갈색': TossDesignSystem.brownPrimary,
      '네이비': TossDesignSystem.bluePrimary,
    };
    return colorMap[colorName] ?? TossDesignSystem.gray400;
  }
  
  IconData _getItemIcon(String itemType) {
    final iconMap = {
      '상의': Icons.checkroom,
      '하의': Icons.checkroom,
      '아우터': Icons.checkroom,
      '신발': Icons.sports_handball,
      '가방': Icons.shopping_bag,
      '액세서리': Icons.diamond,
      '모자': Icons.accessible,
    };
    return iconMap[itemType] ?? Icons.checkroom;
  }
}