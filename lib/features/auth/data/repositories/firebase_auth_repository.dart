import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:our_today/features/auth/domain/entities/app_user.dart';
import 'package:our_today/features/auth/domain/repositories/auth_repository.dart';

/// Firebase 기반 인증.
/// Phase 2a: 익명 로그인으로 실제 uid·영구 저장을 확보. Google/Apple 은 2b.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AppUser? _cached;

  @override
  AppUser? get currentUser {
    if (_cached != null) return _cached;
    final u = _auth.currentUser;
    if (u == null) return null;
    // Firestore 로딩 전 임시(닉네임/coupleId 는 authStateChanges 에서 채워짐)
    return AppUser(uid: u.uid, nickname: '나', email: u.email);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        _cached = null;
        yield null;
      } else {
        final appUser = await _ensureUserDoc(user);
        _cached = appUser;
        yield appUser;
      }
    }
  }

  Future<AppUser> _ensureUserDoc(fb.User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      const nickname = '나';
      await ref.set({
        'nickname': nickname,
        'email': user.email,
        'provider': user.isAnonymous ? 'anonymous' : 'unknown',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return AppUser(uid: user.uid, nickname: nickname, email: user.email);
    }
    final data = snap.data() ?? <String, dynamic>{};
    return AppUser(
      uid: user.uid,
      nickname: (data['nickname'] as String?) ?? '나',
      email: data['email'] as String?,
      coupleId: data['coupleId'] as String?,
    );
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    final appUser = await _ensureUserDoc(cred.user!);
    _cached = appUser;
    return appUser;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final provider = fb.GoogleAuthProvider()..addScope('email');
    final current = _auth.currentUser;
    fb.UserCredential cred;
    if (current != null && current.isAnonymous) {
      // 익명 계정을 Google 로 승격 → 기존 기록 유지
      try {
        cred = await current.linkWithProvider(provider);
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          cred = await _auth.signInWithProvider(provider);
        } else {
          rethrow;
        }
      }
    } else {
      cred = await _auth.signInWithProvider(provider);
    }
    final user = cred.user!;
    await _firestore.collection('users').doc(user.uid).set(
      {'provider': 'google.com', 'email': user.email},
      SetOptions(merge: true),
    );
    final appUser = await _ensureUserDoc(user);
    _cached = appUser;
    return appUser;
  }

  // Apple 로그인은 유료 Apple Developer Program 필요 → 현재 미지원(게스트 폴백).
  @override
  Future<AppUser> signInWithApple() => signInAnonymously();

  @override
  Future<void> updateNickname(String nickname) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'nickname': nickname});
    _cached = _cached?.copyWith(nickname: nickname);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).delete();
    } catch (_) {
      // 하위 컬렉션 정리는 Cloud Function 권장
    }
    await user.delete();
  }
}
