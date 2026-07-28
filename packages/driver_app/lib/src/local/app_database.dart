import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Sunucudan (Supabase) senkronize edilen, offline kullanim icin cihazda
/// tutulan sefer OTURUMLARININ outbox'i. `clientTripId` sunucudaki
/// `client_trip_id` ile birebir eslesir; boylece baglanti kesildiginde
/// yapilan tekrar denemeler mukerrer kayit olusturmaz.
/// Fabrika Cikis opsiyoneldir; sefer sadece Fabrika Giris ile kapanir.
class TripsCache extends Table {
  TextColumn get clientTripId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get driverId => text()();
  TextColumn get vehicleId => text()();
  TextColumn get tarih => text()();

  DateTimeColumn get fabrikaCikisAt => dateTime().nullable()();
  DateTimeColumn get fabrikaGirisAt => dateTime().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get updatedLocallyAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientTripId};
}

/// Bir sefer (TripsCache) icindeki tek bir firma ziyaretinin outbox'i.
/// `clientStopId` sunucudaki `client_stop_id` ile eslesir.
class TripStopsCache extends Table {
  TextColumn get clientStopId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get clientTripId => text()();
  IntColumn get sira => integer()();

  DateTimeColumn get firmaGirisAt => dateTime()();
  TextColumn get tripTypeId => text().nullable()();
  TextColumn get requesterId => text().nullable()();
  TextColumn get cikisNedeni => text().nullable()();
  TextColumn get gidilenIl => text().nullable()();
  TextColumn get gidilenIlce => text().nullable()();
  TextColumn get gidilenSirketId => text().nullable()();
  TextColumn get gidilenSirketFree => text().nullable()();
  TextColumn get irsaliyeNoGiris => text().nullable()();
  TextColumn get irsaliyeNoCikis => text().nullable()();
  DateTimeColumn get firmaCikisAt => dateTime().nullable()();
  TextColumn get notlar => text().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get updatedLocallyAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientStopId};
}

class VehiclesCache extends Table {
  TextColumn get id => text()();
  TextColumn get plaka => text()();
  TextColumn get aciklama => text().nullable()();
  BoolColumn get aktif => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class TripTypesCache extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get label => text()();
  BoolColumn get requiresIrsaliye => boolean().withDefault(const Constant(false))();
  IntColumn get sira => integer().withDefault(const Constant(0))();
  BoolColumn get aktif => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class RequestersCache extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  BoolColumn get aktif => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class CompaniesCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sehir => text().nullable()();

  /// Virgulle ayrilmis trip_type id listesi (bos string = hic kategorisi yok).
  TextColumn get tripTypeIds => text().withDefault(const Constant(''))();
  BoolColumn get aktif => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  TripsCache,
  TripStopsCache,
  VehiclesCache,
  TripTypesCache,
  RequestersCache,
  CompaniesCache,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: 'sofor_takip_db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // Gelistirme asamasinda semadaki degisiklikler icin yerel
          // onbellek basitce sifirdan olusturulur (sunucu tek dogru kaynak).
          await m.database.customStatement('PRAGMA foreign_keys = OFF');
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        },
      );
}
