import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/widgets/empty_state.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/presentation/providers/couple_providers.dart';

class CoupleHistoryScreen extends ConsumerWidget {
  const CoupleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(coupleHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('우리 기록')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              emoji: '🗂️',
              title: '아직 함께한 기록이 없어요',
              message: '오늘의 질문에 둘 다 답하면\n여기에 차곡차곡 쌓여요.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _HistoryCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final CoupleDailyAnswer item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.dateKey,
                  style: const TextStyle(
                      color: AppColors.subtle, fontSize: 12)),
              const Spacer(),
              Text('#${item.question.category.label}',
                  style: const TextStyle(
                      color: AppColors.seed,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.question.text,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, height: 1.3)),
          const SizedBox(height: 14),
          _answer('나', item.myText ?? ''),
          const SizedBox(height: 10),
          _answer('연인', item.partnerText ?? ''),
        ],
      ),
    );
  }

  Widget _answer(String name, String text) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.seed,
                  fontSize: 13)),
          const SizedBox(height: 2),
          Text(text, style: const TextStyle(height: 1.4)),
        ],
      );
}
