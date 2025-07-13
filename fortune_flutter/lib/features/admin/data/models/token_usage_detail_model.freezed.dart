// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_usage_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TokenUsageDetailModel _$TokenUsageDetailModelFromJson(
    Map<String, dynamic> json) {
  return _TokenUsageDetailModel.fromJson(json);
}

/// @nodoc
mixin _$TokenUsageDetailModel {
  TokenUsageSummary get summary => throw _privateConstructorUsedError;
  List<DailyTokenUsage> get dailyUsage => throw _privateConstructorUsedError;
  List<TokenUsageByType> get usageByType => throw _privateConstructorUsedError;
  List<TopUserUsage> get topUsers => throw _privateConstructorUsedError;
  PackageEfficiency get packageEfficiency => throw _privateConstructorUsedError;
  TokenUsageTrend get trend => throw _privateConstructorUsedError;

  /// Serializes this TokenUsageDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenUsageDetailModelCopyWith<TokenUsageDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenUsageDetailModelCopyWith<$Res> {
  factory $TokenUsageDetailModelCopyWith(TokenUsageDetailModel value,
          $Res Function(TokenUsageDetailModel) then) =
      _$TokenUsageDetailModelCopyWithImpl<$Res, TokenUsageDetailModel>;
  @useResult
  $Res call(
      {TokenUsageSummary summary,
      List<DailyTokenUsage> dailyUsage,
      List<TokenUsageByType> usageByType,
      List<TopUserUsage> topUsers,
      PackageEfficiency packageEfficiency,
      TokenUsageTrend trend});

  $TokenUsageSummaryCopyWith<$Res> get summary;
  $PackageEfficiencyCopyWith<$Res> get packageEfficiency;
  $TokenUsageTrendCopyWith<$Res> get trend;
}

