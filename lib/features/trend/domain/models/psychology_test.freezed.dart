// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'psychology_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrendPsychologyTest _$TrendPsychologyTestFromJson(Map<String, dynamic> json) {
  return _TrendPsychologyTest.fromJson(json);
}

/// @nodoc
mixin _$TrendPsychologyTest {
  String get id => throw _privateConstructorUsedError;
  String get contentId => throw _privateConstructorUsedError;
  PsychologyResultType get resultType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  int get estimatedMinutes => throw _privateConstructorUsedError;
  bool get useLlmAnalysis => throw _privateConstructorUsedError;
  List<TrendPsychologyQuestion> get questions =>
      throw _privateConstructorUsedError;
  List<TrendPsychologyResult> get possibleResults =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TrendPsychologyTest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendPsychologyTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendPsychologyTestCopyWith<TrendPsychologyTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendPsychologyTestCopyWith<$Res> {
  factory $TrendPsychologyTestCopyWith(
          TrendPsychologyTest value, $Res Function(TrendPsychologyTest) then) =
      _$TrendPsychologyTestCopyWithImpl<$Res, TrendPsychologyTest>;
  @useResult
  $Res call(
      {String id,
      String contentId,
      PsychologyResultType resultType,
      String? description,
      int questionCount,
      int estimatedMinutes,
      bool useLlmAnalysis,
      List<TrendPsychologyQuestion> questions,
      List<TrendPsychologyResult> possibleResults,
      DateTime? createdAt});
}

/// @nodoc
class _$TrendPsychologyTestCopyWithImpl<$Res, $Val extends TrendPsychologyTest>
    implements $TrendPsychologyTestCopyWith<$Res> {
  _$TrendPsychologyTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendPsychologyTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contentId = null,
    Object? resultType = null,
    Object? description = freezed,
    Object? questionCount = null,
    Object? estimatedMinutes = null,
    Object? useLlmAnalysis = null,
    Object? questions = null,
    Object? possibleResults = null,
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
      resultType: null == resultType
          ? _value.resultType
          : resultType // ignore: cast_nullable_to_non_nullable
              as PsychologyResultType,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      questionCount: null == questionCount
          ? _value.questionCount
          : questionCount // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedMinutes: null == estimatedMinutes
          ? _value.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      useLlmAnalysis: null == useLlmAnalysis
          ? _value.useLlmAnalysis
          : useLlmAnalysis // ignore: cast_nullable_to_non_nullable
              as bool,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<TrendPsychologyQuestion>,
      possibleResults: null == possibleResults
          ? _value.possibleResults
          : possibleResults // ignore: cast_nullable_to_non_nullable
              as List<TrendPsychologyResult>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendPsychologyTestImplCopyWith<$Res>
    implements $TrendPsychologyTestCopyWith<$Res> {
  factory _$$TrendPsychologyTestImplCopyWith(_$TrendPsychologyTestImpl value,
          $Res Function(_$TrendPsychologyTestImpl) then) =
      __$$TrendPsychologyTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String contentId,
      PsychologyResultType resultType,
      String? description,
      int questionCount,
      int estimatedMinutes,
      bool useLlmAnalysis,
      List<TrendPsychologyQuestion> questions,
      List<TrendPsychologyResult> possibleResults,
      DateTime? createdAt});
}

/// @nodoc
class __$$TrendPsychologyTestImplCopyWithImpl<$Res>
    extends _$TrendPsychologyTestCopyWithImpl<$Res, _$TrendPsychologyTestImpl>
    implements _$$TrendPsychologyTestImplCopyWith<$Res> {
  __$$TrendPsychologyTestImplCopyWithImpl(_$TrendPsychologyTestImpl _value,
      $Res Function(_$TrendPsychologyTestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendPsychologyTest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contentId = null,
    Object? resultType = null,
    Object? description = freezed,
    Object? questionCount = null,
    Object? estimatedMinutes = null,
    Object? useLlmAnalysis = null,
    Object? questions = null,
    Object? possibleResults = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$TrendPsychologyTestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      resultType: null == resultType
          ? _value.resultType
          : resultType // ignore: cast_nullable_to_non_nullable
              as PsychologyResultType,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      questionCount: null == questionCount
          ? _value.questionCount
          : questionCount // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedMinutes: null == estimatedMinutes
          ? _value.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      useLlmAnalysis: null == useLlmAnalysis
          ? _value.useLlmAnalysis
          : useLlmAnalysis // ignore: cast_nullable_to_non_nullable
              as bool,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<TrendPsychologyQuestion>,
      possibleResults: null == possibleResults
          ? _value._possibleResults
          : possibleResults // ignore: cast_nullable_to_non_nullable
              as List<TrendPsychologyResult>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendPsychologyTestImpl implements _TrendPsychologyTest {
  const _$TrendPsychologyTestImpl(
      {required this.id,
      required this.contentId,
      required this.resultType,
      this.description,
      this.questionCount = 0,
      this.estimatedMinutes = 5,
      this.useLlmAnalysis = false,
      required final List<TrendPsychologyQuestion> questions,
      required final List<TrendPsychologyResult> possibleResults,
      this.createdAt})
      : _questions = questions,
        _possibleResults = possibleResults;

  factory _$TrendPsychologyTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendPsychologyTestImplFromJson(json);

  @override
  final String id;
  @override
  final String contentId;
  @override
  final PsychologyResultType resultType;
  @override
  final String? description;
  @override
  @JsonKey()
  final int questionCount;
  @override
  @JsonKey()
  final int estimatedMinutes;
  @override
  @JsonKey()
  final bool useLlmAnalysis;
  final List<TrendPsychologyQuestion> _questions;
  @override
  List<TrendPsychologyQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  final List<TrendPsychologyResult> _possibleResults;
  @override
  List<TrendPsychologyResult> get possibleResults {
    if (_possibleResults is EqualUnmodifiableListView) return _possibleResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_possibleResults);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TrendPsychologyTest(id: $id, contentId: $contentId, resultType: $resultType, description: $description, questionCount: $questionCount, estimatedMinutes: $estimatedMinutes, useLlmAnalysis: $useLlmAnalysis, questions: $questions, possibleResults: $possibleResults, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendPsychologyTestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.resultType, resultType) ||
                other.resultType == resultType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.useLlmAnalysis, useLlmAnalysis) ||
                other.useLlmAnalysis == useLlmAnalysis) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            const DeepCollectionEquality()
                .equals(other._possibleResults, _possibleResults) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      contentId,
      resultType,
      description,
      questionCount,
      estimatedMinutes,
      useLlmAnalysis,
      const DeepCollectionEquality().hash(_questions),
      const DeepCollectionEquality().hash(_possibleResults),
      createdAt);

  /// Create a copy of TrendPsychologyTest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendPsychologyTestImplCopyWith<_$TrendPsychologyTestImpl> get copyWith =>
      __$$TrendPsychologyTestImplCopyWithImpl<_$TrendPsychologyTestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendPsychologyTestImplToJson(
      this,
    );
  }
}

