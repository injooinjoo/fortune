import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 스마트 이미지 위젯
/// URL이면 CachedNetworkImage, 로컬 경로면 Image.asset 사용
/// OTA 업데이트를 위한 CDN 이미지 지원
class SmartImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  const SmartImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
  });

  /// URL인지 확인 (http:// 또는 https://)
  bool get isNetworkImage => path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    }

    // 로컬 에셋 이미지
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) => errorWidget ?? _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: (width ?? 40) * 0.5,
          height: (height ?? 40) * 0.5,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: (width ?? 40) * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }
}

/// 원형 스마트 이미지
class CircularSmartImage extends StatelessWidget {
  final String path;
  final double size;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CircularSmartImage({
    super.key,
    required this.path,
    required this.size,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SmartImage(
        path: path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}
