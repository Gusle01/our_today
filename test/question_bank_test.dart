import 'package:flutter_test/flutter_test.dart';
import 'package:our_today/content/question_bank.dart';

void main() {
  test('forDateKey 는 같은 날짜에 항상 같은 질문을 준다', () {
    final a = QuestionBank.forDateKey('2026-06-24');
    final b = QuestionBank.forDateKey('2026-06-24');
    expect(a.id, b.id);
  });

  test('byId 는 없는 id 면 첫 질문으로 폴백한다', () {
    expect(QuestionBank.byId('___nope___').id, QuestionBank.all.first.id);
  });

  test('질문 풀은 비어있지 않다', () {
    expect(QuestionBank.all.isNotEmpty, true);
  });
}
