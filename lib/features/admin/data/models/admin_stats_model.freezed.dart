// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdminStatsModel _$AdminStatsModelFromJson(Map<String, dynamic> json) {
  return _AdminStatsModel.fromJson(json);
}

/// @nodoc
mixin _$AdminStatsModel {
  int get totalUsers => throw _privateConstructorUsedError;
  int get activeUsers => throw _privateConstructorUsedError;
  int get totalFortunes => throw _privateConstructorUsedError;
  int get todayFortunes => throw _privateConstructorUsedError;
  int get totalTokensUsed => throw _privateConstructorUsedError;
  int get totalRevenue => throw _privateConstructorUsedError;
  Map<String, int> get fortuneTypeStats => throw _privateConstructorUsedError;
  List<DailyStatModel> get dailyStats => throw _privateConstructorUsedError;
  List<TokenUsageModel> get tokenUsageStats =>
      throw _privateConstructorUsedError;

  /// Serializes this AdminStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminStatsModelCopyWith<AdminStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminStatsModelCopyWith<$Res> {
  factory $AdminStatsModelCopyWith(
          AdminStatsModel value, $Res Function(AdminStatsModel) then) =
      _$AdminStatsModelCopyWithImpl<$Res, AdminStatsModel>;
  @useResult
  $Res call(
      {int totalUsers,
      int activeUsers,
      int totalFortunes,
      int todayFortunes,
      int totalTokensUsed,
      int totalRevenue,
      Map<String, int> fortuneTypeStats,
      List<DailyStatModel> dailyStats,
      List<TokenUsageModel> tokenUsageStats});
}

