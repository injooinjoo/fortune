import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/soul_rates.dart';
import '../../../../core/constants/talisman_constants.dart';
import '../../../../core/design_system/components/ds_modal.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../presentation/widgets/social_login_bottom_sheet.dart';
import 'pending_chat_auth_intent.dart';

class CharacterChatPreflightGuard {
  CharacterChatPreflightGuard._();

  static int characterChatTokenCost() {
    return SoulRates.getTokenCost('character-chat');
  }

  static int fortuneLaunchTokenCost(String fortuneType) {
    return fortuneType == 'talisman' ? 0 : characterChatTokenCost();
  }

  static int surveySubmissionTokenCost(
    String fortuneType,
    Map<String, dynamic> surveyAnswers,
  ) {
    if (fortuneType != 'talisman') {
      return characterChatTokenCost();
    }

    return TalismanTierCosts.forGenerationMode(
      _stringValue(surveyAnswers['generationMode']),
    );
  }

  static Future<bool> ensureAuthenticated(
    BuildContext context,
    WidgetRef ref, {
    PendingChatAuthIntent? pendingIntent,
    VoidCallback? onAuthenticated,
  }) async {
    if (_isAuthenticated(ref)) {
      return true;
    }

    await promptAuthentication(
      context,
      ref,
      pendingIntent: pendingIntent,
      onAuthenticated: onAuthenticated,
    );
    return false;
  }

  static Future<void> promptAuthentication(
    BuildContext context,
    WidgetRef ref, {
    PendingChatAuthIntent? pendingIntent,
    VoidCallback? onAuthenticated,
  }) async {
    if (!context.mounted) {
      return;
    }

    if (pendingIntent != null) {
      await ref
          .read(storageServiceProvider)
          .savePendingChatAuthIntent(pendingIntent.toJson());
    }

    if (!context.mounted) {
      return;
    }

    await SocialLoginBottomSheet.showForAuthentication(
      context,
      ref: ref,
      onAuthenticated: onAuthenticated ?? () {},
    );
  }

  static Future<bool> ensureReady(
    BuildContext context,
    WidgetRef ref, {
    required String actionLabel,
    required int requiredTokens,
    PendingChatAuthIntent? pendingIntent,
    String trigger = 'manual',
    VoidCallback? onAuthenticated,
  }) async {
    final isAuthenticated = await ensureAuthenticated(
      context,
      ref,
      pendingIntent: pendingIntent,
      onAuthenticated: onAuthenticated,
    );
    if (!isAuthenticated) {
      return false;
    }

    if (requiredTokens <= 0) {
      return true;
    }

    final tokenNotifier = ref.read(tokenProvider.notifier);
    final previousTokenState = ref.read(tokenProvider);

    await tokenNotifier.ensureLoaded(
      force: previousTokenState.balance == null &&
          previousTokenState.userProfile == null,
      trigger: 'preflight.$trigger',
    );

    if (!context.mounted) {
      return false;
    }

    final tokenState = ref.read(tokenProvider);
    if (tokenState.hasUnlimitedTokens ||
        tokenState.canConsumeTokens(requiredTokens)) {
      return true;
    }

    if (tokenState.balance == null &&
        tokenState.userProfile == null &&
        tokenState.error != null) {
      await DSModal.alert(
        context: context,
        title: '토큰 정보를 확인할 수 없어요',
        message: '잠시 후 다시 시도해 주세요.',
      );
      return false;
    }

    await showInsufficientTokensDialog(
      context,
      ref,
      actionLabel: actionLabel,
      requiredTokens: requiredTokens,
    );
    return false;
  }

  static Future<void> showInsufficientTokensDialog(
    BuildContext context,
    WidgetRef ref, {
    required String actionLabel,
    int? requiredTokens,
  }) async {
    if (!context.mounted) {
      return;
    }

    final tokenState = ref.read(tokenProvider);
    final currentTokens = tokenState.currentTokens;

    final message = requiredTokens == null
        ? '지금은 토큰이 부족해요. 토큰을 충전한 뒤 다시 시도해 주세요.'
        : '$actionLabel $requiredTokens개의 토큰이 필요해요.\n현재 보유 토큰은 $currentTokens개예요.';

    final shouldOpenPremium = await DSModal.confirm(
      context: context,
      title: '토큰이 부족해요',
      message: message,
      confirmText: '토큰 충전',
      cancelText: '닫기',
    );

    if (shouldOpenPremium == true && context.mounted) {
      context.push('/premium');
    }
  }

  static bool _isAuthenticated(WidgetRef ref) {
    return ref.read(authServiceProvider).isAuthenticated;
  }

  static String _stringValue(dynamic raw) {
    return raw?.toString().trim() ?? '';
  }
}
