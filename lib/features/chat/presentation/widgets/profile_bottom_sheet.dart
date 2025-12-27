import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../screens/profile/profile_screen.dart';

/// 프로필 풀스크린 바텀시트
/// 홈 화면 등에서 프로필 아이콘 탭 시 표시
class ProfileBottomSheet extends ConsumerWidget {
  const ProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 핸들 바
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 프로필 콘텐츠 (ProfileScreen 재사용)
              Expanded(
                child: ProfileScreen(
                  scrollController: scrollController,
                  isInBottomSheet: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
