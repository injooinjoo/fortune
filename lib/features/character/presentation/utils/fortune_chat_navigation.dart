import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../../core/utils/logger.dart';
import '../../data/fortune_characters.dart';

void openFortuneChat(
  BuildContext context,
  String fortuneType, {
  String? entrySource,
}) {
  final normalizedType = normalizeFortuneTypeForChat(fortuneType);
  final expert = findFortuneExpert(normalizedType);

  if (expert == null) {
    Logger.warning('[FortuneChatNavigation] Missing fortune expert mapping', {
      'fortuneType': normalizedType,
      'entrySource': entrySource,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이 운세는 아직 대화 시작 준비 중이에요.'),
      ),
    );
    context.go('/chat');
    return;
  }

  context.go(
    buildFortuneChatRoute(
      normalizedType,
      characterId: expert.id,
      entrySource: entrySource,
    ),
  );
}
