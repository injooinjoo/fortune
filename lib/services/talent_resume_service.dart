import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/resilient_service.dart';
import '../core/services/supabase_connection_service.dart';
import '../core/utils/logger.dart';

/// 이력서 정보 모델
class TalentResumeInfo {
  final String fileName;
  final String storagePath;
  final int sizeBytes;
  final DateTime uploadedAt;
  final String? extractedText;

  TalentResumeInfo({
    required this.fileName,
    required this.storagePath,
    required this.sizeBytes,
    required this.uploadedAt,
    this.extractedText,
  });

  factory TalentResumeInfo.fromStorageObject(FileObject file, String userId) {
    return TalentResumeInfo(
      fileName: file.name,
      storagePath: '$userId/${file.name}',
      sizeBytes: file.metadata?['size'] as int? ?? 0,
      uploadedAt: DateTime.tryParse(file.createdAt ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'storagePath': storagePath,
        'sizeBytes': sizeBytes,
        'uploadedAt': uploadedAt.toIso8601String(),
        'extractedText': extractedText,
      };

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${uploadedAt.year}.${uploadedAt.month.toString().padLeft(2, '0')}.${uploadedAt.day.toString().padLeft(2, '0')}';
  }
}

/// 적성 운세 이력서 업로드 서비스
///
/// 사용자 이력서 PDF를 Supabase Storage에 업로드/조회/삭제
/// - 파일 크기 제한: 5MB
/// - 형식: PDF만 지원
/// - 저장 경로: talent-resumes/{userId}/resume_{timestamp}.pdf
class TalentResumeService extends ResilientService {
  final SupabaseClient _supabase;
  static const String _bucketName = 'talent-resumes';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  TalentResumeService(this._supabase);

  @override
  String get serviceName => 'TalentResumeService';

