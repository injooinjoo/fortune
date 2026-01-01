import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../services/talent_resume_service.dart';
import '../../../../../../core/utils/logger.dart';

/// 이력서 업로드 입력 위젯
///
/// PDF 파일만 지원하며, 저장된 이력서가 있으면 자동으로 표시합니다.
class ResumeUploadInput extends StatefulWidget {
  /// 저장된 이력서 정보
  final TalentResumeInfo? resumeInfo;

  /// 이력서 업로드 완료 시 콜백
  final Function(TalentResumeInfo?) onResumeChanged;

  /// 이력서 분석 포함 여부 (토큰 추가 소모)
  final bool includeInAnalysis;

  /// 이력서 분석 포함 여부 변경 콜백
  final Function(bool) onIncludeChanged;

  const ResumeUploadInput({
    super.key,
    this.resumeInfo,
    required this.onResumeChanged,
    this.includeInAnalysis = true,
    required this.onIncludeChanged,
  });

  @override
  State<ResumeUploadInput> createState() => _ResumeUploadInputState();
}

class _ResumeUploadInputState extends State<ResumeUploadInput> {
  bool _isLoading = false;
  String? _errorMessage;
  late TalentResumeService _resumeService;

  @override
  void initState() {
    super.initState();
    _resumeService = TalentResumeService(Supabase.instance.client);
  }

  Future<void> _pickAndUploadResume() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. PDF 파일 선택
      final file = await TalentResumeService.pickPdfFile();
      if (file == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. 사용자 ID 확인
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _errorMessage = '로그인이 필요합니다.';
          _isLoading = false;
        });
        return;
      }

      // 3. 파일 바이트 확인
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() {
          _errorMessage = '파일을 읽을 수 없습니다.';
          _isLoading = false;
        });
        return;
      }

      // 4. 업로드
      final resumeInfo = await _resumeService.uploadResume(
        userId: userId,
        pdfBytes: bytes,
        fileName: file.name,
      );

      if (resumeInfo != null) {
        Logger.info('[ResumeUpload] 이력서 업로드 성공: ${resumeInfo.fileName}');
        widget.onResumeChanged(resumeInfo);
        widget.onIncludeChanged(true); // 업로드 시 분석 포함 자동 활성화
      } else {
        setState(() {
          _errorMessage = '업로드에 실패했습니다. 다시 시도해주세요.';
        });
      }
    } catch (e) {
      Logger.error('[ResumeUpload] 업로드 에러: $e');
      setState(() {
        _errorMessage = '업로드 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteResume() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _resumeService.deleteResume(userId);
      if (success) {
        Logger.info('[ResumeUpload] 이력서 삭제 성공');
        widget.onResumeChanged(null);
        widget.onIncludeChanged(false);
      }
    } catch (e) {
      Logger.error('[ResumeUpload] 삭제 에러: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final hasResume = widget.resumeInfo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 설명 텍스트
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '이력서를 업로드하면 더 정확한 적성 분석을 받을 수 있어요!',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),

        // 이력서 업로드/표시 영역
        if (hasResume)
          _buildResumeCard(context, colors, typography)
        else
          _buildUploadButton(context, colors, typography),

        // 에러 메시지
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: typography.labelSmall.copyWith(
                color: DSColors.error,
              ),
            ),
          ),

        // 토큰 안내 (이력서가 있을 때만)
        if (hasResume) ...[
          const SizedBox(height: 12),
          _buildAnalysisToggle(context, colors, typography),
        ],
      ],
    );
  }

  Widget _buildUploadButton(BuildContext context, DSColorScheme colors, DSTypographyScheme typography) {
    return InkWell(
      onTap: _isLoading ? null : _pickAndUploadResume,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textSecondary,
                ),
              )
            else ...[
              Icon(
                Icons.attach_file_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'PDF 파일 선택',
                style: typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, DSColorScheme colors, DSTypographyScheme typography) {
    final resumeInfo = widget.resumeInfo!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // PDF 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: DSColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 파일 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resumeInfo.fileName,
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${resumeInfo.formattedSize} • ${resumeInfo.formattedDate}',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 삭제 버튼
          if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: _deleteResume,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisToggle(BuildContext context, DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.includeInAnalysis
            ? DSColors.accent.withValues(alpha: 0.1)
            : colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.includeInAnalysis
              ? DSColors.accent.withValues(alpha: 0.3)
              : colors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.includeInAnalysis
                      ? '이력서 분석 포함'
                      : '이력서 분석 제외',
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.includeInAnalysis
                        ? DSColors.accent
                        : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.includeInAnalysis
                      ? '추가 2토큰 소모'
                      : '기본 분석만 진행',
                  style: typography.labelSmall.copyWith(
                    color: widget.includeInAnalysis
                        ? DSColors.accent.withValues(alpha: 0.7)
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.includeInAnalysis,
            onChanged: widget.onIncludeChanged,
            activeTrackColor: DSColors.accent.withValues(alpha: 0.5),
            activeThumbColor: DSColors.accent,
          ),
        ],
      ),
    );
  }
}
