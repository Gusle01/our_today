import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Phase 2 (Firebase) ──────────────────────────────────
  // if (AppConfig.useFirebase) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // }
  // ────────────────────────────────────────────────────────

  runApp(const ProviderScope(child: OurTodayApp()));
}
