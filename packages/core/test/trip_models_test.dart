import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trip serialization', () {
    test('omits empty id for unsynced trip payloads', () {
      const trip = Trip(
        id: '',
        clientTripId: 'client-trip-id',
        driverId: 'driver-id',
        vehicleId: 'vehicle-id',
        tarih: '2026-07-24',
      );

      final json = trip.toJson();

      expect(json['id'], isNull);
      expect(json['client_trip_id'], 'client-trip-id');
    });
  });

  group('TripStop serialization', () {
    test('omits empty id for unsynced stop payloads', () {
      final stop = TripStop(
        id: '',
        clientStopId: 'client-stop-id',
        tripId: 'trip-id',
        sira: 1,
        firmaGirisAt: DateTime.utc(2026, 7, 24, 10, 0),
      );

      final json = stop.toJson();

      expect(json['id'], isNull);
      expect(json['client_stop_id'], 'client-stop-id');
    });
  });
}
