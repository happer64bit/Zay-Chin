import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:zay_chin/api/models/cart.dart';
import 'package:zay_chin/api/models/group.dart';
import 'package:zay_chin/api/services/cart_service.dart';
import 'package:zay_chin/api/services/group_service.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final GroupService _groupService = GroupService();
  final CartService _cartService = CartService();
  bool _loading = true;
  String? _error;
  List<_ItemMarker> _markers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await _groupService.getGroups();
      final entries = await Future.wait(groups.map((g) async {
        final items = await _cartService.getCart(g.id);
        final locItems = items.where((i) => i.locationLat != null && i.locationLng != null);
        return locItems.map((i) => _ItemMarker(
              group: g,
              item: i,
              point: LatLng(i.locationLat!, i.locationLng!),
            ));
      }));
      _markers = entries.expand((e) => e).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    
    LatLng center = LatLng(16.78008816315467, 96.14273492619283);
 
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: _markers.isEmpty ? 10 : (_markers.length == 1 ? 13 : 11),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.zay_chin',
            ),
            if (_markers.isNotEmpty)
              MarkerLayer(
                markers: _markers
                    .map(
                      (m) => Marker(
                        point: m.point,
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            _showItem(context, m);
                          },
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
        if (_markers.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'No item locations yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: _load,
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  void _showItem(BuildContext context, _ItemMarker m) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.item.itemName,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                m.item.locationName ?? 'Unknown place',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      context.push('/cart/${m.group.id}');
                    },
                    child: const Text('Open Cart'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemMarker {
  final Group group;
  final CartItem item;
  final LatLng point;
  _ItemMarker({required this.group, required this.item, required this.point});
}

