import 'package:our_today/features/solo/domain/entities/emotion.dart';

/// 혼자 모드 하루치 기록(질문답변 + 감정 + 칭찬일기).
class SoloEntry {
  const SoloEntry({
    required this.dateKey,
    this.questionId,
    this.questionAnswer,
    this.emotion,
    this.emotionMemo,
    this.praise,
  });

  final String dateKey;
  final String? questionId;
  final String? questionAnswer;
  final Emotion? emotion;
  final String? emotionMemo;
  final String? praise;

  bool get hasAnswer => (questionAnswer ?? '').trim().isNotEmpty;
  bool get hasEmotion => emotion != null;
  bool get hasPraise => (praise ?? '').trim().isNotEmpty;
  bool get isComplete => hasAnswer && hasEmotion && hasPraise;

  int get completedCount =>
      (hasAnswer ? 1 : 0) + (hasEmotion ? 1 : 0) + (hasPraise ? 1 : 0);

  SoloEntry copyWith({
    String? questionId,
    String? questionAnswer,
    Emotion? emotion,
    String? emotionMemo,
    String? praise,
  }) {
    return SoloEntry(
      dateKey: dateKey,
      questionId: questionId ?? this.questionId,
      questionAnswer: questionAnswer ?? this.questionAnswer,
      emotion: emotion ?? this.emotion,
      emotionMemo: emotionMemo ?? this.emotionMemo,
      praise: praise ?? this.praise,
    );
  }
}
