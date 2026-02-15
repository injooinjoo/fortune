import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/design_system/design_system.dart';
import '../../core/services/asset_delivery_service.dart';
import '../../core/models/asset_pack.dart';

/// 스마트 이미지 위젯
/// URL이면 CachedNetworkImage, 로컬 경로면 Image.asset 사용
/// OTA 업데이트를 위한 CDN 이미지 지원
/// On-Demand 자산 팩 다운로드 지원
class SmartImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  /// On-Demand 자산 팩 ID (선택적)
  /// 지정하면 해당 팩의 다운로드 상태를 확인하고 자동으로 경로 해결
  final String? assetPackId;

  /// 프로그레시브 로딩 활성화
  /// true면 shimmer 효과와 함께 로딩
  final bool progressive;

  /// 자산 팩 다운로드 필요 시 자동 다운로드 트리거
  final bool autoDownload;

  /// 이미지 캐시 크기 (메모리 최적화)
  final int? cacheWidth;
  final int? cacheHeight;

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
    this.assetPackId,
    this.progressive = false,
    this.autoDownload = true,
    this.cacheWidth,
    this.cacheHeight,
  });

  /// URL인지 확인 (http:// 또는 https://)
  bool get isNetworkImage =>
      path.startsWith('http://') || path.startsWith('https://');

  /// 로컬 파일 경로인지 확인 (캐시된 On-Demand 자산)
  bool get isLocalFile => path.startsWith('/');

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> {
  String? _resolvedPath;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveAssetPath();
  }

  @override
  void didUpdateWidget(SmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path ||
        oldWidget.assetPackId != widget.assetPackId) {
      _resolveAssetPath();
    }
  }

  Future<void> _resolveAssetPath() async {
    // 이미 네트워크 이미지이거나 로컬 파일이면 바로 사용
    if (widget.isNetworkImage || widget.isLocalFile) {
      setState(() {
        _resolvedPath = widget.path;
        _isLoading = false;
      });
      return;
    }

    // On-Demand 자산 팩 ID가 명시적으로 지정된 경우에만 AssetDeliveryService 사용
    // 일반 번들 에셋 (assetPackId 없음)은 그대로 Image.asset으로 처리
    if (widget.assetPackId == null) {
      setState(() {
        _resolvedPath = widget.path;
        _isLoading = false;
      });
      return;
    }

    // On-Demand 자산 경로 해결
    try {
      final service = AssetDeliveryService();
      final resolved = await service.resolveAssetPath(
        widget.path,
        packId: widget.assetPackId,
      );

      if (mounted) {
        setState(() {
          _resolvedPath = resolved;
          _isLoading = false;
        });
      }

      // 자동 다운로드가 활성화되어 있고 설치되지 않은 팩이면 다운로드
      if (widget.autoDownload) {
        if (!service.isPackSupported(widget.assetPackId!)) {
          debugPrint(
              '🖼️ [SmartImage] ⛔ 미지원 패킷(플랫폼 분기): ${widget.assetPackId}');
          return;
        }

        final isInstalled = await service.isPackInstalled(widget.assetPackId!);
        if (!isInstalled) {
          await _startDownload();
        }
      }
    } catch (e) {
      debugPrint('🖼️ [SmartImage] ❌ 경로 해결 실패: ${widget.path} - $e');
      if (mounted) {
        setState(() {
          _resolvedPath = widget.path; // 원본 경로로 폴백
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _startDownload() async {
    if (widget.assetPackId == null || _isDownloading) return;

    final service = AssetDeliveryService();
    if (!service.isPackSupported(widget.assetPackId!)) {
      debugPrint('🖼️ [SmartImage] ⛔ 미지원 패킷(플랫폼 분기): ${widget.assetPackId}');
      return;
    }

    final requestStarted = await service.requestAssetPack(widget.assetPackId!);
    if (!requestStarted) return;

    if (!mounted) return;

    setState(() {
      _isDownloading = true;
    });

    // 다운로드 진행률 구독
    service.downloadProgress.listen((progress) {
      if (progress.packId == widget.assetPackId && mounted) {
        setState(() {
          _downloadProgress = progress.progress;
          if (progress.status == AssetPackStatus.installed) {
            _isDownloading = false;
            // 다운로드 완료 후 경로 다시 해결
            _resolveAssetPath();
          } else if (progress.status == AssetPackStatus.failed) {
            _isDownloading = false;
            _error = progress.errorMessage;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (_isLoading) {
      return widget.placeholder ?? _buildShimmerPlaceholder();
    }

    // 다운로드 중
    if (_isDownloading) {
      return _buildDownloadingWidget();
    }

    // 에러 상태
    if (_error != null && _resolvedPath == null) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    final path = _resolvedPath ?? widget.path;

    // 네트워크 이미지
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        memCacheWidth: widget.cacheWidth,
        memCacheHeight: widget.cacheHeight,
        placeholder: (context, url) =>
            widget.placeholder ??
            (widget.progressive
                ? _buildShimmerPlaceholder()
                : _buildPlaceholder()),
        errorWidget: (context, url, error) =>
            widget.errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    }

    // 로컬 파일 (캐시된 On-Demand 자산)
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('🖼️ [SmartImage] ❌ 파일 로드 실패: $path');
          return widget.errorWidget ?? _buildErrorWidget();
        },
      );
    }

    // 로컬 에셋 이미지
    return Image.asset(
      path,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('🖼️ [SmartImage] ❌ Asset 로드 실패: $path');
        debugPrint('🖼️ [SmartImage] Error: $error');
        return widget.errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: (widget.width ?? 40) * 0.5,
          height: (widget.height ?? 40) * 0.5,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: context.colors.surface,
      ),
    );
  }

  Widget _buildDownloadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: (widget.width ?? 80) * 0.4,
              height: (widget.width ?? 80) * 0.4,
              child: CircularProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (widget.height != null && widget.height! > 60) ...[
              const SizedBox(height: 8),
              Text(
                '${(_downloadProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: (widget.width ?? 40) * 0.5,
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
