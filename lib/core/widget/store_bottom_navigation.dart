import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';

enum StoreDestination { home, categories, orders, favorites, profile }

extension StoreDestinationPresentation on StoreDestination {
  String get translationKey => switch (this) {
    StoreDestination.home => 'storeNavHome',
    StoreDestination.categories => 'storeNavCategories',
    StoreDestination.orders => 'storeNavOrders',
    StoreDestination.favorites => 'storeNavFavorites',
    StoreDestination.profile => 'storeNavProfile',
  };

  String get label => translationKey.tr;

  IconData get icon => switch (this) {
    StoreDestination.home => Icons.home_outlined,
    StoreDestination.categories => Icons.grid_view_outlined,
    StoreDestination.orders => Icons.receipt_long_outlined,
    StoreDestination.favorites => Icons.favorite_border,
    StoreDestination.profile => Icons.person_outline,
  };

  IconData get selectedIcon => switch (this) {
    StoreDestination.home => Icons.home,
    StoreDestination.categories => Icons.grid_view_rounded,
    StoreDestination.orders => Icons.receipt_long,
    StoreDestination.favorites => Icons.favorite,
    StoreDestination.profile => Icons.person,
  };
}

class StoreBottomNavigation extends StatelessWidget {
  const StoreBottomNavigation({
    required this.current,
    required this.onSelected,
    this.badges = const {},
    super.key,
  });

  final StoreDestination current;
  final ValueChanged<StoreDestination> onSelected;
  final Map<StoreDestination, int> badges;

  @override
  Widget build(BuildContext context) => Material(
    color: StorePalette.surface,
    elevation: StoreElevation.low,
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: StoreCalibration.bottomNavigationHeight,
        child: Row(
          textDirection: Directionality.of(context),
          children: StoreDestination.values
              .map(
                (destination) => Expanded(
                  child: _DestinationButton(
                    destination: destination,
                    selected: current == destination,
                    badgeCount: badges[destination],
                    onTap: () => onSelected(destination),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    ),
  );
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final StoreDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected ? StorePalette.purple : StorePalette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      value: badgeCount == null || badgeCount == 0 ? null : '$badgeCount',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.xxs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badgeCount != null && badgeCount! > 0,
                label: Text('${badgeCount?.clamp(0, 99) ?? 0}'),
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: StoreIconSizes.standard,
                  color: color,
                ),
              ),
              const SizedBox(height: StoreSpacing.xxs),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StoreTypography.caption.copyWith(
                  color: color,
                  fontWeight:
                      selected
                          ? StoreTypography.semiBold
                          : StoreTypography.regular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
