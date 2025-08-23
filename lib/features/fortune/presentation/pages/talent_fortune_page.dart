import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../widgets/talent_type_result_widget.dart';
import '../../domain/models/talent_type.dart';

class TalentFortunePage extends BaseFortunePage {
  const TalentFortunePage({
    super.key, 
    super.initialParams,
  }) : super(
          title: '재능 발견',
          description: '당신의 숨은 재능과 잠재력을 분석해드립니다.',
          fortuneType: 'talent',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<TalentFortunePage> createState() => _TalentFortunePageState();
}

class _TalentFortunePageState extends BaseFortunePageState<TalentFortunePage> {
  TalentTypeInfo? _talentTypeInfo;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // 재능 분석 API 호출을 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));
    
    // 사용자 답변을 바탕으로 재능 분석 결과 생성
    final talents = _analyzeTalents(params);
    final talentType = TalentTypeProvider.determineTalentType(talents);
    _talentTypeInfo = TalentTypeProvider.getInfo(talentType);
    
    return Fortune(
      id: 'talent_${DateTime.now().millisecondsSinceEpoch}',
      userId: userProfile?.id ?? 'anonymous',
      type: 'talent',
      content: _generateTalentDescription(_talentTypeInfo!),
      createdAt: DateTime.now(),
      category: 'talent-discovery',
      overallScore: talents['overall'] as int,
      scoreBreakdown: Map<String, int>.from(talents)..remove('overall'),
      description: '당신의 재능 타입과 성장 방향을 알려드립니다.',
      luckyItems: {
        'talent_type': talentType.name,
        'talent_info': _talentTypeInfo!,
        'score_breakdown': talents,
      },
      recommendations: _talentTypeInfo!.actionPlans,
    );
  }

  Map<String, int> _analyzeTalents(Map<String, dynamic> params) {
    // 개선된 재능 분석 로직 - 더 정교하고 개인화된 결과
    final interest = params['interest'] as String? ?? '';
    final strength = params['strength'] as String? ?? '';
    final goal = params['goal'] as String? ?? '';
    
    // 기본 점수 (50-70 랜덤)
    var creativity = 55 + (DateTime.now().millisecondsSinceEpoch % 16);
    var communication = 55 + (DateTime.now().millisecondsSinceEpoch % 16);
    var analysis = 55 + (DateTime.now().millisecondsSinceEpoch % 16);
    var leadership = 55 + (DateTime.now().millisecondsSinceEpoch % 16);
    var focus = 55 + (DateTime.now().millisecondsSinceEpoch % 16);
    var intuition = 55 + (DateTime.now().millisecondsSinceEpoch % 16);
    
    // 관심 분야에 따른 점수 조정
    switch (interest) {
      case '예술과 창작':
        creativity += 25;
        intuition += 15;
        communication += 5;
        break;
      case '비즈니스':
        leadership += 20;
        analysis += 15;
        communication += 10;
        break;
      case '사람과 소통':
        communication += 25;
        leadership += 15;
        intuition += 10;
        break;
      case '과학과 기술':
        analysis += 25;
        focus += 20;
        creativity += 5;
        break;
      case '운동과 활동':
        leadership += 15;
        focus += 15;
        communication += 10;
        break;
      case '학습과 연구':
        analysis += 20;
        focus += 20;
        leadership += 5;
        break;
    }
    
    // 강점에 따른 조정
    switch (strength) {
      case '창의적 사고':
        creativity += 20;
        intuition += 15;
        analysis += 5;
        break;
      case '빠른 실행력':
        leadership += 15;
        focus += 20;
        communication += 5;
        break;
      case '리더십':
        leadership += 25;
        communication += 15;
        intuition += 5;
        break;
      case '분석적 사고':
        analysis += 25;
        focus += 15;
        creativity += 5;
        break;
      case '공감 능력':
        communication += 20;
        intuition += 20;
        leadership += 5;
        break;
      case '문제 해결':
        analysis += 20;
        creativity += 15;
        focus += 10;
        break;
    }
    
    // 목표에 따른 조정
    switch (goal) {
      case '직업 찾기':
        leadership += 15;
        analysis += 10;
        communication += 10;
        break;
      case '학습 방향':
        focus += 20;
        analysis += 15;
        break;
      case '취미 발견':
        creativity += 20;
        intuition += 15;
        break;
      case '성장 방향':
        leadership += 15;
        focus += 15;
        break;
      case '숨은 재능':
        creativity += 15;
        intuition += 20;
        break;
      case '성격 분석':
        communication += 15;
        intuition += 15;
        break;
    }
    
    return {
      '창의력': creativity.clamp(40, 95),
      '소통력': communication.clamp(40, 95),
      '분석력': analysis.clamp(40, 95),
      '리더십': leadership.clamp(40, 95),
      '집중력': focus.clamp(40, 95),
      '직감력': intuition.clamp(40, 95),
      'overall': ((creativity + communication + analysis + leadership + focus + intuition) / 6).round(),
    };
  }

  String _generateTalentDescription(TalentTypeInfo talentInfo) {
    return '''${talentInfo.title} 타입으로 분석되었습니다.

${talentInfo.description}

추천 성장 방향:
${talentInfo.strengths.map((s) => '• $s').join('\n')}

이 재능을 활용하여 ${talentInfo.careers.take(3).join(', ')} 등의 분야에서 뛰어난 성과를 낼 수 있습니다.''';
  }

  @override
  Widget buildFortuneResult() {
    if (fortune == null || _talentTypeInfo == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 메인 재능 타입 결과
          TalentTypeResultWidget(
            talentInfo: _talentTypeInfo!,
            overallScore: fortune!.overallScore ?? 75,
          ),
          const SizedBox(height: 20),
          
          // 핵심 강점
          TalentStrengthCards(
            strengths: _talentTypeInfo!.strengths,
          ),
          const SizedBox(height: 20),
          
          // 추천 직업
          RecommendedCareersWidget(
            careers: _talentTypeInfo!.careers,
          ),
          const SizedBox(height: 20),
          
          // 오늘부터 시작할 액션 플랜
          ActionPlanWidget(
            actionPlans: _talentTypeInfo!.actionPlans,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}