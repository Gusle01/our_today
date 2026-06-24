import 'dart:math';

/// 커플 초대코드 생성기.
/// 혼동하기 쉬운 문자(0/O, 1/I)를 제외한 6자리 대문자+숫자.
String generateInviteCode([int length = 6]) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rnd = Random.secure();
  return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
}
