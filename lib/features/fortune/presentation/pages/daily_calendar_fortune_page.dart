// ✅ ImageFilter.blur용 (deprecated - UnifiedBlurWrapper 사용)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/services/holiday_service.dart';
import '../../../../core/models/holiday_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/event_category_selector.dart';
import '../widgets/event_detail_input_form.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/conditions/daily_fortune_conditions.dart';
import '../../../../services/fortune_history_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/user_statistics_service.dart';
// ✅ Phase 10: BlurredFortuneContent 제거 - _buildBlurWrapper 사용
import '../../../../services/ad_service.dart';
import '../../../../core/widgets/toss_info_banner.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/services/device_calendar_service.dart';

import '../../../../core/widgets/unified_button.dart';
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

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // 디바이스 캘린더 연동 상태
  final DeviceCalendarService _calendarService = DeviceCalendarService();
  List<CalendarEventSummary> _deviceEvents = [];
  final List<CalendarEventSummary> _selectedEvents = [];

  // 캘린더 연동 배너 상태 (토스 스타일)
  bool _showCalendarBanner = true;
  bool _isCalendarSynced = false;
  bool _isSyncingCalendar = false;

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

  Future<void> _syncDeviceCalendar() async {
    if (_isSyncingCalendar) return;

    setState(() {
      _isSyncingCalendar = true;
    });

    try {
      // 바로 권한 요청 (Permission Priming 제거)
      final hasPermission = await _calendarService.requestCalendarPermission();
      if (!hasPermission) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }

      // 2. 한 달치 이벤트 로드
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final eventsByDate = await _calendarService.getEventsForDateRange(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      // 3. 기존 _events에 디바이스 캘린더 정보 병합
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${eventsByDate.length}일의 일정을 불러왔습니다'),
            backgroundColor: TossDesignSystem.successGreen,
          ),
        );
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
      final events = await _calendarService.getEventSummariesForDate(date);
      if (mounted) {
        setState(() {
          _deviceEvents = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading device events: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
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

        // 디바이스 캘린더 이벤트 로드
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
    // ✅ 1단계: 즉시 로딩 상태 표시 (버튼 애니메이션 시작)
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔮 [시간별운세] 운세 생성 프로세스 시작');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 1️⃣ 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final premiumOverride = await DebugPremiumService.getOverrideValue();
      final isPremium = premiumOverride ?? tokenState.hasUnlimitedAccess;

      debugPrint('');
      debugPrint('1️⃣ 프리미엄 상태 확인');
      debugPrint('   - tokenState.hasUnlimitedAccess: ${tokenState.hasUnlimitedAccess}');
      debugPrint('   - premiumOverride: $premiumOverride');
      debugPrint('   - 최종 isPremium: $isPremium');
      debugPrint('   → ${isPremium ? "✅ 프리미엄 사용자 (블러 없음)" : "❌ 일반 사용자 (블러 적용)"}');

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
        // 디바이스 캘린더 이벤트
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
      debugPrint('   - 카테고리: ${_selectedCategory?.label ?? "없음"}');
      debugPrint('   - 감정: ${_selectedEmotion?.label ?? "없음"}');
      debugPrint('   - 질문: ${_questionController.text.trim().isNotEmpty ? "있음" : "없음"}');
      debugPrint('   - 공휴일: ${_isHoliday ? "예 ($_holidayName)" : "아니오"}');
      debugPrint('   - 캘린더 이벤트: ${_selectedEvents.isEmpty ? "없음" : "${_selectedEvents.length}개"}');
      if (_selectedEvents.isNotEmpty) {
        for (var event in _selectedEvents) {
          debugPrint('      • ${event.title}${event.location != null ? " (${event.location})" : ""}');
        }
      }

      // 2️⃣ isPremium 파라미터와 함께 운세 생성
      debugPrint('');
      debugPrint('3️⃣ UnifiedFortuneService.getFortune() 호출');
      debugPrint('   - fortuneType: daily_calendar');
      debugPrint('   - dataSource: FortuneDataSource.api');
      debugPrint('   - isPremium: $isPremium');
      debugPrint('   → API 호출 시작...');

      // ✅ 2단계: 타이머 시작 (최소 1초 보장)
      final startTime = DateTime.now();

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'daily_calendar',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
        conditions: conditions, // ✅ 최적화 활성화!
        isPremium: isPremium, // ✅ 프리미엄 상태 전달
      );

      debugPrint('');
      debugPrint('4️⃣ 운세 생성 완료');
      debugPrint('   - fortuneResult.isBlurred: ${fortuneResult.isBlurred}');
      debugPrint('   - fortuneResult.blurredSections: ${fortuneResult.blurredSections}');
      debugPrint('   - 데이터 크기: ${fortuneResult.data.toString().length} bytes');

      // ✅ 3단계: 무조건 최소 1초 대기 (API가 빨라도 버튼 애니메이션 보장)
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remainingTime = 1000 - elapsed;

      if (remainingTime > 0) {
        debugPrint('');
        debugPrint('⏳ 버튼 로딩 애니메이션 표시 중... (${remainingTime}ms 추가 대기)');
        await Future.delayed(Duration(milliseconds: remainingTime));
      } else {
        debugPrint('');
        debugPrint('✅ API 호출 완료 (${elapsed}ms) - 즉시 결과 표시');
      }

      if (mounted) {
        setState(() {
          _fortuneResult = fortuneResult; // 3️⃣ fortuneResult.isBlurred 속성 포함
          _isLoading = false;

          // ✅ result.isBlurred 동기화
          _isBlurred = fortuneResult.isBlurred;
          _blurredSections = List<String>.from(fortuneResult.blurredSections);
        });

        debugPrint('');
        debugPrint('5️⃣ UI 상태 업데이트 완료');

        // 히스토리 저장
        debugPrint('');
        debugPrint('6️⃣ 히스토리 저장 시작...');
        await _saveToHistory(fortuneResult);

        // 통계 업데이트
        debugPrint('');
        debugPrint('7️⃣ 통계 업데이트 시작...');
        await _updateStatistics();

        debugPrint('');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('✅ [시간별운세] 운세 생성 프로세스 완료!');
        if (fortuneResult.isBlurred) {
          debugPrint('   → 블러된 섹션: ${fortuneResult.blurredSections.join(", ")}');
          debugPrint('   → 사용자는 "광고 보고 잠금 해제" 버튼을 눌러야 합니다');
        } else {
          debugPrint('   → 프리미엄 사용자: 전체 운세 즉시 표시');
        }
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

  // 4️⃣ 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    if (_fortuneResult == null) {
      debugPrint('');
      debugPrint('⚠️ [광고] _fortuneResult가 null입니다. 블러 해제 취소.');
      return;
    }

    try {
      debugPrint('');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📺 [광고] 광고 시청 & 블러 해제 프로세스 시작');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 광고 서비스 초기화 및 로드
      final adService = AdService();

      debugPrint('');
      debugPrint('1️⃣ 광고 준비 상태 확인');
      debugPrint('   - adService.isRewardedAdReady: ${adService.isRewardedAdReady}');

      // 광고가 아직 로드되지 않았으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('   → 광고가 준비되지 않음. 로딩 시작...');

        // 로딩 중 사용자에게 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중...'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        await adService.loadRewardedAd();

        // 광고 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
          debugPrint('   ⏳ 광고 로딩 대기 중... (${waitCount * 500}ms)');
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('   ❌ 광고 로딩 실패 - 타임아웃');
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

        debugPrint('   ✅ 광고 로딩 완료');
      } else {
        debugPrint('   ✅ 광고가 이미 준비됨');
      }

      debugPrint('');
      debugPrint('2️⃣ 리워드 광고 표시');
      debugPrint('   - 현재 블러 상태: isBlurred=${_fortuneResult!.isBlurred}');
      debugPrint('   - 블러된 섹션: ${_fortuneResult!.blurredSections}');
      debugPrint('   - 광고 준비 상태: ${adService.isRewardedAdReady}');
      debugPrint('   → 광고 표시 중...');

      // 리워드 광고 표시 및 완료 대기
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('');
          debugPrint('3️⃣ 광고 시청 완료!');
          debugPrint('   - reward.type: ${reward.type}');
          debugPrint('   - reward.amount: ${reward.amount}');

          // ✅ 광고 시청 완료 시 블러만 해제 (로컬 상태 변경)
          if (mounted) {
            debugPrint('   → 블러 해제 중...');

            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            debugPrint('   ✅ 블러 해제 완료!');
            debugPrint('      - 새 상태: _isBlurred=false');
            debugPrint('      - 새 상태: _blurredSections=[]');

            // 성공 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('운세가 잠금 해제되었습니다!')),
            );

            debugPrint('');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('✅ [광고] 블러 해제 프로세스 완료!');
            debugPrint('   → 사용자는 이제 전체 운세 내용을 볼 수 있습니다');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('');
          } else {
            debugPrint('   ⚠️ Widget이 이미 dispose됨. 블러 해제 취소.');
          }
        },
      );
    } catch (e) {
      debugPrint('');
      debugPrint('❌ [광고] 광고 표시 실패!');
      debugPrint('   에러: $e');
      debugPrint('');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 토스 스타일 캘린더 연동 배너
          if (_showCalendarBanner && !_isCalendarSynced) _buildCalendarBanner(),
          if (_showCalendarBanner && !_isCalendarSynced) const SizedBox(height: 12),
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

    return UnifiedButton.progress(
      text: buttonText,
      currentStep: _currentStep + 1,
      totalSteps: 3,
      onPressed: onPressed,
      isEnabled: canProceed,
      isFloating: true,
      isLoading: _isLoading, // ✅ 로딩 상태 연결!
    );
  }

  Widget _buildCalendarBanner() {
    return TossInfoBanner(
      icon: Icons.calendar_month,
      iconColor: TossDesignSystem.tossBlue,
      title: '캘린더 연동해서 이벤트운세받기',
      subtitle: '일정 기반 맞춤 운세를 받아보세요',
      onTap: _syncDeviceCalendar,
      onClose: () {
        setState(() {
          _showCalendarBanner = false;
        });
      },
      backgroundColor: Colors.transparent,
    );
  }

  void _showPermissionDeniedDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: TossDesignSystem.errorRed, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '캘린더 접근 권한 필요',
                style: context.heading3,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '일정 기반 맞춤 운세를 보려면 캘린더 접근 권한이 필요합니다.',
                style: context.bodyMedium.copyWith(height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: TossDesignSystem.tossBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Google Calendar 사용하시나요?',
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'iOS에서 Google Calendar를 보려면\n'
                      '먼저 계정을 추가해주세요:',
                      style: context.bodySmall.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    _buildStep('설정 앱 열기 → Calendar', isDark),
                    _buildStep('Accounts → Add Account', isDark),
                    _buildStep('Google 선택 → 계정 로그인', isDark),
                    _buildStep('Calendars 동기화 ON', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '그 다음 Fortune 앱 권한을 허용하세요:',
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '설정 > 개인정보 보호 > 캘린더 > Fortune',
                style: context.bodySmall.copyWith(
                  color: isDark
                      ? TossDesignSystem.textSecondaryDark
                      : TossDesignSystem.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('설정 열기'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.labelMedium.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossDesignSystem.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final theme = Theme.of(context);

    return TossCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
          // 디바이스 캘린더 이벤트 표시 (파란색 바 + 개수)
          if (eventInfo?.hasDeviceEvents ?? false) ...[
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${eventInfo!.deviceEventCount}',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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

          // 디바이스 캘린더 이벤트 리스트
          if (_deviceEvents.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_note, color: TossDesignSystem.tossBlue, size: 18),
                SizedBox(width: 6),
                Text(
                  '내 캘린더 일정 (${_deviceEvents.length})',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.tossBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._deviceEvents.map((event) => _buildDeviceEventItem(event)),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceEventItem(CalendarEventSummary event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedEvents.contains(event);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedEvents.remove(event);
            } else {
              _selectedEvents.add(event);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? Colors.white24 : Colors.black12),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark ? Colors.white54 : Colors.black45),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? TossDesignSystem.textPrimaryDark
                            : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    if (event.startTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.isAllDay
                                ? '종일'
                                : DateFormat('HH:mm', 'ko_KR').format(event.startTime!),
                            style: context.labelMedium.copyWith(
                              color: isDark
                                  ? TossDesignSystem.textSecondaryDark
                                  : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: context.labelMedium.copyWith(
                                color: isDark
                                    ? TossDesignSystem.textSecondaryDark
                                    : TossDesignSystem.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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

    // 🔍 디버그 로깅: build() 호출 시점과 상태 체크
    debugPrint('');
    debugPrint('🔍 [BUILD] daily_calendar_fortune_page.dart build() 호출됨');
    debugPrint('   - _fortuneResult: ${_fortuneResult != null ? "있음" : "없음"}');
    debugPrint('   - _isLoading: $_isLoading');
    debugPrint('   - 표시할 화면: ${_fortuneResult != null && !_isLoading ? "결과 화면" : "입력 폼"}');
    debugPrint('');

    // ✅ 운세 결과가 있고 로딩 중이 아닐 때만 결과 화면 표시
    if (_fortuneResult != null && !_isLoading) {
      debugPrint('📄 [BUILD] → 결과 화면(Scaffold) 렌더링 시작');
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
        // ✅ Phase 8-9: Stack + FloatingBottomButton
        body: Stack(
          children: [
            SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                                '$score점',
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

                      // 조언 (5️⃣ 블러 대상)
                      if (fortuneData['advice'] != null) ...[
                        // ✅ UnifiedBlurWrapper 사용
                        UnifiedBlurWrapper(
                          isBlurred: _isBlurred,
                          blurredSections: _blurredSections,
                          sectionKey: 'advice',
                          child: _buildSectionCard(
                            icon: Icons.tips_and_updates,
                            title: '조언',
                            content: fortuneData['advice'] as String,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // AI 팁 (5️⃣ 블러 대상)
                      if (fortuneData['ai_tips'] != null) ...[
                        // ✅ UnifiedBlurWrapper 사용
                        UnifiedBlurWrapper(
                          isBlurred: _isBlurred,
                          blurredSections: _blurredSections,
                          sectionKey: 'ai_tips',
                          child: _buildAITipsList(fortuneData['ai_tips'] as List, isDark),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 주의사항 (5️⃣ 블러 대상)
                      if (fortuneData['caution'] != null) ...[
                        // ✅ UnifiedBlurWrapper 사용
                        UnifiedBlurWrapper(
                          isBlurred: _isBlurred,
                          blurredSections: _blurredSections,
                          sectionKey: 'caution',
                          child: _buildSectionCard(
                            icon: Icons.warning_amber_rounded,
                            title: '주의사항',
                            content: fortuneData['caution'] as String,
                            isDark: isDark,
                            isWarning: true,
                          ),
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

            // ✅ Phase 9: FloatingBottomButton (Positioned 제거 - 위젯 내부에 이미 있음)
            if (_isBlurred)
              UnifiedButton.floating(
                text: '광고 보고 전체 내용 확인하기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 116), // bottom: 100 효과
              ),
          ],
        ),
      );
    }

    // ✅ 로딩 중일 때는 입력 폼을 계속 표시 (버튼에 로딩 애니메이션)
    // 로딩 페이지 제거 - 버튼 자체에서 로딩 표시

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
    // 문단 구분을 위해 '. '으로 문장 분리
    final sentences = content.split('. ').where((s) => s.trim().isNotEmpty).toList();

    return TossCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 문장별로 구분하여 표시
          ...sentences.asMap().entries.map((entry) {
            final index = entry.key;
            final sentence = entry.value.trim();
            final isLastSentence = index == sentences.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLastSentence ? 0 : 16),
              child: Text(
                sentence + (sentence.endsWith('.') ? '' : '.'),
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  height: 1.8,
                  letterSpacing: -0.3,
                ),
              ),
            );
          }),
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
                          color: (cat['color'] as Color).withValues(alpha: 0.1),
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
                  if (categoryInfo['title'] != null)
                    Text(
                      categoryInfo['title'] as String,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (categoryInfo['advice'] != null)
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
        }),

        // 전체 운세
        if (categories['total'] != null) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
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
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
          }),
        ],
      ),
    );
  }

  // ✅ _buildBlurWrapper 제거 - UnifiedBlurWrapper 사용
}
