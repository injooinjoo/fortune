# 🛠️ Fortune UI 구현 가이드

> **최종 업데이트**: 2025년 1월 16일
> **대상**: Fortune 앱 개발자
> **연관 문서**: 
> - [FORTUNE_RESULT_DESIGN_SYSTEM.md](./FORTUNE_RESULT_DESIGN_SYSTEM.md)
> - [FORTUNE_TYPE_SPECIFIC_DESIGNS.md](./FORTUNE_TYPE_SPECIFIC_DESIGNS.md)

## 📚 목차

1. [기본 설정](#기본-설정)
2. [공통 컴포넌트 구현](#공통-컴포넌트-구현)
3. [운세별 UI 구현 예제](#운세별-ui-구현-예제)
4. [애니메이션 구현](#애니메이션-구현)
5. [성능 최적화](#성능-최적화)
6. [테스트 가이드](#테스트-가이드)

---

## 🚀 기본 설정

### 필요한 패키지

```yaml
dependencies:
  flutter_animate: ^4.3.0
  fl_chart: ^0.65.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  percent_indicator: ^4.2.3
  carousel_slider: ^4.2.1
  confetti: ^0.7.0
```

### 테마 설정

```dart
// lib/core/theme/fortune_theme.dart
class FortuneTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: Brightness.light,
    ),
    fontFamily: 'Pretendard',
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: Brightness.dark,
      background: const Color(0xFF0F0A1F),
    ),
    fontFamily: 'Pretendard',
  );
}
```

---

## 🧩 공통 컴포넌트 구현

### 1. FortuneCard 기본 구현

```dart
// lib/presentation/widgets/fortune_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FortuneCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const FortuneCard({
    Key? key,
    required this.child,
    required this.gradientColors,
    this.onTap,
    this.padding,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
```

### 2. 점수 표시 컴포넌트

```dart
// lib/presentation/widgets/fortune_score_display.dart
class FortuneScoreDisplay extends StatefulWidget {
  final int score;
  final String label;
  final List<Color> colors;
  final double size;

  const FortuneScoreDisplay({
    Key? key,
    required this.score,
    required this.label,
    required this.colors,
    this.size = 150,
  }) : super(key: key);

  @override
  State<FortuneScoreDisplay> createState() => _FortuneScoreDisplayState();
}

class _FortuneScoreDisplayState extends State<FortuneScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
          ),
          // 프로그레스 원
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularProgressPainter(
                  progress: _progressAnimation.value,
                  gradientColors: widget.colors,
                  strokeWidth: 12,
                ),
              );
            },
          ),
          // 점수 텍스트
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Text(
                    '${_scoreAnimation.value.toInt()}',
                    style: TextStyle(
                      fontSize: widget.size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.first,
                    ),
                  );
                },
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.size * 0.1,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 원형 프로그레스 페인터
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.gradientColors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: gradientColors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
```

### 3. 행운 아이템 그리드

```dart
// lib/presentation/widgets/lucky_items_grid.dart
class LuckyItemsGrid extends StatelessWidget {
  final Map<String, dynamic> items;
  final Color primaryColor;

  const LuckyItemsGrid({
    Key? key,
    required this.items,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items.entries.elementAt(index);
        return _LuckyItemCard(
          itemKey: entry.key,
          itemValue: entry.value.toString(),
          color: primaryColor,
          delay: index * 100,
        );
      },
    );
  }
}

class _LuckyItemCard extends StatelessWidget {
  final String itemKey;
  final String itemValue;
  final Color color;
  final int delay;

  const _LuckyItemCard({
    required this.itemKey,
    required this.itemValue,
    required this.color,
    required this.delay,
  });

  IconData _getIcon() {
    switch (itemKey.toLowerCase()) {
      case '숫자':
      case 'number':
        return Icons.looks_one;
      case '색상':
      case 'color':
        return Icons.palette;
      case '방향':
      case 'direction':
        return Icons.explore;
      case '시간':
      case 'time':
        return Icons.access_time;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  itemKey,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  itemValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay))
      .fadeIn()
      .slideX(begin: 0.2, end: 0);
  }
}
```

---

## 🎯 운세별 UI 구현 예제

### 1. 일일 운세 페이지

```dart
// lib/features/fortune/presentation/pages/daily_fortune_result_page.dart
class DailyFortuneResultPage extends ConsumerWidget {
  final DailyFortune fortune;

  const DailyFortuneResultPage({
    Key? key,
    required this.fortune,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 커스텀 앱바
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.today,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 콘텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 전체 점수
                  FortuneScoreDisplay(
                    score: fortune.overallScore,
                    label: '오늘의 운세',
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).animate()
                    .scale(delay: 200.ms),
                  
                  const SizedBox(height: 32),
                  
                  // 시간대별 운세
                  _buildTimelineSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // 분야별 점수
                  _buildCategoryScores(context),
                  
                  const SizedBox(height: 24),
                  
                  // 행운 아이템
                  _buildLuckyItems(context),
                  
                  const SizedBox(height: 24),
                  
                  // 조언
                  _buildAdviceSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineSection(BuildContext context) {
    return FortuneCard(
      gradientColors: [
        Colors.blue.shade400,
        Colors.blue.shade600,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '시간대별 운세',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            child: TimelineChart(
              data: fortune.hourlyScores,
              lineColor: Colors.white,
              fillColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryScores(BuildContext context) {
    return Column(
      children: fortune.categoryScores.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CategoryScoreBar(
            category: entry.key,
            score: entry.value,
            color: _getCategoryColor(entry.key),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildLuckyItems(BuildContext context) {
    return FortuneCard(
      gradientColors: [
        Colors.amber.shade400,
        Colors.amber.shade600,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 행운 아이템',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LuckyItemsGrid(
            items: fortune.luckyItems,
            primaryColor: Colors.amber,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdviceSection(BuildContext context) {
    return FortuneCard(
      gradientColors: [
        Colors.green.shade400,
        Colors.green.shade600,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 조언',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fortune.advice.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 * entry.key))
              .fadeIn()
              .slideX(begin: 0.2, end: 0);
          }).toList(),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case '애정운':
        return Colors.pink;
      case '금전운':
        return Colors.green;
      case '건강운':
        return Colors.orange;
      case '직업운':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
}
```

### 2. MBTI 운세 결과

```dart
// lib/features/fortune/presentation/pages/mbti_fortune_result_page.dart
class MBTIFortuneResultPage extends StatefulWidget {
  final MBTIFortune fortune;
  
  const MBTIFortuneResultPage({
    Key? key,
    required this.fortune,
  }) : super(key: key);
  
  @override
  State<MBTIFortuneResultPage> createState() => _MBTIFortuneResultPageState();
}

class _MBTIFortuneResultPageState extends State<MBTIFortuneResultPage> {
  int _selectedTabIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // MBTI 타입 헤더
          SliverToBoxAdapter(
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getMBTIColors(widget.fortune.mbtiType),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        widget.fortune.mbtiType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.fortune.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.fortune.shortDescription,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 탭 메뉴
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              tabs: ['오늘의 운세', '인지 기능', '조언'],
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
          
          // 탭 콘텐츠
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildTodaysFortune();
      case 1:
        return _buildCognitiveFunctions();
      case 2:
        return _buildAdvice();
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildTodaysFortune() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 전체 점수
          FortuneScoreDisplay(
            score: widget.fortune.todayScore,
            label: '오늘의 시너지',
            colors: _getMBTIColors(widget.fortune.mbtiType),
            size: 180,
          ),
          
          const SizedBox(height: 32),
          
          // 상세 설명
          FortuneCard(
            gradientColors: [
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
            child: Text(
              widget.fortune.todaysFortune,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 행운의 활동
          _buildLuckyActivities(),
        ],
      ),
    );
  }
  
  Widget _buildCognitiveFunctions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.fortune.cognitiveFunctions.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CognitiveFunctionBar(
              function: entry.key,
              percentage: entry.value,
              color: _getFunctionColor(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildAdvice() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 강점
          _buildAdviceCard(
            title: '오늘의 강점',
            content: widget.fortune.todaysStrengths,
            icon: Icons.star,
            color: Colors.amber,
          ),
          
          const SizedBox(height: 16),
          
          // 주의사항
          _buildAdviceCard(
            title: '주의할 점',
            content: widget.fortune.todaysWeaknesses,
            icon: Icons.warning,
            color: Colors.orange,
          ),
          
          const SizedBox(height: 16),
          
          // 추천 활동
          _buildAdviceCard(
            title: '추천 활동',
            content: widget.fortune.recommendations,
            icon: Icons.lightbulb,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
  
  List<Color> _getMBTIColors(String type) {
    // MBTI 타입별 색상 정의
    final colorMap = {
      'INTJ': [Colors.purple.shade600, Colors.purple.shade800],
      'INTP': [Colors.indigo.shade600, Colors.indigo.shade800],
      'ENTJ': [Colors.red.shade600, Colors.red.shade800],
      'ENTP': [Colors.orange.shade600, Colors.orange.shade800],
      // ... 나머지 타입들
    };
    
    return colorMap[type] ?? [Colors.blue.shade600, Colors.blue.shade800];
  }
}
```

---

## 🎬 애니메이션 구현

### 1. 페이지 전환 애니메이션

```dart
// lib/presentation/animations/page_transitions.dart
class FortunePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  
  FortunePageRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);
  
  @override
  Color? get barrierColor => null;
  
  @override
  String? get barrierLabel => null;
  
  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
  
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
  
  @override
  bool get maintainState => true;
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}
```

### 2. 인터랙티브 애니메이션

```dart
// lib/presentation/animations/interactive_animations.dart
class PulsatingWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  
  const PulsatingWidget({
    Key? key,
    required this.child,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);
  
  @override
  State<PulsatingWidget> createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
```

---

## ⚡ 성능 최적화

### 1. 이미지 최적화

```dart
// lib/presentation/widgets/optimized_fortune_image.dart
class OptimizedFortuneImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  const OptimizedFortuneImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.error),
        ),
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
      );
    }
  }
}
```

### 2. 리스트 최적화

```dart
// lib/presentation/widgets/fortune_list_optimized.dart
class OptimizedFortuneList extends StatelessWidget {
  final List<Fortune> fortunes;
  final Widget Function(BuildContext, Fortune, int) itemBuilder;
  
  const OptimizedFortuneList({
    Key? key,
    required this.fortunes,
    required this.itemBuilder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fortunes.length,
      itemExtent: 200, // 고정 높이로 성능 향상
      cacheExtent: 400, // 캐시 영역 확대
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, fortunes[index], index),
        );
      },
    );
  }
}
```

---

## 🧪 테스트 가이드

### 1. 위젯 테스트

```dart
// test/widgets/fortune_score_display_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('FortuneScoreDisplay animates correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FortuneScoreDisplay(
            score: 85,
            label: 'Test Score',
            colors: [Colors.blue, Colors.green],
          ),
        ),
      ),
    );
    
    // 초기 상태 확인
    expect(find.text('0'), findsOneWidget);
    
    // 애니메이션 진행
    await tester.pump(const Duration(milliseconds: 750));
    
    // 중간 상태 확인
    final Text scoreText = tester.widget(find.byType(Text).first);
    expect(int.parse(scoreText.data!), greaterThan(0));
    expect(int.parse(scoreText.data!), lessThan(85));
    
    // 애니메이션 완료
    await tester.pumpAndSettle();
    
    // 최종 상태 확인
    expect(find.text('85'), findsOneWidget);
  });
}
```

### 2. 골든 테스트

```dart
// test/golden/fortune_cards_test.dart
void main() {
  testWidgets('Fortune cards golden test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FortuneTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: FortuneCard(
              gradientColors: [Colors.blue, Colors.purple],
              child: const Text(
                'Fortune Content',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
    
    await expectLater(
      find.byType(FortuneCard),
      matchesGoldenFile('goldens/fortune_card.png'),
    );
  });
}
```

---

## 📋 체크리스트

### 구현 전 확인사항
- [ ] 디자인 시스템 문서 숙지
- [ ] 필요한 패키지 설치
- [ ] 테마 설정 완료
- [ ] 애셋 파일 준비

### 구현 중 확인사항
- [ ] Glass morphism 효과 적용
- [ ] 애니메이션 구현
- [ ] 반응형 레이아웃
- [ ] 다크 모드 지원
- [ ] 접근성 고려

### 구현 후 확인사항
- [ ] 성능 테스트
- [ ] 위젯 테스트 작성
- [ ] 골든 테스트 실행
- [ ] 코드 리뷰
- [ ] 문서 업데이트

---

> 이 가이드는 Fortune 앱의 UI 구현을 위한 실용적인 예제와 베스트 프랙티스를 제공합니다. 새로운 운세 타입을 추가할 때 이 가이드를 참조하여 일관된 사용자 경험을 제공하세요.