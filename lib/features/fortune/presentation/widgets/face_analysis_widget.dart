import 'package:flutter/material.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';

/// 관상 타입 정보를 담는 클래스
class FaceTypeInfo {
  final String type;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<String> strengths;
  final List<String> careers;
  final List<String> advice;
  final Color primaryColor;
  final Color secondaryColor;

  const FaceTypeInfo({
    required this.type,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.strengths,
    required this.careers,
    required this.advice,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

/// 관상 타입 정보 제공자
class FaceTypeProvider {
  static const Map<String, FaceTypeInfo> _faceTypes = {
    'leader': FaceTypeInfo(
      type: 'leader',
      emoji: '👑',
      title: '천성 리더형',
      subtitle: '타고난 지도자의 관상',
      description: '강한 의지력과 카리스마를 지닌 당신은 자연스럽게 사람들을 이끄는 능력을 가지고 있습니다. 결단력이 뛰어나고 책임감이 강해 어려운 상황에서도 중심을 잡고 앞장서는 타입입니다.',
      strengths: ['강한 의지력과 결단력', '뛰어난 리더십과 카리스마', '책임감과 신뢰성'],
      careers: ['CEO·임원', '정치인', '프로젝트 매니저', '교육자', '컨설턴트'],
      advice: ['팀워크를 중시하며 소통하세요', '겸손한 마음가짐을 유지하세요', '장기적 비전을 세우고 실행하세요'],
      primaryColor: Color(0xFF1E40AF),
      secondaryColor: Color(0xFF3B82F6),
    ),
    'creator': FaceTypeInfo(
      type: 'creator',
      emoji: '🎨',
      title: '창조자형',
      subtitle: '예술적 감성과 창의성의 소유자',
      description: '독창적인 아이디어와 뛰어난 감성을 지닌 당신은 새로운 것을 만들어내는 데 탁월한 재능을 가지고 있습니다. 직감력이 뛰어나고 예술적 감각이 발달되어 있어 창작 활동에서 빛을 발합니다.',
      strengths: ['뛰어난 창의력과 상상력', '예술적 감성과 미적 감각', '독창적 사고와 아이디어'],
      careers: ['디자이너', '아티스트', '작가·시나리오작가', '광고기획자', '크리에이티브 디렉터'],
      advice: ['꾸준한 창작 활동을 이어가세요', '다양한 경험으로 영감을 얻으세요', '협업을 통해 시너지를 만들어보세요'],
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFF8B5CF6),
    ),
    'analyzer': FaceTypeInfo(
      type: 'analyzer',
      emoji: '🔬',
      title: '분석가형',
      subtitle: '논리적 사고와 깊은 통찰력',
      description: '체계적이고 논리적인 사고를 지닌 당신은 복잡한 문제를 해결하는 데 뛰어난 능력을 보입니다. 꼼꼼하고 신중한 성격으로 정확한 판단을 내리며, 깊이 있는 분석을 통해 본질을 파악합니다.',
      strengths: ['뛰어난 분석력과 논리력', '체계적이고 꼼꼼한 성격', '깊은 집중력과 인내력'],
      careers: ['연구원·과학자', '데이터분석가', '회계사', '의사', '엔지니어'],
      advice: ['꾸준한 학습으로 전문성을 키우세요', '완벽주의를 적당히 조절하세요', '소통 능력도 함께 기르세요'],
      primaryColor: Color(0xFF059669),
      secondaryColor: Color(0xFF10B981),
    ),
    'communicator': FaceTypeInfo(
      type: 'communicator',
      emoji: '💬',
      title: '소통전문가형',
      subtitle: '뛰어난 대인관계와 소통능력',
      description: '탁월한 소통능력과 공감능력을 지닌 당신은 사람들과의 관계에서 빛을 발합니다. 따뜻한 성격과 높은 감정지능으로 다른 사람의 마음을 잘 이해하고 화합을 이끌어내는 능력이 뛰어납니다.',
      strengths: ['뛰어난 소통능력과 공감력', '따뜻한 성격과 친화력', '갈등 해결과 중재 능력'],
      careers: ['영업·마케팅', 'HR·인사담당자', '상담사·치료사', '방송인·MC', '서비스업'],
      advice: ['진정성 있는 소통을 하세요', '경계선을 적절히 설정하세요', '자기 관리도 소홀히하지 마세요'],
      primaryColor: Color(0xFFDC2626),
      secondaryColor: Color(0xFFEF4444),
    ),
    'guardian': FaceTypeInfo(
      type: 'guardian',
      emoji: '🛡️',
      title: '수호자형',
      subtitle: '안정성과 신뢰성의 상징',
      description: '든든하고 신뢰할 수 있는 당신은 주변 사람들에게 안정감을 주는 존재입니다. 책임감이 강하고 성실한 성격으로 맡은 일을 끝까지 해내는 능력이 뛰어나며, 다른 사람을 보호하고 도우려는 마음이 큽니다.',
      strengths: ['강한 책임감과 신뢰성', '안정적이고 든든한 성격', '배려심과 희생정신'],
      careers: ['공무원', '의료진·간병인', '보안·안전관리', '교사', '사회복지사'],
      advice: ['자신의 한계를 인정하세요', '때로는 도움을 요청하세요', '스트레스 관리에 신경쓰세요'],
      primaryColor: Color(0xFF92400E),
      secondaryColor: Color(0xFFD97706),
    ),
  };

  static FaceTypeInfo getFaceType(String type) {
    return _faceTypes[type] ?? _faceTypes['leader']!;
  }

  static FaceTypeInfo analyzeFace() {
    // 실제로는 이미지 분석이나 사용자 입력에 따라 결정
    // 여기서는 랜덤하게 선택
    final types = _faceTypes.keys.toList();
    final randomType = types[DateTime.now().millisecondsSinceEpoch % types.length];
    return _faceTypes[randomType]!;
  }
}

/// 관상 타입 결과를 표시하는 메인 위젯
class FaceAnalysisResultWidget extends StatelessWidget {
  final FaceTypeInfo faceTypeInfo;
  final int overallScore;

  const FaceAnalysisResultWidget({
    super.key,
    required this.faceTypeInfo,
    required this.overallScore,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 메인 타입 카드
          _buildMainTypeCard(context),
          const SizedBox(height: 20),
          
          // 전체 점수
          _buildOverallScore(context),
          const SizedBox(height: 16),
          
          // 설명
          _buildDescription(context),
        ],
      ),
    );
  }

