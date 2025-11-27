// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'balance_game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BalanceGameSet _$BalanceGameSetFromJson(Map<String, dynamic> json) {
  return _BalanceGameSet.fromJson(json);
}

/// @nodoc
mixin _$BalanceGameSet {
  String get id => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  List<BalanceGameQuestion> get questions => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BalanceGameSet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceGameSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceGameSetCopyWith<BalanceGameSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceGameSetCopyWith<$Res> {
  factory $BalanceGameSetCopyWith(
          BalanceGameSet value, $Res Function(BalanceGameSet) then) =
      _$BalanceGameSetCopyWithImpl<$Res, BalanceGameSet>;
  @useResult
  $Res call(
      {String id,
      String contentId,
      String? description,
      int questionCount,
      List<BalanceGameQuestion> questions,
      DateTime? createdAt});
}

/// @nodoc
class _$BalanceGameSetCopyWithImpl<$Res, $Val extends BalanceGameSet>
    implements $BalanceGameSetCopyWith<$Res> {
  _$BalanceGameSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceGameSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contentId = null,
    Object? description = freezed,
    Object? questionCount = null,
    Object? questions = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      questionCount: null == questionCount
          ? _value.questionCount
          : questionCount // ignore: cast_nullable_to_non_nullable
              as int,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<BalanceGameQuestion>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BalanceGameSetImplCopyWith<$Res>
    implements $BalanceGameSetCopyWith<$Res> {
  factory _$$BalanceGameSetImplCopyWith(_$BalanceGameSetImpl value,
          $Res Function(_$BalanceGameSetImpl) then) =
      __$$BalanceGameSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String contentId,
      String? description,
      int questionCount,
      List<BalanceGameQuestion> questions,
      DateTime? createdAt});
}

