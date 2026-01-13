import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/chat_message.dart';
import 'chat_career_result_card.dart';
import 'chat_moving_result_card.dart';
import 'celebrity/celebrity_card_factory.dart';
import 'chat_fortune_result_card.dart';
import 'chat_past_life_result_card.dart';
import 'chat_tarot_result_card.dart';
import 'chat_match_insight_card.dart';
import 'chat_ootd_result_card.dart';
import 'chat_saju_result_card.dart';
import 'chat_talisman_result_card.dart';
import 'chat_gratitude_result_card.dart';
import 'chat_yearly_encounter_result_card.dart';
import 'fortune_cookie_result_card.dart';
import 'fortune_result_scroll_wrapper.dart';
import 'personality_dna_chat_card.dart';

/// 채팅 메시지 버블
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  /// 운세 결과 카드 렌더링 완료 시 호출되는 콜백
  /// messageId와 context를 전달하여 1회성 스크롤 처리 가능
  final void Function(String messageId, BuildContext context)?
      onFortuneResultRendered;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onFortuneResultRendered,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isUser = message.type == ChatMessageType.user;

    // 성격 DNA 결과 카드 표시
    if (message.type == ChatMessageType.personalityDnaResult &&
        message.personalityDna != null) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: PersonalityDnaChatCard(
            dna: message.personalityDna!,
            isBlurred: message.isBlurred,
          ),
        ),
      );
    }

    // 사주 분석 결과 카드 표시
    if (message.type == ChatMessageType.sajuResult && message.sajuData != null) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatSajuResultCard(
            sajuData: message.sajuData!,
            fortuneResult: message.sajuFortuneResult,
            isBlurred: message.isBlurred,
            blurredSections: message.blurredSections,
          ),
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
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatOotdResultCard(
            ootdData: ootdData,
            isBlurred: message.isBlurred,
            blurredSections: message.blurredSections,
          ),
        ),
      );
    }

    // 커리어 운세 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        (message.fortuneType == 'career' ||
            message.fortuneType == 'career_coaching' ||
            message.fortuneType == 'career-coaching')) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatCareerResultCard(
            fortune: message.fortune!,
            isBlurred: message.isBlurred,
            blurredSections: message.blurredSections,
          ),
        ),
      );
    }

    // 이사운 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'moving') {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatMovingResultCard(
            fortune: message.fortune!,
            isBlurred: message.isBlurred,
            blurredSections: message.blurredSections,
          ),
        ),
      );
    }

    // 유명인 궁합 결과 카드 표시 (유형별 전용 카드)
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'celebrity') {
      // Fortune의 additionalInfo에서 celebrity 정보 추출
      final additionalInfo = message.fortune!.additionalInfo ?? {};
      final questionType = additionalInfo['question_type'] as String?;
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: CelebrityCardFactory.build(
            fortune: message.fortune!,
            questionType: questionType,
            celebrityName: additionalInfo['celebrity_name'] as String?,
            celebrityImageUrl: additionalInfo['celebrity_image_url'] as String?,
          ),
        ),
      );
    }

    // 경기 인사이트 결과 카드 표시
    if (message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'match-insight' &&
        message.matchInsight != null) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatMatchInsightCard(
            insight: message.matchInsight!,
            isBlurred: message.isBlurred,
          ),
        ),
      );
    }

    // 타로 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'tarot') {
      // Fortune의 additionalInfo에서 타로 데이터 추출
      final additionalInfo = message.fortune!.additionalInfo ?? {};
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatTarotResultCard(
            data: {
              'question': additionalInfo['question'] ?? message.fortune!.content,
              'spreadType': additionalInfo['spreadType'] ?? 'single',
              'spreadDisplayName': additionalInfo['spreadDisplayName'] ?? '타로 리딩',
              'cards': additionalInfo['cards'] ?? [],
              'overallReading': additionalInfo['overallReading'] ?? message.fortune!.content ?? '',
              'advice': additionalInfo['advice'] ?? '',
              'energyLevel': additionalInfo['energyLevel'] ?? message.fortune!.overallScore ?? 75,
              'isBlurred': message.isBlurred,
              'blurredSections': message.blurredSections,
            },
            question: additionalInfo['question'] as String?,
          ),
        ),
      );
    }

    // 전생탐험 결과 카드 표시
    if (message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'past-life' &&
        message.pastLifeResult != null) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatPastLifeResultCard(
            result: message.pastLifeResult!,
          ),
        ),
      );
    }

    // 올해의 인연 결과 카드 표시
    if (message.type == ChatMessageType.fortuneResult &&
        (message.fortuneType == 'yearly-encounter' ||
            message.fortuneType == 'yearlyEncounter') &&
        message.yearlyEncounterResult != null) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatYearlyEncounterResultCard(
            result: message.yearlyEncounterResult!,
          ),
        ),
      );
    }

    // 포춘쿠키 결과 카드 표시
    if (message.fortune != null &&
        message.type == ChatMessageType.fortuneResult &&
        message.fortuneType == 'fortune-cookie') {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: FortuneCookieResultCard(
            fortune: message.fortune!,
          ),
        ),
      );
    }

    // 부적 결과 카드 표시 (이미지 + 짧은 설명)
    if (message.type == ChatMessageType.talismanResult &&
        message.talismanImageUrl != null) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatTalismanResultCard(
            imageUrl: message.talismanImageUrl!,
            categoryName: message.talismanCategoryName ?? '부적',
            shortDescription: message.talismanShortDescription ?? '',
            isBlurred: message.isBlurred,
          ),
        ),
      );
    }

    // 감사일기 결과 카드 표시 (일기장 스타일)
    if (message.type == ChatMessageType.gratitudeResult) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatGratitudeResultCard(
            gratitude1: message.gratitude1 ?? '',
            gratitude2: message.gratitude2 ?? '',
            gratitude3: message.gratitude3 ?? '',
            date: message.gratitudeDate ?? DateTime.now(),
          ),
        ),
      );
    }

    // 운세 결과 카드 표시 (Fortune 객체가 있는 경우)
    // 전체 너비 사용, 중앙 정렬 (자석효과 제거)
    if (message.fortune != null && message.type == ChatMessageType.fortuneResult) {
      return FortuneResultScrollWrapper(
        messageId: message.id,
        onRendered: onFortuneResultRendered,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
          child: ChatFortuneResultCard(
            fortune: message.fortune!,
            fortuneType: message.fortuneType ?? 'default',
            typeName: message.text ?? '운세 결과',
            isBlurred: message.isBlurred,
            selectedDate: message.selectedDate,
          ),
        ),
      );
    }

    // 일반 텍스트 메시지 (구름 모양 말풍선)
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.xs,
        horizontal: DSSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: CloudBubble(
          type: isUser ? CloudBubbleType.user : CloudBubbleType.ai,
          showInkBleed: !isUser, // AI 메시지에만 잉크 번짐 효과
          cornerAsset: 'assets/images/chat/corner_motif.svg',
          cornerSize: 16,
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg,
            vertical: DSSpacing.md,
          ),
          child: Text(
            message.text ?? '',
            style: typography.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
