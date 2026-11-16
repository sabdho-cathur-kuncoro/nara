import '../models.dart';

/// Format QR dummy: `NARA-<connectorId>` (format asli TBD-12).
const mockQrCodes = {
  'NARA-c1': 'Available (CCS2 60 kW)',
  'NARA-c3': 'Available (Type 2 22 kW)',
  'NARA-c2': 'In use',
  'NARA-c4': 'Faulted',
  'NARA-c6': 'Offline',
  'NARA-xx': 'Unknown',
};

/// shortcut: lokasi user tetap (Monas). Ganti dengan GPS device (geolocator) saat fitur lokasi dibuat.
const mockUserLocation = (lat: -6.1754, lng: 106.8272);

const mockStations = <Station>[
  Station(
    id: 'st1',
    name: 'NARA Sudirman',
    address: 'Jl. Jend. Sudirman No. 1, Jakarta Pusat',
    lat: -6.2146,
    lng: 106.8227,
    tariffPerKwh: 2467,
    chargers: [
      Charger(
        id: 'ch1',
        name: 'DC Fast 1',
        connectors: [
          Connector(
            id: 'c1',
            type: 'CCS2',
            powerKw: 60,
            status: ConnectorStatus.available,
          ),
          Connector(
            id: 'c2',
            type: 'CHAdeMO',
            powerKw: 50,
            status: ConnectorStatus.charging,
          ),
        ],
      ),
      Charger(
        id: 'ch2',
        name: 'AC 1',
        connectors: [
          Connector(
            id: 'c3',
            type: 'Type 2',
            powerKw: 22,
            status: ConnectorStatus.available,
          ),
        ],
      ),
    ],
  ),
  Station(
    id: 'st2',
    name: 'NARA Kemang',
    address: 'Jl. Kemang Raya No. 8, Jakarta Selatan',
    lat: -6.2607,
    lng: 106.8142,
    tariffPerKwh: 2467,
    chargers: [
      Charger(
        id: 'ch3',
        name: 'DC Fast 1',
        connectors: [
          Connector(
            id: 'c4',
            type: 'CCS2',
            powerKw: 120,
            status: ConnectorStatus.faulted,
          ),
          Connector(
            id: 'c5',
            type: 'CCS2',
            powerKw: 120,
            status: ConnectorStatus.available,
          ),
        ],
      ),
    ],
  ),
  Station(
    id: 'st3',
    name: 'NARA BSD',
    address: 'Jl. BSD Grand Boulevard, Tangerang',
    lat: -6.3016,
    lng: 106.6527,
    tariffPerKwh: 1650,
    chargers: [
      Charger(
        id: 'ch4',
        name: 'AC 1',
        connectors: [
          Connector(
            id: 'c6',
            type: 'Type 2',
            powerKw: 7.4,
            status: ConnectorStatus.offline,
          ),
        ],
      ),
    ],
  ),
];
