/// 감정 6종 (혼자 모드 감정 기록). 순수 도메인 — Flutter 의존 없음.
enum Emotion {
  happy('행복', '😊'),
  flutter('설렘', '🥰'),
  down('우울', '😢'),
  tired('피곤', '😮‍💨'),
  grateful('감사', '🙏'),
  angry('분노', '😡');

  const Emotion(this.label, this.emoji);

  final String label;
  final String emoji;

  static Emotion? fromName(String? name) {
    if (name == null) return null;
    for (final e in Emotion.values) {
      if (e.name == name) return e;
    }
    return null;
  }
}
