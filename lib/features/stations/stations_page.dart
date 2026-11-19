import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_scope.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models.dart';
import 'station_card.dart';
import 'station_detail_page.dart';

enum _View { map, list }

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  late Future<List<Station>> _future = _load();
  var _view = _View.map;
  Station? _selected;

  Future<List<Station>> _load() async {
    final list = await AppScope.of(context).stations.stations();
    final sorted = List.of(list)
      ..sort((a, b) => distanceFromUser(a).compareTo(distanceFromUser(b)));
    _selected = sorted.isEmpty ? null : sorted.first;
    return sorted;
  }

  void _open(Station s) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => StationDetailPage(station: s)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby stations'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<_View>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _View.map,
                  icon: Icon(Icons.map_outlined),
                  tooltip: 'Map',
                ),
                ButtonSegment(
                  value: _View.list,
                  icon: Icon(Icons.view_list_outlined),
                  tooltip: 'List',
                ),
              ],
              selected: {_view},
              onSelectionChanged: (v) => setState(() => _view = v.first),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Station>>(
        future: _future,
        builder: (context, snap) => FadeSwitcher(
          child: KeyedSubtree(
            key: ValueKey('${snap.hasData}-${snap.hasError}-$_view'),
            child: _body(snap),
          ),
        ),
      ),
    );
  }

  Widget _body(AsyncSnapshot<List<Station>> snap) {
    if (snap.hasError) {
      return Center(
        child: TextButton(
          onPressed: () => setState(() => _future = _load()),
          child: const Text("Something went wrong. Let's try again."),
        ),
      );
    }
    if (!snap.hasData) {
      return _view == _View.map ? const _MapSkeleton() : const SkeletonList();
    }
    final stations = snap.data!;
    if (stations.isEmpty) {
      return const EmptyState(
        icon: Icons.ev_station_outlined,
        message: 'No available chargers nearby.',
      );
    }
    return switch (_view) {
      _View.map => _MapView(
        stations: stations,
        selected: _selected,
        onSelect: (s) => setState(() => _selected = s),
        onOpen: _open,
      ),
      _View.list => RefreshIndicator(
        onRefresh: () async {
          final f = _load();
          setState(() => _future = f);
          await f;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            for (final (i, s) in stations.indexed)
              FadeSlideIn(
                index: i,
                child: StationCard(station: s, onTap: () => _open(s)),
              ),
          ],
        ),
      ),
    };
  }
}

class _MapSkeleton extends StatelessWidget {
  const _MapSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Stack(
        children: [
          const Positioned.fill(
            child: SkeletonBox(height: double.infinity, radius: 0),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 64,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SkeletonBox(width: 44, height: 44, radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(width: 140, height: 16),
                          SizedBox(height: 8),
                          SkeletonBox(width: 200, height: 12),
                          SizedBox(height: 8),
                          SkeletonBox(width: 110, height: 20, radius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// shortcut: tile OpenStreetMap publik (kebijakan pemakaian terbatas). Ganti provider final sebelum rilis (PRD TBD-35).
class _MapView extends StatelessWidget {
  const _MapView({
    required this.stations,
    required this.selected,
    required this.onSelect,
    required this.onOpen,
  });

  final List<Station> stations;
  final Station? selected;
  final ValueChanged<Station> onSelect;
  final ValueChanged<Station> onOpen;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final user = LatLng(mockUserLocation.lat, mockUserLocation.lng);
    final points = [user, for (final s in stations) LatLng(s.lat, s.lng)];
    // Titik tengah bounds, digeser ke selatan agar marker tidak tertutup kartu di bawah.
    final bounds = LatLngBounds.fromPoints(points);
    final center = LatLng(
      bounds.center.latitude - 0.03,
      bounds.center.longitude,
    );
    return Stack(
      children: [
        FlutterMap(
          // shortcut: zoom tetap untuk area Jakarta (data dummy). Hitung dari bounds saat data SPKLU asli dipakai.
          options: MapOptions(initialCenter: center, initialZoom: 11),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'id.nara.app',
              tileBuilder: dark ? darkModeTileBuilder : null,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: user,
                  width: 24,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.nara.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
                for (final s in stations)
                  Marker(
                    point: LatLng(s.lat, s.lng),
                    width: 48,
                    height: 48,
                    child: _StationMarker(
                      station: s,
                      selected: s.id == selected?.id,
                      onTap: () => onSelect(s),
                    ),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 64, // sisakan ruang untuk tombol atribusi peta
          child: FadeSwitcher(
            child: selected == null
                ? const SizedBox.shrink()
                : StationCard(
                    key: ValueKey(selected!.id),
                    station: selected!,
                    onTap: () => onOpen(selected!),
                  ),
          ),
        ),
      ],
    );
  }
}

class _StationMarker extends StatelessWidget {
  const _StationMarker({
    required this.station,
    required this.selected,
    required this.onTap,
  });

  final Station station;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = station.availableCount > 0
        ? context.nara.success
        : context.nara.textSecondary;
    final size = selected ? 44.0 : 34.0;
    return Semantics(
      button: true,
      label: '${station.name}, ${station.availableCount} available',
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: selected ? context.nara.primary : color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.ev_station,
              size: size * 0.55,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
