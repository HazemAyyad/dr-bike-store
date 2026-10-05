import 'package:doctor_bike/core/classes/store_view_state.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/core/theme/store_tokens.dart';
import 'package:doctor_bike/core/theme/store_typography.dart';
import 'package:doctor_bike/core/widget/store_bottom_navigation.dart';
import 'package:doctor_bike/core/widget/store_buttons.dart';
import 'package:doctor_bike/core/widget/store_cards.dart';
import 'package:doctor_bike/core/widget/store_chips.dart';
import 'package:doctor_bike/core/widget/store_fields.dart';
import 'package:doctor_bike/core/widget/store_media.dart';
import 'package:doctor_bike/core/widget/store_states.dart';
import 'package:doctor_bike/core/widget/store_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader(StoreTypography.fontFamily)
      ..addFont(rootBundle.load('assets/font/Cairo-Variable.ttf'));
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await loader.load();
    await materialIcons.load();
  });

  test('approved tokens and Cairo roles remain stable', () {
    expect(StorePalette.purple, const Color(0xFF6B65BD));
    expect(StoreSpacing.md, 16);
    expect(StoreRadii.lg, 16);
    expect(StoreCalibration.controlHeight, 48);
    expect(StoreTypography.fontFamily, 'Cairo');
    expect(StoreTypography.light, FontWeight.w300);
    expect(StoreTypography.regular, FontWeight.w400);
    expect(StoreTypography.medium, FontWeight.w500);
    expect(StoreTypography.semiBold, FontWeight.w600);
    expect(StoreTypography.bold, FontWeight.w700);
  });

  test('empty, offline, error, and success remain distinct types', () {
    const StoreViewState<List<int>> empty = StoreEmpty(message: 'empty');
    const StoreViewState<List<int>> offline = StoreOffline(message: 'offline');
    const StoreViewState<List<int>> error = StoreError(message: 'error');
    const StoreViewState<List<int>> success = StoreSuccess(message: 'success');

    expect(empty, isA<StoreEmpty<List<int>>>());
    expect(offline, isA<StoreOffline<List<int>>>());
    expect(error, isA<StoreError<List<int>>>());
    expect(success, isA<StoreSuccess<List<int>>>());
  });

  testWidgets('five destinations are RTL-safe, semantic, and selectable', (
    tester,
  ) async {
    var selected = StoreDestination.home;
    await tester.pumpWidget(
      _TestApp(
        child: StatefulBuilder(
          builder:
              (context, setState) => Scaffold(
                bottomNavigationBar: StoreBottomNavigation(
                  current: selected,
                  onSelected: (value) => setState(() => selected = value),
                ),
              ),
        ),
      ),
    );

    expect(StoreDestination.values, hasLength(5));
    expect(find.bySemanticsLabel('الرئيسية'), findsOneWidget);
    expect(find.bySemanticsLabel('الأقسام'), findsOneWidget);
    expect(find.bySemanticsLabel('طلباتي'), findsOneWidget);
    expect(find.bySemanticsLabel('المفضلة'), findsOneWidget);
    expect(find.bySemanticsLabel('حسابي'), findsOneWidget);

    final home = tester.getCenter(find.bySemanticsLabel('الرئيسية'));
    final profile = tester.getCenter(find.bySemanticsLabel('حسابي'));
    expect(home.dx, greaterThan(profile.dx));

    await tester.tap(find.bySemanticsLabel('المفضلة'));
    await tester.pump();
    expect(selected, StoreDestination.favorites);
  });

  testWidgets('controls preserve semantics at 1.3 text scale', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        textScale: 1.3,
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(StoreSpacing.md),
            child: Column(
              children: [
                StoreButton(label: 'متابعة الطلب', onPressed: _noop),
                SizedBox(height: StoreSpacing.md),
                StoreTextField(
                  label: 'كلمة المرور',
                  semanticLabel: 'كلمة المرور',
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('متابعة الطلب'), findsOneWidget);
    expect(find.bySemanticsLabel('كلمة المرور'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('top bar expands inline search without requiring badge data', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: Scaffold(
          body: StoreTopBar(
            displayName: 'اسم مستخدم طويل للتحقق من الاقتطاع الآمن',
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('فتح البحث'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('فتح البحث'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('حقل البحث'), findsWidgets);
    expect(find.bySemanticsLabel('إغلاق البحث'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('foundation renders at the reference viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _FoundationShowcase());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(_FoundationShowcase),
      matchesGoldenFile('goldens/p02-shared-components-ar-390x844.png'),
    );
  });

  testWidgets('cards render at the reference viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _CardsShowcase());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(_CardsShowcase),
      matchesGoldenFile('goldens/p02-shared-cards-ar-390x844.png'),
    );
  });
}

void _noop() {}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: light(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    ),
  );
}

class _FoundationShowcase extends StatelessWidget {
  const _FoundationShowcase();

  @override
  Widget build(BuildContext context) => _TestApp(
    child: Scaffold(
      body: Column(
        children: [
          const StoreTopBar(
            displayName: 'أحمد محمد',
            notificationCount: 2,
            cartCount: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(StoreSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('أساس متجر دكتور بايك', style: StoreTypography.headline),
                  const SizedBox(height: StoreSpacing.sm),
                  const StoreTextField(
                    label: 'البحث',
                    hint: 'ابحث عن منتج أو قسم',
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  const Wrap(
                    spacing: StoreSpacing.xs,
                    runSpacing: StoreSpacing.xs,
                    children: [
                      StoreAvailabilityChip(inStock: true),
                      StoreDiscountChip(percent: 15),
                      StoreRating(value: 4.7, count: 23),
                      StoreStatusChip(
                        label: 'قيد التجهيز',
                        tone: StoreStatusTone.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  const SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: StoreMediaPlaceholder(
                            message: 'معاينة الوسائط',
                            icon: Icons.pedal_bike_outlined,
                          ),
                        ),
                        SizedBox(width: StoreSpacing.sm),
                        Expanded(
                          child: StoreMessageState(
                            kind: StoreMessageKind.success,
                            message: 'الحالة واضحة',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  const Row(
                    children: [
                      Expanded(
                        child: StoreButton(
                          label: 'إجراء أساسي',
                          onPressed: _noop,
                        ),
                      ),
                      SizedBox(width: StoreSpacing.sm),
                      Expanded(
                        child: StoreButton(
                          label: 'إجراء ثانوي',
                          onPressed: _noop,
                          variant: StoreButtonVariant.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StoreBottomNavigation(
        current: StoreDestination.home,
        onSelected: (_) {},
        badges: const {StoreDestination.orders: 1},
      ),
    ),
  );
}

class _CardsShowcase extends StatelessWidget {
  const _CardsShowcase();

  @override
  Widget build(BuildContext context) => _TestApp(
    child: Scaffold(
      body: Column(
        children: [
          const StoreTopBar(displayName: 'أحمد محمد', cartCount: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(StoreSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('بطاقات المتجر', style: StoreTypography.headline),
                  const SizedBox(height: StoreSpacing.sm),
                  SizedBox(
                    height: 340,
                    child: Row(
                      children: [
                        Expanded(
                          child: StoreProductCard(
                            name: 'خوذة دراجة هوائية آمنة وخفيفة',
                            price: 149,
                            currency: 'شيكل',
                            originalPrice: 179,
                            discountPercent: 15,
                            rating: 4.7,
                            reviewCount: 23,
                            media: const StoreMediaPlaceholder(
                              message: 'صورة المنتج',
                              icon: Icons.sports_motorsports_outlined,
                            ),
                            onTap: _noop,
                          ),
                        ),
                        const SizedBox(width: StoreSpacing.sm),
                        Expanded(
                          child: StoreProductCard(
                            name: 'قفازات قيادة مريحة',
                            price: 65,
                            currency: 'شيكل',
                            inStock: false,
                            media: const Stack(
                              fit: StackFit.expand,
                              children: [
                                StoreMediaPlaceholder(
                                  message: 'فيديو المنتج',
                                  icon: Icons.play_circle_outline,
                                ),
                                PositionedDirectional(
                                  top: StoreSpacing.xs,
                                  end: StoreSpacing.xs,
                                  child: StoreMediaBadge(
                                    type: StoreMediaType.video,
                                  ),
                                ),
                              ],
                            ),
                            onTap: _noop,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  SizedBox(
                    height: 170,
                    child: Row(
                      children: [
                        Expanded(
                          child: StoreCategoryCard(
                            title: 'إكسسوارات',
                            itemCount: 24,
                            media: const Icon(
                              Icons.pedal_bike,
                              size: 48,
                              color: StorePalette.purple,
                            ),
                            onTap: _noop,
                          ),
                        ),
                        const SizedBox(width: StoreSpacing.sm),
                        Expanded(
                          child: StoreCategoryCard(
                            title: 'معدات السلامة',
                            itemCount: 16,
                            media: const Icon(
                              Icons.health_and_safety_outlined,
                              size: 48,
                              color: StorePalette.purple,
                            ),
                            onTap: _noop,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StoreBottomNavigation(
        current: StoreDestination.categories,
        onSelected: (_) {},
      ),
    ),
  );
}
