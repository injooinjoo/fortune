import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/fortune_type_names.dart';
import '../../core/design_system/design_system.dart';
// import 'package:qr_flutter/qr_flutter.dart'; // TODO: Add qr_flutter package

class EnhancedShareableFortuneCard extends StatelessWidget {
  final String fortuneType;
  final String title;
  final String content;
  final String? userName;
  final DateTime? date;
  final Map<String, dynamic>? additionalInfo;
  final ShareCardTemplate template;

  const EnhancedShareableFortuneCard({
    super.key,
    required this.fortuneType,
    required this.title,
    required this.content,
    this.userName,
    this.date,
    this.additionalInfo,
    this.template = ShareCardTemplate.modern});

  @override
  Widget build(BuildContext context) {
    switch (template) {
      case ShareCardTemplate.modern:
        return _buildModernTemplate(context);
      case ShareCardTemplate.traditional:
        return _buildTraditionalTemplate(context);
      case ShareCardTemplate.minimal:
        return _buildMinimalTemplate(context);
      case ShareCardTemplate.instagram:
        return _buildInstagramTemplate(context);
    }
  }

  Widget _buildModernTemplate(BuildContext context) {
    return Container(
      width: AppSpacing.spacing1 * 100.0,
      decoration: BoxDecoration(
        gradient: _getGradientForFortuneType(fortuneType),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: AppSpacing.paddingAll24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.spacing6),
                _buildFortuneContent(context),
                const SizedBox(height: AppSpacing.spacing6),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalTemplate(BuildContext context) {
    return Container(
      width: AppSpacing.spacing1 * 100.0,
      decoration: BoxDecoration(
        color: DSFortuneColors.hanjiWarm,
        borderRadius: AppDimensions.borderRadiusLarge,
        border: Border.all(
          color: const Color(0xFF8D6E63), // 고유 색상 - 전통 한지 테두리
          width: 3)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Traditional Header
          Container(
            padding: AppSpacing.paddingVertical16,
            decoration: const BoxDecoration(
              color: Color(0xFF8D6E63), // 고유 색상 - 전통 한지 헤더
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Center(
              child: Text(
                '⊹ 오늘의 운세 ⊹',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          // Content
          Padding(
            padding: AppSpacing.paddingAll24,
            child: Column(
              children: [
                if (userName != null) ...[
                  Text(
                    userName!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.spacing2),
                ],
                Container(
                  padding: AppSpacing.paddingAll20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDimensions.borderRadiusMedium,
                    border: Border.all(
                      color: const Color(0xFFBCAAA4), // 고유 색상 - 전통 한지 내부 테두리
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.spacing4),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing5),
                _buildTraditionalFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTemplate(BuildContext context) {
    return Container(
      width: AppSpacing.spacing1 * 100.0,
      padding: const EdgeInsets.all(AppSpacing.spacing8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fortune Type Icon
          Container(
            width: 60,
            height: AppSpacing.spacing15,
            decoration: BoxDecoration(
              color: _getColorForFortuneType(fortuneType).withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: Icon(
              _getIconForFortuneType(fortuneType),
              color: _getColorForFortuneType(fortuneType),
              size: AppDimensions.iconSizeXLarge)),
          const SizedBox(height: AppSpacing.spacing5),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
          if (userName != null) ...[
            const SizedBox(height: AppSpacing.spacing2),
            Text(
              userName!,
              style: Theme.of(context).textTheme.bodyMedium)],
          const SizedBox(height: AppSpacing.spacing6),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.spacing8),
          // Minimal Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppDimensions.buttonHeightSmall,
                height: AppDimensions.buttonHeightSmall,
                decoration: BoxDecoration(
                  color: DSColors.backgroundSecondaryDark,
                  borderRadius: AppDimensions.borderRadiusSmall),
                child: const Icon(
                  Icons.auto_awesome,
                  color: DSColors.accentDark,
                  size: AppDimensions.iconSizeSmall)),
              const SizedBox(width: AppSpacing.spacing3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fortune 신점',
                    style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    date != null 
                        ? '${date!.year}.${date!.month}.${date!.day}'
                        : '신이 전하는 나만의 운세',
                    style: Theme.of(context).textTheme.bodyMedium)])])]));
  }

  Widget _buildInstagramTemplate(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: _getInstagramGradient()),
        child: Stack(
          children: [
            // Background Effects
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: AppSpacing.spacing24 * 3.125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacing8),
                child: Column(
                  children: [
                    const Spacer(),
                    // Main Content Card
                    Container(
                      padding: AppSpacing.paddingAll24,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15))]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fortune Icon
                          Container(
                            width: 80,
                            height: AppSpacing.spacing20,
                            decoration: BoxDecoration(
                              gradient: _getGradientForFortuneType(fortuneType),
                              shape: BoxShape.circle),
                            child: Icon(
                              _getIconForFortuneType(fortuneType),
                              color: Colors.white,
                              size: 40)),
                          const SizedBox(height: AppSpacing.spacing5),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center),
                          if (userName != null) ...[
                            const SizedBox(height: AppSpacing.spacing2),
                            Text(
                              '@$userName',
                              style: Theme.of(context).textTheme.bodyMedium)],
                          const SizedBox(height: AppSpacing.spacing6),
                          Text(
                            content,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis)])),
                    const Spacer(),
                    // Instagram Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing5,
                        vertical: AppSpacing.spacing3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.spacing7 * 1.07)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: AppDimensions.iconSizeSmall),
                          const SizedBox(width: AppSpacing.spacing2),
                          Text(
                            'Fortune 신점',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: AppSpacing.spacing12 * 1.04,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: AppDimensions.borderRadiusMedium),
          child: Icon(
            _getIconForFortuneType(fortuneType),
            color: Colors.white,
            size: AppDimensions.iconSizeLarge)),
        const SizedBox(width: AppSpacing.spacing4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FortuneTypeNames.getName(fortuneType),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: AppSpacing.spacing1),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium)]))]);
  }

  Widget _buildFortuneContent(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5))]),
      child: Column(
        children: [
          if (userName != null) ...[
            Text(
              userName!,
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.spacing3)],
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
          if (additionalInfo != null) ...[
            const SizedBox(height: AppSpacing.spacing4),
            _buildAdditionalInfo(context)]]));
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAll12,
      decoration: BoxDecoration(
        color: _getColorForFortuneType(fortuneType).withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: additionalInfo!.entries.map((entry) {
          return Column(
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.spacing1),
              Text(
                entry.value.toString(),
                style: Theme.of(context).textTheme.bodyMedium)]);
        }).toList()));
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: AppSpacing.spacing12 * 1.04,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.spacing2 * 1.25)),
              child: const Icon(
                Icons.qr_code_2,
                color: Colors.white,
                size: 30)),
            const SizedBox(width: AppSpacing.spacing3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fortune 신점',
                  style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '신이 전하는 나만의 운세',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))])]),
        if (date != null)
          Text(
            '${date!.year}.${date!.month.toString().padLeft(
    2, '0')}.${date!.day.toString().padLeft(
    2, '0')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))]);
  }

  Widget _buildTraditionalFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 1,
              color: const Color(0xFFBCAAA4)), // 고유 색상 - 전통 구분선
            const SizedBox(width: AppSpacing.spacing3),
            Text(
              '福',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold)),
            const SizedBox(width: AppSpacing.spacing3),
            Container(
              width: 30,
              height: 1,
              color: const Color(0xFFBCAAA4), // 고유 색상 - 전통 구분선
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing3),
        Text(
          'Fortune 신점 · 행운이 가득하길',
          style: Theme.of(context).textTheme.bodyMedium)]);
  }

  LinearGradient _getGradientForFortuneType(String type) {
    final baseColor = _getColorForFortuneType(type);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.9),
        baseColor,
        baseColor.withValues(alpha: 0.8)]);
  }

  LinearGradient _getInstagramGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF833AB4), // 브랜드 고유 색상 - Instagram
        Color(0xFFF56040), // 브랜드 고유 색상 - Instagram
        Color(0xFFFCAF45), // 브랜드 고유 색상 - Instagram
      ]
    );
  }

  Color _getColorForFortuneType(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return DSColors.accentDark;
      case 'love':
      case 'compatibility':
        return DSColors.error;
      case 'money':
      case 'wealth':
        return DSColors.success;
      case 'career':
      case 'business':
        return DSColors.accentDark;
      case 'health':
        return DSColors.warning;
      case 'zodiac':
        return DSColors.accentDark;
      default:
        return DSColors.accentDark;
    }
  }

  IconData _getIconForFortuneType(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return Icons.today;
      case 'love':
      case 'compatibility':
        return Icons.favorite;
      case 'money':
      case 'wealth':
        return Icons.attach_money;
      case 'career':
      case 'business':
        return Icons.work;
      case 'health':
        return Icons.favorite_border;
      case 'zodiac':
        return Icons.stars;
      default:
        return Icons.auto_awesome;
    }
  }
}

enum ShareCardTemplate {
  
  
  modern,
  traditional,
  minimal,
  instagram}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (var i = 0; i < size.width; i += spacing.toInt()) {
      for (var j = 0; j < size.height; j += spacing.toInt()) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          4,
          paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}