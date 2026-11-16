import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models.dart';

double distanceFromUser(Station s) =>
    s.distanceKm(mockUserLocation.lat, mockUserLocation.lng);

class StationCard extends StatelessWidget {
  const StationCard({super.key, required this.station, required this.onTap});

  final Station station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = station;
    final text = Theme.of(context).textTheme;
    final open = s.availableCount > 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    (open ? context.nara.success : context.nara.textSecondary)
                        .withValues(alpha: 0.15),
                foregroundColor: context.nara.textPrimary,
                child: const Icon(Icons.ev_station),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(s.name, style: text.titleMedium)),
                        Text(km(distanceFromUser(s)), style: text.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.address,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(
                          label:
                              '${s.availableCount} of ${s.connectors.length} available',
                          color: open
                              ? context.nara.success
                              : context.nara.textSecondary,
                        ),
                        Text(
                          '${rupiah(s.tariffPerKwh)}/kWh',
                          style: text.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(s.connectorTypes, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
