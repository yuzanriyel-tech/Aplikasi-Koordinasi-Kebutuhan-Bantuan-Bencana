import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class _NavTab {
  final String label;
  final IconData icon;
  final String route;
  final bool showPendingBadge;

  const _NavTab(this.label, this.icon, this.route, {this.showPendingBadge = false});
}

class PoskoBottomNav extends StatelessWidget {
  const PoskoBottomNav({super.key, required this.currentIndex});

  /// 0 Kebutuhan, 1 Antrean, 2 Beranda, 3 Riwayat, 4 Distribusi.
  final int currentIndex;

  static const _tabs = [
    _NavTab('Kebutuhan', Icons.assignment_outlined, AppRoutes.requirements),
    _NavTab('Antrean', Icons.sync, AppRoutes.queue, showPendingBadge: true),
    _NavTab('Beranda', Icons.home_outlined, AppRoutes.home),
    _NavTab('Riwayat', Icons.schedule, AppRoutes.history),
    _NavTab('Distribusi', Icons.inventory_2_outlined, AppRoutes.distribution),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.olive, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimens.navHeight,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: _tabs[i],
                    selected: i == currentIndex,
                    onTap: () {
                      if (i == currentIndex) return;
                      Navigator.pushReplacementNamed(context, _tabs[i].route);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});
  final _NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.primary : AppColors.oliveSoft;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.panelRadius),
        child: Center(
          child: Container(
            width: AppDimens.navPill,
            height: AppDimens.navPill,
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryTint : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.panelRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(tab.icon, size: 30, color: iconColor),
                    if (tab.showPendingBadge)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: ListenableBuilder(
                          listenable: ItemRepository.instance,
                          builder: (context, _) {
                            final count = ItemRepository.instance.pendingCount;
                            if (count == 0) return const SizedBox.shrink();
                            return Container(
                              constraints: const BoxConstraints(minWidth: 16),
                              height: 16,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.surface,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(tab.label, style: AppTextStyles.navLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
