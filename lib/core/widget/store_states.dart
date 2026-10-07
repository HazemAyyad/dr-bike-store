import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../classes/store_view_state.dart';
import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';
import 'store_buttons.dart';

enum StoreMessageKind { empty, offline, error, success }

class StoreMessageState extends StatelessWidget {
  const StoreMessageState({
    required this.kind,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.iconColor,
    this.iconSize = 48,
    this.actionVariant = StoreButtonVariant.secondary,
    this.actionExpanded = false,
    super.key,
  });

  final StoreMessageKind kind;
  final String message;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final StoreButtonVariant actionVariant;
  final bool actionExpanded;

  @override
  Widget build(BuildContext context) {
    final (icon, color, defaultTitle) = switch (kind) {
      StoreMessageKind.empty => (
        Icons.inbox_outlined,
        StorePalette.textSecondary,
        'storeStateEmptyTitle'.tr,
      ),
      StoreMessageKind.offline => (
        Icons.wifi_off_outlined,
        StorePalette.warning,
        'storeStateOfflineTitle'.tr,
      ),
      StoreMessageKind.error => (
        Icons.error_outline,
        StorePalette.error,
        'storeStateErrorTitle'.tr,
      ),
      StoreMessageKind.success => (
        Icons.check_circle_outline,
        StorePalette.success,
        'storeStateSuccessTitle'.tr,
      ),
    };

    return Semantics(
      liveRegion: true,
      label: '${title ?? defaultTitle}. $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(StoreSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                this.icon ?? icon,
                size: iconSize,
                color: iconColor ?? color,
              ),
              const SizedBox(height: StoreSpacing.md),
              Text(
                title ?? defaultTitle,
                textAlign: TextAlign.center,
                style: StoreTypography.title,
              ),
              const SizedBox(height: StoreSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StoreTypography.body.copyWith(
                  color: StorePalette.textSecondary,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: StoreSpacing.md),
                StoreButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expand: actionExpanded,
                  variant: actionVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StoreStateView<T> extends StatelessWidget {
  const StoreStateView({
    required this.state,
    required this.contentBuilder,
    this.loading,
    this.onRetry,
    super.key,
  });

  final StoreViewState<T> state;
  final Widget Function(BuildContext context, T data) contentBuilder;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is StoreContent<T>) {
      return contentBuilder(context, current.data);
    }
    if (current is StoreLoading<T>) {
      if (current.previousData case final data?) {
        return Stack(
          children: [
            contentBuilder(context, data),
            const PositionedDirectional(
              start: StoreSpacing.md,
              end: StoreSpacing.md,
              top: StoreSpacing.xs,
              child: IgnorePointer(
                child: StoreSkeletonBox(
                  height: 4,
                  borderRadius: StoreRadii.round,
                ),
              ),
            ),
          ],
        );
      }
      return loading ?? const StoreSkeletonList();
    }
    if (current is StoreEmpty<T>) {
      return StoreMessageState(
        kind: StoreMessageKind.empty,
        title: current.title,
        message: current.message,
        actionLabel: current.actionLabel,
        onAction: onRetry,
      );
    }
    if (current is StoreOffline<T>) {
      if (current.previousData case final data?) {
        return Stack(
          children: [
            contentBuilder(context, data),
            PositionedDirectional(
              start: StoreSpacing.sm,
              end: StoreSpacing.sm,
              top: StoreSpacing.sm,
              child: Material(
                color: StorePalette.derivedWarningSurface,
                borderRadius: BorderRadius.circular(StoreRadii.md),
                child: ListTile(
                  leading: const Icon(Icons.wifi_off_outlined),
                  title: Text(current.message),
                  trailing:
                      onRetry == null
                          ? null
                          : TextButton(
                            onPressed: onRetry,
                            child: Text('storeRetry'.tr),
                          ),
                ),
              ),
            ),
          ],
        );
      }
      return StoreMessageState(
        kind: StoreMessageKind.offline,
        message: current.message,
        actionLabel: onRetry == null ? null : 'storeRetry'.tr,
        onAction: onRetry,
      );
    }
    if (current is StoreError<T>) {
      return StoreMessageState(
        kind: StoreMessageKind.error,
        message: current.message,
        actionLabel: onRetry == null ? null : 'storeRetry'.tr,
        onAction: onRetry,
      );
    }
    if (current is StoreSuccess<T>) {
      return StoreMessageState(
        kind: StoreMessageKind.success,
        message: current.message,
      );
    }
    return loading ?? const StoreSkeletonList();
  }
}

class StoreSkeletonBox extends StatefulWidget {
  const StoreSkeletonBox({
    this.width,
    this.height = 16,
    this.borderRadius = StoreRadii.sm,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<StoreSkeletonBox> createState() => _StoreSkeletonBoxState();
}

class _StoreSkeletonBoxState extends State<StoreSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'جاري التحميل',
    child: ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 0.9).animate(_controller),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: StorePalette.border,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    ),
  );
}

class StoreSkeletonList extends StatelessWidget {
  const StoreSkeletonList({this.itemCount = 5, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(StoreSpacing.md),
    itemCount: itemCount,
    separatorBuilder: (_, _) => const SizedBox(height: StoreSpacing.sm),
    itemBuilder: (_, _) => const StoreSkeletonBox(height: 88),
  );
}

class StoreRefreshWrapper extends StatelessWidget {
  const StoreRefreshWrapper({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    color: StorePalette.purple,
    child: child,
  );
}
