/// 전역 설정 플래그.
///
/// 기본은 **Mock 모드**(외부 백엔드 불필요)로 동작한다.
/// Firebase 연동(Phase 2)을 마치면 [useFirebase] 를 true 로 바꾸고
/// 각 *RepositoryProvider 를 Firebase 구현으로 override 한다. (README 참고)
class AppConfig {
  const AppConfig._();

  static const bool useFirebase = false;
  static const String appName = '오늘의 우리';
}
