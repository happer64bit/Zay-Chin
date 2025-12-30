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
  final Set<String> _processing = {};

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Invitations', style: theme.textTheme.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadInvites,
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Invitation>>(
            future: _invitesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SizedBox(
                  height: 120,
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
                  height: 120,
                  child: Center(child: Text('No pending invitations')),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _loadInvites();
                  await Future.delayed(const Duration(milliseconds: 400));
                },
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: invites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final invite = invites[index];
                    final isProcessing = _processing.contains(invite.id);
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Group invite',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                if (isProcessing)
                                  const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Group ID: ${invite.groupId}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: isProcessing
                                      ? null
                                      : () async {
                                          setState(() {
                                            _processing.add(invite.id);
                                          });
                                          try {
                                            await _groupService.rejectInvitation(invite.id);
                                            _loadInvites();
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _processing.remove(invite.id);
                                              });
                                            }
                                          }
                                        },
                                  icon: const Icon(Icons.close),
                                  label: const Text('Decline'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: isProcessing
                                      ? null
                                      : () async {
                                          setState(() {
                                            _processing.add(invite.id);
                                          });
                                          try {
                                            await _groupService.acceptInvitation(invite.id);
                                            if (mounted) {
                                              Navigator.of(context).pop();
                                              widget.onGroupJoined();
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _processing.remove(invite.id);
                                              });
                                            }
                                          }
                                        },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Accept'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
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
