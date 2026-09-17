import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_states.freezed.dart';

@freezed
class AuthStates<T> with _$AuthStates<T> {
  const factory AuthStates.initial() = _Initial;

  const factory AuthStates.loading() = Loading;

  /// Invite code is being verified against Firestore.
  const factory AuthStates.verifyingCode() = VerifyingCode;

  const factory AuthStates.loaded() = Loaded;

  // `empty` intentionally omitted — does not apply to auth.

  const factory AuthStates.success(T data) = Success<T>;

  const factory AuthStates.error({required String message}) = Error;
}
