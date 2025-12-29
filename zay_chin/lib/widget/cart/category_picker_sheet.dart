import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showCategoryPickerSheet({
  required BuildContext context,
  required String currentCategory,
  required List<String> categories,
  required ValueChanged<String> onCategorySelected,
}) async {
  final theme = Theme.of(context);
  int selectedIndex = categories.indexOf(currentCategory);
  if (selectedIndex < 0) selectedIndex = 0;

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) {
      return SizedBox(
        height: 260,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category', style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                itemExtent: 36,
                onSelectedItemChanged: (index) {
                  onCategorySelected(categories[index]);
                },
                children: categories
                    .map(
                      (c) => Center(
                        child: Text(c, style: theme.textTheme.bodyLarge),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
