// ✅ ImageFilter.blur용 (deprecated - UnifiedBlurWrapper 사용)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/services/debug_premium_service.dart';
import '../../../../../core/models/fortune_result.dart';
import '../../../../../core/services/holiday_service.dart';
import '../../../../../core/models/holiday_models.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../domain/models/conditions/daily_fortune_conditions.dart';
import '../../../../../services/fortune_history_service.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../services/user_statistics_service.dart';
import '../../../../../services/ad_service.dart';
import '../../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../core/services/unified_calendar_service.dart';
import '../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../widgets/event_category_selector.dart';
import '../../widgets/event_detail_input_form.dart';

// 모듈화된 위젯들
import 'widgets/calendar_sync_banner.dart';
import 'widgets/calendar_options_dialog.dart';
import 'widgets/calendar_view_widget.dart';
import 'widgets/date_info_widget.dart';
import 'widgets/fortune_result_sections.dart';

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
  bool _showResultView = false;  // 결과 화면 표시 여부 (API 완료 전에도 true)
  FortuneResult? _fortuneResult;
  String? _error;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ✅ 타이핑 효과 상태 관리
  int _currentTypingSection = 0;  // 0: AI 인사이트, 1: 카테고리, 2: 조언, 3: AI 팁, 4: 주의사항

  // 캘린더 연동 상태 (통합 서비스)
  final UnifiedCalendarService _calendarService = UnifiedCalendarService();
  List<CalendarEventSummary> _deviceEvents = [];
  final List<CalendarEventSummary> _selectedEvents = [];

  // 캘린더 연동 배너 상태 (토스 스타일)
  bool _showCalendarBanner = true;
  bool _isCalendarSynced = false;
  bool _isSyncingCalendar = false;
  bool _showGoogleCalendarOption = false;

  @override
  void initState() {
    super.initState();
    _loadEventsForMonth(_focusedDay);
    _initializeFromParams();
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    try {
      await _calendarService.initialize();

      if (_calendarService.isGoogleConnected) {
        debugPrint('[Calendar] ✅ Google Calendar 연동됨: ${_calendarService.googleEmail}');
        if (mounted) {
          setState(() {
            _showCalendarBanner = false;
            _isCalendarSynced = true;
          });
        }
        await _syncAllCalendars();
        return;
      }

      final hasDevicePermission = await _calendarService.requestDevicePermission();

      if (hasDevicePermission) {
        debugPrint('[Calendar] ✅ 디바이스 캘린더 권한 확인됨 - 자동 동기화 시작');
        if (mounted) {
          setState(() {
            _isCalendarSynced = true;
            _showCalendarBanner = false;  // 권한 허용 시 항상 배너 숨김
          });
        }
        await _syncAllCalendars();

        // 이벤트가 없어도 Google Calendar 배너를 바로 보여주지 않음
        // 사용자 경험 개선: 권한 허용 후 바로 다른 배너가 뜨면 혼란스러움
        if (_deviceEvents.isEmpty) {
          debugPrint('[Calendar] ℹ️ 오늘 날짜에 디바이스 캘린더 이벤트 없음');
        }
      } else {
        debugPrint('[Calendar] ⚠️ 캘린더 권한 없음 - 배너 표시');
      }
    } catch (e) {
      debugPrint('[Calendar] 초기화 실패: $e');
    }
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

  Future<void> _syncAllCalendars({bool showSnackbar = true}) async {
    if (_isSyncingCalendar) return;

    setState(() {
      _isSyncingCalendar = true;
    });

    try {
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final eventsByDate = await _calendarService.getEventsForDateRange(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      if (mounted) {
        setState(() {
          for (var entry in eventsByDate.entries) {
            final date = entry.key;
            final events = entry.value;

            if (_events[date] == null) {
              _events[date] = CalendarEventInfo(
                date: date,
                hasDeviceEvents: true,
                deviceEventCount: events.length,
              );
            } else {
              _events[date] = _events[date]!.copyWith(
                hasDeviceEvents: true,
                deviceEventCount: events.length,
              );
            }
          }
          _isCalendarSynced = true;
        });

        if (showSnackbar && eventsByDate.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${eventsByDate.length}일의 일정을 불러왔습니다'),
              backgroundColor: TossDesignSystem.successGreen,
            ),
          );
        }

        await _loadDeviceEventsForDate(_selectedDate);
      }
    } catch (e) {
      debugPrint('Error syncing calendar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('캘린더 동기화 중 오류가 발생했습니다: $e'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingCalendar = false;
        });
      }
    }
  }

  Future<void> _loadDeviceEventsForDate(DateTime date) async {
    try {
      final events = await _calendarService.getEventsForDate(date);
      if (mounted) {
        setState(() {
          _deviceEvents = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading device events: $e');
    }
  }

  Future<void> _connectGoogleCalendar() async {
    setState(() {
      _isSyncingCalendar = true;
    });

    try {
      final connected = await _calendarService.connectGoogleCalendar();

      if (connected) {
        if (mounted) {
          setState(() {
            _showCalendarBanner = false;
            _showGoogleCalendarOption = false;
            _isCalendarSynced = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Calendar 연동 완료: ${_calendarService.googleEmail}'),
              backgroundColor: TossDesignSystem.successGreen,
            ),
          );

          await _syncAllCalendars(showSnackbar: false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Calendar 연동이 취소되었습니다'),
              backgroundColor: TossDesignSystem.warningOrange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Google Calendar 연동 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Calendar 연동 실패: $e'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingCalendar = false;
        });
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDate, selectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDay = focusedDay;

          final eventInfo = _events[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];
          _isHoliday = eventInfo?.isHoliday ?? false;
          _holidayName = eventInfo?.holidayName;
          _specialName = eventInfo?.specialName;
        });

        if (_isCalendarSynced) {
          _loadDeviceEventsForDate(selectedDay);
        }
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
    if (mounted) {
      setState(() {
        _isLoading = true;
        _showResultView = true;  // 즉시 결과 화면으로 전환 (커서 깜빡임 표시)
        _error = null;
        _fortuneResult = null;  // 이전 결과 초기화
        _currentTypingSection = 0;  // 타이핑 섹션 초기화
      });
    }

    try {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔮 [시간별운세] 운세 생성 프로세스 시작');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      debugPrint('');
      debugPrint('1️⃣ 프리미엄 상태 확인');
      debugPrint('   - 최종 isPremium: $isPremium');

      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      final conditions = DailyFortuneConditions(
        period: FortunePeriod.daily,
        category: _selectedCategory,
        emotion: _selectedEmotion,
        question: _questionController.text.trim().isNotEmpty
            ? _questionController.text.trim()
            : null,
      );

      final inputConditions = {
        'date': _selectedDate.toIso8601String(),
        'period': 'daily',
        'is_holiday': _isHoliday,
        'holiday_name': _holidayName,
        'special_name': _specialName,
        'category': _selectedCategory?.label,
        'categoryType': _selectedCategory?.name,
        'question': _questionController.text.trim().isNotEmpty
            ? _questionController.text.trim()
            : null,
        'emotion': _selectedEmotion?.label,
        'emotionType': _selectedEmotion?.name,
        'calendar_events': _selectedEvents.map((e) => {
          'title': e.title,
          'description': e.description,
          'start_time': e.startTime?.toIso8601String(),
          'end_time': e.endTime?.toIso8601String(),
          'location': e.location,
          'is_all_day': e.isAllDay,
        }).toList(),
        'has_calendar_events': _selectedEvents.isNotEmpty,
        'event_count': _selectedEvents.length,
      };

      debugPrint('');
      debugPrint('2️⃣ 운세 조건 준비');
      debugPrint('   - 선택 날짜: $_selectedDate');
      debugPrint('   - 캘린더 이벤트: ${_selectedEvents.isEmpty ? "없음" : "${_selectedEvents.length}개"}');

      debugPrint('');
      debugPrint('3️⃣ UnifiedFortuneService.getFortune() 호출');

      final startTime = DateTime.now();

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'daily_calendar',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions,
        isPremium: isPremium,
      );

      debugPrint('');
      debugPrint('4️⃣ 운세 생성 완료');

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remainingTime = 1000 - elapsed;

      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }

      if (mounted) {
        setState(() {
          _fortuneResult = fortuneResult;
          _isLoading = false;
          _isBlurred = fortuneResult.isBlurred;
          _blurredSections = List<String>.from(fortuneResult.blurredSections);
          // 타이핑 효과 초기화 (새 운세 결과가 로드될 때)
          _currentTypingSection = 0;
        });

        debugPrint('');
        debugPrint('5️⃣ UI 상태 업데이트 완료');

        await _saveToHistory(fortuneResult);
        await _updateStatistics();

        debugPrint('');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('✅ [시간별운세] 운세 생성 프로세스 완료!');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('');
      }
    } catch (e) {
      debugPrint('');
      debugPrint('❌ [시간별운세] 운세 생성 실패!');
      debugPrint('   에러: $e');
      debugPrint('');

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

  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) return;

    try {
      final adService = AdService();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중...'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러오지 못했습니다. 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
              // 블러 해제 후 블러 섹션(조언)부터 타이핑 시작
              _currentTypingSection = 2;
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
      debugPrint('광고 표시 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  void _showCalendarOptionsDialog() {
    CalendarOptionsDialog.show(
      context,
      onDeviceCalendarSelected: () async {
        return await _calendarService.requestDevicePermission();
      },
      onGoogleCalendarSelected: _connectGoogleCalendar,
      onSyncComplete: () async {
        setState(() {
          _showCalendarBanner = false;
          _isCalendarSynced = true;
        });
        await _syncAllCalendars();
      },
      onPermissionDenied: () {
        PermissionDeniedDialog.show(context);
      },
    );
  }

  void _goToNextStep() {
    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_showCalendarBanner && !_isCalendarSynced)
            CalendarSyncBanner(
              onTap: _showCalendarOptionsDialog,
              onClose: () => setState(() => _showCalendarBanner = false),
            ),
          if (_showCalendarBanner && !_isCalendarSynced) const SizedBox(height: 12),

          if (_showGoogleCalendarOption)
            GoogleCalendarBanner(
              onTap: _connectGoogleCalendar,
              onClose: () => setState(() => _showGoogleCalendarOption = false),
            ),
          if (_showGoogleCalendarOption) const SizedBox(height: 12),

          CalendarViewWidget(
            focusedDay: _focusedDay,
            selectedDate: _selectedDate,
            calendarFormat: _calendarFormat,
            events: _events,
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onPageChanged: _onPageChanged,
          ),
          const SizedBox(height: 12),
          DateInfoWidget(
            selectedDate: _selectedDate,
            events: _events,
            isCalendarSynced: _isCalendarSynced,
            deviceEvents: _deviceEvents,
            selectedEvents: _selectedEvents,
            onEventToggle: (event) {
              setState(() {
                if (_selectedEvents.contains(event)) {
                  _selectedEvents.remove(event);
                } else {
                  _selectedEvents.add(event);
                }
              });
            },
          ),
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
        onPressed = _goToNextStep;
        break;
      case 1:
        canProceed = _selectedCategory != null;
        buttonText = '다음';
        onPressed = canProceed ? _goToNextStep : null;
        break;
      case 2:
        canProceed = _selectedEmotion != null;
        buttonText = '운세 보기';
        onPressed = canProceed ? _generateFortune : null;
        break;
    }

    return UnifiedButton.progress(
      text: buttonText,
      currentStep: _currentStep + 1,
      totalSteps: 3,
      onPressed: onPressed,
      isEnabled: canProceed,
      isFloating: true,
      isLoading: _isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 결과 화면 표시 (로딩 중이거나 결과가 있을 때)
    if (_showResultView) {
      return _buildResultScaffold(isDark);
    }

    // 에러 발생
    if (_error != null) {
      return _buildErrorScaffold(isDark);
    }

    // 기본 입력 폼
    return _buildInputFormScaffold(isDark);
  }

  Widget _buildResultScaffold(bool isDark) {
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: _isLoading && _fortuneResult == null
                ? _buildLoadingContent(isDark)  // API 대기 중: 커서 깜빡임
                : _buildFortuneResultContent(isDark),  // 결과 수신: 타이핑 시작
          ),
          if (_isBlurred && _fortuneResult != null)
            UnifiedButton.floating(
              text: '광고 보고 전체 내용 확인하기',
              onPressed: _showAdAndUnblur,
              isLoading: false,
              isEnabled: true,
            ),
        ],
      ),
    );
  }

  /// API 대기 중 커서 깜빡임 표시
  Widget _buildLoadingContent(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '운세를 불러오는 중...',
              style: context.buttonMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            TypingLoadingIndicator(
              style: context.heading3.copyWith(
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneResultContent(bool isDark) {
    final fortuneData = _fortuneResult!.data['fortune'] as Map<String, dynamic>? ?? {};
    final categories = fortuneData['categories'] as Map<String, dynamic>? ?? {};
    final totalFortune = categories['total'] as Map<String, dynamic>?;
    final score = totalFortune?['score'] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 총운 (점수 + 내용) - 맨 처음
        if (totalFortune != null) ...[
          Center(
            child: Column(
              children: [
                if (score != null) ...[
                  Text(
                    '$score점',
                    style: context.displayLarge.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  totalFortune['title'] as String? ?? '오늘의 총운',
                  style: context.heading3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 총운 내용 (타이핑 효과)
          TypingTotalFortuneSection(
            total: totalFortune,
            isDark: isDark,
            startTyping: _currentTypingSection >= 0,
            onTypingComplete: () {
              if (mounted) {
                setState(() => _currentTypingSection = 1);
              }
            },
          ),
          const SizedBox(height: 24),
        ],

        // 2. AI 인사이트 (타이핑 효과)
        if (fortuneData['ai_insight'] != null) ...[
          TypingFortuneSectionCard(
            icon: Icons.lightbulb_outline,
            title: 'AI 인사이트',
            content: FortuneTextCleaner.clean(fortuneData['ai_insight'] as String),
            isDark: isDark,
            startTyping: _currentTypingSection >= 1,
            onTypingComplete: () {
              if (mounted) {
                setState(() => _currentTypingSection = 2);
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        // 3. 카테고리별 운세 (타이핑 효과) - 총운 제외
        if (categories.isNotEmpty) ...[
          TypingCategoriesSection(
            categories: categories,
            isDark: isDark,
            showTotal: false,  // 총운은 위에서 이미 표시
            startTyping: _currentTypingSection >= 2,
            onTypingComplete: () {
              if (mounted) {
                setState(() => _currentTypingSection = 3);
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        // 4. 조언 (블러 대상 + 타이핑 효과)
        if (fortuneData['advice'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'advice',
            child: TypingFortuneSectionCard(
              icon: Icons.tips_and_updates,
              title: '조언',
              content: FortuneTextCleaner.clean(fortuneData['advice'] as String),
              isDark: isDark,
              startTyping: !_isBlurred && _currentTypingSection >= 3,
              onTypingComplete: () {
                if (mounted) {
                  setState(() => _currentTypingSection = 4);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 5. AI 팁 (블러 대상 + 타이핑 효과)
        if (fortuneData['ai_tips'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'ai_tips',
            child: TypingAITipsList(
              tips: fortuneData['ai_tips'] as List,
              isDark: isDark,
              startTyping: !_isBlurred && _currentTypingSection >= 4,
              onTypingComplete: () {
                if (mounted) {
                  setState(() => _currentTypingSection = 5);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 6. 주의사항 (블러 대상 + 타이핑 효과)
        if (fortuneData['caution'] != null) ...[
          UnifiedBlurWrapper(
            isBlurred: _isBlurred,
            blurredSections: _blurredSections,
            sectionKey: 'caution',
            child: TypingFortuneSectionCard(
              icon: Icons.warning_amber_rounded,
              title: '주의사항',
              content: FortuneTextCleaner.clean(fortuneData['caution'] as String),
              isDark: isDark,
              isWarning: true,
              startTyping: !_isBlurred && _currentTypingSection >= 5,
              onTypingComplete: () {
                debugPrint('✅ 모든 섹션 타이핑 완료');
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildErrorScaffold(bool isDark) {
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

  Widget _buildInputFormScaffold(bool isDark) {
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
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep0(),
              _buildStep1(),
              _buildStep2(),
            ],
          ),
          _buildFloatingButton(),
        ],
      ),
    );
  }
}
