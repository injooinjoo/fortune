import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/celebrity_provider.dart';
import '../../../services/celebrity_crawling_service.dart';
import '../../../core/components/app_card.dart';
import '../../../core/widgets/unified_button.dart';
import '../../../core/widgets/unified_button_enums.dart';
import '../../../core/design_system/design_system.dart';

class CelebrityCrawlingPage extends ConsumerStatefulWidget {
  const CelebrityCrawlingPage({super.key});

  @override
  ConsumerState<CelebrityCrawlingPage> createState() =>
      _CelebrityCrawlingPageState();
}

class _CelebrityCrawlingPageState extends ConsumerState<CelebrityCrawlingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crawlingState = ref.watch(crawlingResultProvider);
    final crawlingStats = ref.watch(crawlingStatsProvider);

    return Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: AppBar(
        title: const Text(
          '유명인 정보 크롤링',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: context.colors.border,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 카드
            _buildStatsCard(crawlingStats),
            const SizedBox(height: 24),

            // 단일 크롤링 섹션
            _buildSingleCrawlingSection(crawlingState),
            const SizedBox(height: 32),

            // 일괄 크롤링 섹션
            _buildBatchCrawlingSection(crawlingState),
            const SizedBox(height: 32),

            // 크롤링 상태
            _buildCrawlingStatus(crawlingState),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(AsyncValue<CrawlingStats> statsAsync) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: context.colors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '크롤링 현황',
                style: context.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                _buildStatItem(
                  '전체 유명인',
                  '${stats.totalCelebrities}명',
                  DSColors.textSecondaryDark,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  '크롤링 완료',
                  '${stats.crawledCelebrities}명',
                  context.colors.accent,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  '완료율',
                  '${stats.crawlingPercentage.toStringAsFixed(1)}%',
                  context.colors.accent,
                ),
                if (stats.lastCrawledAt != null) ...[
                  const SizedBox(height: 12),
                  _buildStatItem(
                    '마지막 크롤링',
                    _formatDateTime(stats.lastCrawledAt!),
                    DSColors.textSecondaryDark,
                  ),
                ],
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Text(
              '통계 로드 실패: $error',
              style: const TextStyle(color: DSColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodySmall.copyWith(
            color: DSColors.textSecondaryDark,
          ),
        ),
        Text(
          value,
          style: context.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCrawlingSection(CrawlingState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search,
                color: context.colors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '단일 크롤링',
                style: context.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '유명인 이름',
              hintText: '예: 송중기, 아이유, 손흥민',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DSColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.accent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: UnifiedButton(
                  text: '크롤링 시작',
                  onPressed: state.status == CrawlingStatus.crawling
                      ? null
                      : _crawlSingle,
                  isLoading: state.status == CrawlingStatus.crawling,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UnifiedButton(
                  text: '강제 업데이트',
                  onPressed: state.status == CrawlingStatus.crawling
                      ? null
                      : () => _crawlSingle(forceUpdate: true),
                  style: UnifiedButtonStyle.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCrawlingSection(CrawlingState state) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.batch_prediction,
                color: context.colors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '일괄 크롤링',
                style: context.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _batchController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: '유명인 목록 (한 줄에 하나씩)',
              hintText: '송중기\n아이유\n손흥민\n...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DSColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.accent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: UnifiedButton(
                  text: '일괄 크롤링',
                  onPressed: state.status == CrawlingStatus.crawling
                      ? null
                      : _crawlBatch,
                  isLoading: state.status == CrawlingStatus.crawling,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UnifiedButton(
                  text: '샘플 데이터',
                  onPressed: _loadSampleNames,
                  style: UnifiedButtonStyle.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrawlingStatus(CrawlingState state) {
    if (state.status == CrawlingStatus.idle) {
      return const SizedBox.shrink();
    }

    Color statusColor;
    IconData statusIcon;

    switch (state.status) {
      case CrawlingStatus.crawling:
        statusColor = context.colors.accent;
        statusIcon = Icons.sync;
        break;
      case CrawlingStatus.completed:
        statusColor = DSColors.success;
        statusIcon = Icons.check_circle;
        break;
      case CrawlingStatus.error:
        statusColor = DSColors.error;
        statusIcon = Icons.error;
        break;
      case CrawlingStatus.idle:
        return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusTitle(state.status),
                style: context.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.message != null)
            Text(
              state.message!,
              style: context.bodySmall.copyWith(
                color: DSColors.textSecondaryDark,
              ),
            ),
          if (state.current != null && state.total != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행률',
                  style: context.bodySmall.copyWith(
                    color: DSColors.textSecondaryDark,
                  ),
                ),
                Text(
                  '${state.current}/${state.total}',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.total! > 0 ? state.current! / state.total! : 0,
              backgroundColor: DSColors.borderDark,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ],
          if (state.result != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem(
                  '성공',
                  '${state.result!.successCount}',
                  DSColors.success,
                ),
                _buildResultItem(
                  '실패',
                  '${state.result!.failureCount}',
                  DSColors.error,
                ),
                _buildResultItem(
                  '성공률',
                  '${state.result!.successRate.toStringAsFixed(1)}%',
                  context.colors.accent,
                ),
              ],
            ),
          ],
          if (state.status != CrawlingStatus.crawling) ...[
            const SizedBox(height: 16),
            UnifiedButton(
              text: '초기화',
              onPressed: () {
                ref.read(crawlingResultProvider.notifier).reset();
                ref.invalidate(crawlingStatsProvider);
              },
              style: UnifiedButtonStyle.secondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: context.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: DSColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  void _crawlSingle({bool forceUpdate = false}) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유명인 이름을 입력해주세요')),
      );
      return;
    }

    ref.read(crawlingResultProvider.notifier).crawlSingleCelebrity(
          name,
          forceUpdate: forceUpdate,
        );
  }

  void _crawlBatch() {
    final text = _batchController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('크롤링할 유명인 목록을 입력해주세요')),
      );
      return;
    }

    final names = text
        .split('\n')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 유명인 이름을 입력해주세요')),
      );
      return;
    }

    ref.read(crawlingResultProvider.notifier).crawlMultipleCelebrities(names);
  }

  void _loadSampleNames() {
    const sampleNames = [
      '차은우',
      '김유정',
      '박보영',
      '이민호',
      '수지',
      '박서준',
      '김태리',
      '정해인',
    ];

    _batchController.text = sampleNames.join('\n');
  }

  String _getStatusTitle(CrawlingStatus status) {
    switch (status) {
      case CrawlingStatus.idle:
        return '대기 중';
      case CrawlingStatus.crawling:
        return '크롤링 진행 중';
      case CrawlingStatus.completed:
        return '크롤링 완료';
      case CrawlingStatus.error:
        return '크롤링 실패';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
