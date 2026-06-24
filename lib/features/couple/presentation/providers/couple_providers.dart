import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/config/app_config.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';
import 'package:our_today/features/couple/data/repositories/firebase_couple_repository.dart';
import 'package:our_today/features/couple/data/repositories/mock_couple_repository.dart';
import 'package:our_today/features/couple/domain/entities/couple.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/domain/entities/couple_day.dart';
import 'package:our_today/features/couple/domain/repositories/couple_repository.dart';

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return AppConfig.useFirebase
      ? FirebaseCoupleRepository()
      : MockCoupleRepository();
});

final coupleProvider = StreamProvider<Couple?>((ref) {
  ref.watch(authStateProvider); // 로그인 변화 시 재구독
  return ref.watch(coupleRepositoryProvider).watchCouple();
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(coupleProvider).valueOrNull != null;
});

final todayCoupleAnswerProvider = StreamProvider<CoupleDailyAnswer>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(coupleRepositoryProvider).watchToday(todayKey());
});

final coupleHistoryProvider = StreamProvider<List<CoupleDailyAnswer>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(coupleRepositoryProvider).watchRevealedHistory();
});

/// 기록 탭의 '연인 보기'용 — 커플 일별 감정·공개답변.
final coupleDaysProvider = StreamProvider<List<CoupleDay>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(coupleRepositoryProvider).watchDays();
});
