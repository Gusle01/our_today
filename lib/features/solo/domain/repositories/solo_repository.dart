import 'package:our_today/features/solo/domain/entities/emotion.dart';
import 'package:our_today/features/solo/domain/entities/solo_entry.dart';

/// 혼자 모드 데이터 계약.
abstract interface class SoloRepository {
  /// 현재 사용자의 모든 기록 스트림(날짜 desc 권장).
  Stream<List<SoloEntry>> watchEntries();

  Future<void> saveAnswer(String dateKey, String questionId, String text);
  Future<void> saveEmotion(String dateKey, Emotion emotion, {String? memo});
  Future<void> savePraise(String dateKey, String text);
}
