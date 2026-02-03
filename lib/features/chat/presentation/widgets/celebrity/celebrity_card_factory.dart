import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../domain/entities/fortune.dart';
import 'celebrity_personality_card.dart';
import 'celebrity_love_card.dart';
import 'celebrity_pastlife_card.dart';
import 'celebrity_timing_card.dart';

/// 유명인 궁합 카드 팩토리
///
/// question_type에 따라 적절한 전용 카드를 반환합니다.
/// - personality: 성격궁합 카드
/// - love: 연애궁합 카드
/// - pastLife: 전생인연 카드
/// - timing: 운명의시기 카드
class CelebrityCardFactory {
  /// question_type에 맞는 카드 위젯 반환
  ///
  /// [fortune] 운세 데이터
  /// [questionType] 질문 유형 (personality, love, pastLife, timing)
  /// [celebrityName] 유명인 이름
  /// [celebrityImageUrl] 유명인 이미지 URL
  static Widget build({
    required Fortune fortune,
    required String? questionType,
    String? celebrityName,
    String? celebrityImageUrl,
  }) {
    switch (questionType) {
      case 'personality':
        return CelebrityPersonalityCard(
          fortune: fortune,
          celebrityName: celebrityName,
          celebrityImageUrl: celebrityImageUrl,
        );

      case 'love':
        return CelebrityLoveCard(
          fortune: fortune,
          celebrityName: celebrityName,
          celebrityImageUrl: celebrityImageUrl,
        );

      case 'pastLife':
        return CelebrityPastLifeCard(
          fortune: fortune,
          celebrityName: celebrityName,
          celebrityImageUrl: celebrityImageUrl,
        );

      case 'timing':
        return CelebrityTimingCard(
          fortune: fortune,
          celebrityName: celebrityName,
          celebrityImageUrl: celebrityImageUrl,
        );

      default:
        // 기본값: 성격궁합 카드
        return CelebrityPersonalityCard(
          fortune: fortune,
          celebrityName: celebrityName,
          celebrityImageUrl: celebrityImageUrl,
        );
    }
  }

  /// question_type에 맞는 제목 반환
  static String getTitle(String? questionType) {
    switch (questionType) {
      case 'personality':
        return '성격 궁합';
      case 'love':
        return '연애 궁합';
      case 'pastLife':
        return '전생 인연';
      case 'timing':
        return '운명의 시기';
      default:
        return '궁합 분석';
    }
  }

  /// question_type에 맞는 이모지 반환
  static String getEmoji(String? questionType) {
    switch (questionType) {
      case 'personality':
        return '🧠';
      case 'love':
        return '💕';
      case 'pastLife':
        return '🌙';
      case 'timing':
        return '⏰';
      default:
        return '✨';
    }
  }

  /// question_type에 맞는 테마 색상 반환
  static Color getThemeColor(String? questionType) {
    switch (questionType) {
      case 'personality':
        return DSFortuneColors.categoryPersonalityDna; // 보라색
      case 'love':
        return DSFortuneColors.categoryLove; // 핑크
      case 'pastLife':
        return DSFortuneColors.mysticalPurpleDark; // 남보라
      case 'timing':
        return DSFortuneColors.categoryLotto; // 골드
      default:
        return DSFortuneColors.categoryPersonalityDna;
    }
  }
}
