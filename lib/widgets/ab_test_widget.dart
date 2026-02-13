import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ab_test_variant.dart';
import '../services/ab_test_service.dart';

/// AB 테스트 위젯 - 변형별 UI를 자동으로 렌더링하고 이벤트를 추적
class ABTestWidget extends ConsumerStatefulWidget {
  final String experimentId;
  final Widget Function(BuildContext context, ABTestVariant variant) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onVariantAssigned;

  const ABTestWidget({
    super.key,
    required this.experimentId,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.onVariantAssigned,
  });

  @override
  ConsumerState<ABTestWidget> createState() => _ABTestWidgetState();
}

class _ABTestWidgetState extends ConsumerState<ABTestWidget> {
  ABTestVariant? _variant;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVariant();
  }

  Future<void> _loadVariant() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // AB 테스트 서비스 초기화 대기
      await ref.read(abTestInitializerProvider.future);

      // 변형 가져오기
      final variant =
          await ref.read(abTestServiceProvider).getVariant(widget.experimentId);

      setState(() {
        _variant = variant;
        _isLoading = false;
      });

      // 콜백 호출
      widget.onVariantAssigned?.call();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorWidget ?? Center(child: Text('Error: $_error'));
    }

    if (_variant == null) {
      return widget.errorWidget ??
          const Center(child: Text('No variant assigned'));
    }

    return widget.builder(context, _variant!);
  }
}

/// AB 테스트 조건부 위젯 - 특정 변형에만 표시
class ABTestConditionalWidget extends ConsumerWidget {
  final String experimentId;
  final String targetVariantId;
  final Widget child;
  final Widget? fallback;

  const ABTestConditionalWidget({
    super.key,
    required this.experimentId,
    required this.targetVariantId,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<ABTestVariant>(
      future: ref.watch(experimentVariantProvider(experimentId).future),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.id == targetVariantId) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// AB 테스트 스위치 위젯 - 여러 변형을 switch-case로 처리
class ABTestSwitchWidget extends ConsumerWidget {
  final String experimentId;
  final Map<String, Widget> variants;
  final Widget? defaultWidget;
  final Widget? loadingWidget;

  const ABTestSwitchWidget({
    super.key,
    required this.experimentId,
    required this.variants,
    this.defaultWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantAsync = ref.watch(experimentVariantProvider(experimentId));

    return variantAsync.when(
      data: (variant) {
        return variants[variant.id] ?? defaultWidget ?? const SizedBox.shrink();
      },
      loading: () =>
          loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          defaultWidget ?? Center(child: Text('Error: $error')),
    );
  }
}

/// AB 테스트 파라미터 위젯 - 변형의 파라미터에 따라 UI 렌더링
class ABTestParameterWidget<T> extends ConsumerWidget {
  final String experimentId;
  final String parameterKey;
  final Widget Function(BuildContext context, T? value) builder;
  final T? defaultValue;

  const ABTestParameterWidget({
    super.key,
    required this.experimentId,
    required this.parameterKey,
    required this.builder,
    this.defaultValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantAsync = ref.watch(experimentVariantProvider(experimentId));

    return variantAsync.when(
      data: (variant) {
        final value = variant.getParameter<T>(parameterKey) ?? defaultValue;
        return builder(context, value);
      },
      loading: () => builder(context, defaultValue),
      error: (error, stack) => builder(context, defaultValue),
    );
  }
}

/// AB 테스트 전환 추적 위젯 - 자식 위젯의 액션을 자동으로 추적
class ABTestConversionTracker extends ConsumerWidget {
  final String experimentId;
  final String conversionType;
  final Widget child;
  final Map<String, dynamic>? additionalData;

  const ABTestConversionTracker({
    super.key,
    required this.experimentId,
    required this.conversionType,
    required this.child,
    this.additionalData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        // 전환 이벤트 추적
        await ref.read(abTestServiceProvider).trackConversion(
              experimentId: experimentId,
              conversionType: conversionType,
              additionalData: additionalData,
            );
      },
      child: child,
    );
  }
}
