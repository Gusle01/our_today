/// 커플 관계(1:1). 멤버 닉네임은 UI 즉시 렌더를 위해 비정규화.
class Couple {
  const Couple({
    required this.coupleId,
    required this.memberUids,
    required this.memberNicknames,
    this.streakCount = 0,
    this.lastRevealDateKey,
  });

  final String coupleId;
  final List<String> memberUids;
  final Map<String, String> memberNicknames; // uid -> nickname
  final int streakCount;
  final String? lastRevealDateKey;

  String partnerNicknameOf(String myUid) {
    for (final entry in memberNicknames.entries) {
      if (entry.key != myUid) return entry.value;
    }
    return '연인';
  }
}
