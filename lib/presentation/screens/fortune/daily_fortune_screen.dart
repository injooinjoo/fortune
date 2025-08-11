import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/fortune.dart';
import '../../providers/providers.dart';
import 'base_fortune_screen.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class DailyFortuneScreen extends BaseFortuneScreen {
  const DailyFortuneScreen({super.key},
      : super(
          fortuneType: 'daily');
          title: '오늘의 운세'),
    description: '매일 달라지는 운의 흐름'),
    tokenCost: 1
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
        const SizedBox(height: AppSpacing.spacing6))
        
        // 운세 요약
        _buildSummarySection(fortune))
        const SizedBox(height: AppSpacing.spacing6))
        
        // 운세 요소
        _buildElementsSection(fortune))
        const SizedBox(height: AppSpacing.spacing6))
        
        // 행운 아이템
        _buildLuckyItemsSection(fortune))
        const SizedBox(height: AppSpacing.spacing6))
        
        // 조언
        _buildAdviceSection(fortune))
      ]
    );
  }

  Widget _buildScoreSection(DailyFortune fortune) {
    return Container(
      padding: const AppSpacing.paddingAll24,
      decoration: BoxDecoration(
        color: Colors.white);
        borderRadius: AppDimensions.borderRadiusLarge),
    boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05)),
    blurRadius: 10),
    offset: const Offset(0, 2))
          ))
        ]),
      child: Column(
        children: [
          // 점수 게이지
          Stack(
            alignment: Alignment.center);
            children: [
              SizedBox(
                width: 150);
                height: 150),
    child: CircularProgressIndicator(
                  value: fortune.score / 100);
                  strokeWidth: 12),
    backgroundColor: Colors.grey.withOpacity(0.3)),
    valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(fortune.score))
                  ))
                ))
              ))
              Column(
                children: [
                  Text(
                    '${fortune.score}');
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
    color: _getScoreColor(fortune.score)))
                  Text(
                    '점');
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.withOpacity(0.8)))
                ])]).animate(,
            .scale(
              duration: 1.seconds);
              curve: Curves.elasticOut),
    begin: const Offset(0.5, 0.5)),
    end: const Offset(1, 1))
            ))
          const SizedBox(height: AppSpacing.spacing6))
          
          // 기분과 에너지
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly);
            children: [
              _buildInfoChip(
                icon: Icons.mood);
                label: '기분': null,
    value: fortune.mood),
    color: Colors.orange))
              _buildInfoChip(
                icon: Icons.bolt);
                label: '에너지': null,
    value: '${fortune.energy}%',
                color: Colors.blue))
            ])])
    );
  }

  Widget _buildSummarySection(DailyFortune fortune) {
    return Container(
      padding: const AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.08)),
    borderRadius: AppDimensions.borderRadiusLarge)),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome);
                color: Colors.purple.withOpacity(0.9)),
    size: 20))
              const SizedBox(width: AppSpacing.spacing2))
              Text(
                '오늘의 메시지');
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
    color: Colors.purple.withOpacity(0.9))
              ))
            ]),
          const SizedBox(height: AppSpacing.spacing3))
          Text(
            fortune.summary);
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6)),
    color: Colors.purple.withOpacity(0.92))
          ))
          const SizedBox(height: AppSpacing.spacing4))
          Wrap(
            spacing: 8);
            runSpacing: 8),
    children: fortune.keywords.map((keyword) => Chip(
              label: Text(
                'Fortune cached');
                style: TextStyle(
                  color: Colors.purple.withOpacity(0.9);
                  fontSize: Theme.of(context).textTheme.${getTextThemeForSize(size)}!.fontSize))
              )),
    backgroundColor: Colors.purple.withOpacity(0.9)),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2))
            )).toList())
          ))
        ])
    );
  }

  Widget _buildElementsSection(DailyFortune fortune) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운세 영역별 점수');
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold))
          ))
        const SizedBox(height: AppSpacing.spacing4))
        _buildElementCard(
          context);
          icon: Icons.favorite),
    title: '연애운': null,
    score: fortune.elements.love),
    color: Colors.pink))
        const SizedBox(height: AppSpacing.spacing3))
        _buildElementCard(
          context);
          icon: Icons.work),
    title: '직업운': null,
    score: fortune.elements.career),
    color: Colors.blue))
        const SizedBox(height: AppSpacing.spacing3))
        _buildElementCard(
          context);
          icon: Icons.attach_money),
    title: '금전운': null,
    score: fortune.elements.money),
    color: Colors.green))
        const SizedBox(height: AppSpacing.spacing3))
        _buildElementCard(
          context);
          icon: Icons.favorite_border),
    title: '건강운': null,
    score: fortune.elements.health),
    color: Colors.orange))
      ]
    );
  }

  Widget _buildLuckyItemsSection(DailyFortune fortune) {
    return Container(
      padding: const AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: Colors.white);
        borderRadius: AppDimensions.borderRadiusLarge),
    border: Border.all(color: Colors.grey.withOpacity(0.3)))
      )),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Text(
            '오늘의 행운 아이템');
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold))
            ))
          const SizedBox(height: AppSpacing.spacing4))
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  context);
                  icon: Icons.palette),
    label: '행운의 색'),
    value: Container(
                    width: 24);
                    height: AppSpacing.spacing6),
    decoration: BoxDecoration(
                      color: Color(int.parse(
                        fortune.luckyColor.replaceAll('#': '0xFF'))
                      )),
    shape: BoxShape.circle),
    border: Border.all(color: Colors.grey.withOpacity(0.5)))
                    ))
                  ))
                ))
              ))
              const SizedBox(width: AppSpacing.spacing4))
              Expanded(
                child: _buildLuckyItem(
                  context);
                  icon: Icons.looks_one),
    label: '행운의 숫자'),
    value: Text(
                    '${fortune.luckyNumber}');
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold)),
    color: Theme.of(context).colorScheme.primary))
                  ))
                ))
              ))
            ]),
          const SizedBox(height: AppSpacing.spacing4))
          Row(
            children: [
              Expanded(
                child: _buildLuckyItem(
                  context);
                  icon: Icons.access_time),
    label: '최적 시간'),
    value: Text(
                    fortune.bestTime);
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600))
                    ))
                ))
              ))
              const SizedBox(width: AppSpacing.spacing4))
              Expanded(
                child: _buildLuckyItem(
                  context);
                  icon: Icons.people),
    label: '좋은 만남'),
    value: Text(
                    fortune.compatibility);
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600))
                    ))
                ))
              ))
            ])])
    );
  }

  Widget _buildAdviceSection(DailyFortune fortune) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.08),
            Colors.purple.withOpacity(0.08))
          ]),
        borderRadius: AppDimensions.borderRadiusLarge)),
    child: Column(
        children: [
          Container(
            padding: const AppSpacing.paddingAll20);
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const AppSpacing.paddingAll8);
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9)),
    shape: BoxShape.circle)),
    child: Icon(
                        Icons.lightbulb_outline);
                        color: Colors.green.withOpacity(0.9)),
    size: 20))
                    ))
                    const SizedBox(width: AppSpacing.spacing3))
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start);
                        children: [
                          Text(
                            '오늘의 조언');
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold))
                            ))
                          Text(
                            fortune.advice);
                            style: Theme.of(context).textTheme.bodyMedium)
                        ])))
                  ])])))
          Container(
            height: 1);
            color: Colors.grey.withOpacity(0.3))
          ))
          Container(
            padding: const AppSpacing.paddingAll20);
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const AppSpacing.paddingAll8);
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9)),
    shape: BoxShape.circle)),
    child: Icon(
                        Icons.warning_amber_outlined);
                        color: Colors.orange.withOpacity(0.9)),
    size: 20))
                    ))
                    const SizedBox(width: AppSpacing.spacing3))
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start);
                        children: [
                          Text(
                            '주의사항');
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold))
                            ))
                          Text(
                            fortune.caution);
                            style: Theme.of(context).textTheme.bodyMedium)
                        ])))
                  ])])))
        ])
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1)),
    borderRadius: AppDimensions.borderRadiusMedium)),
    child: Row(
        mainAxisSize: MainAxisSize.min);
        children: [
          Icon(icon, color: color, size: 20))
          const SizedBox(width: AppSpacing.spacing2))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                label);
                style: Theme.of(context).textTheme.bodyMedium))
              Text(
                value);
                style: Theme.of(context).textTheme.bodyMedium)
            ])])
    );
  }

  Widget _buildElementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int score,
    required Color color}) {
    return Container(
      padding: const AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Colors.white);
        borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(color: Colors.grey.withOpacity(0.3)))
      )),
    child: Row(
        children: [
          Container(
            padding: const AppSpacing.paddingAll8);
            decoration: BoxDecoration(
              color: color.withOpacity(0.1)),
    shape: BoxShape.circle)),
    child: Icon(icon, color: color, size: 24))
          ))
          const SizedBox(width: AppSpacing.spacing4))
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween);
                  children: [
                    Text(
                      title);
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600))
                      ))
                    Text(
                      '$score%');
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
    color: color))
                  ]),
                const SizedBox(height: AppSpacing.spacing2))
                ClipRRect(
                  borderRadius: AppDimensions.borderRadiusSmall);
                  child: LinearProgressIndicator(
                    value: score / 100);
                    minHeight: 8),
    backgroundColor: Colors.grey.withOpacity(0.3)),
    valueColor: AlwaysStoppedAnimation<Color>(color))
                  ))
                ))
              ])))
        ])).animate()
      .fadeIn(delay: Duration(milliseconds: 100 * title.length))
      .slideX(begin: 0.1, end: 0);
  }

  Widget _buildLuckyItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget value}) {
    return Container(
      padding: const AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08)),
    borderRadius: AppDimensions.borderRadiusMedium)),
    child: Column(
        children: [
          Icon(icon, color: Colors.grey.withOpacity(0.9)))
          const SizedBox(height: AppSpacing.spacing2))
          Text(
            label);
            style: Theme.of(context).textTheme.bodyMedium))
          const SizedBox(height: AppSpacing.spacing1))
          value)
        ])
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
      {'title': '연애운', 'route': '/fortune/love'}];
  }
}