/// @nodoc
class _$AdminStatsModelCopyWithImpl<$Res, $Val extends AdminStatsModel>
    implements $AdminStatsModelCopyWith<$Res> {
  _$AdminStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? activeUsers = null,
    Object? totalFortunes = null,
    Object? todayFortunes = null,
    Object? totalTokensUsed = null,
    Object? totalRevenue = null,
    Object? fortuneTypeStats = null,
    Object? dailyStats = null,
    Object? tokenUsageStats = null,
  }) {
    return _then(_value.copyWith(
      totalUsers: null == totalUsers
          ? _value.totalUsers
          : totalUsers // ignore: cast_nullable_to_non_nullable
              as int,
      activeUsers: null == activeUsers
          ? _value.activeUsers
          : activeUsers // ignore: cast_nullable_to_non_nullable
              as int,
      totalFortunes: null == totalFortunes
          ? _value.totalFortunes
          : totalFortunes // ignore: cast_nullable_to_non_nullable
              as int,
      todayFortunes: null == todayFortunes
          ? _value.todayFortunes
          : todayFortunes // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokensUsed: null == totalTokensUsed
          ? _value.totalTokensUsed
          : totalTokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneTypeStats: null == fortuneTypeStats
          ? _value.fortuneTypeStats
          : fortuneTypeStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      dailyStats: null == dailyStats
          ? _value.dailyStats
          : dailyStats // ignore: cast_nullable_to_non_nullable
              as List<DailyStatModel>,
      tokenUsageStats: null == tokenUsageStats
          ? _value.tokenUsageStats
          : tokenUsageStats // ignore: cast_nullable_to_non_nullable
              as List<TokenUsageModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminStatsModelImplCopyWith<$Res>
    implements $AdminStatsModelCopyWith<$Res> {
  factory _$$AdminStatsModelImplCopyWith(_$AdminStatsModelImpl value,
          $Res Function(_$AdminStatsModelImpl) then) =
      __$$AdminStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalUsers,
      int activeUsers,
      int totalFortunes,
      int todayFortunes,
      int totalTokensUsed,
      int totalRevenue,
      Map<String, int> fortuneTypeStats,
      List<DailyStatModel> dailyStats,
      List<TokenUsageModel> tokenUsageStats});
}

/// @nodoc
class __$$AdminStatsModelImplCopyWithImpl<$Res>
    extends _$AdminStatsModelCopyWithImpl<$Res, _$AdminStatsModelImpl>
    implements _$$AdminStatsModelImplCopyWith<$Res> {
  __$$AdminStatsModelImplCopyWithImpl(
      _$AdminStatsModelImpl _value, $Res Function(_$AdminStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? activeUsers = null,
    Object? totalFortunes = null,
    Object? todayFortunes = null,
    Object? totalTokensUsed = null,
    Object? totalRevenue = null,
    Object? fortuneTypeStats = null,
    Object? dailyStats = null,
    Object? tokenUsageStats = null,
  }) {
    return _then(_$AdminStatsModelImpl(
      totalUsers: null == totalUsers
          ? _value.totalUsers
          : totalUsers // ignore: cast_nullable_to_non_nullable
              as int,
      activeUsers: null == activeUsers
          ? _value.activeUsers
          : activeUsers // ignore: cast_nullable_to_non_nullable
              as int,
      totalFortunes: null == totalFortunes
          ? _value.totalFortunes
          : totalFortunes // ignore: cast_nullable_to_non_nullable
              as int,
      todayFortunes: null == todayFortunes
          ? _value.todayFortunes
          : todayFortunes // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokensUsed: null == totalTokensUsed
          ? _value.totalTokensUsed
          : totalTokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneTypeStats: null == fortuneTypeStats
          ? _value._fortuneTypeStats
          : fortuneTypeStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      dailyStats: null == dailyStats
          ? _value._dailyStats
          : dailyStats // ignore: cast_nullable_to_non_nullable
              as List<DailyStatModel>,
      tokenUsageStats: null == tokenUsageStats
          ? _value._tokenUsageStats
          : tokenUsageStats // ignore: cast_nullable_to_non_nullable
              as List<TokenUsageModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminStatsModelImpl implements _AdminStatsModel {
  const _$AdminStatsModelImpl(
      {required this.totalUsers,
      required this.activeUsers,
      required this.totalFortunes,
      required this.todayFortunes,
      required this.totalTokensUsed,
      required this.totalRevenue,
      required final Map<String, int> fortuneTypeStats,
      required final List<DailyStatModel> dailyStats,
      required final List<TokenUsageModel> tokenUsageStats})
      : _fortuneTypeStats = fortuneTypeStats,
        _dailyStats = dailyStats,
        _tokenUsageStats = tokenUsageStats;

  factory _$AdminStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminStatsModelImplFromJson(json);

  @override
  final int totalUsers;
  @override
  final int activeUsers;
  @override
  final int totalFortunes;
  @override
  final int todayFortunes;
  @override
  final int totalTokensUsed;
  @override
  final int totalRevenue;
  final Map<String, int> _fortuneTypeStats;
  @override
  Map<String, int> get fortuneTypeStats {
    if (_fortuneTypeStats is EqualUnmodifiableMapView) return _fortuneTypeStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fortuneTypeStats);
  }

  final List<DailyStatModel> _dailyStats;
  @override
  List<DailyStatModel> get dailyStats {
    if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyStats);
  }

  final List<TokenUsageModel> _tokenUsageStats;
  @override
  List<TokenUsageModel> get tokenUsageStats {
    if (_tokenUsageStats is EqualUnmodifiableListView) return _tokenUsageStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tokenUsageStats);
  }

  @override
  String toString() {
    return 'AdminStatsModel(totalUsers: $totalUsers, activeUsers: $activeUsers, totalFortunes: $totalFortunes, todayFortunes: $todayFortunes, totalTokensUsed: $totalTokensUsed, totalRevenue: $totalRevenue, fortuneTypeStats: $fortuneTypeStats, dailyStats: $dailyStats, tokenUsageStats: $tokenUsageStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminStatsModelImpl &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.totalFortunes, totalFortunes) ||
                other.totalFortunes == totalFortunes) &&
            (identical(other.todayFortunes, todayFortunes) ||
                other.todayFortunes == todayFortunes) &&
            (identical(other.totalTokensUsed, totalTokensUsed) ||
                other.totalTokensUsed == totalTokensUsed) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            const DeepCollectionEquality()
                .equals(other._fortuneTypeStats, _fortuneTypeStats) &&
            const DeepCollectionEquality()
                .equals(other._dailyStats, _dailyStats) &&
            const DeepCollectionEquality()
                .equals(other._tokenUsageStats, _tokenUsageStats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalUsers,
      activeUsers,
      totalFortunes,
      todayFortunes,
      totalTokensUsed,
      totalRevenue,
      const DeepCollectionEquality().hash(_fortuneTypeStats),
      const DeepCollectionEquality().hash(_dailyStats),
      const DeepCollectionEquality().hash(_tokenUsageStats));

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminStatsModelImplCopyWith<_$AdminStatsModelImpl> get copyWith =>
      __$$AdminStatsModelImplCopyWithImpl<_$AdminStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminStatsModelImplToJson(
      this,
    );
  }
}

abstract class _AdminStatsModel implements AdminStatsModel {
  const factory _AdminStatsModel(
          {required final int totalUsers,
          required final int activeUsers,
          required final int totalFortunes,
          required final int todayFortunes,
          required final int totalTokensUsed,
          required final int totalRevenue,
          required final Map<String, int> fortuneTypeStats,
          required final List<DailyStatModel> dailyStats,
          required final List<TokenUsageModel> tokenUsageStats}) =
      _$AdminStatsModelImpl;

  factory _AdminStatsModel.fromJson(Map<String, dynamic> json) =
      _$AdminStatsModelImpl.fromJson;

  @override
  int get totalUsers;
  @override
  int get activeUsers;
  @override
  int get totalFortunes;
  @override
  int get todayFortunes;
  @override
  int get totalTokensUsed;
  @override
  int get totalRevenue;
  @override
  Map<String, int> get fortuneTypeStats;
  @override
  List<DailyStatModel> get dailyStats;
  @override
  List<TokenUsageModel> get tokenUsageStats;

  /// Create a copy of AdminStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminStatsModelImplCopyWith<_$AdminStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyStatModel _$DailyStatModelFromJson(Map<String, dynamic> json) {
  return _DailyStatModel.fromJson(json);
}

/// @nodoc
mixin _$DailyStatModel {
  DateTime get date => throw _privateConstructorUsedError;
  int get fortunes => throw _privateConstructorUsedError;
  int get users => throw _privateConstructorUsedError;
  int get tokens => throw _privateConstructorUsedError;
  int get revenue => throw _privateConstructorUsedError;

  /// Serializes this DailyStatModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStatModelCopyWith<DailyStatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStatModelCopyWith<$Res> {
  factory $DailyStatModelCopyWith(
          DailyStatModel value, $Res Function(DailyStatModel) then) =
      _$DailyStatModelCopyWithImpl<$Res, DailyStatModel>;
  @useResult
  $Res call({DateTime date, int fortunes, int users, int tokens, int revenue});
}

/// @nodoc
class _$DailyStatModelCopyWithImpl<$Res, $Val extends DailyStatModel>
    implements $DailyStatModelCopyWith<$Res> {
  _$DailyStatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? fortunes = null,
    Object? users = null,
    Object? tokens = null,
    Object? revenue = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fortunes: null == fortunes
          ? _value.fortunes
          : fortunes // ignore: cast_nullable_to_non_nullable
              as int,
      users: null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as int,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStatModelImplCopyWith<$Res>
    implements $DailyStatModelCopyWith<$Res> {
  factory _$$DailyStatModelImplCopyWith(_$DailyStatModelImpl value,
          $Res Function(_$DailyStatModelImpl) then) =
      __$$DailyStatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int fortunes, int users, int tokens, int revenue});
}

