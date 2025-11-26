// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investment_ticker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InvestmentTicker _$InvestmentTickerFromJson(Map<String, dynamic> json) {
  return _InvestmentTicker.fromJson(json);
}

/// @nodoc
mixin _$InvestmentTicker {
  String get symbol => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get exchange => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isPopular => throw _privateConstructorUsedError;

  /// Serializes this InvestmentTicker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvestmentTicker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestmentTickerCopyWith<InvestmentTicker> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestmentTickerCopyWith<$Res> {
  factory $InvestmentTickerCopyWith(
          InvestmentTicker value, $Res Function(InvestmentTicker) then) =
      _$InvestmentTickerCopyWithImpl<$Res, InvestmentTicker>;
  @useResult
  $Res call(
      {String symbol,
      String name,
      String category,
      String? exchange,
      String? description,
      bool isPopular});
}

/// @nodoc
class _$InvestmentTickerCopyWithImpl<$Res, $Val extends InvestmentTicker>
    implements $InvestmentTickerCopyWith<$Res> {
  _$InvestmentTickerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvestmentTicker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? category = null,
    Object? exchange = freezed,
    Object? description = freezed,
    Object? isPopular = null,
  }) {
    return _then(_value.copyWith(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      exchange: freezed == exchange
          ? _value.exchange
          : exchange // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvestmentTickerImplCopyWith<$Res>
    implements $InvestmentTickerCopyWith<$Res> {
  factory _$$InvestmentTickerImplCopyWith(_$InvestmentTickerImpl value,
          $Res Function(_$InvestmentTickerImpl) then) =
      __$$InvestmentTickerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String symbol,
      String name,
      String category,
      String? exchange,
      String? description,
      bool isPopular});
}

/// @nodoc
class __$$InvestmentTickerImplCopyWithImpl<$Res>
    extends _$InvestmentTickerCopyWithImpl<$Res, _$InvestmentTickerImpl>
    implements _$$InvestmentTickerImplCopyWith<$Res> {
  __$$InvestmentTickerImplCopyWithImpl(_$InvestmentTickerImpl _value,
      $Res Function(_$InvestmentTickerImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvestmentTicker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? category = null,
    Object? exchange = freezed,
    Object? description = freezed,
    Object? isPopular = null,
  }) {
    return _then(_$InvestmentTickerImpl(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      exchange: freezed == exchange
          ? _value.exchange
          : exchange // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvestmentTickerImpl implements _InvestmentTicker {
  const _$InvestmentTickerImpl(
      {required this.symbol,
      required this.name,
      required this.category,
      this.exchange,
      this.description,
      this.isPopular = false});

  factory _$InvestmentTickerImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestmentTickerImplFromJson(json);

  @override
  final String symbol;
  @override
  final String name;
  @override
  final String category;
  @override
  final String? exchange;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isPopular;

  @override
  String toString() {
    return 'InvestmentTicker(symbol: $symbol, name: $name, category: $category, exchange: $exchange, description: $description, isPopular: $isPopular)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestmentTickerImpl &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.exchange, exchange) ||
                other.exchange == exchange) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, symbol, name, category, exchange, description, isPopular);

  /// Create a copy of InvestmentTicker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestmentTickerImplCopyWith<_$InvestmentTickerImpl> get copyWith =>
      __$$InvestmentTickerImplCopyWithImpl<_$InvestmentTickerImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestmentTickerImplToJson(
      this,
    );
  }
}

abstract class _InvestmentTicker implements InvestmentTicker {
  const factory _InvestmentTicker(
      {required final String symbol,
      required final String name,
      required final String category,
      final String? exchange,
      final String? description,
      final bool isPopular}) = _$InvestmentTickerImpl;

  factory _InvestmentTicker.fromJson(Map<String, dynamic> json) =
      _$InvestmentTickerImpl.fromJson;

  @override
  String get symbol;
  @override
  String get name;
  @override
  String get category;
  @override
  String? get exchange;
  @override
  String? get description;
  @override
  bool get isPopular;

  /// Create a copy of InvestmentTicker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestmentTickerImplCopyWith<_$InvestmentTickerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
