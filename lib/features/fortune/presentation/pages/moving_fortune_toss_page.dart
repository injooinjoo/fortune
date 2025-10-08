import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';
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

    Logger.info('🔮 [MovingFortune] Calling API', {'params': params});

    try {
      final apiService = ref.read(fortuneApiServiceProvider);

      // API 호출 - FortuneApiService.getFortune 사용
      // Decision service is automatically applied inside getFortune
      final fortune = await apiService.getFortune(
        userId: user.id,
        fortuneType: widget.fortuneType,
        params: params,
      );

      Logger.info('✅ [MovingFortune] API fortune loaded successfully');
      return fortune;

    } catch (e, stackTrace) {
      Logger.error('❌ [MovingFortune] API failed', e, stackTrace);
      rethrow;
    }
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
