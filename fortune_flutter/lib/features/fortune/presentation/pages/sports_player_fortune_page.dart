import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/fortune_content_card.dart';
import 'base_fortune_page.dart';

class SportsPlayerFortunePage extends StatefulWidget {
  const SportsPlayerFortunePage({super.key});

  @override
  State<SportsPlayerFortunePage> createState() => _SportsPlayerFortunePageState();
}

class _SportsPlayerFortunePageState extends State<SportsPlayerFortunePage> {
  String selectedSport = 'all';
  String? selectedPlayer;
  
  final Map<String, List<Map<String, String>>> playerData = {
    'all': [
      {'name': '손흥민', 'sport': '축구', 'team': '토트넘', 'position': 'FW'},
      {'name': '김민재', 'sport': '축구', 'team': '바이에른 뮌헨', 'position': 'DF'},
      {'name': '이강인', 'sport': '축구', 'team': 'PSG', 'position': 'MF'},
      {'name': '류현진', 'sport': '야구', 'team': '한화 이글스', 'position': '투수'},
      {'name': '김하성', 'sport': '야구', 'team': '샌디에이고', 'position': '내야수'},
      {'name': '김연아', 'sport': '피겨', 'team': '은퇴', 'position': '싱글'},
      {'name': '안산', 'sport': '양궁', 'team': '광주시청', 'position': '리커브'},
      {'name': '김연경', 'sport': '배구', 'team': '흥국생명', 'position': '아웃사이드'},
    ],
    'soccer': [
      {'name': '손흥민', 'sport': '축구', 'team': '토트넘', 'position': 'FW'},
      {'name': '김민재', 'sport': '축구', 'team': '바이에른 뮌헨', 'position': 'DF'},
      {'name': '이강인', 'sport': '축구', 'team': 'PSG', 'position': 'MF'},
      {'name': '황희찬', 'sport': '축구', 'team': '울버햄튼', 'position': 'FW'},
      {'name': '황인범', 'sport': '축구', 'team': '페예노르트', 'position': 'MF'},
      {'name': '조규성', 'sport': '축구', 'team': 'FC 미틸란', 'position': 'FW'},
      {'name': '김진수', 'sport': '축구', 'team': '전북 현대', 'position': 'DF'},
      {'name': '이재성', 'sport': '축구', 'team': '마인츠', 'position': 'MF'},
    ],
    'baseball': [
      {'name': '류현진', 'sport': '야구', 'team': '한화 이글스', 'position': '투수'},
      {'name': '김하성', 'sport': '야구', 'team': '샌디에이고', 'position': '내야수'},
      {'name': '이정후', 'sport': '야구', 'team': '샌프란시스코', 'position': '외야수'},
      {'name': '김광현', 'sport': '야구', 'team': 'SSG 랜더스', 'position': '투수'},
      {'name': '양현종', 'sport': '야구', 'team': 'KIA 타이거즈', 'position': '투수'},
      {'name': '이대호', 'sport': '야구', 'team': '은퇴', 'position': '타자'},
      {'name': '추신수', 'sport': '야구', 'team': '은퇴', 'position': '외야수'},
      {'name': '오승환', 'sport': '야구', 'team': '삼성 라이온즈', 'position': '투수'},
    ],
    'other': [
      {'name': '김연아', 'sport': '피겨', 'team': '은퇴', 'position': '싱글'},
      {'name': '안산', 'sport': '양궁', 'team': '광주시청', 'position': '리커브'},
      {'name': '김연경', 'sport': '배구', 'team': '흥국생명', 'position': '아웃사이드'},
      {'name': '신유빈', 'sport': '탁구', 'team': '대한항공', 'position': '단식/복식'},
      {'name': '임시현', 'sport': '양궁', 'team': '현대모비스', 'position': '리커브'},
      {'name': '황선우', 'sport': '수영', 'team': '강원도청', 'position': '자유형'},
      {'name': '우상혁', 'sport': '육상', 'team': '국군체육부대', 'position': '높이뛰기'},
      {'name': '양학선', 'sport': '체조', 'team': '은퇴', 'position': '도마'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return BaseFortunePage(
      title: '스포츠 선수 운세',
      fortuneType: 'sports-player',
      headerColor: const Color(0xFF00897B),
      onGenerateFortune: selectedPlayer != null 
          ? () => _generateFortune(context)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSportSelector(),
          const SizedBox(height: 20),
          _buildPlayerGrid(),
        ],
      ),
    );
  }

