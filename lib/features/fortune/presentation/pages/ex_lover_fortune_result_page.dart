import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/emotion_radar_chart.dart';
import '../widgets/healing_progress_widget.dart';

class ExLoverFortuneResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> fortuneData;
  
  const ExLoverFortuneResultPage({
    Key? key,
    required this.fortuneData,
  }) : super(key: key);

  @override
  ConsumerState<ExLoverFortuneResultPage> createState() => _ExLoverFortuneResultPageState();
}

class _ExLoverFortuneResultPageState extends ConsumerState<ExLoverFortuneResultPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortune = widget.fortuneData;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '운세 결과',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareFortune,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
              const Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 인사말
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fortune['greeting'] ?? '운세 분석이 완료되었습니다',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // 탭 바
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  tabs: const [
                    Tab(text: '감정 상태'),
                    Tab(text: '관계 분석'),
                    Tab(text: '재회 가능성'),
                    Tab(text: '앞으로'),
                  ],
                ),
              ),
              
              // 탭 뷰
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmotionalStateTab(fortune['emotionalState'],
                    _buildRelationshipAnalysisTab(fortune['relationshipAnalysis'],
                    _buildReunionPossibilityTab(fortune['reunionPossibility'],
                    _buildMovingForwardTab(fortune['movingForward'],
                  ],
                ),
              ),
              
              // 하단 조언
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '오늘의 특별 조언',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fortune['specialAdvice'] ?? '자신을 사랑하는 것부터 시작하세요.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmotionalStateTab(Map<String, dynamic>? emotionalState) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 현재 감정 상태
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 감정 상태',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  emotionalState?['current'] ?? '분석 중...',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                
                // 치유 진행도
                Row(
                  children: [
                    Icon(Icons.healing, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '치유 단계',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Use new healing progress widget
                HealingProgressWidget(
                  currentStage: emotionalState?['healing'],
                  progress: (emotionalState?['progress'],
                  onTap: () {
                    // Show detailed healing information
                    _showHealingDetails(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Emotion Radar Chart
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.radar, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '감정 분석',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: EmotionRadarChart(
                    emotions: {
                      'healing': (emotionalState?['progress'] ?? 0).toDouble(),
                      'acceptance': 65.0,
                      'growth': 70.0,
                      'peace': 55.0,
                      'hope': 80.0,
                      'strength': null,
                    },
                    size: 250,
                    primaryColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 오늘의 집중 사항
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 집중 사항',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildTodayFocusItem(
                  Icons.check_circle,
                  '오늘 해야 할 일',
                  widget.fortuneData['todaysFocus']?['action'] ?? '자신을 위한 시간 갖기',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                
                _buildTodayFocusItem(
                  Icons.cancel,
                  '오늘 피해야 할 것',
                  widget.fortuneData['todaysFocus']?['avoid'] ?? '과거에 집착하기',
                  Colors.red,
                ),
                const SizedBox(height: 12),
                
                _buildTodayFocusItem(
                  Icons.format_quote,
                  '오늘의 확언',
                  widget.fortuneData['todaysFocus']?['affirmation'] ?? '나는 충분히 사랑받을 자격이 있다',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRelationshipAnalysisTab(Map<String, dynamic>? analysis) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 이별 원인 분석
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '이별의 근본 원인',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  analysis?['whyItEnded'] ?? '분석 중...',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 배운 점
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '이 관계에서 배운 점',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  analysis?['lessonsLearned'] ?? '성장의 기회...',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 미해결 감정
          if (analysis?['unfinishedBusiness'] != null)
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '미해결된 감정들',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    analysis!['unfinishedBusiness'],
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildReunionPossibilityTab(Map<String, dynamic>? reunion) {
    final theme = Theme.of(context);
    final percentage = reunion?['percentage'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 재회 가능성 원형 차트
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Text(
                  '재회 가능성',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 20,
                        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProbabilityColor(percentage),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$percentage%',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getProbabilityColor(percentage),
                          ),
                        ),
                        Text(
                          _getProbabilityText(percentage),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 영향 요인들
          if (reunion?['factors'] != null) ...[
            // 긍정적 요인
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '긍정적 요인',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(reunion!['factors'][0] as List).map((factor) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              factor.toString(),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 부정적 요인
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.remove_circle, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        '부정적 요인',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(reunion!['factors'][1] as List).map((factor) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.close, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              factor.toString(),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // 조언
          if (reunion?['advice'] != null)
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reunion!['advice'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMovingForwardTab(Map<String, dynamic>? movingForward) {
    final theme = Theme.of(context);
    final readiness = movingForward?['readiness'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 새로운 시작 준비도
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rocket_launch, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '새로운 시작 준비도',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: readiness / 100,
                  minHeight: 20,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(readiness),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getReadinessText(readiness),
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      '$readiness%',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(readiness),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 다음 단계들
          if (movingForward?['nextSteps'] != null)
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stairs, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '앞으로 나아가기 위한 단계',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(movingForward!['nextSteps'] as List).asMap().entries.map((entry) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          
          // 치유 활동 추천
          if (widget.fortuneData['healingActivities'] != null)
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.pink),
                      const SizedBox(width: 8),
                      Text(
                        '추천 치유 활동',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (widget.fortuneData['healingActivities'] as List).map((activity) => 
                      Chip(
                        label: Text(activity.toString()),
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          
          // 예상 회복 기간
          if (movingForward?['timeline'] != null)
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '예상 회복 기간',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movingForward!['timeline'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHealingStages(int currentStage) {
    final stages = ['부정': '분노': '타협', '우울', '수용'];
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stages.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final stage = entry.value;
        final isCompleted = index <= currentStage;
        
        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              child: Center(
                child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCompleted 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
  
  Widget _buildTodayFocusItem(IconData icon, String title, String content, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Color _getProgressColor(num progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.orange;
    if (progress >= 40) return Colors.amber;
    return Colors.red;
  }
  
  Color _getProbabilityColor(num probability) {
    if (probability >= 70) return Colors.green;
    if (probability >= 40) return Colors.orange;
    return Colors.red;
  }
  
  String _getProbabilityText(num probability) {
    if (probability >= 70) return '높음';
    if (probability >= 40) return '보통';
    return '낮음';
  }
  
  String _getReadinessText(num readiness) {
    if (readiness >= 80) return '새로운 시작을 할 준비가 되었습니다';
    if (readiness >= 60) return '조금 더 시간이 필요합니다';
    if (readiness >= 40) return '아직 치유가 필요합니다';
    return '충분한 휴식이 필요합니다';
  }
  
  void _shareFortune() {
    // TODO: 공유 기능 구현
  }
  
  void _showHealingDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final emotionalState = widget.fortuneData['emotionalState'];
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '치유 과정 상세 정보',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      
                      // Stage details
                      _buildStageDetails(context, emotionalState?['healing'],
                      const SizedBox(height: 24),
                      
                      // Recommendations
                      Text(
                        '이 단계에서 추천하는 활동',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ..._getStageRecommendations(emotionalState?['healing'] ?? 1).map(
                        (rec) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, 
                                color: theme.colorScheme.primary, 
                                size: 20
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(rec)),
                            ],
                          ),
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
    );
  }
  
  Widget _buildStageDetails(BuildContext context, int stage) {
    final theme = Theme.of(context);
    final stageInfo = _getStageInfo(stage);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stageInfo['icon'],
                color: stageInfo['color'],
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stage}단계: ${stageInfo['name']}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    stageInfo['duration'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stageInfo['description'],
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _getStageInfo(int stage) {
    final stages = {
      1: {
        'name': '부정',
        'icon': Icons.block,
        'color': Colors.red,
        'duration': '보통 1-2주',
        'description': '이별의 현실을 받아들이기 어려워하는 시기입니다. "이건 실수일 거야", "다시 돌아올 거야"라는 생각이 들 수 있습니다.',
      },
      2: {
        'name': '분노',
        'icon': Icons.bolt,
        'color': Colors.orange,
        'duration': '보통 2-4주',
        'description': '상대방이나 자신에게 화가 나는 시기입니다. "왜 이렇게 됐을까", "내가 뭘 잘못했을까"라는 생각이 듭니다.',
      },
      3: {
        'name': '타협',
        'icon': Icons.handshake,
        'color': Colors.amber,
        'duration': '보통 1-2개월',
        'description': '"만약 내가 다르게 했다면..."이라는 생각을 하며 과거를 되돌리려 합니다.',
      },
      4: {
        'name': '우울',
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'duration': '보통 2-3개월',
        'description': '깊은 슬픔과 상실감을 느끼는 시기입니다. 이는 치유를 위한 필수적인 과정입니다.',
      },
      5: {
        'name': '수용',
        'icon': Icons.favorite,
        'color': Colors.green,
        'duration': '3개월 이후',
        'description': '이별을 받아들이고 새로운 시작을 준비하는 시기입니다. 평화로운 마음을 되찾게 됩니다.',
      },
    };
    
    return stages[stage] ?? stages[1]!;
  }
  
  List<String> _getStageRecommendations(int stage) {
    final recommendations = {
      1: [
        '친구나 가족과 시간 보내기',
        '일기 쓰기로 감정 표현하기',
        '충분한 휴식 취하기',
        '좋아하는 음악 듣기',
      ],
      2: [
        '운동으로 에너지 발산하기',
        '창의적인 활동 시도하기',
        '명상이나 요가 하기',
        '자연 속에서 산책하기',
      ],
      3: [
        '새로운 취미 시작하기',
        '자기계발 서적 읽기',
        '봉사활동 참여하기',
        '여행 계획 세우기',
      ],
      4: [
        '전문가 상담 고려하기',
        '예술 활동 참여하기',
        '건강한 식습관 유지하기',
        '충분한 수면 취하기',
      ],
      5: [
        '새로운 목표 설정하기',
        '사회 활동 늘리기',
        '자신에게 보상하기',
        '미래 계획 세우기',
      ],
    };
    
    return recommendations[stage] ?? recommendations[1]!;
  }
}