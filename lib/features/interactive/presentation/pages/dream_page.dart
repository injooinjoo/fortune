import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/providers/user_settings_provider.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';

// Import domain models
import '../../domain/models/dream_models.dart';

// Import providers
import '../providers/dream_providers.dart';

class DreamPage extends ConsumerStatefulWidget {
  const DreamPage({super.key});

  @override
  ConsumerState<DreamPage> createState() => _DreamPageState();
}

class _DreamPageState extends ConsumerState<DreamPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isWriting = false;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedTags = [];

  final List<String> _availableTags = [
    '가족', '친구', '연인', '동물', '자연', '물', '불', '하늘',
    '비행', '추락', '도망', '싸움', '죽음', '재물', '음식', '여행',
    '학교', '직장', '집', '차', '돈', '보물', '괴물', '유명인'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveDream() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      Toast.show(context, message: '제목과 내용을 모두 입력해주세요', type: ToastType.warning);
      return;
    }

    final newEntry = DreamEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      date: _selectedDate,
      tags: _selectedTags,
      luckScore: 0, // Will be calculated after analysis
    );

    ref.read(dreamEntriesProvider.notifier).addEntry(newEntry);
    
    setState(() {
      _isWriting = false;
      _titleController.clear();
      _contentController.clear();
      _selectedTags.clear();
    });

    Toast.show(context, message: '꿈 일기가 저장되었습니다', type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseFontSize = 16 * ref.watch(userSettingsProvider).fontScale;
    final dreamEntries = ref.watch(dreamEntriesProvider);

    return Scaffold(
      appBar: AppHeader(
        title: '꿈 일기',
        showBackButton: true,
        actions: [
          if (!_isWriting)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                setState(() {
                  _isWriting = true;
                });
              }),
        ],
      ),
      body: _isWriting
          ? _buildWritingView(theme, baseFontSize)
          : _buildMainView(theme, baseFontSize, dreamEntries),
    );
  }

  Widget _buildMainView(ThemeData theme, double fontSize, List<DreamEntry> entries) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: '내 꿈 일기'),
              Tab(text: '꿈 해석'),
            ],
          ),
        ),
        
        // Tab View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDreamList(theme, fontSize, entries),
              _buildDreamInterpretation(theme, fontSize),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDreamList(ThemeData theme, double fontSize, List<DreamEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/moon.json',
              width: 200,
              height: 200,
              repeat: true),
            const SizedBox(height: 24),
            Text(
              '아직 기록된 꿈이 없어요',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: fontSize + 4)),
            const SizedBox(height: 8),
            Text(
              '오늘 밤 꾼 꿈을 기록해보세요',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: fontSize,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildDreamCard(theme, fontSize, entry);
      },
    );
  }

  Widget _buildDreamCard(ThemeData theme, double fontSize, DreamEntry entry) {
    return GestureDetector(
      onTap: () {
        // Navigate to dream detail
        _showDreamDetail(entry);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.luckScore > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getLuckColor(entry.luckScore).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.luckScore}점',
                        style: TextStyle(
                          color: _getLuckColor(entry.luckScore),
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize - 2,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: fontSize,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.date.year}년 ${entry.date.month}월 ${entry.date.day}일',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: fontSize - 2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(width: 16),
                  if (entry.tags.isNotEmpty) ...[
                    Icon(
                      Icons.label_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.tags.take(3).join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: fontSize - 2,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDreamInterpretation(ThemeData theme, double fontSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'AI 꿈 해석',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: fontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '기록한 꿈을 선택하면\nAI가 상세하게 해석해드립니다',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: fontSize,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/interactive/dream-interpretation');
              },
              icon: const Icon(Icons.psychology_rounded),
              label: const Text('꿈 해몽 바로가기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingView(ThemeData theme, double fontSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Picker
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '날짜',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                NumericDateInput(
                  selectedDate: _selectedDate,
                  onDateChanged: (date) => setState(() => _selectedDate = date),
                  minDate: DateTime.now().subtract(const Duration(days: 365)),
                  maxDate: DateTime.now(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Title Input
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제목',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: '꿈의 제목을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content Input
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내용',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: fontSize),
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: '꿈의 내용을 자세히 기록해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tags Selection
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '태그',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: theme.colorScheme.primary);
                  }).toList()),
                ],
              ),
            ),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isWriting = false;
                      _titleController.clear();
                      _contentController.clear();
                      _selectedTags.clear();
                    });
                  },
                  child: const Text('취소')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveDream,
                  child: const Text('저장')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDreamDetail(DreamEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => DreamDetailSheet(entry: entry));
  }

  Color _getLuckColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}

class DreamDetailSheet extends ConsumerWidget {
  final DreamEntry entry;

  const DreamDetailSheet({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final baseFontSize = 16 * ref.watch(userSettingsProvider).fontScale;
    final analysisAsync = ref.watch(dreamAnalysisProvider(entry.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(

        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date
                  Text(
                    entry.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: baseFontSize + 4,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.date.year}년 ${entry.date.month}월 ${entry.date.day}일',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: baseFontSize - 2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 20),
                  // Content
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '꿈 내용',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: baseFontSize + 2,
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          entry.content,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: baseFontSize,
                            height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  if (entry.tags.isNotEmpty) ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '태그',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: baseFontSize + 2,
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: theme.colorScheme.primaryContainer);
                            }).toList()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Analysis
                  analysisAsync.when(
                    data: (analysis) {
                      if (analysis == null) return const SizedBox.shrink();
                      return GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                            theme.colorScheme.secondary.withValues(alpha: 0.1)]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'AI 꿈 해석',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: baseFontSize + 2,
                                    fontWeight: FontWeight.bold))]),
                            const SizedBox(height: 16),
                            // Dream Type and Score
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                                    analysis.dreamType,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: baseFontSize - 2)),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getLuckColor(analysis.overallLuck).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '운세 ${analysis.overallLuck}점',
                                    style: TextStyle(
                                      color: _getLuckColor(analysis.overallLuck),
                                      fontWeight: FontWeight.bold,
                                      fontSize: baseFontSize - 2)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Interpretation
                            Text(
                              analysis.interpretation,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: baseFontSize,
                                height: 1.6)),
                            const SizedBox(height: 16),
                            // Symbols
                            Text(
                              '주요 상징',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: baseFontSize,
                                fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: analysis.symbols.map((symbol) {
                                return Chip(
                                  label: Text(symbol),
                                  backgroundColor: theme.colorScheme.secondaryContainer);
                              }).toList()),
                            const SizedBox(height: 16),
                            // Advice
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.tertiary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_rounded,
                                    color: theme.colorScheme.tertiary,
                                    size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      analysis.advice,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: baseFontSize - 1)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const LoadingStateWidget(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share dream
                      Toast.show(context, message: '공유 기능은 준비 중입니다', type: ToastType.info);
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('공유하기')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(dreamEntriesProvider.notifier).deleteEntry(entry.id);
                      Navigator.of(context).pop();
                      Toast.show(context, message: '꿈 일기가 삭제되었습니다', type: ToastType.success);
                    },
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('삭제'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLuckColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}