/// @nodoc
class _$TokenUsageDetailModelCopyWithImpl<$Res,
        $Val extends TokenUsageDetailModel>
    implements $TokenUsageDetailModelCopyWith<$Res> {
  _$TokenUsageDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? dailyUsage = null,
    Object? usageByType = null,
    Object? topUsers = null,
    Object? packageEfficiency = null,
    Object? trend = null,
  }) {
    return _then(_value.copyWith(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as TokenUsageSummary,
      dailyUsage: null == dailyUsage
          ? _value.dailyUsage
          : dailyUsage // ignore: cast_nullable_to_non_nullable
              as List<DailyTokenUsage>,
      usageByType: null == usageByType
          ? _value.usageByType
          : usageByType // ignore: cast_nullable_to_non_nullable
              as List<TokenUsageByType>,
      topUsers: null == topUsers
          ? _value.topUsers
          : topUsers // ignore: cast_nullable_to_non_nullable
              as List<TopUserUsage>,
      packageEfficiency: null == packageEfficiency
          ? _value.packageEfficiency
          : packageEfficiency // ignore: cast_nullable_to_non_nullable
              as PackageEfficiency,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TokenUsageTrend,
    ) as $Val);
  }

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TokenUsageSummaryCopyWith<$Res> get summary {
    return $TokenUsageSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PackageEfficiencyCopyWith<$Res> get packageEfficiency {
    return $PackageEfficiencyCopyWith<$Res>(_value.packageEfficiency, (value) {
      return _then(_value.copyWith(packageEfficiency: value) as $Val);
    });
  }

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TokenUsageTrendCopyWith<$Res> get trend {
    return $TokenUsageTrendCopyWith<$Res>(_value.trend, (value) {
      return _then(_value.copyWith(trend: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TokenUsageDetailModelImplCopyWith<$Res>
    implements $TokenUsageDetailModelCopyWith<$Res> {
  factory _$$TokenUsageDetailModelImplCopyWith(
          _$TokenUsageDetailModelImpl value,
          $Res Function(_$TokenUsageDetailModelImpl) then) =
      __$$TokenUsageDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TokenUsageSummary summary,
      List<DailyTokenUsage> dailyUsage,
      List<TokenUsageByType> usageByType,
      List<TopUserUsage> topUsers,
      PackageEfficiency packageEfficiency,
      TokenUsageTrend trend});

  @override
  $TokenUsageSummaryCopyWith<$Res> get summary;
  @override
  $PackageEfficiencyCopyWith<$Res> get packageEfficiency;
  @override
  $TokenUsageTrendCopyWith<$Res> get trend;
}

/// @nodoc
class __$$TokenUsageDetailModelImplCopyWithImpl<$Res>
    extends _$TokenUsageDetailModelCopyWithImpl<$Res,
        _$TokenUsageDetailModelImpl>
    implements _$$TokenUsageDetailModelImplCopyWith<$Res> {
  __$$TokenUsageDetailModelImplCopyWithImpl(_$TokenUsageDetailModelImpl _value,
      $Res Function(_$TokenUsageDetailModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? dailyUsage = null,
    Object? usageByType = null,
    Object? topUsers = null,
    Object? packageEfficiency = null,
    Object? trend = null,
  }) {
    return _then(_$TokenUsageDetailModelImpl(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as TokenUsageSummary,
      dailyUsage: null == dailyUsage
          ? _value._dailyUsage
          : dailyUsage // ignore: cast_nullable_to_non_nullable
              as List<DailyTokenUsage>,
      usageByType: null == usageByType
          ? _value._usageByType
          : usageByType // ignore: cast_nullable_to_non_nullable
              as List<TokenUsageByType>,
      topUsers: null == topUsers
          ? _value._topUsers
          : topUsers // ignore: cast_nullable_to_non_nullable
              as List<TopUserUsage>,
      packageEfficiency: null == packageEfficiency
          ? _value.packageEfficiency
          : packageEfficiency // ignore: cast_nullable_to_non_nullable
              as PackageEfficiency,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TokenUsageTrend,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenUsageDetailModelImpl implements _TokenUsageDetailModel {
  const _$TokenUsageDetailModelImpl(
      {required this.summary,
      required final List<DailyTokenUsage> dailyUsage,
      required final List<TokenUsageByType> usageByType,
      required final List<TopUserUsage> topUsers,
      required this.packageEfficiency,
      required this.trend})
      : _dailyUsage = dailyUsage,
        _usageByType = usageByType,
        _topUsers = topUsers;

  factory _$TokenUsageDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenUsageDetailModelImplFromJson(json);

  @override
  final TokenUsageSummary summary;
  final List<DailyTokenUsage> _dailyUsage;
  @override
  List<DailyTokenUsage> get dailyUsage {
    if (_dailyUsage is EqualUnmodifiableListView) return _dailyUsage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyUsage);
  }

  final List<TokenUsageByType> _usageByType;
  @override
  List<TokenUsageByType> get usageByType {
    if (_usageByType is EqualUnmodifiableListView) return _usageByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_usageByType);
  }

  final List<TopUserUsage> _topUsers;
  @override
  List<TopUserUsage> get topUsers {
    if (_topUsers is EqualUnmodifiableListView) return _topUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topUsers);
  }

  @override
  final PackageEfficiency packageEfficiency;
  @override
  final TokenUsageTrend trend;

  @override
  String toString() {
    return 'TokenUsageDetailModel(summary: $summary, dailyUsage: $dailyUsage, usageByType: $usageByType, topUsers: $topUsers, packageEfficiency: $packageEfficiency, trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenUsageDetailModelImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._dailyUsage, _dailyUsage) &&
            const DeepCollectionEquality()
                .equals(other._usageByType, _usageByType) &&
            const DeepCollectionEquality().equals(other._topUsers, _topUsers) &&
            (identical(other.packageEfficiency, packageEfficiency) ||
                other.packageEfficiency == packageEfficiency) &&
            (identical(other.trend, trend) || other.trend == trend));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      summary,
      const DeepCollectionEquality().hash(_dailyUsage),
      const DeepCollectionEquality().hash(_usageByType),
      const DeepCollectionEquality().hash(_topUsers),
      packageEfficiency,
      trend);

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenUsageDetailModelImplCopyWith<_$TokenUsageDetailModelImpl>
      get copyWith => __$$TokenUsageDetailModelImplCopyWithImpl<
          _$TokenUsageDetailModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenUsageDetailModelImplToJson(
      this,
    );
  }
}

abstract class _TokenUsageDetailModel implements TokenUsageDetailModel {
  const factory _TokenUsageDetailModel(
      {required final TokenUsageSummary summary,
      required final List<DailyTokenUsage> dailyUsage,
      required final List<TokenUsageByType> usageByType,
      required final List<TopUserUsage> topUsers,
      required final PackageEfficiency packageEfficiency,
      required final TokenUsageTrend trend}) = _$TokenUsageDetailModelImpl;

  factory _TokenUsageDetailModel.fromJson(Map<String, dynamic> json) =
      _$TokenUsageDetailModelImpl.fromJson;

  @override
  TokenUsageSummary get summary;
  @override
  List<DailyTokenUsage> get dailyUsage;
  @override
  List<TokenUsageByType> get usageByType;
  @override
  List<TopUserUsage> get topUsers;
  @override
  PackageEfficiency get packageEfficiency;
  @override
  TokenUsageTrend get trend;

  /// Create a copy of TokenUsageDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenUsageDetailModelImplCopyWith<_$TokenUsageDetailModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TokenUsageSummary _$TokenUsageSummaryFromJson(Map<String, dynamic> json) {
  return _TokenUsageSummary.fromJson(json);
}

/// @nodoc
mixin _$TokenUsageSummary {
  int get totalTokensUsed => throw _privateConstructorUsedError;
  int get totalTokensPurchased => throw _privateConstructorUsedError;
  int get activeUsers => throw _privateConstructorUsedError;
  double get averageUsagePerUser => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;

  /// Serializes this TokenUsageSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenUsageSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenUsageSummaryCopyWith<TokenUsageSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenUsageSummaryCopyWith<$Res> {
  factory $TokenUsageSummaryCopyWith(
          TokenUsageSummary value, $Res Function(TokenUsageSummary) then) =
      _$TokenUsageSummaryCopyWithImpl<$Res, TokenUsageSummary>;
  @useResult
  $Res call(
      {int totalTokensUsed,
      int totalTokensPurchased,
      int activeUsers,
      double averageUsagePerUser,
      String period});
}

/// @nodoc
class _$TokenUsageSummaryCopyWithImpl<$Res, $Val extends TokenUsageSummary>
    implements $TokenUsageSummaryCopyWith<$Res> {
  _$TokenUsageSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenUsageSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTokensUsed = null,
    Object? totalTokensPurchased = null,
    Object? activeUsers = null,
    Object? averageUsagePerUser = null,
    Object? period = null,
  }) {
    return _then(_value.copyWith(
      totalTokensUsed: null == totalTokensUsed
          ? _value.totalTokensUsed
          : totalTokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokensPurchased: null == totalTokensPurchased
          ? _value.totalTokensPurchased
          : totalTokensPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      activeUsers: null == activeUsers
          ? _value.activeUsers
          : activeUsers // ignore: cast_nullable_to_non_nullable
              as int,
      averageUsagePerUser: null == averageUsagePerUser
          ? _value.averageUsagePerUser
          : averageUsagePerUser // ignore: cast_nullable_to_non_nullable
              as double,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenUsageSummaryImplCopyWith<$Res>
    implements $TokenUsageSummaryCopyWith<$Res> {
  factory _$$TokenUsageSummaryImplCopyWith(_$TokenUsageSummaryImpl value,
          $Res Function(_$TokenUsageSummaryImpl) then) =
      __$$TokenUsageSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalTokensUsed,
      int totalTokensPurchased,
      int activeUsers,
      double averageUsagePerUser,
      String period});
}

/// @nodoc
class __$$TokenUsageSummaryImplCopyWithImpl<$Res>
    extends _$TokenUsageSummaryCopyWithImpl<$Res, _$TokenUsageSummaryImpl>
    implements _$$TokenUsageSummaryImplCopyWith<$Res> {
  __$$TokenUsageSummaryImplCopyWithImpl(_$TokenUsageSummaryImpl _value,
      $Res Function(_$TokenUsageSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenUsageSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTokensUsed = null,
    Object? totalTokensPurchased = null,
    Object? activeUsers = null,
    Object? averageUsagePerUser = null,
    Object? period = null,
  }) {
    return _then(_$TokenUsageSummaryImpl(
      totalTokensUsed: null == totalTokensUsed
          ? _value.totalTokensUsed
          : totalTokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokensPurchased: null == totalTokensPurchased
          ? _value.totalTokensPurchased
          : totalTokensPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      activeUsers: null == activeUsers
          ? _value.activeUsers
          : activeUsers // ignore: cast_nullable_to_non_nullable
              as int,
      averageUsagePerUser: null == averageUsagePerUser
          ? _value.averageUsagePerUser
          : averageUsagePerUser // ignore: cast_nullable_to_non_nullable
              as double,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenUsageSummaryImpl implements _TokenUsageSummary {
  const _$TokenUsageSummaryImpl(
      {required this.totalTokensUsed,
      required this.totalTokensPurchased,
      required this.activeUsers,
      required this.averageUsagePerUser,
      required this.period});

  factory _$TokenUsageSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenUsageSummaryImplFromJson(json);

  @override
  final int totalTokensUsed;
  @override
  final int totalTokensPurchased;
  @override
  final int activeUsers;
  @override
  final double averageUsagePerUser;
  @override
  final String period;

  @override
  String toString() {
    return 'TokenUsageSummary(totalTokensUsed: $totalTokensUsed, totalTokensPurchased: $totalTokensPurchased, activeUsers: $activeUsers, averageUsagePerUser: $averageUsagePerUser, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenUsageSummaryImpl &&
            (identical(other.totalTokensUsed, totalTokensUsed) ||
                other.totalTokensUsed == totalTokensUsed) &&
            (identical(other.totalTokensPurchased, totalTokensPurchased) ||
                other.totalTokensPurchased == totalTokensPurchased) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.averageUsagePerUser, averageUsagePerUser) ||
                other.averageUsagePerUser == averageUsagePerUser) &&
            (identical(other.period, period) || other.period == period));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalTokensUsed,
      totalTokensPurchased, activeUsers, averageUsagePerUser, period);

  /// Create a copy of TokenUsageSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenUsageSummaryImplCopyWith<_$TokenUsageSummaryImpl> get copyWith =>
      __$$TokenUsageSummaryImplCopyWithImpl<_$TokenUsageSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenUsageSummaryImplToJson(
      this,
    );
  }
}

abstract class _TokenUsageSummary implements TokenUsageSummary {
  const factory _TokenUsageSummary(
      {required final int totalTokensUsed,
      required final int totalTokensPurchased,
      required final int activeUsers,
      required final double averageUsagePerUser,
      required final String period}) = _$TokenUsageSummaryImpl;

  factory _TokenUsageSummary.fromJson(Map<String, dynamic> json) =
      _$TokenUsageSummaryImpl.fromJson;

  @override
  int get totalTokensUsed;
  @override
  int get totalTokensPurchased;
  @override
  int get activeUsers;
  @override
  double get averageUsagePerUser;
  @override
  String get period;

  /// Create a copy of TokenUsageSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenUsageSummaryImplCopyWith<_$TokenUsageSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyTokenUsage _$DailyTokenUsageFromJson(Map<String, dynamic> json) {
  return _DailyTokenUsage.fromJson(json);
}

/// @nodoc
mixin _$DailyTokenUsage {
  DateTime get date => throw _privateConstructorUsedError;
  int get tokensUsed => throw _privateConstructorUsedError;
  int get tokensPurchased => throw _privateConstructorUsedError;
  int get uniqueUsers => throw _privateConstructorUsedError;
  int get transactions => throw _privateConstructorUsedError;

  /// Serializes this DailyTokenUsage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyTokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyTokenUsageCopyWith<DailyTokenUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyTokenUsageCopyWith<$Res> {
  factory $DailyTokenUsageCopyWith(
          DailyTokenUsage value, $Res Function(DailyTokenUsage) then) =
      _$DailyTokenUsageCopyWithImpl<$Res, DailyTokenUsage>;
  @useResult
  $Res call(
      {DateTime date,
      int tokensUsed,
      int tokensPurchased,
      int uniqueUsers,
      int transactions});
}

/// @nodoc
class _$DailyTokenUsageCopyWithImpl<$Res, $Val extends DailyTokenUsage>
    implements $DailyTokenUsageCopyWith<$Res> {
  _$DailyTokenUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyTokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? tokensUsed = null,
    Object? tokensPurchased = null,
    Object? uniqueUsers = null,
    Object? transactions = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      tokensPurchased: null == tokensPurchased
          ? _value.tokensPurchased
          : tokensPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueUsers: null == uniqueUsers
          ? _value.uniqueUsers
          : uniqueUsers // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyTokenUsageImplCopyWith<$Res>
    implements $DailyTokenUsageCopyWith<$Res> {
  factory _$$DailyTokenUsageImplCopyWith(_$DailyTokenUsageImpl value,
          $Res Function(_$DailyTokenUsageImpl) then) =
      __$$DailyTokenUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int tokensUsed,
      int tokensPurchased,
      int uniqueUsers,
      int transactions});
}

/// @nodoc
class __$$DailyTokenUsageImplCopyWithImpl<$Res>
    extends _$DailyTokenUsageCopyWithImpl<$Res, _$DailyTokenUsageImpl>
    implements _$$DailyTokenUsageImplCopyWith<$Res> {
  __$$DailyTokenUsageImplCopyWithImpl(
      _$DailyTokenUsageImpl _value, $Res Function(_$DailyTokenUsageImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyTokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? tokensUsed = null,
    Object? tokensPurchased = null,
    Object? uniqueUsers = null,
    Object? transactions = null,
  }) {
    return _then(_$DailyTokenUsageImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      tokensPurchased: null == tokensPurchased
          ? _value.tokensPurchased
          : tokensPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueUsers: null == uniqueUsers
          ? _value.uniqueUsers
          : uniqueUsers // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyTokenUsageImpl implements _DailyTokenUsage {
  const _$DailyTokenUsageImpl(
      {required this.date,
      required this.tokensUsed,
      required this.tokensPurchased,
      required this.uniqueUsers,
      required this.transactions});

  factory _$DailyTokenUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyTokenUsageImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int tokensUsed;
  @override
  final int tokensPurchased;
  @override
  final int uniqueUsers;
  @override
  final int transactions;

  @override
  String toString() {
    return 'DailyTokenUsage(date: $date, tokensUsed: $tokensUsed, tokensPurchased: $tokensPurchased, uniqueUsers: $uniqueUsers, transactions: $transactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyTokenUsageImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.tokensUsed, tokensUsed) ||
                other.tokensUsed == tokensUsed) &&
            (identical(other.tokensPurchased, tokensPurchased) ||
                other.tokensPurchased == tokensPurchased) &&
            (identical(other.uniqueUsers, uniqueUsers) ||
                other.uniqueUsers == uniqueUsers) &&
            (identical(other.transactions, transactions) ||
                other.transactions == transactions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, tokensUsed,
      tokensPurchased, uniqueUsers, transactions);

  /// Create a copy of DailyTokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyTokenUsageImplCopyWith<_$DailyTokenUsageImpl> get copyWith =>
      __$$DailyTokenUsageImplCopyWithImpl<_$DailyTokenUsageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyTokenUsageImplToJson(
      this,
    );
  }
}

abstract class _DailyTokenUsage implements DailyTokenUsage {
  const factory _DailyTokenUsage(
      {required final DateTime date,
      required final int tokensUsed,
      required final int tokensPurchased,
      required final int uniqueUsers,
      required final int transactions}) = _$DailyTokenUsageImpl;

  factory _DailyTokenUsage.fromJson(Map<String, dynamic> json) =
      _$DailyTokenUsageImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get tokensUsed;
  @override
  int get tokensPurchased;
  @override
  int get uniqueUsers;
  @override
  int get transactions;

  /// Create a copy of DailyTokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyTokenUsageImplCopyWith<_$DailyTokenUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenUsageByType _$TokenUsageByTypeFromJson(Map<String, dynamic> json) {
  return _TokenUsageByType.fromJson(json);
}

/// @nodoc
mixin _$TokenUsageByType {
  String get fortuneType => throw _privateConstructorUsedError;
  String get fortuneCategory => throw _privateConstructorUsedError;
  int get tokensUsed => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this TokenUsageByType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenUsageByType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenUsageByTypeCopyWith<TokenUsageByType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenUsageByTypeCopyWith<$Res> {
  factory $TokenUsageByTypeCopyWith(
          TokenUsageByType value, $Res Function(TokenUsageByType) then) =
      _$TokenUsageByTypeCopyWithImpl<$Res, TokenUsageByType>;
  @useResult
  $Res call(
      {String fortuneType,
      String fortuneCategory,
      int tokensUsed,
      int usageCount,
      double percentage});
}

/// @nodoc
class _$TokenUsageByTypeCopyWithImpl<$Res, $Val extends TokenUsageByType>
    implements $TokenUsageByTypeCopyWith<$Res> {
  _$TokenUsageByTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenUsageByType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fortuneType = null,
    Object? fortuneCategory = null,
    Object? tokensUsed = null,
    Object? usageCount = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      fortuneType: null == fortuneType
          ? _value.fortuneType
          : fortuneType // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneCategory: null == fortuneCategory
          ? _value.fortuneCategory
          : fortuneCategory // ignore: cast_nullable_to_non_nullable
              as String,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenUsageByTypeImplCopyWith<$Res>
    implements $TokenUsageByTypeCopyWith<$Res> {
  factory _$$TokenUsageByTypeImplCopyWith(_$TokenUsageByTypeImpl value,
          $Res Function(_$TokenUsageByTypeImpl) then) =
      __$$TokenUsageByTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fortuneType,
      String fortuneCategory,
      int tokensUsed,
      int usageCount,
      double percentage});
}

/// @nodoc
class __$$TokenUsageByTypeImplCopyWithImpl<$Res>
    extends _$TokenUsageByTypeCopyWithImpl<$Res, _$TokenUsageByTypeImpl>
    implements _$$TokenUsageByTypeImplCopyWith<$Res> {
  __$$TokenUsageByTypeImplCopyWithImpl(_$TokenUsageByTypeImpl _value,
      $Res Function(_$TokenUsageByTypeImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenUsageByType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fortuneType = null,
    Object? fortuneCategory = null,
    Object? tokensUsed = null,
    Object? usageCount = null,
    Object? percentage = null,
  }) {
    return _then(_$TokenUsageByTypeImpl(
      fortuneType: null == fortuneType
          ? _value.fortuneType
          : fortuneType // ignore: cast_nullable_to_non_nullable
              as String,
      fortuneCategory: null == fortuneCategory
          ? _value.fortuneCategory
          : fortuneCategory // ignore: cast_nullable_to_non_nullable
              as String,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
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
class _$TokenUsageByTypeImpl implements _TokenUsageByType {
  const _$TokenUsageByTypeImpl(
      {required this.fortuneType,
      required this.fortuneCategory,
      required this.tokensUsed,
      required this.usageCount,
      required this.percentage});

  factory _$TokenUsageByTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenUsageByTypeImplFromJson(json);

  @override
  final String fortuneType;
  @override
  final String fortuneCategory;
  @override
  final int tokensUsed;
  @override
  final int usageCount;
  @override
  final double percentage;

  @override
  String toString() {
    return 'TokenUsageByType(fortuneType: $fortuneType, fortuneCategory: $fortuneCategory, tokensUsed: $tokensUsed, usageCount: $usageCount, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenUsageByTypeImpl &&
            (identical(other.fortuneType, fortuneType) ||
                other.fortuneType == fortuneType) &&
            (identical(other.fortuneCategory, fortuneCategory) ||
                other.fortuneCategory == fortuneCategory) &&
            (identical(other.tokensUsed, tokensUsed) ||
                other.tokensUsed == tokensUsed) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fortuneType, fortuneCategory,
      tokensUsed, usageCount, percentage);

  /// Create a copy of TokenUsageByType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenUsageByTypeImplCopyWith<_$TokenUsageByTypeImpl> get copyWith =>
      __$$TokenUsageByTypeImplCopyWithImpl<_$TokenUsageByTypeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenUsageByTypeImplToJson(
      this,
    );
  }
}

abstract class _TokenUsageByType implements TokenUsageByType {
  const factory _TokenUsageByType(
      {required final String fortuneType,
      required final String fortuneCategory,
      required final int tokensUsed,
      required final int usageCount,
      required final double percentage}) = _$TokenUsageByTypeImpl;

  factory _TokenUsageByType.fromJson(Map<String, dynamic> json) =
      _$TokenUsageByTypeImpl.fromJson;

  @override
  String get fortuneType;
  @override
  String get fortuneCategory;
  @override
  int get tokensUsed;
  @override
  int get usageCount;
  @override
  double get percentage;

  /// Create a copy of TokenUsageByType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenUsageByTypeImplCopyWith<_$TokenUsageByTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TopUserUsage _$TopUserUsageFromJson(Map<String, dynamic> json) {
  return _TopUserUsage.fromJson(json);
}

/// @nodoc
mixin _$TopUserUsage {
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  int get tokensUsed => throw _privateConstructorUsedError;
  int get tokensPurchased => throw _privateConstructorUsedError;
  int get fortuneCount => throw _privateConstructorUsedError;
  DateTime get lastActivity => throw _privateConstructorUsedError;
  bool get isUnlimited => throw _privateConstructorUsedError;

  /// Serializes this TopUserUsage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopUserUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopUserUsageCopyWith<TopUserUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopUserUsageCopyWith<$Res> {
  factory $TopUserUsageCopyWith(
          TopUserUsage value, $Res Function(TopUserUsage) then) =
      _$TopUserUsageCopyWithImpl<$Res, TopUserUsage>;
  @useResult
  $Res call(
      {String userId,
      String email,
      String? displayName,
      int tokensUsed,
      int tokensPurchased,
      int fortuneCount,
      DateTime lastActivity,
      bool isUnlimited});
}

/// @nodoc
class _$TopUserUsageCopyWithImpl<$Res, $Val extends TopUserUsage>
    implements $TopUserUsageCopyWith<$Res> {
  _$TopUserUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopUserUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? tokensUsed = null,
    Object? tokensPurchased = null,
    Object? fortuneCount = null,
    Object? lastActivity = null,
    Object? isUnlimited = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      tokensPurchased: null == tokensPurchased
          ? _value.tokensPurchased
          : tokensPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneCount: null == fortuneCount
          ? _value.fortuneCount
          : fortuneCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUnlimited: null == isUnlimited
          ? _value.isUnlimited
          : isUnlimited // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopUserUsageImplCopyWith<$Res>
    implements $TopUserUsageCopyWith<$Res> {
  factory _$$TopUserUsageImplCopyWith(
          _$TopUserUsageImpl value, $Res Function(_$TopUserUsageImpl) then) =
      __$$TopUserUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String email,
      String? displayName,
      int tokensUsed,
      int tokensPurchased,
      int fortuneCount,
      DateTime lastActivity,
      bool isUnlimited});
}

/// @nodoc
class __$$TopUserUsageImplCopyWithImpl<$Res>
    extends _$TopUserUsageCopyWithImpl<$Res, _$TopUserUsageImpl>
    implements _$$TopUserUsageImplCopyWith<$Res> {
  __$$TopUserUsageImplCopyWithImpl(
      _$TopUserUsageImpl _value, $Res Function(_$TopUserUsageImpl) _then)
      : super(_value, _then);

  /// Create a copy of TopUserUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? tokensUsed = null,
    Object? tokensPurchased = null,
    Object? fortuneCount = null,
    Object? lastActivity = null,
    Object? isUnlimited = null,
  }) {
    return _then(_$TopUserUsageImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      tokensPurchased: null == tokensPurchased
          ? _value.tokensPurchased
          : tokensPurchased // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneCount: null == fortuneCount
          ? _value.fortuneCount
          : fortuneCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUnlimited: null == isUnlimited
          ? _value.isUnlimited
          : isUnlimited // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopUserUsageImpl implements _TopUserUsage {
  const _$TopUserUsageImpl(
      {required this.userId,
      required this.email,
      required this.displayName,
      required this.tokensUsed,
      required this.tokensPurchased,
      required this.fortuneCount,
      required this.lastActivity,
      required this.isUnlimited});

  factory _$TopUserUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopUserUsageImplFromJson(json);

  @override
  final String userId;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final int tokensUsed;
  @override
  final int tokensPurchased;
  @override
  final int fortuneCount;
  @override
  final DateTime lastActivity;
  @override
  final bool isUnlimited;

  @override
  String toString() {
    return 'TopUserUsage(userId: $userId, email: $email, displayName: $displayName, tokensUsed: $tokensUsed, tokensPurchased: $tokensPurchased, fortuneCount: $fortuneCount, lastActivity: $lastActivity, isUnlimited: $isUnlimited)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopUserUsageImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.tokensUsed, tokensUsed) ||
                other.tokensUsed == tokensUsed) &&
            (identical(other.tokensPurchased, tokensPurchased) ||
                other.tokensPurchased == tokensPurchased) &&
            (identical(other.fortuneCount, fortuneCount) ||
                other.fortuneCount == fortuneCount) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.isUnlimited, isUnlimited) ||
                other.isUnlimited == isUnlimited));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, email, displayName,
      tokensUsed, tokensPurchased, fortuneCount, lastActivity, isUnlimited);

  /// Create a copy of TopUserUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopUserUsageImplCopyWith<_$TopUserUsageImpl> get copyWith =>
      __$$TopUserUsageImplCopyWithImpl<_$TopUserUsageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopUserUsageImplToJson(
      this,
    );
  }
}

