import 'dart:async';

/// 상위 스트림이 새 값을 낼 때마다 이전 inner 구독을 취소하고 새 inner 로 전환한다.
/// (rxdart 의존 없이 switchMap 구현 — coupleId 변화에 따라 하위 스트림 재구독용)
Stream<R> switchMap<T, R>(Stream<T> source, Stream<R> Function(T value) mapper) {
  final controller = StreamController<R>();
  StreamSubscription<T>? outer;
  StreamSubscription<R>? inner;

  controller.onListen = () {
    outer = source.listen(
      (value) {
        inner?.cancel();
        inner = mapper(value).listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onError: controller.addError,
    );
  };
  controller.onCancel = () async {
    await inner?.cancel();
    await outer?.cancel();
  };
  return controller.stream;
}