abstract class _TrendPsychologyTest implements TrendPsychologyTest {
  const factory _TrendPsychologyTest(
      {required final String id,
      required final String contentId,
      required final PsychologyResultType resultType,
      final String? description,
      final int questionCount,
      final int estimatedMinutes,
      final bool useLlmAnalysis,
      required final List<TrendPsychologyQuestion> questions,
      required final List<TrendPsychologyResult> possibleResults,
      final DateTime? createdAt}) = _$TrendPsychologyTestImpl;

  factory _TrendPsychologyTest.fromJson(Map<String, dynamic> json) =
      _$TrendPsychologyTestImpl.fromJson;

  @override
  String get id;
  @override
  String get contentId;
  @override
  PsychologyResultType get resultType;
  @override
  String? get description;
  @override
  int get questionCount;
  @override
  int get estimatedMinutes;
  @override
  bool get useLlmAnalysis;
  @override
  List<TrendPsychologyQuestion> get questions;
  @override
  List<TrendPsychologyResult> get possibleResults;
  @override
  DateTime? get createdAt;

  /// Create a copy of TrendPsychologyTest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendPsychologyTestImplCopyWith<_$TrendPsychologyTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendPsychologyQuestion _$TrendPsychologyQuestionFromJson(
    Map<String, dynamic> json) {
  return _TrendPsychologyQuestion.fromJson(json);
}

/// @nodoc
mixin _$TrendPsychologyQuestion {
  String get id => throw _privateConstructorUsedError;
  int get questionOrder => throw _privateConstructorUsedError;
  String get questionText => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<TrendPsychologyOption> get options => throw _privateConstructorUsedError;

  /// Serializes this TrendPsychologyQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendPsychologyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendPsychologyQuestionCopyWith<TrendPsychologyQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendPsychologyQuestionCopyWith<$Res> {
  factory $TrendPsychologyQuestionCopyWith(TrendPsychologyQuestion value,
          $Res Function(TrendPsychologyQuestion) then) =
      _$TrendPsychologyQuestionCopyWithImpl<$Res, TrendPsychologyQuestion>;
  @useResult
  $Res call(
      {String id,
      int questionOrder,
      String questionText,
      String? imageUrl,
      List<TrendPsychologyOption> options});
}

/// @nodoc
class _$TrendPsychologyQuestionCopyWithImpl<$Res,
        $Val extends TrendPsychologyQuestion>
    implements $TrendPsychologyQuestionCopyWith<$Res> {
  _$TrendPsychologyQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendPsychologyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionOrder = null,
    Object? questionText = null,
    Object? imageUrl = freezed,
    Object? options = null,
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
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<TrendPsychologyOption>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendPsychologyQuestionImplCopyWith<$Res>
    implements $TrendPsychologyQuestionCopyWith<$Res> {
  factory _$$TrendPsychologyQuestionImplCopyWith(
          _$TrendPsychologyQuestionImpl value,
          $Res Function(_$TrendPsychologyQuestionImpl) then) =
      __$$TrendPsychologyQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int questionOrder,
      String questionText,
      String? imageUrl,
      List<TrendPsychologyOption> options});
}

/// @nodoc
class __$$TrendPsychologyQuestionImplCopyWithImpl<$Res>
    extends _$TrendPsychologyQuestionCopyWithImpl<$Res,
        _$TrendPsychologyQuestionImpl>
    implements _$$TrendPsychologyQuestionImplCopyWith<$Res> {
  __$$TrendPsychologyQuestionImplCopyWithImpl(
      _$TrendPsychologyQuestionImpl _value,
      $Res Function(_$TrendPsychologyQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendPsychologyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionOrder = null,
    Object? questionText = null,
    Object? imageUrl = freezed,
    Object? options = null,
  }) {
    return _then(_$TrendPsychologyQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      questionOrder: null == questionOrder
          ? _value.questionOrder
          : questionOrder // ignore: cast_nullable_to_non_nullable
              as int,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<TrendPsychologyOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendPsychologyQuestionImpl implements _TrendPsychologyQuestion {
  const _$TrendPsychologyQuestionImpl(
      {required this.id,
      required this.questionOrder,
      required this.questionText,
      this.imageUrl,
      required final List<TrendPsychologyOption> options})
      : _options = options;

  factory _$TrendPsychologyQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendPsychologyQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final int questionOrder;
  @override
  final String questionText;
  @override
  final String? imageUrl;
  final List<TrendPsychologyOption> _options;
  @override
  List<TrendPsychologyOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'TrendPsychologyQuestion(id: $id, questionOrder: $questionOrder, questionText: $questionText, imageUrl: $imageUrl, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendPsychologyQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionOrder, questionOrder) ||
                other.questionOrder == questionOrder) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, questionOrder, questionText,
      imageUrl, const DeepCollectionEquality().hash(_options));

  /// Create a copy of TrendPsychologyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendPsychologyQuestionImplCopyWith<_$TrendPsychologyQuestionImpl>
      get copyWith => __$$TrendPsychologyQuestionImplCopyWithImpl<
          _$TrendPsychologyQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendPsychologyQuestionImplToJson(
      this,
    );
  }
}

