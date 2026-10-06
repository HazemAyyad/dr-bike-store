import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/functions/handingData.dart';
import 'package:doctor_bike/core/widget/store_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget host(Widget child) => GetMaterialApp(home: Scaffold(body: child));

void main() {
  test('view-state types remain truthfully distinct', () {
    const StoreViewState<List<int>> loading = StoreLoading();
    const StoreViewState<List<int>> empty = StoreEmpty(message: 'empty');
    const StoreViewState<List<int>> offline = StoreOffline(message: 'offline');
    const StoreViewState<List<int>> error = StoreError(message: 'error');
    const StoreViewState<List<int>> success = StoreSuccess(message: 'success');
    expect(loading.runtimeType, isNot(empty.runtimeType));
    expect(empty.runtimeType, isNot(error.runtimeType));
    expect(offline.runtimeType, isNot(error.runtimeType));
    expect(success, isNot(isA<StoreContent<List<int>>>()));
  });

  testWidgets('offline and recoverable error show retry exactly once', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        StoreStateView<List<int>>(
          state: const StoreOffline(message: 'offline'),
          contentBuilder: (_, data) => Text('$data'),
          onRetry: () => calls++,
        ),
      ),
    );
    expect(find.text('storeRetry'), findsOneWidget);
    await tester.tap(find.text('storeRetry'));
    expect(calls, 1);
    await tester.pumpWidget(
      host(
        StoreStateView<List<int>>(
          state: const StoreError(message: 'error'),
          contentBuilder: (_, data) => Text('$data'),
          onRetry: () {},
        ),
      ),
    );
    expect(find.text('storeRetry'), findsOneWidget);
  });

  testWidgets('previous content is retained while loading or offline', (
    tester,
  ) async {
    Widget view(StoreViewState<List<int>> state) => StoreStateView<List<int>>(
      state: state,
      contentBuilder: (_, data) => Text('content ${data.first}'),
    );
    await tester.pumpWidget(
      host(view(const StoreLoading(previousData: <int>[7]))),
    );
    expect(find.text('content 7'), findsOneWidget);
    await tester.pumpWidget(
      host(
        view(const StoreOffline(message: 'offline', previousData: <int>[8])),
      ),
    );
    expect(find.text('content 8'), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);
  });

  testWidgets('empty error and skeleton expose semantic text', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const StoreMessageState(
          kind: StoreMessageKind.empty,
          message: 'لا توجد نتائج',
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('لا توجد نتائج')), findsOneWidget);
    await tester.pumpWidget(
      host(
        const StoreMessageState(
          kind: StoreMessageKind.error,
          message: 'تعذر التحميل',
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('تعذر التحميل')), findsOneWidget);
    await tester.pumpWidget(host(const StoreSkeletonBox()));
    expect(find.bySemanticsLabel('جاري التحميل'), findsOneWidget);
    semantics.dispose();
  });

  test('generic response classification never converts failure to empty', () {
    expect(
      StoreResponseClassifier.classify(const StatusRequestValue()),
      StoreResponseKind.malformed,
    );
    expect(
      StoreResponseClassifier.classify(
        const Response(statusCode: 500, body: <String, dynamic>{}),
      ),
      StoreResponseKind.failure,
    );
    expect(
      StoreResponseClassifier.classify(
        const Response(statusCode: 401, body: <String, dynamic>{}),
      ),
      StoreResponseKind.unauthorized,
    );
    expect(
      StoreResponseClassifier.classify(const Response(statusCode: 1)),
      StoreResponseKind.offline,
    );
    expect(
      StoreResponseClassifier.classify(
        const Response(statusCode: 200, body: 'bad'),
        parser: (body) => body is Map,
      ),
      StoreResponseKind.malformed,
    );
    expect(
      StoreResponseClassifier.classify(
        const Response(
          statusCode: 200,
          body: <String, dynamic>{'items': <int>[]},
        ),
        parser: (body) => body is Map,
      ),
      StoreResponseKind.success,
    );
  });

  testWidgets('retry can replace offline with content', (tester) async {
    StoreViewState<List<int>> state = const StoreOffline<List<int>>(
      message: 'offline',
    );
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, setter) {
            set = setter;
            return StoreStateView<List<int>>(
              state: state,
              contentBuilder: (_, data) => const Text('recovered'),
              onRetry: () => set(() => state = const StoreContent(<int>[1])),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('storeRetry'));
    await tester.pump();
    expect(find.text('recovered'), findsOneWidget);
  });
}

class StatusRequestValue {
  const StatusRequestValue();
}
