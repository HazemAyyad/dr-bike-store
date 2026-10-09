import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum StoreFeedbackTone { success, error }

class StoreFeedbackNotice {
  StoreFeedbackNotice._();

  static const Duration successDuration = Duration(milliseconds: 2400);
  static const Duration errorDuration = Duration(milliseconds: 3800);
  static const Duration actionDuration = Duration(milliseconds: 4200);

  static OverlayEntry? _activeEntry;

  static void show({
    BuildContext? context,
    required String title,
    required String message,
    required StoreFeedbackTone tone,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final overlay =
        context == null
            ? Get.key.currentState?.overlay
            : Overlay.maybeOf(context, rootOverlay: true);
    final resolvedOverlay = overlay ?? Get.key.currentState?.overlay;
    if (resolvedOverlay == null) return;

    dismissActive();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (_) => _StoreFeedbackOverlay(
            title: title,
            message: message,
            tone: tone,
            duration:
                duration ??
                (onAction == null
                    ? tone == StoreFeedbackTone.error
                        ? errorDuration
                        : successDuration
                    : actionDuration),
            actionLabel: actionLabel,
            onAction: onAction,
            onDismiss: () {
              if (!identical(_activeEntry, entry)) return;
              _activeEntry = null;
              entry.remove();
            },
          ),
    );
    _activeEntry = entry;
    resolvedOverlay.insert(entry);
  }

  @visibleForTesting
  static void dismissActive() {
    final entry = _activeEntry;
    _activeEntry = null;
    entry?.remove();
  }
}

class _StoreFeedbackOverlay extends StatefulWidget {
  const _StoreFeedbackOverlay({
    required this.title,
    required this.message,
    required this.tone,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final StoreFeedbackTone tone;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  State<_StoreFeedbackOverlay> createState() => _StoreFeedbackOverlayState();
}

class _StoreFeedbackOverlayState extends State<_StoreFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  static const _enterDuration = Duration(milliseconds: 160);
  static const _exitDuration = Duration(milliseconds: 110);

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  late final Animation<double> _scale;
  Timer? _dismissTimer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _enterDuration,
      reverseDuration: _exitDuration,
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.14),
      end: Offset.zero,
    ).animate(curve);
    _scale = Tween<double>(begin: .98, end: 1).animate(curve);
    _controller.forward();

    final exitDelay = math.max(
      0,
      widget.duration.inMilliseconds - _exitDuration.inMilliseconds,
    );
    _dismissTimer = Timer(Duration(milliseconds: exitDelay), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted || _closing) return;
    _closing = true;
    _dismissTimer?.cancel();
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismiss();
  }

  void _activateAction() {
    if (_closing) return;
    widget.onAction?.call();
    unawaited(_dismiss());
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = math.max(media.padding.top + 72, media.size.height * .17);
    final isError = widget.tone == StoreFeedbackTone.error;
    final accent = isError ? const Color(0xFFB42332) : const Color(0xFF178653);
    final pale = isError ? const Color(0xFFFFF1F2) : const Color(0xFFEDF9F2);
    final border = isError ? const Color(0xFFF1DADC) : const Color(0xFFDDEBE3);

    return Positioned.fill(
      key: const Key('store-feedback-overlay'),
      child: Stack(
        children: [
          IgnorePointer(
            child: FadeTransition(
              opacity: _opacity,
              child: ColoredBox(color: Colors.black.withValues(alpha: .14)),
            ),
          ),
          Positioned(
            top: top,
            left: 16,
            right: 16,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: FadeTransition(
                    opacity: _opacity,
                    child: SlideTransition(
                      position: _offset,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Material(
                          key: const Key('store-feedback-card'),
                          color: Colors.transparent,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFEFD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .14),
                                  blurRadius: 26,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    13,
                                    11,
                                    13,
                                    10,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: pale,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isError
                                              ? Icons.close_rounded
                                              : Icons.check_rounded,
                                          color: accent,
                                          size: 23,
                                        ),
                                      ),
                                      const SizedBox(width: 11),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: accent,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (widget.message
                                                .trim()
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 3),
                                              Text(
                                                widget.message,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF626C7C),
                                                  fontSize: 12,
                                                  height: 1.4,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (widget.onAction != null &&
                                          widget.actionLabel
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true) ...[
                                        const SizedBox(width: 8),
                                        TextButton(
                                          key: const Key(
                                            'store-feedback-action',
                                          ),
                                          onPressed: _activateAction,
                                          style: TextButton.styleFrom(
                                            foregroundColor: accent,
                                            backgroundColor: pale,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 9,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            widget.actionLabel!,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 1, end: 0),
                                  duration: widget.duration,
                                  builder:
                                      (_, value, __) => Align(
                                        alignment: Alignment.centerRight,
                                        child: FractionallySizedBox(
                                          widthFactor: value,
                                          child: Container(
                                            height: 2,
                                            color:
                                                isError
                                                    ? const Color(0xFFE04455)
                                                    : const Color(0xFF34C759),
                                          ),
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
