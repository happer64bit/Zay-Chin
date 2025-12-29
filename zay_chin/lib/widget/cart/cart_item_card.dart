import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zay_chin/api/models/cart.dart';
import 'package:zay_chin/widget/chiclet_card.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bought = item.current;
    final planned = item.quantity;
    final progress = planned == 0
        ? 0.0
        : (bought / planned).clamp(0, 1).toDouble();

    return ChicletCard(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(item.category, style: theme.textTheme.bodySmall),
                ),
                const SizedBox(width: 8),
                Text('\$${item.price}', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  '$bought of $planned bought',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Bought', style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: bought > 0 ? onDecrement : null,
                ),
                Text(bought.toString(), style: theme.textTheme.bodyMedium),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: bought < planned ? onIncrement : null,
                ),
                const Spacer(),
                CupertinoButton(
                  onPressed: onDelete,
                  child: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
