import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/tokens/ds_colors.dart';
import '../../../../../core/design_system/tokens/ds_typography.dart';
import '../../../../../core/constants/in_app_products.dart';
import '../../../../../services/in_app_purchase_service.dart';
import '../../../../../presentation/providers/subscription_provider.dart';

/// 프리미엄 사주명리서 메인 페이지 (구매/진입)
class PremiumSajuMainPage extends ConsumerStatefulWidget {
  const PremiumSajuMainPage({super.key});

  @override
  ConsumerState<PremiumSajuMainPage> createState() =>
      _PremiumSajuMainPageState();
}

class _PremiumSajuMainPageState extends ConsumerState<PremiumSajuMainPage> {
  bool _isPurchasing = false;
  final bool _hasOwnership = false;
  String? _existingResultId;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    // TODO: 기존 구매 이력 확인
    // final result = await ref.read(premiumSajuServiceProvider).checkOwnership();
    // setState(() {
    //   _hasOwnership = result != null;
    //   _existingResultId = result?.id;
    // });
  }

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);

    try {
      final purchaseService = ref.read(inAppPurchaseServiceProvider);
      final success = await purchaseService.purchaseProduct(
        InAppProducts.premiumSajuLifetime,
      );

      if (success && mounted) {
        // 구매 성공 → 생성 페이지로 이동
        context.push('/premium-saju/generation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구매 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.background,
      appBar: AppBar(
        title: const Text('프리미엄 사주명리서'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 이미지/배너
            _buildHeaderBanner(),
            const SizedBox(height: 24),

            // 상품 설명
            _buildProductDescription(),
            const SizedBox(height: 24),

            // 목차 미리보기
            _buildTableOfContents(),
            const SizedBox(height: 24),

            // 구매 버튼 또는 열기 버튼
            _buildActionButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/pattern_saju.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '📜',
                  style: TextStyle(fontSize: 40), // 예외: 이모지
                ),
                const SizedBox(height: 12),
                Text(
                  '프리미엄 사주명리서',
                  style: DSTypography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '215페이지 · 60년 대운 분석 · 평생 소유',
                  style: DSTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신만을 위한 사주 분석서',
          style: DSTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '전문 명리학 이론을 바탕으로 작성된 215페이지 분량의 상세한 사주 분석서입니다. '
          '타고난 성격, 재물운, 애정운, 건강운, 그리고 60년간의 대운 흐름까지 '
          '당신의 인생을 깊이 있게 분석합니다.',
          style: DSTypography.bodyLarge.copyWith(
            color: DSColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        // 특징 목록
        _buildFeatureItem('📖', '215페이지 상세 분석'),
        _buildFeatureItem('⏳', '6대운 (60년) 타임라인'),
        _buildFeatureItem('💎', '일회 결제, 평생 소유'),
        _buildFeatureItem('🔖', '북마크 & 메모 기능'),
        _buildFeatureItem('📱', '오프라인에서도 열람 가능'),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)), // 예외: 이모지
          const SizedBox(width: 12),
          Text(
            text,
            style: DSTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableOfContents() {
    final parts = [
      ('Part 1', '사주 기초', '45페이지'),
      ('Part 2', '성격과 운명', '35페이지'),
      ('Part 3', '재물과 직업', '40페이지'),
      ('Part 4', '애정과 가정', '35페이지'),
      ('Part 5', '건강과 수명', '25페이지'),
      ('Part 6', '인생 타임라인', '35페이지'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '목차',
          style: DSTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: DSColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DSColors.border),
          ),
          child: Column(
            children: parts.asMap().entries.map((entry) {
              final index = entry.key;
              final part = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: index < parts.length - 1
                      ? Border(
                          bottom: BorderSide(color: DSColors.border),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        part.$1,
                        style: DSTypography.labelSmall.copyWith(
                          color: DSColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        part.$2,
                        style: DSTypography.bodyMedium,
                      ),
                    ),
                    Text(
                      part.$3,
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_hasOwnership && _existingResultId != null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () =>
              context.push('/premium-saju/reader/$_existingResultId'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DSColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            '내 사주명리서 열기',
            style: DSTypography.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isPurchasing ? null : _handlePurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isPurchasing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  )
                : Text(
                    '₩39,000 구매하기',
                    style: DSTypography.buttonMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // 예외: CTA 버튼 강조
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '일회 결제 · 평생 소유 · 환불 가능',
          style: DSTypography.labelSmall.copyWith(
            color: DSColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
