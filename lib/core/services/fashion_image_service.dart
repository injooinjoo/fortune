import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/utils/logger.dart';

/// 스타일 타입 Enum
enum FashionStyleType {
  hip('hip', '힙하게', 'trendy streetwear aesthetic'),
  neat('neat', '단정하게', 'clean minimalist style'),
  sexy('sexy', '섹시하게', 'elegant fitted silhouette'),
  intellectual('intellectual', '지적이게', 'smart casual refined'),
  natural('natural', '내추럴', 'relaxed comfortable fit'),
  romantic('romantic', '로맨틱', 'soft feminine aesthetic'),
  sporty('sporty', '스포티', 'athletic wear dynamic');

  const FashionStyleType(this.id, this.displayName, this.description);

  final String id;
  final String displayName;
  final String description;
}

/// 패션 이미지 생성 요청 모델
class FashionImageRequest {
  final String gender;
  final FashionStyleType styleType;
  final FashionOutfitData outfitData;
  final String colorTone;

  FashionImageRequest({
    required this.gender,
    required this.styleType,
    required this.outfitData,
    this.colorTone = 'warm',
  });

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'styleType': styleType.id,
        'outfitData': outfitData.toJson(),
        'colorTone': colorTone,
      };
}

/// 패션 아이템 데이터
class FashionOutfitData {
  final FashionItem top;
  final FashionItem bottom;
  final FashionItem? outer;
  final FashionItem shoes;
  final List<String>? accessories;

  FashionOutfitData({
    required this.top,
    required this.bottom,
    this.outer,
    required this.shoes,
    this.accessories,
  });

  Map<String, dynamic> toJson() => {
        'top': top.toJson(),
        'bottom': bottom.toJson(),
        if (outer != null) 'outer': outer!.toJson(),
        'shoes': shoes.toJson(),
        if (accessories != null) 'accessories': accessories,
      };
}

/// 패션 아이템
class FashionItem {
  final String item;
  final String color;

  FashionItem({required this.item, required this.color});

  Map<String, dynamic> toJson() => {'item': item, 'color': color};
}

/// 패션 이미지 생성 결과
class FashionImageResult {
  final String? id;
  final String imageUrl;
  final String styleType;
  final String gender;
  final Map<String, dynamic> outfitData;
  final DateTime createdAt;

  FashionImageResult({
    this.id,
    required this.imageUrl,
    required this.styleType,
    required this.gender,
    required this.outfitData,
    required this.createdAt,
  });

