import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zay_chin/api/models/group.dart';
import 'package:zay_chin/api/services/group_service.dart';
import 'package:zay_chin/widget/home/create_group_dialog.dart';
import 'package:zay_chin/widget/home/group_card.dart';
import 'package:zay_chin/widget/home/invites_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GroupService _groupService = GroupService();
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupService.getGroups();
  }

  Future<void> _refresh() async {
    setState(() {
      _groupsFuture = _groupService.getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () => showInvitesSheet(context, _refresh),
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateGroupDialog(context, _refresh),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Group>>(
            future: _groupsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load groups',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }
              final groups = snapshot.data ?? [];
              if (groups.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Text('No groups yet. Tap + to create one.'),
                    ),
                  ],
                );
              }

              return ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, _) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return GroupCard(
                    group: group,
                    onTap: () {
                      context.push('/cart/${group.id}');
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
