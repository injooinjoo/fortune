import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/components/app_card.dart';

/// 토스 스타일 사주팔자 명식 테이블
class SajuTableToss extends StatefulWidget {
  final Map<String, dynamic> sajuData;
  final AnimationController animationController;

  const SajuTableToss({
    super.key,
    required this.sajuData,
    required this.animationController,
  });

  @override
  State<SajuTableToss> createState() => _SajuTableTossState();
}

class _SajuTableTossState extends State<SajuTableToss> {
  late List<Animation<double>> _pillarAnimations;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    
    _titleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _pillarAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.2 + index * 0.15,
          0.5 + index * 0.15,
          curve: Curves.elasticOut,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return AppCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              FadeTransition(
                opacity: _titleAnimation,
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_chart_outlined,
                      color: DSColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '사주팔자',
                      style: DSTypography.headingLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: DSSpacing.sm),
              
              FadeTransition(
                opacity: _titleAnimation,
                child: Text(
                  '당신의 타고난 명식입니다',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: DSSpacing.lg),
              
              // 사주 테이블
              _buildSajuTable(),
              
              const SizedBox(height: DSSpacing.md),
              
              // 일간 설명
              FadeTransition(
                opacity: _titleAnimation,
                child: _buildDayMasterExplanation(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSajuTable() {
    final pillars = [
      {'title': '년주', 'key': 'year'},
      {'title': '월주', 'key': 'month'},
      {'title': '일주', 'key': 'day'},
      {'title': '시주', 'key': 'hour'},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: DSColors.border),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            decoration: const BoxDecoration(
              color: DSColors.backgroundSecondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DSRadius.md),
                topRight: Radius.circular(DSRadius.md),
              ),
            ),
            child: Row(
              children: pillars.asMap().entries.map((entry) {
                final index = entry.key;
                final pillar = entry.value;
                final isDay = pillar['key'] == 'day';
                
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < pillars.length - 1 
                          ? const BorderSide(color: DSColors.border, width: 1)
                          : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      pillar['title']!,
                      style: DSTypography.bodyMedium.copyWith(
                        fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                        color: isDay ? DSColors.accent : DSColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // 천간 행
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: DSColors.border, width: 1),
              ),
            ),
            child: Row(
              children: pillars.asMap().entries.map((entry) {
                final index = entry.key;
                final pillar = entry.value;
                final pillarData = widget.sajuData[pillar['key']];
                final isDay = pillar['key'] == 'day';
                
                return Expanded(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(_pillarAnimations[index]),
                    child: ScaleTransition(
                      scale: _pillarAnimations[index],
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: DSSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border(
                            right: index < pillars.length - 1 
                              ? const BorderSide(color: DSColors.border, width: 1)
                              : BorderSide.none,
                          ),
                          color: isDay 
                            ? DSColors.accent.withValues(alpha: 0.08)
                            : null,
                        ),
                        child: _buildStemCell(pillarData?['cheongan'], isDay),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // 지지 행
          Row(
            children: pillars.asMap().entries.map((entry) {
              final index = entry.key;
              final pillar = entry.value;
              final pillarData = widget.sajuData[pillar['key']];
              final isDay = pillar['key'] == 'day';
              
              return Expanded(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_pillarAnimations[index]),
                  child: ScaleTransition(
                    scale: _pillarAnimations[index],
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: DSSpacing.lg),
                      decoration: BoxDecoration(
                        border: Border(
                          right: index < pillars.length - 1 
                            ? const BorderSide(color: DSColors.border, width: 1)
                            : BorderSide.none,
                        ),
                        color: isDay 
                          ? DSColors.accent.withValues(alpha: 0.08)
                          : null,
                        borderRadius: index == pillars.length - 1 
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(DSRadius.md),
                            )
                          : index == 0 
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(DSRadius.md),
                              )
                            : null,
                      ),
                      child: _buildBranchCell(pillarData?['jiji'], isDay),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStemCell(Map<String, dynamic>? stemData, bool isDay) {
    if (stemData == null) {
      return const Text('-', textAlign: TextAlign.center);
    }

    final name = stemData['char'] as String? ?? '';
    final hanja = stemData['hanja'] as String? ?? '';
    final element = stemData['element'] as String? ?? '';
    final color = _getElementColor(element);

    return Column(
      children: [
        // 한글 + 한자 (더 크고 명확하게)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: DSTypography.bodyLarge.copyWith(
                fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                color: isDay ? DSColors.accent : color,
                fontSize: isDay ? 20 : 18,
              ),
            ),
            if (hanja.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                hanja,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDay ? DSColors.accent : DSColors.textPrimary,
                  fontSize: isDay ? 18 : 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        // 오행 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            element,
            style: DSTypography.labelSmall.copyWith(
              color: color,
              
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCell(Map<String, dynamic>? branchData, bool isDay) {
    if (branchData == null) {
      return const Text('-', textAlign: TextAlign.center);
    }

    final name = branchData['char'] as String? ?? '';
    final hanja = branchData['hanja'] as String? ?? '';
    final animal = branchData['animal'] as String? ?? '';
    final element = branchData['element'] as String? ?? '';
    final color = _getElementColor(element);

    return Column(
      children: [
        // 한글 + 한자 (더 크고 명확하게)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: DSTypography.bodyLarge.copyWith(
                fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                color: isDay ? DSColors.accent : DSColors.textPrimary,
                fontSize: isDay ? 20 : 18,
              ),
            ),
            if (hanja.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                hanja,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDay ? DSColors.accent : DSColors.textPrimary,
                  fontSize: isDay ? 18 : 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        // 동물 띠
        Text(
          animal,
          style: DSTypography.labelSmall.copyWith(
            color: isDay ? DSColors.accent.withValues(alpha: 0.8) : DSColors.textSecondary,
            fontSize: isDay ? 12 : 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // 오행 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            element,
            style: DSTypography.labelSmall.copyWith(
              color: color,
              
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayMasterExplanation() {
    final dayData = widget.sajuData['day'];
    if (dayData == null) return const SizedBox.shrink();

    final stemData = dayData['cheongan'] as Map<String, dynamic>?;
    if (stemData == null) return const SizedBox.shrink();

    final stemName = stemData['char'] as String? ?? '';
    final stemHanja = stemData['hanja'] as String? ?? '';
    final element = stemData['element'] as String? ?? '';
    final color = _getElementColor(element);

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '일간: $stemName($stemHanja) · $element 오행',
                  style: DSTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '당신의 본질을 나타내는 핵심 요소입니다',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return DSColors.success;
      case '화':
        return DSColors.error;
      case '토':
        return DSColors.warning;
      case '금':
        return DSColors.textSecondary;
      case '수':
        return DSColors.accent;
      default:
        return DSColors.textTertiary;
    }
  }
}