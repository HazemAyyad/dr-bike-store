import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/widget/store_skeletons.dart';
import 'package:doctor_bike/core/widget/store_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 390, height: 844, child: child)),
);

void main() {
  testWidgets('default StoreStateView loading uses skeletons', (tester) async {
    await tester.pumpWidget(
      _host(
        StoreStateView<List<int>>(
          state: const StoreLoading(),
          contentBuilder: (_, values) => Text('$values'),
        ),
      ),
    );

    expect(find.byType(StoreSkeletonBox), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('catalog skeleton follows grid and list layouts', (tester) async {
    await tester.pumpWidget(
      _host(const StoreProductCollectionSkeleton(isGrid: true)),
    );
    expect(
      find.byKey(const ValueKey('store-product-collection-skeleton')),
      findsOneWidget,
    );
    expect(find.byType(GridView), findsNothing);
    expect(find.byType(StoreSkeletonBox), findsWidgets);

    await tester.pumpWidget(
      _host(const StoreProductCollectionSkeleton(isGrid: false)),
    );
    expect(find.byType(StoreSkeletonBox), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('detail, related products and reviews have shaped skeletons', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const StoreProductDetailsSkeleton()));
    expect(
      find.byKey(const ValueKey('store-product-details-skeleton')),
      findsOneWidget,
    );

    await tester.pumpWidget(_host(const StoreHorizontalProductsSkeleton()));
    expect(
      find.byKey(const ValueKey('store-horizontal-products-skeleton')),
      findsOneWidget,
    );

    await tester.pumpWidget(_host(const StoreReviewsSkeleton()));
    expect(
      find.byKey(const ValueKey('store-reviews-skeleton')),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('inline data loading is semantic and spinner free', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const Center(
          child: StoreInlineFieldSkeleton(label: 'تحميل مناطق التوصيل'),
        ),
      ),
    );

    expect(find.bySemanticsLabel('تحميل مناطق التوصيل'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    semantics.dispose();
  });
}
