import 'package:our_today/features/couple/domain/entities/couple.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/domain/entities/couple_day.dart';
import 'package:our_today/features/solo/domain/entities/emotion.dart';

/// 커플 모드 데이터 계약.
abstract interface class CoupleRepository {
  /// 연결된 커플 스트림. 미연결이면 null.
  Stream<Couple?> watchCouple();

  Future<String> createInviteCode();
  Future<void> connectWithCode(String code);
  Future<void> disconnect();

  Stream<CoupleDailyAnswer> watchToday(String dateKey);
  Stream<List<CoupleDailyAnswer>> watchRevealedHistory();
  Future<void> submitAnswer(String dateKey, String text);

  /// 연결 시 감정을 커플에 공유(기록 탭에서 연인 감정 보기용).
  Future<void> setEmotion(String dateKey, Emotion emotion);

  /// 커플의 일별 공유 데이터(감정 · 공개 답변) 스트림.
  Stream<List<CoupleDay>> watchDays();

  /// [데모 전용] 상대방이 답한 상황을 시뮬레이션한다.
  /// Firebase 구현에서는 실제 상대 기기가 답하므로 no-op 으로 둔다.
  Future<void> simulatePartnerAnswer(String dateKey);
}
