import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/core/router/app_router.dart';
import 'package:our_today/core/theme/app_theme.dart';

class OurTodayApp extends ConsumerWidget {
  const OurTodayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '오늘의 우리',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
