import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/providers.dart';

class LuckyJobFortunePage extends ConsumerStatefulWidget {
  const LuckyJobFortunePage({super.key});

  @override
  ConsumerState<LuckyJobFortunePage> createState() => _LuckyJobFortunePageState();
}

class _LuckyJobFortunePageState extends ConsumerState<LuckyJobFortunePage> {
  String? _name;
  DateTime? _birthdate;
  String? _currentStatus;
  List<String> _interests = [];
  
  final List<Map<String, dynamic>> interestOptions = [
    {'id': 'tech', 'label': '기술/IT', 'icon': Icons.computer},
    {'id': 'art', 'label': '예술/디자인', 'icon': Icons.palette},
    {'id': 'business', 'label': '경영/사업', 'icon': Icons.business},
    {'id': 'education', 'label': '교육/연구', 'icon': Icons.school},
    {'id': 'health', 'label': '의료/건강', 'icon': Icons.local_hospital},
    {'id': 'service', 'label': '서비스/접객', 'icon': Icons.people},
    {'id': 'finance', 'label': '금융/회계', 'icon': Icons.account_balance},
    {'id': 'media', 'label': '미디어/방송', 'icon': Icons.movie},
    {'id': 'sports', 'label': '스포츠/운동', 'icon': Icons.sports},
    {'id': 'nature', 'label': '자연/환경', 'icon': Icons.nature},
    {'id': 'law', 'label': '법률/정책', 'icon': Icons.gavel},
    {'id': 'trade', 'label': '무역/물류', 'icon': Icons.local_shipping},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile != null) {
      setState(() {
        _name = profile.name;
        _birthdate = profile.birthDate;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '행운의 직업',
      fortuneType: 'lucky-job',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00BCD4), Color(0xFF3F51B5)],
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result),
    );
  }
  
  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '당신의 천직 찾기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '사주와 성향을 분석하여 당신에게 가장 잘 맞는 직업을 찾아드립니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Name input
          TextFormField(
            initialValue: _name,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            onChanged: (value) => _name = value,
          ),
          
          const SizedBox(height: 16),
          
          // Birthdate input
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                _birthdate != null
                    ? '${_birthdate!.year}년 ${_birthdate!.month}월 ${_birthdate!.day}일'
                    : '생년월일을 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  color: _birthdate != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current status
          DropdownButtonFormField<String>(
            value: _currentStatus,
            decoration: InputDecoration(
              labelText: '현재 상태',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.work),
            ),
            items: const [
              DropdownMenuItem(value: 'student', child: Text('학생')),
              DropdownMenuItem(value: 'job_seeker', child: Text('구직자')),
              DropdownMenuItem(value: 'employed', child: Text('직장인')),
              DropdownMenuItem(value: 'self_employed', child: Text('자영업/프리랜서')),
              DropdownMenuItem(value: 'career_change', child: Text('이직 준비중')),
            ],
            onChanged: (value) {
              setState(() {
                _currentStatus = value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Interest areas
          const Text(
            '관심 분야 (최대 3개)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interestOptions.map((option) {
              final isSelected = _interests.contains(option['id']);
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(option['label']),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _interests.length < 3) {
                      _interests.add(option['id']);
                    } else if (!selected) {
                      _interests.remove(option['id']);
                    } else if (_interests.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('최대 3개까지만 선택할 수 있습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  });
                },
                selectedColor: Colors.blue,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
          
          if (_interests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${_interests.length}/3개 선택됨',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canSubmit()
                  ? () => onSubmit({
                        'name': _name,
                        'birthdate': _birthdate!.toIso8601String(),
                        'current_status': _currentStatus,
                        'interests': _interests,
                      })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '천직 찾기',
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
  
  bool _canSubmit() {
    return _name != null &&
        _name!.isNotEmpty &&
        _birthdate != null &&
        _currentStatus != null &&
        _interests.isNotEmpty;
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdate = picked;
      });
    }
  }
  
  Widget _buildResult(BuildContext context, FortuneResult result) {
    final data = result.details ?? {};
    
    return Column(
      children: [
        // Main Job Recommendation
        if (data['recommended_job'] != null) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[100]!,
                  Colors.cyan[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  '당신의 천직',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['recommended_job'] ?? '분석 중',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (data['job_description'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    data['job_description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Compatibility Score
        if (result.overallScore != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: result.overallScore! / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(result.overallScore!),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '직업 적합도',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.overallScore}% 일치',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(result.overallScore!),
                        ),
                      ),
                      Text(
                        _getScoreMessage(result.overallScore!),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Main Fortune
        if (result.mainFortune != null) ...[
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
                const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      '상세 분석',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.mainFortune!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Alternative Jobs
        if (data['alternative_jobs'] != null && data['alternative_jobs'] is List) ...[
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
                const Row(
                  children: [
                    Icon(Icons.list, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '다른 추천 직업',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(data['alternative_jobs'] as List).map((job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          job.toString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Skill Requirements
        if (result.sections != null && result.sections!['required_skills'] != null) ...[
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
                const Row(
                  children: [
                    Icon(Icons.checklist, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '필요한 역량',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  result.sections!['required_skills'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Career Path
        if (result.sections != null && result.sections!['career_path'] != null) ...[
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      '경력 개발 경로',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  result.sections!['career_path'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Action Steps
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.rocket_launch, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '시작하기 위한 단계',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.recommendations!.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  String _getScoreMessage(int score) {
    if (score >= 80) return '천직이에요!';
    if (score >= 60) return '잘 맞는 직업입니다';
    if (score >= 40) return '노력하면 가능합니다';
    return '다른 분야도 고려해보세요';
  }
}