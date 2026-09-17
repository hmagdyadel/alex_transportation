// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BusStates<T> {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BusStates<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>()';
}


}

/// @nodoc
class $BusStatesCopyWith<T,$Res>  {
$BusStatesCopyWith(BusStates<T> _, $Res Function(BusStates<T>) __);
}


/// Adds pattern-matching-related methods to [BusStates].
extension BusStatesPatterns<T> on BusStates<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial<T> value)?  initial,TResult Function( Loading<T> value)?  loading,TResult Function( SubscribingToRoute<T> value)?  subscribingToRoute,TResult Function( BookingSeat<T> value)?  bookingSeat,TResult Function( CancellingBooking<T> value)?  cancellingBooking,TResult Function( CheckingInToday<T> value)?  checkingInToday,TResult Function( Loaded<T> value)?  loaded,TResult Function( Empty<T> value)?  empty,TResult Function( Success<T> value)?  success,TResult Function( Error<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case SubscribingToRoute() when subscribingToRoute != null:
return subscribingToRoute(_that);case BookingSeat() when bookingSeat != null:
return bookingSeat(_that);case CancellingBooking() when cancellingBooking != null:
return cancellingBooking(_that);case CheckingInToday() when checkingInToday != null:
return checkingInToday(_that);case Loaded() when loaded != null:
return loaded(_that);case Empty() when empty != null:
return empty(_that);case Success() when success != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial<T> value)  initial,required TResult Function( Loading<T> value)  loading,required TResult Function( SubscribingToRoute<T> value)  subscribingToRoute,required TResult Function( BookingSeat<T> value)  bookingSeat,required TResult Function( CancellingBooking<T> value)  cancellingBooking,required TResult Function( CheckingInToday<T> value)  checkingInToday,required TResult Function( Loaded<T> value)  loaded,required TResult Function( Empty<T> value)  empty,required TResult Function( Success<T> value)  success,required TResult Function( Error<T> value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case Loading():
return loading(_that);case SubscribingToRoute():
return subscribingToRoute(_that);case BookingSeat():
return bookingSeat(_that);case CancellingBooking():
return cancellingBooking(_that);case CheckingInToday():
return checkingInToday(_that);case Loaded():
return loaded(_that);case Empty():
return empty(_that);case Success():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial<T> value)?  initial,TResult? Function( Loading<T> value)?  loading,TResult? Function( SubscribingToRoute<T> value)?  subscribingToRoute,TResult? Function( BookingSeat<T> value)?  bookingSeat,TResult? Function( CancellingBooking<T> value)?  cancellingBooking,TResult? Function( CheckingInToday<T> value)?  checkingInToday,TResult? Function( Loaded<T> value)?  loaded,TResult? Function( Empty<T> value)?  empty,TResult? Function( Success<T> value)?  success,TResult? Function( Error<T> value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case SubscribingToRoute() when subscribingToRoute != null:
return subscribingToRoute(_that);case BookingSeat() when bookingSeat != null:
return bookingSeat(_that);case CancellingBooking() when cancellingBooking != null:
return cancellingBooking(_that);case CheckingInToday() when checkingInToday != null:
return checkingInToday(_that);case Loaded() when loaded != null:
return loaded(_that);case Empty() when empty != null:
return empty(_that);case Success() when success != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  subscribingToRoute,TResult Function()?  bookingSeat,TResult Function()?  cancellingBooking,TResult Function()?  checkingInToday,TResult Function()?  loaded,TResult Function()?  empty,TResult Function( T data)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case SubscribingToRoute() when subscribingToRoute != null:
return subscribingToRoute();case BookingSeat() when bookingSeat != null:
return bookingSeat();case CancellingBooking() when cancellingBooking != null:
return cancellingBooking();case CheckingInToday() when checkingInToday != null:
return checkingInToday();case Loaded() when loaded != null:
return loaded();case Empty() when empty != null:
return empty();case Success() when success != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  subscribingToRoute,required TResult Function()  bookingSeat,required TResult Function()  cancellingBooking,required TResult Function()  checkingInToday,required TResult Function()  loaded,required TResult Function()  empty,required TResult Function( T data)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case Loading():
return loading();case SubscribingToRoute():
return subscribingToRoute();case BookingSeat():
return bookingSeat();case CancellingBooking():
return cancellingBooking();case CheckingInToday():
return checkingInToday();case Loaded():
return loaded();case Empty():
return empty();case Success():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  subscribingToRoute,TResult? Function()?  bookingSeat,TResult? Function()?  cancellingBooking,TResult? Function()?  checkingInToday,TResult? Function()?  loaded,TResult? Function()?  empty,TResult? Function( T data)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case SubscribingToRoute() when subscribingToRoute != null:
return subscribingToRoute();case BookingSeat() when bookingSeat != null:
return bookingSeat();case CancellingBooking() when cancellingBooking != null:
return cancellingBooking();case CheckingInToday() when checkingInToday != null:
return checkingInToday();case Loaded() when loaded != null:
return loaded();case Empty() when empty != null:
return empty();case Success() when success != null:
return success(_that.data);case Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial<T> implements BusStates<T> {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.initial()';
}


}




/// @nodoc


class Loading<T> implements BusStates<T> {
  const Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.loading()';
}


}




/// @nodoc


class SubscribingToRoute<T> implements BusStates<T> {
  const SubscribingToRoute();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscribingToRoute<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.subscribingToRoute()';
}


}




/// @nodoc


class BookingSeat<T> implements BusStates<T> {
  const BookingSeat();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingSeat<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.bookingSeat()';
}


}




/// @nodoc


class CancellingBooking<T> implements BusStates<T> {
  const CancellingBooking();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CancellingBooking<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.cancellingBooking()';
}


}




/// @nodoc


class CheckingInToday<T> implements BusStates<T> {
  const CheckingInToday();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckingInToday<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.checkingInToday()';
}


}




/// @nodoc


class Loaded<T> implements BusStates<T> {
  const Loaded();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loaded<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.loaded()';
}


}




/// @nodoc


class Empty<T> implements BusStates<T> {
  const Empty();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Empty<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BusStates<$T>.empty()';
}


}




/// @nodoc


class Success<T> implements BusStates<T> {
  const Success(this.data);
  

 final  T data;

/// Create a copy of BusStates
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
    return 'BusStates<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<T,$Res> implements $BusStatesCopyWith<T, $Res> {
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

/// Create a copy of BusStates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Success<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class Error<T> implements BusStates<T> {
  const Error({required this.message});
  

 final  String message;

/// Create a copy of BusStates
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
    return 'BusStates<$T>.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<T,$Res> implements $BusStatesCopyWith<T, $Res> {
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

/// Create a copy of BusStates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(Error<T>(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
