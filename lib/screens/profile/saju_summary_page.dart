import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/design_system/design_system.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
// 전통사주 페이지의 상세 위젯들
import '../../features/fortune/presentation/widgets/saju/saju_widgets.dart';
import '../../features/fortune/presentation/widgets/saju_element_chart.dart';
import '../../data/saju_explanations.dart';
// 대운 타임라인 (compact 버전 유지)
import 'widgets/compact/compact_daeun_timeline.dart';

/// 사주 종합 페이지
///
/// 전통사주의 모든 정보를 한 장의 인포그래픽으로 표시합니다.
/// - 사주 팔자 (4주 + 십성)
/// - 지장간, 12운성, 납음오행
/// - 오행 균형
/// - 합충형해
/// - 신살 (길신/흉신)
/// - 대운 타임라인
class SajuSummaryPage extends ConsumerStatefulWidget {
  const SajuSummaryPage({super.key});

  @override
  ConsumerState<SajuSummaryPage> createState() => _SajuSummaryPageState();
}

class _SajuSummaryPageState extends ConsumerState<SajuSummaryPage>
    with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  // 오행 차트 애니메이션 컨트롤러
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 사주 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sajuProvider.notifier).fetchUserSaju();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final sajuState = ref.watch(sajuProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('사주 종합'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 이미지 저장 버튼
          IconButton(
            onPressed: _isCapturing ? null : _showShareBottomSheet,
            icon: Icon(
              Icons.download_rounded,
              color: context.colors.textPrimary,
            ),
            tooltip: '이미지로 저장',
          ),
          // 공유 버튼
          IconButton(
            onPressed: _isCapturing ? null : () => _shareImage(context),
            icon: Icon(
              Icons.share_rounded,
              color: context.colors.textPrimary,
            ),
            tooltip: '공유하기',
          ),
        ],
      ),
      body: sajuState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sajuState.error != null
              ? _buildErrorView(sajuState.error!, isDark)
              : sajuState.sajuData == null
                  ? _buildEmptyView(isDark)
                  : _buildContent(sajuState.sajuData!, isDark),
    );
  }

  Widget _buildContent(Map<String, dynamic> sajuData, bool isDark) {
    // 오행 균형 데이터 준비
    final sajuState = ref.watch(sajuProvider);
    final providerElements =
        sajuState.sajuData?['elements'] as Map<String, dynamic>?;
    final elementBalance = {
      '목': providerElements?['목'] ?? sajuData['elementBalance']?['목'] ?? 0,
      '화': providerElements?['화'] ?? sajuData['elementBalance']?['화'] ?? 0,
      '토': providerElements?['토'] ?? sajuData['elementBalance']?['토'] ?? 0,
      '금': providerElements?['금'] ?? sajuData['elementBalance']?['금'] ?? 0,
      '수': providerElements?['수'] ?? sajuData['elementBalance']?['수'] ?? 0,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: context.colors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              _buildHeader(isDark),
              const SizedBox(height: DSSpacing.lg),

              // 1. 명식 섹션
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['myungsik']!,
                icon: Icons.grid_view_rounded,
                isDark: isDark,
                child: SajuPillarTablePro(
                  sajuData: sajuData,
                  showTitle: false,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // 2. 오행 섹션
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['ohang']!,
                icon: Icons.donut_large_rounded,
                isDark: isDark,
                child: SajuElementChart(
                  elementBalance: elementBalance,
                  animationController: _animationController,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // 3. 지장간 섹션
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['jijanggan']!,
                icon: Icons.layers_rounded,
                isDark: isDark,
                child: SajuJijangganWidget(
                  sajuData: sajuData,
                  showTitle: false,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // 4. 12운성 섹션
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['twelve_fortune']!,
                icon: Icons.loop_rounded,
                isDark: isDark,
                child: SajuTwelveStagesWidget(
                  sajuData: sajuData,
                  showTitle: false,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // 5. 신살 섹션
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['sinsal']!,
                icon: Icons.stars_rounded,
                isDark: isDark,
                child: SajuSinsalWidget(
                  sajuData: sajuData,
                  showTitle: false,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // 6. 합충 섹션
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['hapchung']!,
                icon: Icons.compare_arrows_rounded,
                isDark: isDark,
                child: SajuHapchungWidget(
                  sajuData: sajuData,
                  showTitle: false,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // 7. 대운 타임라인 (compact 버전 유지)
              _buildDaeunSection(sajuData, isDark),

              // 하단 여백
              const SizedBox(height: DSSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// 개념 설명 카드와 함께 섹션 빌드
  Widget _buildSectionWithConcept({
    required Map<String, String> concept,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SajuConceptCard(
          title: concept['title']!,
          shortDescription: concept['short']!,
          fullDescription: concept['full']!,
          icon: icon,
          realLife: concept['realLife'],
          tips: concept['tips'],
        ),
        const SizedBox(height: DSSpacing.md),
        child,
      ],
    );
  }

  /// 대운 섹션 빌드
  Widget _buildDaeunSection(Map<String, dynamic> sajuData, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 대운 제목
        Row(
          children: [
            Icon(
              Icons.timeline_rounded,
              color: context.colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: DSSpacing.sm),
            Text(
              '대운 흐름',
              style: context.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          '10년 단위로 변화하는 인생의 큰 흐름입니다',
          style: context.labelMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        CompactDaeunTimeline(sajuData: sajuData),
      ],
    );
  }

  /// 헤더 빌드
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [DSFortuneColors.categoryDaily, DSFortuneColors.categoryCareer] // 사주 헤더 그라디언트
                  : [DSFortuneColors.categoryLuckyItems, DSFortuneColors.categoryFamily], // 사주 헤더 그라디언트
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '사주 종합',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                '四柱綜合 · 나의 사주 팔자',
                style: context.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              '사주 정보를 불러올 수 없습니다',
              style: context.heading3.copyWith(
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              error,
              style: context.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.lg),
            ElevatedButton(
              onPressed: () {
                ref.read(sajuProvider.notifier).fetchUserSaju();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              '사주 정보가 없습니다',
              style: context.heading3.copyWith(
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '프로필에서 생년월일을 입력하면\n사주를 계산해 드립니다',
              style: context.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet() {
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: DSColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들바
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: DSSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 제목
              Text(
                '사주 카드 저장/공유',
                style: context.heading3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              // 옵션들
              _buildShareOption(
                icon: Icons.save_alt_rounded,
                label: '이미지로 저장',
                onTap: () {
                  Navigator.pop(context);
                  _saveImage(context);
                },
                isDark: isDark,
              ),
              _buildShareOption(
                icon: Icons.share_rounded,
                label: '공유하기',
                onTap: () {
                  Navigator.pop(context);
                  _shareImage(context);
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Icon(
          icon,
          color: context.colors.textPrimary,
        ),
      ),
      title: Text(
        label,
        style: context.bodyLarge.copyWith(
          color: context.colors.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    setState(() => _isCapturing = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        _showSnackBar('이미지 생성에 실패했습니다', isError: true);
        return;
      }

      // 갤러리에 저장
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'saju_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      _showSnackBar('이미지가 저장되었습니다');
    } catch (e) {
      _showSnackBar('저장 중 오류가 발생했습니다: $e', isError: true);
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    setState(() => _isCapturing = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        _showSnackBar('이미지 생성에 실패했습니다', isError: true);
        return;
      }

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final fileName = 'saju_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '나의 사주 팔자',
      );
    } catch (e) {
      _showSnackBar('공유 중 오류가 발생했습니다: $e', isError: true);
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
