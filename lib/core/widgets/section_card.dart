import 'package:flutter/material.dart';
import 'package:our_today/core/theme/app_colors.dart';

/// 홈 "오늘 할 일" 카드 등에 쓰는 탭 가능한 카드.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.done = false,
    this.onTap,
    this.trailing,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final bool done;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.subtle),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  (done
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF7DCFB6))
                      : Icon(Icons.chevron_right, color: Colors.grey.shade400)),
            ],
          ),
        ),
      ),
    );
  }
}
