import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ksi_pm/core/models/user_model.dart';
import 'package:ksi_pm/core/services/auth_service.dart';
import 'package:ksi_pm/core/services/firestore_service.dart';

// Definisi State: kombinasi status login dan data user
class AuthState {
  final bool isLoggedIn;
  final UserModel? userModel;

  AuthState({required this.isLoggedIn, this.userModel});
}

// StateNotifierProvider untuk mengelola status otentikasi
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  late final AuthService _authService;
  late final FirestoreService _firestoreService;

  AuthNotifier(this._ref)
    : super(AuthState(isLoggedIn: false, userModel: null)) {
    _authService = _ref.read(authServiceProvider);
    _firestoreService = _ref.read(firestoreServiceProvider);
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Listener untuk perubahan status Firebase Auth
  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      final userData = await _firestoreService.getUserData(user.uid);
      if (userData != null) {
        state = AuthState(
          isLoggedIn: true,
          userModel: UserModel.fromMap(userData, user.uid),
        );
        return;
      }
    }
    state = AuthState(isLoggedIn: false, userModel: null);
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
