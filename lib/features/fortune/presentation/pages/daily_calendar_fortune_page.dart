import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/holiday_service.dart';
import '../../../../core/models/holiday_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/event_category_selector.dart';
import '../widgets/event_detail_input_form.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/conditions/daily_fortune_conditions.dart';
import '../../../../services/fortune_history_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/user_statistics_service.dart';

class DailyCalendarFortunePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;

  const DailyCalendarFortunePage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<DailyCalendarFortunePage> createState() => _DailyCalendarFortunePageState();
}

class _DailyCalendarFortunePageState extends ConsumerState<DailyCalendarFortunePage> {
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

  // PageView Controller
  final PageController _pageController = PageController();

  // 운세 결과 상태
  bool _isLoading = false;
  FortuneResult? _fortuneResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEventsForMonth(_focusedDay);
    _initializeFromParams();
  }

  void _initializeFromParams() {
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
  }

  @override
  void dispose() {
    _questionController.dispose();
    _pageController.dispose();
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

  Future<void> _generateFortune() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // 🔮 최적화 시스템: 조건 객체 생성
      final conditions = DailyFortuneConditions(
        period: FortunePeriod.daily,
        category: _selectedCategory,
        emotion: _selectedEmotion,
        question: _questionController.text.trim().isNotEmpty
            ? _questionController.text.trim()
            : null,
      );

      // input_conditions 정규화
      final inputConditions = {
        'date': _selectedDate.toIso8601String(),
        'period': 'daily',
        'is_holiday': _isHoliday,
        'holiday_name': _holidayName,
        'special_name': _specialName,
        // 이벤트 정보
        'category': _selectedCategory?.label,
        'categoryType': _selectedCategory?.name,
        'question': _questionController.text.trim().isNotEmpty
            ? _questionController.text.trim()
            : null,
        'emotion': _selectedEmotion?.label,
        'emotionType': _selectedEmotion?.name,
      };

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'daily_calendar',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions, // ✅ 최적화 활성화!
      );

      if (mounted) {
        setState(() {
          _fortuneResult = fortuneResult;
          _isLoading = false;
        });

        // 히스토리 저장
        await _saveToHistory(fortuneResult);

        // 통계 업데이트
        await _updateStatistics();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToHistory(FortuneResult result) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final historyService = FortuneHistoryService();
      await historyService.saveFortuneResult(
        fortuneType: result.type,
        title: '특정일 운세 - ${DateFormat('yyyy년 MM월 dd일').format(_selectedDate)}',
        summary: result.summary,
        fortuneData: result.data,
      );

      // 최근 본 운세 저장
      final storageService = StorageService();
      await storageService.addRecentFortune(
        'daily_calendar',
        '시간별 운세',
      );
    } catch (e) {
      debugPrint('히스토리 저장 실패: $e');
    }
  }

  Future<void> _updateStatistics() async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final statsService = UserStatisticsService(
        Supabase.instance.client,
        StorageService(),
      );
      await statsService.incrementFortuneCount(
        user.id,
        'daily_calendar',
      );
    } catch (e) {
      debugPrint('통계 업데이트 실패: $e');
    }
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 12),
          _buildSelectedDateInfo(),
          const BottomButtonSpacing(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EventCategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          const BottomButtonSpacing(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    // _selectedCategory가 null이면 빈 화면 (Step1에서 선택 전)
    if (_selectedCategory == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
              debugPrint('상대방 정보 추가');
            },
          ),
          const BottomButtonSpacing(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    bool canProceed = false;
    String buttonText = '';
    VoidCallback? onPressed;

    switch (_currentStep) {
      case 0:
        canProceed = true;
        buttonText = '다음';
        onPressed = () {
          setState(() {
            _currentStep = 1;
          });
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        };
        break;
      case 1:
        canProceed = _selectedCategory != null;
        buttonText = '다음';
        onPressed = canProceed ? () {
          setState(() {
            _currentStep = 2;
          });
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } : null;
        break;
      case 2:
        canProceed = _selectedEmotion != null;
        buttonText = '운세 보기';
        onPressed = canProceed ? () {
          _generateFortune();
        } : null;
        break;
    }

    return TossFloatingProgressButtonPositioned(
      text: buttonText,
      currentStep: _currentStep + 1,
      totalSteps: 3,
      onPressed: onPressed,
      isEnabled: canProceed,
      showProgress: true,
      isVisible: true,
    );
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
              SizedBox(width: 8),
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
          SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (score != null) ...[
            SizedBox(width: 4),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 운세 결과가 있으면 결과 화면 표시
    if (_fortuneResult != null) {
      return Scaffold(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            '시간별 운세',
            style: context.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
              onPressed: () => context.go('/fortune'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // fortune 데이터 추출
              Builder(
                builder: (context) {
                  final fortuneData = _fortuneResult!.data['fortune'] as Map<String, dynamic>? ?? {};
                  final score = fortuneData['total']?['score'] as int?;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 점수
                      if (score != null) ...[
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '${score}점',
                                style: context.displayLarge.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                fortuneData['total']?['title'] as String? ?? '전체 운세',
                                style: context.heading3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // AI 인사이트
                      if (fortuneData['ai_insight'] != null) ...[
                        _buildSectionCard(
                          icon: Icons.lightbulb_outline,
                          title: 'AI 인사이트',
                          content: fortuneData['ai_insight'] as String,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 카테고리별 운세
                      if (fortuneData['categories'] != null) ...[
                        _buildCategoriesSection(fortuneData['categories'] as Map<String, dynamic>, isDark),
                        const SizedBox(height: 16),
                      ],

                      // 조언
                      if (fortuneData['advice'] != null) ...[
                        _buildSectionCard(
                          icon: Icons.tips_and_updates,
                          title: '조언',
                          content: fortuneData['advice'] as String,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // AI 팁
                      if (fortuneData['ai_tips'] != null) ...[
                        _buildAITipsList(fortuneData['ai_tips'] as List, isDark),
                        const SizedBox(height: 16),
                      ],

                      // 주의사항
                      if (fortuneData['caution'] != null) ...[
                        _buildSectionCard(
                          icon: Icons.warning_amber_rounded,
                          title: '주의사항',
                          content: fortuneData['caution'] as String,
                          isDark: isDark,
                          isWarning: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // 로딩 중
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    // 에러 발생
    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '운세 생성 실패',
                style: context.heading3.copyWith(
                  color: TossDesignSystem.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: context.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    // 기본 입력 폼
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () {
            // Step이 0보다 크면 이전 단계로, 0이면 페이지 나가기
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          '시간별 운세',
          style: context.heading4.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep0(),
              _buildStep1(),
              _buildStep2(),
            ],
          ),

          // Floating Progress Button
          _buildFloatingButton(),
        ],
      ),
    );
  }

  // 섹션 카드 빌더
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
    bool isWarning = false,
  }) {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning
                  ? TossDesignSystem.errorRed
                  : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.heading4.copyWith(
                  color: isWarning
                    ? TossDesignSystem.errorRed
                    : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: context.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리별 운세 섹션
  Widget _buildCategoriesSection(Map<String, dynamic> categories, bool isDark) {
    final categoryData = [
      {'key': 'love', 'title': '애정 운세', 'icon': Icons.favorite_outline, 'color': Colors.pink},
      {'key': 'work', 'title': '직장 운세', 'icon': Icons.work_outline, 'color': Colors.blue},
      {'key': 'money', 'title': '금전 운세', 'icon': Icons.attach_money, 'color': Colors.green},
      {'key': 'study', 'title': '학업 운세', 'icon': Icons.school_outlined, 'color': Colors.orange},
      {'key': 'health', 'title': '건강 운세', 'icon': Icons.favorite_border, 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '카테고리별 운세',
            style: context.heading4.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
        ),
        ...categoryData.map((cat) {
          final categoryInfo = categories[cat['key']];
          if (categoryInfo == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TossCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['title'] as String,
                        style: context.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${categoryInfo['score']}점',
                          style: context.labelMedium.copyWith(
                            color: cat['color'] as Color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryInfo['title'] as String,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryInfo['advice'] as String,
                    style: context.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // 전체 운세
        if (categories['total'] != null) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TossCard(
              padding: const EdgeInsets.all(20),
              style: TossCardStyle.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '전체 운세',
                        style: context.heading4.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${categories['total']['score']}점',
                          style: context.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (categories['total']['advice'] is Map) ...[
                    // advice가 Map 구조인 경우 (idiom + description)
                    Text(
                      (categories['total']['advice'] as Map)['idiom'] as String? ?? '',
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (categories['total']['advice'] as Map)['description'] as String? ?? '',
                      style: context.bodyMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        height: 1.6,
                      ),
                    ),
                  ] else ...[
                    // advice가 String인 경우 (하위 호환)
                    Text(
                      categories['total']['advice'] as String? ?? '',
                      style: context.bodyMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // AI 팁 리스트
  Widget _buildAITipsList(List tips, bool isDark) {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 팁',
                style: context.heading4.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.labelSmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: context.bodyMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
