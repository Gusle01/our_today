import 'package:our_today/core/utils/date_key.dart';

/// 질문 카테고리. 로테이션으로 다양성을 보장한다.
enum QuestionCategory { value, memory, daily, future }

extension QuestionCategoryX on QuestionCategory {
  String get label => switch (this) {
        QuestionCategory.value => '가치관',
        QuestionCategory.memory => '추억',
        QuestionCategory.daily => '일상',
        QuestionCategory.future => '미래',
      };
}

/// 큐레이션 질문 1개.
class Question {
  const Question({
    required this.id,
    required this.text,
    required this.category,
  });

  final String id;
  final String text;
  final QuestionCategory category;
}

/// MVP 시드 질문 풀 + 결정적 선택 로직.
/// (운영 시에는 Firestore `questions` 컬렉션으로 이전 — 5단계 설계 참고)
class QuestionBank {
  const QuestionBank._();

  static const List<Question> all = [
    // ── 가치관 ──
    Question(id: 'q01', text: '지금 내 삶에서 가장 포기할 수 없는 가치는 무엇인가요?', category: QuestionCategory.value),
    Question(id: 'q02', text: '내가 절대 타협하고 싶지 않은 한 가지는?', category: QuestionCategory.value),
    Question(id: 'q03', text: "'좋은 사람'이란 나에게 어떤 사람인가요?", category: QuestionCategory.value),
    Question(id: 'q04', text: '나를 가장 잘 표현하는 단어 하나는?', category: QuestionCategory.value),
    Question(id: 'q05', text: '최근에 바뀐 내 생각이나 가치관이 있나요?', category: QuestionCategory.value),
    Question(id: 'q06', text: '돈과 시간 중 지금 더 소중한 건 무엇인가요?', category: QuestionCategory.value),

    // ── 추억 ──
    Question(id: 'q07', text: '오늘 떠오른 가장 행복했던 기억은?', category: QuestionCategory.memory),
    Question(id: 'q08', text: '어릴 적 가장 좋아했던 장소는 어디였나요?', category: QuestionCategory.memory),
    Question(id: 'q09', text: '누군가에게 가장 고마웠던 순간은?', category: QuestionCategory.memory),
    Question(id: 'q10', text: '최근 가장 크게 웃었던 일은 무엇인가요?', category: QuestionCategory.memory),
    Question(id: 'q11', text: '다시 돌아가고 싶은 하루가 있다면?', category: QuestionCategory.memory),
    Question(id: 'q12', text: "처음으로 '어른이 됐다'고 느낀 순간은?", category: QuestionCategory.memory),

    // ── 일상 ──
    Question(id: 'q13', text: '오늘 가장 행복했던 순간은 언제였나요?', category: QuestionCategory.daily),
    Question(id: 'q14', text: '오늘 나를 가장 힘들게 한 건 무엇이었나요?', category: QuestionCategory.daily),
    Question(id: 'q15', text: '오늘 감사한 것 한 가지는?', category: QuestionCategory.daily),
    Question(id: 'q16', text: '오늘 하루를 색으로 표현한다면?', category: QuestionCategory.daily),
    Question(id: 'q17', text: '요즘 가장 자주 하는 생각은 무엇인가요?', category: QuestionCategory.daily),
    Question(id: 'q18', text: '오늘 나에게 해주고 싶은 칭찬은?', category: QuestionCategory.daily),

    // ── 미래 ──
    Question(id: 'q19', text: '올해가 끝나기 전에 꼭 해보고 싶은 것은?', category: QuestionCategory.future),
    Question(id: 'q20', text: '1년 뒤 나는 어떤 모습이면 좋겠나요?', category: QuestionCategory.future),
    Question(id: 'q21', text: '요즘 가장 기대되는 일은 무엇인가요?', category: QuestionCategory.future),
    Question(id: 'q22', text: '두렵지만 그래도 도전하고 싶은 것은?', category: QuestionCategory.future),
    Question(id: 'q23', text: '미래의 나에게 한마디 한다면?', category: QuestionCategory.future),
    Question(id: 'q24', text: '함께라면 꼭 가보고 싶은 곳이 있나요?', category: QuestionCategory.future),
  ];

  /// 날짜 기반 결정적 선택 — 같은 날이면 항상 같은 질문(솔로·커플 공통).
  static Question forDateKey(String dateKey) {
    final index = epochDayOf(dateKey) % all.length;
    return all[index];
  }

  static Question byId(String id) =>
      all.firstWhere((q) => q.id == id, orElse: () => all.first);
}
