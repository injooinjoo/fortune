import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/fortune_content_card.dart';
import 'base_fortune_page.dart';

class PoliticianFortunePage extends StatefulWidget {
  const PoliticianFortunePage({super.key});

  @override
  State<PoliticianFortunePage> createState() => _PoliticianFortunePageState();
}

class _PoliticianFortunePageState extends State<PoliticianFortunePage> {
  String selectedParty = 'all';
  String? selectedPolitician;
  
  final Map<String, List<Map<String, String>>> politicianData = {
    'all': [
      {'name': '이재명', 'party': '더불어민주당', 'position': '당대표'},
      {'name': '한동훈', 'party': '국민의힘', 'position': '당대표'},
      {'name': '이준석', 'party': '개혁신당', 'position': '당대표'},
      {'name': '조국', 'party': '조국혁신당', 'position': '당대표'},
      {'name': '안철수', 'party': '무소속', 'position': '의원'},
      {'name': '윤석열', 'party': '국민의힘', 'position': '대통령'},
      {'name': '이낙연', 'party': '더불어민주당', 'position': '의원'},
      {'name': '심상정', 'party': '정의당', 'position': '의원'},
    ],
    'democratic': [
      {'name': '이재명', 'party': '더불어민주당', 'position': '당대표'},
      {'name': '이낙연', 'party': '더불어민주당', 'position': '의원'},
      {'name': '박용진', 'party': '더불어민주당', 'position': '의원'},
      {'name': '김두관', 'party': '더불어민주당', 'position': '의원'},
    ],
    'conservative': [
      {'name': '한동훈', 'party': '국민의힘', 'position': '당대표'},
      {'name': '윤석열', 'party': '국민의힘', 'position': '대통령'},
      {'name': '김기현', 'party': '국민의힘', 'position': '의원'},
      {'name': '나경원', 'party': '국민의힘', 'position': '의원'},
    ],
    'progressive': [
      {'name': '이준석', 'party': '개혁신당', 'position': '당대표'},
      {'name': '조국', 'party': '조국혁신당', 'position': '당대표'},
      {'name': '심상정', 'party': '정의당', 'position': '의원'},
      {'name': '안철수', 'party': '무소속', 'position': '의원'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    // final authProvider = context.watch<AuthProvider>();
    // final userProfile = authProvider.userProfile;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPartySelector(),
          const SizedBox(height: 20),
          _buildPoliticianGrid(),
        ],
      ),
    );
  }

  Widget _buildPartySelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: TossDesignSystem.backgroundPrimary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPartyTab('all', '전체', Icons.groups),
          _buildPartyTab('democratic', '민주', Icons.flag, const Color(0xFF004EA2)),
          _buildPartyTab('conservative', '보수', Icons.flag, const Color(0xFFE61E2B)),
          _buildPartyTab('progressive', '진보', Icons.flag, const Color(0xFF00A85D)),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPartyTab(String party, String label, IconData icon, [Color? color]) {
    final isSelected = selectedParty == party;
    final tabColor = color ?? const Color(0xFF1976D2);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedParty = party;
            selectedPolitician = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? tabColor : TossDesignSystem.white.withValues(alpha: 0.0),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray500,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoliticianGrid() {
    final politicians = politicianData[selectedParty] ?? [];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12),
      itemCount: politicians.length,
      itemBuilder: (context, index) {
        final politician = politicians[index];
        final isSelected = selectedPolitician == politician['name'
  ];
        final partyColor = _getPartyColor(politician['party']!);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPolitician = politician['name'
  ];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [partyColor, partyColor.withValues(alpha: 0.7)]
                    : [TossDesignSystem.backgroundPrimary, TossDesignSystem.backgroundPrimary]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? partyColor : TossDesignSystem.gray300,
                width: isSelected ? 2 : 1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: partyColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4))
                    ]
                  : []),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isSelected 
                        ? TossDesignSystem.white.withValues(alpha: 0.2)
                        : partyColor.withValues(alpha: 0.1),
                    child: Text(
                      politician['name']!.substring(0, 1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? TossDesignSystem.white : partyColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    politician['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? TossDesignSystem.white : TossDesignSystem.gray900,
                    ),
                  ),
                  Text(
                    politician['position']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected 
                          ? TossDesignSystem.white.withValues(alpha: 0.8)
                          : TossDesignSystem.gray500,
                    ),
                  ),
                  Text(
                    politician['party']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected 
                          ? TossDesignSystem.white.withValues(alpha: 0.7)
                          : partyColor,
                      fontWeight: FontWeight.w500,
                    ),
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

  Color _getPartyColor(String party) {
    switch (party) {
      case '더불어민주당': return const Color(0xFF004EA2);
      case '국민의힘':
        return const Color(0xFFE61E2B);
      case '정의당':
        return const Color(0xFFFFCC00);
      case '조국혁신당':
        return const Color(0xFF00A85D);
      case '개혁신당': return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF757575);
    }
  }

  Future<void> _generateFortune(BuildContext context) async {
    // // final authProvider = context.read<AuthProvider>();
    // // final fortuneProvider = context.read<FortuneProvider>();
    // final userProfile = authProvider.userProfile;

    // final requestData = {
    //   'fortuneType': 'politician',
    //   'userId': authProvider.userId,
    //   'name': userProfile?.name ?? '시민',
    //   'birthDate': userProfile?.birthDate ?? DateTime.now().toIso8601String(),
    //   'politician': selectedPolitician,
    //   'party': politicianData[selectedParty]
    //       ?.firstWhere((p) => p['name'] == selectedPolitician)['party']
    // };

    // try {
    //   final result = await fortuneProvider.generateFortune(
    //     fortuneType: 'politician',
    //     requestData: requestData
    //   );

    //   if (result != null && mounted) {
    //     _showFortuneResult(context, result);
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('발생했습니다: $e')),
    //     );
    //   }
    // }
  }

  void _showFortuneResult(BuildContext context, Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: TossDesignSystem.gray100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: TossDesignSystem.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$selectedPolitician님의 정치 스타일과 나의 운세',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildResultSection('정치 성향 분석', result['politicalTendency']),
              _buildResultSection('리더십 스타일', result['leadershipStyle']),
              _buildResultSection('오늘의 정치 운세', result['todaysPoliticalFortune']),
              _buildResultSection('사회 이슈 관심도', result['socialIssueInterest']),
              _buildResultSection('대인 관계 운', result['networkingLuck']),
              _buildResultSection('설득력 지수', result['persuasionIndex']),
              if (result['politicalAdvice'] != null)
                _buildAdviceSection(result['politicalAdvice']),
              if (result['careerPath'] != null)
                _buildCareerSection(result['careerPath']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, dynamic content) {
    if (content == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TossDesignSystem.tossBlue, TossDesignSystem.tossBlueLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.toString(),
            style: const TextStyle(
              fontSize: 14,
              color: TossDesignSystem.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection(Map<String, dynamic> advice) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossDesignSystem.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TossDesignSystem.tossBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정치적 조언 📋',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          const SizedBox(height: 12),
          ...advice.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: TossDesignSystem.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCareerSection(Map<String, dynamic> career) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TossDesignSystem.tossBlue.withValues(alpha: 0.1),
            TossDesignSystem.tossBlueLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정치 경력 전망 🏛️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            career['path'] ?? '시민 참여부터 시작하여 점진적인 성장 가능',
            style: const TextStyle(fontSize: 14),
          ),
          if (career['milestone'] != null) ...[
            const SizedBox(height: 8),
            Text(
              '이정표: ${career['milestone']}',
              style: const TextStyle(
                fontSize: 13,
                color: TossDesignSystem.gray500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}