abstract class _TrendPsychologyQuestion implements TrendPsychologyQuestion {
  const factory _TrendPsychologyQuestion(
          {required final String id,
          required final int questionOrder,
          required final String questionText,
          final String? imageUrl,
          required final List<TrendPsychologyOption> options}) =
      _$TrendPsychologyQuestionImpl;

  factory _TrendPsychologyQuestion.fromJson(Map<String, dynamic> json) =
      _$TrendPsychologyQuestionImpl.fromJson;

  @override
  String get id;
  @override
  int get questionOrder;
  @override
  String get questionText;
  @override
  String? get imageUrl;
  @override
  List<TrendPsychologyOption> get options;

  /// Create a copy of TrendPsychologyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendPsychologyQuestionImplCopyWith<_$TrendPsychologyQuestionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TrendPsychologyOption _$TrendPsychologyOptionFromJson(
    Map<String, dynamic> json) {
  return _TrendPsychologyOption.fromJson(json);
}

/// @nodoc
mixin _$TrendPsychologyOption {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  Map<String, int> get scoreMap => throw _privateConstructorUsedError;
  int get optionOrder => throw _privateConstructorUsedError;

  /// Serializes this TrendPsychologyOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendPsychologyOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendPsychologyOptionCopyWith<TrendPsychologyOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendPsychologyOptionCopyWith<$Res> {
  factory $TrendPsychologyOptionCopyWith(TrendPsychologyOption value,
          $Res Function(TrendPsychologyOption) then) =
      _$TrendPsychologyOptionCopyWithImpl<$Res, TrendPsychologyOption>;
  @useResult
  $Res call(
      {String id,
      String label,
      String? imageUrl,
      Map<String, int> scoreMap,
      int optionOrder});
}

/// @nodoc
class _$TrendPsychologyOptionCopyWithImpl<$Res,
        $Val extends TrendPsychologyOption>
    implements $TrendPsychologyOptionCopyWith<$Res> {
  _$TrendPsychologyOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendPsychologyOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? imageUrl = freezed,
    Object? scoreMap = null,
    Object? optionOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      scoreMap: null == scoreMap
          ? _value.scoreMap
          : scoreMap // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      optionOrder: null == optionOrder
          ? _value.optionOrder
          : optionOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendPsychologyOptionImplCopyWith<$Res>
    implements $TrendPsychologyOptionCopyWith<$Res> {
  factory _$$TrendPsychologyOptionImplCopyWith(
          _$TrendPsychologyOptionImpl value,
          $Res Function(_$TrendPsychologyOptionImpl) then) =
      __$$TrendPsychologyOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String? imageUrl,
      Map<String, int> scoreMap,
      int optionOrder});
}

