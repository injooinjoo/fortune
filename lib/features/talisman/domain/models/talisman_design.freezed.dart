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
  String get userId => throw _privateConstructorUsedError;
  TalismanDesignType get designType => throw _privateConstructorUsedError;
  TalismanCategory get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic> get colors => throw _privateConstructorUsedError;
  Map<String, dynamic> get symbols => throw _privateConstructorUsedError;
  String get mantraText => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  int get effectScore => throw _privateConstructorUsedError;
  List<String> get blessings => throw _privateConstructorUsedError;

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
      String userId,
      TalismanDesignType designType,
      TalismanCategory category,
      String title,
      String imageUrl,
      Map<String, dynamic> colors,
      Map<String, dynamic> symbols,
      String mantraText,
      DateTime createdAt,
      DateTime? expiresAt,
      bool isPremium,
      int effectScore,
      List<String> blessings});
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
      String userId,
      TalismanDesignType designType,
      TalismanCategory category,
      String title,
      String imageUrl,
      Map<String, dynamic> colors,
      Map<String, dynamic> symbols,
      String mantraText,
      DateTime createdAt,
      DateTime? expiresAt,
      bool isPremium,
      int effectScore,
      List<String> blessings});
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TalismanDesignImpl implements _TalismanDesign {
  const _$TalismanDesignImpl(
      {required this.id,
      required this.userId,
      required this.designType,
      required this.category,
      required this.title,
      required this.imageUrl,
      final Map<String, dynamic> colors = const {},
      final Map<String, dynamic> symbols = const {},
      required this.mantraText,
      required this.createdAt,
      this.expiresAt,
      this.isPremium = false,
      this.effectScore = 0,
      final List<String> blessings = const []})
      : _colors = colors,
        _symbols = symbols,
        _blessings = blessings;

  factory _$TalismanDesignImpl.fromJson(Map<String, dynamic> json) =>
      _$$TalismanDesignImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final TalismanDesignType designType;
  @override
  final TalismanCategory category;
  @override
  final String title;
  @override
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
  final String mantraText;
  @override
  final DateTime createdAt;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final int effectScore;
  final List<String> _blessings;
  @override
  @JsonKey()
  List<String> get blessings {
    if (_blessings is EqualUnmodifiableListView) return _blessings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blessings);
  }

  @override
  String toString() {
    return 'TalismanDesign(id: $id, userId: $userId, designType: $designType, category: $category, title: $title, imageUrl: $imageUrl, colors: $colors, symbols: $symbols, mantraText: $mantraText, createdAt: $createdAt, expiresAt: $expiresAt, isPremium: $isPremium, effectScore: $effectScore, blessings: $blessings)';
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
                .equals(other._blessings, _blessings));
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
      const DeepCollectionEquality().hash(_blessings));

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
      required final String userId,
      required final TalismanDesignType designType,
      required final TalismanCategory category,
      required final String title,
      required final String imageUrl,
      final Map<String, dynamic> colors,
      final Map<String, dynamic> symbols,
      required final String mantraText,
      required final DateTime createdAt,
      final DateTime? expiresAt,
      final bool isPremium,
      final int effectScore,
      final List<String> blessings}) = _$TalismanDesignImpl;

  factory _TalismanDesign.fromJson(Map<String, dynamic> json) =
      _$TalismanDesignImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  TalismanDesignType get designType;
  @override
  TalismanCategory get category;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  Map<String, dynamic> get colors;
  @override
  Map<String, dynamic> get symbols;
  @override
  String get mantraText;
  @override
  DateTime get createdAt;
  @override
  DateTime? get expiresAt;
  @override
  bool get isPremium;
  @override
  int get effectScore;
  @override
  List<String> get blessings;

  /// Create a copy of TalismanDesign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TalismanDesignImplCopyWith<_$TalismanDesignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