/// @nodoc
class __$$DailyStatModelImplCopyWithImpl<$Res>
    extends _$DailyStatModelCopyWithImpl<$Res, _$DailyStatModelImpl>
    implements _$$DailyStatModelImplCopyWith<$Res> {
  __$$DailyStatModelImplCopyWithImpl(
      _$DailyStatModelImpl _value, $Res Function(_$DailyStatModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? fortunes = null,
    Object? users = null,
    Object? tokens = null,
    Object? revenue = null,
  }) {
    return _then(_$DailyStatModelImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fortunes: null == fortunes
          ? _value.fortunes
          : fortunes // ignore: cast_nullable_to_non_nullable
              as int,
      users: null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as int,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStatModelImpl implements _DailyStatModel {
  const _$DailyStatModelImpl(
      {required this.date,
      required this.fortunes,
      required this.users,
      required this.tokens,
      required this.revenue});

  factory _$DailyStatModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStatModelImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int fortunes;
  @override
  final int users;
  @override
  final int tokens;
  @override
  final int revenue;

  @override
  String toString() {
    return 'DailyStatModel(date: $date, fortunes: $fortunes, users: $users, tokens: $tokens, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStatModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.fortunes, fortunes) ||
                other.fortunes == fortunes) &&
            (identical(other.users, users) || other.users == users) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, fortunes, users, tokens, revenue);

  /// Create a copy of DailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStatModelImplCopyWith<_$DailyStatModelImpl> get copyWith =>
      __$$DailyStatModelImplCopyWithImpl<_$DailyStatModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStatModelImplToJson(
      this,
    );
  }
}

abstract class _DailyStatModel implements DailyStatModel {
  const factory _DailyStatModel(
      {required final DateTime date,
      required final int fortunes,
      required final int users,
      required final int tokens,
      required final int revenue}) = _$DailyStatModelImpl;

  factory _DailyStatModel.fromJson(Map<String, dynamic> json) =
      _$DailyStatModelImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get fortunes;
  @override
  int get users;
  @override
  int get tokens;
  @override
  int get revenue;

  /// Create a copy of DailyStatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStatModelImplCopyWith<_$DailyStatModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenUsageModel _$TokenUsageModelFromJson(Map<String, dynamic> json) {
  return _TokenUsageModel.fromJson(json);
}

/// @nodoc
mixin _$TokenUsageModel {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  int get tokensUsed => throw _privateConstructorUsedError;
  int get fortuneCount => throw _privateConstructorUsedError;
  DateTime get lastActivity => throw _privateConstructorUsedError;
  bool get isSubscribed => throw _privateConstructorUsedError;

  /// Serializes this TokenUsageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenUsageModelCopyWith<TokenUsageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenUsageModelCopyWith<$Res> {
  factory $TokenUsageModelCopyWith(
          TokenUsageModel value, $Res Function(TokenUsageModel) then) =
      _$TokenUsageModelCopyWithImpl<$Res, TokenUsageModel>;
  @useResult
  $Res call(
      {String userId,
      String userName,
      int tokensUsed,
      int fortuneCount,
      DateTime lastActivity,
      bool isSubscribed});
}

/// @nodoc
class _$TokenUsageModelCopyWithImpl<$Res, $Val extends TokenUsageModel>
    implements $TokenUsageModelCopyWith<$Res> {
  _$TokenUsageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? tokensUsed = null,
    Object? fortuneCount = null,
    Object? lastActivity = null,
    Object? isSubscribed = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneCount: null == fortuneCount
          ? _value.fortuneCount
          : fortuneCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isSubscribed: null == isSubscribed
          ? _value.isSubscribed
          : isSubscribed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenUsageModelImplCopyWith<$Res>
    implements $TokenUsageModelCopyWith<$Res> {
  factory _$$TokenUsageModelImplCopyWith(_$TokenUsageModelImpl value,
          $Res Function(_$TokenUsageModelImpl) then) =
      __$$TokenUsageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String userName,
      int tokensUsed,
      int fortuneCount,
      DateTime lastActivity,
      bool isSubscribed});
}