  Widget _buildSportSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSportTab('all', '전체', Icons.sports),
          _buildSportTab('soccer', '축구', Icons.sports_soccer),
          _buildSportTab('baseball', '야구', Icons.sports_baseball),
          _buildSportTab('other', '기타', Icons.emoji_events),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSportTab(String sport, String label, IconData icon) {
    final isSelected = selectedSport == sport;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSport = sport;
            selectedPlayer = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00897B) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerGrid() {
    final players = playerData[selectedSport] ?? [];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isSelected = selectedPlayer == player['name'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPlayer = player['name'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [const Color(0xFF00897B), const Color(0xFF00BFA5)]
                    : [AppColors.surface, AppColors.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF00897B) 
                    : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00897B).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF00897B).withOpacity(0.1),
                    ),
                    child: Icon(
                      _getSportIcon(player['sport']!),
                      size: 24,
                      color: isSelected ? Colors.white : const Color(0xFF00897B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    player['position']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    player['team']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(delay: (50 * index).ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        );
      },
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case '축구':
        return Icons.sports_soccer;
      case '야구':
        return Icons.sports_baseball;
      case '배구':
        return Icons.sports_volleyball;
      case '양궁':
        return Icons.gps_fixed;
      case '피겨':
        return Icons.ac_unit;
      case '수영':
        return Icons.pool;
      case '탁구':
        return Icons.sports_tennis;
      case '육상':
        return Icons.directions_run;
      case '체조':
        return Icons.accessibility_new;
      default:
        return Icons.sports;
    }
  }

  Future<void> _generateFortune(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final fortuneProvider = context.read<FortuneProvider>();
    final userProfile = authProvider.userProfile;

    final player = playerData[selectedSport]
        ?.firstWhere((p) => p['name'] == selectedPlayer);

    final requestData = {
      'fortuneType': 'sports-player',
      'userId': authProvider.userId,
      'name': userProfile?.name ?? '선수',
      'birthDate': userProfile?.birthDate ?? DateTime.now().toIso8601String(),
      'playerName': selectedPlayer,
      'sport': player?['sport'],
      'team': player?['team'],
      'position': player?['position'],
    };

    try {
      final result = await fortuneProvider.generateFortune(
        fortuneType: 'sports-player',
        requestData: requestData,
      );

      if (result != null && mounted) {
        _showFortuneResult(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운세 생성 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showFortuneResult(BuildContext context, Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$selectedPlayer 선수의 스타일로 보는 운동 운세',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildPerformanceSection(result['performanceAnalysis']),
              const SizedBox(height: 20),
              _buildResultSection('오늘의 운동 운세', result['todaysFortune']),
              _buildResultSection('체력 상태', result['physicalCondition']),
              _buildResultSection('부상 예방 지수', result['injuryPrevention']),
              _buildResultSection('경기력 예측', result['performancePrediction']),
              _buildResultSection('팀워크 운', result['teamworkLuck']),
              _buildResultSection('훈련 효율성', result['trainingEfficiency']),
              if (result['trainingTips'] != null)
                _buildTrainingSection(result['trainingTips']),
              if (result['mentalCoaching'] != null)
                _buildMentalSection(result['mentalCoaching']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(dynamic analysis) {
    if (analysis == null) return const SizedBox.shrink();
    
    final stats = analysis is Map ? analysis : {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00897B).withOpacity(0.1),
            const Color(0xFF00BFA5).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '오늘의 경기력 분석',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatBar('체력', stats['stamina'] ?? 85),
          _buildStatBar('집중력', stats['focus'] ?? 78),
          _buildStatBar('반응속도', stats['reaction'] ?? 82),
          _buildStatBar('판단력', stats['decision'] ?? 90),
          _buildStatBar('정신력', stats['mental'] ?? 88),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00897B),
                          const Color(0xFF00BFA5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, dynamic content) {
    if (content == null) return const SizedBox.shrink();
    
    return FortuneContentCard(
      title: title,
      content: content.toString(),
      gradientColors: const [Color(0xFF00897B), Color(0xFF00BFA5)],
      delay: 0,
    );
  }

  Widget _buildTrainingSection(List<dynamic> tips) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00897B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '훈련 팁 🏃‍♂️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.sports_score,
                  size: 16,
                  color: Color(0xFF00897B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMentalSection(Map<String, dynamic> mental) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00897B).withOpacity(0.05),
            const Color(0xFF00BFA5).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '멘탈 코칭 🧠',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          const SizedBox(height: 8),
          if (mental['motivation'] != null)
            Text(
              '💪 ${mental['motivation']}',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (mental['mindset'] != null) ...[
            const SizedBox(height: 8),
            Text(
              '🎯 ${mental['mindset']}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}