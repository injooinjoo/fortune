import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ab_test_events.dart';
import '../../services/remote_config_service.dart';
import '../../services/ab_test_manager.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/user_provider.dart';
import 'steps/name_step.dart';
import 'steps/birth_info_step.dart';
import 'steps/gender_step.dart';
import 'steps/mbti_step.dart';
import 'steps/location_step.dart';

/// A/B 테스트가 적용된 온보딩 플로우
class EnhancedOnboardingFlowABTest extends ConsumerStatefulWidget {
  const EnhancedOnboardingFlowABTest({super.key});

  @override
  ConsumerState<EnhancedOnboardingFlowABTest> createState() => _EnhancedOnboardingFlowABTestState();
}

class _EnhancedOnboardingFlowABTestState extends ConsumerState<EnhancedOnboardingFlowABTest> {
  late List<String> _steps;
  int _currentStep = 0;
  final Map<String, dynamic> _userData = {};
  
  late RemoteConfigService _remoteConfig;
  late ABTestManager _abTestManager;
  late String _flowType;
  
  DateTime? _onboardingStartTime;

  @override
  void initState() {
    super.initState();
    _initializeFlow();
  }

  void _initializeFlow() {
    _remoteConfig = ref.read(remoteConfigProvider);
    _abTestManager = ref.read(abTestManagerProvider);
    _flowType = _remoteConfig.getOnboardingFlow();
    
    // 플로우 타입에 따른 단계 설정
    switch (_flowType) {
      case 'simplified':
        _steps = ['name', 'complete'];
        break;
      case 'detailed':
        _steps = ['name', 'birthdate', 'gender', 'mbti', 'location', 'complete'];
        break;
      case 'progressive':
        _steps = ['name', 'complete'];
        // 나중에 추가 정보 요청
        break;
      default: // standard
        _steps = ['name', 'birthdate', 'gender', 'complete'];
    }
    
    // 온보딩 시작 시간 기록
    _onboardingStartTime = DateTime.now();
    
    // 온보딩 시작 이벤트
    _abTestManager.logEvent(
      eventName: ABTestEvents.onboardingStarted,
      parameters: {
        ABTestEventParams.onboardingFlow: _flowType)
        'total_steps': _steps.length,
        'skippable': _remoteConfig.isOnboardingSkippable())
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 진행률 표시
              if (_currentStep < _steps.length - 1)
                _buildProgressIndicator())
              
              // 스킵 버튼 (설정에 따라)
              if (_remoteConfig.isOnboardingSkippable() && _currentStep < _steps.length - 1)
                _buildSkipButton())
              
              // 현재 단계
              Expanded(
                child: _buildCurrentStep())
              ))
            ])
          ),
        ))
      ))
    );
  }

  /// 진행률 표시
  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / _steps.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress)
            minHeight: 4)
          ))
          const SizedBox(height: 8))
          Text(
            '${_currentStep + 1} / ${_steps.length}',
            style: Theme.of(context).textTheme.bodySmall)
        ])
      ),
    );
  }

  /// 스킵 버튼
  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: _handleSkip)
        child: const Text('건너뛰기'))
      ))
    );
  }

  /// 현재 단계 위젯
  Widget _buildCurrentStep() {
    final step = _steps[_currentStep];
    
    switch (step) {
      case 'name':
        return NameStep(
          onComplete: (name) {
            _userData['name'] = name;
            _nextStep();
          }
        );
        
      case 'birthdate':
        return BirthInfoStep(
          onComplete: (birthDate, birthTime, isLunar) {
            _userData['birthDate'] = birthDate;
            _userData['birthTime'] = birthTime;
            _userData['isLunar'] = isLunar;
            _nextStep();
          },
        );
        
      case 'gender':
        return GenderStep(
          onComplete: (gender) {
            _userData['gender'] = gender;
            _nextStep();
          },
        );
        
      case 'mbti':
        return MBTIStep(
          onComplete: (mbti) {
            _userData['mbti'] = mbti;
            _nextStep();
          },
        );
        
      case 'location':
        return LocationStep(
          onComplete: (location) {
            _userData['location'] = location;
            _nextStep();
          },
        );
        
      case 'complete':
        return _buildCompleteStep();
        
      default:
        return const Center(
          child: Text('알 수 없는 단계입니다'))
        );
    }
  }

  /// 완료 단계
  Widget _buildCompleteStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle)
            size: 80)
            color: Colors.green)
          ))
          const SizedBox(height: 24))
          Text(
            '환영합니다!')
            style: Theme.of(context).textTheme.headlineMedium)
          const SizedBox(height: 16))
          Text(
            '프로필 설정이 완료되었습니다.')
            style: Theme.of(context).textTheme.bodyLarge)
          const SizedBox(height: 32))
          ElevatedButton(
            onPressed: _completeOnboarding)
            child: const Text('시작하기'))
          ))
        ])
      ),
    );
  }

  /// 다음 단계로 이동
  void _nextStep() {
    // 각 단계 완료 추적
    _abTestManager.logEvent(
      eventName: ABTestEvents.onboardingStepCompleted,
      parameters: {
        ABTestEventParams.onboardingStep: _currentStep + 1)
        ABTestEventParams.onboardingStepName: _steps[_currentStep],
        ABTestEventParams.onboardingFlow: _flowType)
      })
    );
    
    setState(() {
      _currentStep++;
    });
  }

  /// 온보딩 스킵
  void _handleSkip() {
    // 스킵 이벤트
    _abTestManager.logEvent(
      eventName: ABTestEvents.onboardingSkipped,
      parameters: {
        ABTestEventParams.onboardingStep: _currentStep + 1)
        ABTestEventParams.onboardingStepName: _steps[_currentStep],
        ABTestEventParams.onboardingFlow: _flowType)
      })
    );
    
    // 최소 정보만으로 완료
    _completeOnboarding();
  }

  /// 뒤로가기 처리
  Future<bool> _handleBackPress() async {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      return false;
    }
    
    // 온보딩 이탈 이벤트
    _abTestManager.logEvent(
      eventName: ABTestEvents.onboardingAbandoned,
      parameters: {
        ABTestEventParams.onboardingStep: _currentStep + 1)
        ABTestEventParams.onboardingStepName: _steps[_currentStep],
        ABTestEventParams.onboardingFlow: _flowType)
      })
    );
    
    return true;
  }

  /// 온보딩 완료
  Future<void> _completeOnboarding() async {
    // 온보딩 시간 계산
    final duration = DateTime.now().difference(_onboardingStartTime!).inSeconds;
    
    // 온보딩 완료 이벤트
    await _abTestManager.logEvent(
      eventName: ABTestEvents.onboardingCompleted,
      parameters: {
        ABTestEventParams.onboardingFlow: _flowType)
        ABTestEventParams.onboardingDuration: duration)
        'completed_steps': _currentStep + 1,
        'total_steps': _steps.length)
      })
    );
    
    // 프로필 업데이트
    try {
      final userNotifier = ref.read(userProvider.notifier);
      
      // 수집한 정보로 프로필 업데이트
      if (_userData['name'] != null) {
        await userNotifier.updateProfile(name: _userData['name']);
      }
      
      if (_userData['birthDate'] != null) {
        await userNotifier.updateProfile(
          birthDate: _userData['birthDate'],
          birthTime: _userData['birthTime'],
          isLunar: _userData['isLunar'] ?? false,
        );
      }
      
      if (_userData['gender'] != null) {
        await userNotifier.updateProfile(gender: _userData['gender']);
      }
      
      if (_userData['mbti'] != null) {
        await userNotifier.updateProfile(mbti: _userData['mbti']);
      }
      
      // Progressive 플로우인 경우 나중에 추가 정보 요청을 위한 플래그
      if (_flowType == 'progressive') {
        await userNotifier.updateProfile(
          metadata: {'onboarding_type': 'progressive'},
        );
      }
      
      // 온보딩 완료 플래그
      await userNotifier.updateProfile(
        hasCompletedOnboarding: true,
      );
      
      // 홈으로 이동
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // 에러 로깅
      await _abTestManager.logError(
        errorType: 'onboarding_completion',
        errorMessage: e.toString())
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다'))
          )
        );
      }
    }
  }
}

