import 'package:flutter/material.dart';
import 'package:zay_chin/api/services/group_service.dart';

Future<void> showCreateGroupDialog(BuildContext context, VoidCallback onGroupCreated) async {
  final controller = TextEditingController();
  final theme = Theme.of(context);
  final groupService = GroupService();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Family grocery trip',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                await groupService.createGroup(name);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onGroupCreated();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group created')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString(),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}
