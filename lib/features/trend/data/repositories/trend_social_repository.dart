import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/models.dart';

/// 트렌드 소셜 기능 Repository (좋아요, 댓글)
class TrendSocialRepository {
  final SupabaseClient _supabase;

  TrendSocialRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ============ 좋아요 기능 ============

  /// 좋아요 토글
  Future<LikeState> toggleLike(String contentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // 기존 좋아요 확인
      final existingLike = await _supabase
          .from('trend_likes')
          .select('id')
          .eq('content_id', contentId)
          .eq('user_id', userId)
          .maybeSingle();

      bool isLiked;

      if (existingLike != null) {
        // 좋아요 취소
        await _supabase
            .from('trend_likes')
            .delete()
            .eq('content_id', contentId)
            .eq('user_id', userId);
        isLiked = false;
      } else {
        // 좋아요 추가
        await _supabase.from('trend_likes').insert({
          'content_id': contentId,
          'user_id': userId,
        });
        isLiked = true;
      }

      // 최신 카운트 조회
      final countResponse = await _supabase
          .from('trend_contents')
          .select('like_count')
          .eq('id', contentId)
          .single();

      return LikeState(
        contentId: contentId,
        isLiked: isLiked,
        likeCount: countResponse['like_count'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] toggleLike error: $e');
      rethrow;
    }
  }

  /// 좋아요 상태 조회
  Future<LikeState> getLikeState(String contentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      bool isLiked = false;
      if (userId != null) {
        final existingLike = await _supabase
            .from('trend_likes')
            .select('id')
            .eq('content_id', contentId)
            .eq('user_id', userId)
            .maybeSingle();

        isLiked = existingLike != null;
      }

      final countResponse = await _supabase
          .from('trend_contents')
          .select('like_count')
          .eq('id', contentId)
          .single();

      return LikeState(
        contentId: contentId,
        isLiked: isLiked,
        likeCount: countResponse['like_count'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] getLikeState error: $e');
      return LikeState(
        contentId: contentId,
        isLiked: false,
        likeCount: 0,
      );
    }
  }

  // ============ 댓글 기능 ============

  /// 댓글 목록 조회
  Future<CommentListResponse> getComments(
    String contentId, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      // 댓글 조회
      final response = await _supabase
          .from('trend_comments')
          .select('''
            *,
            profiles:user_id (nickname, profile_image_url)
          ''')
          .eq('content_id', contentId)
          .isFilter('parent_id', null)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final commentsList = response as List;

      final comments = await Future.wait(
        commentsList.map((c) async {
          // 대댓글 조회
          final repliesResponse =
              await _supabase.from('trend_comments').select('''
                *,
                profiles:user_id (nickname, profile_image_url)
              ''').eq('parent_id', c['id']).order('created_at');

          final replies =
              (repliesResponse as List).map((r) => _parseComment(r)).toList();

          return _parseComment(c, replies: replies);
        }),
      );

      final hasMore = commentsList.length >= limit;

      return CommentListResponse(
        comments: comments,
        totalCount: offset + comments.length + (hasMore ? 1 : 0),
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] getComments error: $e');
      return const CommentListResponse(
        comments: [],
        totalCount: 0,
        hasMore: false,
      );
    }
  }

  TrendComment _parseComment(Map<String, dynamic> json,
      {List<TrendComment>? replies}) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return TrendComment(
      id: json['id'],
      userId: json['user_id'],
      contentId: json['content_id'],
      parentId: json['parent_id'],
      text: json['content'] ?? '',
      likeCount: json['like_count'] ?? 0,
      isDeleted: json['is_deleted'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userName: profile?['nickname'] ?? '익명',
      userProfileImage: profile?['profile_image_url'],
      replies: replies ?? [],
    );
  }

  /// 댓글 작성
  Future<TrendComment?> addComment(CommentInput input) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase.from('trend_comments').insert({
        'content_id': input.contentId,
        'user_id': userId,
        'content': input.text,
        'parent_id': input.parentId,
      }).select('''
            *,
            profiles:user_id (nickname, profile_image_url)
          ''').single();

      return _parseComment(response);
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] addComment error: $e');
      return null;
    }
  }

  /// 댓글 수정
  Future<TrendComment?> updateComment(String commentId, String text) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('trend_comments')
          .update({
            'content': text,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .eq('user_id', userId) // 본인 댓글만 수정 가능
          .select('''
            *,
            profiles:user_id (nickname, profile_image_url)
          ''')
          .single();

      return _parseComment(response);
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] updateComment error: $e');
      return null;
    }
  }

  /// 댓글 삭제 (소프트 삭제)
  Future<bool> deleteComment(String commentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('trend_comments')
          .update({
            'is_deleted': true,
            'content': '삭제된 댓글입니다.',
          })
          .eq('id', commentId)
          .eq('user_id', userId); // 본인 댓글만 삭제 가능

      return true;
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] deleteComment error: $e');
      return false;
    }
  }

  /// 댓글 좋아요 토글
  Future<int> toggleCommentLike(String commentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // 기존 좋아요 확인
      final existingLike = await _supabase
          .from('trend_comment_likes')
          .select('id')
          .eq('comment_id', commentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // 좋아요 취소
        await _supabase
            .from('trend_comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', userId);
      } else {
        // 좋아요 추가
        await _supabase.from('trend_comment_likes').insert({
          'comment_id': commentId,
          'user_id': userId,
        });
      }

      // 최신 카운트 조회
      final countResponse = await _supabase
          .from('trend_comments')
          .select('like_count')
          .eq('id', commentId)
          .single();

      return countResponse['like_count'] ?? 0;
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] toggleCommentLike error: $e');
      return 0;
    }
  }

  // ============ 공유 기능 ============

  /// 공유 카운트 증가
  Future<void> incrementShareCount(String contentId) async {
    try {
      await _supabase.rpc('increment_share_count', params: {
        'p_content_id': contentId,
      });
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] incrementShareCount error: $e');
    }
  }

  /// 공유 데이터 생성
  ShareData createShareData({
    required TrendContent content,
    String? resultTitle,
    String? resultImageUrl,
  }) {
    return ShareData(
      title: resultTitle ?? content.title,
      description: content.subtitle ?? '${content.type.displayName}에 참여해보세요!',
      imageUrl: resultImageUrl ?? content.thumbnailUrl,
      url: 'https://fortune.app/trend/${content.id}',
    );
  }

  /// 결과 공유 표시 업데이트
  Future<void> markResultShared({
    required String tableName,
    required String resultId,
  }) async {
    try {
      await _supabase
          .from(tableName)
          .update({'is_shared': true}).eq('id', resultId);
    } catch (e) {
      debugPrint('❌ [TrendSocialRepository] markResultShared error: $e');
    }
  }
}
