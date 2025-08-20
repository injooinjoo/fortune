import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme_extensions.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/services/personalized_fortune_service.dart';

class DailyCalendarFortunePage extends BaseFortunePage {
  const DailyCalendarFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '특정일 운세',
          description: '선택한 날짜의 전체적인 운세를 확인하세요',
          fortuneType: 'daily_calendar',
          requiresUserInfo: false,
          initialParams: initialParams,
        );

  @override
  ConsumerState<DailyCalendarFortunePage> createState() => _DailyCalendarFortunePageState();
}

class _DailyCalendarFortunePageState extends BaseFortunePageState<DailyCalendarFortunePage> {
  DateTime _selectedDate = DateTime.now();
  int? _selectedHour;
  String? _holidayName;
  String? _specialName;
  bool _isHoliday = false;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    final userId = ref.read(userProvider).value?.id ?? 'anonymous';
    
    // Use getTimeFortune with daily period for date-based fortune
    return await fortuneService.getTimeFortune(
      userId: userId,
      fortuneType: 'daily_calendar',
      params: {
        'period': 'daily',
        'date': _selectedDate.toIso8601String(),
        'isHoliday': _isHoliday,
        'holidayName': _holidayName,
        'specialName': _specialName,
        'selectedDateFormatted': DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDate),
        ...params,
      }
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    // Get selected date from navigation parameters
    if (widget.initialParams != null) {
      final selectedDateStr = widget.initialParams!['selectedDate'] as String?;
      if (selectedDateStr != null) {
        _selectedDate = DateTime.parse(selectedDateStr);
      }
      
      final fortuneParams = widget.initialParams?['fortuneParams'] as Map<String, dynamic>? ?? {};
      _isHoliday = fortuneParams['isHoliday'] as bool? ?? false;
      _holidayName = fortuneParams['holidayName'] as String?;
      _specialName = fortuneParams['specialName'] as String?;
    }
    