  factory FashionImageResult.fromJson(Map<String, dynamic> json) {
    return FashionImageResult(
      id: json['id'] as String? ?? json['recordId'] as String?,
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String,
      styleType: (json['styleType'] ?? json['style_type']) as String,
      gender: json['gender'] as String,
      outfitData: json['outfitData'] ?? json['outfit_data'] ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// NanoBanana 패션 이미지 생성 서비스
///
/// NanoBanana API를 사용하여 오행 기반 패션 이미지를 생성합니다.
///
/// **사용 예시**:
/// ```dart
/// final service = FashionImageService();
/// final result = await service.generateFashionImage(
///   request: FashionImageRequest(
///     gender: 'female',
///     styleType: FashionStyleType.romantic,
///     outfitData: FashionOutfitData(
///       top: FashionItem(item: 'blouse', color: 'soft pink'),
///       bottom: FashionItem(item: 'skirt', color: 'ivory'),
///       shoes: FashionItem(item: 'heels', color: 'beige'),
///     ),
///   ),
/// );
/// print('Image URL: ${result.imageUrl}');
/// ```
class FashionImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 패션 이미지 생성 (35 souls 소비)
  ///
  /// [request] - 패션 이미지 생성 요청 데이터
  Future<FashionImageResult> generateFashionImage({
    required FashionImageRequest request,
  }) async {
    try {
      Logger.info('[FashionImage] 🎨 Generating fashion image: ${request.styleType.displayName}');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Logger.info('[FashionImage] 📝 Style: ${request.styleType.id}, Gender: ${request.gender}');

      // Edge Function 호출
      final response = await _supabase.functions.invoke(
        'generate-fashion-image',
        body: {
          'userId': userId,
          ...request.toJson(),
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? 'Unknown error';
        throw Exception('Failed to generate fashion image: $errorMessage');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Image generation failed');
      }

      Logger.info('[FashionImage] ✅ Image generated: ${data['imageUrl']}');

      return FashionImageResult(
        id: data['recordId'] as String?,
        imageUrl: data['imageUrl'] as String,
        styleType: data['styleType'] as String,
        gender: request.gender,
        outfitData: request.outfitData.toJson(),
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      Logger.error('[FashionImage] ❌ Failed to generate fashion image: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 사용자의 패션 이미지 목록 조회
  ///
  /// [limit] - 최대 조회 개수 (기본값: 20)
  Future<List<FashionImageResult>> getUserFashionImages({int limit = 20}) async {
    try {
      Logger.info('[FashionImage] 📋 Fetching user fashion images (limit: $limit)');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('fashion_images')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final images = (response as List)
          .map((json) => FashionImageResult(
                id: json['id'] as String?,
                imageUrl: json['image_url'] as String,
                styleType: json['style_type'] as String,
                gender: json['gender'] as String,
                outfitData: json['outfit_data'] ?? {},
                createdAt: DateTime.parse(json['created_at'] as String),
              ))
          .toList();

      Logger.info('[FashionImage] ✅ Found ${images.length} images');

      return images;
    } catch (e, stackTrace) {
      Logger.error('[FashionImage] ❌ Failed to fetch images: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 특정 스타일의 패션 이미지 조회
  Future<List<FashionImageResult>> getFashionImagesByStyle(
    FashionStyleType styleType, {
    int limit = 10,
  }) async {
    try {
      Logger.info('[FashionImage] 📋 Fetching images for: ${styleType.displayName}');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('fashion_images')
          .select()
          .eq('user_id', userId)
          .eq('style_type', styleType.id)
          .order('created_at', ascending: false)
          .limit(limit);

      final images = (response as List)
          .map((json) => FashionImageResult(
                id: json['id'] as String?,
                imageUrl: json['image_url'] as String,
                styleType: json['style_type'] as String,
                gender: json['gender'] as String,
                outfitData: json['outfit_data'] ?? {},
                createdAt: DateTime.parse(json['created_at'] as String),
              ))
          .toList();

      Logger.info('[FashionImage] ✅ Found ${images.length} images for ${styleType.displayName}');

      return images;
    } catch (e, stackTrace) {
      Logger.error('[FashionImage] ❌ Failed to fetch images by style: $e', e, stackTrace);
      rethrow;
    }
  }

  /// 오늘 생성한 패션 이미지 조회
  Future<FashionImageResult?> getTodaysFashionImage(FashionStyleType styleType) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final todayStart = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);

      final response = await _supabase
          .from('fashion_images')
          .select()
          .eq('user_id', userId)
          .eq('style_type', styleType.id)
          .gte('created_at', todayStart.toIso8601String())
          .maybeSingle();

      if (response == null) return null;

      return FashionImageResult(
        id: response['id'] as String?,
        imageUrl: response['image_url'] as String,
        styleType: response['style_type'] as String,
        gender: response['gender'] as String,
        outfitData: response['outfit_data'] ?? {},
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      Logger.error('[FashionImage] ❌ Failed to get todays image: $e', e);
      return null;
    }
  }

  /// 패션 이미지 삭제
  Future<void> deleteFashionImage(String imageId) async {
    try {
      Logger.info('[FashionImage] 🗑️ Deleting fashion image: $imageId');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 먼저 이미지 URL 가져오기
      final imageData = await _supabase
          .from('fashion_images')
          .select('image_url')
          .eq('id', imageId)
          .eq('user_id', userId)
          .single();

      final imageUrl = imageData['image_url'] as String;

      // DB에서 삭제
      await _supabase
          .from('fashion_images')
          .delete()
          .eq('id', imageId)
          .eq('user_id', userId);

      // Storage에서 파일 삭제
      try {
        final fileName = imageUrl.split('/').last;
        await _supabase.storage
            .from('fashion-images')
            .remove(['$userId/$fileName']);
      } catch (storageError) {
        Logger.error('[FashionImage] ⚠️ Storage delete failed (may already be deleted): $storageError', storageError);
      }

      Logger.info('[FashionImage] ✅ Fashion image deleted');
    } catch (e, stackTrace) {
      Logger.error('[FashionImage] ❌ Failed to delete fashion image: $e', e, stackTrace);
      rethrow;
    }
  }
}
