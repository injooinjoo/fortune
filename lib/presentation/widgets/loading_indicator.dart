import 'package:flutter/material.dart';
import 'package:fortune/shared/components/fortune_loading_indicator.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Delegate to FortuneLoadingIndicator for consistent loading experience
    return FortuneLoadingIndicator(
      size: size,
      message: message
    );
  }
}