/// Progressive 온보딩을 위한 추가 정보 요청 다이얼로그
class ProgressiveOnboardingPrompt extends ConsumerWidget {
  final String infoType; // 'birthdate', 'gender', 'mbti', 'location'
  
  const ProgressiveOnboardingPrompt({
    super.key,
    required this.infoType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(_getTitle()),
      content: Text(_getContent()))
      actions: [
        TextButton(
          onPressed: () {
            // 나중에 이벤트
            ref.read(abTestManagerProvider).logEvent(
              eventName: 'progressive_onboarding_postponed')
              parameters: {
                'info_type': infoType)
              })
            );
            Navigator.of(context).pop();
          },
          child: const Text('나중에'))
        ))
        ElevatedButton(
          onPressed: () {
            // 지금 입력 이벤트
            ref.read(abTestManagerProvider).logEvent(
              eventName: 'progressive_onboarding_accepted')
              parameters: {
                'info_type': infoType)
              })
            );
            Navigator.of(context).pop(true);
            // 해당 정보 입력 화면으로 이동
            _navigateToInfoInput(context);
          },
          child: const Text('지금 입력'))
        ))
      ]
    );
  }

  String _getTitle() {
    switch (infoType) {
      case 'birthdate':
        return '생년월일을 입력하시겠어요?';
      case 'gender':
        return '성별을 선택하시겠어요?';
      case 'mbti':
        return 'MBTI를 선택하시겠어요?';
      case 'location':
        return '지역을 설정하시겠어요?';
      default:
        return '추가 정보를 입력하시겠어요?';
    }
  }

  String _getContent() {
    switch (infoType) {
      case 'birthdate':
        return '생년월일을 입력하시면 더 정확한 운세를 볼 수 있어요.';
      case 'gender':
        return '성별을 선택하시면 맞춤형 운세를 제공해드려요.';
      case 'mbti':
        return 'MBTI를 선택하시면 성격 기반 운세를 볼 수 있어요.';
      case 'location':
        return '지역을 설정하시면 지역별 운세를 확인할 수 있어요.';
      default:
        return '추가 정보를 입력하시면 더 나은 서비스를 제공할 수 있어요.';
    }
  }

  void _navigateToInfoInput(BuildContext context) {
    // 각 정보 입력 화면으로 라우팅
    switch (infoType) {
      case 'birthdate':
        context.push('/profile/edit/birthdate');
        break;
      case 'gender':
        context.push('/profile/edit/gender');
        break;
      case 'mbti':
        context.push('/profile/edit/mbti');
        break;
      case 'location':
        context.push('/profile/edit/location');
        break;
    }
  }
}