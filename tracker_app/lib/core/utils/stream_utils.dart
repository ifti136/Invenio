import 'dart:async';

/// Combines the latest values from two streams.
Stream<T> combineLatest2<S1, S2, T>(
  Stream<S1> s1,
  Stream<S2> s2,
  T Function(S1, S2) combiner,
) {
  final controller = StreamController<T>();
  S1? last1;
  S2? last2;

  void checkAndEmit() {
    if (last1 != null && last2 != null) {
      controller.add(combiner(last1 as S1, last2 as S2));
    }
  }

  s1.listen(
    (v1) {
      last1 = v1;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  s2.listen(
    (v2) {
      last2 = v2;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  return controller.stream;
}

/// Combines the latest values from three streams.
Stream<T> combineLatest3<S1, S2, S3, T>(
  Stream<S1> s1,
  Stream<S2> s2,
  Stream<S3> s3,
  T Function(S1, S2, S3) combiner,
) {
  final controller = StreamController<T>();
  S1? last1;
  S2? last2;
  S3? last3;

  void checkAndEmit() {
    if (last1 != null && last2 != null && last3 != null) {
      controller.add(combiner(last1 as S1, last2 as S2, last3 as S3));
    }
  }

  s1.listen(
    (v1) {
      last1 = v1;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  s2.listen(
    (v2) {
      last2 = v2;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  s3.listen(
    (v3) {
      last3 = v3;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  return controller.stream;
}

/// Combines the latest values from four streams.
Stream<T> combineLatest4<S1, S2, S3, S4, T>(
  Stream<S1> s1,
  Stream<S2> s2,
  Stream<S3> s3,
  Stream<S4> s4,
  T Function(S1, S2, S3, S4) combiner,
) {
  final controller = StreamController<T>();
  S1? last1;
  S2? last2;
  S3? last3;
  S4? last4;

  void checkAndEmit() {
    if (last1 != null && last2 != null && last3 != null && last4 != null) {
      controller.add(combiner(last1 as S1, last2 as S2, last3 as S3, last4 as S4));
    }
  }

  s1.listen(
    (v1) {
      last1 = v1;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  s2.listen(
    (v2) {
      last2 = v2;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  s3.listen(
    (v3) {
      last3 = v3;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  s4.listen(
    (v4) {
      last4 = v4;
      checkAndEmit();
    },
    onError: controller.addError,
    onDone: () => controller.close(),
  );

  return controller.stream;
}
