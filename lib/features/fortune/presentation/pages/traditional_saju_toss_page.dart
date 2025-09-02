import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../providers/saju_provider.dart';
import '../widgets/saju_table_toss.dart';
import '../widgets/saju_element_chart.dart';
import '../widgets/manseryeok_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 토스 스타일 전통 사주팔자 페이지
class TraditionalSajuTossPage extends ConsumerStatefulWidget {
  const TraditionalSajuTossPage({super.key});

  @override
  ConsumerState<TraditionalSajuTossPage> createState() => _TraditionalSajuTossPageState();
}

class _TraditionalSajuTossPageState extends ConsumerState<TraditionalSajuTossPage> 
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _resultAnimationController;
  
  // 질문 선택 및 운세보기 상태 관리
  String? _selectedQuestion;
  final TextEditingController _customQuestionController = TextEditingController();
  bool _isFortuneLoading = false;
  bool _showResults = false;
  
  @override
  void initState() {
    super.initState();
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 네비게이션 바 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
      // 바로 사주 데이터 로드
      ref.read(sajuProvider.notifier).fetchUserSaju();
    });
  }
  
  @override
  void dispose() {
    // 애니메이션 컨트롤러 먼저 해제
    _resultAnimationController.dispose();
    _customQuestionController.dispose();
    super.dispose();
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    final sajuState = ref.watch(sajuProvider);
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: TossTheme.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: TossTheme.textBlack),
          onPressed: () {
            // 네비게이션 바 다시 보이기
            ref.read(navigationVisibilityProvider.notifier).show();
            Navigator.pop(context);
          },
        ),
        title: Text(
          '전통 사주팔자',
          style: TossTheme.heading3.copyWith(color: TossTheme.textBlack),
        ),
      ),
      body: _buildBody(sajuState),
    );
  }
  
  Widget _buildBody(SajuState sajuState) {
    if (sajuState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('사주 데이터를 불러오는 중...'),
          ],
        ),
      );
    }
    
    if (sajuState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: TossTheme.error),
            const SizedBox(height: 16),
            Text(
              sajuState.error!,
              textAlign: TextAlign.center,
              style: TossTheme.body3,
            ),
            const SizedBox(height: 24),
            TossButton(
              text: '다시 시도',
              onPressed: () {
                ref.read(sajuProvider.notifier).fetchUserSaju();
              },
              style: TossButtonStyle.primary,
            ),
          ],
        ),
      );
    }
    
    if (sajuState.sajuData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: TossTheme.textGray500),
            const SizedBox(height: 16),
            Text(
              '사주 데이터가 없습니다.\n먼저 사주 계산을 완료해주세요.',
              textAlign: TextAlign.center,
              style: TossTheme.body3,
            ),
          ],
        ),
      );
    }
    
    // 사주 데이터가 있으면 메인 화면 표시
    return _buildMainScreen(sajuState.sajuData!);
  }
  
  Widget _buildMainScreen(Map<String, dynamic> sajuData) {
    if (_showResults) {
      return _buildResultScreen(sajuData);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      child: Column(
        children: [
          // 기본 사주 정보만 표시
          _buildBasicSajuInfo(sajuData),
          const SizedBox(height: TossTheme.spacingL),
          
          // 질문 선택 섹션
          _buildQuestionSelectionSection(),
          const SizedBox(height: TossTheme.spacingL),
          
          // 운세보기 버튼
          _buildFortuneButton(),
          const SizedBox(height: TossTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildResultScreen(Map<String, dynamic> sajuData) {
    _resultAnimationController.forward();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      child: Column(
        children: [
          // 운세 결과
          _buildFortuneResult(sajuData),
          const SizedBox(height: TossTheme.spacingL),
          
          // 다시 보기 버튼
          TossButton(
            text: '다른 운세 보기',
            onPressed: () {
              setState(() {
                _showResults = false;
                _selectedQuestion = null;
                _customQuestionController.clear();
              });
            },
            style: TossButtonStyle.primary,
            width: double.infinity,
          ),
          const SizedBox(height: TossTheme.spacingL),
          
          // 공유 버튼
          TossButton(
            text: '결과 공유하기',
            onPressed: () {
              // TODO: 공유 기능 구현
            },
            style: TossButtonStyle.secondary,
            width: double.infinity,
          ),
          const SizedBox(height: TossTheme.spacingXXL),
        ],
      ),
    );
  }
  
  Widget _buildInterpretation(Map<String, dynamic> sajuData) {
    final interpretation = sajuData['interpretation'] ?? '';
    final personalityAnalysis = sajuData['personalityAnalysis'] ?? '';
    final careerGuidance = sajuData['careerGuidance'] ?? '';
    final relationshipAdvice = sajuData['relationshipAdvice'] ?? '';
    
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: TossTheme.brandBlue, size: 24),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '종합 해석',
                style: TossTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingM),
          if (interpretation.isNotEmpty) ...[
            Text(
              interpretation,
              style: TossTheme.body3,
            ),
            const SizedBox(height: TossTheme.spacingM),
          ],
          if (personalityAnalysis.isNotEmpty)
            _buildInterpretationItem('성격 분석', personalityAnalysis),
          if (careerGuidance.isNotEmpty)
            _buildInterpretationItem('직업 가이드', careerGuidance),
          if (relationshipAdvice.isNotEmpty)
            _buildInterpretationItem('인간관계', relationshipAdvice),
        ],
      ),
    );
  }
  
  Widget _buildInterpretationItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TossTheme.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            child: Text(
              title,
              style: TossTheme.caption.copyWith(
                color: TossTheme.textGray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: TossTheme.spacingM),
          Expanded(
            child: Text(
              content,
              style: TossTheme.body3,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendations(Map<String, dynamic> sajuData) {
    final dominantElement = sajuData['dominantElement'] ?? '목';
    final lackingElement = sajuData['lackingElement'] ?? '수';
    
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: TossTheme.warning, size: 24),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '개운법',
                style: TossTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingM),
          _buildRecommendationItem(
            '보완 오행',
            '$lackingElement 기운을 보충하세요',
            _getElementColor(lackingElement),
          ),
          _buildRecommendationItem(
            '행운의 방향',
            _getLuckyDirection(lackingElement),
            TossTheme.brandBlue,
          ),
          _buildRecommendationItem(
            '행운의 색상',
            _getLuckyColor(dominantElement),
            _getElementColor(dominantElement),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationItem(String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: TossTheme.spacingM),
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: TossTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TossTheme.body3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  
  String _getLuckyDirection(String element) {
    final directions = {
      '목': '동쪽',
      '화': '남쪽',
      '토': '중앙',
      '금': '서쪽',
      '수': '북쪽',
    };
    return directions[element] ?? '동쪽';
  }
  
  String _getLuckyColor(String element) {
    final colors = {
      '목': '초록색, 청색',
      '화': '빨간색, 분홍색',
      '토': '노란색, 갈색',
      '금': '흰색, 은색',
      '수': '검은색, 파란색',
    };
    return colors[element] ?? '파란색';
  }
  
  
  Color _getElementColor(String element) {
    final colors = {
      '목': TossTheme.success,
      '화': TossTheme.error,
      '토': TossTheme.warning,
      '금': TossTheme.textGray600,
      '수': TossTheme.brandBlue,
    };
    return colors[element] ?? TossTheme.textGray600;
  }
  
  Widget _buildBasicSajuInfo(Map<String, dynamic> sajuData) {
    // 오행 균형 데이터 생성
    final elementBalance = {
      '목': sajuData['elementBalance']?['목'] ?? 0,
      '화': sajuData['elementBalance']?['화'] ?? 0,
      '토': sajuData['elementBalance']?['토'] ?? 0,
      '금': sajuData['elementBalance']?['금'] ?? 0,
      '수': sajuData['elementBalance']?['수'] ?? 0,
    };
    
    return Column(
      children: [
        // 사주 명식 표시 (만세력 스타일)
        ManseryeokDisplay(sajuData: sajuData),
        const SizedBox(height: TossTheme.spacingL),
        
        // 오행 차트
        SajuElementChart(
          elementBalance: elementBalance,
          animationController: _resultAnimationController,
        ),
      ],
    );
  }

  Widget _buildQuestionSelectionSection() {
    final predefinedQuestions = [
      '언제 돈이 들어올까요?',
      '어떤 일이 나에게 맞을까요?',
      '언제 결혼하면 좋을까요?',
      '건강 주의사항이 있나요?',
      '어느 방향으로 가면 좋을까요?',
    ];

    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '궁금한 질문을 선택하세요',
            style: TossTheme.heading3,
          ),
          const SizedBox(height: TossTheme.spacingM),
          
          // 미리 정의된 질문들
          ...predefinedQuestions.map((question) => 
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: TossTheme.spacingS),
              child: TossButton(
                text: question,
                onPressed: () {
                  setState(() {
                    _selectedQuestion = question;
                    _customQuestionController.clear();
                  });
                },
                style: _selectedQuestion == question 
                    ? TossButtonStyle.primary 
                    : TossButtonStyle.secondary,
              ),
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingL),
          
          // 직접 질문 입력
          Text(
            '또는 직접 질문을 작성해주세요',
            style: TossTheme.body3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          
          TextField(
            controller: _customQuestionController,
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _selectedQuestion = value;
                } else if (_selectedQuestion != null && !predefinedQuestions.contains(_selectedQuestion)) {
                  _selectedQuestion = null;
                }
              });
            },
            decoration: InputDecoration(
              hintText: '예: 언제 직장을 옮겨야 할까요?',
              hintStyle: TossTheme.hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusM),
                borderSide: BorderSide(color: TossTheme.borderPrimary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusM),
                borderSide: BorderSide(color: TossTheme.brandBlue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusM),
                borderSide: BorderSide(color: TossTheme.borderPrimary),
              ),
              contentPadding: const EdgeInsets.all(TossTheme.spacingM),
            ),
            style: TossTheme.body3,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneButton() {
    final hasQuestion = _selectedQuestion != null && _selectedQuestion!.isNotEmpty;
    
    return Container(
      width: double.infinity,
      height: 60,
      child: TossButton(
        text: _isFortuneLoading ? '운세를 보고 있어요...' : '운세보기',
        onPressed: hasQuestion && !_isFortuneLoading ? _onFortuneButtonPressed : null,
        style: TossButtonStyle.primary,
        isLoading: _isFortuneLoading,
      ),
    );
  }

  Future<void> _onFortuneButtonPressed() async {
    setState(() {
      _isFortuneLoading = true;
    });

    // 로딩 애니메이션 (2초)
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: 여기에 광고 표시 로직 추가
    
    setState(() {
      _isFortuneLoading = false;
      _showResults = true;
    });
  }

  Widget _buildFortuneResult(Map<String, dynamic> sajuData) {
    if (_selectedQuestion == null) return const SizedBox.shrink();
    
    String answer = _getAnswerForQuestion(_selectedQuestion!, sajuData);
    
    return TossCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: TossTheme.brandBlue, size: 24),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '운세 결과',
                style: TossTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingM),
          
          // 질문
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingM),
            decoration: BoxDecoration(
              color: TossTheme.brandBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossTheme.radiusM),
              border: Border.all(color: TossTheme.brandBlue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q.',
                  style: TossTheme.body3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TossTheme.brandBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedQuestion!,
                  style: TossTheme.body3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingM),
          
          // 답변
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingM),
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(TossTheme.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A.',
                  style: TossTheme.body3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TossTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: TossTheme.body3.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAnswerForQuestion(String question, Map<String, dynamic> sajuData) {
    switch (question) {
      case '언제 돈이 들어올까요?':
        return _getFinancialAnswer(sajuData);
      case '어떤 일이 나에게 맞을까요?':
        return _getCareerAnswer(sajuData);
      case '언제 결혼하면 좋을까요?':
        return _getMarriageAnswer(sajuData);
      case '건강 주의사항이 있나요?':
        return _getHealthAnswer(sajuData);
      case '어느 방향으로 가면 좋을까요?':
        return _getDirectionAnswer(sajuData);
      default:
        // 커스텀 질문에 대한 답변
        return _getCustomAnswer(question, sajuData);
    }
  }

  String _getCustomAnswer(String question, Map<String, dynamic> sajuData) {
    final dominantElement = sajuData['dominantElement'] ?? '목';
    final lackingElement = sajuData['lackingElement'] ?? '수';
    
    return '''당신의 사주를 기반으로 해석해드립니다.

주요 포인트:
• 현재 ${dominantElement} 기운이 강하여 의욕적이고 추진력이 있습니다
• ${lackingElement} 기운이 부족하여 이 부분을 보완하면 더욱 좋을 것
• 현재 대운에서는 신중하게 접근하는 것이 중요

전반적으로 긍정적인 변화가 예상되며, 인내심을 가지고 추진하시기 바랍니다.''';
  }


  // 질문별 답변 생성 메서드들
  String _getFinancialAnswer(Map<String, dynamic> sajuData) {
    final dominantElement = sajuData['dominantElement'] ?? '목';
    return '''재물운은 ${dominantElement} 기운의 영향으로 점진적으로 상승할 것으로 보입니다.

특히 현재 대운에서는:
• 정재보다 편재의 기운이 강하여 사업이나 투자를 통한 수익이 유리
• 가을철(8-10월)에 재물운이 가장 왕성
• 서쪽이나 북서쪽 방향의 사업이나 투자에 관심을 가져보세요

주의사항: 과도한 욕심보다는 꾸준한 축적이 중요한 시기입니다.''';
  }

  String _getCareerAnswer(Map<String, dynamic> sajuData) {
    return '''당신의 사주를 보면 다음과 같은 직업 분야가 특히 유리합니다:

추천 직업군:
• 교육, 상담 관련 업무 (정인의 기운)
• 경영, 관리직 (정관의 기운)
• 창의적 분야의 일 (식신의 기운)

특히 사람을 상대하는 일이나 지식을 전달하는 업무에서 큰 성과를 거둘 수 있습니다. 혼자 하는 일보다는 팀워크가 중요한 환경에서 더욱 빛을 발할 것입니다.''';
  }

  String _getMarriageAnswer(Map<String, dynamic> sajuData) {
    return '''결혼운을 보면:

좋은 시기:
• 현재 대운에서는 인연운이 상당히 좋습니다
• 특히 봄철(3-5월)이나 가을철(9-11월)에 좋은 만남이 예상
• 나이 차이가 2-3살 정도인 상대와 궁합이 잘 맞을 것

결혼 후에는 배우자의 도움으로 사회적 지위나 재물운이 상승할 가능성이 높습니다. 서두르기보다는 신중하게 선택하는 것이 좋겠습니다.''';
  }

  String _getHealthAnswer(Map<String, dynamic> sajuData) {
    final lackingElement = sajuData['lackingElement'] ?? '수';
    return '''건강 관리에 있어 주의사항:

주의할 부분:
• ${lackingElement} 기운 부족으로 인한 관련 장기 약화 가능성
• 스트레스로 인한 소화기계 문제 주의
• 과로를 피하고 충분한 휴식 필요

건강 관리법:
• 규칙적인 운동과 균형 잡힌 식단
• ${_getLuckyDirection(lackingElement)} 방향으로의 산책이나 운동
• 명상이나 요가 등을 통한 정신적 안정

전체적으로 큰 질병보다는 만성 피로나 스트레스 관리가 중요합니다.''';
  }

  String _getDirectionAnswer(Map<String, dynamic> sajuData) {
    final dominantElement = sajuData['dominantElement'] ?? '목';
    final luckyDirection = _getLuckyDirection(dominantElement);
    
    return '''방향과 관련된 조언:

유리한 방향:
• 주거지: ${luckyDirection} 방향이 가장 유리
• 직장: ${luckyDirection} 방향에 있는 회사나 사업장
• 여행: ${luckyDirection} 방향으로의 여행이 운기 상승에 도움

이사나 이직을 고려한다면 현재 대운이 끝나는 시점인 내년 하반기가 적절한 타이밍입니다. 급하게 결정하기보다는 충분히 준비한 후 움직이는 것을 권합니다.''';
  }
}