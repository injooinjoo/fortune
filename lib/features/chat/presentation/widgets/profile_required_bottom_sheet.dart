import 'package:flutter/material.dart';
import '../../../../core/components/app_bottom_sheet.dart';

/// 프로필 필요 시 사용자 선택 액션
enum ProfileRequiredAction {
  /// 로그인 페이지로 이동
  login,

  /// 게스트로 계속 (온보딩 시작)
  continueAsGuest,
}

/// 프로필 정보가 필요할 때 표시하는 선택 바텀시트
class ProfileRequiredBottomSheet {
  /// 바텀시트 표시
  ///
  /// Returns:
  /// - [ProfileRequiredAction.login]: 로그인 선택
  /// - [ProfileRequiredAction.continueAsGuest]: 게스트로 계속 선택
  /// - null: 사용자가 닫음
  static Future<ProfileRequiredAction?> show(BuildContext context) {
    return AppBottomSheet.showSelection<ProfileRequiredAction>(
      context: context,
      title: '프로필 정보가 필요해요',
      subtitle: '맞춤 운세를 받으려면 생년월일 정보가 필요합니다.',
      options: const [
        AppBottomSheetOption(
          label: '로그인하기',
          description: '로그인하면 기록이 영구 보관됩니다.',
          value: ProfileRequiredAction.login,
          icon: Icons.login_outlined,
        ),
        AppBottomSheetOption(
          label: '게스트로 계속',
          description: '간단한 정보만 입력하고 바로 시작합니다.',
          value: ProfileRequiredAction.continueAsGuest,
          icon: Icons.person_outline,
        ),
      ],
    );
  }
}