/// @nodoc
class __$$BalanceGameSetImplCopyWithImpl<$Res>
    extends _$BalanceGameSetCopyWithImpl<$Res, _$BalanceGameSetImpl>
    implements _$$BalanceGameSetImplCopyWith<$Res> {
  __$$BalanceGameSetImplCopyWithImpl(
      _$BalanceGameSetImpl _value, $Res Function(_$BalanceGameSetImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceGameSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contentId = null,
    Object? description = freezed,
    Object? questionCount = null,
    Object? questions = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$BalanceGameSetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      questionCount: null == questionCount
          ? _value.questionCount
          : questionCount // ignore: cast_nullable_to_non_nullable
              as int,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<BalanceGameQuestion>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceGameSetImpl implements _BalanceGameSet {
  const _$BalanceGameSetImpl(
      {required this.id,
      required this.contentId,
      this.description,
      this.questionCount = 10,
      required final List<BalanceGameQuestion> questions,
      this.createdAt})
      : _questions = questions;

  factory _$BalanceGameSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceGameSetImplFromJson(json);

  @override
  final String id;
  @override
  final String contentId;
  @override
  final String? description;
  @override
  @JsonKey()
  final int questionCount;
  final List<BalanceGameQuestion> _questions;
  @override
  List<BalanceGameQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'BalanceGameSet(id: $id, contentId: $contentId, description: $description, questionCount: $questionCount, questions: $questions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceGameSetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      contentId,
      description,
      questionCount,
      const DeepCollectionEquality().hash(_questions),
      createdAt);

  /// Create a copy of BalanceGameSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceGameSetImplCopyWith<_$BalanceGameSetImpl> get copyWith =>
      __$$BalanceGameSetImplCopyWithImpl<_$BalanceGameSetImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceGameSetImplToJson(
      this,
    );
  }
}

abstract class _BalanceGameSet implements BalanceGameSet {
  const factory _BalanceGameSet(
      {required final String id,
      required final String contentId,
      final String? description,
      final int questionCount,
      required final List<BalanceGameQuestion> questions,
      final DateTime? createdAt}) = _$BalanceGameSetImpl;

  factory _BalanceGameSet.fromJson(Map<String, dynamic> json) =
      _$BalanceGameSetImpl.fromJson;

  @override
  String get id;
  @override
  String get contentId;
  @override
  String? get description;
  @override
  int get questionCount;
  @override
  List<BalanceGameQuestion> get questions;
  @override
  DateTime? get createdAt;

  /// Create a copy of BalanceGameSet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceGameSetImplCopyWith<_$BalanceGameSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BalanceGameQuestion _$BalanceGameQuestionFromJson(Map<String, dynamic> json) {
  return _BalanceGameQuestion.fromJson(json);
}

/// @nodoc
mixin _$BalanceGameQuestion {
  String get id => throw _privateConstructorUsedError;
  int get questionOrder => throw _privateConstructorUsedError;
  BalanceGameChoice get choiceA => throw _privateConstructorUsedError;
  BalanceGameChoice get choiceB => throw _privateConstructorUsedError;
  int get totalVotes => throw _privateConstructorUsedError;
  int get votesA => throw _privateConstructorUsedError;
  int get votesB => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BalanceGameQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceGameQuestionCopyWith<BalanceGameQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceGameQuestionCopyWith<$Res> {
  factory $BalanceGameQuestionCopyWith(
          BalanceGameQuestion value, $Res Function(BalanceGameQuestion) then) =
      _$BalanceGameQuestionCopyWithImpl<$Res, BalanceGameQuestion>;
  @useResult
  $Res call(
      {String id,
      int questionOrder,
      BalanceGameChoice choiceA,
      BalanceGameChoice choiceB,
      int totalVotes,
      int votesA,
      int votesB,
      DateTime? createdAt});

  $BalanceGameChoiceCopyWith<$Res> get choiceA;
  $BalanceGameChoiceCopyWith<$Res> get choiceB;
}

/// @nodoc
class _$BalanceGameQuestionCopyWithImpl<$Res, $Val extends BalanceGameQuestion>
    implements $BalanceGameQuestionCopyWith<$Res> {
  _$BalanceGameQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionOrder = null,
    Object? choiceA = null,
    Object? choiceB = null,
    Object? totalVotes = null,
    Object? votesA = null,
    Object? votesB = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      questionOrder: null == questionOrder
          ? _value.questionOrder
          : questionOrder // ignore: cast_nullable_to_non_nullable
              as int,
      choiceA: null == choiceA
          ? _value.choiceA
          : choiceA // ignore: cast_nullable_to_non_nullable
              as BalanceGameChoice,
      choiceB: null == choiceB
          ? _value.choiceB
          : choiceB // ignore: cast_nullable_to_non_nullable
              as BalanceGameChoice,
      totalVotes: null == totalVotes
          ? _value.totalVotes
          : totalVotes // ignore: cast_nullable_to_non_nullable
              as int,
      votesA: null == votesA
          ? _value.votesA
          : votesA // ignore: cast_nullable_to_non_nullable
              as int,
      votesB: null == votesB
          ? _value.votesB
          : votesB // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BalanceGameChoiceCopyWith<$Res> get choiceA {
    return $BalanceGameChoiceCopyWith<$Res>(_value.choiceA, (value) {
      return _then(_value.copyWith(choiceA: value) as $Val);
    });
  }

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BalanceGameChoiceCopyWith<$Res> get choiceB {
    return $BalanceGameChoiceCopyWith<$Res>(_value.choiceB, (value) {
      return _then(_value.copyWith(choiceB: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BalanceGameQuestionImplCopyWith<$Res>
    implements $BalanceGameQuestionCopyWith<$Res> {
  factory _$$BalanceGameQuestionImplCopyWith(_$BalanceGameQuestionImpl value,
          $Res Function(_$BalanceGameQuestionImpl) then) =
      __$$BalanceGameQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int questionOrder,
      BalanceGameChoice choiceA,
      BalanceGameChoice choiceB,
      int totalVotes,
      int votesA,
      int votesB,
      DateTime? createdAt});

  @override
  $BalanceGameChoiceCopyWith<$Res> get choiceA;
  @override
  $BalanceGameChoiceCopyWith<$Res> get choiceB;
}

/// @nodoc
class __$$BalanceGameQuestionImplCopyWithImpl<$Res>
    extends _$BalanceGameQuestionCopyWithImpl<$Res, _$BalanceGameQuestionImpl>
    implements _$$BalanceGameQuestionImplCopyWith<$Res> {
  __$$BalanceGameQuestionImplCopyWithImpl(_$BalanceGameQuestionImpl _value,
      $Res Function(_$BalanceGameQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionOrder = null,
    Object? choiceA = null,
    Object? choiceB = null,
    Object? totalVotes = null,
    Object? votesA = null,
    Object? votesB = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$BalanceGameQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      questionOrder: null == questionOrder
          ? _value.questionOrder
          : questionOrder // ignore: cast_nullable_to_non_nullable
              as int,
      choiceA: null == choiceA
          ? _value.choiceA
          : choiceA // ignore: cast_nullable_to_non_nullable
              as BalanceGameChoice,
      choiceB: null == choiceB
          ? _value.choiceB
          : choiceB // ignore: cast_nullable_to_non_nullable
              as BalanceGameChoice,
      totalVotes: null == totalVotes
          ? _value.totalVotes
          : totalVotes // ignore: cast_nullable_to_non_nullable
              as int,
      votesA: null == votesA
          ? _value.votesA
          : votesA // ignore: cast_nullable_to_non_nullable
              as int,
      votesB: null == votesB
          ? _value.votesB
          : votesB // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceGameQuestionImpl implements _BalanceGameQuestion {
  const _$BalanceGameQuestionImpl(
      {required this.id,
      required this.questionOrder,
      required this.choiceA,
      required this.choiceB,
      this.totalVotes = 0,
      this.votesA = 0,
      this.votesB = 0,
      this.createdAt});

  factory _$BalanceGameQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceGameQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final int questionOrder;
  @override
  final BalanceGameChoice choiceA;
  @override
  final BalanceGameChoice choiceB;
  @override
  @JsonKey()
  final int totalVotes;
  @override
  @JsonKey()
  final int votesA;
  @override
  @JsonKey()
  final int votesB;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'BalanceGameQuestion(id: $id, questionOrder: $questionOrder, choiceA: $choiceA, choiceB: $choiceB, totalVotes: $totalVotes, votesA: $votesA, votesB: $votesB, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceGameQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionOrder, questionOrder) ||
                other.questionOrder == questionOrder) &&
            (identical(other.choiceA, choiceA) || other.choiceA == choiceA) &&
            (identical(other.choiceB, choiceB) || other.choiceB == choiceB) &&
            (identical(other.totalVotes, totalVotes) ||
                other.totalVotes == totalVotes) &&
            (identical(other.votesA, votesA) || other.votesA == votesA) &&
            (identical(other.votesB, votesB) || other.votesB == votesB) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, questionOrder, choiceA,
      choiceB, totalVotes, votesA, votesB, createdAt);

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceGameQuestionImplCopyWith<_$BalanceGameQuestionImpl> get copyWith =>
      __$$BalanceGameQuestionImplCopyWithImpl<_$BalanceGameQuestionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceGameQuestionImplToJson(
      this,
    );
  }
}

abstract class _BalanceGameQuestion implements BalanceGameQuestion {
  const factory _BalanceGameQuestion(
      {required final String id,
      required final int questionOrder,
      required final BalanceGameChoice choiceA,
      required final BalanceGameChoice choiceB,
      final int totalVotes,
      final int votesA,
      final int votesB,
      final DateTime? createdAt}) = _$BalanceGameQuestionImpl;

  factory _BalanceGameQuestion.fromJson(Map<String, dynamic> json) =
      _$BalanceGameQuestionImpl.fromJson;

  @override
  String get id;
  @override
  int get questionOrder;
  @override
  BalanceGameChoice get choiceA;
  @override
  BalanceGameChoice get choiceB;
  @override
  int get totalVotes;
  @override
  int get votesA;
  @override
  int get votesB;
  @override
  DateTime? get createdAt;

  /// Create a copy of BalanceGameQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceGameQuestionImplCopyWith<_$BalanceGameQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BalanceGameChoice _$BalanceGameChoiceFromJson(Map<String, dynamic> json) {
  return _BalanceGameChoice.fromJson(json);
}

/// @nodoc
mixin _$BalanceGameChoice {
  String get text => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get emoji => throw _privateConstructorUsedError;

  /// Serializes this BalanceGameChoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceGameChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceGameChoiceCopyWith<BalanceGameChoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceGameChoiceCopyWith<$Res> {
  factory $BalanceGameChoiceCopyWith(
          BalanceGameChoice value, $Res Function(BalanceGameChoice) then) =
      _$BalanceGameChoiceCopyWithImpl<$Res, BalanceGameChoice>;
  @useResult
  $Res call({String text, String? imageUrl, String? emoji});
}

/// @nodoc
class _$BalanceGameChoiceCopyWithImpl<$Res, $Val extends BalanceGameChoice>
    implements $BalanceGameChoiceCopyWith<$Res> {
  _$BalanceGameChoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceGameChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? imageUrl = freezed,
    Object? emoji = freezed,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BalanceGameChoiceImplCopyWith<$Res>
    implements $BalanceGameChoiceCopyWith<$Res> {
  factory _$$BalanceGameChoiceImplCopyWith(_$BalanceGameChoiceImpl value,
          $Res Function(_$BalanceGameChoiceImpl) then) =
      __$$BalanceGameChoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, String? imageUrl, String? emoji});
}

/// @nodoc
class __$$BalanceGameChoiceImplCopyWithImpl<$Res>
    extends _$BalanceGameChoiceCopyWithImpl<$Res, _$BalanceGameChoiceImpl>
    implements _$$BalanceGameChoiceImplCopyWith<$Res> {
  __$$BalanceGameChoiceImplCopyWithImpl(_$BalanceGameChoiceImpl _value,
      $Res Function(_$BalanceGameChoiceImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceGameChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? imageUrl = freezed,
    Object? emoji = freezed,
  }) {
    return _then(_$BalanceGameChoiceImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceGameChoiceImpl implements _BalanceGameChoice {
  const _$BalanceGameChoiceImpl(
      {required this.text, this.imageUrl, this.emoji});

  factory _$BalanceGameChoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceGameChoiceImplFromJson(json);

  @override
  final String text;
  @override
  final String? imageUrl;
  @override
  final String? emoji;

  @override
  String toString() {
    return 'BalanceGameChoice(text: $text, imageUrl: $imageUrl, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceGameChoiceImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, imageUrl, emoji);

  /// Create a copy of BalanceGameChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceGameChoiceImplCopyWith<_$BalanceGameChoiceImpl> get copyWith =>
      __$$BalanceGameChoiceImplCopyWithImpl<_$BalanceGameChoiceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceGameChoiceImplToJson(
      this,
    );
  }
}

abstract class _BalanceGameChoice implements BalanceGameChoice {
  const factory _BalanceGameChoice(
      {required final String text,
      final String? imageUrl,
      final String? emoji}) = _$BalanceGameChoiceImpl;

  factory _BalanceGameChoice.fromJson(Map<String, dynamic> json) =
      _$BalanceGameChoiceImpl.fromJson;

  @override
  String get text;
  @override
  String? get imageUrl;
  @override
  String? get emoji;

  /// Create a copy of BalanceGameChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceGameChoiceImplCopyWith<_$BalanceGameChoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BalanceQuestionStats _$BalanceQuestionStatsFromJson(Map<String, dynamic> json) {
  return _BalanceQuestionStats.fromJson(json);
}

/// @nodoc
mixin _$BalanceQuestionStats {
  String get questionId => throw _privateConstructorUsedError;
  int get totalVotes => throw _privateConstructorUsedError;
  int get votesA => throw _privateConstructorUsedError;
  int get votesB => throw _privateConstructorUsedError;

  /// Serializes this BalanceQuestionStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceQuestionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceQuestionStatsCopyWith<BalanceQuestionStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceQuestionStatsCopyWith<$Res> {
  factory $BalanceQuestionStatsCopyWith(BalanceQuestionStats value,
          $Res Function(BalanceQuestionStats) then) =
      _$BalanceQuestionStatsCopyWithImpl<$Res, BalanceQuestionStats>;
  @useResult
  $Res call({String questionId, int totalVotes, int votesA, int votesB});
}

/// @nodoc
class _$BalanceQuestionStatsCopyWithImpl<$Res,
        $Val extends BalanceQuestionStats>
    implements $BalanceQuestionStatsCopyWith<$Res> {
  _$BalanceQuestionStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceQuestionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? totalVotes = null,
    Object? votesA = null,
    Object? votesB = null,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      totalVotes: null == totalVotes
          ? _value.totalVotes
          : totalVotes // ignore: cast_nullable_to_non_nullable
              as int,
      votesA: null == votesA
          ? _value.votesA
          : votesA // ignore: cast_nullable_to_non_nullable
              as int,
      votesB: null == votesB
          ? _value.votesB
          : votesB // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BalanceQuestionStatsImplCopyWith<$Res>
    implements $BalanceQuestionStatsCopyWith<$Res> {
  factory _$$BalanceQuestionStatsImplCopyWith(_$BalanceQuestionStatsImpl value,
          $Res Function(_$BalanceQuestionStatsImpl) then) =
      __$$BalanceQuestionStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String questionId, int totalVotes, int votesA, int votesB});
}

/// @nodoc
class __$$BalanceQuestionStatsImplCopyWithImpl<$Res>
    extends _$BalanceQuestionStatsCopyWithImpl<$Res, _$BalanceQuestionStatsImpl>
    implements _$$BalanceQuestionStatsImplCopyWith<$Res> {
  __$$BalanceQuestionStatsImplCopyWithImpl(_$BalanceQuestionStatsImpl _value,
      $Res Function(_$BalanceQuestionStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceQuestionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? totalVotes = null,
    Object? votesA = null,
    Object? votesB = null,
  }) {
    return _then(_$BalanceQuestionStatsImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      totalVotes: null == totalVotes
          ? _value.totalVotes
          : totalVotes // ignore: cast_nullable_to_non_nullable
              as int,
      votesA: null == votesA
          ? _value.votesA
          : votesA // ignore: cast_nullable_to_non_nullable
              as int,
      votesB: null == votesB
          ? _value.votesB
          : votesB // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceQuestionStatsImpl extends _BalanceQuestionStats {
  const _$BalanceQuestionStatsImpl(
      {required this.questionId,
      required this.totalVotes,
      required this.votesA,
      required this.votesB})
      : super._();

  factory _$BalanceQuestionStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceQuestionStatsImplFromJson(json);

  @override
  final String questionId;
  @override
  final int totalVotes;
  @override
  final int votesA;
  @override
  final int votesB;

  @override
  String toString() {
    return 'BalanceQuestionStats(questionId: $questionId, totalVotes: $totalVotes, votesA: $votesA, votesB: $votesB)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceQuestionStatsImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.totalVotes, totalVotes) ||
                other.totalVotes == totalVotes) &&
            (identical(other.votesA, votesA) || other.votesA == votesA) &&
            (identical(other.votesB, votesB) || other.votesB == votesB));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, questionId, totalVotes, votesA, votesB);

  /// Create a copy of BalanceQuestionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceQuestionStatsImplCopyWith<_$BalanceQuestionStatsImpl>
      get copyWith =>
          __$$BalanceQuestionStatsImplCopyWithImpl<_$BalanceQuestionStatsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceQuestionStatsImplToJson(
      this,
    );
  }
}

abstract class _BalanceQuestionStats extends BalanceQuestionStats {
  const factory _BalanceQuestionStats(
      {required final String questionId,
      required final int totalVotes,
      required final int votesA,
      required final int votesB}) = _$BalanceQuestionStatsImpl;
  const _BalanceQuestionStats._() : super._();

  factory _BalanceQuestionStats.fromJson(Map<String, dynamic> json) =
      _$BalanceQuestionStatsImpl.fromJson;

  @override
  String get questionId;
  @override
  int get totalVotes;
  @override
  int get votesA;
  @override
  int get votesB;

  /// Create a copy of BalanceQuestionStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceQuestionStatsImplCopyWith<_$BalanceQuestionStatsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UserBalanceResult _$UserBalanceResultFromJson(Map<String, dynamic> json) {
  return _UserBalanceResult.fromJson(json);
}

/// @nodoc
mixin _$UserBalanceResult {
  String get id => throw _privateConstructorUsedError;
  String get gameSetId => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;
  int get majorityMatchCount => throw _privateConstructorUsedError;
  bool get isShared => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this UserBalanceResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserBalanceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserBalanceResultCopyWith<UserBalanceResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserBalanceResultCopyWith<$Res> {
  factory $UserBalanceResultCopyWith(
          UserBalanceResult value, $Res Function(UserBalanceResult) then) =
      _$UserBalanceResultCopyWithImpl<$Res, UserBalanceResult>;
  @useResult
  $Res call(
      {String id,
      String gameSetId,
      Map<String, String> answers,
      int majorityMatchCount,
      bool isShared,
      DateTime? completedAt});
}

/// @nodoc
class _$UserBalanceResultCopyWithImpl<$Res, $Val extends UserBalanceResult>
    implements $UserBalanceResultCopyWith<$Res> {
  _$UserBalanceResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserBalanceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameSetId = null,
    Object? answers = null,
    Object? majorityMatchCount = null,
    Object? isShared = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      majorityMatchCount: null == majorityMatchCount
          ? _value.majorityMatchCount
          : majorityMatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      isShared: null == isShared
          ? _value.isShared
          : isShared // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserBalanceResultImplCopyWith<$Res>
    implements $UserBalanceResultCopyWith<$Res> {
  factory _$$UserBalanceResultImplCopyWith(_$UserBalanceResultImpl value,
          $Res Function(_$UserBalanceResultImpl) then) =
      __$$UserBalanceResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String gameSetId,
      Map<String, String> answers,
      int majorityMatchCount,
      bool isShared,
      DateTime? completedAt});
}

/// @nodoc
class __$$UserBalanceResultImplCopyWithImpl<$Res>
    extends _$UserBalanceResultCopyWithImpl<$Res, _$UserBalanceResultImpl>
    implements _$$UserBalanceResultImplCopyWith<$Res> {
  __$$UserBalanceResultImplCopyWithImpl(_$UserBalanceResultImpl _value,
      $Res Function(_$UserBalanceResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserBalanceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameSetId = null,
    Object? answers = null,
    Object? majorityMatchCount = null,
    Object? isShared = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$UserBalanceResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      majorityMatchCount: null == majorityMatchCount
          ? _value.majorityMatchCount
          : majorityMatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      isShared: null == isShared
          ? _value.isShared
          : isShared // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserBalanceResultImpl implements _UserBalanceResult {
  const _$UserBalanceResultImpl(
      {required this.id,
      required this.gameSetId,
      required final Map<String, String> answers,
      this.majorityMatchCount = 0,
      this.isShared = false,
      this.completedAt})
      : _answers = answers;

  factory _$UserBalanceResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserBalanceResultImplFromJson(json);

  @override
  final String id;
  @override
  final String gameSetId;
  final Map<String, String> _answers;
  @override
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  @JsonKey()
  final int majorityMatchCount;
  @override
  @JsonKey()
  final bool isShared;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'UserBalanceResult(id: $id, gameSetId: $gameSetId, answers: $answers, majorityMatchCount: $majorityMatchCount, isShared: $isShared, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserBalanceResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameSetId, gameSetId) ||
                other.gameSetId == gameSetId) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.majorityMatchCount, majorityMatchCount) ||
                other.majorityMatchCount == majorityMatchCount) &&
            (identical(other.isShared, isShared) ||
                other.isShared == isShared) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      gameSetId,
      const DeepCollectionEquality().hash(_answers),
      majorityMatchCount,
      isShared,
      completedAt);

  /// Create a copy of UserBalanceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserBalanceResultImplCopyWith<_$UserBalanceResultImpl> get copyWith =>
      __$$UserBalanceResultImplCopyWithImpl<_$UserBalanceResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserBalanceResultImplToJson(
      this,
    );
  }
}

abstract class _UserBalanceResult implements UserBalanceResult {
  const factory _UserBalanceResult(
      {required final String id,
      required final String gameSetId,
      required final Map<String, String> answers,
      final int majorityMatchCount,
      final bool isShared,
      final DateTime? completedAt}) = _$UserBalanceResultImpl;

  factory _UserBalanceResult.fromJson(Map<String, dynamic> json) =
      _$UserBalanceResultImpl.fromJson;

  @override
  String get id;
  @override
  String get gameSetId;
  @override
  Map<String, String> get answers;
  @override
  int get majorityMatchCount;
  @override
  bool get isShared;
  @override
  DateTime? get completedAt;

  /// Create a copy of UserBalanceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserBalanceResultImplCopyWith<_$UserBalanceResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BalanceGameState _$BalanceGameStateFromJson(Map<String, dynamic> json) {
  return _BalanceGameState.fromJson(json);
}

/// @nodoc
mixin _$BalanceGameState {
  String get gameSetId => throw _privateConstructorUsedError;
  int get currentQuestionIndex => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;
  BalanceGameQuestion? get currentQuestion =>
      throw _privateConstructorUsedError;
  bool get showStats => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this BalanceGameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceGameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceGameStateCopyWith<BalanceGameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceGameStateCopyWith<$Res> {
  factory $BalanceGameStateCopyWith(
          BalanceGameState value, $Res Function(BalanceGameState) then) =
      _$BalanceGameStateCopyWithImpl<$Res, BalanceGameState>;
  @useResult
  $Res call(
      {String gameSetId,
      int currentQuestionIndex,
      int totalQuestions,
      Map<String, String> answers,
      BalanceGameQuestion? currentQuestion,
      bool showStats,
      bool isCompleted});

  $BalanceGameQuestionCopyWith<$Res>? get currentQuestion;
}

/// @nodoc
class _$BalanceGameStateCopyWithImpl<$Res, $Val extends BalanceGameState>
    implements $BalanceGameStateCopyWith<$Res> {
  _$BalanceGameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceGameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameSetId = null,
    Object? currentQuestionIndex = null,
    Object? totalQuestions = null,
    Object? answers = null,
    Object? currentQuestion = freezed,
    Object? showStats = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      currentQuestionIndex: null == currentQuestionIndex
          ? _value.currentQuestionIndex
          : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      currentQuestion: freezed == currentQuestion
          ? _value.currentQuestion
          : currentQuestion // ignore: cast_nullable_to_non_nullable
              as BalanceGameQuestion?,
      showStats: null == showStats
          ? _value.showStats
          : showStats // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of BalanceGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BalanceGameQuestionCopyWith<$Res>? get currentQuestion {
    if (_value.currentQuestion == null) {
      return null;
    }

    return $BalanceGameQuestionCopyWith<$Res>(_value.currentQuestion!, (value) {
      return _then(_value.copyWith(currentQuestion: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BalanceGameStateImplCopyWith<$Res>
    implements $BalanceGameStateCopyWith<$Res> {
  factory _$$BalanceGameStateImplCopyWith(_$BalanceGameStateImpl value,
          $Res Function(_$BalanceGameStateImpl) then) =
      __$$BalanceGameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gameSetId,
      int currentQuestionIndex,
      int totalQuestions,
      Map<String, String> answers,
      BalanceGameQuestion? currentQuestion,
      bool showStats,
      bool isCompleted});

  @override
  $BalanceGameQuestionCopyWith<$Res>? get currentQuestion;
}

/// @nodoc
class __$$BalanceGameStateImplCopyWithImpl<$Res>
    extends _$BalanceGameStateCopyWithImpl<$Res, _$BalanceGameStateImpl>
    implements _$$BalanceGameStateImplCopyWith<$Res> {
  __$$BalanceGameStateImplCopyWithImpl(_$BalanceGameStateImpl _value,
      $Res Function(_$BalanceGameStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceGameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameSetId = null,
    Object? currentQuestionIndex = null,
    Object? totalQuestions = null,
    Object? answers = null,
    Object? currentQuestion = freezed,
    Object? showStats = null,
    Object? isCompleted = null,
  }) {
    return _then(_$BalanceGameStateImpl(
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      currentQuestionIndex: null == currentQuestionIndex
          ? _value.currentQuestionIndex
          : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      currentQuestion: freezed == currentQuestion
          ? _value.currentQuestion
          : currentQuestion // ignore: cast_nullable_to_non_nullable
              as BalanceGameQuestion?,
      showStats: null == showStats
          ? _value.showStats
          : showStats // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceGameStateImpl implements _BalanceGameState {
  const _$BalanceGameStateImpl(
      {required this.gameSetId,
      required this.currentQuestionIndex,
      required this.totalQuestions,
      required final Map<String, String> answers,
      this.currentQuestion,
      this.showStats = false,
      this.isCompleted = false})
      : _answers = answers;

  factory _$BalanceGameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceGameStateImplFromJson(json);

  @override
  final String gameSetId;
  @override
  final int currentQuestionIndex;
  @override
  final int totalQuestions;
  final Map<String, String> _answers;
  @override
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  final BalanceGameQuestion? currentQuestion;
  @override
  @JsonKey()
  final bool showStats;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'BalanceGameState(gameSetId: $gameSetId, currentQuestionIndex: $currentQuestionIndex, totalQuestions: $totalQuestions, answers: $answers, currentQuestion: $currentQuestion, showStats: $showStats, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceGameStateImpl &&
            (identical(other.gameSetId, gameSetId) ||
                other.gameSetId == gameSetId) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.currentQuestion, currentQuestion) ||
                other.currentQuestion == currentQuestion) &&
            (identical(other.showStats, showStats) ||
                other.showStats == showStats) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      gameSetId,
      currentQuestionIndex,
      totalQuestions,
      const DeepCollectionEquality().hash(_answers),
      currentQuestion,
      showStats,
      isCompleted);

  /// Create a copy of BalanceGameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceGameStateImplCopyWith<_$BalanceGameStateImpl> get copyWith =>
      __$$BalanceGameStateImplCopyWithImpl<_$BalanceGameStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceGameStateImplToJson(
      this,
    );
  }
}

abstract class _BalanceGameState implements BalanceGameState {
  const factory _BalanceGameState(
      {required final String gameSetId,
      required final int currentQuestionIndex,
      required final int totalQuestions,
      required final Map<String, String> answers,
      final BalanceGameQuestion? currentQuestion,
      final bool showStats,
      final bool isCompleted}) = _$BalanceGameStateImpl;

  factory _BalanceGameState.fromJson(Map<String, dynamic> json) =
      _$BalanceGameStateImpl.fromJson;

  @override
  String get gameSetId;
  @override
  int get currentQuestionIndex;
  @override
  int get totalQuestions;
  @override
  Map<String, String> get answers;
  @override
  BalanceGameQuestion? get currentQuestion;
  @override
  bool get showStats;
  @override
  bool get isCompleted;

  /// Create a copy of BalanceGameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceGameStateImplCopyWith<_$BalanceGameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BalanceGameSummary _$BalanceGameSummaryFromJson(Map<String, dynamic> json) {
  return _BalanceGameSummary.fromJson(json);
}

/// @nodoc
mixin _$BalanceGameSummary {
  String get gameSetId => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get majorityMatchCount => throw _privateConstructorUsedError;
  int get minorityCount => throw _privateConstructorUsedError;
  List<BalanceQuestionSummary> get questionSummaries =>
      throw _privateConstructorUsedError;
  String? get personalityType => throw _privateConstructorUsedError;
  String? get analysis => throw _privateConstructorUsedError;

  /// Serializes this BalanceGameSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceGameSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceGameSummaryCopyWith<BalanceGameSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceGameSummaryCopyWith<$Res> {
  factory $BalanceGameSummaryCopyWith(
          BalanceGameSummary value, $Res Function(BalanceGameSummary) then) =
      _$BalanceGameSummaryCopyWithImpl<$Res, BalanceGameSummary>;
  @useResult
  $Res call(
      {String gameSetId,
      int totalQuestions,
      int majorityMatchCount,
      int minorityCount,
      List<BalanceQuestionSummary> questionSummaries,
      String? personalityType,
      String? analysis});
}

/// @nodoc
class _$BalanceGameSummaryCopyWithImpl<$Res, $Val extends BalanceGameSummary>
    implements $BalanceGameSummaryCopyWith<$Res> {
  _$BalanceGameSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceGameSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameSetId = null,
    Object? totalQuestions = null,
    Object? majorityMatchCount = null,
    Object? minorityCount = null,
    Object? questionSummaries = null,
    Object? personalityType = freezed,
    Object? analysis = freezed,
  }) {
    return _then(_value.copyWith(
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      majorityMatchCount: null == majorityMatchCount
          ? _value.majorityMatchCount
          : majorityMatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      minorityCount: null == minorityCount
          ? _value.minorityCount
          : minorityCount // ignore: cast_nullable_to_non_nullable
              as int,
      questionSummaries: null == questionSummaries
          ? _value.questionSummaries
          : questionSummaries // ignore: cast_nullable_to_non_nullable
              as List<BalanceQuestionSummary>,
      personalityType: freezed == personalityType
          ? _value.personalityType
          : personalityType // ignore: cast_nullable_to_non_nullable
              as String?,
      analysis: freezed == analysis
          ? _value.analysis
          : analysis // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BalanceGameSummaryImplCopyWith<$Res>
    implements $BalanceGameSummaryCopyWith<$Res> {
  factory _$$BalanceGameSummaryImplCopyWith(_$BalanceGameSummaryImpl value,
          $Res Function(_$BalanceGameSummaryImpl) then) =
      __$$BalanceGameSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gameSetId,
      int totalQuestions,
      int majorityMatchCount,
      int minorityCount,
      List<BalanceQuestionSummary> questionSummaries,
      String? personalityType,
      String? analysis});
}

/// @nodoc
class __$$BalanceGameSummaryImplCopyWithImpl<$Res>
    extends _$BalanceGameSummaryCopyWithImpl<$Res, _$BalanceGameSummaryImpl>
    implements _$$BalanceGameSummaryImplCopyWith<$Res> {
  __$$BalanceGameSummaryImplCopyWithImpl(_$BalanceGameSummaryImpl _value,
      $Res Function(_$BalanceGameSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceGameSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameSetId = null,
    Object? totalQuestions = null,
    Object? majorityMatchCount = null,
    Object? minorityCount = null,
    Object? questionSummaries = null,
    Object? personalityType = freezed,
    Object? analysis = freezed,
  }) {
    return _then(_$BalanceGameSummaryImpl(
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      majorityMatchCount: null == majorityMatchCount
          ? _value.majorityMatchCount
          : majorityMatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      minorityCount: null == minorityCount
          ? _value.minorityCount
          : minorityCount // ignore: cast_nullable_to_non_nullable
              as int,
      questionSummaries: null == questionSummaries
          ? _value._questionSummaries
          : questionSummaries // ignore: cast_nullable_to_non_nullable
              as List<BalanceQuestionSummary>,
      personalityType: freezed == personalityType
          ? _value.personalityType
          : personalityType // ignore: cast_nullable_to_non_nullable
              as String?,
      analysis: freezed == analysis
          ? _value.analysis
          : analysis // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceGameSummaryImpl extends _BalanceGameSummary {
  const _$BalanceGameSummaryImpl(
      {required this.gameSetId,
      required this.totalQuestions,
      required this.majorityMatchCount,
      required this.minorityCount,
      required final List<BalanceQuestionSummary> questionSummaries,
      this.personalityType,
      this.analysis})
      : _questionSummaries = questionSummaries,
        super._();

  factory _$BalanceGameSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceGameSummaryImplFromJson(json);

  @override
  final String gameSetId;
  @override
  final int totalQuestions;
  @override
  final int majorityMatchCount;
  @override
  final int minorityCount;
  final List<BalanceQuestionSummary> _questionSummaries;
  @override
  List<BalanceQuestionSummary> get questionSummaries {
    if (_questionSummaries is EqualUnmodifiableListView)
      return _questionSummaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questionSummaries);
  }

  @override
  final String? personalityType;
  @override
  final String? analysis;

  @override
  String toString() {
    return 'BalanceGameSummary(gameSetId: $gameSetId, totalQuestions: $totalQuestions, majorityMatchCount: $majorityMatchCount, minorityCount: $minorityCount, questionSummaries: $questionSummaries, personalityType: $personalityType, analysis: $analysis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceGameSummaryImpl &&
            (identical(other.gameSetId, gameSetId) ||
                other.gameSetId == gameSetId) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.majorityMatchCount, majorityMatchCount) ||
                other.majorityMatchCount == majorityMatchCount) &&
            (identical(other.minorityCount, minorityCount) ||
                other.minorityCount == minorityCount) &&
            const DeepCollectionEquality()
                .equals(other._questionSummaries, _questionSummaries) &&
            (identical(other.personalityType, personalityType) ||
                other.personalityType == personalityType) &&
            (identical(other.analysis, analysis) ||
                other.analysis == analysis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      gameSetId,
      totalQuestions,
      majorityMatchCount,
      minorityCount,
      const DeepCollectionEquality().hash(_questionSummaries),
      personalityType,
      analysis);

  /// Create a copy of BalanceGameSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceGameSummaryImplCopyWith<_$BalanceGameSummaryImpl> get copyWith =>
      __$$BalanceGameSummaryImplCopyWithImpl<_$BalanceGameSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceGameSummaryImplToJson(
      this,
    );
  }
}

abstract class _BalanceGameSummary extends BalanceGameSummary {
  const factory _BalanceGameSummary(
      {required final String gameSetId,
      required final int totalQuestions,
      required final int majorityMatchCount,
      required final int minorityCount,
      required final List<BalanceQuestionSummary> questionSummaries,
      final String? personalityType,
      final String? analysis}) = _$BalanceGameSummaryImpl;
  const _BalanceGameSummary._() : super._();

  factory _BalanceGameSummary.fromJson(Map<String, dynamic> json) =
      _$BalanceGameSummaryImpl.fromJson;

  @override
  String get gameSetId;
  @override
  int get totalQuestions;
  @override
  int get majorityMatchCount;
  @override
  int get minorityCount;
  @override
  List<BalanceQuestionSummary> get questionSummaries;
  @override
  String? get personalityType;
  @override
  String? get analysis;

  /// Create a copy of BalanceGameSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceGameSummaryImplCopyWith<_$BalanceGameSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BalanceQuestionSummary _$BalanceQuestionSummaryFromJson(
    Map<String, dynamic> json) {
  return _BalanceQuestionSummary.fromJson(json);
}

/// @nodoc
mixin _$BalanceQuestionSummary {
  String get questionId => throw _privateConstructorUsedError;
  String get userChoice => throw _privateConstructorUsedError;
  String get majorityChoice => throw _privateConstructorUsedError;
  bool get isMajority => throw _privateConstructorUsedError;
  double get userChoicePercentage => throw _privateConstructorUsedError;
  String get choiceAText => throw _privateConstructorUsedError;
  String get choiceBText => throw _privateConstructorUsedError;
  double get percentageA => throw _privateConstructorUsedError;
  double get percentageB => throw _privateConstructorUsedError;

  /// Serializes this BalanceQuestionSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceQuestionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceQuestionSummaryCopyWith<BalanceQuestionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceQuestionSummaryCopyWith<$Res> {
  factory $BalanceQuestionSummaryCopyWith(BalanceQuestionSummary value,
          $Res Function(BalanceQuestionSummary) then) =
      _$BalanceQuestionSummaryCopyWithImpl<$Res, BalanceQuestionSummary>;
  @useResult
  $Res call(
      {String questionId,
      String userChoice,
      String majorityChoice,
      bool isMajority,
      double userChoicePercentage,
      String choiceAText,
      String choiceBText,
      double percentageA,
      double percentageB});
}

/// @nodoc
class _$BalanceQuestionSummaryCopyWithImpl<$Res,
        $Val extends BalanceQuestionSummary>
    implements $BalanceQuestionSummaryCopyWith<$Res> {
  _$BalanceQuestionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceQuestionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? userChoice = null,
    Object? majorityChoice = null,
    Object? isMajority = null,
    Object? userChoicePercentage = null,
    Object? choiceAText = null,
    Object? choiceBText = null,
    Object? percentageA = null,
    Object? percentageB = null,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      userChoice: null == userChoice
          ? _value.userChoice
          : userChoice // ignore: cast_nullable_to_non_nullable
              as String,
      majorityChoice: null == majorityChoice
          ? _value.majorityChoice
          : majorityChoice // ignore: cast_nullable_to_non_nullable
              as String,
      isMajority: null == isMajority
          ? _value.isMajority
          : isMajority // ignore: cast_nullable_to_non_nullable
              as bool,
      userChoicePercentage: null == userChoicePercentage
          ? _value.userChoicePercentage
          : userChoicePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      choiceAText: null == choiceAText
          ? _value.choiceAText
          : choiceAText // ignore: cast_nullable_to_non_nullable
              as String,
      choiceBText: null == choiceBText
          ? _value.choiceBText
          : choiceBText // ignore: cast_nullable_to_non_nullable
              as String,
      percentageA: null == percentageA
          ? _value.percentageA
          : percentageA // ignore: cast_nullable_to_non_nullable
              as double,
      percentageB: null == percentageB
          ? _value.percentageB
          : percentageB // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BalanceQuestionSummaryImplCopyWith<$Res>
    implements $BalanceQuestionSummaryCopyWith<$Res> {
  factory _$$BalanceQuestionSummaryImplCopyWith(
          _$BalanceQuestionSummaryImpl value,
          $Res Function(_$BalanceQuestionSummaryImpl) then) =
      __$$BalanceQuestionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String questionId,
      String userChoice,
      String majorityChoice,
      bool isMajority,
      double userChoicePercentage,
      String choiceAText,
      String choiceBText,
      double percentageA,
      double percentageB});
}

/// @nodoc
class __$$BalanceQuestionSummaryImplCopyWithImpl<$Res>
    extends _$BalanceQuestionSummaryCopyWithImpl<$Res,
        _$BalanceQuestionSummaryImpl>
    implements _$$BalanceQuestionSummaryImplCopyWith<$Res> {
  __$$BalanceQuestionSummaryImplCopyWithImpl(
      _$BalanceQuestionSummaryImpl _value,
      $Res Function(_$BalanceQuestionSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceQuestionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? userChoice = null,
    Object? majorityChoice = null,
    Object? isMajority = null,
    Object? userChoicePercentage = null,
    Object? choiceAText = null,
    Object? choiceBText = null,
    Object? percentageA = null,
    Object? percentageB = null,
  }) {
    return _then(_$BalanceQuestionSummaryImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      userChoice: null == userChoice
          ? _value.userChoice
          : userChoice // ignore: cast_nullable_to_non_nullable
              as String,
      majorityChoice: null == majorityChoice
          ? _value.majorityChoice
          : majorityChoice // ignore: cast_nullable_to_non_nullable
              as String,
      isMajority: null == isMajority
          ? _value.isMajority
          : isMajority // ignore: cast_nullable_to_non_nullable
              as bool,
      userChoicePercentage: null == userChoicePercentage
          ? _value.userChoicePercentage
          : userChoicePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      choiceAText: null == choiceAText
          ? _value.choiceAText
          : choiceAText // ignore: cast_nullable_to_non_nullable
              as String,
      choiceBText: null == choiceBText
          ? _value.choiceBText
          : choiceBText // ignore: cast_nullable_to_non_nullable
              as String,
      percentageA: null == percentageA
          ? _value.percentageA
          : percentageA // ignore: cast_nullable_to_non_nullable
              as double,
      percentageB: null == percentageB
          ? _value.percentageB
          : percentageB // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceQuestionSummaryImpl implements _BalanceQuestionSummary {
  const _$BalanceQuestionSummaryImpl(
      {required this.questionId,
      required this.userChoice,
      required this.majorityChoice,
      required this.isMajority,
      required this.userChoicePercentage,
      required this.choiceAText,
      required this.choiceBText,
      required this.percentageA,
      required this.percentageB});

  factory _$BalanceQuestionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceQuestionSummaryImplFromJson(json);

  @override
  final String questionId;
  @override
  final String userChoice;
  @override
  final String majorityChoice;
  @override
  final bool isMajority;
  @override
  final double userChoicePercentage;
  @override
  final String choiceAText;
  @override
  final String choiceBText;
  @override
  final double percentageA;
  @override
  final double percentageB;

  @override
  String toString() {
    return 'BalanceQuestionSummary(questionId: $questionId, userChoice: $userChoice, majorityChoice: $majorityChoice, isMajority: $isMajority, userChoicePercentage: $userChoicePercentage, choiceAText: $choiceAText, choiceBText: $choiceBText, percentageA: $percentageA, percentageB: $percentageB)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceQuestionSummaryImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.userChoice, userChoice) ||
                other.userChoice == userChoice) &&
            (identical(other.majorityChoice, majorityChoice) ||
                other.majorityChoice == majorityChoice) &&
            (identical(other.isMajority, isMajority) ||
                other.isMajority == isMajority) &&
            (identical(other.userChoicePercentage, userChoicePercentage) ||
                other.userChoicePercentage == userChoicePercentage) &&
            (identical(other.choiceAText, choiceAText) ||
                other.choiceAText == choiceAText) &&
            (identical(other.choiceBText, choiceBText) ||
                other.choiceBText == choiceBText) &&
            (identical(other.percentageA, percentageA) ||
                other.percentageA == percentageA) &&
            (identical(other.percentageB, percentageB) ||
                other.percentageB == percentageB));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      userChoice,
      majorityChoice,
      isMajority,
      userChoicePercentage,
      choiceAText,
      choiceBText,
      percentageA,
      percentageB);

  /// Create a copy of BalanceQuestionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceQuestionSummaryImplCopyWith<_$BalanceQuestionSummaryImpl>
      get copyWith => __$$BalanceQuestionSummaryImplCopyWithImpl<
          _$BalanceQuestionSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceQuestionSummaryImplToJson(
      this,
    );
  }
}

abstract class _BalanceQuestionSummary implements BalanceQuestionSummary {
  const factory _BalanceQuestionSummary(
      {required final String questionId,
      required final String userChoice,
      required final String majorityChoice,
      required final bool isMajority,
      required final double userChoicePercentage,
      required final String choiceAText,
      required final String choiceBText,
      required final double percentageA,
      required final double percentageB}) = _$BalanceQuestionSummaryImpl;

  factory _BalanceQuestionSummary.fromJson(Map<String, dynamic> json) =
      _$BalanceQuestionSummaryImpl.fromJson;

  @override
  String get questionId;
  @override
  String get userChoice;
  @override
  String get majorityChoice;
  @override
  bool get isMajority;
  @override
  double get userChoicePercentage;
  @override
  String get choiceAText;
  @override
  String get choiceBText;
  @override
  double get percentageA;
  @override
  double get percentageB;

  /// Create a copy of BalanceQuestionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceQuestionSummaryImplCopyWith<_$BalanceQuestionSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BalanceGameSubmission _$BalanceGameSubmissionFromJson(
    Map<String, dynamic> json) {
  return _BalanceGameSubmission.fromJson(json);
}

/// @nodoc
mixin _$BalanceGameSubmission {
  String get gameSetId => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;

  /// Serializes this BalanceGameSubmission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BalanceGameSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BalanceGameSubmissionCopyWith<BalanceGameSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BalanceGameSubmissionCopyWith<$Res> {
  factory $BalanceGameSubmissionCopyWith(BalanceGameSubmission value,
          $Res Function(BalanceGameSubmission) then) =
      _$BalanceGameSubmissionCopyWithImpl<$Res, BalanceGameSubmission>;
  @useResult
  $Res call({String gameSetId, Map<String, String> answers});
}

/// @nodoc
class _$BalanceGameSubmissionCopyWithImpl<$Res,
        $Val extends BalanceGameSubmission>
    implements $BalanceGameSubmissionCopyWith<$Res> {
  _$BalanceGameSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BalanceGameSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameSetId = null,
    Object? answers = null,
  }) {
    return _then(_value.copyWith(
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BalanceGameSubmissionImplCopyWith<$Res>
    implements $BalanceGameSubmissionCopyWith<$Res> {
  factory _$$BalanceGameSubmissionImplCopyWith(
          _$BalanceGameSubmissionImpl value,
          $Res Function(_$BalanceGameSubmissionImpl) then) =
      __$$BalanceGameSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String gameSetId, Map<String, String> answers});
}

/// @nodoc
class __$$BalanceGameSubmissionImplCopyWithImpl<$Res>
    extends _$BalanceGameSubmissionCopyWithImpl<$Res,
        _$BalanceGameSubmissionImpl>
    implements _$$BalanceGameSubmissionImplCopyWith<$Res> {
  __$$BalanceGameSubmissionImplCopyWithImpl(_$BalanceGameSubmissionImpl _value,
      $Res Function(_$BalanceGameSubmissionImpl) _then)
      : super(_value, _then);

  /// Create a copy of BalanceGameSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameSetId = null,
    Object? answers = null,
  }) {
    return _then(_$BalanceGameSubmissionImpl(
      gameSetId: null == gameSetId
          ? _value.gameSetId
          : gameSetId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BalanceGameSubmissionImpl implements _BalanceGameSubmission {
  const _$BalanceGameSubmissionImpl(
      {required this.gameSetId, required final Map<String, String> answers})
      : _answers = answers;

  factory _$BalanceGameSubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BalanceGameSubmissionImplFromJson(json);

  @override
  final String gameSetId;
  final Map<String, String> _answers;
  @override
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  String toString() {
    return 'BalanceGameSubmission(gameSetId: $gameSetId, answers: $answers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BalanceGameSubmissionImpl &&
            (identical(other.gameSetId, gameSetId) ||
                other.gameSetId == gameSetId) &&
            const DeepCollectionEquality().equals(other._answers, _answers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, gameSetId, const DeepCollectionEquality().hash(_answers));

  /// Create a copy of BalanceGameSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BalanceGameSubmissionImplCopyWith<_$BalanceGameSubmissionImpl>
      get copyWith => __$$BalanceGameSubmissionImplCopyWithImpl<
          _$BalanceGameSubmissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BalanceGameSubmissionImplToJson(
      this,
    );
  }
}

abstract class _BalanceGameSubmission implements BalanceGameSubmission {
  const factory _BalanceGameSubmission(
          {required final String gameSetId,
          required final Map<String, String> answers}) =
      _$BalanceGameSubmissionImpl;

  factory _BalanceGameSubmission.fromJson(Map<String, dynamic> json) =
      _$BalanceGameSubmissionImpl.fromJson;

  @override
  String get gameSetId;
  @override
  Map<String, String> get answers;

  /// Create a copy of BalanceGameSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BalanceGameSubmissionImplCopyWith<_$BalanceGameSubmissionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
