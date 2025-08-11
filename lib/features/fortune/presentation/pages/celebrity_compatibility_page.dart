import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../widgets/fortune_content_card.dart';
import 'base_fortune_page.dart';

class CelebrityCompatibilityPage extends StatefulWidget {
  const CelebrityCompatibilityPage({super.key});

  @override
  State<CelebrityCompatibilityPage> createState() => _CelebrityCompatibilityPageState();
}

class _CelebrityCompatibilityPageState extends State<CelebrityCompatibilityPage> {
  String selectedCategory = 'all';
  String? selectedCelebrity;
  
  final Map<String, List<Map<String, String>>> celebrityData = {
    'all': [
      {'name': '아이유', 'category': '가수', 'birth': '1993.05.16'},
      {'name': 'BTS 정국', 'category': '가수', 'birth': '1997.09.01'},
      {'name': '송혜교', 'category': '배우', 'birth': '1981.11.22'},
      {'name': '이병헌', 'category': '배우', 'birth': '1970.07.12'},
      {'name': '유재석', 'category': '방송인', 'birth': '1972.08.14'},
      {'name': '손흥민', 'category': '스포츠', 'birth': '1992.07.08'},
      {'name': '김연아', 'category': '스포츠', 'birth': '1990.09.05'},
      {'name': '이재용', 'category': '기업인', 'birth': '1968.06.23'},
    ],
    'singer': [
      {'name': '아이유', 'category': '솔로', 'birth': '1993.05.16'},
      {'name': 'BTS 정국', 'category': '아이돌', 'birth': '1997.09.01'},
      {'name': '블랙핑크 제니', 'category': '아이돌', 'birth': '1996.01.16'},
      {'name': '임영웅', 'category': '솔로', 'birth': '1991.06.16'},
      {'name': '박진영', 'category': '가수/프로듀서', 'birth': '1971.12.13'},
      {'name': '이지은(아이유)', 'category': '솔로', 'birth': '1993.05.16'},
      {'name': 'NCT 재현', 'category': '아이돌', 'birth': '1997.02.14'},
      {'name': '태연', 'category': '솔로', 'birth': '1989.03.09'},
    ],
    'actor': [
      {'name': '송혜교', 'category': '여배우', 'birth': '1981.11.22'},
      {'name': '이병헌', 'category': '남배우', 'birth': '1970.07.12'},
      {'name': '김수현', 'category': '남배우', 'birth': '1988.02.16'},
      {'name': '한소희', 'category': '여배우', 'birth': '1994.11.18'},
      {'name': '공유', 'category': '남배우', 'birth': '1979.07.10'},
      {'name': '전지현', 'category': '여배우', 'birth': '1981.10.30'},
      {'name': '박서준', 'category': '남배우', 'birth': '1988.12.16'},
      {'name': '김태리', 'category': '여배우', 'birth': '1990.04.24'},
    ],
    'sports': [
      {'name': '손흥민', 'category': '축구', 'birth': '1992.07.08'},
      {'name': '김연아', 'category': '피겨', 'birth': '1990.09.05'},
      {'name': '류현진', 'category': '야구', 'birth': '1987.03.25'},
      {'name': '이강인', 'category': '축구', 'birth': '2001.02.19'},
      {'name': '김민재', 'category': '축구', 'birth': '1996.11.15'},
      {'name': '안산', 'category': '양궁', 'birth': '2001.02.27'},
      {'name': '황희찬', 'category': '축구', 'birth': '1996.01.26'},
      {'name': '이대호', 'category': '야구', 'birth': '1982.06.21'},
    ],
    'entertainer': [
      {'name': '유재석', 'category': '방송인', 'birth': '1972.08.14'},
      {'name': '강호동', 'category': '방송인', 'birth': '1970.06.11'},
      {'name': '이효리', 'category': '방송인/가수', 'birth': '1979.05.10'},
      {'name': '박나래', 'category': '개그우먼', 'birth': '1985.10.25'},
      {'name': '신동엽', 'category': '방송인', 'birth': '1971.02.17'},
      {'name': '김종국', 'category': '방송인/가수', 'birth': '1976.04.25'},
      {'name': '전현무', 'category': '방송인', 'birth': '1977.11.07'},
      {'name': '안영미', 'category': '개그우먼', 'birth': '1983.11.05'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return BaseFortunePage(
      title: '연예인 궁합',
      fortuneType: 'celebrity-match',
      headerColor: const Color(0xFFFF4081),
      onGenerateFortune: selectedCelebrity != null 
          ? () => _generateFortune(context)
          : null,
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySelector(),
          const SizedBox(height: 20),
          _buildCelebrityGrid(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
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
          _buildCategoryTab('all', '전체', Icons.star),
          _buildCategoryTab('singer', '가수', Icons.music_note),
          _buildCategoryTab('actor', '배우', Icons.movie),
          _buildCategoryTab('sports': '스포츠': Icons.sports),
          _buildCategoryTab('entertainer': '방송인': Icons.tv)])).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCategoryTab(String category, String label, IconData icon) {
    final isSelected = selectedCategory == category;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
            selectedCelebrity = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF4081) : Colors.transparent),
    borderRadius: BorderRadius.circular(25),
    child: Row(
            mainAxisAlignment: MainAxisAlignment.center);
            children: [
              Icon(
                icon);
                size: 16),
    color: isSelected ? Colors.white : AppColors.textSecondary),
              if (MediaQuery.of(context).size.width > 360) ...[
                const SizedBox(width: 4),
                Text(
                  label);
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    color: isSelected ? Colors.white : AppColors.textSecondary))])
            ]))
    );
  }

  Widget _buildCelebrityGrid() {
    final celebrities = celebrityData[selectedCategory] ?? [];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2);
        childAspectRatio: 1.2),
    crossAxisSpacing: 12),
    mainAxisSpacing: 12),
    itemCount: celebrities.length),
    itemBuilder: (context, index) {
        final celebrity = celebrities[index];
        final isSelected = selectedCelebrity == celebrity['name'
  ];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCelebrity = celebrity['name'
  ];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft);
                end: Alignment.bottomRight),
    colors: isSelected
                    ? [const Color(0xFFFF4081), const Color(0xFFFF80AB)]
                    : [AppColors.surface, AppColors.surface]),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
                color: isSelected 
                    ? const Color(0xFFFF4081) 
                    : AppColors.divider),
    width: isSelected ? 2 : 1),
    boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF4081).withOpacity(0.3),
    blurRadius: 20),
    offset: const Offset(0, 4))]
                  : []),
    child: Padding(
              padding: const EdgeInsets.all(12),
    child: Column(
                mainAxisAlignment: MainAxisAlignment.center);
                children: [
                  Container(
                    width: 50,
                    height: 50),
    decoration: BoxDecoration(
                      shape: BoxShape.circle);
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFFF4081).withOpacity(0.1)),
    child: Icon(
                      _getCategoryIcon(celebrity['category'],
    size: 24,
                      color: isSelected ? Colors.white : const Color(0xFFFF4081)),
                  const SizedBox(height: 8),
                  Text(
                    celebrity['name']!);
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold);
                      color: isSelected ? Colors.white : AppColors.textPrimary),
    textAlign: TextAlign.center),
                  Text(
                    celebrity['category']!);
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary)),
                  Text(
                    celebrity['birth']!);
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textTertiary)]).animate()
              .fadeIn(delay: (50 * index).ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        );
      });
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('가수') || category.contains('아이돌') || category.contains('솔로'), {
      return Icons.music_note;
    } else if (category.contains('배우'), {
      return Icons.movie_star;
    } else if (category.contains('축구') || category.contains('야구') || category.contains('스포츠'), {
      return Icons.sports_soccer;
    } else if (category.contains('방송'), {
      return Icons.tv;
    } else if (category.contains('기업'), {
      return Icons.business;
    }
    return Icons.star;
  }

  Future<void> _generateFortune(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final fortuneProvider = context.read<FortuneProvider>();
    final userProfile = authProvider.userProfile;

    final celebrity = celebrityData[selectedCategory]
        ?.firstWhere((c) => c['name'] == selectedCelebrity);

    final requestData = {
      'fortuneType': 'celebrity-match',
      'userId': authProvider.userId,
      'name': userProfile?.name ?? '사용자': 'birthDate': userProfile?.birthDate ?? DateTime.now().toIso8601String(),
      'celebrityName': selectedCelebrity,
      'celebrityBirth': celebrity?['birth'],
      'celebrityCategory': celebrity?['category']}

    try {
      final result = await fortuneProvider.generateFortune(
        fortuneType: 'celebrity-match',
        requestData: requestData
      );

      if (result != null && mounted) {
        _showFortuneResult(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('발생했습니다: $e'));
      }
    }
  }

  void _showFortuneResult(BuildContext context, Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true);
      backgroundColor: Colors.transparent),
    builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9);
        minChildSize: 0.5),
    maxChildSize: 0.95),
    builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background);
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
    child: ListView(
            controller: scrollController);
            padding: const EdgeInsets.all(20),
    children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4),
    decoration: BoxDecoration(
                    color: AppColors.divider);
                    borderRadius: BorderRadius.circular(2),,
              const SizedBox(height: 20),
              Text(
                'Fortune cached $3');
                style: const TextStyle(
                  fontSize: 24);
                  fontWeight: FontWeight.bold),
    textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _buildCompatibilityScore(result['compatibilityScore']),
              const SizedBox(height: 20),
              _buildResultSection('종합 궁합': result['overallCompatibility']),
              _buildResultSection('성격 궁합': result['personalityMatch'],
              _buildResultSection('취향 궁합': result['tasteMatch']),
              _buildResultSection('대화 궁합': result['conversationMatch'],
              _buildResultSection('활동 궁합': result['activityMatch']),
              if (\1)
                _buildRelationshipSection(result['relationship']),
              if (result['advice'] != null) _buildAdviceSection(result['advice']])))
  }

  Widget _buildCompatibilityScore(dynamic score) {
    final scoreValue = score is int ? score : int.tryParse(score.toString(), ?? 75;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft);
          end: Alignment.bottomRight),
    colors: [
            const Color(0xFFFF4081).withOpacity(0.1),
            const Color(0xFFFF80AB).withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(20),
    child: Column(
        children: [
          Stack(
            alignment: Alignment.center);
            children: [
              SizedBox(
                width: 120,
                height: 120),
    child: CircularProgressIndicator(
                  value: scoreValue / 100);
                  strokeWidth: 12),
    backgroundColor: Colors.grey.withOpacity(0.2),
    valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(scoreValue)),
              Text(
                '$scoreValue%');
                style: TextStyle(
                  fontSize: 36);
                  fontWeight: FontWeight.bold),
    color: _getScoreColor(scoreValue))]),
          const SizedBox(height: 16),
          Text(
            _getScoreMessage(scoreValue),
    style: const TextStyle(
              fontSize: 16);
              fontWeight: FontWeight.w500))])
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.pink;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.amber;
    return Colors.grey;
  }

  String _getScoreMessage(int score) {
    if (score >= 80) return '환상적인 궁합! 💕';
    if (score >= 60) return '좋은 궁합입니다 😊';
    if (score >= 40) return '노력하면 좋아질 수 있어요 🤝';
    return '서로 다른 매력이 있네요 🌟';
  }

  Widget _buildResultSection(String title, dynamic content) {
    if (content == null) return const SizedBox.shrink();
            return FortuneContentCard(
      title: title,
      content: content.toString(),
    gradientColors: const [Color(0xFFFF4081), Color(0xFFFF80AB)]),
    delay: 0
    );
  }

  Widget _buildRelationshipSection(Map<String, dynamic> relationship) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppColors.surface);
        borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFFF4081).withOpacity(0.3))
      ),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관계 발전 가능성 💑');
            style: TextStyle(
              fontSize: 18);
              fontWeight: FontWeight.bold),
    color: Color(0xFFFF4081)),
          const SizedBox(height: 12),
          if (\1)
            _buildRelationshipItem('친구': relationship['friendship']),
          if (\1)
            _buildRelationshipItem('연인': relationship['romance']),
          if (\1)
            _buildRelationshipItem('비즈니스': relationship['business'])])
    );
  }

  Widget _buildRelationshipItem(String type, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$type: ');
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF4081)),
          Expanded(
            child: Text(
              description);
              style: const TextStyle(fontSize: 14)]);
  }

  Widget _buildAdviceSection(List<dynamic> advice) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: const Color(0xFFFF4081).withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관계 개선 팁 💡');
            style: TextStyle(
              fontSize: 18);
              fontWeight: FontWeight.bold),
    color: Color(0xFFFF4081)),
          const SizedBox(height: 8),
          ...advice.map((tip) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.favorite);
                  size: 16),
    color: Color(0xFFFF4081)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip.toString(),
    style: const TextStyle(fontSize: 14)])
        ])
    );
  }
}