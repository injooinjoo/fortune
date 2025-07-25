import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/widgets/social_share_bottom_sheet.dart';
import '../../domain/models/talisman_models.dart';
import '../widgets/talisman_design_canvas.dart';
import '../../../../services/talisman_share_service.dart';

class TalismanResultPage extends ConsumerStatefulWidget {
  final TalismanResult result;

  const TalismanResultPage({
    super.key,
    required this.result,
  });

  @override
  ConsumerState<TalismanResultPage> createState() => _TalismanResultPageState();
}

class _TalismanResultPageState extends ConsumerState<TalismanResultPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _talismanKey = GlobalKey();
  final _shareService = TalismanShareService();
  late AnimationController _animationController;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _captureTalisman() async {
    try {
      setState(() => _isCapturing = true);
      HapticUtils.lightImpact();
      
      final RenderRepaintBoundary boundary = 
          _talismanKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Add watermark
        final watermarkedImage = await _shareService.addWatermark(pngBytes);
        
        // Show share bottom sheet
        if (mounted) {
          _showShareOptions(watermarkedImage);
        }
      }
    } catch (e) {
      print('Error capturing talisman: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _showShareOptions(Uint8List imageData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialShareBottomSheet(
        fortuneTitle: widget.result.type.displayName,
        fortuneContent: widget.result.meaning,
        userName: widget.result.design.userName,
        previewImage: imageData,
        onShare: (platform) async {
          await _shareService.shareTalisman(
            imageData: imageData,
            platform: platform,
            talismanType: widget.result.type.displayName,
            userName: widget.result.design.userName ?? '',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: '부적 완성',
        showBackButton: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isCapturing 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            onPressed: _isCapturing ? null : _captureTalisman,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Talisman display
            Center(
              child: RepaintBoundary(
                key: _talismanKey,
                child: TalismanDesignCanvas(
                  result: widget.result,
                  size: 300,
                ),
              ),
            ).animate()
              .fadeIn(duration: 800.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 800.ms,
                curve: Curves.easeOutBack,
              ),
            
            const SizedBox(height: 32),
            
            // Meaning section
            _buildSectionCard(
              title: '부적의 의미',
              icon: Icons.auto_awesome,
              content: widget.result.meaning,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 16),
            
            // Usage section
            _buildSectionCard(
              title: '사용 방법',
              icon: Icons.info_outline,
              content: widget.result.usage,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 16),
            
            // Effectiveness section
            _buildSectionCard(
              title: '효과',
              icon: Icons.star_outline,
              content: widget.result.effectiveness,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 16),
            
            // Precautions section
            if (widget.result.precautions.isNotEmpty)
              _buildPrecautionsCard().animate()
                .fadeIn(duration: 600.ms, delay: 1000.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            
            // Action buttons
            _buildActionButtons().animate()
              .fadeIn(duration: 600.ms, delay: 1200.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: widget.result.type.gradientColors[0],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrecautionsCard() {
    final theme = Theme.of(context);
    
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          Colors.orange.withValues(alpha: 0.1),
          Colors.orange.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 8),
              Text(
                '주의사항',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.result.precautions.map((precaution) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    precaution,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isCapturing ? null : _captureTalisman,
          icon: const Icon(Icons.share),
          label: const Text('부적 공유하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            setState(() => _isCapturing = true);
            HapticUtils.lightImpact();
            
            try {
              final RenderRepaintBoundary boundary = 
                  _talismanKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
              
              final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
              final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              
              if (byteData != null) {
                final Uint8List pngBytes = byteData.buffer.asUint8List();
                await _shareService.saveToGallery(pngBytes);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('부적이 갤러리에 저장되었습니다'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            } catch (e) {
              print('Error saving talisman: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('저장 중 오류가 발생했습니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } finally {
              setState(() => _isCapturing = false);
            }
          },
          icon: const Icon(Icons.download),
          label: const Text('부적 저장하기'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('홈으로 돌아가기'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}