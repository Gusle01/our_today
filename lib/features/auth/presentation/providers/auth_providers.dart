import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/config/app_config.dart';
import 'package:our_today/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:our_today/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:our_today/features/auth/domain/entities/app_user.dart';
import 'package:our_today/features/auth/domain/repositories/auth_repository.dart';

/// AppConfig.useFirebase 로 Mock ↔ Firebase 전환.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AppConfig.useFirebase
      ? FirebaseAuthRepository()
      : MockAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
