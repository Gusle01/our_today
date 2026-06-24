import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:our_today/content/question_bank.dart';
import 'package:our_today/core/config/app_config.dart';
import 'package:our_today/core/error/failure.dart';
import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/core/widgets/primary_button.dart';
import 'package:our_today/features/couple/domain/entities/couple.dart';
import 'package:our_today/features/couple/domain/entities/couple_daily_answer.dart';
import 'package:our_today/features/couple/presentation/providers/couple_providers.dart';

/// '우리' 탭. 미연결이면 연결 화면, 연결되면 블라인드 리빌 홈.
class CoupleTabScreen extends ConsumerWidget {
  const CoupleTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(coupleProvider);
    return coupleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('오류: $e'))),
      data: (couple) =>
          couple == null ? const _ConnectView() : _CoupleHomeView(couple: couple),
    );
  }
}

// ─────────────────────────── 연결 화면 ───────────────────────────
class _ConnectView extends ConsumerStatefulWidget {
  const _ConnectView();

  @override
  ConsumerState<_ConnectView> createState() => _ConnectViewState();
}

class _ConnectViewState extends ConsumerState<_ConnectView> {
  final TextEditingController _codeController = TextEditingController();
  String? _myCode;
  bool _connecting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createCode() async {
    final code = await ref.read(coupleRepositoryProvider).createInviteCode();
    if (mounted) setState(() => _myCode = code);
  }

  Future<void> _connect() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _connecting = true);
    try {
      await ref.read(coupleRepositoryProvider).connectWithCode(code);
      // 연결되면 coupleProvider 가 갱신되어 자동으로 홈 화면으로 전환된다.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is Failure ? e.message : '연결에 실패했어요')),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('우리')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('💌', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('연인과 연결하기',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('초대코드로 둘을 연결하면\n매일 같은 질문을 함께 나눠요.',
                style: TextStyle(color: AppColors.subtle, height: 1.4)),
            const SizedBox(height: 28),
            _Card(
              title: '내 초대코드 만들기',
              child: _myCode == null
                  ? OutlinedButton(
                      onPressed: _createCode, child: const Text('코드 생성'))
                  : Column(
                      children: [
                        SelectableText(
                          _myCode!,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _myCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('코드를 복사했어요')));
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('복사'),
                        ),
                        const Text('상대에게 코드를 공유하세요.',
                            style: TextStyle(
                                color: AppColors.subtle, fontSize: 12)),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _Card(
              title: '받은 코드 입력',
              child: Column(
                children: [
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: '예: ABC123',
                      filled: true,
                      fillColor: const Color(0x11000000),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                      label: '연결하기',
                      loading: _connecting,
                      onPressed: _connect),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '💡 데모: 코드 생성 없이도, 아무 코드나 입력하고 연결하면 가상의 연인과 연결됩니다.',
              style: TextStyle(
                  color: AppColors.subtle, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────── 커플 홈(리빌) ───────────────────────────
class _CoupleHomeView extends ConsumerStatefulWidget {
  const _CoupleHomeView({required this.couple});

  final Couple couple;

  @override
  ConsumerState<_CoupleHomeView> createState() => _CoupleHomeViewState();
}

class _CoupleHomeViewState extends ConsumerState<_CoupleHomeView> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    await ref.read(coupleRepositoryProvider).submitAnswer(todayKey(), text);
    if (mounted) setState(() => _submitting = false);
  }

  Future<void> _simulatePartner() =>
      ref.read(coupleRepositoryProvider).simulatePartnerAnswer(todayKey());

  Future<void> _disconnect() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('연결을 해제할까요?'),
        content: const Text('해제하면 "우리 기록"에 더 이상 접근할 수 없어요.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('해제')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(coupleRepositoryProvider).disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final answerAsync = ref.watch(todayCoupleAnswerProvider);
    final partnerName = widget.couple.partnerNicknameOf('me');

    return Scaffold(
      appBar: AppBar(
        title: const Text('우리'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'history') context.push('/couple/history');
              if (v == 'disconnect') _disconnect();
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(value: 'history', child: Text('우리 기록')),
              PopupMenuItem<String>(
                  value: 'disconnect', child: Text('연결 해제')),
            ],
          ),
        ],
      ),
      body: answerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (answer) => _RevealBody(
          answer: answer,
          partnerName: partnerName,
          streak: widget.couple.streakCount,
          controller: _controller,
          submitting: _submitting,
          onSubmit: _submit,
          onSimulatePartner: _simulatePartner,
        ),
      ),
    );
  }
}

/// 블라인드 리빌 상태머신 UI.
class _RevealBody extends StatelessWidget {
  const _RevealBody({
    required this.answer,
    required this.partnerName,
    required this.streak,
    required this.controller,
    required this.submitting,
    required this.onSubmit,
    required this.onSimulatePartner,
  });

  final CoupleDailyAnswer answer;
  final String partnerName;
  final int streak;
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onSimulatePartner;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StreakChip(streak: streak),
        const SizedBox(height: 16),
        _QuestionHeader(answer.question),
        const SizedBox(height: 20),
        ..._byState(),
      ],
    );
  }

  List<Widget> _byState() => switch (answer.state) {
        RevealState.none => [
            _inputSection(hint: '오늘의 답을 적어보세요'),
            const SizedBox(height: 12),
            _partnerStatus('$partnerName 님은 아직 작성 전이에요'),
            _simulateButton(),
          ],
        RevealState.meOnly => [
            _answerCard('나', answer.myText ?? ''),
            const SizedBox(height: 16),
            _lockedPartner(),
            _simulateButton(),
          ],
        RevealState.partnerOnly => [
            _nudge('$partnerName 님이 먼저 답했어요.\n당신만 답하면 서로 공개돼요! 🔓'),
            const SizedBox(height: 12),
            _inputSection(hint: '당신의 답을 적어보세요'),
          ],
        RevealState.revealed => [
            const Text('🎉 오늘도 함께 완료!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _answerCard('나', answer.myText ?? ''),
            const SizedBox(height: 12),
            _answerCard(partnerName, answer.partnerText ?? '',
                color: const Color(0x22FF8FB1)),
          ],
      };

  Widget _inputSection({required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
            label: '제출하기', loading: submitting, onPressed: onSubmit),
      ],
    );
  }

  Widget _partnerStatus(String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text, style: const TextStyle(color: AppColors.subtle)),
      );

  Widget _simulateButton() {
    // Firebase 모드에선 상대 답변을 대신 쓸 수 없음(보안규칙) → 버튼 숨김
    if (AppConfig.useFirebase) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: onSimulatePartner,
        icon: const Icon(Icons.science_outlined, size: 18),
        label: Text('$partnerName 답변 시뮬레이트 (데모)'),
      ),
    );
  }

  Widget _answerCard(String name, String text, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.seed)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(height: 1.5, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _lockedPartner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0x11000000),
          borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$partnerName 님의 답변은\n둘 다 작성하면 공개돼요',
                style: const TextStyle(color: AppColors.subtle, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _nudge(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0x22FF8FB1),
          borderRadius: BorderRadius.circular(18)),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(streak > 0 ? '연속 $streak일 함께' : '오늘 첫 기록을 함께 시작해요',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader(this.question);

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0x22FF8FB1),
              borderRadius: BorderRadius.circular(20)),
          child: Text('#${question.category.label}',
              style: const TextStyle(
                  color: AppColors.seed,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
        const SizedBox(height: 12),
        Text(question.text,
            style: const TextStyle(
                fontSize: 21, fontWeight: FontWeight.w800, height: 1.4)),
      ],
    );
  }
}
