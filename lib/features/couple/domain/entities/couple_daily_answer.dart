import 'package:our_today/content/question_bank.dart';

/// 블라인드 리빌 상태.
enum RevealState { none, meOnly, partnerOnly, revealed }

/// 커플의 오늘 공유 질문 + 양측 답변(공개 규칙 포함).
class CoupleDailyAnswer {
  const CoupleDailyAnswer({
    required this.dateKey,
    required this.question,
    this.myText,
    this.partnerAnswered = false,
    this.partnerText,
  });

  final String dateKey;
  final Question question;
  final String? myText;

  /// 상대가 답을 제출했는지 여부(넛지/잠금 UI용). 내용은 노출하지 않는다.
  final bool partnerAnswered;

  /// 공개(REVEALED) 이후에만 채워진다. 그 전엔 항상 null — 블라인드 무결성.
  final String? partnerText;

  bool get iAnswered => (myText ?? '').trim().isNotEmpty;
  bool get revealed => iAnswered && partnerAnswered;

  RevealState get state {
    if (revealed) return RevealState.revealed;
    if (iAnswered && !partnerAnswered) return RevealState.meOnly;
    if (!iAnswered && partnerAnswered) return RevealState.partnerOnly;
    return RevealState.none;
  }
}
