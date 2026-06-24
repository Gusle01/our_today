import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:our_today/features/auth/domain/entities/app_user.dart';
import 'package:our_today/features/auth/domain/repositories/auth_repository.dart';

/// Phase 2: AppConfig.useFirebase 여부로 Firebase 구현으로 교체.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