/// @nodoc
class __$$TrendPsychologyOptionImplCopyWithImpl<$Res>
    extends _$TrendPsychologyOptionCopyWithImpl<$Res,
        _$TrendPsychologyOptionImpl>
    implements _$$TrendPsychologyOptionImplCopyWith<$Res> {
  __$$TrendPsychologyOptionImplCopyWithImpl(_$TrendPsychologyOptionImpl _value,
      $Res Function(_$TrendPsychologyOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendPsychologyOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? imageUrl = freezed,
    Object? scoreMap = null,
    Object? optionOrder = null,
  }) {
    return _then(_$TrendPsychologyOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      scoreMap: null == scoreMap
          ? _value._scoreMap
          : scoreMap // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      optionOrder: null == optionOrder
          ? _value.optionOrder
          : optionOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendPsychologyOptionImpl implements _TrendPsychologyOption {
  const _$TrendPsychologyOptionImpl(
      {required this.id,
      required this.label,
      this.imageUrl,
      final Map<String, int> scoreMap = const {},
      this.optionOrder = 0})
      : _scoreMap = scoreMap;

  factory _$TrendPsychologyOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendPsychologyOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String? imageUrl;
  final Map<String, int> _scoreMap;
  @override
  @JsonKey()
  Map<String, int> get scoreMap {
    if (_scoreMap is EqualUnmodifiableMapView) return _scoreMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scoreMap);
  }

  @override
  @JsonKey()
  final int optionOrder;

  @override
  String toString() {
    return 'TrendPsychologyOption(id: $id, label: $label, imageUrl: $imageUrl, scoreMap: $scoreMap, optionOrder: $optionOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendPsychologyOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._scoreMap, _scoreMap) &&
            (identical(other.optionOrder, optionOrder) ||
                other.optionOrder == optionOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, imageUrl,
      const DeepCollectionEquality().hash(_scoreMap), optionOrder);

  /// Create a copy of TrendPsychologyOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendPsychologyOptionImplCopyWith<_$TrendPsychologyOptionImpl>
      get copyWith => __$$TrendPsychologyOptionImplCopyWithImpl<
          _$TrendPsychologyOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendPsychologyOptionImplToJson(
      this,
    );
  }
}

abstract class _TrendPsychologyOption implements TrendPsychologyOption {
  const factory _TrendPsychologyOption(
      {required final String id,
      required final String label,
      final String? imageUrl,
      final Map<String, int> scoreMap,
      final int optionOrder}) = _$TrendPsychologyOptionImpl;

  factory _TrendPsychologyOption.fromJson(Map<String, dynamic> json) =
      _$TrendPsychologyOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String? get imageUrl;
  @override
  Map<String, int> get scoreMap;
  @override
  int get optionOrder;

  /// Create a copy of TrendPsychologyOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendPsychologyOptionImplCopyWith<_$TrendPsychologyOptionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TrendPsychologyResult _$TrendPsychologyResultFromJson(
    Map<String, dynamic> json) {
  return _TrendPsychologyResult.fromJson(json);
}

/// @nodoc
mixin _$TrendPsychologyResult {
  String get id => throw _privateConstructorUsedError;
  String get resultCode => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get characteristics => throw _privateConstructorUsedError;
  String? get compatibleWith => throw _privateConstructorUsedError;
  String? get incompatibleWith => throw _privateConstructorUsedError;
  Map<String, dynamic> get additionalInfo => throw _privateConstructorUsedError;
  int get selectionCount => throw _privateConstructorUsedError;

  /// Serializes this TrendPsychologyResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendPsychologyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendPsychologyResultCopyWith<TrendPsychologyResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendPsychologyResultCopyWith<$Res> {
  factory $TrendPsychologyResultCopyWith(TrendPsychologyResult value,
          $Res Function(TrendPsychologyResult) then) =
      _$TrendPsychologyResultCopyWithImpl<$Res, TrendPsychologyResult>;
  @useResult
  $Res call(
      {String id,
      String resultCode,
      String title,
      String description,
      String? imageUrl,
      List<String> characteristics,
      String? compatibleWith,
      String? incompatibleWith,
      Map<String, dynamic> additionalInfo,
      int selectionCount});
}

/// @nodoc
class _$TrendPsychologyResultCopyWithImpl<$Res,
        $Val extends TrendPsychologyResult>
    implements $TrendPsychologyResultCopyWith<$Res> {
  _$TrendPsychologyResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendPsychologyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? resultCode = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? characteristics = null,
    Object? compatibleWith = freezed,
    Object? incompatibleWith = freezed,
    Object? additionalInfo = null,
    Object? selectionCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      resultCode: null == resultCode
          ? _value.resultCode
          : resultCode // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      characteristics: null == characteristics
          ? _value.characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as List<String>,
      compatibleWith: freezed == compatibleWith
          ? _value.compatibleWith
          : compatibleWith // ignore: cast_nullable_to_non_nullable
              as String?,
      incompatibleWith: freezed == incompatibleWith
          ? _value.incompatibleWith
          : incompatibleWith // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalInfo: null == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      selectionCount: null == selectionCount
          ? _value.selectionCount
          : selectionCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrendPsychologyResultImplCopyWith<$Res>
    implements $TrendPsychologyResultCopyWith<$Res> {
  factory _$$TrendPsychologyResultImplCopyWith(
          _$TrendPsychologyResultImpl value,
          $Res Function(_$TrendPsychologyResultImpl) then) =
      __$$TrendPsychologyResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String resultCode,
      String title,
      String description,
      String? imageUrl,
      List<String> characteristics,
      String? compatibleWith,
      String? incompatibleWith,
      Map<String, dynamic> additionalInfo,
      int selectionCount});
}

/// @nodoc
class __$$TrendPsychologyResultImplCopyWithImpl<$Res>
    extends _$TrendPsychologyResultCopyWithImpl<$Res,
        _$TrendPsychologyResultImpl>
    implements _$$TrendPsychologyResultImplCopyWith<$Res> {
  __$$TrendPsychologyResultImplCopyWithImpl(_$TrendPsychologyResultImpl _value,
      $Res Function(_$TrendPsychologyResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrendPsychologyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? resultCode = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? characteristics = null,
    Object? compatibleWith = freezed,
    Object? incompatibleWith = freezed,
    Object? additionalInfo = null,
    Object? selectionCount = null,
  }) {
    return _then(_$TrendPsychologyResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      resultCode: null == resultCode
          ? _value.resultCode
          : resultCode // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      characteristics: null == characteristics
          ? _value._characteristics
          : characteristics // ignore: cast_nullable_to_non_nullable
              as List<String>,
      compatibleWith: freezed == compatibleWith
          ? _value.compatibleWith
          : compatibleWith // ignore: cast_nullable_to_non_nullable
              as String?,
      incompatibleWith: freezed == incompatibleWith
          ? _value.incompatibleWith
          : incompatibleWith // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalInfo: null == additionalInfo
          ? _value._additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      selectionCount: null == selectionCount
          ? _value.selectionCount
          : selectionCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendPsychologyResultImpl implements _TrendPsychologyResult {
  const _$TrendPsychologyResultImpl(
      {required this.id,
      required this.resultCode,
      required this.title,
      required this.description,
      this.imageUrl,
      final List<String> characteristics = const [],
      this.compatibleWith,
      this.incompatibleWith,
      final Map<String, dynamic> additionalInfo = const {},
      this.selectionCount = 0})
      : _characteristics = characteristics,
        _additionalInfo = additionalInfo;

  factory _$TrendPsychologyResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendPsychologyResultImplFromJson(json);

  @override
  final String id;
  @override
  final String resultCode;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? imageUrl;
  final List<String> _characteristics;
  @override
  @JsonKey()
  List<String> get characteristics {
    if (_characteristics is EqualUnmodifiableListView) return _characteristics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_characteristics);
  }

  @override
  final String? compatibleWith;
  @override
  final String? incompatibleWith;
  final Map<String, dynamic> _additionalInfo;
  @override
  @JsonKey()
  Map<String, dynamic> get additionalInfo {
    if (_additionalInfo is EqualUnmodifiableMapView) return _additionalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_additionalInfo);
  }

  @override
  @JsonKey()
  final int selectionCount;

  @override
  String toString() {
    return 'TrendPsychologyResult(id: $id, resultCode: $resultCode, title: $title, description: $description, imageUrl: $imageUrl, characteristics: $characteristics, compatibleWith: $compatibleWith, incompatibleWith: $incompatibleWith, additionalInfo: $additionalInfo, selectionCount: $selectionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendPsychologyResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.resultCode, resultCode) ||
                other.resultCode == resultCode) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._characteristics, _characteristics) &&
            (identical(other.compatibleWith, compatibleWith) ||
                other.compatibleWith == compatibleWith) &&
            (identical(other.incompatibleWith, incompatibleWith) ||
                other.incompatibleWith == incompatibleWith) &&
            const DeepCollectionEquality()
                .equals(other._additionalInfo, _additionalInfo) &&
            (identical(other.selectionCount, selectionCount) ||
                other.selectionCount == selectionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      resultCode,
      title,
      description,
      imageUrl,
      const DeepCollectionEquality().hash(_characteristics),
      compatibleWith,
      incompatibleWith,
      const DeepCollectionEquality().hash(_additionalInfo),
      selectionCount);

  /// Create a copy of TrendPsychologyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendPsychologyResultImplCopyWith<_$TrendPsychologyResultImpl>
      get copyWith => __$$TrendPsychologyResultImplCopyWithImpl<
          _$TrendPsychologyResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendPsychologyResultImplToJson(
      this,
    );
  }
}

