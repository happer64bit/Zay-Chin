import 'package:flutter/material.dart';
import 'package:zay_chin/widget/chiclet_card.dart';

class NewCartItemRow extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final int quantity;
  final String category;
  final String? locationLabel;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onCategoryTap;
  final VoidCallback onLocationTap;
  final Future<void> Function() onSubmit;

  const NewCartItemRow({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.quantity,
    required this.category,
    this.locationLabel,
    required this.onQuantityChanged,
    required this.onCategoryTap,
    required this.onLocationTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChicletCard(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'New item...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '\$0',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.right,
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onCategoryTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tag, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onLocationTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.4,
                              ),
                              child: Text(
                                locationLabel ?? 'Add location',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                    SizedBox(
                      height: 36,
                      child: FilledButton(
                        onPressed: onSubmit,
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
