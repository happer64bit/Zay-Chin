import 'package:flutter/material.dart';
import 'package:zay_chin/widget/chiclet_card.dart';

class CartItemEditCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final int quantity;
  final String category;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onCategoryTap;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const CartItemEditCard({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.quantity,
    required this.category,
    required this.onQuantityChanged,
    required this.onCategoryTap,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChicletCard(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item name',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onCategoryTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tag,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 1
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                    ),
                    Text(
                      quantity.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => onQuantityChanged(quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: onSave,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
