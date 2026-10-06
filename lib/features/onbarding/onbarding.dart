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

  List<_OnboardingItem> get _items => [
    _OnboardingItem(
      image: Images.onBoarding3,
      title: 'storeOnboardingAllTitle'.tr,
      description: 'storeOnboardingAllBody'.tr,
    ),
    _OnboardingItem(
      image: Images.onBoarding2,
      title: 'storeOnboardingQualityTitle'.tr,
      description: 'storeOnboardingQualityBody'.tr,
    ),
    _OnboardingItem(
      image: Images.onBoarding1,
      title: 'storeOnboardingServiceTitle'.tr,
      description: 'storeOnboardingServiceBody'.tr,
    ),
  ];

  Future<void> _complete({required bool startAuthentication}) async {
    await AppUsageService.saveIsFirst(true);
    final callback = startAuthentication ? widget.onStart : widget.onSkip;
    if (callback != null) {
      await callback();
      return;
    }
    Get.offAllNamed(
      startAuthentication ? RouteHelper.signIn : RouteHelper.homePage,
    );
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
                itemBuilder: (_, index) => _OnboardingPage(item: items[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(StoreSpacing.md),
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
                  const SizedBox(height: StoreSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StoreButton(
                          label: 'storePrevious'.tr,
                          onPressed: _currentPage == 0 ? null : _previous,
                          variant: StoreButtonVariant.text,
                        ),
                      ),
                      const SizedBox(width: StoreSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: StoreButton(
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
  const _OnboardingPage({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaHeight = (constraints.maxHeight *
                StoreCalibration.onboardingMediaFraction)
            .clamp(
              StoreCalibration.onboardingMediaMinHeight,
              StoreCalibration.onboardingMediaMaxHeight,
            );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: mediaHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: StorePalette.lightPurple,
                    borderRadius: BorderRadius.circular(StoreRadii.pill),
                  ),
                  padding: const EdgeInsets.all(StoreSpacing.md),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: StoreSpacing.lg),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: StoreTypography.headline,
                ),
                const SizedBox(height: StoreSpacing.xs),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: StoreTypography.body.copyWith(
                    color: StorePalette.textSecondary,
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
