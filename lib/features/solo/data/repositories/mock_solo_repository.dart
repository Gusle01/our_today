import 'dart:async';

import 'package:our_today/features/solo/domain/entities/emotion.dart';
import 'package:our_today/features/solo/domain/entities/solo_entry.dart';
import 'package:our_today/features/solo/domain/repositories/solo_repository.dart';

/// 인메모리 Mock 혼자모드 저장소.
class MockSoloRepository implements SoloRepository {
  final Map<String, SoloEntry> _entries = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<SoloEntry>> watchEntries() async* {
    yield _snapshot();
    await for (final _ in _changes.stream) {
      yield _snapshot();
    }
  }

  List<SoloEntry> _snapshot() {
    final list = _entries.values.toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return list;
  }

  SoloEntry _entryOf(String dateKey) =>
      _entries[dateKey] ?? SoloEntry(dateKey: dateKey);

  void _put(SoloEntry entry) {
    _entries[entry.dateKey] = entry;
    _changes.add(null);
  }

  @override
  Future<void> saveAnswer(String dateKey, String questionId, String text) async {
    _put(_entryOf(dateKey)
        .copyWith(questionId: questionId, questionAnswer: text));
  }

  @override
  Future<void> saveEmotion(String dateKey, Emotion emotion,
      {String? memo}) async {
    _put(_entryOf(dateKey).copyWith(emotion: emotion, emotionMemo: memo));
  }

  @override
  Future<void> savePraise(String dateKey, String text) async {
    _put(_entryOf(dateKey).copyWith(praise: text));
  }
}
