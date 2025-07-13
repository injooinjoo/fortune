import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/fortune.dart';
import '../../providers/providers.dart';
import 'base_fortune_screen.dart';

class DailyFortuneScreen extends BaseFortuneScreen {
  const DailyFortuneScreen({super.key})
      : super(
          fortuneType: 'daily',
          title: '오늘의 운세',
          description: '매일 달라지는 운의 흐름',
          tokenCost: 1,
        );

  @override
  ConsumerState<DailyFortuneScreen> createState() => _DailyFortuneScreenState();
}

class _DailyFortuneScreenState extends BaseFortuneScreenState<DailyFortuneScreen> {
  @override
  Future<DailyFortune> loadFortuneData() async {
    final fortuneDataSource = ref.read(fortuneRemoteDataSourceProvider);
    final response = await fortuneDataSource.getDailyFortune();
    
    if (response.data?.toDailyFortune() == null) {
      throw Exception('Invalid fortune data');
    }
    
    return response.data!.toDailyFortune()!;
  }

  @override
  Widget buildFortuneContent(BuildContext context, dynamic data) {
    final fortune = data as DailyFortune;
    
    return Column(
      children: [
        // 점수와 기분
        _buildScoreSection(fortune),
        const SizedBox(height: 24),
        
        // 운세 요약
        _buildSummarySection(fortune),
        const SizedBox(height: 24),
        
        // 운세 요소
        _buildElementsSection(fortune),
        const SizedBox(height: 24),
        
        // 행운 아이템
        _buildLuckyItemsSection(fortune),
        const SizedBox(height: 24),
        
        // 조언
        _buildAdviceSection(fortune),
      ],
    );
  }

  Widget _buildScoreSection(DailyFortune fortune) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 점수 게이지
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: fortune.score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(fortune.score),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${fortune.score}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(fortune.score),
                    ),
                  ),
                  Text(
                    '점',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ).animate()
            .scale(
              duration: 1.seconds,
              curve: Curves.elasticOut,
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
            ),
          const SizedBox(height: 24),
          
          // 기분과 에너지
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(
                icon: Icons.mood,
                label: '기분',
                value: fortune.mood,
                color: Colors.orange,
              ),
              _buildInfoChip(
                icon: Icons.bolt,
                label: '에너지',
                value: '${fortune.energy}%',
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(DailyFortune fortune) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.purple.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 메시지',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fortune.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.purple.shade900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fortune.keywords.map((keyword) => Chip(
              label: Text(
                '#$keyword',
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.purple.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildElementsSection(DailyFortune fortune) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운세 영역별 점수',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildElementCard(
          context,
          icon: Icons.favorite,
          title: '연애운',
          score: fortune.elements.love,
          color: Colors.pink,
        ),
        const SizedBox(height: 12),
        _buildElementCard(
          context,
          icon: Icons.work,
          title: '직업운',
          score: fortune.elements.career,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildElementCard(
          context,
          icon: Icons.attach_money,
          title: '금전운',
          score: fortune.elements.money,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildElementCard(
          context,
          icon: Icons.favorite_border,
          title: '건강운',
          score: fortune.elements.health,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildLuckyItemsSection(DailyFortune fortune) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 행운 아이템',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  context,
                  icon: Icons.palette,
                  label: '행운의 색',
                  value: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                        fortune.luckyColor.replaceAll('#', '0xFF'),
                      )),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLuckyItem(
                  context,
                  icon: Icons.looks_one,
                  label: '행운의 숫자',
                  value: Text(
                    '${fortune.luckyNumber}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  context,
                  icon: Icons.access_time,
                  label: '최적 시간',
                  value: Text(
                    fortune.bestTime,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLuckyItem(
                  context,
                  icon: Icons.people,
                  label: '좋은 만남',
                  value: Text(
                    fortune.compatibility,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection(DailyFortune fortune) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 조언',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            fortune.advice,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '주의사항',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            fortune.caution,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int score,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$score%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 100 * title.length))
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildLuckyItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          value,
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  List<Map<String, String>> getRelatedFortunes() {
    return [
      {'title': '내일의 운세', 'route': '/fortune/tomorrow'},
      {'title': '이번주 운세', 'route': '/fortune/weekly'},
      {'title': '연애운', 'route': '/fortune/love'},
    ];
  }
}