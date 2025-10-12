import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../widgets/moving_input_unified.dart';
import 'base_fortune_page.dart';

/// 토스 스타일 이사운 페이지 (BaseFortunePage 패턴 사용)
class MovingFortuneTossPage extends BaseFortunePage {
  const MovingFortuneTossPage({super.key})
      : super(
          title: '이사운',
          description: '새로운 보금자리로의 이동 운세를 분석해드립니다',
          fortuneType: 'moving',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<MovingFortuneTossPage> createState() => _MovingFortuneTossPageState();
}

class _MovingFortuneTossPageState extends BaseFortunePageState<MovingFortuneTossPage> {
  /// MovingInputUnified 위젯의 완료 콜백
  void _onInputComplete(String currentArea, String targetArea, String period, String purpose) async {
    final params = {
      'currentArea': currentArea,
      'targetArea': targetArea,
      'movingPeriod': period,
      'purpose': purpose,
    };

    Logger.info('🏠 [MovingFortune] Input complete', {'params': params});

    // BaseFortunePage의 generateFortuneAction 호출
    // This handles: Ad → API call → DB save → Show result
    await generateFortuneAction(params: params);
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    Logger.info('🔮 [MovingFortune] UnifiedFortuneService 호출', {'params': params});

    try {
      // UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // input_conditions 정규화
      final inputConditions = {
        'current_area': params['currentArea'],
        'target_area': params['targetArea'],
        'moving_period': params['movingPeriod'],
        'purpose': params['purpose'],
      };

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'moving',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
      );

      Logger.info('✅ [MovingFortune] UnifiedFortuneService 완료');

      // FortuneResult → Fortune 엔티티 변환
      return _convertToFortune(fortuneResult);

    } catch (e, stackTrace) {
      Logger.error('❌ [MovingFortune] UnifiedFortuneService 실패', e, stackTrace);
      rethrow;
    }
  }

  /// FortuneResult를 Fortune 엔티티로 변환
  Fortune _convertToFortune(FortuneResult result) {
    return Fortune(
      id: result.id ?? '',
      userId: ref.read(userProvider).value?.id ?? '',
      type: result.type,
      content: result.data['content'] as String? ?? result.summary.toString(),
      createdAt: DateTime.now(),
      overallScore: result.score,
      summary: result.summary['message'] as String?,
      metadata: result.data,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If fortune exists, BaseFortunePage automatically shows result
    if (fortune != null || isLoading || error != null) {
      return super.build(context);
    }

    // Show custom input UI from MovingInputUnified widget
    return MovingInputUnified(
      onComplete: _onInputComplete,
    );
  }
}
