import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:our_today/content/question_bank.dart';
import 'package:our_today/core/error/failure.dart';
import 'package:our_today/core/utils/invite_code.dart';
import 'package:our_today/core/utils/rx.dart';
import 'package:our_today/features/couple/domain/entities/couple.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/domain/entities/couple_day.dart';
import 'package:our_today/features/couple/domain/repositories/couple_repository.dart';
import 'package:our_today/features/solo/domain/entities/emotion.dart';

/// Firestore 기반 커플 모드.
/// 멤버십 = couples.memberUids (배열). 블라인드 리빌은 보안규칙으로 무결성 보장:
/// 상대 응답은 "내 응답이 존재할 때"만 read 가능.
class FirebaseCoupleRepository implements CoupleRepository {
  FirebaseCoupleRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> _coupleRef(String cid) =>
      _db.collection('couples').doc(cid);
  CollectionReference<Map<String, dynamic>> _daysCol(String cid) =>
      _db.collection('coupleAnswers').doc(cid).collection('days');

  Couple? _coupleFromDoc(String id, Map<String, dynamic> d) {
    if ((d['status'] as String?) == 'disconnected') return null;
    final members = (d['members'] as Map<String, dynamic>?) ?? {};
    final nick = <String, String>{};
    members.forEach(
        (k, v) => nick[k] = ((v as Map)['nickname'] as String?) ?? '연인');
    final streak = (d['streak'] as Map<String, dynamic>?) ?? {};
    return Couple(
      coupleId: id,
      memberUids: List<String>.from((d['memberUids'] as List?) ?? const []),
      memberNicknames: nick,
      streakCount: (streak['count'] as int?) ?? 0,
      lastRevealDateKey: streak['lastRevealDateKey'] as String?,
    );
  }

