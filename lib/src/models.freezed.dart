// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Card _$CardFromJson(Map<String, dynamic> json) {
  return _Card.fromJson(json);
}

/// @nodoc
mixin _$Card {
  DateTime get due => throw _privateConstructorUsedError;
  set due(DateTime value) => throw _privateConstructorUsedError;
  DateTime get lastReview => throw _privateConstructorUsedError;
  set lastReview(DateTime value) => throw _privateConstructorUsedError;
  double get stability => throw _privateConstructorUsedError;
  set stability(double value) => throw _privateConstructorUsedError;
  double get difficulty => throw _privateConstructorUsedError;
  set difficulty(double value) => throw _privateConstructorUsedError;
  int get elapsedDays => throw _privateConstructorUsedError;
  set elapsedDays(int value) => throw _privateConstructorUsedError;
  int get scheduledDays => throw _privateConstructorUsedError;
  set scheduledDays(int value) => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  set reps(int value) => throw _privateConstructorUsedError;
  int get lapses => throw _privateConstructorUsedError;
  set lapses(int value) => throw _privateConstructorUsedError;
  State get state => throw _privateConstructorUsedError;
  set state(State value) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            DateTime due,
            DateTime lastReview,
            double stability,
            double difficulty,
            int elapsedDays,
            int scheduledDays,
            int reps,
            int lapses,
            State state)
        def,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            DateTime due,
            DateTime lastReview,
            double stability,
            double difficulty,
            int elapsedDays,
            int scheduledDays,
            int reps,
            int lapses,
            State state)?
        def,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            DateTime due,
            DateTime lastReview,
            double stability,
            double difficulty,
            int elapsedDays,
            int scheduledDays,
            int reps,
            int lapses,
            State state)?
        def,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Card value) def,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Card value)? def,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Card value)? def,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CardCopyWith<Card> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardCopyWith<$Res> {
  factory $CardCopyWith(Card value, $Res Function(Card) then) =
      _$CardCopyWithImpl<$Res, Card>;
  @useResult
  $Res call(
      {DateTime due,
      DateTime lastReview,
      double stability,
      double difficulty,
      int elapsedDays,
      int scheduledDays,
      int reps,
      int lapses,
      State state});
}

/// @nodoc
class _$CardCopyWithImpl<$Res, $Val extends Card>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? due = null,
    Object? lastReview = null,
    Object? stability = null,
    Object? difficulty = null,
    Object? elapsedDays = null,
    Object? scheduledDays = null,
    Object? reps = null,
    Object? lapses = null,
    Object? state = null,
  }) {
    return _then(_value.copyWith(
      due: null == due
          ? _value.due
          : due // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastReview: null == lastReview
          ? _value.lastReview
          : lastReview // ignore: cast_nullable_to_non_nullable
              as DateTime,
      stability: null == stability
          ? _value.stability
          : stability // ignore: cast_nullable_to_non_nullable
              as double,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double,
      elapsedDays: null == elapsedDays
          ? _value.elapsedDays
          : elapsedDays // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDays: null == scheduledDays
          ? _value.scheduledDays
          : scheduledDays // ignore: cast_nullable_to_non_nullable
              as int,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      lapses: null == lapses
          ? _value.lapses
          : lapses // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as State,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardImplCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$$CardImplCopyWith(
          _$CardImpl value, $Res Function(_$CardImpl) then) =
      __$$CardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime due,
      DateTime lastReview,
      double stability,
      double difficulty,
      int elapsedDays,
      int scheduledDays,
      int reps,
      int lapses,
      State state});
}

