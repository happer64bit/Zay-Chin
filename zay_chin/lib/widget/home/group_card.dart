import 'package:flutter/material.dart';
import 'package:zay_chin/api/models/group.dart';
import 'package:zay_chin/widget/chiclet_card.dart';
 
class GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final int? itemsCount;
  final int? boughtCount;
  final int? plannedCount;
 
  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.itemsCount,
    this.boughtCount,
    this.plannedCount,
  });
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChicletCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '${group.totalMembers} member${group.totalMembers == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  itemsCount == null ? 'Items: —' : 'Items: $itemsCount',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  boughtCount != null && plannedCount != null
                      ? 'Progress: $boughtCount/$plannedCount'
                      : 'Progress: —',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Updated: ${group.updatedAt.toLocal().toString().split(".").first}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
