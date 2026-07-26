import '../models/company.dart';
import '../models/manager.dart';
import '../models/requester.dart';
import '../models/trip_type.dart';
import '../models/vehicle.dart';
import '../supabase/supabase_config.dart';

class MasterDataRepository {
  Future<List<Vehicle>> fetchVehicles({bool sadeceAktif = true}) async {
    var query = supabase.from('vehicles').select();
    if (sadeceAktif) query = query.eq('aktif', true);
    final rows = await query.order('plaka');
    return rows.map(Vehicle.fromJson).toList();
  }

  Future<List<TripType>> fetchTripTypes({bool sadeceAktif = true}) async {
    var query = supabase.from('trip_types').select();
    if (sadeceAktif) query = query.eq('aktif', true);
    final rows = await query.order('sira');
    return rows.map(TripType.fromJson).toList();
  }

  Future<List<Requester>> fetchRequesters({bool sadeceAktif = true}) async {
    var query = supabase.from('requesters').select();
    if (sadeceAktif) query = query.eq('aktif', true);
    final rows = await query.order('full_name');
    return rows.map(Requester.fromJson).toList();
  }

  Future<List<Manager>> fetchManagers({bool sadeceAktif = true}) async {
    var query = supabase.from('managers').select();
    if (sadeceAktif) query = query.eq('aktif', true);
    final rows = await query.order('full_name');
    return rows.map(Manager.fromJson).toList();
  }

  Future<List<Company>> fetchCompanies({bool sadeceAktif = true}) async {
    var query = supabase.from('companies').select();
    if (sadeceAktif) query = query.eq('aktif', true);
    final rows = await query.order('name');
    return rows.map(Company.fromJson).toList();
  }

  Future<void> upsertVehicle(Vehicle vehicle) =>
      supabase.from('vehicles').upsert(vehicle.toJson());

  Future<void> upsertTripType(TripType tripType) =>
      supabase.from('trip_types').upsert(tripType.toJson());

  Future<void> upsertRequester(Requester requester) =>
      supabase.from('requesters').upsert(requester.toJson());

  Future<void> upsertManager(Manager manager) =>
      supabase.from('managers').upsert(manager.toJson());

  Future<void> upsertCompany(Company company) =>
      supabase.from('companies').upsert(company.toJson());
}
