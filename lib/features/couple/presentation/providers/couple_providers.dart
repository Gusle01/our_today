import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/features/couple/data/repositories/mock_couple_repository.dart';
import 'package:our_today/features/couple/domain/entities/couple.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/domain/repositories/couple_repository.dart';

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return MockCoupleRepository();
});

final coupleProvider = StreamProvider<Couple?>((ref) {
  return ref.watch(coupleRepositoryProvider).watchCouple();
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(coupleProvider).valueOrNull != null;
});

final todayCoupleAnswerProvider = StreamProvider<CoupleDailyAnswer>((ref) {
  return ref.watch(coupleRepositoryProvider).watchToday(todayKey());
});

final coupleHistoryProvider = StreamProvider<List<CoupleDailyAnswer>>((ref) {
  return ref.watch(coupleRepositoryProvider).watchRevealedHistory();
});
