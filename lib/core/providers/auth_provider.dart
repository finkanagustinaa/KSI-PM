import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart'; // Dibutuhkan untuk ambil data UserModel

// 1. Providers Service
final authServiceProvider = Provider((ref) => AuthService());
final firestoreServiceProvider = Provider(
  (ref) => FirestoreService(),
); // Pastikan ini juga diakses jika diperlukan

// 2. Stream Provider (Status Login)
final authStreamProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(
    firestoreServiceProvider,
  ); // Ambil FS Service

  return authService.userChanges.asyncMap((user) async {
    if (user == null) {
      return null;
    }
    // Ambil data UserModel lengkap dari Firestore
    return await firestoreService.getUserData(user.uid);
  });
});

// 3. Controller (Logika Aksi)
final authControllerProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService: authService);
});

class AuthController {
  final AuthService _authService;

  AuthController({required AuthService authService})
    : _authService = authService;

  Future<void> signIn(String email, String password) async {
    await _authService.login(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authService.logout();
  }
}