/// @nodoc
class __$$CardImplCopyWithImpl<$Res>
    extends _$CardCopyWithImpl<$Res, _$CardImpl>
    implements _$$CardImplCopyWith<$Res> {
  __$$CardImplCopyWithImpl(_$CardImpl _value, $Res Function(_$CardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? due = null,
    Object? lastReview = null,
    Object? stability = null,
    Object? difficulty = null,
    Object? elapsedDays = null,
    Object? scheduledDays = null,
    Object? reps = null,
    Object? lapses = null,
    Object? state = null,
  }) {
    return _then(_$CardImpl(
      null == due
          ? _value.due
          : due // ignore: cast_nullable_to_non_nullable
              as DateTime,
      null == lastReview
          ? _value.lastReview
          : lastReview // ignore: cast_nullable_to_non_nullable
              as DateTime,
      null == stability
          ? _value.stability
          : stability // ignore: cast_nullable_to_non_nullable
              as double,
      null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double,
      null == elapsedDays
          ? _value.elapsedDays
          : elapsedDays // ignore: cast_nullable_to_non_nullable
              as int,
      null == scheduledDays
          ? _value.scheduledDays
          : scheduledDays // ignore: cast_nullable_to_non_nullable
              as int,
      null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      null == lapses
          ? _value.lapses
          : lapses // ignore: cast_nullable_to_non_nullable
              as int,
      null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as State,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CardImpl extends _Card {
  _$CardImpl(this.due, this.lastReview,
      [this.stability = 0,
      this.difficulty = 0,
      this.elapsedDays = 0,
      this.scheduledDays = 0,
      this.reps = 0,
      this.lapses = 0,
      this.state = State.newState])
      : super._();

  factory _$CardImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardImplFromJson(json);

  @override
  DateTime due;
  @override
  DateTime lastReview;
  @override
  @JsonKey()
  double stability;
  @override
  @JsonKey()
  double difficulty;
  @override
  @JsonKey()
  int elapsedDays;
  @override
  @JsonKey()
  int scheduledDays;
  @override
  @JsonKey()
  int reps;
  @override
  @JsonKey()
  int lapses;
  @override
  @JsonKey()
  State state;

  @override
  String toString() {
    return 'Card.def(due: $due, lastReview: $lastReview, stability: $stability, difficulty: $difficulty, elapsedDays: $elapsedDays, scheduledDays: $scheduledDays, reps: $reps, lapses: $lapses, state: $state)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardImplCopyWith<_$CardImpl> get copyWith =>
      __$$CardImplCopyWithImpl<_$CardImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            DateTime due,
            DateTime lastReview,
            double stability,
            double difficulty,
            int elapsedDays,
            int scheduledDays,
            int reps,
            int lapses,
            State state)
        def,
  }) {
    return def(due, lastReview, stability, difficulty, elapsedDays,
        scheduledDays, reps, lapses, state);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            DateTime due,
            DateTime lastReview,
            double stability,
            double difficulty,
            int elapsedDays,
            int scheduledDays,
            int reps,
            int lapses,
            State state)?
        def,
  }) {
    return def?.call(due, lastReview, stability, difficulty, elapsedDays,
        scheduledDays, reps, lapses, state);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            DateTime due,
            DateTime lastReview,
            double stability,
            double difficulty,
            int elapsedDays,
            int scheduledDays,
            int reps,
            int lapses,
            State state)?
        def,
    required TResult orElse(),
  }) {
    if (def != null) {
      return def(due, lastReview, stability, difficulty, elapsedDays,
          scheduledDays, reps, lapses, state);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Card value) def,
  }) {
    return def(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Card value)? def,
  }) {
    return def?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Card value)? def,
    required TResult orElse(),
  }) {
    if (def != null) {
      return def(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CardImplToJson(
      this,
    );
  }
}

abstract class _Card extends Card {
  factory _Card(DateTime due, DateTime lastReview,
      [double stability,
      double difficulty,
      int elapsedDays,
      int scheduledDays,
      int reps,
      int lapses,
      State state]) = _$CardImpl;
  _Card._() : super._();

  factory _Card.fromJson(Map<String, dynamic> json) = _$CardImpl.fromJson;

  @override
  DateTime get due;
  set due(DateTime value);
  @override
  DateTime get lastReview;
  set lastReview(DateTime value);
  @override
  double get stability;
  set stability(double value);
  @override
  double get difficulty;
  set difficulty(double value);
  @override
  int get elapsedDays;
  set elapsedDays(int value);
  @override
  int get scheduledDays;
  set scheduledDays(int value);
  @override
  int get reps;
  set reps(int value);
  @override
  int get lapses;
  set lapses(int value);
  @override
  State get state;
  set state(State value);
  @override
  @JsonKey(ignore: true)
  _$$CardImplCopyWith<_$CardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
