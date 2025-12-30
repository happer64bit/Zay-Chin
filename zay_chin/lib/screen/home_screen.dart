import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zay_chin/api/models/group.dart';
import 'package:zay_chin/api/services/group_service.dart';
import 'package:zay_chin/api/services/cart_service.dart';
import 'package:zay_chin/widget/home/create_group_dialog.dart';
import 'package:zay_chin/widget/home/group_card.dart';
import 'package:zay_chin/widget/home/invites_sheet.dart';
import 'package:zay_chin/widget/home/map_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GroupService _groupService = GroupService();
  final CartService _cartService = CartService();
  late Future<List<Group>> _groupsFuture;
  Map<String, _GroupCartStats> _stats = {};

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupService.getGroups();
    _groupsFuture.then((groups) {
      _loadCounts(groups);
    });
  }

  Future<void> _refresh() async {
    final future = _groupService.getGroups();
    setState(() {
      _groupsFuture = future;
    });
    await Future.wait([
      future,
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    final groups = await future;
    await _loadCounts(groups);
  }

  Future<void> _loadCounts(List<Group> groups) async {
    final entries = await Future.wait(groups.map((g) async {
      try {
        final items = await _cartService.getCart(g.id);
        final int itemCount = items.length;
        final int bought = items.fold(0, (sum, i) => sum + i.current);
        final int planned = items.fold(0, (sum, i) => sum + i.quantity);
        return MapEntry(g.id, _GroupCartStats(itemCount, bought, planned));
      } catch (_) {
        return MapEntry(g.id, _GroupCartStats(0, 0, 0));
      }
    }));
    if (mounted) {
      setState(() {
        _stats = Map.fromEntries(entries);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'Groups'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateGroupDialog(context, _refresh),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        children: [
          Padding(
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
                        itemsCount: _stats[group.id]?.items,
                        boughtCount: _stats[group.id]?.bought,
                        plannedCount: _stats[group.id]?.planned,
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
          const MapTab(),
        ],
      ),
    ));
  }
}

class _GroupCartStats {
  final int items;
  final int bought;
  final int planned;
  _GroupCartStats(this.items, this.bought, this.planned);
}
