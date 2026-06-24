import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:our_today/content/question_bank.dart';
import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/core/widgets/section_card.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/presentation/providers/couple_providers.dart';
import 'package:our_today/features/solo/presentation/providers/solo_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final entry = ref.watch(todayEntryProvider);
    final couple = ref.watch(coupleProvider).valueOrNull;
    final question = QuestionBank.forDateKey(todayKey());

    // 연결 시: 오늘의 질문은 '커플 공유 질문'이 된다(따로 기록 X).
    final coupleAnswer = couple != null
        ? ref.watch(todayCoupleAnswerProvider).valueOrNull
        : null;
    final bool questionDone =
        couple != null ? (coupleAnswer?.iAnswered ?? false) : entry.hasAnswer;
    final String questionSubtitle = couple != null
        ? switch (coupleAnswer?.state) {
            RevealState.revealed => '둘 다 작성 완료 🎉 (우리 탭에서 확인)',
            RevealState.meOnly => '내 답 완료 · 상대를 기다리는 중 🔒',
            RevealState.partnerOnly => '상대가 먼저 답했어요! 당신 차례 💝',
            _ => question.text,
          }
        : (entry.hasAnswer
            ? '작성 완료 · #${question.category.label}'
            : question.text);
    final doneCount = (questionDone ? 1 : 0) +
        (entry.hasEmotion ? 1 : 0) +
        (entry.hasPraise ? 1 : 0);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('안녕하세요, ${user?.nickname ?? '나'}님 👋',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('오늘의 우리, 2분이면 충분해요.',
                style: TextStyle(color: AppColors.subtle)),
            const SizedBox(height: 20),
            if (couple != null) ...[
              _StreakBanner(streak: couple.streakCount),
              const SizedBox(height: 16),
            ],
            _ProgressBar(done: doneCount, total: 3),
            const SizedBox(height: 16),
            SectionCard(
              emoji: '📝',
              title: couple != null ? '오늘의 질문 · 우리' : '오늘의 질문',
              subtitle: questionSubtitle,
              done: questionDone,
              onTap: () => couple != null
                  ? context.go('/couple')
                  : context.push('/question'),
            ),
            const SizedBox(height: 12),
            SectionCard(
              emoji: '😊',
              title: '오늘의 감정',
              subtitle: entry.hasEmotion
                  ? '${entry.emotion!.emoji} ${entry.emotion!.label} 기록함'
                  : '지금 마음은 어떤가요?',
              done: entry.hasEmotion,
              onTap: () => context.push('/emotion'),
            ),
            const SizedBox(height: 12),
            SectionCard(
              emoji: '💛',
              title: '칭찬일기',
              subtitle: entry.hasPraise ? '작성 완료' : '오늘의 나에게 한마디',
              done: entry.hasPraise,
              onTap: () => context.push('/praise'),
            ),
            const SizedBox(height: 24),
            if (couple == null) _ConnectInvite(onTap: () => context.go('/couple')),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('오늘 $total개 중 $done개 완료',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: const Color(0x22FF8FB1),
          ),
        ),
      ],
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD3A5), Color(0xFFFF8FB1)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              streak > 0
                  ? '연인과 연속 $streak일 함께했어요!'
                  : '오늘 둘 다 답하면 streak 가 시작돼요',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectInvite extends StatelessWidget {
  const _ConnectInvite({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x22FF8FB1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Text('💌', style: TextStyle(fontSize: 26)),
              SizedBox(width: 14),
              Expanded(
                child: Text('연인과 연결하고\n매일의 질문을 함께 나눠보세요',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, height: 1.4)),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
