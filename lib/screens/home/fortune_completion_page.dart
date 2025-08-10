import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fortune.dart' as fortune_entity;

/// 운세 스토리 완료 후 표시되는 화면
class FortuneCompletionPage extends ConsumerWidget {
  final fortune_entity.Fortune? fortune;
  final VoidCallback? onReplay;
  final String? userName;

  const FortuneCompletionPage({
    super.key,
    this.fortune,
    this.onReplay,
    this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = fortune?.overallScore ?? 75;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f1624),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // 완료 메시지
                  Text(
                    '오늘의 운세',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '읽기 완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 1,
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  
                  const SizedBox(height: 40),
                  
                  // 종합 점수
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '종합 점수',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$score점',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStarRating(score),
                        const SizedBox(height: 16),
                        Text(
                          _getScoreMessage(score),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  // 세부 운세 점수
                  if (fortune?.scoreBreakdown != null) ...[
                    _buildScoreGrid(fortune!.scoreBreakdown!),
                    const SizedBox(height: 32),
                  ],
                  
                  // 행운의 요소들
                  if (fortune?.luckyItems != null) ...[
                    _buildLuckyItems(fortune!.luckyItems!),
                    const SizedBox(height: 32),
                  ],
                  
                  // 액션 버튼들
                  Column(
                    children: [
                      // 다시 보기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onReplay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF1a1a2e),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '다시 보기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 다른 운세 보기
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _showFortuneMenu(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '다른 운세 보기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate()
                    .fadeIn(duration: 800.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStarRating(int score) {
    final stars = (score / 20).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        ).animate()
          .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 600 + (index * 100)))
          .scale(begin: const Offset(0, 0), end: const Offset(1, 1));
      }),
    );
  }
  
  String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 날! 무엇이든 도전하세요';
    if (score >= 80) return '행운이 가득한 하루입니다';
    if (score >= 70) return '안정적이고 평온한 하루';
    if (score >= 60) return '차분하게 보내면 좋은 날';
    return '조심스럽게 행동하세요';
  }
  
  Widget _buildScoreGrid(Map<String, dynamic> scoreBreakdown) {
    final items = [
      {'title': '연애운', 'score': scoreBreakdown['love'] ?? 0, 'icon': Icons.favorite, 'color': Colors.pink},
      {'title': '직장운', 'score': scoreBreakdown['career'] ?? 0, 'icon': Icons.work, 'color': Colors.blue},
      {'title': '금전운', 'score': scoreBreakdown['money'] ?? 0, 'icon': Icons.attach_money, 'color': Colors.green},
      {'title': '건강운', 'score': scoreBreakdown['health'] ?? 0, 'icon': Icons.favorite_border, 'color': Colors.orange},
    ];
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] as String,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item['score']}점',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 600 + (index * 100)))
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      }).toList(),
    );
  }
  
  Widget _buildLuckyItems(Map<String, dynamic> luckyItems) {
    final items = <Widget>[];
    
    if (luckyItems['color'] != null) {
      items.add(_buildLuckyItem('색상', luckyItems['color'], Icons.palette));
    }
    if (luckyItems['number'] != null) {
      items.add(_buildLuckyItem('숫자', luckyItems['number'].toString(), Icons.looks_one));
    }
    if (luckyItems['time'] != null) {
      items.add(_buildLuckyItem('시간', luckyItems['time'], Icons.access_time));
    }
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '오늘의 행운',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms, delay: 700.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildLuckyItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFortuneMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFF1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '다른 운세 보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(context, '연애운', Icons.favorite, '/fortune/love'),
            _buildMenuItem(context, '직장운', Icons.work, '/fortune/career'),
            _buildMenuItem(context, '금전운', Icons.attach_money, '/fortune/wealth'),
            _buildMenuItem(context, '건강운', Icons.favorite_border, '/fortune/health'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 16),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}