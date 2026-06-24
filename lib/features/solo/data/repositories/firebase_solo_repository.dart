import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:our_today/features/solo/domain/entities/emotion.dart';
import 'package:our_today/features/solo/domain/entities/solo_entry.dart';
import 'package:our_today/features/solo/domain/repositories/solo_repository.dart';

/// Firestore 기반 혼자 모드 저장소. 경로: users/{uid}/entries/{dateKey}
class FirebaseSoloRepository implements SoloRepository {
  FirebaseSoloRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _entriesCol() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('entries');
  }

  @override
  Stream<List<SoloEntry>> watchEntries() {
    final col = _entriesCol();
    if (col == null) return Stream.value(const <SoloEntry>[]);
    return col.snapshots().map((snap) {
      final list = snap.docs.map(_fromDoc).toList()
        ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
      return list;
    });
  }

  SoloEntry _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return SoloEntry(
      dateKey: doc.id,
      questionId: d['questionId'] as String?,
      questionAnswer: d['questionAnswer'] as String?,
      emotion: Emotion.fromName(d['emotion'] as String?),
      emotionMemo: d['emotionMemo'] as String?,
      praise: d['praise'] as String?,
    );
  }

  Future<void> _merge(String dateKey, Map<String, dynamic> data) async {
    final col = _entriesCol();
    if (col == null) return;
    await col.doc(dateKey).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> saveAnswer(String dateKey, String questionId, String text) =>
      _merge(dateKey, {'questionId': questionId, 'questionAnswer': text});

  @override
  Future<void> saveEmotion(String dateKey, Emotion emotion, {String? memo}) =>
      _merge(dateKey, {'emotion': emotion.name, 'emotionMemo': memo});

  @override
  Future<void> savePraise(String dateKey, String text) =>
      _merge(dateKey, {'praise': text});
}
