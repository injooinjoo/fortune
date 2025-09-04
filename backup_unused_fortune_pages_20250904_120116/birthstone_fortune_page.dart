import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/providers.dart';

class BirthstoneFortunePage extends ConsumerStatefulWidget {
  const BirthstoneFortunePage({super.key});

  @override
  ConsumerState<BirthstoneFortunePage> createState() => _BirthstoneFortunePageState();
}

class _BirthstoneFortunePageState extends ConsumerState<BirthstoneFortunePage> {
  int? _selectedMonth;
  
  final Map<int, Map<String, dynamic>> birthstones = {
    1: {
      'name': '가넷',
      'englishName': 'Garnet',
      'color': const Color(0xFF8B0000),
      'meaning': '진실, 우정, 충성',
      'description': '가넷은 변함없는 우정과 신뢰를 상징합니다. 어둠 속에서도 빛을 발하는 이 보석은 당신에게 희망과 용기를 줍니다.',
      'benefits': ['인내심 강화', '목표 달성 지원', '부정적 에너지 차단', '자신감 향상'],
      'chakra': '루트 차크라',
      'element': '불',
      'planet': '화성',
      'healing': '혈액순환 개선, 에너지 증진',
      'icon': Icons.feedback},
    2: {
      'name': '자수정',
      'englishName': 'Amethyst',
      'color': const Color(0xFF9966CC),
      'meaning': '평화, 안정, 지혜',
      'description': '자수정은 마음의 평화와 영적 성장을 돕습니다. 직관력을 높이고 명상에 도움을 주는 신비로운 보석입니다.',
      'benefits': ['스트레스 해소', '직관력 향상', '중독 극복', '영적 성장'],
      'chakra': '크라운 차크라',
      'element': '공기',
      'planet': '목성',
      'healing': '불면증 개선, 두통 완화',
      'icon': Icons.feedback},
    3: {
      'name': '아쿠아마린',
      'englishName': 'Aquamarine',
      'color': const Color(0xFF7FFFD4),
      'meaning': '용기, 소통, 정화',
      'description': '바다의 정수를 담은 아쿠아마린은 명확한 소통과 진실을 추구하게 합니다. 여행자의 수호석으로도 알려져 있습니다.',
      'benefits': ['의사소통 개선', '두려움 극복', '정신 정화', '관계 개선'],
      'chakra': '목 차크라',
      'element': '물',
      'planet': '해왕성',
      'healing': '목 건강, 알레르기 완화',
      'icon': Icons.feedback},
    4: {
      'name': '다이아몬드',
      'englishName': 'Diamond',
      'color': Colors.white,
      'meaning': '영원, 순수, 강인함',
      'description': '세상에서 가장 단단한 보석인 다이아몬드는 불굴의 의지와 영원한 사랑을 상징합니다.',
      'benefits': ['의지력 강화', '순수성 유지', '부정 에너지 정화', '풍요 유치'],
      'chakra': '크라운 차크라',
      'element': '빛',
      'planet': '금성',
      'healing': '뇌 기능 향상, 해독 작용',
      'icon': Icons.feedback},
    5: {
      'name': '에메랄드',
      'englishName': 'Emerald',
      'color': const Color(0xFF50C878),
      'meaning': '성장, 풍요, 치유',
      'description': '봄의 생명력을 담은 에메랄드는 새로운 시작과 번영을 가져다줍니다. 클레오파트라가 사랑한 보석입니다.',
      'benefits': ['재물운 상승', '사랑운 강화', '기억력 향상', '인내심 증진'],
      'chakra': '하트 차크라',
      'element': '흙',
      'planet': '수성',
      'healing': '시력 보호, 심장 건강',
      'icon': Icons.feedback},
    6: {
      'name': '진주',
      'englishName': 'Pearl',
      'color': const Color(0xFFFFFAF0),
      'meaning': '순결, 지혜, 정직',
      'description': '바다의 선물인 진주는 순수한 마음과 내면의 지혜를 상징합니다. 여성성과 모성애를 대표하는 보석입니다.',
      'benefits': ['감정 안정', '직관력 강화', '순수성 보호', '평온함 유지'],
      'chakra': '사크랄 차크라',
      'element': '물',
      'planet': '달',
      'healing': '소화 개선, 피부 건강',
      'icon': Icons.feedback},
    7: {
      'name': '루비',
      'englishName': 'Ruby',
      'color': const Color(0xFFE0115F),
      'meaning': '열정, 권력, 보호',
      'description': '열정의 불꽃을 담은 루비는 강력한 생명력과 리더십을 상징합니다. 왕의 보석으로 불리며 승리를 가져다줍니다.',
      'benefits': ['열정 증진', '리더십 강화', '자신감 상승', '보호 에너지'],
      'chakra': '루트 차크라',
      'element': '불',
      'planet': '태양',
      'healing': '혈액순환, 활력 증진',
      'icon': Icons.feedback},
    8: {
      'name': '페리도트',
      'englishName': 'Peridot',
      'color': const Color(0xFF9ACD32),
      'meaning': '행복, 긍정, 번영',
      'description': '태양의 보석 페리도트는 부정적인 감정을 정화하고 긍정적인 에너지를 가져다줍니다.',
      'benefits': ['스트레스 해소', '긍정성 향상', '인간관계 개선', '부의 유치'],
      'chakra': '하트 차크라',
      'element': '흙',
      'planet': '금성',
      'healing': '소화기 건강, 면역력 강화',
      'icon': Icons.feedback},
    9: {
      'name': '사파이어',
      'englishName': 'Sapphire',
      'color': const Color(0xFF0F52BA),
      'meaning': '지혜, 충성, 고귀함',
      'description': '하늘의 색을 담은 사파이어는 신성한 지혜와 정신적 깨달음을 상징합니다. 왕족의 보석으로 사랑받아 왔습니다.',
      'benefits': ['지혜 향상', '집중력 강화', '진실 추구', '정신적 평화'],
      'chakra': '제3의 눈 차크라',
      'element': '공기',
      'planet': '토성',
      'healing': '시력 개선, 정신 안정',
      'icon': Icons.feedback},
    10: {
      'name': '오팔',
      'englishName': 'Opal',
      'color': const Color(0xFFFFE4E1),
      'meaning': '희망, 창의성, 변화',
      'description': '무지개빛을 품은 오팔은 무한한 가능성과 창의적 영감을 상징합니다. 예술가의 보석으로 알려져 있습니다.',
      'benefits': ['창의력 증진', '감정 표현', '변화 수용', '영감 획듍'],
      'chakra': '모든 차크라',
      'element': '모든 원소',
      'planet': '수성',
      'healing': '감정 치유, 면역력 강화',
      'icon': Icons.feedback},
    11: {
      'name': '토파즈',
      'englishName': 'Topaz',
      'color': const Color(0xFFFFBF00),
      'meaning': '성공, 풍요, 기쁨',
      'description': '황금빛 토파즈는 태양의 에너지를 담아 성공과 풍요를 가져다줍니다. 우정과 사랑을 강화하는 보석입니다.',
      'benefits': ['목표 달성', '풍요 유치', '자신감 향상', '기쁨 증진'],
      'chakra': '태양신경총 차크라',
      'element': '불',
      'planet': '목성',
      'healing': '소화 개선, 신진대사 활성화',
      'icon': Icons.feedback},
    12: {
      'name': '터키석',
      'englishName': 'Turquoise',
      'color': const Color(0xFF40E0D0),
      'meaning': '보호, 치유, 행운',
      'description': '하늘과 바다의 색을 닮은 터키석은 강력한 보호와 치유의 에너지를 지닙니다. 여행자의 수호석입니다.',
      'benefits': ['보호 에너지', '치유력 강화', '소통 개선', '행운 유치'],
      'chakra': '목 차크라',
      'element': '공기와 물',
      'planet': '금성',
      'healing': '해독 작용, 면역력 강화',
      'icon': Icons.feedback,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadProfileBirthMonth();
  }

  void _loadProfileBirthMonth() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile?.birthDate != null) {
      setState(() {
        _selectedMonth = profile!.birthDate!.month;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '탄생석 운세',
      fortuneType: 'birthstone',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9966CC), Color(0xFF7FFFD4)]),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result));
  }

  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탄생월 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '당신이 태어난 월을 선택하면, 그 달의 탄생석이 전하는 특별한 메시지를 확인할 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          // Month grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final birthstone = birthstones[month]!;
              final isSelected = _selectedMonth == month;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMonth = month;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (birthstone['color'] as Color).withOpacity(0.2)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? birthstone['color'] as Color
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: birthstone['color'] as Color,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        birthstone['icon'],
                        size: 32,
                        color: birthstone['color'],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$month월',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? birthstone['color'] as Color
                              : Colors.grey[700]!,
                        ),
                      ),
                      Text(
                        birthstone['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          
          const SizedBox(height: 24),
          
          // Selected birthstone preview
          if (_selectedMonth != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (birthstones[_selectedMonth]!['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: birthstones[_selectedMonth]!['color'] as Color,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    birthstones[_selectedMonth]!['icon'] as IconData,
                    size: 48,
                    color: birthstones[_selectedMonth]!['color'] as Color,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          birthstones[_selectedMonth]!['name'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          birthstones[_selectedMonth]!['englishName'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          birthstones[_selectedMonth]!['meaning'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: birthstones[_selectedMonth]!['color'] as Color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedMonth != null 
                ? () => onSubmit({
                    'month': _selectedMonth})
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMonth != null
                    ? birthstones[_selectedMonth]!['color'] as Color
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '탄생석 운세 확인하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, FortuneResult result) {
    final data = result.details ?? {};
    
    // Extract month from result or use selected month
    int? month = data['month'] ?? _selectedMonth;
    if (month == null) {
      return const Center(child: Text('탄생석 정보를 불러올 수 없습니다.'));
    }
    
    final birthstone = birthstones[month]!;
    
    return Column(
      children: [
        // Birthstone header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                birthstone['color'] as Color,
                (birthstone['color'] as Color).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                birthstone['icon'] as IconData,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                birthstone['name'] as String,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                birthstone['englishName'] as String,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (birthstone['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  birthstone['meaning'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    color: birthstone['color'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            birthstone['description'] as String,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Benefits
        Container(
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
                  Icon(Icons.auto_awesome, color: birthstone['color'] as Color),
                  const SizedBox(width: 8),
                  const Text(
                    '탄생석의 효능',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...(birthstone['benefits'] as List<String>).map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: birthstone['color'] as Color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Spiritual info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple[50]!,
                Colors.blue[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.spa, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    '영적 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('차크라', birthstone['chakra'] as String),
              _buildInfoRow('원소', birthstone['element'] as String),
              _buildInfoRow('지배 행성', birthstone['planet'] as String),
              _buildInfoRow('치유 효과', birthstone['healing'] as String),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Additional content from API
        if (data['content'] != null) ...[
          const SizedBox(height: 20),
          Text(
            data['content'],
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}