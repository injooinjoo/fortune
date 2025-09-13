import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../services/fortune_history_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/app_header.dart';
import '../widgets/moving_step_indicator.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../widgets/moving_input_unified.dart';
import '../widgets/moving_result_infographic.dart';
import '../../../../services/ad_service.dart';

/// 토스 스타일 이사운 페이지
class MovingFortuneTossPage extends ConsumerStatefulWidget {
  const MovingFortuneTossPage({super.key});

  @override
  ConsumerState<MovingFortuneTossPage> createState() => _MovingFortuneTossPageState();
}

class _MovingFortuneTossPageState extends ConsumerState<MovingFortuneTossPage> {
  int _currentStep = 0;

  // 사용자 입력 데이터
  String _currentArea = '';
  String _targetArea = '';
  String _movingPeriod = '';
  String _purpose = '';

  void _onInputComplete(String currentArea, String targetArea, String period, String purpose) async {
    setState(() {
      _currentArea = currentArea;
      _targetArea = targetArea;
      _movingPeriod = period;
      _purpose = purpose;
    });

    // 광고 표시 후 결과 페이지로 이동
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        // 운세 결과를 히스토리에 저장
        await _saveMovingFortuneResult();

        if (mounted) {
          setState(() {
            _currentStep = 1; // 결과 페이지로 이동
          });
        }
      },
      onAdFailed: () async {
        // 광고 실패 시에도 결과 표시
        await _saveMovingFortuneResult();

        if (mounted) {
          setState(() {
            _currentStep = 1; // 결과 페이지로 이동
          });
        }
      },
    );
  }

  /// 이사운 결과를 히스토리에 저장
  Future<void> _saveMovingFortuneResult() async {
    try {
      final userProfile = ref.read(userProfileProvider).value;
      final userName = userProfile?.name ?? '사용자';
      
      // 임시 점수 생성 (실제로는 운세 API에서 받을 값)
      final score = 65 + (DateTime.now().millisecond % 30);
      
      final summary = {
        'score': score,
        'content': '${userName}님의 이사운을 분석한 결과입니다.',
        'advice': _getMainAdvice(),
        'luckyDirection': _getLuckyDirection(),
        'luckyDates': _getLuckyDates().map((d) => d.toIso8601String()).toList(),
      };

      final metadata = {
        'name': userName,
        'birthDate': userProfile?.birthDate?.toIso8601String(),
        'currentArea': _currentArea,
        'targetArea': _targetArea,
        'movingPeriod': _movingPeriod,
        'purpose': _purpose,
      };

      final tags = ['이사', '주거', _purpose];

      await FortuneHistoryService().saveFortuneResult(
        fortuneType: 'moving',
        title: '${userName}님의 이사운',
        summary: summary,
        fortuneData: summary, // fortuneData 추가
        metadata: metadata,
        tags: tags,
      );

      Logger.info('[MovingFortune] 이사운 결과 저장 완료');
    } catch (error) {
      Logger.error('[MovingFortune] 이사운 결과 저장 실패: $error');
    }
  }

  /// 목적에 따른 조언 생성
  String _getMainAdvice() {
    switch (_purpose) {
      case '직장 때문에':
        return '직장과 가까운 곳일수록 업무 운이 상승합니다';
      case '결혼해서':
        return '두 사람의 화합을 위해 남향집을 추천드려요';
      case '교육 환경':
        return '아이의 학업운을 위해 조용한 환경이 좋겠어요';
      case '더 나은 환경':
        return '새로운 시작에는 깨끗하고 밝은 집이 최고예요';
      case '투자 목적':
        return '장기적인 관점에서 교통이 편리한 곳을 선택하세요';
      default:
        return '가족 모두가 행복할 수 있는 따뜻한 집을 찾으세요';
    }
  }

  /// 길방향 생성
  String _getLuckyDirection() {
    final directions = ['동쪽', '서쪽', '남쪽', '북쪽'];
    return directions[DateTime.now().millisecond % directions.length];
  }

  /// 길한 날짜 생성
  List<DateTime> _getLuckyDates() {
    final now = DateTime.now();
    final random = DateTime.now().millisecond;
    return List.generate(3, (index) => 
      now.add(Duration(days: 10 + index * 15 + (random % 10))));
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentStep();
  }

  Widget _buildCurrentStep() {
    final userProfile = ref.watch(userProfileProvider).value;
    
    switch (_currentStep) {
      case 0:
        return MovingInputUnified(
          onComplete: _onInputComplete,
        );
      case 1:
        return MovingResultInfographic(
          name: userProfile?.name ?? '사용자',
          birthDate: userProfile?.birthDate ?? DateTime.now(),
          currentArea: _currentArea,
          targetArea: _targetArea,
          movingPeriod: _movingPeriod,
          purpose: _purpose,
          onRetry: () {
            setState(() {
              _currentStep = 0;
              // 모든 데이터 초기화
              _currentArea = '';
              _targetArea = '';
              _movingPeriod = '';
              _purpose = '';
            });
          },
        );
      default:
        return MovingInputUnified(
          onComplete: _onInputComplete,
        );
    }
  }

}