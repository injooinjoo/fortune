import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../presentation/providers/font_size_provider.dart';

// Fortune history provider
final fortuneHistoryProvider = FutureProvider.autoDispose<List<FortuneHistory>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
    final response = await apiClient.get(ApiEndpoints.fortuneHistory);
    
    if (response.data['success'] == true) {
      final historyList = response.data['data'] as List;
      return historyList.map((item) => FortuneHistory.fromJson(item)).toList();
    } else {
      throw Exception(response.data['error'] ?? '운세 기록을 불러올 수 없습니다');
    }
  } catch (e) {
    throw Exception('운세 기록 조회 실패: $e');
  }
});

// Fortune history model
class FortuneHistory {
  final String id;
  final String fortuneType;
  final String title;
  final DateTime createdAt;
  final Map<String, dynamic> summary;
  final int tokenUsed;

  FortuneHistory({
    required this.id,
    required this.fortuneType,
    required this.title,
    required this.createdAt,
    required this.summary,
    required this.tokenUsed,
  });

  factory FortuneHistory.fromJson(Map<String, dynamic> json) {
    return FortuneHistory(
      id: json['id'] ?? '',
      fortuneType: json['fortune_type'] ?? '',
      title: json['title'] ?? '운세',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      summary: json['summary'] ?? {},
      tokenUsed: json['token_used'] ?? 1,
    );
  }
}

class FortuneHistoryPage extends ConsumerStatefulWidget {
  const FortuneHistoryPage({super.key});

  @override
  ConsumerState<FortuneHistoryPage> createState() => _FortuneHistoryPageState();
}

class _FortuneHistoryPageState extends ConsumerState<FortuneHistoryPage> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'daily', 'love', 'wealth', 'career', 'health'];
  
  List<FortuneHistory> _filterHistory(List<FortuneHistory> history) {
    if (_selectedFilter == 'all') return history;
    
    return history.where((item) {
      switch (_selectedFilter) {
        case 'daily':
          return item.fortuneType.contains('daily') || 
                 item.fortuneType.contains('today') || 
                 item.fortuneType.contains('tomorrow');
        case 'love':
          return item.fortuneType.contains('love') || 
                 item.fortuneType.contains('compatibility') || 
                 item.fortuneType.contains('marriage');
        case 'wealth':
          return item.fortuneType.contains('wealth') || 
                 item.fortuneType.contains('investment') || 
                 item.fortuneType.contains('business');
        case 'career':
          return item.fortuneType.contains('career') || 
                 item.fortuneType.contains('job') || 
                 item.fortuneType.contains('employment');
        case 'health':
          return item.fortuneType.contains('health') || 
                 item.fortuneType.contains('biorhythm');
        default:
          return true;
      }
    }).toList();
  }

  String _getFortuneIcon(String fortuneType) {
    if (fortuneType.contains('love') || fortuneType.contains('compatibility')) return '❤️';
    if (fortuneType.contains('wealth') || fortuneType.contains('investment')) return '💰';
    if (fortuneType.contains('career') || fortuneType.contains('job')) return '💼';
    if (fortuneType.contains('health')) return '🏥';
    if (fortuneType.contains('daily') || fortuneType.contains('today')) return '☀️';
    if (fortuneType.contains('mbti')) return '🧠';
    if (fortuneType.contains('zodiac')) return '✨';
    return '🔮';
  }

  Color _getFortuneColor(String fortuneType) {
    if (fortuneType.contains('love') || fortuneType.contains('compatibility')) return Colors.pink;
    if (fortuneType.contains('wealth') || fortuneType.contains('investment')) return Colors.green;
    if (fortuneType.contains('career') || fortuneType.contains('job')) return Colors.blue;
    if (fortuneType.contains('health')) return Colors.orange;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final historyAsync = ref.watch(fortuneHistoryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '운세 기록',
              showBackButton: true,
              showTokenBalance: true,
            ),
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(child: LoadingIndicator(size: 60)),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '운세 기록을 불러올 수 없습니다',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        GlassButton(
                          onPressed: () => ref.invalidate(fortuneHistoryProvider),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text('다시 시도'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (history) {
                  final filteredHistory = _filterHistory(history);
                  
                  return Column(
                    children: [
                      // Filter chips
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = _selectedFilter == filter;
                            final filterLabels = {
                              'all': '전체',
                              'daily': '일일 운세',
                              'love': '연애/결혼',
                              'wealth': '재물/투자',
                              'career': '직업/사업',
                              'health': '건강',
                            };
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  filterLabels[filter] ?? filter,
                                  style: TextStyle(fontSize: 14 * fontScale),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                                checkmarkColor: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // History list
                      Expanded(
                        child: filteredHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 64,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '운세 기록이 없습니다',
                                      style: TextStyle(
                                        fontSize: 18 * fontScale,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredHistory.length,
                                itemBuilder: (context, index) {
                                  final item = filteredHistory[index];
                                  final color = _getFortuneColor(item.fortuneType);
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to detail view if needed
                                        Toast.show(
                                          context,
                                          message: '상세 보기는 준비 중입니다',
                                          type: ToastType.info,
                                        );
                                      },
                                      child: GlassContainer(
                                        gradient: LinearGradient(
                                          colors: [
                                            color.withValues(alpha: 0.1),
                                            color.withValues(alpha: 0.05),
                                          ],
                                        ),
                                        child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Icon
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getFortuneIcon(item.fortuneType),
                                                  style: TextStyle(fontSize: 24),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontSize: 16 * fontScale,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    DateFormat('yyyy년 MM월 dd일 HH:mm').format(item.createdAt),
                                                    style: TextStyle(
                                                      fontSize: 12 * fontScale,
                                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                                    ),
                                                  ),
                                                  if (item.summary.isNotEmpty) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      item.summary['brief'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 14 * fontScale,
                                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            
                                            // Token info
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.token,
                                                        size: 14,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${item.tokenUsed}',
                                                        style: TextStyle(
                                                          fontSize: 12 * fontScale,
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.colorScheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Icon(
                                                  Icons.chevron_right,
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}