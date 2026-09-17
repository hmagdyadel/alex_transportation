import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';

/// Manages invite-code verification and session state.
///
/// Phase 0: skeleton only — no real logic yet.
class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(const AuthStates.initial());

  /// Verify an invite code against the backend.
  Future<void> verifyInviteCode(String code) async {
    safeEmit(const AuthStates.verifyingCode());
    // TODO: Phase 1 — implement invite code verification
  }
}
