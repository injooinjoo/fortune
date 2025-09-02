import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/avoid_person_analysis.dart';

class AvoidPeopleResultPage extends ConsumerWidget {
  final AvoidPersonInput input;
  
  const AvoidPeopleResultPage({
    super.key,
    required this.input,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyses = _generateAnalyses(input);
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            size: 20,
          ),
        ),
        title: Text(
          '분석 결과',
          style: TossDesignSystem.heading3.copyWith(
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _shareResult(context, analyses),
            icon: Icon(
              Icons.share_rounded,
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전체 위험도 요약
            _buildRiskSummary(input, isDark).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // 주의할 사람 타입별 분석
            Text(
              '오늘 주의할 사람 유형',
              style: TossDesignSystem.heading4.copyWith(
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...analyses.asMap().entries.map((entry) {
              final index = entry.key;
              final analysis = entry.value;
              return _buildPersonTypeCard(analysis, isDark)
                .animate(delay: Duration(milliseconds: 100 * (index + 1)))
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.05, end: 0);
            }).toList(),
            
            const SizedBox(height: 32),
            
            // 종합 조언
            _buildGeneralAdvice(input, isDark).animate(delay: 400.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // 액션 버튼
            SizedBox(
              width: double.infinity,
              child: TossButton(
                text: '다시 분석하기',
                onPressed: () => Navigator.pop(context),
                style: TossButtonStyle.primary,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSummary(AvoidPersonInput input, bool isDark) {
    final riskLevel = _calculateRiskLevel(input);
    final riskColor = _getRiskColor(riskLevel);
    final riskText = _getRiskText(riskLevel);
    
    return TossCard(
      style: TossCardStyle.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [riskColor, riskColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${riskLevel * 20}%',
                  style: TossDesignSystem.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: riskLevel / 5,
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 20),
          
          Text(
            '오늘의 대인관계 위험도',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            riskText,
            style: TossDesignSystem.heading3.copyWith(
              color: riskColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: riskColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getRiskAdvice(riskLevel, input),
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonTypeCard(AvoidPersonAnalysis analysis, bool isDark) {
    return TossCard(
      style: TossCardStyle.filled,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(analysis.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(analysis.type),
                  color: _getTypeColor(analysis.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.title,
                      style: TossDesignSystem.body1.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis.description,
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              // 위험도 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskColor(analysis.riskLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.warning_rounded,
                      size: 12,
                      color: index < analysis.riskLevel
                          ? _getRiskColor(analysis.riskLevel)
                          : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300),
                    );
                  }),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 특징
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      size: 16,
                      color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '이런 특징을 보입니다',
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...analysis.characteristics.map((char) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TossDesignSystem.body3.copyWith(
                          color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          char,
                          style: TossDesignSystem.body3.copyWith(
                            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 시간대 & 장소
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.warningOrange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TossDesignSystem.warningOrange.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: TossDesignSystem.warningOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        analysis.timeOfDay,
                        style: TossDesignSystem.caption.copyWith(
                          color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.purple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TossDesignSystem.purple.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_rounded,
                        size: 16,
                        color: TossDesignSystem.purple,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          analysis.colorToAvoid,
                          style: TossDesignSystem.caption.copyWith(
                            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 대처 방법
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 8),
            title: Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: TossDesignSystem.successGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  '대처 방법',
                  style: TossDesignSystem.body2.copyWith(
                    color: TossDesignSystem.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            children: analysis.copingStrategies.map((strategy) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: TossDesignSystem.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strategy,
                      style: TossDesignSystem.body3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralAdvice(AvoidPersonInput input, bool isDark) {
    return TossCard(
      style: TossCardStyle.elevated,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TossDesignSystem.tossBlue, TossDesignSystem.tossBlue.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 종합 조언',
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _getGeneralAdviceText(input),
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.tossBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '오늘은 혼자만의 시간을 가지며 에너지를 충전하는 것도 좋은 방법입니다.',
                    style: TossDesignSystem.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AvoidPersonAnalysis> _generateAnalyses(AvoidPersonInput input) {
    final List<AvoidPersonAnalysis> analyses = [];
    final random = math.Random();
    
    // 스트레스 레벨이 높으면 에너지 뱀파이어 추가
    if (input.stressLevel >= 3) {
      analyses.add(AvoidPersonAnalysis(
        type: AvoidPersonType.energyVampire,
        title: '에너지 뱀파이어',
        description: '당신의 긍정 에너지를 빼앗는 사람',
        characteristics: [
          '끊임없이 부정적인 이야기를 합니다',
          '자신의 문제를 계속 토로합니다',
          '해결책보다 불평에 집중합니다',
        ],
        behaviors: ['한숨', '불만 표출', '부정적 표현'],
        timeOfDay: input.importantSchedule == '면접' ? '오전' : '오후',
        copingStrategies: [
          '대화 시간을 제한하세요',
          '긍정적인 주제로 전환하세요',
          '필요시 정중히 자리를 피하세요',
        ],
        riskLevel: 4,
        warningMessage: '에너지 소모 주의',
        colorToAvoid: '어두운 색상',
        location: input.environment,
      ));
    }
    
    // 중요한 의사결정이 있으면 조종자 추가
    if (input.hasImportantDecision) {
      analyses.add(AvoidPersonAnalysis(
        type: AvoidPersonType.manipulator,
        title: '조종자',
        description: '당신을 이용하려는 사람',
        characteristics: [
          '과도한 친절을 베풉니다',
          '대가를 바라는 도움을 제안합니다',
          '당신의 결정에 개입하려 합니다',
        ],
        behaviors: ['과한 칭찬', '조건부 제안', '압박'],
        timeOfDay: '점심시간',
        copingStrategies: [
          '중요한 결정은 혼자 내리세요',
          '즉답을 피하고 시간을 가지세요',
          '객관적인 제3자와 상의하세요',
        ],
        riskLevel: 5,
        warningMessage: '의사결정 주의',
        colorToAvoid: '붉은 계열',
        location: input.environment,
      ));
    }
    
    // 팀 프로젝트가 있으면 드라마 메이커 추가
    if (input.hasTeamProject) {
      analyses.add(AvoidPersonAnalysis(
        type: AvoidPersonType.dramaMaker,
        title: '드라마 메이커',
        description: '불필요한 갈등을 만드는 사람',
        characteristics: [
          '사소한 일을 크게 만듭니다',
          '팀원 간 이간질을 시도합니다',
          '감정적으로 과잉 반응합니다',
        ],
        behaviors: ['과장된 반응', '뒷담화', '선동'],
        timeOfDay: '회의 시간',
        copingStrategies: [
          '사실 위주로 대화하세요',
          '감정적 대응을 피하세요',
          '문서로 소통을 남기세요',
        ],
        riskLevel: 3,
        warningMessage: '갈등 발생 주의',
        colorToAvoid: '노란 계열',
        location: input.environment,
      ));
    }
    
    // 기본적으로 하나는 추가
    if (analyses.isEmpty) {
      analyses.add(AvoidPersonAnalysis(
        type: AvoidPersonType.critic,
        title: '비판자',
        description: '모든 것을 부정적으로 보는 사람',
        characteristics: [
          '건설적이지 않은 비판을 합니다',
          '당신의 노력을 평가절하합니다',
          '완벽주의적 잣대를 들이댑니다',
        ],
        behaviors: ['비판', '지적', '비교'],
        timeOfDay: '저녁',
        copingStrategies: [
          '비판을 개인적으로 받아들이지 마세요',
          '객관적 피드백만 수용하세요',
          '자신의 가치를 스스로 인정하세요',
        ],
        riskLevel: 2,
        warningMessage: '자존감 보호 필요',
        colorToAvoid: '회색 계열',
        location: input.environment,
      ));
    }
    
    return analyses.take(3).toList(); // 최대 3개까지만 표시
  }

  int _calculateRiskLevel(AvoidPersonInput input) {
    int risk = 2; // 기본 위험도
    
    if (input.stressLevel >= 4) risk++;
    if (input.socialFatigue >= 4) risk++;
    if (input.moodLevel <= 2) risk++;
    if (input.hasImportantDecision) risk++;
    if (input.hasSensitiveConversation) risk++;
    
    return risk.clamp(1, 5);
  }

  Color _getRiskColor(int level) {
    switch (level) {
      case 1:
      case 2:
        return TossDesignSystem.successGreen;
      case 3:
        return TossDesignSystem.warningOrange;
      case 4:
      case 5:
        return TossDesignSystem.errorRed;
      default:
        return TossDesignSystem.gray600;
    }
  }

  String _getRiskText(int level) {
    switch (level) {
      case 1:
        return '매우 안전';
      case 2:
        return '안전';
      case 3:
        return '보통';
      case 4:
        return '주의 필요';
      case 5:
        return '매우 주의';
      default:
        return '보통';
    }
  }

  String _getRiskAdvice(int level, AvoidPersonInput input) {
    if (level >= 4) {
      return '오늘은 대인관계에서 특별히 조심하세요. ${input.importantSchedule}이(가) 있다면 충분한 준비와 마음의 여유를 가지세요.';
    } else if (level >= 3) {
      return '평소보다 조금 더 신중하게 행동하면 좋은 하루가 될 것입니다.';
    } else {
      return '오늘은 대체로 순조로운 대인관계가 예상됩니다. 자신감을 가지세요!';
    }
  }

  Color _getTypeColor(AvoidPersonType type) {
    switch (type) {
      case AvoidPersonType.energyVampire:
        return TossDesignSystem.purple;
      case AvoidPersonType.critic:
        return TossDesignSystem.gray600;
      case AvoidPersonType.dramaMaker:
        return TossDesignSystem.warningOrange;
      case AvoidPersonType.manipulator:
        return TossDesignSystem.errorRed;
      case AvoidPersonType.gossiper:
        return TossDesignSystem.tossBlue;
    }
  }

  IconData _getTypeIcon(AvoidPersonType type) {
    switch (type) {
      case AvoidPersonType.energyVampire:
        return Icons.battery_alert_rounded;
      case AvoidPersonType.critic:
        return Icons.rate_review_rounded;
      case AvoidPersonType.dramaMaker:
        return Icons.theater_comedy_rounded;
      case AvoidPersonType.manipulator:
        return Icons.psychology_rounded;
      case AvoidPersonType.gossiper:
        return Icons.campaign_rounded;
    }
  }

  String _getGeneralAdviceText(AvoidPersonInput input) {
    final buffer = StringBuffer();
    
    buffer.write('${input.environment}에서 ');
    
    if (input.importantSchedule != '없음') {
      buffer.write('${input.importantSchedule}이(가) 예정되어 있는 오늘, ');
    }
    
    if (input.stressLevel >= 4 || input.socialFatigue >= 4) {
      buffer.write('스트레스와 피로도가 높은 상태입니다. 불필요한 대화는 최소화하고, 중요한 일에만 집중하세요. ');
    } else {
      buffer.write('컨디션은 양호한 편입니다. ');
    }
    
    if (input.hasImportantDecision) {
      buffer.write('중요한 결정은 충분한 시간을 가지고 신중하게 내리세요. ');
    }
    
    if (input.hasSensitiveConversation) {
      buffer.write('민감한 대화는 감정보다 사실에 집중하여 진행하세요. ');
    }
    
    buffer.write('오늘 하루도 현명하게 보내시길 바랍니다.');
    
    return buffer.toString();
  }

  void _shareResult(BuildContext context, List<AvoidPersonAnalysis> analyses) {
    HapticFeedback.lightImpact();
    
    final text = StringBuffer();
    text.writeln('📊 오늘의 피해야 할 사람 분석 결과\n');
    
    for (final analysis in analyses) {
      text.writeln('⚠️ ${analysis.title}');
      text.writeln(analysis.description);
      text.writeln('시간대: ${analysis.timeOfDay}');
      text.writeln('');
    }
    
    text.writeln('💡 오늘은 대인관계에서 신중하게 행동하세요!');
    
    // 실제 앱에서는 share 패키지를 사용
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('분석 결과가 복사되었습니다'),
        backgroundColor: TossDesignSystem.successGreen,
      ),
    );
  }
}