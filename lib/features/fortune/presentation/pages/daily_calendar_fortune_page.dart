import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/services/personalized_fortune_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/holiday_service.dart';
import '../../../../core/models/holiday_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/event_category_selector.dart';
import '../widgets/event_detail_input_form.dart';

class DailyCalendarFortunePage extends BaseFortunePage {
  const DailyCalendarFortunePage({
    super.key,
    super.initialParams,
  }) : super(
          title: '시간별 운세',
          description: '선택한 날짜의 전체적인 운세를 확인하세요',
          fortuneType: 'daily_calendar',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<DailyCalendarFortunePage> createState() => _DailyCalendarFortunePageState();
}

class _DailyCalendarFortunePageState extends BaseFortunePageState<DailyCalendarFortunePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _holidayName;
  String? _specialName;
  bool _isHoliday = false;
  Map<DateTime, CalendarEventInfo> _events = {};
  final HolidayService _holidayService = HolidayService();

  // 이벤트 입력 관련 상태
  EventCategory? _selectedCategory;
  EmotionState? _selectedEmotion;
  final TextEditingController _questionController = TextEditingController();

  // UI 단계 (0: 캘린더 선택, 1: 카테고리 선택, 2: 상세 입력)
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadEventsForMonth(_focusedDay);
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadEventsForMonth(DateTime month) async {
    try {
      final events = await _holidayService.getEventsForMonth(month);
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDate, selectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDay = focusedDay;

          // 선택된 날짜의 이벤트 정보 업데이트
          final eventInfo = _events[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];
          _isHoliday = eventInfo?.isHoliday ?? false;
          _holidayName = eventInfo?.holidayName;
          _specialName = eventInfo?.specialName;
        });
      }
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    if (mounted) {
      setState(() {
        _focusedDay = focusedDay;
      });
      _loadEventsForMonth(focusedDay);
    }
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // UnifiedFortuneService 사용
    final fortuneService = UnifiedFortuneService(Supabase.instance.client);

    // input_conditions 정규화
    final inputConditions = {
      'date': _selectedDate.toIso8601String(),
      'period': 'daily',
      'is_holiday': _isHoliday,
      'holiday_name': _holidayName,
      'special_name': _specialName,
    };

    final fortuneResult = await fortuneService.getFortune(
      fortuneType: 'daily_calendar',
      dataSource: FortuneDataSource.api,
      inputConditions: inputConditions,
    );

    // FortuneResult → Fortune 엔티티 변환
    return _convertToFortune(fortuneResult);
  }

  /// FortuneResult를 Fortune 엔티티로 변환
  Fortune _convertToFortune(FortuneResult result) {
    return Fortune(
      id: result.id ?? '',
      userId: ref.read(userProvider).value?.id ?? '',
      type: result.type,
      content: result.data['content'] as String? ?? result.summary.toString(),
      createdAt: DateTime.now(),
      overallScore: result.score,
      summary: result.summary['message'] as String?,
      metadata: result.data,
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

      // 이벤트 정보
      'category': _selectedCategory?.label,
      'categoryType': _selectedCategory?.name,
      'question': _questionController.text.trim().isNotEmpty ? _questionController.text.trim() : null,
      'emotion': _selectedEmotion?.label,
      'emotionType': _selectedEmotion?.name,
    };
  }

  @override
  Widget buildInputForm() {
    return Column(
      children: [
        // Step 1: 캘린더 선택
        if (_currentStep == 0) ...[
          _buildCalendar(),
          const SizedBox(height: 12),
          _buildSelectedDateInfo(),
          const SizedBox(height: 12),
          _buildNextStepButton(),
        ],

        // Step 2: 카테고리 선택
        if (_currentStep == 1) ...[
          _buildStepIndicator(),
          const SizedBox(height: 16),
          EventCategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNavigationButtons(),
        ],

        // Step 3: 상세 입력
        if (_currentStep == 2 && _selectedCategory != null) ...[
          _buildStepIndicator(),
          const SizedBox(height: 16),
          EventDetailInputForm(
            category: _selectedCategory!,
            questionController: _questionController,
            selectedEmotion: _selectedEmotion,
            onEmotionSelected: (emotion) {
              setState(() {
                _selectedEmotion = emotion;
              });
            },
            onAddPartner: () {
              // TODO: 상대방 정보 입력 다이얼로그
              debugPrint('상대방 정보 추가');
            },
          ),
          const SizedBox(height: 12),
          _buildNavigationButtons(),
        ],
      ],
    );
  }

  Widget _buildStepIndicator() {
    return TossCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepDot(0, '날짜'),
          _buildStepLine(0),
          _buildStepDot(1, '유형'),
          _buildStepLine(1),
          _buildStepDot(2, '입력'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? TossDesignSystem.white : TossDesignSystem.gray600,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
                : (isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600),
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;

    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive
          ? AppTheme.primaryColor
          : (Theme.of(context).brightness == Brightness.dark
              ? TossDesignSystem.grayDark300
              : TossDesignSystem.gray300),
    );
  }

  Widget _buildNextStepButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentStep = 1;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: TossDesignSystem.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '다음',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final canProceed = _currentStep == 1 ? _selectedCategory != null : _selectedEmotion != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 이전 버튼
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '이전',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 다음/완료 버튼
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (_currentStep == 2) {
                        // 운세 생성
                        _generateFortuneWithEventDetails();
                      } else {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: TossDesignSystem.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 2 ? '운세 보기' : '다음',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateFortuneWithEventDetails() async {
    // BaseFortunePage의 운세 생성 트리거
    // generateFortuneParams에서 이벤트 정보를 포함하도록 수정
    // 운세 생성 호출 (BaseFortunePage에서 처리)
    await generateFortuneAction();
  }

  Widget _buildCalendar() {
    final theme = Theme.of(context);

    return TossCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: TableCalendar<CalendarEventInfo>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.month: '월',
          CalendarFormat.week: '주',
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        eventLoader: (day) {
          final event = _events[DateTime(day.year, day.month, day.day)];
          return event != null ? [event] : [];
        },
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: _onPageChanged,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: TossDesignSystem.errorRed),
          holidayTextStyle: const TextStyle(color: TossDesignSystem.errorRed),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: _buildCalendarCell,
          selectedBuilder: _buildCalendarCell,
          todayBuilder: _buildCalendarCell,
          outsideBuilder: _buildCalendarCell,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
          titleTextStyle: (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
          ),
          titleTextFormatter: (date, locale) => DateFormat('yyyy년 M월', 'ko_KR').format(date),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          weekendStyle: TextStyle(color: TossDesignSystem.errorRed.withValues(alpha: 0.7)),
        ),
        daysOfWeekHeight: 40,
        locale: 'ko_KR',
      ),
    );
  }

  Widget _buildCalendarCell(BuildContext context, DateTime day, DateTime focusedDay) {
    final theme = Theme.of(context);
    final isSelected = isSameDay(day, _selectedDate);
    final isToday = isSameDay(day, DateTime.now());
    final isPastDate = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    final eventInfo = _events[DateTime(day.year, day.month, day.day)];
    final isHoliday = eventInfo?.isHoliday ?? false;
    final isSpecial = eventInfo?.isSpecial ?? false;
    final isAuspicious = eventInfo?.isAuspicious ?? false;
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color textColor = theme.colorScheme.onSurface;
    Color? backgroundColor;
    Color? borderColor;

    if (isPastDate) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = TossDesignSystem.white;
    } else if (isToday) {
      borderColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
    } else if (isHoliday || (isWeekend && !isPastDate)) {
      textColor = TossDesignSystem.errorRed;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // 이벤트 표시 점들
          if (isHoliday || isSpecial || isAuspicious) ...[
            Positioned(
              right: 2,
              top: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHoliday)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isSpecial)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isAuspicious)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final theme = Theme.of(context);
    final eventInfo = _events[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)];

    return TossCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          // 이벤트 정보 표시
          if (eventInfo != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (eventInfo.holidayName != null)
                  _buildEventTag(
                    icon: Icons.celebration,
                    label: eventInfo.holidayName!,
                    color: TossDesignSystem.errorRed,
                  ),
                if (eventInfo.specialName != null)
                  _buildEventTag(
                    icon: Icons.star,
                    label: eventInfo.specialName!,
                    color: TossDesignSystem.warningOrange,
                  ),
                if (eventInfo.auspiciousName != null)
                  _buildEventTag(
                    icon: Icons.home,
                    label: eventInfo.auspiciousName!,
                    color: TossDesignSystem.warningOrange,
                    score: eventInfo.auspiciousScore,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventTag({
    required IconData icon,
    required String label,
    required Color color,
    int? score,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (score != null) ...[
            const SizedBox(width: 4),
            Text(
              '$score점',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildFortuneResult() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? TossDesignSystem.backgroundDark
        : TossDesignSystem.backgroundLight;

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        controller: scrollController,
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
            style: TossDesignSystem.heading1.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(overallScore).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              gradeText,
              style: TossDesignSystem.body2.copyWith(
                color: _getScoreColor(overallScore),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summaryText,
            style: TossDesignSystem.body1.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
          _buildCoreItem('✅', '할 일', todos, TossDesignSystem.successGreen),
          const SizedBox(height: 16),
          _buildCoreItem('❌', '피할 일', avoids, TossDesignSystem.errorRed),
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
              style: TossDesignSystem.heading3.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
            style: TossDesignSystem.body2.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('💡', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: TossDesignSystem.body2.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              hour['time'] as String,
              style: TossDesignSystem.body3.copyWith(
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
              style: TossDesignSystem.body2.copyWith(
                color: isDarkMode ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
          ),
          Text(
            '$score점',
            style: TossDesignSystem.heading4.copyWith(
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
        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
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
            style: TossDesignSystem.body3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            element['value'] as String,
            style: TossDesignSystem.heading4.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
          color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _holidayName ?? _specialName ?? '',
              style: TossDesignSystem.heading3.copyWith(
                color: TossDesignSystem.tossBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '특별한 날에는 평소보다 더 좋은 기운이 함께합니다. 새로운 시작이나 중요한 일을 계획해보세요.',
              style: TossDesignSystem.body2.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
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
    return '음력 $lunarMonth월 $lunarDay일';
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
    if (score >= 90) return TossDesignSystem.successGreen;
    if (score >= 80) return TossDesignSystem.tossBlue;
    if (score >= 70) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
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
            TossDesignSystem.successGreen,
          ),
          const SizedBox(height: 12),
          _buildRelationshipItem(
            '⚠️',
            '주의할 사람',
            relationships['careful'] ?? '감정적인 성향이 강한 사람',
            TossDesignSystem.warningOrange,
          ),
          const SizedBox(height: 12),
          _buildRelationshipItem(
            '💕',
            '연애운',
            relationships['love'] ?? '진솔한 대화가 관계를 발전시킴',
            TossDesignSystem.tossBlue,
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
            color: color.withValues(alpha: 0.1),
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
                style: TossDesignSystem.heading4.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TossDesignSystem.body2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
                      style: TossDesignSystem.heading4.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      PersonalizedFortuneService.getPersonalizedMoneyAdvice(userProfile),
                      style: TossDesignSystem.body3.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
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
            style: TossDesignSystem.heading2.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '재물운',
            style: TossDesignSystem.body3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
                      style: TossDesignSystem.heading4.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      PersonalizedFortuneService.getPersonalizedHealthAdvice(userProfile),
                      style: TossDesignSystem.body3.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
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
            style: TossDesignSystem.heading2.copyWith(
              color: _getScoreColor(score),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '건강운',
            style: TossDesignSystem.body3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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