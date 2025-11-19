// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'talisman_design.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TalismanDesign _$TalismanDesignFromJson(Map<String, dynamic> json) {
  return _TalismanDesign.fromJson(json);
}

/// @nodoc
mixin _$TalismanDesign {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'design_type')
  TalismanDesignType get designType => throw _privateConstructorUsedError;
  TalismanCategory get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic> get colors => throw _privateConstructorUsedError;
  Map<String, dynamic> get symbols => throw _privateConstructorUsedError;
  @JsonKey(name: 'mantra_text')
  String get mantraText => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_premium')
  bool get isPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'effect_score')
  int get effectScore => throw _privateConstructorUsedError;
  List<String> get blessings =>
      throw _privateConstructorUsedError; // 🆕 AI 생성 관련 필드 추가
  @JsonKey(name: 'is_ai_generated')
  bool get isAIGenerated => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_characters')
  List<String>? get customCharacters => throw _privateConstructorUsedError;
  @JsonKey(name: 'generation_prompt')
  String? get generationPrompt => throw _privateConstructorUsedError;

  /// Serializes this TalismanDesign to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TalismanDesign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TalismanDesignCopyWith<TalismanDesign> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TalismanDesignCopyWith<$Res> {
  factory $TalismanDesignCopyWith(
          TalismanDesign value, $Res Function(TalismanDesign) then) =
      _$TalismanDesignCopyWithImpl<$Res, TalismanDesign>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'design_type') TalismanDesignType designType,
      TalismanCategory category,
      String title,
      @JsonKey(name: 'image_url') String imageUrl,
      Map<String, dynamic> colors,
      Map<String, dynamic> symbols,
      @JsonKey(name: 'mantra_text') String mantraText,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'is_premium') bool isPremium,
      @JsonKey(name: 'effect_score') int effectScore,
      List<String> blessings,
      @JsonKey(name: 'is_ai_generated') bool isAIGenerated,
      @JsonKey(name: 'custom_characters') List<String>? customCharacters,
      @JsonKey(name: 'generation_prompt') String? generationPrompt});
}

/// @nodoc
class _$TalismanDesignCopyWithImpl<$Res, $Val extends TalismanDesign>
    implements $TalismanDesignCopyWith<$Res> {
  _$TalismanDesignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TalismanDesign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? designType = null,
    Object? category = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? colors = null,
    Object? symbols = null,
    Object? mantraText = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isPremium = null,
    Object? effectScore = null,
    Object? blessings = null,
    Object? isAIGenerated = null,
    Object? customCharacters = freezed,
    Object? generationPrompt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      designType: null == designType
          ? _value.designType
          : designType // ignore: cast_nullable_to_non_nullable
              as TalismanDesignType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TalismanCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      colors: null == colors
          ? _value.colors
          : colors // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      symbols: null == symbols
          ? _value.symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      mantraText: null == mantraText
          ? _value.mantraText
          : mantraText // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      effectScore: null == effectScore
          ? _value.effectScore
          : effectScore // ignore: cast_nullable_to_non_nullable
              as int,
      blessings: null == blessings
          ? _value.blessings
          : blessings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isAIGenerated: null == isAIGenerated
          ? _value.isAIGenerated
          : isAIGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      customCharacters: freezed == customCharacters
          ? _value.customCharacters
          : customCharacters // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      generationPrompt: freezed == generationPrompt
          ? _value.generationPrompt
          : generationPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TalismanDesignImplCopyWith<$Res>
    implements $TalismanDesignCopyWith<$Res> {
  factory _$$TalismanDesignImplCopyWith(_$TalismanDesignImpl value,
          $Res Function(_$TalismanDesignImpl) then) =
      __$$TalismanDesignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'design_type') TalismanDesignType designType,
      TalismanCategory category,
      String title,
      @JsonKey(name: 'image_url') String imageUrl,
      Map<String, dynamic> colors,
      Map<String, dynamic> symbols,
      @JsonKey(name: 'mantra_text') String mantraText,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'is_premium') bool isPremium,
      @JsonKey(name: 'effect_score') int effectScore,
      List<String> blessings,
      @JsonKey(name: 'is_ai_generated') bool isAIGenerated,
      @JsonKey(name: 'custom_characters') List<String>? customCharacters,
      @JsonKey(name: 'generation_prompt') String? generationPrompt});
}

