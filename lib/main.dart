import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:our_today/app.dart';
import 'package:our_today/core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화. flutterfire configure 가 네이티브 설정
  // (GoogleService-Info.plist / google-services.json)을 추가하면
  // 옵션 없이 initializeApp() 으로 동작한다. (웹은 Phase 2b 에서 옵션 추가)
  if (AppConfig.useFirebase) {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: OurTodayApp()));
}
