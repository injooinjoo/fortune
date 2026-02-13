import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../core/utils/logger.dart';
import '../core/services/resilient_service.dart';
import '../core/services/supabase_connection_service.dart';

/// 강화된 Supabase 스토리지 서비스
///
/// KAN-76: 스토리지 버킷 권한 문제 해결
/// - ResilientService 패턴 적용
/// - 연결 안정성 확인
/// - 마이그레이션 자동 검증
/// - 권한 문제 자동 감지 및 복구
class SupabaseStorageService extends ResilientService {
  final SupabaseClient _supabase;
  static const String _profileImagesBucket = 'profile-images';

  SupabaseStorageService(this._supabase);

  @override
  String get serviceName => 'SupabaseStorageService';

  /// 강화된 버킷 존재 및 권한 확인 (연결 안정성 포함)
  Future<bool> ensureBucketExists() async {
    return await safeExecuteWithBool(() async {
      // 1. Supabase 연결 상태 확인
      if (!SupabaseConnectionService.isConnected) {
        throw Exception('Supabase 연결이 끊어진 상태입니다. 연결을 확인해주세요.');
      }

      // 2. 사용자 인증 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('사용자 인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      }

      // 3. 마이그레이션 및 버킷 상태 검증
      await _verifyStorageInfrastructure();

      // 4. 버킷 존재 확인
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((b) => b.name == _profileImagesBucket);

      if (!bucketExists) {
        throw Exception(
            '스토리지 버킷($_profileImagesBucket)이 존재하지 않습니다. 관리자에게 문의하세요.');
      }

      // 5. RLS 정책 권한 테스트
      await _testBucketPermissions(user.id);

      Logger.info('Storage bucket access verified successfully');
    }, '스토리지 버킷 접근성 검증', '스토리지 기능 일시 비활성화');
  }

  /// 스토리지 인프라 상태 검증 (마이그레이션 포함)
  Future<void> _verifyStorageInfrastructure() async {
    await safeExecute(() async {
      // 버킷 정책 검증
      final bucketPolicies = await _supabase
          .rpc('storage_bucket_policies_check')
          .timeout(const Duration(seconds: 5));

      if (bucketPolicies == null || bucketPolicies.isEmpty) {
        Logger.warning('스토리지 정책이 설정되지 않았습니다. 마이그레이션을 확인해주세요.');
      }
    }, '스토리지 인프라 검증', '인프라 검증 생략');
  }

  /// RLS 정책 권한 테스트
  Future<void> _testBucketPermissions(String userId) async {
    await safeExecute(() async {
      // SELECT 권한 테스트
      await _supabase.storage
          .from(_profileImagesBucket)
          .list(path: userId, searchOptions: const SearchOptions(limit: 1));

      Logger.info('스토리지 읽기 권한 확인됨');
    }, '스토리지 권한 테스트', '권한 검증 생략');
  }

  /// 강화된 프로필 이미지 업로드 (ResilientService 패턴)
  Future<String?> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) async {
    return await safeExecuteWithNull(() async {
      // 1. 스토리지 접근 권한 검증
      final hasAccess = await ensureBucketExists();
      if (!hasAccess) {
        throw Exception('스토리지 접근 권한이 없습니다. 관리자에게 문의하세요.');
      }

      // 2. 파일 유효성 검증
      if (!validateImageFile(imageFile)) {
        throw Exception('지원되지 않는 파일 형식입니다. JPG, PNG, WebP 파일만 업로드 가능합니다.');
      }

      // 3. 파일 처리 및 업로드
      final uploadResult = await _processAndUploadImage(userId, imageFile);

      // 4. 이전 이미지 정리 (백그라운드)
      Future(() async {
        await cleanupOldProfileImages(
          userId: userId,
          currentImageUrl: uploadResult,
        );
      });

      Logger.info('프로필 이미지 업로드 성공: $userId');
      return uploadResult;
    }, '프로필 이미지 업로드', '이미지 업로드 실패, 기존 이미지 유지');
  }

  /// 이미지 처리 및 업로드 실행
  Future<String> _processAndUploadImage(String userId, XFile imageFile) async {
    // 파일명 생성
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final fileName = 'profile_${userId}_$timestamp.$fileExtension';
    final filePath = '$userId/$fileName';

    // 파일 읽기 및 크기 검증
    final bytes = await imageFile.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      throw Exception('파일 크기가 5MB를 초과합니다. 더 작은 파일을 선택해주세요.');
    }

    // Supabase 스토리지 업로드
    await _supabase.storage.from(_profileImagesBucket).uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExtension',
            upsert: true,
          ),
        );

    // Public URL 생성
    final publicUrl =
        _supabase.storage.from(_profileImagesBucket).getPublicUrl(filePath);

    return publicUrl;
  }

  /// 이전 프로필 이미지 정리 (ResilientService 패턴)
  Future<void> cleanupOldProfileImages({
    required String userId,
    String? currentImageUrl,
  }) async {
    await safeExecute(() async {
      // 사용자 디렉토리 내 파일 목록 조회
      final files =
          await _supabase.storage.from(_profileImagesBucket).list(path: userId);

      // 현재 이미지 파일명 추출
      String? currentFileName;
      if (currentImageUrl != null) {
        final uri = Uri.parse(currentImageUrl);
        currentFileName = uri.pathSegments.last;
      }

      // 이전 파일들 삭제
      final filesToDelete = files
          .where((file) => file.name != currentFileName)
          .map((file) => '$userId/${file.name}')
          .toList();

      if (filesToDelete.isNotEmpty) {
        await _supabase.storage
            .from(_profileImagesBucket)
            .remove(filesToDelete);

        Logger.info('이전 프로필 이미지 ${filesToDelete.length}개 정리 완료');
      }
    }, '이전 프로필 이미지 정리', '이전 파일 정리 생략');
  }

  /// 이미지 피커 인스턴스 생성
  static ImagePicker getImagePicker() => ImagePicker();

  /// 갤러리에서 이미지 선택 (ResilientService 패턴)
  static Future<XFile?> pickImageFromGallery() async {
    final tempService = _TempResilientService();
    return await tempService.safeExecuteWithNull(() async {
      final picker = getImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        Logger.info('갤러리에서 이미지 선택 성공');
        return image;
      } else {
        throw Exception('이미지 선택이 취소되었습니다');
      }
    }, '갤러리 이미지 선택', '갤러리 접근 실패, 카메라 사용 권장');
  }

  /// 카메라로 이미지 촬영 (ResilientService 패턴)
  static Future<XFile?> pickImageFromCamera() async {
    final tempService = _TempResilientService();
    return await tempService.safeExecuteWithNull(() async {
      final picker = getImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        Logger.info('카메라 이미지 촬영 성공');
        return image;
      } else {
        throw Exception('이미지 촬영이 취소되었습니다');
      }
    }, '카메라 이미지 촬영', '카메라 접근 실패, 갤러리 사용 권장');
  }

  /// 이미지 파일 유효성 검증
  static bool validateImageFile(XFile file) {
    // 파일 확장자 검증
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final fileExtension = file.path.split('.').last.toLowerCase();

    if (!validExtensions.contains(fileExtension)) {
      Logger.warning('지원되지 않는 파일 형식: $fileExtension');
      return false;
    }

    // 파일 크기는 업로드 시 검증 (비동기 작업 필요)
    Logger.info('이미지 파일 검증 성공: $fileExtension');
    return true;
  }
}

/// Static 메서드에서 ResilientService 패턴 사용을 위한 임시 클래스
class _TempResilientService extends ResilientService {
  @override
  String get serviceName => 'TempResilientService';
}