abstract class _TopUserUsage implements TopUserUsage {
  const factory _TopUserUsage(
      {required final String userId,
      required final String email,
      required final String? displayName,
      required final int tokensUsed,
      required final int tokensPurchased,
      required final int fortuneCount,
      required final DateTime lastActivity,
      required final bool isUnlimited}) = _$TopUserUsageImpl;

  factory _TopUserUsage.fromJson(Map<String, dynamic> json) =
      _$TopUserUsageImpl.fromJson;

  @override
  String get userId;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  int get tokensUsed;
  @override
  int get tokensPurchased;
  @override
  int get fortuneCount;
  @override
  DateTime get lastActivity;
  @override
  bool get isUnlimited;

  /// Create a copy of TopUserUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopUserUsageImplCopyWith<_$TopUserUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackageEfficiency _$PackageEfficiencyFromJson(Map<String, dynamic> json) {
  return _PackageEfficiency.fromJson(json);
}

/// @nodoc
mixin _$PackageEfficiency {
  Map<String, PackageStats> get packages => throw _privateConstructorUsedError;
  String get mostPopular => throw _privateConstructorUsedError;
  String get bestValue => throw _privateConstructorUsedError;

  /// Serializes this PackageEfficiency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PackageEfficiency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageEfficiencyCopyWith<PackageEfficiency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageEfficiencyCopyWith<$Res> {
  factory $PackageEfficiencyCopyWith(
          PackageEfficiency value, $Res Function(PackageEfficiency) then) =
      _$PackageEfficiencyCopyWithImpl<$Res, PackageEfficiency>;
  @useResult
  $Res call(
      {Map<String, PackageStats> packages,
      String mostPopular,
      String bestValue});
}

