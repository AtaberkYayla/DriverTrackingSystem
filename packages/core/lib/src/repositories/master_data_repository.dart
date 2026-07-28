import '../api/api_client.dart';
import '../models/company.dart';
import '../models/requester.dart';
import '../models/trip_type.dart';
import '../models/vehicle.dart';

class MasterDataRepository {
  Future<List<Vehicle>> fetchVehicles({bool sadeceAktif = true}) async {
    final rows = await api.get('/master_data_vehicles.php', query: {
      'sadece_aktif': sadeceAktif ? '1' : '0',
    }) as List;
    return rows.cast<Map<String, dynamic>>().map(Vehicle.fromJson).toList();
  }

  Future<List<TripType>> fetchTripTypes({bool sadeceAktif = true}) async {
    final rows = await api.get('/master_data_trip_types.php', query: {
      'sadece_aktif': sadeceAktif ? '1' : '0',
    }) as List;
    return rows.cast<Map<String, dynamic>>().map(TripType.fromJson).toList();
  }

  Future<List<Requester>> fetchRequesters({bool sadeceAktif = true}) async {
    final rows = await api.get('/master_data_requesters.php', query: {
      'sadece_aktif': sadeceAktif ? '1' : '0',
    }) as List;
    return rows.cast<Map<String, dynamic>>().map(Requester.fromJson).toList();
  }

  Future<List<Company>> fetchCompanies({bool sadeceAktif = true}) async {
    final rows = await api.get('/master_data_companies.php', query: {
      'sadece_aktif': sadeceAktif ? '1' : '0',
    }) as List;
    return rows.cast<Map<String, dynamic>>().map(Company.fromJson).toList();
  }

  Future<void> upsertVehicle(Vehicle vehicle) =>
      api.post('/master_data_vehicles.php', body: vehicle.toJson());

  Future<void> upsertTripType(TripType tripType) =>
      api.post('/master_data_trip_types.php', body: tripType.toJson());

  Future<void> upsertRequester(Requester requester) =>
      api.post('/master_data_requesters.php', body: requester.toJson());

  Future<void> upsertCompany(Company company) =>
      api.post('/master_data_companies.php', body: company.toJson());

  // Silme islemleri sadece yonetici/admin'e acik (backend/master_data_*.php
  // requireRole kontrolu). Baska bir seferde kullanilan bir kayit silinmeye
  // calisilirsa sunucu 'fk_in_use' kodlu bir ApiException firlatir; cagiran
  // taraf bunu yakalayip kullaniciya "pasife alin" mesaji gostermelidir.
  Future<void> deleteVehicle(String id) =>
      api.delete('/master_data_vehicles.php', query: {'id': id});

  Future<void> deleteTripType(String id) =>
      api.delete('/master_data_trip_types.php', query: {'id': id});

  Future<void> deleteRequester(String id) =>
      api.delete('/master_data_requesters.php', query: {'id': id});

  Future<void> deleteCompany(String id) =>
      api.delete('/master_data_companies.php', query: {'id': id});
}
