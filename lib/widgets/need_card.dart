import 'package:flutter/material.dart';

import '../models/item.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/format.dart';
import 'status_widgets.dart';

/// Kartu satu kebutuhan bantuan (gaya prototype Requirement List).
/// [showMeta] menambahkan koordinat GPS dan waktu input (halaman Antrean).
class NeedCard extends StatelessWidget {
  const NeedCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showMeta = false,
  });

  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(item.subtitle, style: AppTextStyles.cardQuantity),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        UrgencyChip(item.urgency),
                        SyncBadge(item.syncStatus, pill: showMeta),
                      ],
                    ),
                    if (showMeta) ...[
                      const SizedBox(height: 8),
                      Text(
                        'GPS ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDateTime(item.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Ubah',
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF79807D)),
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