    return {
      'date': _selectedDate.toIso8601String(),
      'isHoliday': _isHoliday,
      'holidayName': _holidayName,
      'specialName': _specialName,
      'selectedDateFormatted': DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDate),
    };
  }

  @override
  Widget buildInputForm() {
    return _buildDateHeaderSection();
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // 기본 운세 결과는 제외하고 특정일에 맞는 정보만 표시
          _buildOverallScoreSection(),
          _buildTodaysCoreSection(), 
          _buildHourlyFortuneSection(),
          _buildLuckyElementsSection(),
          _buildRelationshipSection(),
          _buildMoneySection(),
          _buildHealthSection(),
          if (_isSpecialDay()) _buildSpecialDaySection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDateHeaderSection() {
    return TossCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(_selectedDate),
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.getTossTextPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLunarDate(_selectedDate),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.getTossTextSecondary(context),
            ),
          ),
          if (_holidayName != null || _specialName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tossBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.tossBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _holidayName ?? _specialName!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.tossBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildOverallScoreSection() {
    final overallScore = 75 + (DateTime.now().millisecond % 25);
    final gradeText = _getGradeText(overallScore);
    final summaryText = _getSummaryText(overallScore);
    
    return TossCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '$overallScore',
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.getTossTextPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(overallScore).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              gradeText,
              style: AppTypography.bodyMedium.copyWith(
                color: _getScoreColor(overallScore),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summaryText,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.getTossTextPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysCoreSection() {
    final todos = PersonalizedFortuneService.getPersonalizedTodos(userProfile);
    final avoids = PersonalizedFortuneService.getPersonalizedAvoids(userProfile);
    
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '오늘의 핵심',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoreItem('✅', '할 일', todos, AppColors.positive),
          const SizedBox(height: 16),
          _buildCoreItem('❌', '피할 일', avoids, AppColors.negative),
          const SizedBox(height: 16),
          _buildAdviceBox(),
        ],
      ),
    );
  }
  
  Widget _buildCoreItem(String icon, String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.getTossTextPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 4),
          child: Text(
            '• $item',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.getTossTextSecondary(context),
            ),
          ),
        )),
      ],
    );
  }
  
  Widget _buildAdviceBox() {
    final advice = PersonalizedFortuneService.getPersonalizedAdvice(userProfile);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getTossIconBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('💡', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.getTossTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyFortuneSection() {
    final hourlyData = PersonalizedFortuneService.getPersonalizedHourlyActivities(userProfile);
    
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '시간대별 운세',
      child: Column(
        children: hourlyData.map((hour) => _buildHourlyItem(hour)).toList(),
      ),
    );
  }
  
  Widget _buildHourlyItem(Map<String, dynamic> hour) {
    final score = hour['score'] as int;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              hour['time'] as String,
              style: AppTypography.bodySmall.copyWith(
                color: _getScoreColor(score),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hour['activity'] as String,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.getTossTextPrimary(context),
              ),
            ),
          ),
          Text(
            '${score}점',
            style: AppTypography.titleSmall.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildLuckyElementsSection() {
    final elements = [
      {'title': '행운의 숫자', 'value': '3, 7, 21', 'icon': '🔢'},
      {'title': '행운의 색상', 'value': '파란색, 은색', 'icon': '🎨'},
      {'title': '행운의 방향', 'value': '동쪽, 남동쪽', 'icon': '🧭'},
      {'title': '행운의 아이템', 'value': '시계, 펜', 'icon': '🍀'},
    ];
    
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '행운 요소',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLuckyElementCard(elements[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildLuckyElementCard(elements[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLuckyElementCard(elements[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildLuckyElementCard(elements[3])),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLuckyElementCard(Map<String, dynamic> element) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getTossIconBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            element['icon'] as String,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            element['title'] as String,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.getTossTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            element['value'] as String,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.getTossTextPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isSpecialDay() {
    return _holidayName != null || _specialName != null;
  }
  
  Widget _buildSpecialDaySection() {
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '특별한 날',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tossBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.tossBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _holidayName ?? _specialName ?? '',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.tossBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '특별한 날에는 평소보다 더 좋은 기운이 함께합니다. 새로운 시작이나 중요한 일을 계획해보세요.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.getTossTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getLunarDate(DateTime date) {
    // 간단한 음력 변환 (실제로는 더 정확한 계산 필요)
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final lunarDay = (dayOfYear % 30) + 1;
    final lunarMonth = ((dayOfYear ~/ 30) + 1) % 12 + 1;
    return '음력 ${lunarMonth}월 ${lunarDay}일';
  }
  
  String _getGradeText(int score) {
    if (score >= 90) return '매우 좋음';
    if (score >= 80) return '좋음';
    if (score >= 70) return '보통';
    if (score >= 60) return '주의';
    return '나쁨';
  }
  
  String _getSummaryText(int score) {
    if (score >= 90) return '오늘은 새로운 시작에 매우 좋은 날입니다';
    if (score >= 80) return '긍정적인 에너지가 함께하는 하루입니다';
    if (score >= 70) return '평온하고 안정적인 하루가 예상됩니다';
    if (score >= 60) return '신중하게 행동하면 좋은 결과를 얻을 수 있어요';
    return '차분히 기다리는 자세가 필요한 날입니다';
  }
  
  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.positive;
    if (score >= 80) return AppColors.tossBlue;
    if (score >= 70) return AppColors.caution;
    return AppColors.negative;
  }

  Widget _buildRelationshipSection() {
    final relationships = PersonalizedFortuneService.getPersonalizedRelationships(userProfile);
    
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '인간관계',
      child: Column(
        children: [
          _buildRelationshipItem(
            '👥',
            '귀인운',
            relationships['lucky'] ?? '나이가 많은 동료나 선배',
            AppColors.positive,
          ),
          const SizedBox(height: 12),
          _buildRelationshipItem(
            '⚠️',
            '주의할 사람',
            relationships['careful'] ?? '감정적인 성향이 강한 사람',
            AppColors.caution,
          ),
          const SizedBox(height: 12),
          _buildRelationshipItem(
            '💕',
            '연애운',
            relationships['love'] ?? '진솔한 대화가 관계를 발전시킴',
            AppColors.tossBlue,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRelationshipItem(String icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.getTossTextPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.getTossTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMoneySection() {
    final moneyScore = 78;
    
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '금전운',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMoneyScoreCard(moneyScore),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '투자/소비 조언',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.getTossTextPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      PersonalizedFortuneService.getPersonalizedMoneyAdvice(userProfile),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.getTossTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoneyScoreCard(int score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getTossIconBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '💰',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '$score점',
            style: AppTypography.titleLarge.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '재물운',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.getTossTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthSection() {
    final healthScore = 82;
    
    return TossSectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: '건강',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildHealthScoreCard(healthScore),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '건강 조언',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.getTossTextPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      PersonalizedFortuneService.getPersonalizedHealthAdvice(userProfile),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.getTossTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthScoreCard(int score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getTossIconBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '🏥',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '$score점',
            style: AppTypography.titleLarge.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '건강운',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.getTossTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    if (isToday) {
      return '오늘 (${DateFormat('M월 d일').format(date)})';
    }

    final isTomorrow = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    if (isTomorrow) {
      return '내일 (${DateFormat('M월 d일').format(date)})';
    }

    return DateFormat('yyyy년 M월 d일').format(date);
  }
}