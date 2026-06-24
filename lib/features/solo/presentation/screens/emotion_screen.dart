import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/core/widgets/primary_button.dart';
import 'package:our_today/features/solo/domain/entities/emotion.dart';
import 'package:our_today/features/solo/presentation/providers/solo_providers.dart';

class EmotionScreen extends ConsumerStatefulWidget {
  const EmotionScreen({super.key});

  @override
  ConsumerState<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends ConsumerState<EmotionScreen> {
  Emotion? _selected;
  late final TextEditingController _memo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = ref.read(todayEntryProvider);
    _selected = e.emotion;
    _memo = TextEditingController(text: e.emotionMemo ?? '');
  }

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sel = _selected;
    if (sel == null) return;
    setState(() => _saving = true);
    final memo = _memo.text.trim();
    await ref
        .read(soloRepositoryProvider)
        .saveEmotion(todayKey(), sel, memo: memo.isEmpty ? null : memo);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 감정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('지금 마음에 가장 가까운 건?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Emotion.values.map((e) {
                  final selected = _selected == e;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? emotionColor(e) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? emotionColor(e)
                              : const Color(0x22000000),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(e.emoji, style: const TextStyle(fontSize: 30)),
                          const SizedBox(height: 6),
                          Text(e.label,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      selected ? Colors.white : AppColors.ink)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _memo,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: '한 줄 메모 (선택)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: '저장하기',
                loading: _saving,
                onPressed: _selected == null ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
