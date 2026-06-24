/// 인증된 사용자(도메인 엔티티).
class AppUser {
  const AppUser({
    required this.uid,
    required this.nickname,
    this.email,
    this.coupleId,
  });

  final String uid;
  final String nickname;
  final String? email;
  final String? coupleId;

  bool get isConnected => coupleId != null;

  AppUser copyWith({
    String? nickname,
    String? email,
    String? coupleId,
    bool clearCouple = false,
  }) {
    return AppUser(
      uid: uid,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      coupleId: clearCouple ? null : (coupleId ?? this.coupleId),
    );
  }
}
