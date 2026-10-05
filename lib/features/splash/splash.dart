import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/check_account/account_service.dart';
import '../../core/constants/images.dart';
import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_states.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    this.resolver,
    this.onDecision,
    this.reduceMotionOverride,
    super.key,
  });

  final StartupResolver? resolver;
  final ValueChanged<StartupDecision>? onDecision;
  final bool? reduceMotionOverride;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: StoreCalibration.splashSequence,
  );
  StartupDecision? _error;
  bool _started = false;
  int _attempt = 0;
  Timer? _resolutionTimer;
  Timer? _minimumDisplayTimer;

  bool get _reduceMotion =>
      widget.reduceMotionOverride ?? MediaQuery.disableAnimationsOf(context);

  StartupResolver get _resolver {
    final supplied = widget.resolver;
    if (supplied != null) return supplied;
    if (Get.isRegistered<ApiService>()) return Get.find<ApiService>();
    return ApiService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
    }
  }

  Future<void> _begin() async {
    final attempt = ++_attempt;
    if (mounted) setState(() => _error = null);
    if (_reduceMotion) {
      _animation.value = 1;
    } else {
      unawaited(_animation.forward(from: 0));
    }

    final minimum =
        _reduceMotion
            ? const Duration(milliseconds: 180)
            : StoreCalibration.splashMinimumDisplay;
    final startedAt = DateTime.now();
    StartupDecision decision;
    try {
      decision = await _resolveWithTimeout();
    } catch (_) {
      decision = const StartupDecision(
        destination: StartupDestination.error,
        canRetry: true,
      );
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minimum) await _waitForMinimum(minimum - elapsed);
    if (!mounted || attempt != _attempt) return;

    if (decision.destination == StartupDestination.error) {
      setState(() => _error = decision);
      return;
    }
    final onDecision = widget.onDecision;
    if (onDecision != null) {
      onDecision(decision);
      return;
    }
    _navigate(decision);
  }

  Future<StartupDecision> _resolveWithTimeout() {
    final completer = Completer<StartupDecision>();
    _resolutionTimer?.cancel();
    _resolutionTimer = Timer(StoreCalibration.splashInitializationTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('startup'));
      }
    });
    _resolver.resolveStartup().then(
      (decision) {
        if (completer.isCompleted) return;
        _resolutionTimer?.cancel();
        completer.complete(decision);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (completer.isCompleted) return;
        _resolutionTimer?.cancel();
        completer.completeError(error, stackTrace);
      },
    );
    return completer.future;
  }

  Future<void> _waitForMinimum(Duration duration) {
    final completer = Completer<void>();
    _minimumDisplayTimer?.cancel();
    _minimumDisplayTimer = Timer(duration, completer.complete);
    return completer.future;
  }

  void _navigate(StartupDecision decision) {
    switch (decision.destination) {
      case StartupDestination.onboarding:
        Get.offAllNamed(RouteHelper.onBoardin);
      case StartupDestination.guestHome:
      case StartupDestination.authenticatedHome:
        Get.offAllNamed(RouteHelper.homePage);
      case StartupDestination.offline:
        Get.offAllNamed(
          RouteHelper.storeUnavailable,
          arguments: {'kind': 'offline'},
        );
      case StartupDestination.storeUnavailable:
        Get.offAllNamed(
          RouteHelper.storeUnavailable,
          arguments: {
            'kind': 'maintenance',
            'message': decision.message,
            'support': decision.supportContact,
          },
        );
      case StartupDestination.updateRequired:
      case StartupDestination.updateRecommended:
        Get.offAllNamed(
          RouteHelper.updateRequired,
          arguments: {
            'required':
                decision.destination == StartupDestination.updateRequired,
            'message': decision.message,
            'updateUri': decision.updateUri?.toString(),
          },
        );
      case StartupDestination.error:
        setState(() => _error = decision);
    }
  }

  @override
  void dispose() {
    _attempt++;
    _resolutionTimer?.cancel();
    _minimumDisplayTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StorePalette.navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.75, -0.6),
                radius: 1.35,
                colors: [StorePalette.derivedNavyGlow, StorePalette.navy],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SplashLightTrailPainter()),
            ),
          ),
          SafeArea(
            child:
                _error == null
                    ? _AnimatedBrand(animation: _animation)
                    : Center(
                      child: Container(
                        margin: const EdgeInsets.all(StoreSpacing.lg),
                        constraints: const BoxConstraints(
                          maxWidth: StoreCalibration.authContentMaxWidth,
                        ),
                        decoration: BoxDecoration(
                          color: StorePalette.surface,
                          borderRadius: BorderRadius.circular(StoreRadii.lg),
                        ),
                        child: StoreMessageState(
                          kind: StoreMessageKind.error,
                          message:
                              _error?.message ??
                              'storeSplashInitializationError'.tr,
                          actionLabel: 'storeRetry'.tr,
                          onAction: _begin,
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBrand extends StatelessWidget {
  const _AnimatedBrand({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final logoReveal = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.05, 0.72, curve: Curves.easeOutCubic),
    );
    final wordmarkReveal = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.58, 0.9, curve: Curves.easeOut),
    );

    return Semantics(
      label: 'storeSplashBrand'.tr,
      image: true,
      child: Padding(
        padding: const EdgeInsets.all(StoreSpacing.lg),
        child: Column(
          children: [
            const Spacer(flex: 3),
            AnimatedBuilder(
              animation: animation,
              builder:
                  (context, child) => Opacity(
                    opacity: logoReveal.value,
                    child: ClipRect(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: logoReveal.value.clamp(0.05, 1),
                        child: child,
                      ),
                    ),
                  ),
              child: Image.asset(
                Images.logoDark,
                width: StoreCalibration.splashLogoWidth,
                height: StoreCalibration.splashLogoHeight,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            FadeTransition(
              opacity: wordmarkReveal,
              child: Column(
                children: [
                  Text(
                    'storeBrandName'.tr,
                    textDirection: TextDirection.ltr,
                    style: StoreTypography.display.copyWith(
                      color: StorePalette.surface,
                      fontSize: StoreCalibration.splashWordmarkFontSize,
                    ),
                  ),
                  Text(
                    'storeBrandTagline'.tr,
                    textDirection: TextDirection.ltr,
                    style: StoreTypography.label.copyWith(
                      color: StorePalette.lightPurple,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4),
            SizedBox(
              width: StoreCalibration.splashProgressWidth,
              child: AnimatedBuilder(
                animation: animation,
                builder:
                    (_, _) => LinearProgressIndicator(
                      value: animation.value.clamp(0.08, 0.96),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(StoreRadii.round),
                      backgroundColor: StorePalette.surface.withValues(
                        alpha: 0.24,
                      ),
                      valueColor: const AlwaysStoppedAnimation(
                        StorePalette.purple,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: StoreSpacing.md),
            Text(
              'storeSplashLoading'.tr,
              style: StoreTypography.caption.copyWith(
                color: StorePalette.surface.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: StoreSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SplashLightTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow =
        Paint()
          ..color = StorePalette.purple.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = StoreCalibration.splashTrailGlowWidth
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            StoreCalibration.splashTrailGlowWidth,
          );
    final line =
        Paint()
          ..color = StorePalette.purple.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = StoreCalibration.splashTrailLineWidth;
    final path =
        Path()
          ..moveTo(-20, size.height * 0.74)
          ..cubicTo(
            size.width * 0.25,
            size.height * 0.68,
            size.width * 0.55,
            size.height * 0.8,
            size.width + 20,
            size.height * 0.7,
          );
    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