/// @nodoc
class __$$TokenUsageModelImplCopyWithImpl<$Res>
    extends _$TokenUsageModelCopyWithImpl<$Res, _$TokenUsageModelImpl>
    implements _$$TokenUsageModelImplCopyWith<$Res> {
  __$$TokenUsageModelImplCopyWithImpl(
      _$TokenUsageModelImpl _value, $Res Function(_$TokenUsageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? tokensUsed = null,
    Object? fortuneCount = null,
    Object? lastActivity = null,
    Object? isSubscribed = null,
  }) {
    return _then(_$TokenUsageModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      tokensUsed: null == tokensUsed
          ? _value.tokensUsed
          : tokensUsed // ignore: cast_nullable_to_non_nullable
              as int,
      fortuneCount: null == fortuneCount
          ? _value.fortuneCount
          : fortuneCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isSubscribed: null == isSubscribed
          ? _value.isSubscribed
          : isSubscribed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenUsageModelImpl implements _TokenUsageModel {
  const _$TokenUsageModelImpl(
      {required this.userId,
      required this.userName,
      required this.tokensUsed,
      required this.fortuneCount,
      required this.lastActivity,
      required this.isSubscribed});

  factory _$TokenUsageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenUsageModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final int tokensUsed;
  @override
  final int fortuneCount;
  @override
  final DateTime lastActivity;
  @override
  final bool isSubscribed;

  @override
  String toString() {
    return 'TokenUsageModel(userId: $userId, userName: $userName, tokensUsed: $tokensUsed, fortuneCount: $fortuneCount, lastActivity: $lastActivity, isSubscribed: $isSubscribed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenUsageModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.tokensUsed, tokensUsed) ||
                other.tokensUsed == tokensUsed) &&
            (identical(other.fortuneCount, fortuneCount) ||
                other.fortuneCount == fortuneCount) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.isSubscribed, isSubscribed) ||
                other.isSubscribed == isSubscribed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userName, tokensUsed,
      fortuneCount, lastActivity, isSubscribed);

  /// Create a copy of TokenUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenUsageModelImplCopyWith<_$TokenUsageModelImpl> get copyWith =>
      __$$TokenUsageModelImplCopyWithImpl<_$TokenUsageModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenUsageModelImplToJson(
      this,
    );
  }
}

abstract class _TokenUsageModel implements TokenUsageModel {
  const factory _TokenUsageModel(
      {required final String userId,
      required final String userName,
      required final int tokensUsed,
      required final int fortuneCount,
      required final DateTime lastActivity,
      required final bool isSubscribed}) = _$TokenUsageModelImpl;

  factory _TokenUsageModel.fromJson(Map<String, dynamic> json) =
      _$TokenUsageModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  int get tokensUsed;
  @override
  int get fortuneCount;
  @override
  DateTime get lastActivity;
  @override
  bool get isSubscribed;

  /// Create a copy of TokenUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenUsageModelImplCopyWith<_$TokenUsageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
