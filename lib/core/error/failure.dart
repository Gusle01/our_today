/// 도메인 계층에서 사용하는 단순 실패 타입.
class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => 'Failure($message)';
}
