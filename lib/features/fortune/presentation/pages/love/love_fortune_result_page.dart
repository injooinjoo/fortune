import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../widgets/love/love_score_circle.dart';
import '../../widgets/love/love_trend_chart.dart';
import '../../widgets/love/love_mission_card.dart';
import '../../widgets/love/love_lucky_items.dart';

class LoveFortuneResultPage extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const LoveFortuneResultPage({super.key, required this.data});

  @override
  State<LoveFortuneResultPage> createState() => _LoveFortuneResultPageState();
}

class _LoveFortuneResultPageState extends State<LoveFortuneResultPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _loveScore = 0;
  bool _showScore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateLoveScore();
    
    // 점수 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showScore = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateLoveScore() {
    // 입력된 데이터를 바탕으로 점수 계산
    int baseScore = 50;
    
    // 나이 요소 (20-30세가 가장 높은 점수)
    int age = widget.data['age'] ?? 25;
    if (age >= 20 && age <= 30) {
      baseScore += 8;
    } else if (age >= 18 && age <= 35) {
      baseScore += 5;
    }
    
    // 연애 스타일 요소
    List<String> styles = widget.data['datingStyles'] ?? [];
    if (styles.isNotEmpty) {
      baseScore += (styles.length * 3).clamp(3, 12);
    }
    
    // 매력 포인트 요소
    List<String> charmPoints = widget.data['charmPoints'] ?? [];
    if (charmPoints.isNotEmpty) {
      baseScore += (charmPoints.length * 4).clamp(4, 12);
    }
    
    // 외모 자신감 요소 (1-10 점수)
    double appearanceConf = widget.data['appearanceConfidence'] ?? 5.0;
    baseScore += ((appearanceConf - 1) * 1.5).round();
    
    // 취미 활동 요소
    List<String> hobbies = widget.data['hobbies'] ?? [];
    if (hobbies.isNotEmpty) {
      baseScore += (hobbies.length * 2).clamp(2, 10);
    }
    
    // 관계 목표 요소
    String relationshipGoal = widget.data['relationshipGoal'] ?? '';
    if (relationshipGoal == 'marriage') {
      baseScore += 5;
    } else if (relationshipGoal == 'serious') {
      baseScore += 4;
    } else if (relationshipGoal == 'casual') {
      baseScore += 2;
    }
    
    // 라이프스타일 요소
    String lifestyle = widget.data['lifestyle'] ?? '';
    if (lifestyle.isNotEmpty) {
      baseScore += 3;
    }
    
    // 선호 만남 장소 요소
    List<String> meetingPlaces = widget.data['preferredMeetingPlaces'] ?? [];
    if (meetingPlaces.isNotEmpty) {
      baseScore += (meetingPlaces.length * 1.5).round().clamp(2, 8);
    }
    
    _loveScore = (baseScore).clamp(40, 95);
  }

  String _getScoreDescription(int score) {
    if (score >= 90) {
      return '환상적인 연애운! 🌟';
    } else if (score >= 80) {
      return '매우 좋은 연애운! 💕';
    } else if (score >= 70) {
      return '좋은 연애운이에요! 😊';
    } else {
      return '조금만 더 노력하면 완벽! 💪';
    }
  }

  String _getMonthlyFortune() {
    String relationshipStatus = widget.data['relationshipStatus'] ?? 'single';
    
    switch (relationshipStatus) {
      case 'single':
        return '이번 달은 새로운 인연을 만날 확률이 높은 시기입니다. 특히 ${_getRecommendedPlaces()}에서 좋은 만남이 기대됩니다.';
      case 'dating':
        return '연인과의 관계가 한 단계 더 발전할 수 있는 달입니다. 진솔한 대화를 통해 서로를 더 깊이 이해하게 될 것입니다.';
      case 'breakup':
        return '지난 관계에서 배운 것들을 바탕으로 더 나은 사랑을 만날 준비가 되어가는 시기입니다. 자신을 위한 시간을 충분히 가지세요.';
      case 'crush':
        return '짝사랑하는 상대에게 마음을 표현하기 좋은 시기입니다. 용기를 내어 다가가보세요.';
      default:
        return '사랑스러운 한 달이 될 것입니다.';
    }
  }

  String _getRecommendedPlaces() {
    List<String> places = widget.data['preferredMeetingPlaces'] ?? ['cafe'];
    if (places.contains('cafe')) return '카페나 맛집';
    if (places.contains('gym')) return '헬스장이나 운동시설';
    if (places.contains('hobby')) return '취미모임';
    return '일상적인 장소';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: TossTheme.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: TossTheme.textBlack,
              size: 20,
            ),
          ),
        ),
        title: Text(
          '연애운세 결과',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _shareResult,
              style: IconButton.styleFrom(
                backgroundColor: TossTheme.backgroundSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.share,
                color: TossTheme.textBlack,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 헤더 - 종합 점수
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 점수 표시
                LoveScoreCircle(
                  score: _showScore ? _loveScore : 0,
                  animated: _showScore,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _getScoreDescription(_loveScore),
                  style: TossTheme.heading3.copyWith(
                    color: TossTheme.textBlack,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate(delay: 1200.ms).slideX(duration: 600.ms).fadeIn(),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: TossTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TossTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _getMonthlyFortune(),
                    style: TossTheme.body1.copyWith(
                      color: TossTheme.textBlack,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate(delay: 1400.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
              ],
            ),
          ),
          
          // 탭 섹션
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: TossTheme.primaryBlue,
              unselectedLabelColor: TossTheme.textGray600,
              indicator: BoxDecoration(
                color: TossTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '만남 예측'),
                Tab(text: '자기계발'),
                Tab(text: '월간 트렌드'),
              ],
            ),
          ).animate(delay: 1600.ms).slideY(begin: 0.3, duration: 600.ms).fadeIn(),
          
          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeetingPredictionTab(),
                _buildSelfDevelopmentTab(),
                _buildMonthlyTrendTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TossTheme.backgroundPrimary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TossButton(
                text: '다시 하기',
                onPressed: () => Navigator.pop(context),
                style: TossButtonStyle.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TossButton(
                text: '알림 설정',
                onPressed: _setNotification,
                style: TossButtonStyle.primary,
              ),
            ),
          ],
        ),
      ).animate(delay: 1800.ms).slideY(begin: 1, duration: 600.ms).fadeIn(),
    );
  }

  Widget _buildMeetingPredictionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // 추천 만남 장소
          _buildSectionCard(
            title: '📍 추천 만남 장소',
            child: Column(
              children: [
                _buildLocationItem('카페 & 맛집', '85%', TossTheme.success),
                _buildLocationItem('헬스장 & 스포츠센터', '72%', TossTheme.primaryBlue),
                _buildLocationItem('취미모임 & 동호회', '68%', TossTheme.warning),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 행운의 날짜
          _buildSectionCard(
            title: '📅 이번 달 행운의 날',
            child: _buildLuckyDaysCalendar(),
          ),
          
          const SizedBox(height: 16),
          
          // 예상 인연 타입
          _buildSectionCard(
            title: '👥 예상 인연 타입',
            child: _buildIdealTypeDescription(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfDevelopmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // 개선 포인트
          _buildSectionCard(
            title: '💪 우선 개선 포인트',
            child: Column(
              children: [
                _buildImprovementItem('외모 관리', '스킨케어 루틴 개선', Icons.face_rounded),
                _buildImprovementItem('대화 스킬', '경청하는 자세 기르기', Icons.chat_bubble_outline),
                _buildImprovementItem('자신감', '새로운 도전 시작하기', Icons.emoji_emotions),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 오늘의 미션
          LoveMissionCard(
            missions: _getTodayMissions(),
            onMissionComplete: _onMissionComplete,
          ),
          
          const SizedBox(height: 16),
          
          // 대화 팁
          _buildSectionCard(
            title: '💬 상황별 대화 팁',
            child: _buildConversationTips(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // 월간 트렌드 차트
          _buildSectionCard(
            title: '📈 4주간 연애운 변화',
            child: LoveTrendChart(
              data: _getMonthlyTrendData(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 주간별 조언
          _buildSectionCard(
            title: '🗓️ 주간별 핵심 포인트',
            child: _buildWeeklyAdvice(),
          ),
          
          const SizedBox(height: 16),
          
          // 행운 아이템
          LoveLuckyItems(
            luckyItems: _getLuckyItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TossTheme.borderGray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TossTheme.heading4.copyWith(
              color: TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLocationItem(String place, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              place,
              style: TossTheme.body1.copyWith(
                color: TossTheme.textBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            percentage,
            style: TossTheme.body1.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyDaysCalendar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TossTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '이번 달 특히 좋은 날: 7일, 14일, 21일, 28일\n금요일과 일요일이 가장 행운의 날이에요! ✨',
        style: TossTheme.body1.copyWith(
          color: TossTheme.textBlack,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildIdealTypeDescription() {
    List<String> personality = widget.data['preferredPersonality'] ?? ['활발한'];
    return Text(
      '${personality.join(', ')}한 성격의 사람과 만날 확률이 높습니다. 특히 비슷한 취미를 가진 사람과의 인연이 기대됩니다.',
      style: TossTheme.body1.copyWith(
        color: TossTheme.textBlack,
        height: 1.5,
      ),
    );
  }

  Widget _buildImprovementItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: TossTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossTheme.body1.copyWith(
                    color: TossTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TossTheme.body2.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTips() {
    return Column(
      children: [
        _buildTipItem('첫 만남', '공통 관심사를 찾아 대화를 시작하세요'),
        _buildTipItem('데이트 중', '상대방의 이야기에 집중하고 공감을 표현하세요'),
        _buildTipItem('갈등 상황', '감정보다는 사실 위주로 대화하세요'),
      ],
    );
  }

  Widget _buildTipItem(String situation, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            situation,
            style: TossTheme.body1.copyWith(
              color: TossTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip,
            style: TossTheme.body2.copyWith(
              color: TossTheme.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAdvice() {
    return Column(
      children: [
        _buildWeekItem('1주차', '새로운 사람들과의 만남이 활발해집니다', TossTheme.success),
        _buildWeekItem('2주차', '기존 인연과의 관계가 깊어질 수 있어요', TossTheme.primaryBlue),
        _buildWeekItem('3주차', '중요한 고백이나 결정을 내리기 좋은 시기', TossTheme.warning),
        _buildWeekItem('4주차', '관계를 정리하고 새로운 시작을 준비하세요', TossTheme.textGray600),
      ],
    );
  }

  Widget _buildWeekItem(String week, String advice, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              week,
              style: TossTheme.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: TossTheme.body2.copyWith(
                color: TossTheme.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTodayMissions() {
    return [
      '하루에 한 번 자신에게 칭찬하기',
      '새로운 사람에게 먼저 인사하기', 
      '관심 있던 취미 활동 알아보기',
      '건강한 식사와 충분한 수면',
      '감사 일기 쓰기',
    ];
  }

  List<Map<String, dynamic>> _getMonthlyTrendData() {
    return [
      {'week': '1주차', 'score': 75},
      {'week': '2주차', 'score': 82},
      {'week': '3주차', 'score': 90},
      {'week': '4주차', 'score': 88},
    ];
  }

  Map<String, String> _getLuckyItems() {
    return {
      '향수': '플로럴 또는 시트러스 계열',
      '색상': '핑크, 블루, 화이트',
      '액세서리': '심플한 실버 목걸이',
      '꽃': '장미, 백합, 튤립',
    };
  }

  void _onMissionComplete(int index) {
    // 미션 완료 처리
    setState(() {
      // 미션 완료 상태 업데이트
    });
  }

  void _shareResult() {
    // 결과 공유 기능
  }

  void _setNotification() {
    // 알림 설정 기능
  }
}