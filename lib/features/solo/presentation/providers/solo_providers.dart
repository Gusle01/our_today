import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/features/solo/data/repositories/mock_solo_repository.dart';
import 'package:our_today/features/solo/domain/entities/solo_entry.dart';
import 'package:our_today/features/solo/domain/repositories/solo_repository.dart';

final soloRepositoryProvider = Provider<SoloRepository>((ref) {
  return MockSoloRepository();
});

final soloEntriesProvider = StreamProvider<List<SoloEntry>>((ref) {
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
