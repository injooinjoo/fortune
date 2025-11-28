import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/widgets/info_banner.dart';

/// 캘린더 동기화 배너 위젯
class CalendarSyncBanner extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onClose;

  const CalendarSyncBanner({
    super.key,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      icon: Icons.calendar_month,
      iconColor: TossDesignSystem.tossBlue,
      title: '캘린더 연동해서 이벤트운세받기',
      subtitle: '일정 기반 맞춤 운세를 받아보세요',
      onTap: onTap,
      onClose: onClose,
      backgroundColor: Colors.transparent,
    );
  }
}

/// Google Calendar 연동 배너 위젯 (이벤트 없을 때 표시)
class GoogleCalendarBanner extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onClose;

  const GoogleCalendarBanner({
    super.key,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      icon: Icons.calendar_month,
      iconColor: const Color(0xFF4285F4), // Google Blue
      title: '일정이 없네요',
      subtitle: 'Google 캘린더를 연결해서 일정을 가져올까요?',
      onTap: onTap,
      onClose: onClose,
      backgroundColor: Colors.transparent,
    );
  }
}
