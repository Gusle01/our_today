import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/config/app_config.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';
import 'package:our_today/features/solo/data/repositories/firebase_solo_repository.dart';
import 'package:our_today/features/solo/data/repositories/mock_solo_repository.dart';
import 'package:our_today/features/solo/domain/entities/solo_entry.dart';
import 'package:our_today/features/solo/domain/repositories/solo_repository.dart';

final soloRepositoryProvider = Provider<SoloRepository>((ref) {
  return AppConfig.useFirebase
      ? FirebaseSoloRepository()
      : MockSoloRepository();
});

final soloEntriesProvider = StreamProvider<List<SoloEntry>>((ref) {
  // 로그인 상태가 바뀌면(예: 익명 로그인 완료) uid 반영을 위해 재구독
  ref.watch(authStateProvider);
  return ref.watch(soloRepositoryProvider).watchEntries();
});

/// 오늘 기록(없으면 빈 엔트리).
final todayEntryProvider = Provider<SoloEntry>((ref) {
  final key = todayKey();
  final entries =
      ref.watch(soloEntriesProvider).valueOrNull ?? const <SoloEntry>[];
  return entries.firstWhere(
    (e) => e.dateKey == key,
    orElse: () => SoloEntry(dateKey: key),
  );
});