abstract class _TrendPsychologyResult implements TrendPsychologyResult {
  const factory _TrendPsychologyResult(
      {required final String id,
      required final String resultCode,
      required final String title,
      required final String description,
      final String? imageUrl,
      final List<String> characteristics,
      final String? compatibleWith,
      final String? incompatibleWith,
      final Map<String, dynamic> additionalInfo,
      final int selectionCount}) = _$TrendPsychologyResultImpl;

  factory _TrendPsychologyResult.fromJson(Map<String, dynamic> json) =
      _$TrendPsychologyResultImpl.fromJson;

  @override
  String get id;
  @override
  String get resultCode;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get imageUrl;
  @override
  List<String> get characteristics;
  @override
  String? get compatibleWith;
  @override
  String? get incompatibleWith;
  @override
  Map<String, dynamic> get additionalInfo;
  @override
  int get selectionCount;

  /// Create a copy of TrendPsychologyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendPsychologyResultImplCopyWith<_$TrendPsychologyResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UserPsychologyTestResult _$UserPsychologyTestResultFromJson(
    Map<String, dynamic> json) {
  return _UserPsychologyTestResult.fromJson(json);
}

/// @nodoc
mixin _$UserPsychologyTestResult {
  String get id => throw _privateConstructorUsedError;
  String get testId => throw _privateConstructorUsedError;
  String get resultId => throw _privateConstructorUsedError;
  TrendPsychologyResult get result => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;
  Map<String, int> get scoreBreakdown => throw _privateConstructorUsedError;
  String? get llmAnalysis => throw _privateConstructorUsedError;
  bool get isShared => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this UserPsychologyTestResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPsychologyTestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPsychologyTestResultCopyWith<UserPsychologyTestResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPsychologyTestResultCopyWith<$Res> {
  factory $UserPsychologyTestResultCopyWith(UserPsychologyTestResult value,
          $Res Function(UserPsychologyTestResult) then) =
      _$UserPsychologyTestResultCopyWithImpl<$Res, UserPsychologyTestResult>;
  @useResult
  $Res call(
      {String id,
      String testId,
      String resultId,
      TrendPsychologyResult result,
      Map<String, String> answers,
      Map<String, int> scoreBreakdown,
      String? llmAnalysis,
      bool isShared,
      DateTime? completedAt});

  $TrendPsychologyResultCopyWith<$Res> get result;
}

/// @nodoc
class _$UserPsychologyTestResultCopyWithImpl<$Res,
        $Val extends UserPsychologyTestResult>
    implements $UserPsychologyTestResultCopyWith<$Res> {
  _$UserPsychologyTestResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPsychologyTestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? testId = null,
    Object? resultId = null,
    Object? result = null,
    Object? answers = null,
    Object? scoreBreakdown = null,
    Object? llmAnalysis = freezed,
    Object? isShared = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      resultId: null == resultId
          ? _value.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as String,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as TrendPsychologyResult,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      scoreBreakdown: null == scoreBreakdown
          ? _value.scoreBreakdown
          : scoreBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      llmAnalysis: freezed == llmAnalysis
          ? _value.llmAnalysis
          : llmAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of UserPsychologyTestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrendPsychologyResultCopyWith<$Res> get result {
    return $TrendPsychologyResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserPsychologyTestResultImplCopyWith<$Res>
    implements $UserPsychologyTestResultCopyWith<$Res> {
  factory _$$UserPsychologyTestResultImplCopyWith(
          _$UserPsychologyTestResultImpl value,
          $Res Function(_$UserPsychologyTestResultImpl) then) =
      __$$UserPsychologyTestResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String testId,
      String resultId,
      TrendPsychologyResult result,
      Map<String, String> answers,
      Map<String, int> scoreBreakdown,
      String? llmAnalysis,
      bool isShared,
      DateTime? completedAt});

  @override
  $TrendPsychologyResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$UserPsychologyTestResultImplCopyWithImpl<$Res>
    extends _$UserPsychologyTestResultCopyWithImpl<$Res,
        _$UserPsychologyTestResultImpl>
    implements _$$UserPsychologyTestResultImplCopyWith<$Res> {
  __$$UserPsychologyTestResultImplCopyWithImpl(
      _$UserPsychologyTestResultImpl _value,
      $Res Function(_$UserPsychologyTestResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPsychologyTestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? testId = null,
    Object? resultId = null,
    Object? result = null,
    Object? answers = null,
    Object? scoreBreakdown = null,
    Object? llmAnalysis = freezed,
    Object? isShared = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$UserPsychologyTestResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      resultId: null == resultId
          ? _value.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as String,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as TrendPsychologyResult,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      scoreBreakdown: null == scoreBreakdown
          ? _value._scoreBreakdown
          : scoreBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      llmAnalysis: freezed == llmAnalysis
          ? _value.llmAnalysis
          : llmAnalysis // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$UserPsychologyTestResultImpl implements _UserPsychologyTestResult {
  const _$UserPsychologyTestResultImpl(
      {required this.id,
      required this.testId,
      required this.resultId,
      required this.result,
      required final Map<String, String> answers,
      required final Map<String, int> scoreBreakdown,
      this.llmAnalysis,
      this.isShared = false,
      this.completedAt})
      : _answers = answers,
        _scoreBreakdown = scoreBreakdown;

  factory _$UserPsychologyTestResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPsychologyTestResultImplFromJson(json);

  @override
  final String id;
  @override
  final String testId;
  @override
  final String resultId;
  @override
  final TrendPsychologyResult result;
  final Map<String, String> _answers;
  @override
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  final Map<String, int> _scoreBreakdown;
  @override
  Map<String, int> get scoreBreakdown {
    if (_scoreBreakdown is EqualUnmodifiableMapView) return _scoreBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scoreBreakdown);
  }

  @override
  final String? llmAnalysis;
  @override
  @JsonKey()
  final bool isShared;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'UserPsychologyTestResult(id: $id, testId: $testId, resultId: $resultId, result: $result, answers: $answers, scoreBreakdown: $scoreBreakdown, llmAnalysis: $llmAnalysis, isShared: $isShared, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPsychologyTestResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.testId, testId) || other.testId == testId) &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.result, result) || other.result == result) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            const DeepCollectionEquality()
                .equals(other._scoreBreakdown, _scoreBreakdown) &&
            (identical(other.llmAnalysis, llmAnalysis) ||
                other.llmAnalysis == llmAnalysis) &&
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
      testId,
      resultId,
      result,
      const DeepCollectionEquality().hash(_answers),
      const DeepCollectionEquality().hash(_scoreBreakdown),
      llmAnalysis,
      isShared,
      completedAt);

  /// Create a copy of UserPsychologyTestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPsychologyTestResultImplCopyWith<_$UserPsychologyTestResultImpl>
      get copyWith => __$$UserPsychologyTestResultImplCopyWithImpl<
          _$UserPsychologyTestResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPsychologyTestResultImplToJson(
      this,
    );
  }
}

abstract class _UserPsychologyTestResult implements UserPsychologyTestResult {
  const factory _UserPsychologyTestResult(
      {required final String id,
      required final String testId,
      required final String resultId,
      required final TrendPsychologyResult result,
      required final Map<String, String> answers,
      required final Map<String, int> scoreBreakdown,
      final String? llmAnalysis,
      final bool isShared,
      final DateTime? completedAt}) = _$UserPsychologyTestResultImpl;

  factory _UserPsychologyTestResult.fromJson(Map<String, dynamic> json) =
      _$UserPsychologyTestResultImpl.fromJson;

  @override
  String get id;
  @override
  String get testId;
  @override
  String get resultId;
  @override
  TrendPsychologyResult get result;
  @override
  Map<String, String> get answers;
  @override
  Map<String, int> get scoreBreakdown;
  @override
  String? get llmAnalysis;
  @override
  bool get isShared;
  @override
  DateTime? get completedAt;

  /// Create a copy of UserPsychologyTestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPsychologyTestResultImplCopyWith<_$UserPsychologyTestResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PsychologyTestSubmission _$PsychologyTestSubmissionFromJson(
    Map<String, dynamic> json) {
  return _PsychologyTestSubmission.fromJson(json);
}

/// @nodoc
mixin _$PsychologyTestSubmission {
  String get testId => throw _privateConstructorUsedError;
  Map<String, String> get answers => throw _privateConstructorUsedError;

  /// Serializes this PsychologyTestSubmission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PsychologyTestSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PsychologyTestSubmissionCopyWith<PsychologyTestSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PsychologyTestSubmissionCopyWith<$Res> {
  factory $PsychologyTestSubmissionCopyWith(PsychologyTestSubmission value,
          $Res Function(PsychologyTestSubmission) then) =
      _$PsychologyTestSubmissionCopyWithImpl<$Res, PsychologyTestSubmission>;
  @useResult
  $Res call({String testId, Map<String, String> answers});
}

/// @nodoc
class _$PsychologyTestSubmissionCopyWithImpl<$Res,
        $Val extends PsychologyTestSubmission>
    implements $PsychologyTestSubmissionCopyWith<$Res> {
  _$PsychologyTestSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PsychologyTestSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? answers = null,
  }) {
    return _then(_value.copyWith(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PsychologyTestSubmissionImplCopyWith<$Res>
    implements $PsychologyTestSubmissionCopyWith<$Res> {
  factory _$$PsychologyTestSubmissionImplCopyWith(
          _$PsychologyTestSubmissionImpl value,
          $Res Function(_$PsychologyTestSubmissionImpl) then) =
      __$$PsychologyTestSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String testId, Map<String, String> answers});
}

/// @nodoc
class __$$PsychologyTestSubmissionImplCopyWithImpl<$Res>
    extends _$PsychologyTestSubmissionCopyWithImpl<$Res,
        _$PsychologyTestSubmissionImpl>
    implements _$$PsychologyTestSubmissionImplCopyWith<$Res> {
  __$$PsychologyTestSubmissionImplCopyWithImpl(
      _$PsychologyTestSubmissionImpl _value,
      $Res Function(_$PsychologyTestSubmissionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PsychologyTestSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? answers = null,
  }) {
    return _then(_$PsychologyTestSubmissionImpl(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
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
class _$PsychologyTestSubmissionImpl implements _PsychologyTestSubmission {
  const _$PsychologyTestSubmissionImpl(
      {required this.testId, required final Map<String, String> answers})
      : _answers = answers;

  factory _$PsychologyTestSubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PsychologyTestSubmissionImplFromJson(json);

  @override
  final String testId;
  final Map<String, String> _answers;
  @override
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  String toString() {
    return 'PsychologyTestSubmission(testId: $testId, answers: $answers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PsychologyTestSubmissionImpl &&
            (identical(other.testId, testId) || other.testId == testId) &&
            const DeepCollectionEquality().equals(other._answers, _answers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, testId, const DeepCollectionEquality().hash(_answers));

  /// Create a copy of PsychologyTestSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PsychologyTestSubmissionImplCopyWith<_$PsychologyTestSubmissionImpl>
      get copyWith => __$$PsychologyTestSubmissionImplCopyWithImpl<
          _$PsychologyTestSubmissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PsychologyTestSubmissionImplToJson(
      this,
    );
  }
}

abstract class _PsychologyTestSubmission implements PsychologyTestSubmission {
  const factory _PsychologyTestSubmission(
          {required final String testId,
          required final Map<String, String> answers}) =
      _$PsychologyTestSubmissionImpl;

  factory _PsychologyTestSubmission.fromJson(Map<String, dynamic> json) =
      _$PsychologyTestSubmissionImpl.fromJson;

  @override
  String get testId;
  @override
  Map<String, String> get answers;

  /// Create a copy of PsychologyTestSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PsychologyTestSubmissionImplCopyWith<_$PsychologyTestSubmissionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PsychologyTestStats _$PsychologyTestStatsFromJson(Map<String, dynamic> json) {
  return _PsychologyTestStats.fromJson(json);
}

/// @nodoc
mixin _$PsychologyTestStats {
  String get testId => throw _privateConstructorUsedError;
  int get totalParticipants => throw _privateConstructorUsedError;
  List<ResultDistribution> get resultDistribution =>
      throw _privateConstructorUsedError;

  /// Serializes this PsychologyTestStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PsychologyTestStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PsychologyTestStatsCopyWith<PsychologyTestStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PsychologyTestStatsCopyWith<$Res> {
  factory $PsychologyTestStatsCopyWith(
          PsychologyTestStats value, $Res Function(PsychologyTestStats) then) =
      _$PsychologyTestStatsCopyWithImpl<$Res, PsychologyTestStats>;
  @useResult
  $Res call(
      {String testId,
      int totalParticipants,
      List<ResultDistribution> resultDistribution});
}

/// @nodoc
class _$PsychologyTestStatsCopyWithImpl<$Res, $Val extends PsychologyTestStats>
    implements $PsychologyTestStatsCopyWith<$Res> {
  _$PsychologyTestStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PsychologyTestStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? totalParticipants = null,
    Object? resultDistribution = null,
  }) {
    return _then(_value.copyWith(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      resultDistribution: null == resultDistribution
          ? _value.resultDistribution
          : resultDistribution // ignore: cast_nullable_to_non_nullable
              as List<ResultDistribution>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PsychologyTestStatsImplCopyWith<$Res>
    implements $PsychologyTestStatsCopyWith<$Res> {
  factory _$$PsychologyTestStatsImplCopyWith(_$PsychologyTestStatsImpl value,
          $Res Function(_$PsychologyTestStatsImpl) then) =
      __$$PsychologyTestStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String testId,
      int totalParticipants,
      List<ResultDistribution> resultDistribution});
}

/// @nodoc
class __$$PsychologyTestStatsImplCopyWithImpl<$Res>
    extends _$PsychologyTestStatsCopyWithImpl<$Res, _$PsychologyTestStatsImpl>
    implements _$$PsychologyTestStatsImplCopyWith<$Res> {
  __$$PsychologyTestStatsImplCopyWithImpl(_$PsychologyTestStatsImpl _value,
      $Res Function(_$PsychologyTestStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PsychologyTestStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? totalParticipants = null,
    Object? resultDistribution = null,
  }) {
    return _then(_$PsychologyTestStatsImpl(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      resultDistribution: null == resultDistribution
          ? _value._resultDistribution
          : resultDistribution // ignore: cast_nullable_to_non_nullable
              as List<ResultDistribution>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PsychologyTestStatsImpl implements _PsychologyTestStats {
  const _$PsychologyTestStatsImpl(
      {required this.testId,
      required this.totalParticipants,
      required final List<ResultDistribution> resultDistribution})
      : _resultDistribution = resultDistribution;

  factory _$PsychologyTestStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PsychologyTestStatsImplFromJson(json);

  @override
  final String testId;
  @override
  final int totalParticipants;
  final List<ResultDistribution> _resultDistribution;
  @override
  List<ResultDistribution> get resultDistribution {
    if (_resultDistribution is EqualUnmodifiableListView)
      return _resultDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_resultDistribution);
  }

  @override
  String toString() {
    return 'PsychologyTestStats(testId: $testId, totalParticipants: $totalParticipants, resultDistribution: $resultDistribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PsychologyTestStatsImpl &&
            (identical(other.testId, testId) || other.testId == testId) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            const DeepCollectionEquality()
                .equals(other._resultDistribution, _resultDistribution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, testId, totalParticipants,
      const DeepCollectionEquality().hash(_resultDistribution));

  /// Create a copy of PsychologyTestStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PsychologyTestStatsImplCopyWith<_$PsychologyTestStatsImpl> get copyWith =>
      __$$PsychologyTestStatsImplCopyWithImpl<_$PsychologyTestStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PsychologyTestStatsImplToJson(
      this,
    );
  }
}

abstract class _PsychologyTestStats implements PsychologyTestStats {
  const factory _PsychologyTestStats(
          {required final String testId,
          required final int totalParticipants,
          required final List<ResultDistribution> resultDistribution}) =
      _$PsychologyTestStatsImpl;

  factory _PsychologyTestStats.fromJson(Map<String, dynamic> json) =
      _$PsychologyTestStatsImpl.fromJson;

  @override
  String get testId;
  @override
  int get totalParticipants;
  @override
  List<ResultDistribution> get resultDistribution;

  /// Create a copy of PsychologyTestStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PsychologyTestStatsImplCopyWith<_$PsychologyTestStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResultDistribution _$ResultDistributionFromJson(Map<String, dynamic> json) {
  return _ResultDistribution.fromJson(json);
}

/// @nodoc
mixin _$ResultDistribution {
  String get resultId => throw _privateConstructorUsedError;
  String get resultTitle => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this ResultDistribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultDistributionCopyWith<ResultDistribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultDistributionCopyWith<$Res> {
  factory $ResultDistributionCopyWith(
          ResultDistribution value, $Res Function(ResultDistribution) then) =
      _$ResultDistributionCopyWithImpl<$Res, ResultDistribution>;
  @useResult
  $Res call(
      {String resultId, String resultTitle, int count, double percentage});
}

/// @nodoc
class _$ResultDistributionCopyWithImpl<$Res, $Val extends ResultDistribution>
    implements $ResultDistributionCopyWith<$Res> {
  _$ResultDistributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultId = null,
    Object? resultTitle = null,
    Object? count = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      resultId: null == resultId
          ? _value.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as String,
      resultTitle: null == resultTitle
          ? _value.resultTitle
          : resultTitle // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResultDistributionImplCopyWith<$Res>
    implements $ResultDistributionCopyWith<$Res> {
  factory _$$ResultDistributionImplCopyWith(_$ResultDistributionImpl value,
          $Res Function(_$ResultDistributionImpl) then) =
      __$$ResultDistributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String resultId, String resultTitle, int count, double percentage});
}

/// @nodoc
class __$$ResultDistributionImplCopyWithImpl<$Res>
    extends _$ResultDistributionCopyWithImpl<$Res, _$ResultDistributionImpl>
    implements _$$ResultDistributionImplCopyWith<$Res> {
  __$$ResultDistributionImplCopyWithImpl(_$ResultDistributionImpl _value,
      $Res Function(_$ResultDistributionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultDistribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultId = null,
    Object? resultTitle = null,
    Object? count = null,
    Object? percentage = null,
  }) {
    return _then(_$ResultDistributionImpl(
      resultId: null == resultId
          ? _value.resultId
          : resultId // ignore: cast_nullable_to_non_nullable
              as String,
      resultTitle: null == resultTitle
          ? _value.resultTitle
          : resultTitle // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultDistributionImpl implements _ResultDistribution {
  const _$ResultDistributionImpl(
      {required this.resultId,
      required this.resultTitle,
      required this.count,
      required this.percentage});

  factory _$ResultDistributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultDistributionImplFromJson(json);

  @override
  final String resultId;
  @override
  final String resultTitle;
  @override
  final int count;
  @override
  final double percentage;

  @override
  String toString() {
    return 'ResultDistribution(resultId: $resultId, resultTitle: $resultTitle, count: $count, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultDistributionImpl &&
            (identical(other.resultId, resultId) ||
                other.resultId == resultId) &&
            (identical(other.resultTitle, resultTitle) ||
                other.resultTitle == resultTitle) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, resultId, resultTitle, count, percentage);

  /// Create a copy of ResultDistribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultDistributionImplCopyWith<_$ResultDistributionImpl> get copyWith =>
      __$$ResultDistributionImplCopyWithImpl<_$ResultDistributionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultDistributionImplToJson(
      this,
    );
  }
}

abstract class _ResultDistribution implements ResultDistribution {
  const factory _ResultDistribution(
      {required final String resultId,
      required final String resultTitle,
      required final int count,
      required final double percentage}) = _$ResultDistributionImpl;

  factory _ResultDistribution.fromJson(Map<String, dynamic> json) =
      _$ResultDistributionImpl.fromJson;

  @override
  String get resultId;
  @override
  String get resultTitle;
  @override
  int get count;
  @override
  double get percentage;

  /// Create a copy of ResultDistribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultDistributionImplCopyWith<_$ResultDistributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
