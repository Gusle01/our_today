import 'package:flutter/material.dart';
import 'package:our_today/features/solo/domain/entities/emotion.dart';

class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFFFF8FB1); // 살구빛 핑크
  static const Color bg = Color(0xFFFDF7F4); // 따뜻한 오프화이트
  static const Color ink = Color(0xFF2D2A32); // 본문 텍스트
  static const Color subtle = Color(0xFF8E8A95); // 보조 텍스트
}

/// 감정 → 색 매핑(프레젠테이션 전용). 도메인 enum 은 색을 모른다.
Color emotionColor(Emotion e) => switch (e) {
      Emotion.happy => const Color(0xFFFFC93C),
      Emotion.flutter => const Color(0xFFFF8FB1),
      Emotion.down => const Color(0xFF6C8EBF),
      Emotion.tired => const Color(0xFFB0A8B9),
      Emotion.grateful => const Color(0xFF7DCFB6),
      Emotion.angry => const Color(0xFFE85D5D),
    };
