import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';
import 'package:our_today/features/couple/presentation/providers/couple_providers.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final connected = ref.watch(isConnectedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0x33FF8FB1),
                  child: Text('🙂', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nickname ?? '게스트',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        connected ? '💞 연인과 연결됨' : '혼자 사용 중',
                        style: const TextStyle(color: AppColors.subtle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tile(Icons.edit_outlined, '닉네임 수정',
              () => _editNickname(context, ref, user?.nickname ?? '')),
          _tile(Icons.notifications_outlined, '알림 설정',
              () => _snack(context, '알림 설정은 Phase 2에서 제공됩니다.')),
          _tile(Icons.download_outlined, '내 기록 내보내기',
              () => _snack(context, '내보내기는 Phase 2에서 제공됩니다.')),
          _tile(Icons.privacy_tip_outlined, '개인정보처리방침',
              () => _snack(context, '정책 페이지 연결 예정')),
          const SizedBox(height: 8),
          const Divider(),
          _tile(Icons.logout, '로그아웃',
              () => ref.read(authRepositoryProvider).signOut()),
          _tile(Icons.delete_outline, '계정 삭제',
              () => _confirmDelete(context, ref),
              danger: true),
          const SizedBox(height: 24),
          const Center(
            child: Text('오늘의 우리 · v0.1.0 (MVP scaffold)',
                style: TextStyle(color: AppColors.subtle, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? const Color(0xFFE85D5D) : AppColors.ink;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _editNickname(
      BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('닉네임 수정'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('저장')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await ref.read(authRepositoryProvider).updateNickname(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('계정을 삭제할까요?'),
        content: const Text('모든 기록이 삭제되며 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE85D5D)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authRepositoryProvider).deleteAccount();
    }
  }
}