  Widget _buildMainTypeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            faceTypeInfo.primaryColor.withOpacity(0.1),
            faceTypeInfo.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: faceTypeInfo.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // 이모지
          Text(
            faceTypeInfo.emoji,
            style: const TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 16),
          
          // 타입명
          Text(
            faceTypeInfo.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: faceTypeInfo.primaryColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // 서브타이틀
          Text(
            faceTypeInfo.subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TossTheme.textGray600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _getScoreColor(overallScore).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getScoreColor(overallScore).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: _getScoreColor(overallScore),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '관상 매력도 $overallScore점',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _getScoreColor(overallScore),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        faceTypeInfo.description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: TossTheme.textBlack,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF22C55E);
    if (score >= 70) return faceTypeInfo.primaryColor;
    if (score >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// 핵심 강점 카드들
class FaceStrengthsWidget extends StatelessWidget {
  final List<String> strengths;
  final Color primaryColor;

  const FaceStrengthsWidget({
    super.key,
    required this.strengths,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '핵심 강점',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...strengths.asMap().entries.map((entry) {
            final index = entry.key;
            final strength = entry.value;
            return _buildStrengthItem(context, index + 1, strength);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStrengthItem(BuildContext context, int rank, String strength) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strength,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 추천 직업 위젯
class RecommendedCareersWidget extends StatelessWidget {
  final List<String> careers;
  final Color primaryColor;

  const RecommendedCareersWidget({
    super.key,
    required this.careers,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_rounded,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '추천 직업',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers.map((career) => _buildCareerChip(context, career)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerChip(BuildContext context, String career) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
        ),
      ),
      child: Text(
        career,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 인생 조언 위젯
class LifeAdviceWidget extends StatelessWidget {
  final List<String> advice;
  final Color primaryColor;

  const LifeAdviceWidget({
    super.key,
    required this.advice,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '인생 조언',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...advice.asMap().entries.map((entry) {
            final index = entry.key;
            final adviceText = entry.value;
            return _buildAdviceItem(context, index + 1, adviceText);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(BuildContext context, int index, String advice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '조언 $index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}