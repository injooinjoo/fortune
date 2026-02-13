import 'package:flutter/material.dart';
import 'utils.dart';

/// Micro-interactions configuration
@immutable
class MicroInteractions {
  final double buttonPressScale;
  final double cardHoverElevation;
  final double listItemPressScale;
  final double switchThumbScale;
  final double checkboxScale;
  final double fabPressScale;
  final double iconButtonScale;
  final double chipPressScale;

  const MicroInteractions(
      {required this.buttonPressScale,
      required this.cardHoverElevation,
      required this.listItemPressScale,
      required this.switchThumbScale,
      required this.checkboxScale,
      required this.fabPressScale,
      required this.iconButtonScale,
      required this.chipPressScale});

  factory MicroInteractions.light() => const MicroInteractions(
      buttonPressScale: 0.98,
      cardHoverElevation: 4.0,
      listItemPressScale: 0.99,
      switchThumbScale: 1.2,
      checkboxScale: 1.15,
      fabPressScale: 0.96,
      iconButtonScale: 0.95,
      chipPressScale: 0.97);

  factory MicroInteractions.dark() => const MicroInteractions(
      buttonPressScale: 0.97,
      cardHoverElevation: 6.0,
      listItemPressScale: 0.98,
      switchThumbScale: 1.25,
      checkboxScale: 1.2,
      fabPressScale: 0.95,
      iconButtonScale: 0.94,
      chipPressScale: 0.96);

  static MicroInteractions lerp(
      MicroInteractions a, MicroInteractions b, double t) {
    return MicroInteractions(
        buttonPressScale:
            lerpDouble(a.buttonPressScale, b.buttonPressScale, t)!,
        cardHoverElevation:
            lerpDouble(a.cardHoverElevation, b.cardHoverElevation, t)!,
        listItemPressScale:
            lerpDouble(a.listItemPressScale, b.listItemPressScale, t)!,
        switchThumbScale:
            lerpDouble(a.switchThumbScale, b.switchThumbScale, t)!,
        checkboxScale: lerpDouble(a.checkboxScale, b.checkboxScale, t)!,
        fabPressScale: lerpDouble(a.fabPressScale, b.fabPressScale, t)!,
        iconButtonScale: lerpDouble(a.iconButtonScale, b.iconButtonScale, t)!,
        chipPressScale: lerpDouble(a.chipPressScale, b.chipPressScale, t)!);
  }
}
