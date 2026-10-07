import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';
import 'store_buttons.dart';
import 'store_fields.dart';

class StoreTopBar extends StatefulWidget {
  const StoreTopBar({
    required this.displayName,
    this.greeting,
    this.avatar,
    this.notificationCount,
    this.cartCount,
    this.onNotifications,
    this.onCart,
    this.onSearch,
    this.onSearchChanged,
    this.searchHint,
    this.initialSearchExpanded = false,
    this.searchExpanded,
    this.onSearchExpandedChanged,
    this.searchController,
    this.loading = false,
    super.key,
  });

  final String displayName;
  final String? greeting;
  final Widget? avatar;
  final int? notificationCount;
  final int? cartCount;
  final VoidCallback? onNotifications;
  final VoidCallback? onCart;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  final bool initialSearchExpanded;
  final bool? searchExpanded;
  final ValueChanged<bool>? onSearchExpandedChanged;
  final TextEditingController? searchController;
  final bool loading;

  @override
  State<StoreTopBar> createState() => _StoreTopBarState();
}

class _StoreTopBarState extends State<StoreTopBar> {
  late bool _searchExpanded = widget.initialSearchExpanded;
  late final TextEditingController _searchController =
      widget.searchController ?? TextEditingController();
  final _searchFocusNode = FocusNode();

  bool get _effectiveSearchExpanded => widget.searchExpanded ?? _searchExpanded;

  @override
  void dispose() {
    if (widget.searchController == null) _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    final expanded = !_effectiveSearchExpanded;
    if (widget.searchExpanded == null) {
      setState(() => _searchExpanded = expanded);
    }
    widget.onSearchExpandedChanged?.call(expanded);
    if (expanded) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _searchFocusNode.requestFocus(),
      );
    } else {
      _searchFocusNode.unfocus();
      _searchController.clear();
      widget.onSearchChanged?.call('');
    }
  }

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          StoreSpacing.md,
          StoreSpacing.xs,
          StoreSpacing.md,
          StoreSpacing.sm,
        ),
        child: Column(
          children: [
            SizedBox(
              height:
                  StoreCalibration.topBarHeight -
                  StoreSpacing.md +
                  (MediaQuery.textScalerOf(context).scale(1) > 1 ? 4 : 0),
              child: Row(
                children: [
                  if (widget.loading)
                    const _TopBarSkeletonBox(
                      width: 44,
                      height: 44,
                      borderRadius: StoreRadii.round,
                    )
                  else
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: StorePalette.lightPurple,
                      child:
                          widget.avatar ??
                          const Icon(
                            Icons.person_outline,
                            color: StorePalette.purple,
                          ),
                    ),
                  const SizedBox(width: StoreSpacing.sm),
                  Expanded(
                    child:
                        widget.loading
                            ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TopBarSkeletonBox(width: 44, height: 9),
                                SizedBox(height: StoreSpacing.xxs),
                                _TopBarSkeletonBox(width: 86, height: 16),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.greeting ?? 'storeGreeting'.tr,
                                  style: StoreTypography.caption,
                                ),
                                Text(
                                  widget.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: StoreTypography.title,
                                ),
                              ],
                            ),
                  ),
                  StoreIconButton(
                    icon: Icons.search,
                    semanticLabel:
                        _effectiveSearchExpanded
                            ? 'storeCloseSearch'.tr
                            : 'storeOpenSearch'.tr,
                    onPressed: _toggleSearch,
                    tonal: true,
                  ),
                  StoreIconButton(
                    icon: Icons.shopping_cart_outlined,
                    semanticLabel: 'storeCart'.tr,
                    badgeCount: widget.cartCount,
                    badgeColor: StorePalette.purple,
                    onPressed: widget.onCart,
                  ),
                  StoreIconButton(
                    icon: Icons.notifications_none,
                    semanticLabel: 'storeNotifications'.tr,
                    badgeCount: widget.notificationCount,
                    onPressed: widget.onNotifications,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: StoreMotion.standard,
              alignment: Alignment.topCenter,
              child:
                  _effectiveSearchExpanded
                      ? Padding(
                        key: const ValueKey('store-search-expanded'),
                        padding: const EdgeInsets.only(top: StoreSpacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: StoreTextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                hint: widget.searchHint ?? 'storeSearchHint'.tr,
                                semanticLabel: 'storeSearchField'.tr,
                                prefixIcon: Icons.search,
                                textInputAction: TextInputAction.search,
                                onChanged: widget.onSearchChanged,
                                onSubmitted: widget.onSearch,
                              ),
                            ),
                            const SizedBox(width: StoreSpacing.xs),
                            SizedBox(
                              height: StoreCalibration.controlHeight,
                              child: TextButton(
                                onPressed: _toggleSearch,
                                child: Text('cancel'.tr),
                              ),
                            ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TopBarSkeletonBox extends StatelessWidget {
  const _TopBarSkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = StoreRadii.sm,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: StorePalette.border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
  );
}
