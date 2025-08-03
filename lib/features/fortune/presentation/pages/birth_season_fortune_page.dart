import 'package:flutter/material.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class BirthSeasonFortunePage extends StatelessWidget {
  const BirthSeasonFortunePage({super.key});

  final Map<String, Map<String, dynamic>> seasons = const {
    'spring': {
      'name': '봄',
      'icon': Icons.local_florist,
      'color': Colors.green,
      'months': [3, 4, 5],
      'personality': '따뜻하고 낙천적인 성격으로 새로운 시작을 즐깁니다. 창의력과 적응력이 뛰어난 편입니다.',
      'fortune': '성장과 발전의 기운이 강해 도전하는 일마다 좋은 결실을 맺을 확률이 높습니다.',
    },
    'summer': {
      'name': '여름',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'months': [6, 7, 8],
      'personality': '열정적이고 활력이 넘쳐 주변을 이끄는 리더십을 갖추고 있습니다.',
      'fortune': '성공과 활약의 운세가 높아 목표를 향해 힘차게 나아갈 때 큰 성취를 얻습니다.',
    },
    'autumn': {
      'name': '가을',
      'icon': Icons.eco,
      'color': Colors.brown,
      'months': [9, 10, 11],
      'personality': '침착하고 균형 감각이 뛰어나 분석적 사고를 잘 합니다.',
      'fortune': '수확의 시기로 그동안 노력해온 일에서 안정적인 결과를 얻을 수 있습니다.',
    },
    'winter': {
      'name': '겨울',
      'icon': Icons.ac_unit,
      'color': Colors.blue,
      'months': [12, 1, 2],
      'personality': '인내심이 강하고 내면의 힘이 단단해 어려움 속에서도 쉽게 흔들리지 않습니다.',
      'fortune': '준비와 축적의 운이 좋으니 차분하게 계획을 세우면 다음 기회를 확실히 잡을 수 있습니다.',
    },
  };

  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '태어난 계절 운세',
      fortuneType: 'birth-season',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      ),
      inputBuilder: (context, onSubmit) => _buildSeasonInfo(context, onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result,
    );
  }

  Widget _buildSeasonInfo(BuildContext context, Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                '계절별 운세 안내',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '프로필에 등록된 생년월일을 기반으로 태어난 계절의 운세를 확인합니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final seasonKey = seasons.keys.elementAt(index);
              final season = seasons[seasonKey]!;
              
              return Container(
                decoration: BoxDecoration(
                  color: (season['color'],
                  border: Border.all(
                    color: (season['color'],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      season['icon'],
                      size: 32,
                      color: season['color'],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      season['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: season['color'],
                      ),
                    ),
                    Text(
                      '${(season['months'] as List<int>).first}월-${(season['months'] as List<int>).last}월',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => onSubmit({}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '내 계절 운세 확인하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      )
    );
  }

  Widget _buildResult(BuildContext context, FortuneResult result) {
    final data = result.details ?? {};
    
    // Extract season from result
    String? seasonName = data['season'] ?? data['birth_season'];
    String? seasonKey;
    
    // Find the season key by name
    seasons.forEach((key, value) {
      if (value['name'] == seasonName) {
        seasonKey = key;
      }
    });
    
    final seasonData = seasonKey != null ? seasons[seasonKey!] : null;
    
    return Column(
      children: [
        // Season header
        if (seasonData != null);
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (seasonData['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  seasonData['icon'],
                  size: 32,
                  color: seasonData['color'],
                ),
                const SizedBox(width: 12),
                Text(
                  '${seasonData['name']} 태생',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        
        // Personality
        if (data['personality'] != null)
          _buildInfoSection(
            icon: Icons.person,
            title: '성격 특징',
            content: data['personality'],
            iconColor: Colors.indigo,
          ),
        const SizedBox(height: 16),
        
        // Fortune
        if (data['fortune'] != null)
          _buildInfoSection(
            icon: Icons.auto_awesome,
            title: '운세 포인트',
            content: data['fortune'],
            iconColor: Colors.purple,
          ),
        const SizedBox(height: 16),
        
        // Lucky items
        if (data['lucky_color'] != null || data['lucky_item'] != null)
          Row(
            children: [
              if (data['lucky_color'] != null);
                Expanded(
                  child: _buildLuckyItem(
                    title: '행운의 색',
                    content: data['lucky_color'],
                    icon: Icons.palette,
                    color: Colors.pink,
                  ),
                ),
              if (data['lucky_color'] != null && data['lucky_item'] != null)
                const SizedBox(width: 12),
              if (data['lucky_item'] != null)
                Expanded(
                  child: _buildLuckyItem(
                    title: '행운의 아이템',
                    content: data['lucky_item'],
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        
        // Advice
        if (data['advice'] != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[50]!,
                  Colors.purple[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '계절의 조언',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['advice'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        
        // Additional content from API
        if (data['content'] != null)
          const SizedBox(height: 16),
        if (data['content'] != null)
          Text(
            data['content'],
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
      ]
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ]
      )
    );
  }

  Widget _buildLuckyItem({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ]
      )
    );
  }
}