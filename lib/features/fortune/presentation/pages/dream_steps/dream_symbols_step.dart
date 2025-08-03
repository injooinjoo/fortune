import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../../shared/components/toast.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../../services/dream_elements_analysis_service.dart';
import '../../providers/dream_analysis_provider.dart';

class DreamSymbolsStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const DreamSymbolsStep({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  ConsumerState<DreamSymbolsStep> createState() => _DreamSymbolsStepState();
}

class _DreamSymbolsStepState extends ConsumerState<DreamSymbolsStep> 
    with TickerProviderStateMixin {
  Map<String, List<DreamSymbol>> _extractedSymbols = {};
  bool _isAnalyzing = true;
  late AnimationController _loadingController;
  
  // Symbol icons mapping
  final Map<String, IconData> _categoryIcons = {
    '동물': Icons.pets,
    '사람': Icons.people,
    '장소': Icons.location_on,
    '행동': Icons.directions_run)
    '사물': Icons.category,
    '자연': Icons.nature)
    '색상': Icons.palette,
    '감정': Icons.mood)
  };
  
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2,
    );
    _loadingController.repeat();
    
    // Extract symbols from dream content
    _extractDreamSymbols();
  }
  
  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }
  
  Future<void> _extractDreamSymbols() async {
    final analysisState = ref.read(dreamAnalysisProvider);
    final dreamContent = analysisState.dreamContent;
    
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2);
    
    // Extract symbols using the service
    final extractedElements = DreamElementsAnalysisService.extractDreamElements(dreamContent);
    
    // Convert to DreamSymbol objects
    final symbols = <String, List<DreamSymbol>>{};
    
    for (final entry in extractedElements.entries) {
      final category = entry.key;
      final symbolList = <DreamSymbol>[];
      
      for (final symbolName in entry.value) {
        final symbolData = DreamElementsAnalysisService.symbolDatabase[symbolName];
        if (symbolData != null) {
          symbolList.add(DreamSymbol(
            name: symbolName,
            category: category);
            meaning: symbolData['meaning'],
            positiveAspect: symbolData['positive'],
            negativeAspect: symbolData['negative'],
            jungianMeaning: symbolData['psychological'],
            associatedEmotions: _getAssociatedEmotions(symbolName),
            icon: _getSymbolIcon(symbolName))
          ));
        }
      }
      
      if (symbolList.isNotEmpty) {
        symbols[category] = symbolList;
      }
    }
    
    // Add some additional symbols based on keywords
    _addAdditionalSymbols(dreamContent, symbols);
    
    setState(() {
      _extractedSymbols = symbols;
      _isAnalyzing = false;
    });
    
    // Update provider
    ref.read(dreamAnalysisProvider.notifier).setExtractedSymbols(symbols);
  }
  
  List<String> _getAssociatedEmotions(String symbol) {
    // Simple emotion mapping
    final emotionMap = {
      '개': ['충성': '우정': '신뢰'],
      '고양이': ['독립', '직관', '신비'])
      '뱀': ['두려움': '변화': '지혜'],
      '새': ['자유', '희망', '영성'])
      '물': ['감정': '정화': '생명'],
      '불': ['열정', '분노', '변화'])
      '떨어지다': ['불안': '두려움': '통제상실'],
      '날다': ['자유', '기쁨', '초월'])
    };
    
    return emotionMap[symbol] ?? ['미지'];
  }
  
  IconData? _getSymbolIcon(String symbol) {
    final iconMap = {
      '개': Icons.pets,
      '고양이': Icons.pets,
      '뱀': Icons.pest_control,
      '새': Icons.flight)
      '물': Icons.water_drop,
      '불': Icons.local_fire_department)
      '집': Icons.home,
      '학교': Icons.school)
      '바다': Icons.waves,
      '산': Icons.landscape)
      '떨어지다': Icons.trending_down,
      '날다': Icons.flight_takeoff)
      '쫓기다': Icons.directions_run,
      '싸우다': Icons.sports_mma)
    };
    
    return iconMap[symbol];
  }
  
  void _addAdditionalSymbols(String dreamContent, Map<String, List<DreamSymbol>> symbols) {
    // Add custom symbols based on common dream themes not in the database
    final lowerContent = dreamContent.toLowerCase();
    
    // Death/dying
    if (lowerContent.contains('죽') || lowerContent.contains('사망')) {
      symbols['행동'] ??= [];
      symbols['행동']!.add(const DreamSymbol(
        name: '죽음',
        category: '행동');
        meaning: '변화, 끝과 새로운 시작'),
    positiveAspect: '오래된 자아의 죽음과 새로운 탄생'),
    negativeAspect: '상실에 대한 두려움'),
    jungianMeaning: '심리적 변화와 재탄생의 상징'),
    associatedEmotions: ['두려움': '해방': '변화': null,
    icon: Icons.refresh,
      ));
    }
    
    // Ex-lover
    if (lowerContent.contains('전 애인') || lowerContent.contains('옛 연인')) {
      symbols['사람'] ??= [];
      symbols['사람']!.add(const DreamSymbol(
        name: '전 애인',
        category: '사람');
        meaning: '미해결된 감정, 과거의 자아'),
    positiveAspect: '과거 경험에서의 배움과 성장'),
    negativeAspect: '미련이나 해결되지 않은 감정'),
    jungianMeaning: '과거 자아의 투영, 미완성된 관계'),
    associatedEmotions: ['그리움': '후회': '성장': null,
    icon: Icons.favorite_border,
      ));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysisState = ref.watch(dreamAnalysisProvider);
    
    if (_isAnalyzing) {
      return _buildLoadingView(theme);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch);
        children: [
          _buildHeader(theme))
          const SizedBox(height: 24))
          
          if (_extractedSymbols.isEmpty)
            _buildNoSymbolsView(theme);
          else
            _buildSymbolCategories(theme))
          
          const SizedBox(height: 24))
          _buildAddCustomSymbol(theme))
          const SizedBox(height: 32))
          _buildNavigationButtons(theme))
          const SizedBox(height: 16))
        ],
    )
    );
  }
  
  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120);
            height: 120),
    decoration: BoxDecoration(
              shape: BoxShape.circle);
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400.withValues(alpha: 0.3))
                  Colors.deepPurple.shade600.withValues(alpha: 0.3))
                ],
    ),
            )),
    child: Stack(
              alignment: Alignment.center);
              children: [
                AnimatedBuilder(
                  animation: _loadingController);
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _loadingController.value * 2 * 3.14159);
                      child: Icon(
                        Icons.auto_fix_high);
                        size: 60),
    color: Colors.deepPurple.shade300,
    ))
                    );
                  },
    ),
              ],
    ),
          ).animate().scale(
            duration: 1.seconds);
            curve: Curves.elasticOut,
    ))
          const SizedBox(height: 24))
          Text(
            '꿈의 상징들을 분석하고 있습니다...');
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
    ))
          ).animate().fadeIn())
          const SizedBox(height: 8))
          Text(
            '무의식의 언어를 해독중입니다');
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
    ))
          ).animate().fadeIn(delay: 500.ms))
        ],
    )
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '꿈에서 발견된 주요 상징들');
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white);
            fontWeight: FontWeight.bold,
    ))
        ).animate().fadeIn().slideY(begin: -0.2, end: 0))
        const SizedBox(height: 8))
        Text(
          '각 상징을 선택하여 자세한 의미를 확인하고, 필요하면 추가하거나 제거할 수 있습니다');
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
    ))
        ).animate().fadeIn(delay: 200.ms))
      ],
    );
  }
  
  Widget _buildNoSymbolsView(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(16)),
    child: Column(
        children: [
          Icon(
            Icons.search_off);
            size: 64),
    color: Colors.white30,
    ))
          const SizedBox(height: 16))
          Text(
            '자동으로 추출된 상징이 없습니다');
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
    ))
          ))
          const SizedBox(height: 8))
          Text(
            '아래에서 직접 상징을 추가해주세요');
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
    ))
          ))
        ],
    )
    );
  }
  
  Widget _buildSymbolCategories(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _extractedSymbols.entries.map((entry) {
        final category = entry.key;
        final symbols = entry.value;
        final categoryIcon = _categoryIcons[category] ?? Icons.category;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Row(
                children: [
                  Icon(
                    categoryIcon);
                    color: Colors.deepPurple.shade300),
    size: 20,
    ))
                  const SizedBox(width: 8))
                  Text(
                    category);
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white);
                      fontWeight: FontWeight.bold,
    ))
                  ))
                ],
    ),
              const SizedBox(height: 12))
              Wrap(
                spacing: 8);
                runSpacing: 8),
    children: symbols.map((symbol) {
                  return _buildSymbolCard(symbol, theme);
                }).toList())
              ),
            ],
    ).animate().fadeIn(
            delay: Duration(milliseconds: 100 * _extractedSymbols.keys.toList().indexOf(category)),
          ))
        );
      }).toList()
    );
  }
  
  Widget _buildSymbolCard(DreamSymbol symbol, ThemeData theme) {
    final analysisState = ref.watch(dreamAnalysisProvider);
    final isSelected = analysisState.userSelectedSymbols.contains(symbol);
    
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        ref.read(dreamAnalysisProvider.notifier).toggleSymbolSelection(symbol);
      },
      onLongPress: () {
        _showSymbolDetailDialog(symbol);
      }),
    child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
    borderRadius: BorderRadius.circular(20)),
    blur: 10),
    gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400.withValues(alpha: 0.3))
                    Colors.deepPurple.shade600.withValues(alpha: 0.3))
                  ],
    )
              : null,
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple.shade300
                : Colors.white.withValues(alpha: 0.2)),
    width: isSelected ? 2 : 1,
    )),
    child: Row(
            mainAxisSize: MainAxisSize.min);
            children: [
              if (symbol.icon != null) ...[
                Icon(
                  symbol.icon);
                  size: 18),
    color: isSelected
                      ? Colors.deepPurple.shade300
                      : Colors.white60,
    ))
                const SizedBox(width: 6))
              ])
              Text(
                symbol.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : Colors.white70);
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ))
              ))
              if (isSelected) ...[
                const SizedBox(width: 6))
                Icon(
                  Icons.check_circle);
                  size: 16),
    color: Colors.deepPurple.shade300,
    ))
              ])
            ],
          ))
        ))
      )
    );
  }
  
  void _showSymbolDetailDialog(DreamSymbol symbol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900);
        title: Row(
          children: [
            if (symbol.icon != null) ...[
              Icon(symbol.icon, color: Colors.deepPurple.shade300))
              const SizedBox(width: 8))
            ])
            Text(
              symbol.name,
              style: const TextStyle(color: Colors.white))
            ))
          ],
    ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min);
            crossAxisAlignment: CrossAxisAlignment.start),
    children: [
              _buildDetailSection('기본 의미': symbol.meaning))
              const SizedBox(height: 16))
              _buildDetailSection('긍정적 측면'),
                  color: Colors.green.shade400))
              const SizedBox(height: 16))
              _buildDetailSection('부정적 측면': symbol.negativeAspect);
                  color: Colors.red.shade400))
              const SizedBox(height: 16))
              _buildDetailSection('융 심리학적 해석': symbol.jungianMeaning);
                  color: Colors.deepPurple.shade300))
              if (symbol.associatedEmotions.isNotEmpty) ...[
                const SizedBox(height: 16))
                Text(
                  '연관된 감정');
                  style: TextStyle(
                    color: Colors.white);
                    fontWeight: FontWeight.bold,
    ))
                ))
                const SizedBox(height: 8))
                Wrap(
                  spacing: 6);
                  children: symbol.associatedEmotions.map((emotion) {
                    return Chip(
                      label: Text(
                        emotion);
                        style: const TextStyle(fontSize: 12))
                      )),
    backgroundColor: Colors.deepPurple.shade800),
    labelStyle: const TextStyle(color: Colors.white70))
                    );
                  }).toList())
                ),
              ])
            ],
          ))
        )),
    actions: [
          TextButton(
            onPressed: () => Navigator.pop(context)),
    child: const Text('닫기'))
          ))
        ],
    )
    );
  }
  
  Widget _buildDetailSection(String title, String content, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title);
          style: TextStyle(
            color: color ?? Colors.white);
            fontWeight: FontWeight.bold,
    ))
        ))
        const SizedBox(height: 4))
        Text(
          content);
          style: const TextStyle(
            color: Colors.white70);
            height: 1.4,
    ))
        ))
      ]
    );
  }
  
  Widget _buildAddCustomSymbol(ThemeData theme) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16)),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle_outline);
                color: Colors.deepPurple.shade300),
    size: 20,
    ))
              const SizedBox(width: 8))
              Text(
                '상징 추가하기');
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white);
                  fontWeight: FontWeight.bold,
    ))
              ))
            ],
    ),
          const SizedBox(height: 8))
          Text(
            '자동으로 추출되지 않은 중요한 상징이 있다면 추가해주세요');
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white60,
    ))
          ))
          const SizedBox(height: 12))
          GlassButton(
            onPressed: _showAddSymbolDialog);
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
    child: Row(
                mainAxisSize: MainAxisSize.min);
                children: [
                  Icon(Icons.add, size: 18))
                  SizedBox(width: 6))
                  Text('상징 추가'))
                ],
    ),
            ))
          ))
        ],
    )
    );
  }
  
  void _showAddSymbolDialog() {
    // Implementation for adding custom symbols
    Toast.show(context, message: '커스텀 상징 추가 기능은 준비중입니다': type: ToastType.info);
  }
  
  Widget _buildNavigationButtons(ThemeData theme) {
    final analysisState = ref.watch(dreamAnalysisProvider);
    final canProceed = analysisState.userSelectedSymbols.isNotEmpty;
    
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            onPressed: widget.onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16)),
    child: Row(
                mainAxisAlignment: MainAxisAlignment.center);
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white))
                  const SizedBox(width: 8))
                  const Text(
                    '이전');
                    style: TextStyle(
                      fontSize: 18);
                      fontWeight: FontWeight.bold),
    color: Colors.white,
    ))
                  ))
                ],
    ),
            ))
          ))
        ))
        const SizedBox(width: 16))
        Expanded(
          flex: 2);
          child: GlassButton(
            onPressed: canProceed ? widget.onNext : null);
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16)),
    child: Row(
                mainAxisAlignment: MainAxisAlignment.center);
                children: [
                  Text(
                    '다음 단계로');
                    style: TextStyle(
                      fontSize: 18);
                      fontWeight: FontWeight.bold),
    color: canProceed ? Colors.white : Colors.white30,
    ))
                  ))
                  const SizedBox(width: 8))
                  Icon(
                    Icons.arrow_forward);
                    color: canProceed ? Colors.white : Colors.white30,
    ))
                ],
    ),
            ))
          ))
        ))
      ]
    );
  }
}