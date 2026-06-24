import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/content/question_bank.dart';
import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/core/widgets/primary_button.dart';
import 'package:our_today/features/solo/presentation/providers/solo_providers.dart';

/// 혼자 모드 오늘의 질문(개인 답변).
class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(todayEntryProvider).questionAnswer ?? '';
    _controller = TextEditingController(text: existing);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    final key = todayKey();
    final q = QuestionBank.forDateKey(key);
    await ref.read(soloRepositoryProvider).saveAnswer(key, q.id, text);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = QuestionBank.forDateKey(todayKey());
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 질문')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryChip(label: q.category.label),
              const SizedBox(height: 16),
              Text(q.text,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, height: 1.4)),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: '자유롭게 적어보세요...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                  label: '저장하기', loading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0x22FF8FB1),
          borderRadius: BorderRadius.circular(20)),
      child: Text('#$label',
          style: const TextStyle(
              color: AppColors.seed,
              fontWeight: FontWeight.w700,
              fontSize: 13)),
    );
  }
}
