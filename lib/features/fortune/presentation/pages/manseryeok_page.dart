import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/design_system/design_system.dart';
import '../providers/saju_provider.dart';
import '../widgets/saju/saju_widgets.dart';
import '../widgets/saju_element_chart.dart';
import '../../../../data/saju_explanations.dart';

/// 만세력(萬歲曆) 전체 페이지
///
/// 포스텔러 만세력 2.2 수준의 13개 섹션을 모두 포함하는 전용 풀페이지.
/// - 프로필 헤더
/// - 사주 원국 / 오행 분석 / 신강신약 / 용신 / 오행 상생상극
/// - 지장간 / 12운성 / 합충형파해 / 신살
/// - 대운 / 연운월운 / 오늘의 일진
class ManseryeokPage extends ConsumerStatefulWidget {
  const ManseryeokPage({super.key});

  @override
  ConsumerState<ManseryeokPage> createState() => _ManseryeokPageState();
}

class _ManseryeokPageState extends ConsumerState<ManseryeokPage>
    with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

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
        title: const Text('만세력'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isCapturing ? null : _showShareBottomSheet,
            icon: Icon(
              Icons.download_rounded,
              color: context.colors.textPrimary,
            ),
            tooltip: '이미지로 저장',
          ),
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

  // ───────────────────────────── Content ─────────────────────────────

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
              // ── 1. 프로필 헤더 ──
              _buildProfileHeader(sajuData, isDark),
              const SizedBox(height: DSSpacing.lg),

              // ── 2. 사주 원국 (명식) ──
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

              // ── 3. 오행 분석 ──
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

              // ── 4. 신강/신약 ──
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['strength']!,
                icon: Icons.speed_rounded,
                isDark: isDark,
                child: SajuStrengthGauge(sajuData: sajuData),
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── 5. 용신 분석 ──
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['yongshin']!,
                icon: Icons.favorite_rounded,
                isDark: isDark,
                child: SajuYongshinCard(sajuData: sajuData),
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── 6. 오행 상생상극 ──
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['oheng_cycle']!,
                icon: Icons.all_inclusive_rounded,
                isDark: isDark,
                child: OhengCycleWidget(sajuData: sajuData),
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── 7. 지장간 ──
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

              // ── 8. 12운성 ──
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

              // ── 9. 합충형파해 ──
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

              // ── 10. 신살 ──
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

              // ── 11. 대운 타임라인 ──
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['daeun_full']!,
                icon: Icons.timeline_rounded,
                isDark: isDark,
                child: ManseryeokDaeunTimeline(sajuData: sajuData),
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── 12. 연운/월운 ──
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['yeonwolun']!,
                icon: Icons.calendar_month_rounded,
                isDark: isDark,
                child: SajuYeonWolunCard(sajuData: sajuData),
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── 13. 오늘의 일진 ──
              _buildSectionWithConcept(
                concept: SajuExplanations.tabConcepts['iljin']!,
                icon: Icons.today_rounded,
                isDark: isDark,
                child: TodayIljinCard(sajuData: sajuData),
              ),

              // 하단 여백
              const SizedBox(height: DSSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────── 프로필 헤더 ─────────────────────────────

  Widget _buildProfileHeader(Map<String, dynamic> sajuData, bool isDark) {
    final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
    final userName =
        sajuData['userName'] as String? ?? sajuData['name'] as String? ?? '사용자';
    final gender = sajuData['gender'] as String? ?? '';
    final birthYear = sajuData['birthYear'] as int?;
    final birthMonth = sajuData['birthMonth'] as int?;
    final birthDay = sajuData['birthDay'] as int?;
    final isLunar = sajuData['isLunar'] as bool? ?? false;

    // 일간 추출
    String dayStem = '';
    String dayStemHanja = '';
    if (myungsik != null) {
      dayStem = myungsik['daySky'] as String? ?? '';
      dayStemHanja = _stemToHanja(dayStem);
    } else {
      final dayData = sajuData['day'] as Map<String, dynamic>?;
      final cheongan = dayData?['cheongan'] as Map<String, dynamic>?;
      dayStem = cheongan?['char'] as String? ?? '';
      dayStemHanja = cheongan?['hanja'] as String? ?? _stemToHanja(dayStem);
    }

    // 띠 추출
    final animal = _getAnimalFromYear(birthYear);

    // 생년월일 문자열
    String birthString = '';
    if (birthYear != null && birthMonth != null && birthDay != null) {
      birthString =
          '$birthYear년 $birthMonth월 $birthDay일 (${isLunar ? '음력' : '양력'})';
    }

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  DSColors.accentSecondary.withValues(alpha: 0.15),
                  DSColors.info.withValues(alpha: 0.1),
                ]
              : [
                  DSColors.accentSecondary.withValues(alpha: 0.08),
                  DSColors.info.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark
              ? DSColors.accentSecondary.withValues(alpha: 0.3)
              : DSColors.accentSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // 일간 대형 표시
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: dayStem.isNotEmpty
                  ? SajuColors.getStemColor(dayStem, isDark: isDark)
                      .withValues(alpha: 0.15)
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: dayStem.isNotEmpty
                    ? SajuColors.getStemColor(dayStem, isDark: isDark)
                    : context.colors.textTertiary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                dayStemHanja.isNotEmpty ? dayStemHanja : '?',
                style: context.heading1.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: dayStem.isNotEmpty
                      ? SajuColors.getStemColor(dayStem, isDark: isDark)
                      : context.colors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.md),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 + 성별
                Row(
                  children: [
                    Text(
                      userName,
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (gender.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (gender == '남'
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFEC4899))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadius.full),
                        ),
                        child: Text(
                          gender == '남' ? '남♂' : '여♀',
                          style: context.labelTiny.copyWith(
                            color: gender == '남'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // 생년월일
                if (birthString.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    birthString,
                    style: context.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],

                // 일간 + 띠
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (dayStem.isNotEmpty)
                      Text(
                        '일간: $dayStem($dayStemHanja)',
                        style: context.labelSmall.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (animal.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(DSRadius.full),
                          border: Border.all(
                            color:
                                isDark ? DSColors.border : DSColors.borderDark,
                          ),
                        ),
                        child: Text(
                          '$animal띠',
                          style: context.labelTiny.copyWith(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── 섹션 빌더 ─────────────────────────────

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

  // ───────────────────────────── 에러/빈 상태 ─────────────────────────────

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
              '만세력 정보를 불러올 수 없습니다',
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
              '채팅에서 "무현도사 사주팔자"를 선택하면\n사주를 분석해 드립니다',
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

  // ───────────────────────────── 공유/저장 ─────────────────────────────

  void _showShareBottomSheet() {
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: DSColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: DSSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                '만세력 카드 저장/공유',
                style: context.heading3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              _buildShareOption(
                icon: Icons.save_alt_rounded,
                label: '이미지로 저장',
                onTap: () {
                  Navigator.pop(ctx);
                  _saveImage(context);
                },
                isDark: isDark,
              ),
              _buildShareOption(
                icon: Icons.share_rounded,
                label: '공유하기',
                onTap: () {
                  Navigator.pop(ctx);
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
        child: Icon(icon, color: context.colors.textPrimary),
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

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'manseryeok_${DateTime.now().millisecondsSinceEpoch}.png';
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

      final directory = await getTemporaryDirectory();
      final fileName =
          'manseryeok_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '나의 만세력',
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

  // ───────────────────────────── 유틸 ─────────────────────────────

  String _stemToHanja(String stem) {
    const map = {
      '갑': '甲',
      '을': '乙',
      '병': '丙',
      '정': '丁',
      '무': '戊',
      '기': '己',
      '경': '庚',
      '신': '辛',
      '임': '壬',
      '계': '癸',
    };
    return map[stem] ?? '';
  }

  String _getAnimalFromYear(int? year) {
    if (year == null) return '';
    const animals = [
      '원숭이',
      '닭',
      '개',
      '돼지',
      '쥐',
      '소',
      '호랑이',
      '토끼',
      '용',
      '뱀',
      '말',
      '양',
    ];
    return animals[year % 12];
  }
}