/// @nodoc
class __$$TalismanDesignImplCopyWithImpl<$Res>
    extends _$TalismanDesignCopyWithImpl<$Res, _$TalismanDesignImpl>
    implements _$$TalismanDesignImplCopyWith<$Res> {
  __$$TalismanDesignImplCopyWithImpl(
      _$TalismanDesignImpl _value, $Res Function(_$TalismanDesignImpl) _then)
      : super(_value, _then);

  /// Create a copy of TalismanDesign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? designType = null,
    Object? category = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? colors = null,
    Object? symbols = null,
    Object? mantraText = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isPremium = null,
    Object? effectScore = null,
    Object? blessings = null,
    Object? isAIGenerated = null,
    Object? customCharacters = freezed,
    Object? generationPrompt = freezed,
  }) {
    return _then(_$TalismanDesignImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      designType: null == designType
          ? _value.designType
          : designType // ignore: cast_nullable_to_non_nullable
              as TalismanDesignType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TalismanCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      colors: null == colors
          ? _value._colors
          : colors // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      symbols: null == symbols
          ? _value._symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      mantraText: null == mantraText
          ? _value.mantraText
          : mantraText // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      effectScore: null == effectScore
          ? _value.effectScore
          : effectScore // ignore: cast_nullable_to_non_nullable
              as int,
      blessings: null == blessings
          ? _value._blessings
          : blessings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isAIGenerated: null == isAIGenerated
          ? _value.isAIGenerated
          : isAIGenerated // ignore: cast_nullable_to_non_nullable
              as bool,
      customCharacters: freezed == customCharacters
          ? _value._customCharacters
          : customCharacters // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      generationPrompt: freezed == generationPrompt
          ? _value.generationPrompt
          : generationPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TalismanDesignImpl implements _TalismanDesign {
  const _$TalismanDesignImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'design_type')
      this.designType = TalismanDesignType.traditional,
      required this.category,
      required this.title,
      @JsonKey(name: 'image_url') required this.imageUrl,
      final Map<String, dynamic> colors = const {},
      final Map<String, dynamic> symbols = const {},
      @JsonKey(name: 'mantra_text') required this.mantraText,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'expires_at') this.expiresAt,
      @JsonKey(name: 'is_premium') this.isPremium = false,
      @JsonKey(name: 'effect_score') this.effectScore = 0,
      final List<String> blessings = const [],
      @JsonKey(name: 'is_ai_generated') this.isAIGenerated = false,
      @JsonKey(name: 'custom_characters') final List<String>? customCharacters,
      @JsonKey(name: 'generation_prompt') this.generationPrompt})
      : _colors = colors,
        _symbols = symbols,
        _blessings = blessings,
        _customCharacters = customCharacters;

  factory _$TalismanDesignImpl.fromJson(Map<String, dynamic> json) =>
      _$$TalismanDesignImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'design_type')
  final TalismanDesignType designType;
  @override
  final TalismanCategory category;
  @override
  final String title;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final Map<String, dynamic> _colors;
  @override
  @JsonKey()
  Map<String, dynamic> get colors {
    if (_colors is EqualUnmodifiableMapView) return _colors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_colors);
  }

  final Map<String, dynamic> _symbols;
  @override
  @JsonKey()
  Map<String, dynamic> get symbols {
    if (_symbols is EqualUnmodifiableMapView) return _symbols;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_symbols);
  }

  @override
  @JsonKey(name: 'mantra_text')
  final String mantraText;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @override
  @JsonKey(name: 'effect_score')
  final int effectScore;
  final List<String> _blessings;
  @override
  @JsonKey()
  List<String> get blessings {
    if (_blessings is EqualUnmodifiableListView) return _blessings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blessings);
  }

