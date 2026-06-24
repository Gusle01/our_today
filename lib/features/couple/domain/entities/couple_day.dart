import 'package:our_today/features/solo/domain/entities/emotion.dart';

/// 커플의 하루치 공유 데이터(감정 + 공개된 답변). 기록 탭의 '연인 보기'용.
class CoupleDay {
  const CoupleDay({
    required this.dateKey,
    this.emotions = const {},
    this.answers = const {},
    this.revealed = false,
  });

  final String dateKey;
  final Map<String, Emotion> emotions; // uid -> 감정
  final Map<String, String> answers; // uid -> 답변(공개된 경우만)
  final bool revealed;

  Emotion? emotionOf(String uid) => emotions[uid];
  String? answerOf(String uid) => answers[uid];
}
