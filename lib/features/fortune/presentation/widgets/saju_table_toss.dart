import 'package:flutter/material.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/theme/toss_design_system.dart';

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
          padding: const EdgeInsets.all(TossTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              FadeTransition(
                opacity: _titleAnimation,
                child: Row(
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      color: TossTheme.brandBlue,
                      size: 24,
                    ),
                    const SizedBox(width: TossTheme.spacingS),
                    Text(
                      '사주팔자',
                      style: TossTheme.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingS),
              
              FadeTransition(
                opacity: _titleAnimation,
                child: Text(
                  '당신의 타고난 명식입니다',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ),
              
              const SizedBox(height: TossTheme.spacingL),
              
              // 사주 테이블
              _buildSajuTable(),
              
              const SizedBox(height: TossTheme.spacingM),
              
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
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(color: TossTheme.borderPrimary),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TossTheme.radiusM),
                topRight: Radius.circular(TossTheme.radiusM),
              ),
            ),
            child: Row(
              children: pillars.asMap().entries.map((entry) {
                final index = entry.key;
                final pillar = entry.value;
                final isDay = pillar['key'] == 'day';
                
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: TossTheme.spacingM),
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < pillars.length - 1 
                          ? BorderSide(color: TossTheme.borderPrimary, width: 1)
                          : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      pillar['title']!,
                      style: TossTheme.body2.copyWith(
                        fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                        color: isDay ? TossTheme.brandBlue : TossTheme.textBlack,
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
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TossTheme.borderPrimary, width: 1),
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
                        padding: const EdgeInsets.symmetric(vertical: TossTheme.spacingL),
                        decoration: BoxDecoration(
                          border: Border(
                            right: index < pillars.length - 1 
                              ? BorderSide(color: TossTheme.borderPrimary, width: 1)
                              : BorderSide.none,
                          ),
                          color: isDay 
                            ? TossTheme.brandBlue.withValues(alpha: 0.08)
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
                      padding: const EdgeInsets.symmetric(vertical: TossTheme.spacingL),
                      decoration: BoxDecoration(
                        border: Border(
                          right: index < pillars.length - 1 
                            ? BorderSide(color: TossTheme.borderPrimary, width: 1)
                            : BorderSide.none,
                        ),
                        color: isDay 
                          ? TossTheme.brandBlue.withValues(alpha: 0.08)
                          : null,
                        borderRadius: index == pillars.length - 1 
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(TossTheme.radiusM),
                            )
                          : index == 0 
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(TossTheme.radiusM),
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
              style: TossTheme.body1.copyWith(
                fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                color: isDay ? TossTheme.brandBlue : color,
                fontSize: isDay ? 20 : 18,
              ),
            ),
            if (hanja.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                hanja,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDay ? TossTheme.brandBlue : TossTheme.textBlack,
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
            style: TossTheme.caption.copyWith(
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
              style: TossTheme.body1.copyWith(
                fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                color: isDay ? TossTheme.brandBlue : TossTheme.textBlack,
                fontSize: isDay ? 20 : 18,
              ),
            ),
            if (hanja.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                hanja,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDay ? TossTheme.brandBlue : TossTheme.textBlack,
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
          style: TossTheme.caption.copyWith(
            color: isDay ? TossTheme.brandBlue.withValues(alpha: 0.8) : TossTheme.textGray600,
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
            style: TossTheme.caption.copyWith(
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
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(TossTheme.spacingS),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: TossDesignSystem.white,
              size: 16,
            ),
          ),
          const SizedBox(width: TossTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '일간: $stemName($stemHanja) · $element 오행',
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '당신의 본질을 나타내는 핵심 요소입니다',
                  style: TossTheme.caption.copyWith(
                    color: TossTheme.textGray600,
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
        return TossTheme.success;
      case '화':
        return TossTheme.error;
      case '토':
        return TossTheme.warning;
      case '금':
        return TossTheme.textGray600;
      case '수':
        return TossTheme.brandBlue;
      default:
        return TossTheme.textGray500;
    }
  }
}