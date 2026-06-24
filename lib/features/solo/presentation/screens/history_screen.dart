import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:our_today/content/question_bank.dart';
import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';
import 'package:our_today/features/couple/domain/entities/couple_day.dart';
import 'package:our_today/features/couple/presentation/providers/couple_providers.dart';
import 'package:our_today/features/solo/domain/entities/emotion.dart';
import 'package:our_today/features/solo/domain/entities/solo_entry.dart';
import 'package:our_today/features/solo/presentation/providers/solo_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(soloEntriesProvider);
    final monthPrefix = DateFormat('yyyy-MM').format(_month);

    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (entries) {
          final byKey = {for (final e in entries) e.dateKey: e};
          final monthEntries =
              entries.where((e) => e.dateKey.startsWith(monthPrefix)).toList();
          final couple = ref.watch(coupleProvider).valueOrNull;
          final myUid = ref.watch(currentUserProvider)?.uid;
          final coupleDays = couple != null
              ? {
                  for (final d in (ref.watch(coupleDaysProvider).valueOrNull ??
                      const <CoupleDay>[]))
                    d.dateKey: d
                }
              : const <String, CoupleDay>{};
          final partnerUid = (couple != null && myUid != null)
              ? couple.memberUids.firstWhere((u) => u != myUid, orElse: () => '')
              : '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MonthHeader(
                  month: _month,
                  onPrev: () => _shift(-1),
                  onNext: () => _shift(1)),
              const SizedBox(height: 12),
              _CalendarGrid(
                month: _month,
                byKey: byKey,
                onTapDay: (key) => _openDay(
                    context, byKey[key], key, coupleDays[key], partnerUid),
              ),
              const SizedBox(height: 28),
              const Text('이번 달 감정 분포',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              _EmotionDistribution(entries: monthEntries),
            ],
          );
        },
      ),
    );
  }

  void _openDay(BuildContext context, SoloEntry? entry, String dateKey,
      CoupleDay? coupleDay, String partnerUid) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DayDetailSheet(
        dateKey: dateKey,
        entry: entry,
        coupleDay: coupleDay,
        partnerUid: partnerUid,
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader(
      {required this.month, required this.onPrev, required this.onNext});

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
        Text(DateFormat('yyyy년 M월').format(month),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid(
      {required this.month, required this.byKey, required this.onTapDay});

  final DateTime month;
  final Map<String, SoloEntry> byKey;
  final void Function(String dateKey) onTapDay;

  @override
  Widget build(BuildContext context) {
    final y = month.year;
    final m = month.month;
    final days = DateUtils.getDaysInMonth(y, m);
    final offset = DateTime(y, m, 1).weekday % 7; // 일요일=0
    final total = offset + days;

    return Column(
      children: [
        Row(
          children: const ['일', '월', '화', '수', '목', '금', '토']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              color: AppColors.subtle, fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: total,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 0.8),
          itemBuilder: (context, i) {
            if (i < offset) return const SizedBox.shrink();
            final day = i - offset + 1;
            final key = dateKeyOf(DateTime(y, m, day));
            return _DayCell(
                day: day, entry: byKey[key], onTap: () => onTapDay(key));
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell(
      {required this.day, required this.entry, required this.onTap});

  final int day;
  final SoloEntry? entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final emotion = e?.emotion;
    final hasAny =
        e != null && (e.hasAnswer || e.hasEmotion || e.hasPraise);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$day',
              style: TextStyle(
                  fontSize: 13,
                  color: hasAny ? AppColors.ink : AppColors.subtle,
                  fontWeight: hasAny ? FontWeight.w700 : FontWeight.w400)),
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: emotion != null
                  ? emotionColor(emotion)
                  : (hasAny ? AppColors.seed : Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionDistribution extends StatelessWidget {
  const _EmotionDistribution({required this.entries});

  final List<SoloEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <Emotion, int>{};
    for (final e in entries) {
      final em = e.emotion;
      if (em != null) counts[em] = (counts[em] ?? 0) + 1;
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('아직 기록된 감정이 없어요.',
            style: TextStyle(color: AppColors.subtle)),
      );
    }

    return Column(
      children: Emotion.values.where((e) => (counts[e] ?? 0) > 0).map((e) {
        final c = counts[e] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                  width: 64,
                  child: Text('${e.emoji} ${e.label}',
                      style: const TextStyle(fontSize: 13))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: c / total,
                    minHeight: 12,
                    backgroundColor: const Color(0x11000000),
                    valueColor: AlwaysStoppedAnimation<Color>(emotionColor(e)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$c', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({
    required this.dateKey,
    required this.entry,
    this.coupleDay,
    this.partnerUid = '',
  });

  final String dateKey;
  final SoloEntry? entry;
  final CoupleDay? coupleDay;
  final String partnerUid;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final hasContent =
        e != null && (e.hasAnswer || e.hasEmotion || e.hasPraise);
    final qid = e?.questionId;
    final q = qid != null
        ? QuestionBank.byId(qid)
        : QuestionBank.forDateKey(dateKey);

    final partnerEmotion =
        partnerUid.isNotEmpty ? coupleDay?.emotionOf(partnerUid) : null;
    final partnerAnswer =
        partnerUid.isNotEmpty ? coupleDay?.answerOf(partnerUid) : null;
    final hasPartner = partnerEmotion != null ||
        (partnerAnswer != null && partnerAnswer.isNotEmpty);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateKey,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            if (!hasContent && !hasPartner)
              const Text('이 날의 기록이 없어요.',
                  style: TextStyle(color: AppColors.subtle)),
            if (hasContent) ...[
              const Text('나',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.seed,
                      fontSize: 13)),
              const SizedBox(height: 8),
              if (e.hasEmotion)
                _row('감정', '${e.emotion!.emoji} ${e.emotion!.label}'),
              if (e.hasAnswer) _block('💭 ${q.text}', e.questionAnswer!),
              if (e.hasPraise) _block('💛 칭찬일기', e.praise!),
            ],
            if (hasPartner) ...[
              if (hasContent) const Divider(height: 28),
              const Text('💞 연인',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.seed,
                      fontSize: 13)),
              const SizedBox(height: 8),
              if (partnerEmotion != null)
                _row('감정', '${partnerEmotion.emoji} ${partnerEmotion.label}'),
              if (partnerAnswer != null && partnerAnswer.isNotEmpty)
                _block('💭 ${q.text}', partnerAnswer),
              if (partnerEmotion != null &&
                  (partnerAnswer == null || partnerAnswer.isEmpty))
                const Text('답변은 둘 다 작성하면 공개돼요',
                    style: TextStyle(color: AppColors.subtle, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Text('$k  ', style: const TextStyle(color: AppColors.subtle)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _block(String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.4)),
          ],
        ),
      );
}
