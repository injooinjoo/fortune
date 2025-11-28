import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../widgets/event_category_selector.dart';
import '../../../widgets/event_detail_input_form.dart';
import 'calendar_sync_banner.dart';
import 'calendar_view_widget.dart';
import 'date_info_widget.dart';
import '../../../../../../core/models/holiday_models.dart';
import '../../../../../../core/services/unified_calendar_service.dart';

/// Step 0: 캘린더 선택 화면
class Step0CalendarView extends StatelessWidget {
  final bool showCalendarBanner;
  final bool isCalendarSynced;
  final bool showGoogleCalendarOption;
  final VoidCallback onCalendarBannerTap;
  final VoidCallback onCalendarBannerClose;
  final VoidCallback onGoogleCalendarTap;
  final VoidCallback onGoogleCalendarClose;
  final DateTime focusedDay;
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final Map<DateTime, CalendarEventInfo> events;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;
  final List<CalendarEventSummary> deviceEvents;
  final List<CalendarEventSummary> selectedEvents;
  final ValueChanged<CalendarEventSummary> onEventToggle;

  const Step0CalendarView({
    super.key,
    required this.showCalendarBanner,
    required this.isCalendarSynced,
    required this.showGoogleCalendarOption,
    required this.onCalendarBannerTap,
    required this.onCalendarBannerClose,
    required this.onGoogleCalendarTap,
    required this.onGoogleCalendarClose,
    required this.focusedDay,
    required this.selectedDate,
    required this.calendarFormat,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.deviceEvents,
    required this.selectedEvents,
    required this.onEventToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 기본 캘린더 연동 배너 (권한 없을 때)
          if (showCalendarBanner && !isCalendarSynced)
            CalendarSyncBanner(
              onTap: onCalendarBannerTap,
              onClose: onCalendarBannerClose,
            ),
          if (showCalendarBanner && !isCalendarSynced) const SizedBox(height: 12),

          // Google Calendar 연동 옵션 (디바이스 캘린더에 이벤트 없을 때)
          if (showGoogleCalendarOption)
            GoogleCalendarBanner(
              onTap: onGoogleCalendarTap,
              onClose: onGoogleCalendarClose,
            ),
          if (showGoogleCalendarOption) const SizedBox(height: 12),

          CalendarViewWidget(
            focusedDay: focusedDay,
            selectedDate: selectedDate,
            calendarFormat: calendarFormat,
            events: events,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: 12),
          DateInfoWidget(
            selectedDate: selectedDate,
            events: events,
            isCalendarSynced: isCalendarSynced,
            deviceEvents: deviceEvents,
            selectedEvents: selectedEvents,
            onEventToggle: onEventToggle,
          ),
          const BottomButtonSpacing(),
        ],
      ),
    );
  }
}

/// Step 1: 카테고리 선택 화면
class Step1CategoryView extends StatelessWidget {
  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory?> onCategorySelected;

  const Step1CategoryView({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EventCategorySelector(
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
          ),
          const BottomButtonSpacing(),
        ],
      ),
    );
  }
}

/// Step 2: 상세 입력 화면
class Step2DetailView extends StatelessWidget {
  final EventCategory? selectedCategory;
  final TextEditingController questionController;
  final EmotionState? selectedEmotion;
  final ValueChanged<EmotionState?> onEmotionSelected;
  final VoidCallback onAddPartner;

  const Step2DetailView({
    super.key,
    required this.selectedCategory,
    required this.questionController,
    required this.selectedEmotion,
    required this.onEmotionSelected,
    required this.onAddPartner,
  });

  @override
  Widget build(BuildContext context) {
    // _selectedCategory가 null이면 빈 화면 (Step1에서 선택 전)
    if (selectedCategory == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EventDetailInputForm(
            category: selectedCategory!,
            questionController: questionController,
            selectedEmotion: selectedEmotion,
            onEmotionSelected: onEmotionSelected,
            onAddPartner: onAddPartner,
          ),
          const BottomButtonSpacing(),
        ],
      ),
    );
  }
}

/// 플로팅 버튼 빌더
class StepFloatingButton extends StatelessWidget {
  final int currentStep;
  final EventCategory? selectedCategory;
  final EmotionState? selectedEmotion;
  final bool isLoading;
  final VoidCallback onNextStep;
  final VoidCallback onGenerateFortune;
  final PageController pageController;

  const StepFloatingButton({
    super.key,
    required this.currentStep,
    required this.selectedCategory,
    required this.selectedEmotion,
    required this.isLoading,
    required this.onNextStep,
    required this.onGenerateFortune,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    bool canProceed = false;
    String buttonText = '';
    VoidCallback? onPressed;

    switch (currentStep) {
      case 0:
        canProceed = true;
        buttonText = '다음';
        onPressed = onNextStep;
        break;
      case 1:
        canProceed = selectedCategory != null;
        buttonText = '다음';
        onPressed = canProceed ? onNextStep : null;
        break;
      case 2:
        canProceed = selectedEmotion != null;
        buttonText = '운세 보기';
        onPressed = canProceed ? onGenerateFortune : null;
        break;
    }

    // isLoading은 결과 화면에서 커서 깜빡임으로 대체 (버튼 로딩 제거)
    return UnifiedButton.progress(
      text: buttonText,
      currentStep: currentStep + 1,
      totalSteps: 3,
      onPressed: isLoading ? null : onPressed,  // 로딩 중 버튼 비활성화
      isEnabled: canProceed && !isLoading,
      isFloating: true,
      isLoading: false,  // 버튼 로딩 애니메이션 제거
    );
  }
}
