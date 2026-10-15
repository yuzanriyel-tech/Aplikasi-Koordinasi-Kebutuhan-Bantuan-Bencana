import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class PoskoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PoskoAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
  });

  final String title;
  final bool showBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppDimens.appBarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: AppDimens.appBarHeight,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Kembali',
              icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      titleSpacing: showBack ? 0 : 20,
      title: Text(title, style: AppTextStyles.pageTitle),
      actions: [
        ...?actions,
        const SizedBox(width: 16),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }
}
