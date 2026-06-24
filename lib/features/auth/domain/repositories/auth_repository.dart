import 'package:our_today/features/auth/domain/entities/app_user.dart';

/// 인증 계약. 구현은 Mock(기본) 또는 Firebase(Phase 2).
abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();
  Future<void> updateNickname(String nickname);
  Future<void> signOut();
  Future<void> deleteAccount();
}
