import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global key for token balance widget to get its position
final tokenBalanceGlobalKey = GlobalKey();

// Provider to get token balance widget position
final tokenBalancePositionProvider = Provider<Offset?>((ref) {
  final key = tokenBalanceGlobalKey;
  if (key.currentContext != null) {
    final RenderBox? renderBox =
        key.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      // Return center of the widget
      return Offset(
          position.dx + size.width / 2, position.dy + size.height / 2);
    }
  }
  return null;
});

// Soul animation state
class SoulAnimationState {
  final bool isAnimating;
  final int? soulAmount;
  final Offset? startPosition;
  final Offset? endPosition;

  const SoulAnimationState(
      {this.isAnimating = false,
      this.soulAmount,
      this.startPosition,
      this.endPosition});

  SoulAnimationState copyWith(
      {bool? isAnimating,
      int? soulAmount,
      Offset? startPosition,
      Offset? endPosition}) {
    return SoulAnimationState(
        isAnimating: isAnimating ?? this.isAnimating,
        soulAmount: soulAmount ?? this.soulAmount,
        startPosition: startPosition ?? this.startPosition,
        endPosition: endPosition ?? this.endPosition);
  }
}

// Soul animation notifier
class SoulAnimationNotifier extends StateNotifier<SoulAnimationState> {
  final Ref ref;

  SoulAnimationNotifier(this.ref) : super(const SoulAnimationState());

  void showSoulAnimation(
      {required BuildContext context,
      required int soulAmount,
      Offset? startPosition}) {
    // Get token balance widget position
    final endPosition = ref.read(tokenBalancePositionProvider);

    state = state.copyWith(
        isAnimating: true,
        soulAmount: soulAmount,
        startPosition: startPosition,
        endPosition: endPosition);

    // Reset state after animation
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = const SoulAnimationState();
      }
    });
  }

  void hideSoulAnimation() {
    state = const SoulAnimationState();
  }
}

// Provider
final soulAnimationProvider =
    StateNotifierProvider<SoulAnimationNotifier, SoulAnimationState>((ref) {
  return SoulAnimationNotifier(ref);
});
