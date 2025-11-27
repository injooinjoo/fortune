// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_social.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrendLikeImpl _$$TrendLikeImplFromJson(Map<String, dynamic> json) =>
    _$TrendLikeImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrendLikeImplToJson(_$TrendLikeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'contentId': instance.contentId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$TrendCommentImpl _$$TrendCommentImplFromJson(Map<String, dynamic> json) =>
    _$TrendCommentImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      parentId: json['parentId'] as String?,
      text: json['text'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userName: json['userName'] as String?,
      userProfileImage: json['userProfileImage'] as String?,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => TrendComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );

Map<String, dynamic> _$$TrendCommentImplToJson(_$TrendCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'contentId': instance.contentId,
      'parentId': instance.parentId,
      'text': instance.text,
      'likeCount': instance.likeCount,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userName': instance.userName,
      'userProfileImage': instance.userProfileImage,
      'replies': instance.replies,
      'isLikedByMe': instance.isLikedByMe,
    };

_$TrendCommentLikeImpl _$$TrendCommentLikeImplFromJson(
        Map<String, dynamic> json) =>
    _$TrendCommentLikeImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      commentId: json['commentId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrendCommentLikeImplToJson(
        _$TrendCommentLikeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'commentId': instance.commentId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CommentInputImpl _$$CommentInputImplFromJson(Map<String, dynamic> json) =>
    _$CommentInputImpl(
      contentId: json['contentId'] as String,
      text: json['text'] as String,
      parentId: json['parentId'] as String?,
    );

Map<String, dynamic> _$$CommentInputImplToJson(_$CommentInputImpl instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'text': instance.text,
      'parentId': instance.parentId,
    };

_$CommentListResponseImpl _$$CommentListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CommentListResponseImpl(
      comments: (json['comments'] as List<dynamic>)
          .map((e) => TrendComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommentListResponseImplToJson(
        _$CommentListResponseImpl instance) =>
    <String, dynamic>{
      'comments': instance.comments,
      'totalCount': instance.totalCount,
      'hasMore': instance.hasMore,
    };

_$LikeStateImpl _$$LikeStateImplFromJson(Map<String, dynamic> json) =>
    _$LikeStateImpl(
      contentId: json['contentId'] as String,
      isLiked: json['isLiked'] as bool,
      likeCount: (json['likeCount'] as num).toInt(),
    );

Map<String, dynamic> _$$LikeStateImplToJson(_$LikeStateImpl instance) =>
    <String, dynamic>{
      'contentId': instance.contentId,
      'isLiked': instance.isLiked,
      'likeCount': instance.likeCount,
    };

_$ShareDataImpl _$$ShareDataImplFromJson(Map<String, dynamic> json) =>
    _$ShareDataImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      url: json['url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ShareDataImplToJson(_$ShareDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'url': instance.url,
      'metadata': instance.metadata,
    };
