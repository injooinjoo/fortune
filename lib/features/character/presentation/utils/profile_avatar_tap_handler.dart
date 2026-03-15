import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../../../services/social_auth_service.dart';

typedef OpenProfileSheet = Future<void> Function();

Future<void> handleProfileAvatarTap({
  required BuildContext context,
  required WidgetRef ref,
  required User? currentUser,
  required OpenProfileSheet openProfileSheet,
  SocialAuthService? socialAuthService,
  VoidCallback? onAuthenticated,
}) async {
  if (currentUser == null) {
    await SocialLoginBottomSheet.showForAuthentication(
      context,
      ref: ref,
      socialAuthService: socialAuthService,
      onAuthenticated: onAuthenticated,
    );
    return;
  }

  await openProfileSheet();
}
