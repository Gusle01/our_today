import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/theme/app_colors.dart';
import 'package:our_today/core/utils/date_key.dart';
import 'package:our_today/core/widgets/primary_button.dart';
import 'package:our_today/features/solo/presentation/providers/solo_providers.dart';

class PraiseScreen extends ConsumerStatefulWidget {
  const PraiseScreen({super.key});

  @override
  ConsumerState<PraiseScreen> createState() => _PraiseScreenState();
}

class _PraiseScreenState extends ConsumerState<PraiseScreen> {
  late final TextEditingController _controller;
  bool _saving = false;

  static const List<String> _examples = [
    '오늘도 수고했어',
    '운동한 나 칭찬해',
    '잘 버텼어, 충분해',
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(todayEntryProvider).praise ?? '');
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
    await ref.read(soloRepositoryProvider).savePraise(todayKey(), text);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('칭찬일기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('오늘의 나에게 한마디 💛',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLength: 200,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '나를 칭찬해주세요...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _examples
                    .map((ex) => ActionChip(
                          label: Text(ex),
                          backgroundColor: Colors.white,
                          onPressed: () => _controller.text = ex,
                        ))
                    .toList(),
              ),
              const Spacer(),
              PrimaryButton(
                  label: '저장하기', loading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
