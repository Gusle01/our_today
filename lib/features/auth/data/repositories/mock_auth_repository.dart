import 'dart:async';

import 'package:our_today/features/auth/domain/entities/app_user.dart';
import 'package:our_today/features/auth/domain/repositories/auth_repository.dart';

/// 인메모리 Mock 인증. Firebase 설정 없이 로그인 흐름을 시연한다.
class MockAuthRepository implements AuthRepository {
  AppUser? _current;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  void _emit() => _controller.add(_current);

  @override
  Future<AppUser> signInWithGoogle() => _fakeSignIn();

  @override
  Future<AppUser> signInWithApple() => _fakeSignIn();

  @override
  Future<AppUser> signInAnonymously() => _fakeSignIn();

  Future<AppUser> _fakeSignIn() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _current = const AppUser(uid: 'me', nickname: '나', email: 'me@example.com');
    _emit();
    return _current!;
  }

  @override
  Future<void> updateNickname(String nickname) async {
    final c = _current;
    if (c == null) return;
    _current = c.copyWith(nickname: nickname);
    _emit();
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _emit();
  }

  @override
  Future<void> deleteAccount() async {
    _current = null;
    _emit();
  }
}
