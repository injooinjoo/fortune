import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/theme/toss_theme.dart';
import '../../core/theme/toss_design_system.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
import 'widgets/saju_summary_card.dart';

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

class _SajuSummaryPageState extends ConsumerState<SajuSummaryPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // 사주 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sajuProvider.notifier).fetchUserSaju();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sajuState = ref.watch(sajuProvider);

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
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
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: '이미지로 저장',
          ),
          // 공유 버튼
          IconButton(
            onPressed: _isCapturing ? null : () => _shareImage(context),
            icon: Icon(
              Icons.share_rounded,
              color: isDark ? Colors.white : Colors.black87,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: isDark
              ? TossDesignSystem.backgroundDark
              : TossDesignSystem.backgroundLight,
          child: SajuSummaryCard(
            sajuData: sajuData,
            showHeader: true,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TossTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: TossTheme.spacingM),
            Text(
              '사주 정보를 불러올 수 없습니다',
              style: TossTheme.heading3.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TossTheme.spacingS),
            Text(
              error,
              style: TossTheme.body2.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TossTheme.spacingL),
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
        padding: const EdgeInsets.all(TossTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: TossTheme.spacingM),
            Text(
              '사주 정보가 없습니다',
              style: TossTheme.heading3.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TossTheme.spacingS),
            Text(
              '프로필에서 생년월일을 입력하면\n사주를 계산해 드립니다',
              style: TossTheme.body2.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? TossDesignSystem.cardBackgroundDark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TossTheme.spacingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들바
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: TossTheme.spacingM),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 제목
              Text(
                '사주 카드 저장/공유',
                style: TossTheme.heading3.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: TossTheme.spacingM),
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
          color: isDark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      title: Text(
        label,
        style: TossTheme.body1.copyWith(
          color: isDark ? Colors.white : Colors.black87,
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
