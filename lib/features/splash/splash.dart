import 'dart:async';
import 'dart:ui' show Tangent;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/check_account/account_service.dart';
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
      backgroundColor: StorePalette.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
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
      curve: const Interval(0.72, 0.94, curve: Curves.easeOut),
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
              builder: (context, _) {
                final progress = logoReveal.value;
                return SizedBox(
                  width: StoreCalibration.splashLogoWidth,
                  height: StoreCalibration.splashLogoHeight,
                  child: CustomPaint(
                    painter: _SplashLogoPainter(progress: progress),
                  ),
                );
              },
            ),
            FadeTransition(
              opacity: wordmarkReveal,
              child: Column(
                children: [
                  Text(
                    'storeBrandName'.tr,
                    textDirection: TextDirection.ltr,
                    style: StoreTypography.display.copyWith(
                      color: StorePalette.navy,
                      fontSize: StoreCalibration.splashWordmarkFontSize,
                    ),
                  ),
                  Text(
                    'storeBrandTagline'.tr,
                    textDirection: TextDirection.ltr,
                    style: StoreTypography.label.copyWith(
                      color: StorePalette.textSecondary,
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
                      backgroundColor: StorePalette.lightPurple,
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
                color: StorePalette.textSecondary,
              ),
            ),
            const SizedBox(height: StoreSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  const _SplashLogoPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = Size(size.width / 191, size.height / 130);
    canvas.save();
    canvas.scale(scale.width, scale.height);

    final paint =
        Paint()
          ..color = StorePalette.navy
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 8;

    final paths = <Path>[
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(31, 101), radius: 24)),
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(158, 101), radius: 24)),
      Path()
        ..moveTo(31, 101)
        ..lineTo(91, 94)
        ..lineTo(67, 111)
        ..lineTo(158, 101),
      Path()
        ..moveTo(91, 94)
        ..lineTo(119, 48)
        ..lineTo(151, 62),
      Path()
        ..moveTo(119, 48)
        ..lineTo(106, 18)
        ..lineTo(97, 42),
    ];

    final segment = 1 / paths.length;
    Tangent? drawingHead;
    for (var index = 0; index < paths.length; index++) {
      final localProgress = ((progress - (segment * index)) / segment).clamp(
        0.0,
        1.0,
      );
      if (localProgress == 0) continue;
      for (final metric in paths[index].computeMetrics()) {
        final distance = metric.length * localProgress;
        canvas.drawPath(metric.extractPath(0, distance), paint);
        if (localProgress < 1) {
          drawingHead = metric.getTangentForOffset(distance);
        }
      }
    }
    if (drawingHead != null && progress < 0.995) {
      _paintMagicHead(canvas, drawingHead, progress);
    }
    canvas.restore();
  }

  void _paintMagicHead(Canvas canvas, Tangent head, double animationValue) {
    final pulse = 0.75 + (0.25 * ((animationValue * 40) % 1));
    final glow =
        Paint()
          ..color = StorePalette.purple.withValues(alpha: 0.24 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(head.position, 12 * pulse, glow);

    canvas.save();
    canvas.translate(head.position.dx, head.position.dy);
    canvas.rotate(head.angle);
    final bolt =
        Path()
          ..moveTo(-11, -3)
          ..lineTo(-3, -1)
          ..lineTo(-6, 5)
          ..lineTo(12, -4)
          ..lineTo(3, -3)
          ..lineTo(6, -9)
          ..close();
    canvas.drawPath(bolt, Paint()..color = StorePalette.purple);

    final sparkPaint =
        Paint()
          ..color = StorePalette.purple.withValues(alpha: 0.72)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2;
    canvas.drawLine(const Offset(2, -14), const Offset(2, -19), sparkPaint);
    canvas.drawLine(const Offset(13, -9), const Offset(17, -13), sparkPaint);
    canvas.drawLine(const Offset(14, 3), const Offset(20, 4), sparkPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashLogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
