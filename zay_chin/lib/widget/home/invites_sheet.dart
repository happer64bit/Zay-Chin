import 'package:flutter/material.dart';
import 'package:zay_chin/api/models/group.dart';
import 'package:zay_chin/api/services/group_service.dart';

class InvitesSheet extends StatefulWidget {
  final VoidCallback onGroupJoined;

  const InvitesSheet({super.key, required this.onGroupJoined});

  @override
  State<InvitesSheet> createState() => _InvitesSheetState();
}

class _InvitesSheetState extends State<InvitesSheet> {
  final GroupService _groupService = GroupService();
  late Future<List<Invitation>> _invitesFuture;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  void _loadInvites() {
    setState(() {
      _invitesFuture = _groupService.getInvites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Invitation>>(
        future: _invitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Failed to load invites',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          }
          final invites = snapshot.data ?? [];
          if (invites.isEmpty) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('No pending invitations')),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            itemCount: invites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final invite = invites[index];
              return ListTile(
                title: const Text('Group invite'),
                subtitle: Text('Group ID: ${invite.groupId}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await _groupService.rejectInvitation(invite.id);
                        _loadInvites();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.greenAccent),
                      onPressed: () async {
                        await _groupService.acceptInvitation(invite.id);
                        if (mounted) {
                          Navigator.of(context).pop();
                          widget.onGroupJoined();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void showInvitesSheet(BuildContext context, VoidCallback onGroupJoined) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return InvitesSheet(onGroupJoined: onGroupJoined);
    },
  );
}
