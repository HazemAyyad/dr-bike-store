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

  @override
  State<StoreTopBar> createState() => _StoreTopBarState();
}

class _StoreTopBarState extends State<StoreTopBar> {
  late bool _searchExpanded = widget.initialSearchExpanded;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchExpanded = !_searchExpanded);
    if (_searchExpanded) {
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
              height: StoreCalibration.topBarHeight - StoreSpacing.md,
              child: Row(
                children: [
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
                    child: Column(
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
                    icon: _searchExpanded ? Icons.close : Icons.search,
                    semanticLabel:
                        _searchExpanded
                            ? 'storeCloseSearch'.tr
                            : 'storeOpenSearch'.tr,
                    onPressed: _toggleSearch,
                  ),
                  StoreIconButton(
                    icon: Icons.notifications_none,
                    semanticLabel: 'storeNotifications'.tr,
                    badgeCount: widget.notificationCount,
                    onPressed: widget.onNotifications,
                  ),
                  StoreIconButton(
                    icon: Icons.shopping_cart_outlined,
                    semanticLabel: 'storeCart'.tr,
                    badgeCount: widget.cartCount,
                    onPressed: widget.onCart,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: StoreMotion.standard,
              alignment: Alignment.topCenter,
              child:
                  _searchExpanded
                      ? Padding(
                        padding: const EdgeInsets.only(top: StoreSpacing.xs),
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
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ),
  );
}
