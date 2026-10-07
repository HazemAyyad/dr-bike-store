import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/images.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({this.onSkip, this.onStart, super.key});

  final Future<void> Function()? onSkip;
  final Future<void> Function()? onStart;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _didPrecacheAssets = false;

  List<_OnboardingItem> get _items => [
    _OnboardingItem(
      image: Images.onBoarding1,
      title: 'storeOnboardingAllTitle'.tr,
      description: 'storeOnboardingAllBody'.tr,
    ),
    _OnboardingItem(
      image: Images.onBoarding2,
      title: 'storeOnboardingQualityTitle'.tr,
      description: 'storeOnboardingQualityBody'.tr,
    ),
    _OnboardingItem(
      image: Images.onBoarding3,
      title: 'storeOnboardingServiceTitle'.tr,
      description: 'storeOnboardingServiceBody'.tr,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheAssets) return;
    _didPrecacheAssets = true;
    for (final item in _items) {
      precacheImage(AssetImage(item.image), context);
    }
  }

  Future<void> _complete({required bool startAuthentication}) async {
    await AppUsageService.saveIsFirst(true);
    final callback = startAuthentication ? widget.onStart : widget.onSkip;
    if (callback != null) {
      await callback();
      return;
    }
    Get.offAllNamed(RouteHelper.signIn);
  }

  void _next() {
    if (_currentPage == _items.length - 1) {
      _complete(startAuthentication: true);
      return;
    }
    _pageController.nextPage(
      duration: StoreMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: StoreMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: StorePalette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                StoreSpacing.md,
                StoreSpacing.xs,
                StoreSpacing.md,
                0,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: StoreButton(
                  label: 'storeSkip'.tr,
                  onPressed: () => _complete(startAuthentication: false),
                  variant: StoreButtonVariant.text,
                  expand: false,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder:
                    (_, index) => _OnboardingPage(
                      key: ValueKey(items[index].image),
                      item: items[index],
                      index: index,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                StoreSpacing.md,
                StoreSpacing.xs,
                StoreSpacing.md,
                StoreSpacing.md,
              ),
              child: Column(
                children: [
                  Semantics(
                    label: 'storeOnboardingProgress'.trParams({
                      'current': '${_currentPage + 1}',
                      'total': '${items.length}',
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        items.length,
                        (index) => AnimatedContainer(
                          duration: StoreMotion.fast,
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(
                            horizontal: StoreSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                index == _currentPage
                                    ? StorePalette.purple
                                    : StorePalette.border,
                            borderRadius: BorderRadius.circular(
                              StoreRadii.round,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: StoreButton(
                          label: 'storePrevious'.tr,
                          onPressed: _currentPage == 0 ? null : _previous,
                          variant: StoreButtonVariant.secondary,
                          height: 56,
                        ),
                      ),
                      const SizedBox(width: StoreSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: _OnboardingPrimaryButton(
                          label:
                              _currentPage == items.length - 1
                                  ? 'storeStartNow'.tr
                                  : 'storeNext'.tr,
                          onPressed: _next,
                          icon:
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back
                                  : Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.item, required this.index, super.key});

  final _OnboardingItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 610;
        final mediaFraction =
            compact
                ? .48
                : switch (index) {
                  0 => .58,
                  2 => .62,
                  _ => .55,
                };
        final mediaHeight = (constraints.maxHeight * mediaFraction).clamp(
          230.0,
          StoreCalibration.onboardingMediaMaxHeight,
        );
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            StoreSpacing.lg,
            0,
            StoreSpacing.lg,
            StoreSpacing.xs,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (index == 0) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Images.logo,
                          width: 72,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'storeBrandName'.tr,
                          textDirection: TextDirection.ltr,
                          style: StoreTypography.title.copyWith(
                            color: StorePalette.navy,
                            fontSize: 14,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? StoreSpacing.xs : StoreSpacing.md),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    index == 2 ? StoreRadii.pill : StoreRadii.lg,
                  ),
                  child: SizedBox(
                    height: mediaHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item.image,
                          key: ValueKey(item.image),
                          fit: index == 1 ? BoxFit.contain : BoxFit.cover,
                          alignment:
                              index == 2
                                  ? Alignment.topCenter
                                  : Alignment.center,
                          filterQuality: FilterQuality.high,
                        ),
                        if (index == 0) ...[
                          PositionedDirectional(
                            top: 46,
                            end: 10,
                            child: _OnboardingCallout(
                              width: 86,
                              child: Text(
                                'storeOnboardingElectricBikes'.tr,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            top: 150,
                            start: 10,
                            child: _OnboardingCallout(
                              width: 92,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    color: StorePalette.purple,
                                    size: 26,
                                  ),
                                  Text(
                                    'storeOnboardingBetterRide'.tr,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: compact ? StoreSpacing.md : StoreSpacing.lg),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: StoreTypography.headline.copyWith(
                    color: StorePalette.navy,
                    fontSize: compact ? 22 : 27,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: compact ? StoreSpacing.xxs : StoreSpacing.xs),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: StoreTypography.body.copyWith(
                    color: StorePalette.textSecondary,
                    fontSize: compact ? 13 : 16,
                  ),
                ),
                const SizedBox(height: StoreSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingCallout extends StatelessWidget {
  const _OnboardingCallout({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: StoreSpacing.xs,
        vertical: StoreSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(StoreRadii.lg),
        border: Border.all(color: Colors.white),
        boxShadow: const [StoreElevation.lowShadow],
      ),
      child: DefaultTextStyle(
        style: StoreTypography.caption.copyWith(
          color: StorePalette.navy,
          fontWeight: StoreTypography.semiBold,
          height: 1.45,
        ),
        child: child,
      ),
    );
  }
}

class _OnboardingPrimaryButton extends StatelessWidget {
  const _OnboardingPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6257C8), Color(0xFF7468D7)],
          ),
          borderRadius: BorderRadius.circular(StoreRadii.lg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x246B65BD),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StoreRadii.lg),
            ),
            textStyle: StoreTypography.title.copyWith(
              color: Colors.white,
              fontWeight: StoreTypography.semiBold,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (icon != null) ...[
                const SizedBox(width: StoreSpacing.sm),
                Icon(icon, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}
