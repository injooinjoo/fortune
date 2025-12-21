import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';

/// 성격DNA 페이지 전용 한지 스타일 섹션 위젯
///
/// HanjiSectionCard를 기반으로 한국 전통 미학을 적용합니다.
class FortuneSectionWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final String? hanja;
  final HanjiColorScheme colorScheme;
  final HanjiCardStyle style;
  final bool showSealStamp;
  final String? sealText;

  const FortuneSectionWidget({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.hanja,
    this.colorScheme = HanjiColorScheme.fortune,
    this.style = HanjiCardStyle.standard,
    this.showSealStamp = false,
    this.sealText,
  });

  @override
  Widget build(BuildContext context) {
    return HanjiSectionCard(
      title: title,
      hanja: hanja,
      colorScheme: colorScheme,
      style: style,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

/// @deprecated Use FortuneSectionWidget instead
typedef TossSectionWidget = FortuneSectionWidget;
