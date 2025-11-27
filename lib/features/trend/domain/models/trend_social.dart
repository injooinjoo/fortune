import 'package:freezed_annotation/freezed_annotation.dart';

part 'trend_social.freezed.dart';
part 'trend_social.g.dart';

/// 트렌드 콘텐츠 좋아요
@freezed
class TrendLike with _$TrendLike {
  const factory TrendLike({
    required String id,
    required String userId,
    required String contentId,
    DateTime? createdAt,
  }) = _TrendLike;

  factory TrendLike.fromJson(Map<String, dynamic> json) =>
      _$TrendLikeFromJson(json);
}

/// 트렌드 콘텐츠 댓글
@freezed
class TrendComment with _$TrendComment {
  const factory TrendComment({
    required String id,
    required String userId,
    required String contentId,
    String? parentId,
    required String text,
    @Default(0) int likeCount,
    @Default(false) bool isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    // 조인된 데이터
    String? userName,
    String? userProfileImage,
    @Default([]) List<TrendComment> replies,
    @Default(false) bool isLikedByMe,
  }) = _TrendComment;

  factory TrendComment.fromJson(Map<String, dynamic> json) =>
      _$TrendCommentFromJson(json);
}

/// 댓글 좋아요
@freezed
class TrendCommentLike with _$TrendCommentLike {
  const factory TrendCommentLike({
    required String id,
    required String userId,
    required String commentId,
    DateTime? createdAt,
  }) = _TrendCommentLike;

  factory TrendCommentLike.fromJson(Map<String, dynamic> json) =>
      _$TrendCommentLikeFromJson(json);
}

/// 댓글 작성 입력
@freezed
class CommentInput with _$CommentInput {
  const factory CommentInput({
    required String contentId,
    required String text,
    String? parentId,
  }) = _CommentInput;

  factory CommentInput.fromJson(Map<String, dynamic> json) =>
      _$CommentInputFromJson(json);
}

/// 댓글 목록 응답
@freezed
class CommentListResponse with _$CommentListResponse {
  const factory CommentListResponse({
    required List<TrendComment> comments,
    @Default(0) int totalCount,
    @Default(false) bool hasMore,
  }) = _CommentListResponse;

  factory CommentListResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentListResponseFromJson(json);
}

/// 좋아요 상태
@freezed
class LikeState with _$LikeState {
  const factory LikeState({
    required String contentId,
    required bool isLiked,
    required int likeCount,
  }) = _LikeState;

  factory LikeState.fromJson(Map<String, dynamic> json) =>
      _$LikeStateFromJson(json);
}

/// 공유 데이터
@freezed
class ShareData with _$ShareData {
  const factory ShareData({
    required String title,
    required String description,
    String? imageUrl,
    String? url,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ShareData;

  factory ShareData.fromJson(Map<String, dynamic> json) =>
      _$ShareDataFromJson(json);
}