// 🆕 AI 생성 관련 필드 추가
  @override
  @JsonKey(name: 'is_ai_generated')
  final bool isAIGenerated;
  final List<String>? _customCharacters;
  @override
  @JsonKey(name: 'custom_characters')
  List<String>? get customCharacters {
    final value = _customCharacters;
    if (value == null) return null;
    if (_customCharacters is EqualUnmodifiableListView)
      return _customCharacters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'generation_prompt')
  final String? generationPrompt;

  @override
  String toString() {
    return 'TalismanDesign(id: $id, userId: $userId, designType: $designType, category: $category, title: $title, imageUrl: $imageUrl, colors: $colors, symbols: $symbols, mantraText: $mantraText, createdAt: $createdAt, expiresAt: $expiresAt, isPremium: $isPremium, effectScore: $effectScore, blessings: $blessings, isAIGenerated: $isAIGenerated, customCharacters: $customCharacters, generationPrompt: $generationPrompt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TalismanDesignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.designType, designType) ||
                other.designType == designType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._colors, _colors) &&
            const DeepCollectionEquality().equals(other._symbols, _symbols) &&
            (identical(other.mantraText, mantraText) ||
                other.mantraText == mantraText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.effectScore, effectScore) ||
                other.effectScore == effectScore) &&
            const DeepCollectionEquality()
                .equals(other._blessings, _blessings) &&
            (identical(other.isAIGenerated, isAIGenerated) ||
                other.isAIGenerated == isAIGenerated) &&
            const DeepCollectionEquality()
                .equals(other._customCharacters, _customCharacters) &&
            (identical(other.generationPrompt, generationPrompt) ||
                other.generationPrompt == generationPrompt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      designType,
      category,
      title,
      imageUrl,
      const DeepCollectionEquality().hash(_colors),
      const DeepCollectionEquality().hash(_symbols),
      mantraText,
      createdAt,
      expiresAt,
      isPremium,
      effectScore,
      const DeepCollectionEquality().hash(_blessings),
      isAIGenerated,
      const DeepCollectionEquality().hash(_customCharacters),
      generationPrompt);

  /// Create a copy of TalismanDesign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TalismanDesignImplCopyWith<_$TalismanDesignImpl> get copyWith =>
      __$$TalismanDesignImplCopyWithImpl<_$TalismanDesignImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TalismanDesignImplToJson(
      this,
    );
  }
}

abstract class _TalismanDesign implements TalismanDesign {
  const factory _TalismanDesign(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'design_type') final TalismanDesignType designType,
      required final TalismanCategory category,
      required final String title,
      @JsonKey(name: 'image_url') required final String imageUrl,
      final Map<String, dynamic> colors,
      final Map<String, dynamic> symbols,
      @JsonKey(name: 'mantra_text') required final String mantraText,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'expires_at') final DateTime? expiresAt,
      @JsonKey(name: 'is_premium') final bool isPremium,
      @JsonKey(name: 'effect_score') final int effectScore,
      final List<String> blessings,
      @JsonKey(name: 'is_ai_generated') final bool isAIGenerated,
      @JsonKey(name: 'custom_characters') final List<String>? customCharacters,
      @JsonKey(name: 'generation_prompt')
      final String? generationPrompt}) = _$TalismanDesignImpl;

  factory _TalismanDesign.fromJson(Map<String, dynamic> json) =
      _$TalismanDesignImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'design_type')
  TalismanDesignType get designType;
  @override
  TalismanCategory get category;
  @override
  String get title;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  Map<String, dynamic> get colors;
  @override
  Map<String, dynamic> get symbols;
  @override
  @JsonKey(name: 'mantra_text')
  String get mantraText;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'is_premium')
  bool get isPremium;
  @override
  @JsonKey(name: 'effect_score')
  int get effectScore;
  @override
  List<String> get blessings; // 🆕 AI 생성 관련 필드 추가
  @override
  @JsonKey(name: 'is_ai_generated')
  bool get isAIGenerated;
  @override
  @JsonKey(name: 'custom_characters')
  List<String>? get customCharacters;
  @override
  @JsonKey(name: 'generation_prompt')
  String? get generationPrompt;

  /// Create a copy of TalismanDesign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TalismanDesignImplCopyWith<_$TalismanDesignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
