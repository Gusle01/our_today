import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/widgets/primary_button.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _loading = false;

  Future<void> _signIn(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      // 라우터 redirect 가 자동으로 /home 으로 이동시킨다.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(authRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text('💞', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                '오늘의 우리',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                '나를 이해하고,\n그 다음 서로를 이해해요.',
                style:
                    TextStyle(fontSize: 16, height: 1.5, color: AppColors.subtle),
              ),
              const SizedBox(height: 28),
              const _Bullet('📝', '매일 하나의 질문으로 나를 돌아봐요'),
              const _Bullet('💛', '칭찬일기와 감정기록으로 마음을 챙겨요'),
              const _Bullet('🔒', '연인과는 둘 다 답해야 서로 공개돼요'),
              const Spacer(),
              PrimaryButton(
                label: 'Google로 시작하기',
                icon: Icons.login,
                loading: _loading,
                onPressed: () =>
                    _signIn(() async => repo.signInWithGoogle()),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => _signIn(() async => repo.signInAnonymously()),
                child: const Text(
                  '게스트로 둘러보기',
                  style: TextStyle(color: AppColors.subtle),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  '시작하면 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
                  style: TextStyle(fontSize: 12, color: AppColors.subtle),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.emoji, this.text);

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 15, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
