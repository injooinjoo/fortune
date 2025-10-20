import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../widgets/moving_input_unified.dart';
import '../../domain/models/conditions/moving_fortune_conditions.dart';
import '../../../../core/widgets/fortune_result_widgets.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

/// 토스 스타일 이사운 페이지 (UnifiedFortuneBaseWidget 사용)
class MovingFortuneTossPage extends ConsumerStatefulWidget {
  const MovingFortuneTossPage({super.key});

  @override
  ConsumerState<MovingFortuneTossPage> createState() => _MovingFortuneTossPageState();
}

class _MovingFortuneTossPageState extends ConsumerState<MovingFortuneTossPage> {
  String? _currentArea;
  String? _targetArea;
  String? _period;
  String? _purpose;

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'moving',
      title: '이사운',
      description: '새로운 보금자리로의 이동 운세를 분석해드립니다',
      dataSource: FortuneDataSource.api,
      // 입력 UI
      inputBuilder: (context, onComplete) {
        return MovingInputUnified(
          onComplete: (currentArea, targetArea, period, purpose) {
            setState(() {
              _currentArea = currentArea;
              _targetArea = targetArea;
              _period = period;
              _purpose = purpose;
            });
            onComplete();
          },
        );
      },

      // 조건 객체 생성
      conditionsBuilder: () async {
        return MovingFortuneConditions(
          currentArea: _currentArea ?? '',
          targetArea: _targetArea ?? '',
          movingPeriod: _period ?? '',
          purpose: _purpose ?? '',
        );
      },

      // 결과 표시 UI
      resultBuilder: (context, result) {
        final theme = Theme.of(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이사운 분석 결과',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.data['content'] as String? ?? result.summary.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                if (result.score != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '운세 점수: ${result.score}/100',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: TossDesignSystem.tossBlue,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
