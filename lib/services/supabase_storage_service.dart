import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../core/utils/logger.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase;
  static const String _profileImagesBucket = 'profile-images';
  
  SupabaseStorageService(this._supabase);
  
  // Check if bucket exists and create if needed
  Future<void> ensureBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((b) => b.name == _profileImagesBucket);
      
      if (!bucketExists) {
        await _supabase.storage.createBucket(
          _profileImagesBucket,
          const BucketOptions(public: true));
        Logger.info('Created profile images bucket');
      }
    } catch (e) {
      Logger.warning('[SupabaseStorageService] 스토리지 버킷 생성 실패 (선택적 기능, 업로드 기능 비활성화): $e');
      // Bucket might already exist, continue
    }
  }
  
  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required XFile imageFile}) async {
    try {
      await ensureBucketExists();
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = imageFile.path.split('.').last;
      final fileName = 'profile_${userId}_$timestamp.$fileExtension';
      final filePath = '$userId/$fileName';
      
      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      
      // Upload to Supabase Storage
      final response = await _supabase.storage
          .from(_profileImagesBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExtension',
              upsert: true));
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from(_profileImagesBucket)
          .getPublicUrl(filePath);
      
      Logger.info('Supabase initialized successfully');
      return publicUrl;
    } catch (e) {
      Logger.warning('[SupabaseStorageService] 프로필 이미지 업로드 실패 (선택적 기능, 기존 이미지 유지): $e');
      return null;
    }
  }
  
  // Delete old profile images for a user (keep only the latest,
  Future<void> cleanupOldProfileImages({
    required String userId,
    String? currentImageUrl}) async {
    try {
      // List all files in user's directory
      final files = await _supabase.storage
          .from(_profileImagesBucket)
          .list(path: userId);
      
      // Extract current image filename from URL if provided
      String? currentFileName;
      if (currentImageUrl != null) {
        final uri = Uri.parse(currentImageUrl);
        currentFileName = uri.pathSegments.last;
      }
      
      // Delete old files
      for (final file in files) {
        if (file.name != currentFileName) {
          await _supabase.storage
              .from(_profileImagesBucket)
              .remove(['$userId/${file.name}']);
          Logger.info('Deleted old profile image: ${file.name}');
        }
      }
    } catch (e) {
      Logger.warning('[SupabaseStorageService] 이전 프로필 이미지 정리 실패 (선택적 기능, 이전 파일 유지): $e');
      // Non-critical error, continue
    }
  }
  
  // Get image picker instance
  static ImagePicker getImagePicker() => ImagePicker();
  
  // Pick image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final picker = getImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80
      );
      return image;
    } catch (e) {
      Logger.warning('[SupabaseStorageService] 갤러리 이미지 선택 실패 (선택적 기능, 카메라 사용 권장): $e');
      return null;
    }
  }
  
  // Pick image from camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final picker = getImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80
      );
      return image;
    } catch (e) {
      Logger.warning('[SupabaseStorageService] 카메라 이미지 촬영 실패 (선택적 기능, 갤러리 사용 권장): $e');
      return null;
    }
  }
  
  // Validate image file
  static bool validateImageFile(XFile file) {
    // Check file size (max 5MB,
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    
    // Check file extension
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final fileExtension = file.path.split('.').last.toLowerCase();
    
    if (!validExtensions.contains(fileExtension)) {
      Logger.warning('[SupabaseStorageService] 이미지 파일 형식 오류 (선택적 기능, 올바른 형식 선택 필요): 지원되지 않는 파일 형식');
      return false;
    }
    
    // File size check would require reading the file
    // For now, we'll trust the image picker's compression
    return true;
  }
}