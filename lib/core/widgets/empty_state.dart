import 'package:flutter/material.dart';
import 'package:our_today/core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.message,
  });

  final String emoji;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.subtle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
