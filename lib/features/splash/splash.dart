import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart' as rive;

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
      backgroundColor: StorePalette.surface,
      body:
          _error == null
              ? _AnimatedBrand(animation: _animation)
              : SafeArea(
                child: Center(
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
    );
  }
}

class _AnimatedBrand extends StatefulWidget {
  const _AnimatedBrand({required this.animation});

  final Animation<double> animation;

  @override
  State<_AnimatedBrand> createState() => _AnimatedBrandState();
}

class _AnimatedBrandState extends State<_AnimatedBrand> {
  late final rive.FileLoader _fileLoader = rive.FileLoader.fromAsset(
    Images.doctorBikeSplashRive,
    riveFactory: rive.Factory.flutter,
  );

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'storeSplashBrand'.tr,
      image: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: widget.animation,
            builder: (context, _) {
              if (widget.animation.value >= 0.985) {
                return const _FinalSplashLogo(
                  key: ValueKey('splash-final-logo'),
                );
              }
              return rive.RiveWidgetBuilder(
                key: const ValueKey('splash-rive-animation'),
                fileLoader: _fileLoader,
                builder:
                    (context, state) => switch (state) {
                      rive.RiveLoaded() => rive.RiveWidget(
                        key: const ValueKey('splash-rive-renderer'),
                        controller: state.controller,
                        fit: rive.Fit.contain,
                        alignment: Alignment.center,
                      ),
                      rive.RiveLoading() => const SizedBox.expand(),
                      rive.RiveFailed() => const _FinalSplashLogo(),
                    },
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: StoreSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: StoreCalibration.splashProgressWidth,
                      child: AnimatedBuilder(
                        animation: widget.animation,
                        builder:
                            (_, _) => LinearProgressIndicator(
                              value: widget.animation.value.clamp(0.08, 1),
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(
                                StoreRadii.round,
                              ),
                              backgroundColor: StorePalette.lightPurple,
                              valueColor: const AlwaysStoppedAnimation(
                                StorePalette.purple,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: StoreSpacing.sm),
                    Text(
                      'storeSplashLoading'.tr,
                      style: StoreTypography.caption.copyWith(
                        color: StorePalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalSplashLogo extends StatelessWidget {
  const _FinalSplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / 1080,
          constraints.maxHeight / 1920,
        );
        return Center(
          child: SizedBox(
            width: 821 * 0.95 * scale,
            height: 859 * 0.95 * scale,
            child: SvgPicture.asset(
              Images.doctorBikeSplashLogo,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
