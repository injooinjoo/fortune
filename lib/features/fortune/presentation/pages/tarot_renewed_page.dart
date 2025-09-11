import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as dart_math;
import 'dart:math';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/constants/tarot_metadata.dart';
import '../widgets/tarot/tarot_question_selector.dart';
import '../widgets/tarot/tarot_loading_button.dart';
import '../widgets/tarot/tarot_result_card.dart';
import '../../../../services/ad_service.dart';

enum TarotFlowState {
  initial,      // 초기 화면
  questioning,  // 질문 선택/입력
  loading,     // 로딩 중
  result       // 결과 표시
}

class TarotRenewedPage extends ConsumerStatefulWidget {
  const TarotRenewedPage({super.key});

  @override
  ConsumerState<TarotRenewedPage> createState() => _TarotRenewedPageState();
}

class _TarotRenewedPageState extends ConsumerState<TarotRenewedPage>
    with TickerProviderStateMixin {
  TarotFlowState _currentState = TarotFlowState.questioning;
  String? _selectedQuestion;
  String? _customQuestion;
  Map<String, dynamic>? _tarotResult;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // 네비게이션 바 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
    });
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // 초기 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    // 페이지 나갈 때 네비게이션 바 다시 표시 - dispose에서 ref 사용 금지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 네비게이션 바 표시는 다른 곳에서 처리하거나 제거
    });
    
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 네비게이션 바 숨기기 - 빌드할 때마다 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).hide();
      }
    });
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildCurrentStateWidget(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF191919)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        '타로 카드',
        style: TextStyle(
          color: Color(0xFF191919),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCurrentStateWidget() {
    switch (_currentState) {
      case TarotFlowState.initial:
        return _buildInitialScreen();
      case TarotFlowState.questioning:
        return _buildQuestioningScreen();
      case TarotFlowState.loading:
        return _buildLoadingScreen();
      case TarotFlowState.result:
        return _buildResultScreen();
    }
  }

  Widget _buildInitialScreen() {
    final userProfile = ref.watch(userProfileProvider).value;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 사용자 인사말 (토스 스타일)
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7C3AED),
                          const Color(0xFF3B82F6),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userProfile?.name ?? '익명'}님의',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B95A1),
                          ),
                        ),
                        const Text(
                          '타로 운세',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191919),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 타로 카드 이미지 (큰 카드)
              Center(
                child: Container(
                  width: 200,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1E3A5F),
                            const Color(0xFF0D1B2A),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _TarotCardBackPainter(),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 설명 텍스트
              const Center(
                child: Text(
                  '카드가 전하는 신비로운 메시지를\n받아보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // 시작하기 버튼
              TossButton(
                text: '타로 운세 보기',
                onPressed: () async {
                  await AdService.instance.showInterstitialAdWithCallback(
                    onAdCompleted: () {
                      setState(() {
                        _currentState = TarotFlowState.questioning;
                      });
                    },
                    onAdFailed: () {
                      // Still allow tarot reading even if ad fails
                      setState(() {
                        _currentState = TarotFlowState.questioning;
                      });
                    },
                  );
                },
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestioningScreen() {
    return TarotQuestionSelector(
      onQuestionSelected: (question) {
        setState(() {
          _selectedQuestion = question.isEmpty ? null : question;
          _customQuestion = null;
        });
      },
      onCustomQuestionChanged: (question) {
        setState(() {
          _customQuestion = question;
          _selectedQuestion = null;
        });
      },
      onStartReading: () {
        _startTarotReading();
      },
      selectedQuestion: _selectedQuestion,
      customQuestion: _customQuestion,
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED),
                  const Color(0xFF3B82F6),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '카드를 뽑고 있어요...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildResultScreen() {
    if (_tarotResult == null) return const SizedBox();
    
    return TarotResultCard(
      result: _tarotResult!,
      question: _selectedQuestion ?? _customQuestion ?? '일반 운세',
      onRetry: () {
        setState(() {
          _currentState = TarotFlowState.questioning;
          _tarotResult = null;
        });
      },
    );
  }

  void _startTarotReading() {
    if (!mounted) return;
    
    setState(() {
      _currentState = TarotFlowState.loading;
    });
    
    // 로딩 시뮬레이션 후 바로 결과 생성
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _generateTarotResult();
    });
  }

  void _generateTarotResult() {
    if (!mounted) return;
    
    // 랜덤하게 메이저 아르카나 카드 선택
    final random = Random();
    final cardNumbers = TarotMetadata.majorArcana.keys.toList();
    final selectedCardNumber = cardNumbers[random.nextInt(cardNumbers.length)];
    final selectedCard = TarotMetadata.majorArcana[selectedCardNumber]!;
    
    // 질문에 따른 해석 커스터마이징
    String interpretation = selectedCard.uprightMeaning;
    String advice = selectedCard.advice;
    
    if (_selectedQuestion != null || _customQuestion != null) {
      final question = _selectedQuestion ?? _customQuestion ?? '';
      
      // 질문 키워드에 따른 해석 조정
      if (question.contains('연애') || question.contains('사랑')) {
        interpretation = '${selectedCard.name}가 연애운에 대해 전하는 메시지입니다. ${selectedCard.uprightMeaning}';
        advice = '연애 관계에서 ${selectedCard.advice}';
      } else if (question.contains('직장') || question.contains('일') || question.contains('커리어')) {
        interpretation = '${selectedCard.name}가 직장운에 대해 알려줍니다. ${selectedCard.uprightMeaning}';
        advice = '업무와 관련하여 ${selectedCard.advice}';
      } else if (question.contains('돈') || question.contains('재물') || question.contains('금전')) {
        interpretation = '${selectedCard.name}가 금전운을 보여줍니다. ${selectedCard.uprightMeaning}';
        advice = '재정 관리에 있어 ${selectedCard.advice}';
      }
    }
    
    // 역방향 카드 확률 (30%)
    final isReversed = random.nextInt(100) < 30;
    if (isReversed) {
      interpretation = '[역방향] ${selectedCard.reversedMeaning}';
      advice = '주의사항: ${selectedCard.advice}';
    }
    
    setState(() {
      _tarotResult = {
        'cardName': selectedCard.name,
        'cardNumber': selectedCardNumber,
        'cardImage': 'assets/images/tarot/major_${selectedCardNumber.toString().padLeft(2, '0')}.jpg',
        'interpretation': interpretation,
        'keywords': selectedCard.keywords,
        'advice': advice,
        'isReversed': isReversed,
        'element': selectedCard.element,
        'astrology': selectedCard.astrology,
        'story': selectedCard.story,
        'mythology': selectedCard.mythology,
        'psychologicalMeaning': selectedCard.psychologicalMeaning,
      };
      _currentState = TarotFlowState.result;
    });
  }
}

// 타로 카드 뒷면 그리기 위한 CustomPainter
class _TarotCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.3);

    final center = Offset(size.width / 2, size.height / 2);
    
    // 중앙 별 그리기
    _drawStar(canvas, center, size.width * 0.15, paint);
    
    // 주변 별들 그리기
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final starPos = Offset(
        center.dx + size.width * 0.25 * (angle.cos()),
        center.dy + size.width * 0.25 * (angle.sin()),
      );
      _drawStar(canvas, starPos, size.width * 0.08, paint);
    }
    
    // 테두리 패턴
    final borderRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.9,
    );
    canvas.drawRect(borderRect, paint);
    
    final innerRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.08,
      size.width * 0.7,
      size.height * 0.84,
    );
    paint.strokeWidth = 0.5;
    canvas.drawRect(innerRect, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const angle = -3.14159 / 2;

    for (int i = 0; i < 5; i++) {
      final outerAngle = angle + i * 2 * 3.14159 / 5;
      final outerX = center.dx + radius * outerAngle.cos();
      final outerY = center.dy + radius * outerAngle.sin();

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerRadius = radius * 0.4;
      final innerAngle = angle + (i * 2 + 1) * 3.14159 / 5;
      final innerX = center.dx + innerRadius * innerAngle.cos();
      final innerY = center.dy + innerRadius * innerAngle.sin();
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Math extensions
extension on double {
  double cos() => dart_math.cos(this);
  double sin() => dart_math.sin(this);
}