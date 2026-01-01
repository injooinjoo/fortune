import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/chat_message.dart';
import 'chat_career_result_card.dart';
import 'chat_celebrity_result_card.dart';
import 'chat_fortune_result_card.dart';
import 'chat_ootd_result_card.dart';
import 'chat_saju_result_card.dart';

/// 채팅 메시지 버블
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.type == ChatMessageType.user;

    // 사주 분석 결과 카드 표시
    if (message.type == ChatMessageType.sajuResult && message.sajuData != null) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: ChatSajuResultCard(
          sajuData: message.sajuData!,
          fortuneResult: message.sajuFortuneResult,
          isBlurred: message.isBlurred,
          blurredSections: message.blurredSections,
        ),
      );
    }

    // OOTD 평가 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'ootd-evaluation') {
      // Fortune의 additionalInfo에서 OOTD 결과 추출
      final additionalInfo = message.fortune!.additionalInfo ?? {};
      final ootdData = {
        'score': message.fortune!.overallScore?.toDouble() ??
            additionalInfo['score'] ??
            0.0,
        'tpo': additionalInfo['tpo'] ?? '',
        'details': additionalInfo['details'] ?? {},
      };
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: ChatOotdResultCard(
          ootdData: ootdData,
          isBlurred: message.isBlurred,
          blurredSections: message.blurredSections,
        ),
      );
    }

    // 커리어 운세 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        (message.fortuneType == 'career' ||
            message.fortuneType == 'career_coaching' ||
            message.fortuneType == 'career-coaching')) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: ChatCareerResultCard(
          fortune: message.fortune!,
          isBlurred: message.isBlurred,
          blurredSections: message.blurredSections,
        ),
      );
    }

    // 유명인 궁합 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'celebrity') {
      // Fortune의 additionalInfo에서 celebrity 정보 추출
      final additionalInfo = message.fortune!.additionalInfo ?? {};
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: ChatCelebrityResultCard(
          fortune: message.fortune!,
          celebrityName: additionalInfo['celebrity_name'] as String?,
          celebrityImageUrl: additionalInfo['celebrity_image_url'] as String?,
          connectionType: additionalInfo['connection_type'] as String? ?? 'ideal_match',
        ),
      );
    }

    // 운세 결과 카드 표시 (Fortune 객체가 있는 경우)
    // 전체 너비 사용, 중앙 정렬 (자석효과 제거)
    if (message.fortune != null && message.type == ChatMessageType.fortuneResult) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: ChatFortuneResultCard(
          fortune: message.fortune!,
          fortuneType: message.fortuneType ?? 'default',
          typeName: message.text ?? '운세 결과',
          isBlurred: message.isBlurred,
        ),
      );
    }

    // 일반 텍스트 메시지 (수평 패딩 포함)
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.xs,
        horizontal: DSSpacing.md, // ListView에서 제거된 수평 패딩을 여기서 적용
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: isUser
              ? colors.textPrimary
              : (isDark
                  ? colors.backgroundSecondary
                  : colors.surface),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: isUser
              ? null
              : Border.all(
                  color: colors.textPrimary.withValues(alpha: 0.15),
                ),
        ),
        child: Text(
          message.text ?? '',
          style: typography.bodyMedium.copyWith(
            color: isUser
                ? colors.background
                : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
