import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/utils/dark_mode_helper.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';
import 'base_fortune_page.dart';

/// 생일 운세 페이지
class BirthdateFortunePage extends BaseFortunePage {
  const BirthdateFortunePage({super.key})
      : super(
          title: '생일 운세',
          description: '생년월일로 당신의 인생 운명을 읽어드립니다',
          fortuneType: 'birthdate',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<BirthdateFortunePage> createState() => _BirthdateFortunePageState();
}

class _BirthdateFortunePageState extends BaseFortunePageState<BirthdateFortunePage> {
  DateTime? _selectedDate;
  bool _isLunar = false;

  // 요일 정보 (UI 참조용)
  final Map<int, Map<String, dynamic>> weekdayMeanings = {
    1: {'day': '월요일', 'planet': '달', 'element': '물'},
    2: {'day': '화요일', 'planet': '화성', 'element': '불'},
    3: {'day': '수요일', 'planet': '수성', 'element': '공기'},
    4: {'day': '목요일', 'planet': '목성', 'element': '나무'},
    5: {'day': '금요일', 'planet': '금성', 'element': '금속'},
    6: {'day': '토요일', 'planet': '토성', 'element': '흙'},
    7: {'day': '일요일', 'planet': '태양', 'element': '빛'},
  };

  // 생일 수 계산 (1-9로 축약)
  int calculateLifePathNumber(DateTime date) {
    int sum = date.year + date.month + date.day;

    // 단일 숫자가 될 때까지 반복
    while (sum > 9 && sum != 11 && sum != 22 && sum != 33) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }

    return sum;
  }

  @override
  void initState() {
    super.initState();
    _loadProfileBirthDate();
  }

  void _loadProfileBirthDate() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile?.birthDate != null) {
      setState(() {
        _selectedDate = profile!.birthDate;
      });
    }
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    Logger.info('🔮 [BirthdateFortune] Calling API', {'params': params});

    try {
      final apiService = ref.read(fortuneApiServiceProvider);

      // API 호출 - FortuneApiService.getFortune 사용
      // Decision service is automatically applied inside getFortune
      final fortune = await apiService.getFortune(
        userId: user.id,
        fortuneType: widget.fortuneType,
        params: params,
      );

      Logger.info('✅ [BirthdateFortune] API fortune loaded successfully');
      return fortune;

    } catch (e, stackTrace) {
      Logger.error('❌ [BirthdateFortune] API failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If fortune exists, BaseFortunePage automatically shows result
    if (fortune != null || isLoading || error != null) {
      return super.build(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show custom input UI
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '생년월일 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Date display
            Center(
              child: Column(
                children: [
                  if (_selectedDate != null) ...[
                    Icon(
                      Icons.cake,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weekdayMeanings[_selectedDate!.weekday]!['day'],
                      style: TextStyle(
                        fontSize: 16,
                        color: DarkModeHelper.getColor(
                          context: context,
                          light: TossDesignSystem.gray600,
                          dark: TossDesignSystem.grayDark100,
                        ),
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.calendar_today,
                      size: 48,
                      color: DarkModeHelper.getColor(
                        context: context,
                        light: TossDesignSystem.gray500,
                        dark: TossDesignSystem.grayDark400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '생년월일을 선택해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: DarkModeHelper.getColor(
                          context: context,
                          light: TossDesignSystem.gray500,
                          dark: TossDesignSystem.grayDark400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Date picker button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    locale: const Locale('ko', 'KR'),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(_selectedDate == null ? '날짜 선택' : '날짜 변경'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Lunar calendar checkbox
            Row(
              children: [
                Checkbox(
                  value: _isLunar,
                  onChanged: (value) {
                    setState(() {
                      _isLunar = value ?? false;
                    });
                  },
                ),
                const Text('음력 생일입니다')
              ],
            ),

            // Preview info
            if (_selectedDate != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DarkModeHelper.getColor(
                    context: context,
                    light: TossDesignSystem.gray100,
                    dark: TossDesignSystem.grayDark700,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '생일 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('인생수', calculateLifePathNumber(_selectedDate!).toString()),
                    _buildInfoRow('요일', weekdayMeanings[_selectedDate!.weekday]!['day']),
                    _buildInfoRow('지배 행성', weekdayMeanings[_selectedDate!.weekday]!['planet']),
                    _buildInfoRow('원소', weekdayMeanings[_selectedDate!.weekday]!['element']),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            // Submit button
            TossButton(
              text: '생일 운세 확인하기',
              onPressed: _selectedDate != null
                  ? () => generateFortuneAction(params: {
                        'birthdate': _selectedDate!.toIso8601String(),
                        'isLunar': _isLunar,
                      })
                  : null,
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: DarkModeHelper.getColor(
                context: context,
                light: TossDesignSystem.gray600,
                dark: TossDesignSystem.grayDark100,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500))
        ],
      ),
    );
  }
}
