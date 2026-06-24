import 'dart:async';

import 'package:our_today/content/question_bank.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/core/utils/invite_code.dart';
import 'package:our_today/features/couple/domain/entities/couple.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/domain/entities/couple_day.dart';
import 'package:our_today/features/couple/domain/repositories/couple_repository.dart';
import 'package:our_today/features/solo/domain/entities/emotion.dart';

class _DayState {
  String? myText;
  bool partnerAnswered = false;
  String? partnerText;
  final Map<String, String> emotions = {};
}

/// 인메모리 Mock 커플 저장소. 블라인드 리빌을 가짜 상대로 시연한다.
class MockCoupleRepository implements CoupleRepository {
  static const String _myUid = 'me';
  static const String _partnerUid = 'partner';

  Couple? _couple;
  final Map<String, _DayState> _days = {};
  final List<String> _revealedKeys = []; // 최신순
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void _emit() => _changes.add(null);

  Stream<T> _watch<T>(T Function() compute) async* {
    yield compute();
    await for (final _ in _changes.stream) {
      yield compute();
    }
  }

  @override
  Stream<Couple?> watchCouple() => _watch(() => _couple);

  @override
  Future<String> createInviteCode() async => generateInviteCode();

  @override
  Future<void> connectWithCode(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _couple = const Couple(
      coupleId: 'couple_demo',
      memberUids: [_myUid, _partnerUid],
      memberNicknames: {_myUid: '나', _partnerUid: '연인'},
      streakCount: 0,
    );
    _emit();
  }

  @override
  Future<void> disconnect() async {
    _couple = null;
    _days.clear();
    _revealedKeys.clear();
    _emit();
  }

  _DayState _dayOf(String dateKey) =>
      _days.putIfAbsent(dateKey, () => _DayState());

  bool _isRevealed(_DayState d) =>
      (d.myText?.trim().isNotEmpty ?? false) && d.partnerAnswered;

  CoupleDailyAnswer _build(String dateKey) {
    final d = _days[dateKey] ?? _DayState();
    final revealed = _isRevealed(d);
    return CoupleDailyAnswer(
      dateKey: dateKey,
      question: QuestionBank.forDateKey(dateKey),
      myText: d.myText,
      partnerAnswered: d.partnerAnswered,
      partnerText: revealed ? d.partnerText : null,
    );
  }

  void _maybeReveal(String dateKey) {
    final d = _dayOf(dateKey);
    if (_isRevealed(d) && !_revealedKeys.contains(dateKey)) {
      _revealedKeys.insert(0, dateKey);
      final c = _couple;
      if (c != null) {
        _couple = Couple(
          coupleId: c.coupleId,
          memberUids: c.memberUids,
          memberNicknames: c.memberNicknames,
          streakCount: c.streakCount + 1,
          lastRevealDateKey: dateKey,
        );
      }
    }
  }

  @override
  Stream<CoupleDailyAnswer> watchToday(String dateKey) =>
      _watch(() => _build(dateKey));

  @override
  Stream<List<CoupleDailyAnswer>> watchRevealedHistory() =>
      _watch(() => _revealedKeys.map(_build).toList());

  @override
  Future<void> submitAnswer(String dateKey, String text) async {
    _dayOf(dateKey).myText = text;
    _maybeReveal(dateKey);
    _emit();
  }

  @override
  Future<void> setEmotion(String dateKey, Emotion emotion) async {
    _dayOf(dateKey).emotions[_myUid] = emotion.name;
    _emit();
  }

  @override
  Stream<List<CoupleDay>> watchDays() => _watch(() {
        return _days.entries.map((e) {
          final st = e.value;
          final emotions = <String, Emotion>{};
          st.emotions.forEach((k, v) {
            final em = Emotion.fromName(v);
            if (em != null) emotions[k] = em;
          });
          final revealed = _isRevealed(st);
          final answers = <String, String>{};
          if (revealed) {
            answers[_myUid] = st.myText ?? '';
            answers[_partnerUid] = st.partnerText ?? '';
          }
          return CoupleDay(
            dateKey: e.key,
            emotions: emotions,
            answers: answers,
            revealed: revealed,
          );
        }).toList();
      });

  @override
  Future<void> simulatePartnerAnswer(String dateKey) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final d = _dayOf(dateKey);
    d.partnerAnswered = true;
    d.partnerText = _fakePartnerText(dateKey);
    _maybeReveal(dateKey);
    _emit();
  }

  String _fakePartnerText(String dateKey) {
    const samples = [
      '나도 비슷한 생각이었어 🙂',
      '음… 난 조금 다르게 느꼈어. 얘기해보고 싶다!',
      '오늘 너 덕분에 많이 웃었어, 고마워 💕',
      '사실 요즘 이 질문 자주 생각했어.',
      '너랑 같이 가보고 싶은 곳이 생겼어!',
    ];
    return samples[epochDayOf(dateKey) % samples.length];
  }
}