/// @nodoc
class _$PackageEfficiencyCopyWithImpl<$Res, $Val extends PackageEfficiency>
    implements $PackageEfficiencyCopyWith<$Res> {
  _$PackageEfficiencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PackageEfficiency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packages = null,
    Object? mostPopular = null,
    Object? bestValue = null,
  }) {
    return _then(_value.copyWith(
      packages: null == packages
          ? _value.packages
          : packages // ignore: cast_nullable_to_non_nullable
              as Map<String, PackageStats>,
      mostPopular: null == mostPopular
          ? _value.mostPopular
          : mostPopular // ignore: cast_nullable_to_non_nullable
              as String,
      bestValue: null == bestValue
          ? _value.bestValue
          : bestValue // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackageEfficiencyImplCopyWith<$Res>
    implements $PackageEfficiencyCopyWith<$Res> {
  factory _$$PackageEfficiencyImplCopyWith(_$PackageEfficiencyImpl value,
          $Res Function(_$PackageEfficiencyImpl) then) =
      __$$PackageEfficiencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, PackageStats> packages,
      String mostPopular,
      String bestValue});
}

/// @nodoc
class __$$PackageEfficiencyImplCopyWithImpl<$Res>
    extends _$PackageEfficiencyCopyWithImpl<$Res, _$PackageEfficiencyImpl>
    implements _$$PackageEfficiencyImplCopyWith<$Res> {
  __$$PackageEfficiencyImplCopyWithImpl(_$PackageEfficiencyImpl _value,
      $Res Function(_$PackageEfficiencyImpl) _then)
      : super(_value, _then);

  /// Create a copy of PackageEfficiency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packages = null,
    Object? mostPopular = null,
    Object? bestValue = null,
  }) {
    return _then(_$PackageEfficiencyImpl(
      packages: null == packages
          ? _value._packages
          : packages // ignore: cast_nullable_to_non_nullable
              as Map<String, PackageStats>,
      mostPopular: null == mostPopular
          ? _value.mostPopular
          : mostPopular // ignore: cast_nullable_to_non_nullable
              as String,
      bestValue: null == bestValue
          ? _value.bestValue
          : bestValue // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageEfficiencyImpl implements _PackageEfficiency {
  const _$PackageEfficiencyImpl(
      {required final Map<String, PackageStats> packages,
      required this.mostPopular,
      required this.bestValue})
      : _packages = packages;

  factory _$PackageEfficiencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageEfficiencyImplFromJson(json);

  final Map<String, PackageStats> _packages;
  @override
  Map<String, PackageStats> get packages {
    if (_packages is EqualUnmodifiableMapView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_packages);
  }

  @override
  final String mostPopular;
  @override
  final String bestValue;

  @override
  String toString() {
    return 'PackageEfficiency(packages: $packages, mostPopular: $mostPopular, bestValue: $bestValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageEfficiencyImpl &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            (identical(other.mostPopular, mostPopular) ||
                other.mostPopular == mostPopular) &&
            (identical(other.bestValue, bestValue) ||
                other.bestValue == bestValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_packages), mostPopular, bestValue);

  /// Create a copy of PackageEfficiency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageEfficiencyImplCopyWith<_$PackageEfficiencyImpl> get copyWith =>
      __$$PackageEfficiencyImplCopyWithImpl<_$PackageEfficiencyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageEfficiencyImplToJson(
      this,
    );
  }
}

