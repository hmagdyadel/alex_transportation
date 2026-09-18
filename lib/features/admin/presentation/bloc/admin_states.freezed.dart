// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminStates<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminStates<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>()';
}


}

/// @nodoc
class $AdminStatesCopyWith<T,$Res>  {
$AdminStatesCopyWith(AdminStates<T> _, $Res Function(AdminStates<T>) __);
}


/// Adds pattern-matching-related methods to [AdminStates].
extension AdminStatesPatterns<T> on AdminStates<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial<T> value)?  initial,TResult Function( Loading<T> value)?  loading,TResult Function( Loaded<T> value)?  loaded,TResult Function( GeneratingCode<T> value)?  generatingCode,TResult Function( Approving<T> value)?  approving,TResult Function( Rejecting<T> value)?  rejecting,TResult Function( Success<T> value)?  success,TResult Function( Error<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Loaded() when loaded != null:
return loaded(_that);case GeneratingCode() when generatingCode != null:
return generatingCode(_that);case Approving() when approving != null:
return approving(_that);case Rejecting() when rejecting != null:
return rejecting(_that);case Success() when success != null:
return success(_that);case Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial<T> value)  initial,required TResult Function( Loading<T> value)  loading,required TResult Function( Loaded<T> value)  loaded,required TResult Function( GeneratingCode<T> value)  generatingCode,required TResult Function( Approving<T> value)  approving,required TResult Function( Rejecting<T> value)  rejecting,required TResult Function( Success<T> value)  success,required TResult Function( Error<T> value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case Loaded():
return loaded(_that);case GeneratingCode():
return generatingCode(_that);case Approving():
return approving(_that);case Rejecting():
return rejecting(_that);case Success():
return success(_that);case Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial<T> value)?  initial,TResult? Function( Loading<T> value)?  loading,TResult? Function( Loaded<T> value)?  loaded,TResult? Function( GeneratingCode<T> value)?  generatingCode,TResult? Function( Approving<T> value)?  approving,TResult? Function( Rejecting<T> value)?  rejecting,TResult? Function( Success<T> value)?  success,TResult? Function( Error<T> value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Loaded() when loaded != null:
return loaded(_that);case GeneratingCode() when generatingCode != null:
return generatingCode(_that);case Approving() when approving != null:
return approving(_that);case Rejecting() when rejecting != null:
return rejecting(_that);case Success() when success != null:
return success(_that);case Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  loaded,TResult Function()?  generatingCode,TResult Function()?  approving,TResult Function()?  rejecting,TResult Function( T data)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Loaded() when loaded != null:
return loaded();case GeneratingCode() when generatingCode != null:
return generatingCode();case Approving() when approving != null:
return approving();case Rejecting() when rejecting != null:
return rejecting();case Success() when success != null:
return success(_that.data);case Error() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  loaded,required TResult Function()  generatingCode,required TResult Function()  approving,required TResult Function()  rejecting,required TResult Function( T data)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case Loaded():
return loaded();case GeneratingCode():
return generatingCode();case Approving():
return approving();case Rejecting():
return rejecting();case Success():
return success(_that.data);case Error():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  loaded,TResult? Function()?  generatingCode,TResult? Function()?  approving,TResult? Function()?  rejecting,TResult? Function( T data)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Loaded() when loaded != null:
return loaded();case GeneratingCode() when generatingCode != null:
return generatingCode();case Approving() when approving != null:
return approving();case Rejecting() when rejecting != null:
return rejecting();case Success() when success != null:
return success(_that.data);case Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial<T> implements AdminStates<T> {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>.initial()';
}


}




/// @nodoc


class Loading<T> implements AdminStates<T> {
  const Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>.loading()';
}


}




/// @nodoc


class Loaded<T> implements AdminStates<T> {
  const Loaded();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loaded<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>.loaded()';
}


}




/// @nodoc


class GeneratingCode<T> implements AdminStates<T> {
  const GeneratingCode();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratingCode<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>.generatingCode()';
}


}




/// @nodoc


class Approving<T> implements AdminStates<T> {
  const Approving();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Approving<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>.approving()';
}


}




/// @nodoc


class Rejecting<T> implements AdminStates<T> {
  const Rejecting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Rejecting<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AdminStates<$T>.rejecting()';
}


}




/// @nodoc


class Success<T> implements AdminStates<T> {
  const Success(this.data);
  

 final  T data;

/// Create a copy of AdminStates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<T, Success<T>> get copyWith => _$SuccessCopyWithImpl<T, Success<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data));
}

@override
String toString() {
    return 'AdminStates<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<T,$Res> implements $AdminStatesCopyWith<T, $Res> {
  factory $SuccessCopyWith(Success<T> value, $Res Function(Success<T>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$SuccessCopyWithImpl<T,$Res>
    implements $SuccessCopyWith<T, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<T> _self;
  final $Res Function(Success<T>) _then;

/// Create a copy of AdminStates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Success<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class Error<T> implements AdminStates<T> {
  const Error({required this.message});
  

 final  String message;

/// Create a copy of AdminStates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorCopyWith<T, Error<T>> get copyWith => _$ErrorCopyWithImpl<T, Error<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Error<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AdminStates<$T>.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<T,$Res> implements $AdminStatesCopyWith<T, $Res> {
  factory $ErrorCopyWith(Error<T> value, $Res Function(Error<T>) _then) = _$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ErrorCopyWithImpl<T,$Res>
    implements $ErrorCopyWith<T, $Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error<T> _self;
  final $Res Function(Error<T>) _then;

/// Create a copy of AdminStates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(Error<T>(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