  Stream<Couple?> _coupleStream() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _db
        .collection('couples')
        .where('memberUids', arrayContains: uid)
        .snapshots()
        .map((snap) {
      for (final doc in snap.docs) {
        final c = _coupleFromDoc(doc.id, doc.data());
        if (c != null) return c;
      }
      return null;
    });
  }

  @override
  Stream<Couple?> watchCouple() => _coupleStream();

  @override
  Future<String> createInviteCode() async {
    final uid = _uid;
    if (uid == null) throw const Failure('로그인이 필요해요');
    final nickname =
        (await _userRef(uid).get()).data()?['nickname'] as String? ?? '나';
    final code = generateInviteCode();
    await _db.collection('coupleInvites').doc(code).set({
      'createdByUid': uid,
      'createdByNickname': nickname,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt':
          Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
    });
    return code;
  }

  @override
  Future<void> connectWithCode(String code) async {
    final uid = _uid;
    if (uid == null) throw const Failure('로그인이 필요해요');
    final inviteRef =
        _db.collection('coupleInvites').doc(code.trim().toUpperCase());
    final coupleRef = _db.collection('couples').doc();
    await _db.runTransaction((tx) async {
      final invite = await tx.get(inviteRef);
      if (!invite.exists) throw const Failure('유효하지 않은 코드예요');
      final data = invite.data()!;
      if ((data['status'] as String?) != 'active') {
        throw const Failure('이미 사용됐거나 만료된 코드예요');
      }
      final createdBy = data['createdByUid'] as String;
      if (createdBy == uid) throw const Failure('본인 코드는 입력할 수 없어요');
      final myNick =
          (await tx.get(_userRef(uid))).data()?['nickname'] as String? ?? '나';
      final partnerNick = data['createdByNickname'] as String? ?? '연인';

      tx.set(coupleRef, {
        'memberUids': [createdBy, uid],
        'members': {
          createdBy: {'nickname': partnerNick},
          uid: {'nickname': myNick},
        },
        'streak': {'count': 0, 'lastRevealDateKey': null},
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(inviteRef, {'status': 'used', 'usedByUid': uid});
    });
  }

  @override
  Future<void> disconnect() async {
    final couple = await _coupleStream().first;
    if (couple == null) return;
    await _coupleRef(couple.coupleId).update({'status': 'disconnected'});
  }

  @override
  Stream<CoupleDailyAnswer> watchToday(String dateKey) =>
      switchMap(_coupleStream(), (couple) {
        final q = QuestionBank.forDateKey(dateKey);
        final uid = _uid;
        if (couple == null || uid == null) {
          return Stream.value(CoupleDailyAnswer(dateKey: dateKey, question: q));
        }
        final dayRef = _daysCol(couple.coupleId).doc(dateKey);
        return dayRef.snapshots().asyncMap((daySnap) async {
          final rc = (daySnap.data()?['responseCount'] as int?) ?? 0;
          final myResp = await dayRef.collection('responses').doc(uid).get();
          final myText = myResp.data()?['text'] as String?;
          final iAnswered = myText?.trim().isNotEmpty ?? false;
          final partnerAnswered = iAnswered ? rc >= 2 : rc >= 1;
          String? partnerText;
          if (iAnswered && partnerAnswered) {
            final partnerUid =
                couple.memberUids.firstWhere((u) => u != uid, orElse: () => '');
            if (partnerUid.isNotEmpty) {
              final pr =
                  await dayRef.collection('responses').doc(partnerUid).get();
              partnerText = pr.data()?['text'] as String?;
            }
          }
          return CoupleDailyAnswer(
            dateKey: dateKey,
            question: q,
            myText: myText,
            partnerAnswered: partnerAnswered,
            partnerText: partnerText,
          );
        });
      });

  @override
  Stream<List<CoupleDailyAnswer>> watchRevealedHistory() =>
      switchMap(_coupleStream(), (couple) {
        final uid = _uid;
        if (couple == null || uid == null) {
          return Stream.value(const <CoupleDailyAnswer>[]);
        }
        return _daysCol(couple.coupleId)
            .where('revealed', isEqualTo: true)
            .orderBy('dateKey', descending: true)
            .snapshots()
            .map((snap) => snap.docs.map((doc) {
                  final d = doc.data();
                  final answers =
                      (d['answers'] as Map<String, dynamic>?) ?? {};
                  final myA = (answers[uid] as Map?)?['text'] as String?;
                  String? partnerText;
                  for (final e in answers.entries) {
                    if (e.key != uid) {
                      partnerText = (e.value as Map)['text'] as String?;
                    }
                  }
                  return CoupleDailyAnswer(
                    dateKey: doc.id,
                    question:
                        QuestionBank.byId(d['questionId'] as String? ?? ''),
                    myText: myA,
                    partnerAnswered: true,
                    partnerText: partnerText,
                  );
                }).toList());
      });

  @override
  Future<void> submitAnswer(String dateKey, String text) async {
    final uid = _uid;
    if (uid == null) return;
    final couple = await _coupleStream().first;
    if (couple == null) return;
    final cid = couple.coupleId;
    final dayRef = _daysCol(cid).doc(dateKey);
    final myRespRef = dayRef.collection('responses').doc(uid);
    final q = QuestionBank.forDateKey(dateKey);
    final myNick = couple.memberNicknames[uid] ?? '나';

    final reachedReveal = await _db.runTransaction<bool>((tx) async {
      final daySnap = await tx.get(dayRef);
      final mySnap = await tx.get(myRespRef);
      final existed = mySnap.exists;
      var rc = (daySnap.data()?['responseCount'] as int?) ?? 0;
      if (!existed) rc += 1;
      final revealed = rc >= 2;
      tx.set(
        myRespRef,
        {
          'text': text,
          'nickname': myNick,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      tx.set(
        dayRef,
        {
          'dateKey': dateKey,
          'questionId': q.id,
          'questionText': q.text,
          'category': q.category.name,
          'responseCount': rc,
          'revealed': revealed,
        },
        SetOptions(merge: true),
      );
      return revealed && !existed;
    });

    if (reachedReveal) {
      await _finalizeReveal(cid, dateKey);
    }
  }

  /// 둘 다 제출 직후(내 제출이 reveal 트리거): 양측 답변 비정규화 + streak.
  /// 내 응답이 이미 커밋돼 보안규칙상 상대 응답도 read 가능하다.
  Future<void> _finalizeReveal(String cid, String dateKey) async {
    final dayRef = _daysCol(cid).doc(dateKey);
    final resp = await dayRef.collection('responses').get();
    final answers = <String, dynamic>{};
    for (final r in resp.docs) {
      answers[r.id] = {
        'text': r.data()['text'],
        'nickname': r.data()['nickname'],
      };
    }
    await dayRef.set(
      {'answers': answers, 'revealedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    await _db.runTransaction((tx) async {
      final c = await tx.get(_coupleRef(cid));
      final streak = (c.data()?['streak'] as Map<String, dynamic>?) ?? {};
      if (streak['lastRevealDateKey'] == dateKey) return;
      final count = ((streak['count'] as int?) ?? 0) + 1;
      tx.update(_coupleRef(cid), {
        'streak': {'count': count, 'lastRevealDateKey': dateKey},
      });
    });
  }

  @override
  Future<void> setEmotion(String dateKey, Emotion emotion) async {
    final uid = _uid;
    if (uid == null) return;
    final couple = await _coupleStream().first;
    if (couple == null) return;
    final q = QuestionBank.forDateKey(dateKey);
    await _daysCol(couple.coupleId).doc(dateKey).set(
      {
        'dateKey': dateKey,
        'questionId': q.id,
        'emotions': {uid: emotion.name},
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<List<CoupleDay>> watchDays() => switchMap(_coupleStream(), (couple) {
        if (couple == null) return Stream.value(const <CoupleDay>[]);
        return _daysCol(couple.coupleId).snapshots().map((snap) {
          return snap.docs.map((doc) {
            final d = doc.data();
            final emotions = <String, Emotion>{};
            (d['emotions'] as Map<String, dynamic>?)?.forEach((k, v) {
              final e = Emotion.fromName(v as String?);
              if (e != null) emotions[k] = e;
            });
            final revealed = (d['revealed'] as bool?) ?? false;
            final answers = <String, String>{};
            if (revealed) {
              (d['answers'] as Map<String, dynamic>?)?.forEach((k, v) {
                final t = (v as Map)['text'] as String?;
                if (t != null) answers[k] = t;
              });
            }
            return CoupleDay(
              dateKey: doc.id,
              emotions: emotions,
              answers: answers,
              revealed: revealed,
            );
          }).toList();
        });
      });

  // 보안규칙상 상대 답변을 대신 쓸 수 없다(블라인드 무결성). Firebase 에선 no-op.
  @override
  Future<void> simulatePartnerAnswer(String dateKey) async {}
}