abstract class _PackageEfficiency implements PackageEfficiency {
  const factory _PackageEfficiency(
      {required final Map<String, PackageStats> packages,
      required final String mostPopular,
      required final String bestValue}) = _$PackageEfficiencyImpl;

  factory _PackageEfficiency.fromJson(Map<String, dynamic> json) =
      _$PackageEfficiencyImpl.fromJson;

  @override
  Map<String, PackageStats> get packages;
  @override
  String get mostPopular;
  @override
  String get bestValue;

  /// Create a copy of PackageEfficiency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageEfficiencyImplCopyWith<_$PackageEfficiencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackageStats _$PackageStatsFromJson(Map<String, dynamic> json) {
  return _PackageStats.fromJson(json);
}

/// @nodoc
mixin _$PackageStats {
  String get packageName => throw _privateConstructorUsedError;
  int get purchaseCount => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  double get conversionRate => throw _privateConstructorUsedError;

  /// Serializes this PackageStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PackageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageStatsCopyWith<PackageStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageStatsCopyWith<$Res> {
  factory $PackageStatsCopyWith(
          PackageStats value, $Res Function(PackageStats) then) =
      _$PackageStatsCopyWithImpl<$Res, PackageStats>;
  @useResult
  $Res call(
      {String packageName,
      int purchaseCount,
      double totalRevenue,
      double conversionRate});
}

