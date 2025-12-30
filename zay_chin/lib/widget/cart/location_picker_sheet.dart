import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Future<void> showLocationPickerSheet({
  required BuildContext context,
  double? initialLat,
  double? initialLng,
  String? initialName,
  required void Function(double? lat, double? lng, String? name) onPicked,
}) async {
  final LatLng defaultCenter = const LatLng(16.78008816315467, 96.14273492619283);
  final LatLng? initialCenter = (initialLat != null && initialLng != null)
      ? LatLng(initialLat, initialLng)
      : null;

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    isDismissible: true,
    builder: (context) {
      return _LocationPickerContent(
        initialCenter: initialCenter ?? defaultCenter,
        hasInitialLocation: initialCenter != null,
        initialName: initialName,
        onPicked: onPicked,
      );
    },
  );
}

class _LocationPickerContent extends StatefulWidget {
  final LatLng initialCenter;
  final bool hasInitialLocation;
  final String? initialName;
  final void Function(double? lat, double? lng, String? name) onPicked;

  const _LocationPickerContent({
    required this.initialCenter,
    required this.hasInitialLocation,
    this.initialName,
    required this.onPicked,
  });

  @override
  State<_LocationPickerContent> createState() => _LocationPickerContentState();
}

class _LocationPickerContentState extends State<_LocationPickerContent> {
  LatLng? _selected;
  late final MapController _mapController;
  late final TextEditingController _nameController;
  bool _hasLocation = false;

  @override
  void initState() {
    super.initState();
    _hasLocation = widget.hasInitialLocation;
    _selected = widget.hasInitialLocation ? widget.initialCenter : null;
    _mapController = MapController();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick location', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Tap anywhere on the map to select a location.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selected ?? widget.initialCenter,
                  initialZoom: 13,
                  onTap: (tapPos, point) {
                    setState(() {
                      _selected = point;
                      _hasLocation = true;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  if (_selected != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selected!,
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Place name (optional)',
              hintText: 'e.g., Walmart, Target, etc.',
              prefixIcon: Icon(Icons.store),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_hasLocation || widget.hasInitialLocation)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onPicked(null, null, null);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear'),
                  ),
                ),
              if (_hasLocation || widget.hasInitialLocation)
                const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _hasLocation || widget.hasInitialLocation
                      ? () {
                          final label = _nameController.text.trim().isEmpty
                              ? null
                              : _nameController.text.trim();
                          final selected = _selected ?? widget.initialCenter;
                          widget.onPicked(
                            selected.latitude,
                            selected.longitude,
                            label,
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
