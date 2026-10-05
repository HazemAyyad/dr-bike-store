sealed class StoreViewState<T> {
  const StoreViewState();
}

final class StoreInitial<T> extends StoreViewState<T> {
  const StoreInitial();
}

final class StoreLoading<T> extends StoreViewState<T> {
  const StoreLoading({this.previousData});

  final T? previousData;
}

final class StoreContent<T> extends StoreViewState<T> {
  const StoreContent(this.data);

  final T data;
}

final class StoreEmpty<T> extends StoreViewState<T> {
  const StoreEmpty({required this.message, this.title, this.actionLabel});

  final String? title;
  final String message;
  final String? actionLabel;
}

final class StoreOffline<T> extends StoreViewState<T> {
  const StoreOffline({required this.message, this.previousData});

  final String message;
  final T? previousData;
}

final class StoreError<T> extends StoreViewState<T> {
  const StoreError({required this.message, this.previousData, this.code});

  final String message;
  final T? previousData;
  final String? code;
}

final class StoreSuccess<T> extends StoreViewState<T> {
  const StoreSuccess({required this.message, this.data});

  final String message;
  final T? data;
}
