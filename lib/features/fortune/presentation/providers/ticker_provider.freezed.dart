// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticker_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TickerState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<InvestmentTicker> get tickers => throw _privateConstructorUsedError;
  List<InvestmentTicker> get popularTickers =>
      throw _privateConstructorUsedError;
  Map<String, List<InvestmentTicker>> get tickersByCategory =>
      throw _privateConstructorUsedError;
  String? get selectedCategory => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of TickerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TickerStateCopyWith<TickerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TickerStateCopyWith<$Res> {
  factory $TickerStateCopyWith(
          TickerState value, $Res Function(TickerState) then) =
      _$TickerStateCopyWithImpl<$Res, TickerState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<InvestmentTicker> tickers,
      List<InvestmentTicker> popularTickers,
      Map<String, List<InvestmentTicker>> tickersByCategory,
      String? selectedCategory,
      String? searchQuery,
      String? errorMessage});
}

/// @nodoc
class _$TickerStateCopyWithImpl<$Res, $Val extends TickerState>
    implements $TickerStateCopyWith<$Res> {
  _$TickerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TickerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? tickers = null,
    Object? popularTickers = null,
    Object? tickersByCategory = null,
    Object? selectedCategory = freezed,
    Object? searchQuery = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      tickers: null == tickers
          ? _value.tickers
          : tickers // ignore: cast_nullable_to_non_nullable
              as List<InvestmentTicker>,
      popularTickers: null == popularTickers
          ? _value.popularTickers
          : popularTickers // ignore: cast_nullable_to_non_nullable
              as List<InvestmentTicker>,
      tickersByCategory: null == tickersByCategory
          ? _value.tickersByCategory
          : tickersByCategory // ignore: cast_nullable_to_non_nullable
              as Map<String, List<InvestmentTicker>>,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TickerStateImplCopyWith<$Res>
    implements $TickerStateCopyWith<$Res> {
  factory _$$TickerStateImplCopyWith(
          _$TickerStateImpl value, $Res Function(_$TickerStateImpl) then) =
      __$$TickerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<InvestmentTicker> tickers,
      List<InvestmentTicker> popularTickers,
      Map<String, List<InvestmentTicker>> tickersByCategory,
      String? selectedCategory,
      String? searchQuery,
      String? errorMessage});
}

/// @nodoc
class __$$TickerStateImplCopyWithImpl<$Res>
    extends _$TickerStateCopyWithImpl<$Res, _$TickerStateImpl>
    implements _$$TickerStateImplCopyWith<$Res> {
  __$$TickerStateImplCopyWithImpl(
      _$TickerStateImpl _value, $Res Function(_$TickerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TickerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? tickers = null,
    Object? popularTickers = null,
    Object? tickersByCategory = null,
    Object? selectedCategory = freezed,
    Object? searchQuery = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$TickerStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      tickers: null == tickers
          ? _value._tickers
          : tickers // ignore: cast_nullable_to_non_nullable
              as List<InvestmentTicker>,
      popularTickers: null == popularTickers
          ? _value._popularTickers
          : popularTickers // ignore: cast_nullable_to_non_nullable
              as List<InvestmentTicker>,
      tickersByCategory: null == tickersByCategory
          ? _value._tickersByCategory
          : tickersByCategory // ignore: cast_nullable_to_non_nullable
              as Map<String, List<InvestmentTicker>>,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TickerStateImpl implements _TickerState {
  const _$TickerStateImpl(
      {this.isLoading = false,
      final List<InvestmentTicker> tickers = const [],
      final List<InvestmentTicker> popularTickers = const [],
      final Map<String, List<InvestmentTicker>> tickersByCategory = const {},
      this.selectedCategory,
      this.searchQuery,
      this.errorMessage})
      : _tickers = tickers,
        _popularTickers = popularTickers,
        _tickersByCategory = tickersByCategory;

  @override
  @JsonKey()
  final bool isLoading;
  final List<InvestmentTicker> _tickers;
  @override
  @JsonKey()
  List<InvestmentTicker> get tickers {
    if (_tickers is EqualUnmodifiableListView) return _tickers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tickers);
  }

  final List<InvestmentTicker> _popularTickers;
  @override
  @JsonKey()
  List<InvestmentTicker> get popularTickers {
    if (_popularTickers is EqualUnmodifiableListView) return _popularTickers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularTickers);
  }

  final Map<String, List<InvestmentTicker>> _tickersByCategory;
  @override
  @JsonKey()
  Map<String, List<InvestmentTicker>> get tickersByCategory {
    if (_tickersByCategory is EqualUnmodifiableMapView)
      return _tickersByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tickersByCategory);
  }

  @override
  final String? selectedCategory;
  @override
  final String? searchQuery;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TickerState(isLoading: $isLoading, tickers: $tickers, popularTickers: $popularTickers, tickersByCategory: $tickersByCategory, selectedCategory: $selectedCategory, searchQuery: $searchQuery, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TickerStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._tickers, _tickers) &&
            const DeepCollectionEquality()
                .equals(other._popularTickers, _popularTickers) &&
            const DeepCollectionEquality()
                .equals(other._tickersByCategory, _tickersByCategory) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_tickers),
      const DeepCollectionEquality().hash(_popularTickers),
      const DeepCollectionEquality().hash(_tickersByCategory),
      selectedCategory,
      searchQuery,
      errorMessage);

  /// Create a copy of TickerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TickerStateImplCopyWith<_$TickerStateImpl> get copyWith =>
      __$$TickerStateImplCopyWithImpl<_$TickerStateImpl>(this, _$identity);
}

abstract class _TickerState implements TickerState {
  const factory _TickerState(
      {final bool isLoading,
      final List<InvestmentTicker> tickers,
      final List<InvestmentTicker> popularTickers,
      final Map<String, List<InvestmentTicker>> tickersByCategory,
      final String? selectedCategory,
      final String? searchQuery,
      final String? errorMessage}) = _$TickerStateImpl;

  @override
  bool get isLoading;
  @override
  List<InvestmentTicker> get tickers;
  @override
  List<InvestmentTicker> get popularTickers;
  @override
  Map<String, List<InvestmentTicker>> get tickersByCategory;
  @override
  String? get selectedCategory;
  @override
  String? get searchQuery;
  @override
  String? get errorMessage;

  /// Create a copy of TickerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TickerStateImplCopyWith<_$TickerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
