import 'package:flutter/widgets.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/models/character_affinity.dart';

/// 캐릭터 콘텐츠 로컬라이징 서비스
///
/// const AiCharacter 객체는 런타임에 context.l10n을 사용할 수 없으므로,
/// 이 서비스를 통해 캐릭터 ID를 기반으로 로컬라이즈된 텍스트를 제공합니다.
class CharacterLocalizer {
  const CharacterLocalizer._();

  // ========== 캐릭터 콘텐츠 ==========

  /// 캐릭터 이름 (로컬라이즈)
  static String getName(BuildContext context, String characterId) {
    final l10n = context.l10n;
    return switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulName,
      'fortune_muhyeon' => l10n.characterMuhyeonName,
      'fortune_stella' => l10n.characterStellaName,
      'fortune_dr_mind' => l10n.characterDrMindName,
      'fortune_rose' => l10n.characterRoseName,
      'fortune_james_kim' => l10n.characterJamesKimName,
      'fortune_lucky' => l10n.characterLuckyName,
      'fortune_marco' => l10n.characterMarcoName,
      'fortune_lina' => l10n.characterLinaName,
      'fortune_luna' => l10n.characterLunaName,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsName,
      'jung_tae_yoon' => l10n.characterJungTaeYoonName,
      'seo_yoonjae' => l10n.characterSeoYoonjaeName,
      'kang_harin' => l10n.characterKangHarinName,
      'jayden_angel' => l10n.characterJaydenAngelName,
      'ciel_butler' => l10n.characterCielButlerName,
      'lee_doyoon' => l10n.characterLeeDoyoonName,
      'han_seojun' => l10n.characterHanSeojunName,
      'baek_hyunwoo' => l10n.characterBaekHyunwooName,
      'min_junhyuk' => l10n.characterMinJunhyukName,
      _ => characterId, // fallback
    };
  }

  /// 짧은 설명 (로컬라이즈)
  static String getShortDescription(BuildContext context, String characterId) {
    final l10n = context.l10n;
    return switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulShortDescription,
      'fortune_muhyeon' => l10n.characterMuhyeonShortDescription,
      'fortune_stella' => l10n.characterStellaShortDescription,
      'fortune_dr_mind' => l10n.characterDrMindShortDescription,
      'fortune_rose' => l10n.characterRoseShortDescription,
      'fortune_james_kim' => l10n.characterJamesKimShortDescription,
      'fortune_lucky' => l10n.characterLuckyShortDescription,
      'fortune_marco' => l10n.characterMarcoShortDescription,
      'fortune_lina' => l10n.characterLinaShortDescription,
      'fortune_luna' => l10n.characterLunaShortDescription,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsShortDescription,
      'jung_tae_yoon' => l10n.characterJungTaeYoonShortDescription,
      'seo_yoonjae' => l10n.characterSeoYoonjaeShortDescription,
      'kang_harin' => l10n.characterKangHarinShortDescription,
      'jayden_angel' => l10n.characterJaydenAngelShortDescription,
      'ciel_butler' => l10n.characterCielButlerShortDescription,
      'lee_doyoon' => l10n.characterLeeDoyoonShortDescription,
      'han_seojun' => l10n.characterHanSeojunShortDescription,
      'baek_hyunwoo' => l10n.characterBaekHyunwooShortDescription,
      'min_junhyuk' => l10n.characterMinJunhyukShortDescription,
      _ => '', // fallback
    };
  }

  /// 세계관 (로컬라이즈)
  static String getWorldview(BuildContext context, String characterId) {
    final l10n = context.l10n;
    return switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulWorldview,
      'fortune_muhyeon' => l10n.characterMuhyeonWorldview,
      'fortune_stella' => l10n.characterStellaWorldview,
      'fortune_dr_mind' => l10n.characterDrMindWorldview,
      'fortune_rose' => l10n.characterRoseWorldview,
      'fortune_james_kim' => l10n.characterJamesKimWorldview,
      'fortune_lucky' => l10n.characterLuckyWorldview,
      'fortune_marco' => l10n.characterMarcoWorldview,
      'fortune_lina' => l10n.characterLinaWorldview,
      'fortune_luna' => l10n.characterLunaWorldview,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsWorldview,
      'jung_tae_yoon' => l10n.characterJungTaeYoonWorldview,
      'seo_yoonjae' => l10n.characterSeoYoonjaeWorldview,
      'kang_harin' => l10n.characterKangHarinWorldview,
      'jayden_angel' => l10n.characterJaydenAngelWorldview,
      'ciel_butler' => l10n.characterCielButlerWorldview,
      'lee_doyoon' => l10n.characterLeeDoyoonWorldview,
      'han_seojun' => l10n.characterHanSeojunWorldview,
      'baek_hyunwoo' => l10n.characterBaekHyunwooWorldview,
      'min_junhyuk' => l10n.characterMinJunhyukWorldview,
      _ => '', // fallback
    };
  }

  /// 성격 (로컬라이즈)
  static String getPersonality(BuildContext context, String characterId) {
    final l10n = context.l10n;
    return switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulPersonality,
      'fortune_muhyeon' => l10n.characterMuhyeonPersonality,
      'fortune_stella' => l10n.characterStellaPersonality,
      'fortune_dr_mind' => l10n.characterDrMindPersonality,
      'fortune_rose' => l10n.characterRosePersonality,
      'fortune_james_kim' => l10n.characterJamesKimPersonality,
      'fortune_lucky' => l10n.characterLuckyPersonality,
      'fortune_marco' => l10n.characterMarcoPersonality,
      'fortune_lina' => l10n.characterLinaPersonality,
      'fortune_luna' => l10n.characterLunaPersonality,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsPersonality,
      'jung_tae_yoon' => l10n.characterJungTaeYoonPersonality,
      'seo_yoonjae' => l10n.characterSeoYoonjaePersonality,
      'kang_harin' => l10n.characterKangHarinPersonality,
      'jayden_angel' => l10n.characterJaydenAngelPersonality,
      'ciel_butler' => l10n.characterCielButlerPersonality,
      'lee_doyoon' => l10n.characterLeeDoyoonPersonality,
      'han_seojun' => l10n.characterHanSeojunPersonality,
      'baek_hyunwoo' => l10n.characterBaekHyunwooPersonality,
      'min_junhyuk' => l10n.characterMinJunhyukPersonality,
      _ => '', // fallback
    };
  }

  /// 첫 메시지 (로컬라이즈)
  static String getFirstMessage(BuildContext context, String characterId) {
    final l10n = context.l10n;
    return switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulFirstMessage,
      'fortune_muhyeon' => l10n.characterMuhyeonFirstMessage,
      'fortune_stella' => l10n.characterStellaFirstMessage,
      'fortune_dr_mind' => l10n.characterDrMindFirstMessage,
      'fortune_rose' => l10n.characterRoseFirstMessage,
      'fortune_james_kim' => l10n.characterJamesKimFirstMessage,
      'fortune_lucky' => l10n.characterLuckyFirstMessage,
      'fortune_marco' => l10n.characterMarcoFirstMessage,
      'fortune_lina' => l10n.characterLinaFirstMessage,
      'fortune_luna' => l10n.characterLunaFirstMessage,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsFirstMessage,
      'jung_tae_yoon' => l10n.characterJungTaeYoonFirstMessage,
      'seo_yoonjae' => l10n.characterSeoYoonjaeFirstMessage,
      'kang_harin' => l10n.characterKangHarinFirstMessage,
      'jayden_angel' => l10n.characterJaydenAngelFirstMessage,
      'ciel_butler' => l10n.characterCielButlerFirstMessage,
      'lee_doyoon' => l10n.characterLeeDoyoonFirstMessage,
      'han_seojun' => l10n.characterHanSeojunFirstMessage,
      'baek_hyunwoo' => l10n.characterBaekHyunwooFirstMessage,
      'min_junhyuk' => l10n.characterMinJunhyukFirstMessage,
      _ => '', // fallback
    };
  }

  /// 태그 목록 (로컬라이즈)
  static List<String> getTags(BuildContext context, String characterId) {
    final l10n = context.l10n;
    final tagsString = switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulTags,
      'fortune_muhyeon' => l10n.characterMuhyeonTags,
      'fortune_stella' => l10n.characterStellaTags,
      'fortune_dr_mind' => l10n.characterDrMindTags,
      'fortune_rose' => l10n.characterRoseTags,
      'fortune_james_kim' => l10n.characterJamesKimTags,
      'fortune_lucky' => l10n.characterLuckyTags,
      'fortune_marco' => l10n.characterMarcoTags,
      'fortune_lina' => l10n.characterLinaTags,
      'fortune_luna' => l10n.characterLunaTags,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsTags,
      'jung_tae_yoon' => l10n.characterJungTaeYoonTags,
      'seo_yoonjae' => l10n.characterSeoYoonjaeTags,
      'kang_harin' => l10n.characterKangHarinTags,
      'jayden_angel' => l10n.characterJaydenAngelTags,
      'ciel_butler' => l10n.characterCielButlerTags,
      'lee_doyoon' => l10n.characterLeeDoyoonTags,
      'han_seojun' => l10n.characterHanSeojunTags,
      'baek_hyunwoo' => l10n.characterBaekHyunwooTags,
      'min_junhyuk' => l10n.characterMinJunhyukTags,
      _ => '', // fallback
    };
    if (tagsString.isEmpty) return [];
    return tagsString.split(',').map((t) => t.trim()).toList();
  }

  /// 제작자 코멘트 (로컬라이즈)
  static String getCreatorComment(BuildContext context, String characterId) {
    final l10n = context.l10n;
    return switch (characterId) {
      // Fortune Characters
      'fortune_haneul' => l10n.characterHaneulCreatorComment,
      'fortune_muhyeon' => l10n.characterMuhyeonCreatorComment,
      'fortune_stella' => l10n.characterStellaCreatorComment,
      'fortune_dr_mind' => l10n.characterDrMindCreatorComment,
      'fortune_rose' => l10n.characterRoseCreatorComment,
      'fortune_james_kim' => l10n.characterJamesKimCreatorComment,
      'fortune_lucky' => l10n.characterLuckyCreatorComment,
      'fortune_marco' => l10n.characterMarcoCreatorComment,
      'fortune_lina' => l10n.characterLinaCreatorComment,
      'fortune_luna' => l10n.characterLunaCreatorComment,
      // Story Characters (actual IDs from default_characters.dart)
      'luts' => l10n.characterLutsCreatorComment,
      'jung_tae_yoon' => l10n.characterJungTaeYoonCreatorComment,
      'seo_yoonjae' => l10n.characterSeoYoonjaeCreatorComment,
      'kang_harin' => l10n.characterKangHarinCreatorComment,
      'jayden_angel' => l10n.characterJaydenAngelCreatorComment,
      'ciel_butler' => l10n.characterCielButlerCreatorComment,
      'lee_doyoon' => l10n.characterLeeDoyoonCreatorComment,
      'han_seojun' => l10n.characterHanSeojunCreatorComment,
      'baek_hyunwoo' => l10n.characterBaekHyunwooCreatorComment,
      'min_junhyuk' => l10n.characterMinJunhyukCreatorComment,
      _ => '', // fallback
    };
  }

  // ========== 호감도 시스템 ==========

  /// 호감도 단계 이름 (로컬라이즈)
  static String getAffinityPhaseName(
      BuildContext context, AffinityPhase phase) {
    final l10n = context.l10n;
    return switch (phase) {
      AffinityPhase.stranger => l10n.affinityPhaseStranger,
      AffinityPhase.acquaintance => l10n.affinityPhaseAcquaintance,
      AffinityPhase.friend => l10n.affinityPhaseFriend,
      AffinityPhase.closeFriend => l10n.affinityPhaseCloseFriend,
      AffinityPhase.romantic => l10n.affinityPhaseRomantic,
      AffinityPhase.soulmate => l10n.affinityPhaseSoulmate,
    };
  }

  /// 단계 상승 축하 메시지 (로컬라이즈)
  static String getPhaseUpMessage(BuildContext context, AffinityPhase phase) {
    final l10n = context.l10n;
    return switch (phase) {
      AffinityPhase.stranger => '',
      AffinityPhase.acquaintance => l10n.affinityPhaseUpAcquaintance,
      AffinityPhase.friend => l10n.affinityPhaseUpFriend,
      AffinityPhase.closeFriend => l10n.affinityPhaseUpCloseFriend,
      AffinityPhase.romantic => l10n.affinityPhaseUpRomantic,
      AffinityPhase.soulmate => l10n.affinityPhaseUpSoulmate,
    };
  }

  /// 단계별 해금 설명 (로컬라이즈)
  static String getUnlockDescription(
      BuildContext context, AffinityPhase phase) {
    final l10n = context.l10n;
    return switch (phase) {
      AffinityPhase.stranger => l10n.affinityUnlockStranger,
      AffinityPhase.acquaintance => l10n.affinityUnlockAcquaintance,
      AffinityPhase.friend => l10n.affinityUnlockFriend,
      AffinityPhase.closeFriend => l10n.affinityUnlockCloseFriend,
      AffinityPhase.romantic => l10n.affinityUnlockRomantic,
      AffinityPhase.soulmate => l10n.affinityUnlockSoulmate,
    };
  }

  /// 호감도 이벤트 설명 (로컬라이즈)
  static String getAffinityEventDescription(
      BuildContext context, AffinityEvent event) {
    final l10n = context.l10n;
    return switch (event) {
      AffinityEvent.basicChat => l10n.affinityEventBasicChat,
      AffinityEvent.qualityEngagement => l10n.affinityEventQualityEngagement,
      AffinityEvent.emotionalSupport => l10n.affinityEventEmotionalSupport,
      AffinityEvent.personalDisclosure => l10n.affinityEventPersonalDisclosure,
      AffinityEvent.firstChatBonus => l10n.affinityEventFirstChatBonus,
      AffinityEvent.streakBonus => l10n.affinityEventStreakBonus,
      AffinityEvent.choicePositive => l10n.affinityEventChoicePositive,
      AffinityEvent.choiceNegative => l10n.affinityEventChoiceNegative,
      AffinityEvent.disrespectful => l10n.affinityEventDisrespectful,
      AffinityEvent.conflict => l10n.affinityEventConflict,
      AffinityEvent.spam => l10n.affinityEventSpam,
      // Deprecated events - fallback to similar ones
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.normalChat => l10n.affinityEventBasicChat,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.sweetTalk => l10n.affinityEventQualityEngagement,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.sharedSecret => l10n.affinityEventPersonalDisclosure,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.comfort => l10n.affinityEventEmotionalSupport,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.gift => l10n.affinityEventChoicePositive,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.specialEvent => l10n.affinityEventChoicePositive,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.misunderstanding => l10n.affinityEventDisrespectful,
      // ignore: deprecated_member_use_from_same_package
      AffinityEvent.breakupThreat => l10n.affinityEventConflict,
    };
  }
}