/// @nodoc
class _$PackageStatsCopyWithImpl<$Res, $Val extends PackageStats>
    implements $PackageStatsCopyWith<$Res> {
  _$PackageStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PackageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packageName = null,
    Object? purchaseCount = null,
    Object? totalRevenue = null,
    Object? conversionRate = null,
  }) {
    return _then(_value.copyWith(
      packageName: null == packageName
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseCount: null == purchaseCount
          ? _value.purchaseCount
          : purchaseCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackageStatsImplCopyWith<$Res>
    implements $PackageStatsCopyWith<$Res> {
  factory _$$PackageStatsImplCopyWith(
          _$PackageStatsImpl value, $Res Function(_$PackageStatsImpl) then) =
      __$$PackageStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String packageName,
      int purchaseCount,
      double totalRevenue,
      double conversionRate});
}

/// @nodoc
class __$$PackageStatsImplCopyWithImpl<$Res>
    extends _$PackageStatsCopyWithImpl<$Res, _$PackageStatsImpl>
    implements _$$PackageStatsImplCopyWith<$Res> {
  __$$PackageStatsImplCopyWithImpl(
      _$PackageStatsImpl _value, $Res Function(_$PackageStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PackageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packageName = null,
    Object? purchaseCount = null,
    Object? totalRevenue = null,
    Object? conversionRate = null,
  }) {
    return _then(_$PackageStatsImpl(
      packageName: null == packageName
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseCount: null == purchaseCount
          ? _value.purchaseCount
          : purchaseCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageStatsImpl implements _PackageStats {
  const _$PackageStatsImpl(
      {required this.packageName,
      required this.purchaseCount,
      required this.totalRevenue,
      required this.conversionRate});

  factory _$PackageStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageStatsImplFromJson(json);

  @override
  final String packageName;
  @override
  final int purchaseCount;
  @override
  final double totalRevenue;
  @override
  final double conversionRate;

  @override
  String toString() {
    return 'PackageStats(packageName: $packageName, purchaseCount: $purchaseCount, totalRevenue: $totalRevenue, conversionRate: $conversionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageStatsImpl &&
            (identical(other.packageName, packageName) ||
                other.packageName == packageName) &&
            (identical(other.purchaseCount, purchaseCount) ||
                other.purchaseCount == purchaseCount) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.conversionRate, conversionRate) ||
                other.conversionRate == conversionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, packageName, purchaseCount, totalRevenue, conversionRate);

  /// Create a copy of PackageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageStatsImplCopyWith<_$PackageStatsImpl> get copyWith =>
      __$$PackageStatsImplCopyWithImpl<_$PackageStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageStatsImplToJson(
      this,
    );
  }
}

abstract class _PackageStats implements PackageStats {
  const factory _PackageStats(
      {required final String packageName,
      required final int purchaseCount,
      required final double totalRevenue,
      required final double conversionRate}) = _$PackageStatsImpl;

  factory _PackageStats.fromJson(Map<String, dynamic> json) =
      _$PackageStatsImpl.fromJson;

  @override
  String get packageName;
  @override
  int get purchaseCount;
  @override
  double get totalRevenue;
  @override
  double get conversionRate;

  /// Create a copy of PackageStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageStatsImplCopyWith<_$PackageStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenUsageTrend _$TokenUsageTrendFromJson(Map<String, dynamic> json) {
  return _TokenUsageTrend.fromJson(json);
}

/// @nodoc
mixin _$TokenUsageTrend {
  double get dailyGrowth => throw _privateConstructorUsedError;
  double get weeklyGrowth => throw _privateConstructorUsedError;
  double get monthlyGrowth => throw _privateConstructorUsedError;
  String get trendDirection => throw _privateConstructorUsedError;
  List<PeakUsageTime> get peakTimes => throw _privateConstructorUsedError;

  /// Serializes this TokenUsageTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenUsageTrendCopyWith<TokenUsageTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenUsageTrendCopyWith<$Res> {
  factory $TokenUsageTrendCopyWith(
          TokenUsageTrend value, $Res Function(TokenUsageTrend) then) =
      _$TokenUsageTrendCopyWithImpl<$Res, TokenUsageTrend>;
  @useResult
  $Res call(
      {double dailyGrowth,
      double weeklyGrowth,
      double monthlyGrowth,
      String trendDirection,
      List<PeakUsageTime> peakTimes});
}

/// @nodoc
class _$TokenUsageTrendCopyWithImpl<$Res, $Val extends TokenUsageTrend>
    implements $TokenUsageTrendCopyWith<$Res> {
  _$TokenUsageTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyGrowth = null,
    Object? weeklyGrowth = null,
    Object? monthlyGrowth = null,
    Object? trendDirection = null,
    Object? peakTimes = null,
  }) {
    return _then(_value.copyWith(
      dailyGrowth: null == dailyGrowth
          ? _value.dailyGrowth
          : dailyGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyGrowth: null == weeklyGrowth
          ? _value.weeklyGrowth
          : weeklyGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyGrowth: null == monthlyGrowth
          ? _value.monthlyGrowth
          : monthlyGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      peakTimes: null == peakTimes
          ? _value.peakTimes
          : peakTimes // ignore: cast_nullable_to_non_nullable
              as List<PeakUsageTime>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenUsageTrendImplCopyWith<$Res>
    implements $TokenUsageTrendCopyWith<$Res> {
  factory _$$TokenUsageTrendImplCopyWith(_$TokenUsageTrendImpl value,
          $Res Function(_$TokenUsageTrendImpl) then) =
      __$$TokenUsageTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double dailyGrowth,
      double weeklyGrowth,
      double monthlyGrowth,
      String trendDirection,
      List<PeakUsageTime> peakTimes});
}

/// @nodoc
class __$$TokenUsageTrendImplCopyWithImpl<$Res>
    extends _$TokenUsageTrendCopyWithImpl<$Res, _$TokenUsageTrendImpl>
    implements _$$TokenUsageTrendImplCopyWith<$Res> {
  __$$TokenUsageTrendImplCopyWithImpl(
      _$TokenUsageTrendImpl _value, $Res Function(_$TokenUsageTrendImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyGrowth = null,
    Object? weeklyGrowth = null,
    Object? monthlyGrowth = null,
    Object? trendDirection = null,
    Object? peakTimes = null,
  }) {
    return _then(_$TokenUsageTrendImpl(
      dailyGrowth: null == dailyGrowth
          ? _value.dailyGrowth
          : dailyGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyGrowth: null == weeklyGrowth
          ? _value.weeklyGrowth
          : weeklyGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyGrowth: null == monthlyGrowth
          ? _value.monthlyGrowth
          : monthlyGrowth // ignore: cast_nullable_to_non_nullable
              as double,
      trendDirection: null == trendDirection
          ? _value.trendDirection
          : trendDirection // ignore: cast_nullable_to_non_nullable
              as String,
      peakTimes: null == peakTimes
          ? _value._peakTimes
          : peakTimes // ignore: cast_nullable_to_non_nullable
              as List<PeakUsageTime>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenUsageTrendImpl implements _TokenUsageTrend {
  const _$TokenUsageTrendImpl(
      {required this.dailyGrowth,
      required this.weeklyGrowth,
      required this.monthlyGrowth,
      required this.trendDirection,
      required final List<PeakUsageTime> peakTimes})
      : _peakTimes = peakTimes;

  factory _$TokenUsageTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenUsageTrendImplFromJson(json);

  @override
  final double dailyGrowth;
  @override
  final double weeklyGrowth;
  @override
  final double monthlyGrowth;
  @override
  final String trendDirection;
  final List<PeakUsageTime> _peakTimes;
  @override
  List<PeakUsageTime> get peakTimes {
    if (_peakTimes is EqualUnmodifiableListView) return _peakTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_peakTimes);
  }

  @override
  String toString() {
    return 'TokenUsageTrend(dailyGrowth: $dailyGrowth, weeklyGrowth: $weeklyGrowth, monthlyGrowth: $monthlyGrowth, trendDirection: $trendDirection, peakTimes: $peakTimes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenUsageTrendImpl &&
            (identical(other.dailyGrowth, dailyGrowth) ||
                other.dailyGrowth == dailyGrowth) &&
            (identical(other.weeklyGrowth, weeklyGrowth) ||
                other.weeklyGrowth == weeklyGrowth) &&
            (identical(other.monthlyGrowth, monthlyGrowth) ||
                other.monthlyGrowth == monthlyGrowth) &&
            (identical(other.trendDirection, trendDirection) ||
                other.trendDirection == trendDirection) &&
            const DeepCollectionEquality()
                .equals(other._peakTimes, _peakTimes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dailyGrowth,
      weeklyGrowth,
      monthlyGrowth,
      trendDirection,
      const DeepCollectionEquality().hash(_peakTimes));

  /// Create a copy of TokenUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenUsageTrendImplCopyWith<_$TokenUsageTrendImpl> get copyWith =>
      __$$TokenUsageTrendImplCopyWithImpl<_$TokenUsageTrendImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenUsageTrendImplToJson(
      this,
    );
  }
}

abstract class _TokenUsageTrend implements TokenUsageTrend {
  const factory _TokenUsageTrend(
      {required final double dailyGrowth,
      required final double weeklyGrowth,
      required final double monthlyGrowth,
      required final String trendDirection,
      required final List<PeakUsageTime> peakTimes}) = _$TokenUsageTrendImpl;

  factory _TokenUsageTrend.fromJson(Map<String, dynamic> json) =
      _$TokenUsageTrendImpl.fromJson;

  @override
  double get dailyGrowth;
  @override
  double get weeklyGrowth;
  @override
  double get monthlyGrowth;
  @override
  String get trendDirection;
  @override
  List<PeakUsageTime> get peakTimes;

  /// Create a copy of TokenUsageTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenUsageTrendImplCopyWith<_$TokenUsageTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PeakUsageTime _$PeakUsageTimeFromJson(Map<String, dynamic> json) {
  return _PeakUsageTime.fromJson(json);
}

/// @nodoc
mixin _$PeakUsageTime {
  int get hour => throw _privateConstructorUsedError;
  String get dayOfWeek => throw _privateConstructorUsedError;
  double get averageTokens => throw _privateConstructorUsedError;
  int get userCount => throw _privateConstructorUsedError;

  /// Serializes this PeakUsageTime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeakUsageTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeakUsageTimeCopyWith<PeakUsageTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeakUsageTimeCopyWith<$Res> {
  factory $PeakUsageTimeCopyWith(
          PeakUsageTime value, $Res Function(PeakUsageTime) then) =
      _$PeakUsageTimeCopyWithImpl<$Res, PeakUsageTime>;
  @useResult
  $Res call({int hour, String dayOfWeek, double averageTokens, int userCount});
}

/// @nodoc
class _$PeakUsageTimeCopyWithImpl<$Res, $Val extends PeakUsageTime>
    implements $PeakUsageTimeCopyWith<$Res> {
  _$PeakUsageTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeakUsageTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? dayOfWeek = null,
    Object? averageTokens = null,
    Object? userCount = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      averageTokens: null == averageTokens
          ? _value.averageTokens
          : averageTokens // ignore: cast_nullable_to_non_nullable
              as double,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeakUsageTimeImplCopyWith<$Res>
    implements $PeakUsageTimeCopyWith<$Res> {
  factory _$$PeakUsageTimeImplCopyWith(
          _$PeakUsageTimeImpl value, $Res Function(_$PeakUsageTimeImpl) then) =
      __$$PeakUsageTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, String dayOfWeek, double averageTokens, int userCount});
}

/// @nodoc
class __$$PeakUsageTimeImplCopyWithImpl<$Res>
    extends _$PeakUsageTimeCopyWithImpl<$Res, _$PeakUsageTimeImpl>
    implements _$$PeakUsageTimeImplCopyWith<$Res> {
  __$$PeakUsageTimeImplCopyWithImpl(
      _$PeakUsageTimeImpl _value, $Res Function(_$PeakUsageTimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PeakUsageTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? dayOfWeek = null,
    Object? averageTokens = null,
    Object? userCount = null,
  }) {
    return _then(_$PeakUsageTimeImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      averageTokens: null == averageTokens
          ? _value.averageTokens
          : averageTokens // ignore: cast_nullable_to_non_nullable
              as double,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PeakUsageTimeImpl implements _PeakUsageTime {
  const _$PeakUsageTimeImpl(
      {required this.hour,
      required this.dayOfWeek,
      required this.averageTokens,
      required this.userCount});

  factory _$PeakUsageTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeakUsageTimeImplFromJson(json);

  @override
  final int hour;
  @override
  final String dayOfWeek;
  @override
  final double averageTokens;
  @override
  final int userCount;

  @override
  String toString() {
    return 'PeakUsageTime(hour: $hour, dayOfWeek: $dayOfWeek, averageTokens: $averageTokens, userCount: $userCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeakUsageTimeImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.averageTokens, averageTokens) ||
                other.averageTokens == averageTokens) &&
            (identical(other.userCount, userCount) ||
                other.userCount == userCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, hour, dayOfWeek, averageTokens, userCount);

  /// Create a copy of PeakUsageTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeakUsageTimeImplCopyWith<_$PeakUsageTimeImpl> get copyWith =>
      __$$PeakUsageTimeImplCopyWithImpl<_$PeakUsageTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeakUsageTimeImplToJson(
      this,
    );
  }
}

abstract class _PeakUsageTime implements PeakUsageTime {
  const factory _PeakUsageTime(
      {required final int hour,
      required final String dayOfWeek,
      required final double averageTokens,
      required final int userCount}) = _$PeakUsageTimeImpl;

  factory _PeakUsageTime.fromJson(Map<String, dynamic> json) =
      _$PeakUsageTimeImpl.fromJson;

  @override
  int get hour;
  @override
  String get dayOfWeek;
  @override
  double get averageTokens;
  @override
  int get userCount;

  /// Create a copy of PeakUsageTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeakUsageTimeImplCopyWith<_$PeakUsageTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
