// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_interaction_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ContentInteractionState {
  bool get isSaved => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ContentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContentInteractionStateCopyWith<ContentInteractionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContentInteractionStateCopyWith<$Res> {
  factory $ContentInteractionStateCopyWith(ContentInteractionState value,
          $Res Function(ContentInteractionState) then) =
      _$ContentInteractionStateCopyWithImpl<$Res, ContentInteractionState>;
  @useResult
  $Res call({bool isSaved, bool isLoading, String? error});
}

/// @nodoc
class _$ContentInteractionStateCopyWithImpl<$Res,
        $Val extends ContentInteractionState>
    implements $ContentInteractionStateCopyWith<$Res> {
  _$ContentInteractionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSaved = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContentInteractionStateImplCopyWith<$Res>
    implements $ContentInteractionStateCopyWith<$Res> {
  factory _$$ContentInteractionStateImplCopyWith(
          _$ContentInteractionStateImpl value,
          $Res Function(_$ContentInteractionStateImpl) then) =
      __$$ContentInteractionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isSaved, bool isLoading, String? error});
}

/// @nodoc
class __$$ContentInteractionStateImplCopyWithImpl<$Res>
    extends _$ContentInteractionStateCopyWithImpl<$Res,
        _$ContentInteractionStateImpl>
    implements _$$ContentInteractionStateImplCopyWith<$Res> {
  __$$ContentInteractionStateImplCopyWithImpl(
      _$ContentInteractionStateImpl _value,
      $Res Function(_$ContentInteractionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSaved = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$ContentInteractionStateImpl(
      isSaved: null == isSaved
          ? _value.isSaved
          : isSaved // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ContentInteractionStateImpl
    with DiagnosticableTreeMixin
    implements _ContentInteractionState {
  const _$ContentInteractionStateImpl(
      {this.isSaved = false, this.isLoading = false, this.error = null});

  @override
  @JsonKey()
  final bool isSaved;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ContentInteractionState(isSaved: $isSaved, isLoading: $isLoading, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ContentInteractionState'))
      ..add(DiagnosticsProperty('isSaved', isSaved))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentInteractionStateImpl &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSaved, isLoading, error);

  /// Create a copy of ContentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentInteractionStateImplCopyWith<_$ContentInteractionStateImpl>
      get copyWith => __$$ContentInteractionStateImplCopyWithImpl<
          _$ContentInteractionStateImpl>(this, _$identity);
}

abstract class _ContentInteractionState implements ContentInteractionState {
  const factory _ContentInteractionState(
      {final bool isSaved,
      final bool isLoading,
      final String? error}) = _$ContentInteractionStateImpl;

  @override
  bool get isSaved;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of ContentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentInteractionStateImplCopyWith<_$ContentInteractionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