  /// 이력서 업로드
  ///
  /// [userId] 사용자 ID
  /// [pdfBytes] PDF 파일 바이트
  /// [fileName] 원본 파일명
  ///
  /// Returns: 업로드된 이력서 정보
  Future<TalentResumeInfo?> uploadResume({
    required String userId,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    return await safeExecuteWithNull(
      () async {
        // 1. 연결 상태 확인
        if (!SupabaseConnectionService.isConnected) {
          throw Exception('Supabase 연결이 끊어진 상태입니다.');
        }

        // 2. 사용자 인증 확인
        final user = _supabase.auth.currentUser;
        if (user == null || user.id != userId) {
          throw Exception('사용자 인증이 필요합니다.');
        }

        // 3. 파일 크기 검증
        if (pdfBytes.length > _maxFileSizeBytes) {
          throw Exception('파일 크기가 5MB를 초과합니다.');
        }

        // 4. PDF 형식 검증 (PDF magic number: %PDF)
        if (!_isPdfFile(pdfBytes)) {
          throw Exception('PDF 파일만 업로드 가능합니다.');
        }

        // 5. 기존 이력서 삭제 (1개만 유지)
        await _deleteExistingResumes(userId);

        // 6. 파일 업로드
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final storagePath = '$userId/resume_$timestamp.pdf';

        await _supabase.storage.from(_bucketName).uploadBinary(
              storagePath,
              pdfBytes,
              fileOptions: const FileOptions(
                contentType: 'application/pdf',
                upsert: true,
              ),
            );

        Logger.info('이력서 업로드 성공: $storagePath');

        return TalentResumeInfo(
          fileName: fileName,
          storagePath: storagePath,
          sizeBytes: pdfBytes.length,
          uploadedAt: DateTime.now(),
        );
      },
      '이력서 업로드',
      '이력서 업로드 실패',
    );
  }

  /// 저장된 이력서 조회
  ///
  /// [userId] 사용자 ID
  ///
  /// Returns: 저장된 이력서 정보 (없으면 null)
  Future<TalentResumeInfo?> getStoredResume(String userId) async {
    try {
      // 연결 상태 확인
      if (!SupabaseConnectionService.isConnected) {
        Logger.warning('[$serviceName] 이력서 조회 실패: Supabase 연결이 끊어진 상태입니다.');
        return null;
      }

      // 사용자 폴더 내 파일 목록 조회
      final files = await _supabase.storage.from(_bucketName).list(path: userId);

      if (files.isEmpty) {
        return null;
      }

      // 가장 최신 파일 반환 (resume_*.pdf 형식)
      final resumeFiles = files.where((f) => f.name.startsWith('resume_') && f.name.endsWith('.pdf')).toList();

      if (resumeFiles.isEmpty) {
        return null;
      }

      // 가장 최신 파일 선택 (타임스탬프 기준)
      resumeFiles.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      final latestFile = resumeFiles.first;

      Logger.info('저장된 이력서 조회: $userId/${latestFile.name}');

      return TalentResumeInfo.fromStorageObject(latestFile, userId);
    } catch (e) {
      Logger.warning('[$serviceName] 이력서 조회 실패: $e');
      return null;
    }
  }

  /// 이력서 다운로드 (바이트로)
  ///
  /// [storagePath] 스토리지 경로
  ///
  /// Returns: PDF 파일 바이트
  Future<Uint8List?> downloadResume(String storagePath) async {
    return await safeExecuteWithNull(
      () async {
        final bytes = await _supabase.storage.from(_bucketName).download(storagePath);
        Logger.info('이력서 다운로드 성공: $storagePath');
        return bytes;
      },
      '이력서 다운로드',
      '이력서 다운로드 실패',
    );
  }

  /// 이력서 삭제
  ///
  /// [userId] 사용자 ID
  Future<bool> deleteResume(String userId) async {
    return await safeExecuteWithBool(
      () async {
        await _deleteExistingResumes(userId);
        Logger.info('이력서 삭제 완료: $userId');
      },
      '이력서 삭제',
      '이력서 삭제 실패',
    );
  }

  /// 기존 이력서 모두 삭제 (내부용)
  Future<void> _deleteExistingResumes(String userId) async {
    try {
      final files = await _supabase.storage.from(_bucketName).list(path: userId);

      if (files.isNotEmpty) {
        final filePaths = files.map((f) => '$userId/${f.name}').toList();
        await _supabase.storage.from(_bucketName).remove(filePaths);
        Logger.info('기존 이력서 ${filePaths.length}개 삭제');
      }
    } catch (e) {
      Logger.warning('기존 이력서 삭제 실패: $e');
    }
  }

  /// PDF 파일 여부 확인 (magic number 검사)
  bool _isPdfFile(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // PDF magic number: %PDF (0x25 0x50 0x44 0x46)
    return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
  }

  /// PDF 텍스트 추출 (간단한 방식)
  ///
  /// 참고: 복잡한 PDF는 Edge Function에서 처리하는 것이 좋음
  /// 이 메서드는 단순 텍스트 기반 PDF에만 작동
  Future<String?> extractTextFromPdf(Uint8List bytes) async {
    try {
      // PDF 바이너리에서 텍스트 스트림 추출 (기본적인 방식)
      // 복잡한 PDF는 서버사이드에서 pdf-parse 등을 사용해야 함
      final content = utf8.decode(bytes, allowMalformed: true);

      // 기본적인 텍스트 추출 (stream 내용)
      final textBuffer = StringBuffer();
      final streamRegex = RegExp(r'stream\s*([\s\S]*?)\s*endstream');
      final matches = streamRegex.allMatches(content);

      for (final match in matches) {
        final streamContent = match.group(1) ?? '';
        // ASCII 텍스트만 추출
        final printable = streamContent.replaceAll(RegExp(r'[^\x20-\x7E\n\r]'), ' ').trim();
        if (printable.isNotEmpty && printable.length > 10) {
          textBuffer.writeln(printable);
        }
      }

      final extractedText = textBuffer.toString().trim();
      if (extractedText.isEmpty) {
        Logger.warning('[$serviceName] PDF에서 텍스트를 추출할 수 없습니다. 서버사이드 처리 필요.');
        return null;
      }

      Logger.info('PDF 텍스트 추출 완료: ${extractedText.length}자');
      return extractedText;
    } catch (e) {
      Logger.warning('[$serviceName] PDF 텍스트 추출 실패: $e');
      return null;
    }
  }

  /// 파일 선택 다이얼로그 (PDF만)
  static Future<PlatformFile?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // 크기 검증
        if (file.size > _maxFileSizeBytes) {
          Logger.warning('파일 크기 초과: ${file.size} bytes');
          return null;
        }

        Logger.info('PDF 파일 선택: ${file.name} (${file.size} bytes)');
        return file;
      }

      return null;
    } catch (e) {
      Logger.error('PDF 파일 선택 실패: $e');
      return null;
    }
  }
}
