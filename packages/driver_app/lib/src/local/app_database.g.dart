// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsCacheTable extends TripsCache
    with TableInfo<$TripsCacheTable, TripsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientTripIdMeta = const VerificationMeta(
    'clientTripId',
  );
  @override
  late final GeneratedColumn<String> clientTripId = GeneratedColumn<String>(
    'client_trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tarihMeta = const VerificationMeta('tarih');
  @override
  late final GeneratedColumn<String> tarih = GeneratedColumn<String>(
    'tarih',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fabrikaCikisAtMeta = const VerificationMeta(
    'fabrikaCikisAt',
  );
  @override
  late final GeneratedColumn<DateTime> fabrikaCikisAt =
      GeneratedColumn<DateTime>(
        'fabrika_cikis_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fabrikaGirisAtMeta = const VerificationMeta(
    'fabrikaGirisAt',
  );
  @override
  late final GeneratedColumn<DateTime> fabrikaGirisAt =
      GeneratedColumn<DateTime>(
        'fabrika_giris_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedLocallyAtMeta = const VerificationMeta(
    'updatedLocallyAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedLocallyAt =
      GeneratedColumn<DateTime>(
        'updated_locally_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    clientTripId,
    serverId,
    driverId,
    vehicleId,
    tarih,
    fabrikaCikisAt,
    fabrikaGirisAt,
    synced,
    retryCount,
    lastError,
    updatedLocallyAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_trip_id')) {
      context.handle(
        _clientTripIdMeta,
        clientTripId.isAcceptableOrUnknown(
          data['client_trip_id']!,
          _clientTripIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientTripIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('tarih')) {
      context.handle(
        _tarihMeta,
        tarih.isAcceptableOrUnknown(data['tarih']!, _tarihMeta),
      );
    } else if (isInserting) {
      context.missing(_tarihMeta);
    }
    if (data.containsKey('fabrika_cikis_at')) {
      context.handle(
        _fabrikaCikisAtMeta,
        fabrikaCikisAt.isAcceptableOrUnknown(
          data['fabrika_cikis_at']!,
          _fabrikaCikisAtMeta,
        ),
      );
    }
    if (data.containsKey('fabrika_giris_at')) {
      context.handle(
        _fabrikaGirisAtMeta,
        fabrikaGirisAt.isAcceptableOrUnknown(
          data['fabrika_giris_at']!,
          _fabrikaGirisAtMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('updated_locally_at')) {
      context.handle(
        _updatedLocallyAtMeta,
        updatedLocallyAt.isAcceptableOrUnknown(
          data['updated_locally_at']!,
          _updatedLocallyAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedLocallyAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientTripId};
  @override
  TripsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripsCacheData(
      clientTripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_trip_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      tarih: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarih'],
      )!,
      fabrikaCikisAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fabrika_cikis_at'],
      ),
      fabrikaGirisAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fabrika_giris_at'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      updatedLocallyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_locally_at'],
      )!,
    );
  }

  @override
  $TripsCacheTable createAlias(String alias) {
    return $TripsCacheTable(attachedDatabase, alias);
  }
}

class TripsCacheData extends DataClass implements Insertable<TripsCacheData> {
  final String clientTripId;
  final String? serverId;
  final String driverId;
  final String vehicleId;
  final String tarih;
  final DateTime? fabrikaCikisAt;
  final DateTime? fabrikaGirisAt;
  final bool synced;
  final int retryCount;
  final String? lastError;
  final DateTime updatedLocallyAt;
  const TripsCacheData({
    required this.clientTripId,
    this.serverId,
    required this.driverId,
    required this.vehicleId,
    required this.tarih,
    this.fabrikaCikisAt,
    this.fabrikaGirisAt,
    required this.synced,
    required this.retryCount,
    this.lastError,
    required this.updatedLocallyAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_trip_id'] = Variable<String>(clientTripId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['driver_id'] = Variable<String>(driverId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['tarih'] = Variable<String>(tarih);
    if (!nullToAbsent || fabrikaCikisAt != null) {
      map['fabrika_cikis_at'] = Variable<DateTime>(fabrikaCikisAt);
    }
    if (!nullToAbsent || fabrikaGirisAt != null) {
      map['fabrika_giris_at'] = Variable<DateTime>(fabrikaGirisAt);
    }
    map['synced'] = Variable<bool>(synced);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['updated_locally_at'] = Variable<DateTime>(updatedLocallyAt);
    return map;
  }

  TripsCacheCompanion toCompanion(bool nullToAbsent) {
    return TripsCacheCompanion(
      clientTripId: Value(clientTripId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      driverId: Value(driverId),
      vehicleId: Value(vehicleId),
      tarih: Value(tarih),
      fabrikaCikisAt: fabrikaCikisAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fabrikaCikisAt),
      fabrikaGirisAt: fabrikaGirisAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fabrikaGirisAt),
      synced: Value(synced),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      updatedLocallyAt: Value(updatedLocallyAt),
    );
  }

  factory TripsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripsCacheData(
      clientTripId: serializer.fromJson<String>(json['clientTripId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      driverId: serializer.fromJson<String>(json['driverId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      tarih: serializer.fromJson<String>(json['tarih']),
      fabrikaCikisAt: serializer.fromJson<DateTime?>(json['fabrikaCikisAt']),
      fabrikaGirisAt: serializer.fromJson<DateTime?>(json['fabrikaGirisAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      updatedLocallyAt: serializer.fromJson<DateTime>(json['updatedLocallyAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientTripId': serializer.toJson<String>(clientTripId),
      'serverId': serializer.toJson<String?>(serverId),
      'driverId': serializer.toJson<String>(driverId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'tarih': serializer.toJson<String>(tarih),
      'fabrikaCikisAt': serializer.toJson<DateTime?>(fabrikaCikisAt),
      'fabrikaGirisAt': serializer.toJson<DateTime?>(fabrikaGirisAt),
      'synced': serializer.toJson<bool>(synced),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'updatedLocallyAt': serializer.toJson<DateTime>(updatedLocallyAt),
    };
  }

  TripsCacheData copyWith({
    String? clientTripId,
    Value<String?> serverId = const Value.absent(),
    String? driverId,
    String? vehicleId,
    String? tarih,
    Value<DateTime?> fabrikaCikisAt = const Value.absent(),
    Value<DateTime?> fabrikaGirisAt = const Value.absent(),
    bool? synced,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? updatedLocallyAt,
  }) => TripsCacheData(
    clientTripId: clientTripId ?? this.clientTripId,
    serverId: serverId.present ? serverId.value : this.serverId,
    driverId: driverId ?? this.driverId,
    vehicleId: vehicleId ?? this.vehicleId,
    tarih: tarih ?? this.tarih,
    fabrikaCikisAt: fabrikaCikisAt.present
        ? fabrikaCikisAt.value
        : this.fabrikaCikisAt,
    fabrikaGirisAt: fabrikaGirisAt.present
        ? fabrikaGirisAt.value
        : this.fabrikaGirisAt,
    synced: synced ?? this.synced,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    updatedLocallyAt: updatedLocallyAt ?? this.updatedLocallyAt,
  );
  TripsCacheData copyWithCompanion(TripsCacheCompanion data) {
    return TripsCacheData(
      clientTripId: data.clientTripId.present
          ? data.clientTripId.value
          : this.clientTripId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      tarih: data.tarih.present ? data.tarih.value : this.tarih,
      fabrikaCikisAt: data.fabrikaCikisAt.present
          ? data.fabrikaCikisAt.value
          : this.fabrikaCikisAt,
      fabrikaGirisAt: data.fabrikaGirisAt.present
          ? data.fabrikaGirisAt.value
          : this.fabrikaGirisAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      updatedLocallyAt: data.updatedLocallyAt.present
          ? data.updatedLocallyAt.value
          : this.updatedLocallyAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripsCacheData(')
          ..write('clientTripId: $clientTripId, ')
          ..write('serverId: $serverId, ')
          ..write('driverId: $driverId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('tarih: $tarih, ')
          ..write('fabrikaCikisAt: $fabrikaCikisAt, ')
          ..write('fabrikaGirisAt: $fabrikaGirisAt, ')
          ..write('synced: $synced, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('updatedLocallyAt: $updatedLocallyAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientTripId,
    serverId,
    driverId,
    vehicleId,
    tarih,
    fabrikaCikisAt,
    fabrikaGirisAt,
    synced,
    retryCount,
    lastError,
    updatedLocallyAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripsCacheData &&
          other.clientTripId == this.clientTripId &&
          other.serverId == this.serverId &&
          other.driverId == this.driverId &&
          other.vehicleId == this.vehicleId &&
          other.tarih == this.tarih &&
          other.fabrikaCikisAt == this.fabrikaCikisAt &&
          other.fabrikaGirisAt == this.fabrikaGirisAt &&
          other.synced == this.synced &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.updatedLocallyAt == this.updatedLocallyAt);
}

class TripsCacheCompanion extends UpdateCompanion<TripsCacheData> {
  final Value<String> clientTripId;
  final Value<String?> serverId;
  final Value<String> driverId;
  final Value<String> vehicleId;
  final Value<String> tarih;
  final Value<DateTime?> fabrikaCikisAt;
  final Value<DateTime?> fabrikaGirisAt;
  final Value<bool> synced;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> updatedLocallyAt;
  final Value<int> rowid;
  const TripsCacheCompanion({
    this.clientTripId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.tarih = const Value.absent(),
    this.fabrikaCikisAt = const Value.absent(),
    this.fabrikaGirisAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedLocallyAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCacheCompanion.insert({
    required String clientTripId,
    this.serverId = const Value.absent(),
    required String driverId,
    required String vehicleId,
    required String tarih,
    this.fabrikaCikisAt = const Value.absent(),
    this.fabrikaGirisAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime updatedLocallyAt,
    this.rowid = const Value.absent(),
  }) : clientTripId = Value(clientTripId),
       driverId = Value(driverId),
       vehicleId = Value(vehicleId),
       tarih = Value(tarih),
       updatedLocallyAt = Value(updatedLocallyAt);
  static Insertable<TripsCacheData> custom({
    Expression<String>? clientTripId,
    Expression<String>? serverId,
    Expression<String>? driverId,
    Expression<String>? vehicleId,
    Expression<String>? tarih,
    Expression<DateTime>? fabrikaCikisAt,
    Expression<DateTime>? fabrikaGirisAt,
    Expression<bool>? synced,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? updatedLocallyAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientTripId != null) 'client_trip_id': clientTripId,
      if (serverId != null) 'server_id': serverId,
      if (driverId != null) 'driver_id': driverId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (tarih != null) 'tarih': tarih,
      if (fabrikaCikisAt != null) 'fabrika_cikis_at': fabrikaCikisAt,
      if (fabrikaGirisAt != null) 'fabrika_giris_at': fabrikaGirisAt,
      if (synced != null) 'synced': synced,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (updatedLocallyAt != null) 'updated_locally_at': updatedLocallyAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCacheCompanion copyWith({
    Value<String>? clientTripId,
    Value<String?>? serverId,
    Value<String>? driverId,
    Value<String>? vehicleId,
    Value<String>? tarih,
    Value<DateTime?>? fabrikaCikisAt,
    Value<DateTime?>? fabrikaGirisAt,
    Value<bool>? synced,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? updatedLocallyAt,
    Value<int>? rowid,
  }) {
    return TripsCacheCompanion(
      clientTripId: clientTripId ?? this.clientTripId,
      serverId: serverId ?? this.serverId,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      tarih: tarih ?? this.tarih,
      fabrikaCikisAt: fabrikaCikisAt ?? this.fabrikaCikisAt,
      fabrikaGirisAt: fabrikaGirisAt ?? this.fabrikaGirisAt,
      synced: synced ?? this.synced,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      updatedLocallyAt: updatedLocallyAt ?? this.updatedLocallyAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientTripId.present) {
      map['client_trip_id'] = Variable<String>(clientTripId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (tarih.present) {
      map['tarih'] = Variable<String>(tarih.value);
    }
    if (fabrikaCikisAt.present) {
      map['fabrika_cikis_at'] = Variable<DateTime>(fabrikaCikisAt.value);
    }
    if (fabrikaGirisAt.present) {
      map['fabrika_giris_at'] = Variable<DateTime>(fabrikaGirisAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (updatedLocallyAt.present) {
      map['updated_locally_at'] = Variable<DateTime>(updatedLocallyAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCacheCompanion(')
          ..write('clientTripId: $clientTripId, ')
          ..write('serverId: $serverId, ')
          ..write('driverId: $driverId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('tarih: $tarih, ')
          ..write('fabrikaCikisAt: $fabrikaCikisAt, ')
          ..write('fabrikaGirisAt: $fabrikaGirisAt, ')
          ..write('synced: $synced, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('updatedLocallyAt: $updatedLocallyAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripStopsCacheTable extends TripStopsCache
    with TableInfo<$TripStopsCacheTable, TripStopsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripStopsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientStopIdMeta = const VerificationMeta(
    'clientStopId',
  );
  @override
  late final GeneratedColumn<String> clientStopId = GeneratedColumn<String>(
    'client_stop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientTripIdMeta = const VerificationMeta(
    'clientTripId',
  );
  @override
  late final GeneratedColumn<String> clientTripId = GeneratedColumn<String>(
    'client_trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siraMeta = const VerificationMeta('sira');
  @override
  late final GeneratedColumn<int> sira = GeneratedColumn<int>(
    'sira',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firmaGirisAtMeta = const VerificationMeta(
    'firmaGirisAt',
  );
  @override
  late final GeneratedColumn<DateTime> firmaGirisAt = GeneratedColumn<DateTime>(
    'firma_giris_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripTypeIdMeta = const VerificationMeta(
    'tripTypeId',
  );
  @override
  late final GeneratedColumn<String> tripTypeId = GeneratedColumn<String>(
    'trip_type_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requesterIdMeta = const VerificationMeta(
    'requesterId',
  );
  @override
  late final GeneratedColumn<String> requesterId = GeneratedColumn<String>(
    'requester_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cikisNedeniMeta = const VerificationMeta(
    'cikisNedeni',
  );
  @override
  late final GeneratedColumn<String> cikisNedeni = GeneratedColumn<String>(
    'cikis_nedeni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gidilenIlMeta = const VerificationMeta(
    'gidilenIl',
  );
  @override
  late final GeneratedColumn<String> gidilenIl = GeneratedColumn<String>(
    'gidilen_il',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gidilenIlceMeta = const VerificationMeta(
    'gidilenIlce',
  );
  @override
  late final GeneratedColumn<String> gidilenIlce = GeneratedColumn<String>(
    'gidilen_ilce',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gidilenSirketIdMeta = const VerificationMeta(
    'gidilenSirketId',
  );
  @override
  late final GeneratedColumn<String> gidilenSirketId = GeneratedColumn<String>(
    'gidilen_sirket_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gidilenSirketFreeMeta = const VerificationMeta(
    'gidilenSirketFree',
  );
  @override
  late final GeneratedColumn<String> gidilenSirketFree =
      GeneratedColumn<String>(
        'gidilen_sirket_free',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _irsaliyeNoMeta = const VerificationMeta(
    'irsaliyeNo',
  );
  @override
  late final GeneratedColumn<String> irsaliyeNo = GeneratedColumn<String>(
    'irsaliye_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firmaCikisAtMeta = const VerificationMeta(
    'firmaCikisAt',
  );
  @override
  late final GeneratedColumn<DateTime> firmaCikisAt = GeneratedColumn<DateTime>(
    'firma_cikis_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notlarMeta = const VerificationMeta('notlar');
  @override
  late final GeneratedColumn<String> notlar = GeneratedColumn<String>(
    'notlar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedLocallyAtMeta = const VerificationMeta(
    'updatedLocallyAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedLocallyAt =
      GeneratedColumn<DateTime>(
        'updated_locally_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    clientStopId,
    serverId,
    clientTripId,
    sira,
    firmaGirisAt,
    tripTypeId,
    requesterId,
    cikisNedeni,
    gidilenIl,
    gidilenIlce,
    gidilenSirketId,
    gidilenSirketFree,
    irsaliyeNo,
    firmaCikisAt,
    notlar,
    synced,
    retryCount,
    lastError,
    updatedLocallyAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_stops_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripStopsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_stop_id')) {
      context.handle(
        _clientStopIdMeta,
        clientStopId.isAcceptableOrUnknown(
          data['client_stop_id']!,
          _clientStopIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientStopIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_trip_id')) {
      context.handle(
        _clientTripIdMeta,
        clientTripId.isAcceptableOrUnknown(
          data['client_trip_id']!,
          _clientTripIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientTripIdMeta);
    }
    if (data.containsKey('sira')) {
      context.handle(
        _siraMeta,
        sira.isAcceptableOrUnknown(data['sira']!, _siraMeta),
      );
    } else if (isInserting) {
      context.missing(_siraMeta);
    }
    if (data.containsKey('firma_giris_at')) {
      context.handle(
        _firmaGirisAtMeta,
        firmaGirisAt.isAcceptableOrUnknown(
          data['firma_giris_at']!,
          _firmaGirisAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firmaGirisAtMeta);
    }
    if (data.containsKey('trip_type_id')) {
      context.handle(
        _tripTypeIdMeta,
        tripTypeId.isAcceptableOrUnknown(
          data['trip_type_id']!,
          _tripTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('requester_id')) {
      context.handle(
        _requesterIdMeta,
        requesterId.isAcceptableOrUnknown(
          data['requester_id']!,
          _requesterIdMeta,
        ),
      );
    }
    if (data.containsKey('cikis_nedeni')) {
      context.handle(
        _cikisNedeniMeta,
        cikisNedeni.isAcceptableOrUnknown(
          data['cikis_nedeni']!,
          _cikisNedeniMeta,
        ),
      );
    }
    if (data.containsKey('gidilen_il')) {
      context.handle(
        _gidilenIlMeta,
        gidilenIl.isAcceptableOrUnknown(data['gidilen_il']!, _gidilenIlMeta),
      );
    }
    if (data.containsKey('gidilen_ilce')) {
      context.handle(
        _gidilenIlceMeta,
        gidilenIlce.isAcceptableOrUnknown(
          data['gidilen_ilce']!,
          _gidilenIlceMeta,
        ),
      );
    }
    if (data.containsKey('gidilen_sirket_id')) {
      context.handle(
        _gidilenSirketIdMeta,
        gidilenSirketId.isAcceptableOrUnknown(
          data['gidilen_sirket_id']!,
          _gidilenSirketIdMeta,
        ),
      );
    }
    if (data.containsKey('gidilen_sirket_free')) {
      context.handle(
        _gidilenSirketFreeMeta,
        gidilenSirketFree.isAcceptableOrUnknown(
          data['gidilen_sirket_free']!,
          _gidilenSirketFreeMeta,
        ),
      );
    }
    if (data.containsKey('irsaliye_no')) {
      context.handle(
        _irsaliyeNoMeta,
        irsaliyeNo.isAcceptableOrUnknown(data['irsaliye_no']!, _irsaliyeNoMeta),
      );
    }
    if (data.containsKey('firma_cikis_at')) {
      context.handle(
        _firmaCikisAtMeta,
        firmaCikisAt.isAcceptableOrUnknown(
          data['firma_cikis_at']!,
          _firmaCikisAtMeta,
        ),
      );
    }
    if (data.containsKey('notlar')) {
      context.handle(
        _notlarMeta,
        notlar.isAcceptableOrUnknown(data['notlar']!, _notlarMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('updated_locally_at')) {
      context.handle(
        _updatedLocallyAtMeta,
        updatedLocallyAt.isAcceptableOrUnknown(
          data['updated_locally_at']!,
          _updatedLocallyAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedLocallyAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientStopId};
  @override
  TripStopsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripStopsCacheData(
      clientStopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_stop_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      clientTripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_trip_id'],
      )!,
      sira: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sira'],
      )!,
      firmaGirisAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}firma_giris_at'],
      )!,
      tripTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_type_id'],
      ),
      requesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requester_id'],
      ),
      cikisNedeni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cikis_nedeni'],
      ),
      gidilenIl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gidilen_il'],
      ),
      gidilenIlce: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gidilen_ilce'],
      ),
      gidilenSirketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gidilen_sirket_id'],
      ),
      gidilenSirketFree: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gidilen_sirket_free'],
      ),
      irsaliyeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}irsaliye_no'],
      ),
      firmaCikisAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}firma_cikis_at'],
      ),
      notlar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notlar'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      updatedLocallyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_locally_at'],
      )!,
    );
  }

  @override
  $TripStopsCacheTable createAlias(String alias) {
    return $TripStopsCacheTable(attachedDatabase, alias);
  }
}

class TripStopsCacheData extends DataClass
    implements Insertable<TripStopsCacheData> {
  final String clientStopId;
  final String? serverId;
  final String clientTripId;
  final int sira;
  final DateTime firmaGirisAt;
  final String? tripTypeId;
  final String? requesterId;
  final String? cikisNedeni;
  final String? gidilenIl;
  final String? gidilenIlce;
  final String? gidilenSirketId;
  final String? gidilenSirketFree;
  final String? irsaliyeNo;
  final DateTime? firmaCikisAt;
  final String? notlar;
  final bool synced;
  final int retryCount;
  final String? lastError;
  final DateTime updatedLocallyAt;
  const TripStopsCacheData({
    required this.clientStopId,
    this.serverId,
    required this.clientTripId,
    required this.sira,
    required this.firmaGirisAt,
    this.tripTypeId,
    this.requesterId,
    this.cikisNedeni,
    this.gidilenIl,
    this.gidilenIlce,
    this.gidilenSirketId,
    this.gidilenSirketFree,
    this.irsaliyeNo,
    this.firmaCikisAt,
    this.notlar,
    required this.synced,
    required this.retryCount,
    this.lastError,
    required this.updatedLocallyAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_stop_id'] = Variable<String>(clientStopId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['client_trip_id'] = Variable<String>(clientTripId);
    map['sira'] = Variable<int>(sira);
    map['firma_giris_at'] = Variable<DateTime>(firmaGirisAt);
    if (!nullToAbsent || tripTypeId != null) {
      map['trip_type_id'] = Variable<String>(tripTypeId);
    }
    if (!nullToAbsent || requesterId != null) {
      map['requester_id'] = Variable<String>(requesterId);
    }
    if (!nullToAbsent || cikisNedeni != null) {
      map['cikis_nedeni'] = Variable<String>(cikisNedeni);
    }
    if (!nullToAbsent || gidilenIl != null) {
      map['gidilen_il'] = Variable<String>(gidilenIl);
    }
    if (!nullToAbsent || gidilenIlce != null) {
      map['gidilen_ilce'] = Variable<String>(gidilenIlce);
    }
    if (!nullToAbsent || gidilenSirketId != null) {
      map['gidilen_sirket_id'] = Variable<String>(gidilenSirketId);
    }
    if (!nullToAbsent || gidilenSirketFree != null) {
      map['gidilen_sirket_free'] = Variable<String>(gidilenSirketFree);
    }
    if (!nullToAbsent || irsaliyeNo != null) {
      map['irsaliye_no'] = Variable<String>(irsaliyeNo);
    }
    if (!nullToAbsent || firmaCikisAt != null) {
      map['firma_cikis_at'] = Variable<DateTime>(firmaCikisAt);
    }
    if (!nullToAbsent || notlar != null) {
      map['notlar'] = Variable<String>(notlar);
    }
    map['synced'] = Variable<bool>(synced);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['updated_locally_at'] = Variable<DateTime>(updatedLocallyAt);
    return map;
  }

  TripStopsCacheCompanion toCompanion(bool nullToAbsent) {
    return TripStopsCacheCompanion(
      clientStopId: Value(clientStopId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientTripId: Value(clientTripId),
      sira: Value(sira),
      firmaGirisAt: Value(firmaGirisAt),
      tripTypeId: tripTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripTypeId),
      requesterId: requesterId == null && nullToAbsent
          ? const Value.absent()
          : Value(requesterId),
      cikisNedeni: cikisNedeni == null && nullToAbsent
          ? const Value.absent()
          : Value(cikisNedeni),
      gidilenIl: gidilenIl == null && nullToAbsent
          ? const Value.absent()
          : Value(gidilenIl),
      gidilenIlce: gidilenIlce == null && nullToAbsent
          ? const Value.absent()
          : Value(gidilenIlce),
      gidilenSirketId: gidilenSirketId == null && nullToAbsent
          ? const Value.absent()
          : Value(gidilenSirketId),
      gidilenSirketFree: gidilenSirketFree == null && nullToAbsent
          ? const Value.absent()
          : Value(gidilenSirketFree),
      irsaliyeNo: irsaliyeNo == null && nullToAbsent
          ? const Value.absent()
          : Value(irsaliyeNo),
      firmaCikisAt: firmaCikisAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firmaCikisAt),
      notlar: notlar == null && nullToAbsent
          ? const Value.absent()
          : Value(notlar),
      synced: Value(synced),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      updatedLocallyAt: Value(updatedLocallyAt),
    );
  }

  factory TripStopsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripStopsCacheData(
      clientStopId: serializer.fromJson<String>(json['clientStopId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientTripId: serializer.fromJson<String>(json['clientTripId']),
      sira: serializer.fromJson<int>(json['sira']),
      firmaGirisAt: serializer.fromJson<DateTime>(json['firmaGirisAt']),
      tripTypeId: serializer.fromJson<String?>(json['tripTypeId']),
      requesterId: serializer.fromJson<String?>(json['requesterId']),
      cikisNedeni: serializer.fromJson<String?>(json['cikisNedeni']),
      gidilenIl: serializer.fromJson<String?>(json['gidilenIl']),
      gidilenIlce: serializer.fromJson<String?>(json['gidilenIlce']),
      gidilenSirketId: serializer.fromJson<String?>(json['gidilenSirketId']),
      gidilenSirketFree: serializer.fromJson<String?>(
        json['gidilenSirketFree'],
      ),
      irsaliyeNo: serializer.fromJson<String?>(json['irsaliyeNo']),
      firmaCikisAt: serializer.fromJson<DateTime?>(json['firmaCikisAt']),
      notlar: serializer.fromJson<String?>(json['notlar']),
      synced: serializer.fromJson<bool>(json['synced']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      updatedLocallyAt: serializer.fromJson<DateTime>(json['updatedLocallyAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientStopId': serializer.toJson<String>(clientStopId),
      'serverId': serializer.toJson<String?>(serverId),
      'clientTripId': serializer.toJson<String>(clientTripId),
      'sira': serializer.toJson<int>(sira),
      'firmaGirisAt': serializer.toJson<DateTime>(firmaGirisAt),
      'tripTypeId': serializer.toJson<String?>(tripTypeId),
      'requesterId': serializer.toJson<String?>(requesterId),
      'cikisNedeni': serializer.toJson<String?>(cikisNedeni),
      'gidilenIl': serializer.toJson<String?>(gidilenIl),
      'gidilenIlce': serializer.toJson<String?>(gidilenIlce),
      'gidilenSirketId': serializer.toJson<String?>(gidilenSirketId),
      'gidilenSirketFree': serializer.toJson<String?>(gidilenSirketFree),
      'irsaliyeNo': serializer.toJson<String?>(irsaliyeNo),
      'firmaCikisAt': serializer.toJson<DateTime?>(firmaCikisAt),
      'notlar': serializer.toJson<String?>(notlar),
      'synced': serializer.toJson<bool>(synced),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'updatedLocallyAt': serializer.toJson<DateTime>(updatedLocallyAt),
    };
  }

  TripStopsCacheData copyWith({
    String? clientStopId,
    Value<String?> serverId = const Value.absent(),
    String? clientTripId,
    int? sira,
    DateTime? firmaGirisAt,
    Value<String?> tripTypeId = const Value.absent(),
    Value<String?> requesterId = const Value.absent(),
    Value<String?> cikisNedeni = const Value.absent(),
    Value<String?> gidilenIl = const Value.absent(),
    Value<String?> gidilenIlce = const Value.absent(),
    Value<String?> gidilenSirketId = const Value.absent(),
    Value<String?> gidilenSirketFree = const Value.absent(),
    Value<String?> irsaliyeNo = const Value.absent(),
    Value<DateTime?> firmaCikisAt = const Value.absent(),
    Value<String?> notlar = const Value.absent(),
    bool? synced,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? updatedLocallyAt,
  }) => TripStopsCacheData(
    clientStopId: clientStopId ?? this.clientStopId,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientTripId: clientTripId ?? this.clientTripId,
    sira: sira ?? this.sira,
    firmaGirisAt: firmaGirisAt ?? this.firmaGirisAt,
    tripTypeId: tripTypeId.present ? tripTypeId.value : this.tripTypeId,
    requesterId: requesterId.present ? requesterId.value : this.requesterId,
    cikisNedeni: cikisNedeni.present ? cikisNedeni.value : this.cikisNedeni,
    gidilenIl: gidilenIl.present ? gidilenIl.value : this.gidilenIl,
    gidilenIlce: gidilenIlce.present ? gidilenIlce.value : this.gidilenIlce,
    gidilenSirketId: gidilenSirketId.present
        ? gidilenSirketId.value
        : this.gidilenSirketId,
    gidilenSirketFree: gidilenSirketFree.present
        ? gidilenSirketFree.value
        : this.gidilenSirketFree,
    irsaliyeNo: irsaliyeNo.present ? irsaliyeNo.value : this.irsaliyeNo,
    firmaCikisAt: firmaCikisAt.present ? firmaCikisAt.value : this.firmaCikisAt,
    notlar: notlar.present ? notlar.value : this.notlar,
    synced: synced ?? this.synced,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    updatedLocallyAt: updatedLocallyAt ?? this.updatedLocallyAt,
  );
  TripStopsCacheData copyWithCompanion(TripStopsCacheCompanion data) {
    return TripStopsCacheData(
      clientStopId: data.clientStopId.present
          ? data.clientStopId.value
          : this.clientStopId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientTripId: data.clientTripId.present
          ? data.clientTripId.value
          : this.clientTripId,
      sira: data.sira.present ? data.sira.value : this.sira,
      firmaGirisAt: data.firmaGirisAt.present
          ? data.firmaGirisAt.value
          : this.firmaGirisAt,
      tripTypeId: data.tripTypeId.present
          ? data.tripTypeId.value
          : this.tripTypeId,
      requesterId: data.requesterId.present
          ? data.requesterId.value
          : this.requesterId,
      cikisNedeni: data.cikisNedeni.present
          ? data.cikisNedeni.value
          : this.cikisNedeni,
      gidilenIl: data.gidilenIl.present ? data.gidilenIl.value : this.gidilenIl,
      gidilenIlce: data.gidilenIlce.present
          ? data.gidilenIlce.value
          : this.gidilenIlce,
      gidilenSirketId: data.gidilenSirketId.present
          ? data.gidilenSirketId.value
          : this.gidilenSirketId,
      gidilenSirketFree: data.gidilenSirketFree.present
          ? data.gidilenSirketFree.value
          : this.gidilenSirketFree,
      irsaliyeNo: data.irsaliyeNo.present
          ? data.irsaliyeNo.value
          : this.irsaliyeNo,
      firmaCikisAt: data.firmaCikisAt.present
          ? data.firmaCikisAt.value
          : this.firmaCikisAt,
      notlar: data.notlar.present ? data.notlar.value : this.notlar,
      synced: data.synced.present ? data.synced.value : this.synced,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      updatedLocallyAt: data.updatedLocallyAt.present
          ? data.updatedLocallyAt.value
          : this.updatedLocallyAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripStopsCacheData(')
          ..write('clientStopId: $clientStopId, ')
          ..write('serverId: $serverId, ')
          ..write('clientTripId: $clientTripId, ')
          ..write('sira: $sira, ')
          ..write('firmaGirisAt: $firmaGirisAt, ')
          ..write('tripTypeId: $tripTypeId, ')
          ..write('requesterId: $requesterId, ')
          ..write('cikisNedeni: $cikisNedeni, ')
          ..write('gidilenIl: $gidilenIl, ')
          ..write('gidilenIlce: $gidilenIlce, ')
          ..write('gidilenSirketId: $gidilenSirketId, ')
          ..write('gidilenSirketFree: $gidilenSirketFree, ')
          ..write('irsaliyeNo: $irsaliyeNo, ')
          ..write('firmaCikisAt: $firmaCikisAt, ')
          ..write('notlar: $notlar, ')
          ..write('synced: $synced, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('updatedLocallyAt: $updatedLocallyAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientStopId,
    serverId,
    clientTripId,
    sira,
    firmaGirisAt,
    tripTypeId,
    requesterId,
    cikisNedeni,
    gidilenIl,
    gidilenIlce,
    gidilenSirketId,
    gidilenSirketFree,
    irsaliyeNo,
    firmaCikisAt,
    notlar,
    synced,
    retryCount,
    lastError,
    updatedLocallyAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripStopsCacheData &&
          other.clientStopId == this.clientStopId &&
          other.serverId == this.serverId &&
          other.clientTripId == this.clientTripId &&
          other.sira == this.sira &&
          other.firmaGirisAt == this.firmaGirisAt &&
          other.tripTypeId == this.tripTypeId &&
          other.requesterId == this.requesterId &&
          other.cikisNedeni == this.cikisNedeni &&
          other.gidilenIl == this.gidilenIl &&
          other.gidilenIlce == this.gidilenIlce &&
          other.gidilenSirketId == this.gidilenSirketId &&
          other.gidilenSirketFree == this.gidilenSirketFree &&
          other.irsaliyeNo == this.irsaliyeNo &&
          other.firmaCikisAt == this.firmaCikisAt &&
          other.notlar == this.notlar &&
          other.synced == this.synced &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.updatedLocallyAt == this.updatedLocallyAt);
}

class TripStopsCacheCompanion extends UpdateCompanion<TripStopsCacheData> {
  final Value<String> clientStopId;
  final Value<String?> serverId;
  final Value<String> clientTripId;
  final Value<int> sira;
  final Value<DateTime> firmaGirisAt;
  final Value<String?> tripTypeId;
  final Value<String?> requesterId;
  final Value<String?> cikisNedeni;
  final Value<String?> gidilenIl;
  final Value<String?> gidilenIlce;
  final Value<String?> gidilenSirketId;
  final Value<String?> gidilenSirketFree;
  final Value<String?> irsaliyeNo;
  final Value<DateTime?> firmaCikisAt;
  final Value<String?> notlar;
  final Value<bool> synced;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> updatedLocallyAt;
  final Value<int> rowid;
  const TripStopsCacheCompanion({
    this.clientStopId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientTripId = const Value.absent(),
    this.sira = const Value.absent(),
    this.firmaGirisAt = const Value.absent(),
    this.tripTypeId = const Value.absent(),
    this.requesterId = const Value.absent(),
    this.cikisNedeni = const Value.absent(),
    this.gidilenIl = const Value.absent(),
    this.gidilenIlce = const Value.absent(),
    this.gidilenSirketId = const Value.absent(),
    this.gidilenSirketFree = const Value.absent(),
    this.irsaliyeNo = const Value.absent(),
    this.firmaCikisAt = const Value.absent(),
    this.notlar = const Value.absent(),
    this.synced = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedLocallyAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripStopsCacheCompanion.insert({
    required String clientStopId,
    this.serverId = const Value.absent(),
    required String clientTripId,
    required int sira,
    required DateTime firmaGirisAt,
    this.tripTypeId = const Value.absent(),
    this.requesterId = const Value.absent(),
    this.cikisNedeni = const Value.absent(),
    this.gidilenIl = const Value.absent(),
    this.gidilenIlce = const Value.absent(),
    this.gidilenSirketId = const Value.absent(),
    this.gidilenSirketFree = const Value.absent(),
    this.irsaliyeNo = const Value.absent(),
    this.firmaCikisAt = const Value.absent(),
    this.notlar = const Value.absent(),
    this.synced = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime updatedLocallyAt,
    this.rowid = const Value.absent(),
  }) : clientStopId = Value(clientStopId),
       clientTripId = Value(clientTripId),
       sira = Value(sira),
       firmaGirisAt = Value(firmaGirisAt),
       updatedLocallyAt = Value(updatedLocallyAt);
  static Insertable<TripStopsCacheData> custom({
    Expression<String>? clientStopId,
    Expression<String>? serverId,
    Expression<String>? clientTripId,
    Expression<int>? sira,
    Expression<DateTime>? firmaGirisAt,
    Expression<String>? tripTypeId,
    Expression<String>? requesterId,
    Expression<String>? cikisNedeni,
    Expression<String>? gidilenIl,
    Expression<String>? gidilenIlce,
    Expression<String>? gidilenSirketId,
    Expression<String>? gidilenSirketFree,
    Expression<String>? irsaliyeNo,
    Expression<DateTime>? firmaCikisAt,
    Expression<String>? notlar,
    Expression<bool>? synced,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? updatedLocallyAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientStopId != null) 'client_stop_id': clientStopId,
      if (serverId != null) 'server_id': serverId,
      if (clientTripId != null) 'client_trip_id': clientTripId,
      if (sira != null) 'sira': sira,
      if (firmaGirisAt != null) 'firma_giris_at': firmaGirisAt,
      if (tripTypeId != null) 'trip_type_id': tripTypeId,
      if (requesterId != null) 'requester_id': requesterId,
      if (cikisNedeni != null) 'cikis_nedeni': cikisNedeni,
      if (gidilenIl != null) 'gidilen_il': gidilenIl,
      if (gidilenIlce != null) 'gidilen_ilce': gidilenIlce,
      if (gidilenSirketId != null) 'gidilen_sirket_id': gidilenSirketId,
      if (gidilenSirketFree != null) 'gidilen_sirket_free': gidilenSirketFree,
      if (irsaliyeNo != null) 'irsaliye_no': irsaliyeNo,
      if (firmaCikisAt != null) 'firma_cikis_at': firmaCikisAt,
      if (notlar != null) 'notlar': notlar,
      if (synced != null) 'synced': synced,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (updatedLocallyAt != null) 'updated_locally_at': updatedLocallyAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripStopsCacheCompanion copyWith({
    Value<String>? clientStopId,
    Value<String?>? serverId,
    Value<String>? clientTripId,
    Value<int>? sira,
    Value<DateTime>? firmaGirisAt,
    Value<String?>? tripTypeId,
    Value<String?>? requesterId,
    Value<String?>? cikisNedeni,
    Value<String?>? gidilenIl,
    Value<String?>? gidilenIlce,
    Value<String?>? gidilenSirketId,
    Value<String?>? gidilenSirketFree,
    Value<String?>? irsaliyeNo,
    Value<DateTime?>? firmaCikisAt,
    Value<String?>? notlar,
    Value<bool>? synced,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? updatedLocallyAt,
    Value<int>? rowid,
  }) {
    return TripStopsCacheCompanion(
      clientStopId: clientStopId ?? this.clientStopId,
      serverId: serverId ?? this.serverId,
      clientTripId: clientTripId ?? this.clientTripId,
      sira: sira ?? this.sira,
      firmaGirisAt: firmaGirisAt ?? this.firmaGirisAt,
      tripTypeId: tripTypeId ?? this.tripTypeId,
      requesterId: requesterId ?? this.requesterId,
      cikisNedeni: cikisNedeni ?? this.cikisNedeni,
      gidilenIl: gidilenIl ?? this.gidilenIl,
      gidilenIlce: gidilenIlce ?? this.gidilenIlce,
      gidilenSirketId: gidilenSirketId ?? this.gidilenSirketId,
      gidilenSirketFree: gidilenSirketFree ?? this.gidilenSirketFree,
      irsaliyeNo: irsaliyeNo ?? this.irsaliyeNo,
      firmaCikisAt: firmaCikisAt ?? this.firmaCikisAt,
      notlar: notlar ?? this.notlar,
      synced: synced ?? this.synced,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      updatedLocallyAt: updatedLocallyAt ?? this.updatedLocallyAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientStopId.present) {
      map['client_stop_id'] = Variable<String>(clientStopId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientTripId.present) {
      map['client_trip_id'] = Variable<String>(clientTripId.value);
    }
    if (sira.present) {
      map['sira'] = Variable<int>(sira.value);
    }
    if (firmaGirisAt.present) {
      map['firma_giris_at'] = Variable<DateTime>(firmaGirisAt.value);
    }
    if (tripTypeId.present) {
      map['trip_type_id'] = Variable<String>(tripTypeId.value);
    }
    if (requesterId.present) {
      map['requester_id'] = Variable<String>(requesterId.value);
    }
    if (cikisNedeni.present) {
      map['cikis_nedeni'] = Variable<String>(cikisNedeni.value);
    }
    if (gidilenIl.present) {
      map['gidilen_il'] = Variable<String>(gidilenIl.value);
    }
    if (gidilenIlce.present) {
      map['gidilen_ilce'] = Variable<String>(gidilenIlce.value);
    }
    if (gidilenSirketId.present) {
      map['gidilen_sirket_id'] = Variable<String>(gidilenSirketId.value);
    }
    if (gidilenSirketFree.present) {
      map['gidilen_sirket_free'] = Variable<String>(gidilenSirketFree.value);
    }
    if (irsaliyeNo.present) {
      map['irsaliye_no'] = Variable<String>(irsaliyeNo.value);
    }
    if (firmaCikisAt.present) {
      map['firma_cikis_at'] = Variable<DateTime>(firmaCikisAt.value);
    }
    if (notlar.present) {
      map['notlar'] = Variable<String>(notlar.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (updatedLocallyAt.present) {
      map['updated_locally_at'] = Variable<DateTime>(updatedLocallyAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripStopsCacheCompanion(')
          ..write('clientStopId: $clientStopId, ')
          ..write('serverId: $serverId, ')
          ..write('clientTripId: $clientTripId, ')
          ..write('sira: $sira, ')
          ..write('firmaGirisAt: $firmaGirisAt, ')
          ..write('tripTypeId: $tripTypeId, ')
          ..write('requesterId: $requesterId, ')
          ..write('cikisNedeni: $cikisNedeni, ')
          ..write('gidilenIl: $gidilenIl, ')
          ..write('gidilenIlce: $gidilenIlce, ')
          ..write('gidilenSirketId: $gidilenSirketId, ')
          ..write('gidilenSirketFree: $gidilenSirketFree, ')
          ..write('irsaliyeNo: $irsaliyeNo, ')
          ..write('firmaCikisAt: $firmaCikisAt, ')
          ..write('notlar: $notlar, ')
          ..write('synced: $synced, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('updatedLocallyAt: $updatedLocallyAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesCacheTable extends VehiclesCache
    with TableInfo<$VehiclesCacheTable, VehiclesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plakaMeta = const VerificationMeta('plaka');
  @override
  late final GeneratedColumn<String> plaka = GeneratedColumn<String>(
    'plaka',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aciklamaMeta = const VerificationMeta(
    'aciklama',
  );
  @override
  late final GeneratedColumn<String> aciklama = GeneratedColumn<String>(
    'aciklama',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, plaka, aciklama, aktif];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehiclesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plaka')) {
      context.handle(
        _plakaMeta,
        plaka.isAcceptableOrUnknown(data['plaka']!, _plakaMeta),
      );
    } else if (isInserting) {
      context.missing(_plakaMeta);
    }
    if (data.containsKey('aciklama')) {
      context.handle(
        _aciklamaMeta,
        aciklama.isAcceptableOrUnknown(data['aciklama']!, _aciklamaMeta),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehiclesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehiclesCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plaka: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plaka'],
      )!,
      aciklama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aciklama'],
      ),
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
    );
  }

  @override
  $VehiclesCacheTable createAlias(String alias) {
    return $VehiclesCacheTable(attachedDatabase, alias);
  }
}

class VehiclesCacheData extends DataClass
    implements Insertable<VehiclesCacheData> {
  final String id;
  final String plaka;
  final String? aciklama;
  final bool aktif;
  const VehiclesCacheData({
    required this.id,
    required this.plaka,
    this.aciklama,
    required this.aktif,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plaka'] = Variable<String>(plaka);
    if (!nullToAbsent || aciklama != null) {
      map['aciklama'] = Variable<String>(aciklama);
    }
    map['aktif'] = Variable<bool>(aktif);
    return map;
  }

  VehiclesCacheCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCacheCompanion(
      id: Value(id),
      plaka: Value(plaka),
      aciklama: aciklama == null && nullToAbsent
          ? const Value.absent()
          : Value(aciklama),
      aktif: Value(aktif),
    );
  }

  factory VehiclesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehiclesCacheData(
      id: serializer.fromJson<String>(json['id']),
      plaka: serializer.fromJson<String>(json['plaka']),
      aciklama: serializer.fromJson<String?>(json['aciklama']),
      aktif: serializer.fromJson<bool>(json['aktif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plaka': serializer.toJson<String>(plaka),
      'aciklama': serializer.toJson<String?>(aciklama),
      'aktif': serializer.toJson<bool>(aktif),
    };
  }

  VehiclesCacheData copyWith({
    String? id,
    String? plaka,
    Value<String?> aciklama = const Value.absent(),
    bool? aktif,
  }) => VehiclesCacheData(
    id: id ?? this.id,
    plaka: plaka ?? this.plaka,
    aciklama: aciklama.present ? aciklama.value : this.aciklama,
    aktif: aktif ?? this.aktif,
  );
  VehiclesCacheData copyWithCompanion(VehiclesCacheCompanion data) {
    return VehiclesCacheData(
      id: data.id.present ? data.id.value : this.id,
      plaka: data.plaka.present ? data.plaka.value : this.plaka,
      aciklama: data.aciklama.present ? data.aciklama.value : this.aciklama,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCacheData(')
          ..write('id: $id, ')
          ..write('plaka: $plaka, ')
          ..write('aciklama: $aciklama, ')
          ..write('aktif: $aktif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plaka, aciklama, aktif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehiclesCacheData &&
          other.id == this.id &&
          other.plaka == this.plaka &&
          other.aciklama == this.aciklama &&
          other.aktif == this.aktif);
}

class VehiclesCacheCompanion extends UpdateCompanion<VehiclesCacheData> {
  final Value<String> id;
  final Value<String> plaka;
  final Value<String?> aciklama;
  final Value<bool> aktif;
  final Value<int> rowid;
  const VehiclesCacheCompanion({
    this.id = const Value.absent(),
    this.plaka = const Value.absent(),
    this.aciklama = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCacheCompanion.insert({
    required String id,
    required String plaka,
    this.aciklama = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plaka = Value(plaka);
  static Insertable<VehiclesCacheData> custom({
    Expression<String>? id,
    Expression<String>? plaka,
    Expression<String>? aciklama,
    Expression<bool>? aktif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plaka != null) 'plaka': plaka,
      if (aciklama != null) 'aciklama': aciklama,
      if (aktif != null) 'aktif': aktif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? plaka,
    Value<String?>? aciklama,
    Value<bool>? aktif,
    Value<int>? rowid,
  }) {
    return VehiclesCacheCompanion(
      id: id ?? this.id,
      plaka: plaka ?? this.plaka,
      aciklama: aciklama ?? this.aciklama,
      aktif: aktif ?? this.aktif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plaka.present) {
      map['plaka'] = Variable<String>(plaka.value);
    }
    if (aciklama.present) {
      map['aciklama'] = Variable<String>(aciklama.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCacheCompanion(')
          ..write('id: $id, ')
          ..write('plaka: $plaka, ')
          ..write('aciklama: $aciklama, ')
          ..write('aktif: $aktif, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripTypesCacheTable extends TripTypesCache
    with TableInfo<$TripTypesCacheTable, TripTypesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripTypesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiresIrsaliyeMeta = const VerificationMeta(
    'requiresIrsaliye',
  );
  @override
  late final GeneratedColumn<bool> requiresIrsaliye = GeneratedColumn<bool>(
    'requires_irsaliye',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_irsaliye" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _siraMeta = const VerificationMeta('sira');
  @override
  late final GeneratedColumn<int> sira = GeneratedColumn<int>(
    'sira',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    label,
    requiresIrsaliye,
    sira,
    aktif,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_types_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripTypesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('requires_irsaliye')) {
      context.handle(
        _requiresIrsaliyeMeta,
        requiresIrsaliye.isAcceptableOrUnknown(
          data['requires_irsaliye']!,
          _requiresIrsaliyeMeta,
        ),
      );
    }
    if (data.containsKey('sira')) {
      context.handle(
        _siraMeta,
        sira.isAcceptableOrUnknown(data['sira']!, _siraMeta),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripTypesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripTypesCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      requiresIrsaliye: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_irsaliye'],
      )!,
      sira: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sira'],
      )!,
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
    );
  }

  @override
  $TripTypesCacheTable createAlias(String alias) {
    return $TripTypesCacheTable(attachedDatabase, alias);
  }
}

class TripTypesCacheData extends DataClass
    implements Insertable<TripTypesCacheData> {
  final String id;
  final String code;
  final String label;
  final bool requiresIrsaliye;
  final int sira;
  final bool aktif;
  const TripTypesCacheData({
    required this.id,
    required this.code,
    required this.label,
    required this.requiresIrsaliye,
    required this.sira,
    required this.aktif,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['label'] = Variable<String>(label);
    map['requires_irsaliye'] = Variable<bool>(requiresIrsaliye);
    map['sira'] = Variable<int>(sira);
    map['aktif'] = Variable<bool>(aktif);
    return map;
  }

  TripTypesCacheCompanion toCompanion(bool nullToAbsent) {
    return TripTypesCacheCompanion(
      id: Value(id),
      code: Value(code),
      label: Value(label),
      requiresIrsaliye: Value(requiresIrsaliye),
      sira: Value(sira),
      aktif: Value(aktif),
    );
  }

  factory TripTypesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripTypesCacheData(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      label: serializer.fromJson<String>(json['label']),
      requiresIrsaliye: serializer.fromJson<bool>(json['requiresIrsaliye']),
      sira: serializer.fromJson<int>(json['sira']),
      aktif: serializer.fromJson<bool>(json['aktif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'label': serializer.toJson<String>(label),
      'requiresIrsaliye': serializer.toJson<bool>(requiresIrsaliye),
      'sira': serializer.toJson<int>(sira),
      'aktif': serializer.toJson<bool>(aktif),
    };
  }

  TripTypesCacheData copyWith({
    String? id,
    String? code,
    String? label,
    bool? requiresIrsaliye,
    int? sira,
    bool? aktif,
  }) => TripTypesCacheData(
    id: id ?? this.id,
    code: code ?? this.code,
    label: label ?? this.label,
    requiresIrsaliye: requiresIrsaliye ?? this.requiresIrsaliye,
    sira: sira ?? this.sira,
    aktif: aktif ?? this.aktif,
  );
  TripTypesCacheData copyWithCompanion(TripTypesCacheCompanion data) {
    return TripTypesCacheData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      label: data.label.present ? data.label.value : this.label,
      requiresIrsaliye: data.requiresIrsaliye.present
          ? data.requiresIrsaliye.value
          : this.requiresIrsaliye,
      sira: data.sira.present ? data.sira.value : this.sira,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripTypesCacheData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('label: $label, ')
          ..write('requiresIrsaliye: $requiresIrsaliye, ')
          ..write('sira: $sira, ')
          ..write('aktif: $aktif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, label, requiresIrsaliye, sira, aktif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripTypesCacheData &&
          other.id == this.id &&
          other.code == this.code &&
          other.label == this.label &&
          other.requiresIrsaliye == this.requiresIrsaliye &&
          other.sira == this.sira &&
          other.aktif == this.aktif);
}

class TripTypesCacheCompanion extends UpdateCompanion<TripTypesCacheData> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> label;
  final Value<bool> requiresIrsaliye;
  final Value<int> sira;
  final Value<bool> aktif;
  final Value<int> rowid;
  const TripTypesCacheCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.label = const Value.absent(),
    this.requiresIrsaliye = const Value.absent(),
    this.sira = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripTypesCacheCompanion.insert({
    required String id,
    required String code,
    required String label,
    this.requiresIrsaliye = const Value.absent(),
    this.sira = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       label = Value(label);
  static Insertable<TripTypesCacheData> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? label,
    Expression<bool>? requiresIrsaliye,
    Expression<int>? sira,
    Expression<bool>? aktif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (label != null) 'label': label,
      if (requiresIrsaliye != null) 'requires_irsaliye': requiresIrsaliye,
      if (sira != null) 'sira': sira,
      if (aktif != null) 'aktif': aktif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripTypesCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? label,
    Value<bool>? requiresIrsaliye,
    Value<int>? sira,
    Value<bool>? aktif,
    Value<int>? rowid,
  }) {
    return TripTypesCacheCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      requiresIrsaliye: requiresIrsaliye ?? this.requiresIrsaliye,
      sira: sira ?? this.sira,
      aktif: aktif ?? this.aktif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (requiresIrsaliye.present) {
      map['requires_irsaliye'] = Variable<bool>(requiresIrsaliye.value);
    }
    if (sira.present) {
      map['sira'] = Variable<int>(sira.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripTypesCacheCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('label: $label, ')
          ..write('requiresIrsaliye: $requiresIrsaliye, ')
          ..write('sira: $sira, ')
          ..write('aktif: $aktif, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestersCacheTable extends RequestersCache
    with TableInfo<$RequestersCacheTable, RequestersCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, fullName, aktif];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requesters_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestersCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestersCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestersCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
    );
  }

  @override
  $RequestersCacheTable createAlias(String alias) {
    return $RequestersCacheTable(attachedDatabase, alias);
  }
}

class RequestersCacheData extends DataClass
    implements Insertable<RequestersCacheData> {
  final String id;
  final String fullName;
  final bool aktif;
  const RequestersCacheData({
    required this.id,
    required this.fullName,
    required this.aktif,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    map['aktif'] = Variable<bool>(aktif);
    return map;
  }

  RequestersCacheCompanion toCompanion(bool nullToAbsent) {
    return RequestersCacheCompanion(
      id: Value(id),
      fullName: Value(fullName),
      aktif: Value(aktif),
    );
  }

  factory RequestersCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestersCacheData(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      aktif: serializer.fromJson<bool>(json['aktif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'aktif': serializer.toJson<bool>(aktif),
    };
  }

  RequestersCacheData copyWith({String? id, String? fullName, bool? aktif}) =>
      RequestersCacheData(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        aktif: aktif ?? this.aktif,
      );
  RequestersCacheData copyWithCompanion(RequestersCacheCompanion data) {
    return RequestersCacheData(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestersCacheData(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('aktif: $aktif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, aktif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestersCacheData &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.aktif == this.aktif);
}

class RequestersCacheCompanion extends UpdateCompanion<RequestersCacheData> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<bool> aktif;
  final Value<int> rowid;
  const RequestersCacheCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestersCacheCompanion.insert({
    required String id,
    required String fullName,
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName);
  static Insertable<RequestersCacheData> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<bool>? aktif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (aktif != null) 'aktif': aktif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestersCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<bool>? aktif,
    Value<int>? rowid,
  }) {
    return RequestersCacheCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      aktif: aktif ?? this.aktif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestersCacheCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('aktif: $aktif, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompaniesCacheTable extends CompaniesCache
    with TableInfo<$CompaniesCacheTable, CompaniesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sehirMeta = const VerificationMeta('sehir');
  @override
  late final GeneratedColumn<String> sehir = GeneratedColumn<String>(
    'sehir',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sehir, aktif];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompaniesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sehir')) {
      context.handle(
        _sehirMeta,
        sehir.isAcceptableOrUnknown(data['sehir']!, _sehirMeta),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompaniesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompaniesCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sehir: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sehir'],
      ),
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
    );
  }

  @override
  $CompaniesCacheTable createAlias(String alias) {
    return $CompaniesCacheTable(attachedDatabase, alias);
  }
}

class CompaniesCacheData extends DataClass
    implements Insertable<CompaniesCacheData> {
  final String id;
  final String name;
  final String? sehir;
  final bool aktif;
  const CompaniesCacheData({
    required this.id,
    required this.name,
    this.sehir,
    required this.aktif,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sehir != null) {
      map['sehir'] = Variable<String>(sehir);
    }
    map['aktif'] = Variable<bool>(aktif);
    return map;
  }

  CompaniesCacheCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCacheCompanion(
      id: Value(id),
      name: Value(name),
      sehir: sehir == null && nullToAbsent
          ? const Value.absent()
          : Value(sehir),
      aktif: Value(aktif),
    );
  }

  factory CompaniesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompaniesCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sehir: serializer.fromJson<String?>(json['sehir']),
      aktif: serializer.fromJson<bool>(json['aktif']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sehir': serializer.toJson<String?>(sehir),
      'aktif': serializer.toJson<bool>(aktif),
    };
  }

  CompaniesCacheData copyWith({
    String? id,
    String? name,
    Value<String?> sehir = const Value.absent(),
    bool? aktif,
  }) => CompaniesCacheData(
    id: id ?? this.id,
    name: name ?? this.name,
    sehir: sehir.present ? sehir.value : this.sehir,
    aktif: aktif ?? this.aktif,
  );
  CompaniesCacheData copyWithCompanion(CompaniesCacheCompanion data) {
    return CompaniesCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sehir: data.sehir.present ? data.sehir.value : this.sehir,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sehir: $sehir, ')
          ..write('aktif: $aktif')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sehir, aktif);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompaniesCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.sehir == this.sehir &&
          other.aktif == this.aktif);
}

class CompaniesCacheCompanion extends UpdateCompanion<CompaniesCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> sehir;
  final Value<bool> aktif;
  final Value<int> rowid;
  const CompaniesCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sehir = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCacheCompanion.insert({
    required String id,
    required String name,
    this.sehir = const Value.absent(),
    this.aktif = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CompaniesCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sehir,
    Expression<bool>? aktif,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sehir != null) 'sehir': sehir,
      if (aktif != null) 'aktif': aktif,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? sehir,
    Value<bool>? aktif,
    Value<int>? rowid,
  }) {
    return CompaniesCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sehir: sehir ?? this.sehir,
      aktif: aktif ?? this.aktif,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sehir.present) {
      map['sehir'] = Variable<String>(sehir.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sehir: $sehir, ')
          ..write('aktif: $aktif, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsCacheTable tripsCache = $TripsCacheTable(this);
  late final $TripStopsCacheTable tripStopsCache = $TripStopsCacheTable(this);
  late final $VehiclesCacheTable vehiclesCache = $VehiclesCacheTable(this);
  late final $TripTypesCacheTable tripTypesCache = $TripTypesCacheTable(this);
  late final $RequestersCacheTable requestersCache = $RequestersCacheTable(
    this,
  );
  late final $CompaniesCacheTable companiesCache = $CompaniesCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tripsCache,
    tripStopsCache,
    vehiclesCache,
    tripTypesCache,
    requestersCache,
    companiesCache,
  ];
}

typedef $$TripsCacheTableCreateCompanionBuilder =
    TripsCacheCompanion Function({
      required String clientTripId,
      Value<String?> serverId,
      required String driverId,
      required String vehicleId,
      required String tarih,
      Value<DateTime?> fabrikaCikisAt,
      Value<DateTime?> fabrikaGirisAt,
      Value<bool> synced,
      Value<int> retryCount,
      Value<String?> lastError,
      required DateTime updatedLocallyAt,
      Value<int> rowid,
    });
typedef $$TripsCacheTableUpdateCompanionBuilder =
    TripsCacheCompanion Function({
      Value<String> clientTripId,
      Value<String?> serverId,
      Value<String> driverId,
      Value<String> vehicleId,
      Value<String> tarih,
      Value<DateTime?> fabrikaCikisAt,
      Value<DateTime?> fabrikaGirisAt,
      Value<bool> synced,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> updatedLocallyAt,
      Value<int> rowid,
    });

class $$TripsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TripsCacheTable> {
  $$TripsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientTripId => $composableBuilder(
    column: $table.clientTripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driverId => $composableBuilder(
    column: $table.driverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fabrikaCikisAt => $composableBuilder(
    column: $table.fabrikaCikisAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fabrikaGirisAt => $composableBuilder(
    column: $table.fabrikaGirisAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedLocallyAt => $composableBuilder(
    column: $table.updatedLocallyAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsCacheTable> {
  $$TripsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientTripId => $composableBuilder(
    column: $table.clientTripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverId => $composableBuilder(
    column: $table.driverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fabrikaCikisAt => $composableBuilder(
    column: $table.fabrikaCikisAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fabrikaGirisAt => $composableBuilder(
    column: $table.fabrikaGirisAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedLocallyAt => $composableBuilder(
    column: $table.updatedLocallyAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsCacheTable> {
  $$TripsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientTripId => $composableBuilder(
    column: $table.clientTripId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get tarih =>
      $composableBuilder(column: $table.tarih, builder: (column) => column);

  GeneratedColumn<DateTime> get fabrikaCikisAt => $composableBuilder(
    column: $table.fabrikaCikisAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fabrikaGirisAt => $composableBuilder(
    column: $table.fabrikaGirisAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedLocallyAt => $composableBuilder(
    column: $table.updatedLocallyAt,
    builder: (column) => column,
  );
}

class $$TripsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsCacheTable,
          TripsCacheData,
          $$TripsCacheTableFilterComposer,
          $$TripsCacheTableOrderingComposer,
          $$TripsCacheTableAnnotationComposer,
          $$TripsCacheTableCreateCompanionBuilder,
          $$TripsCacheTableUpdateCompanionBuilder,
          (
            TripsCacheData,
            BaseReferences<_$AppDatabase, $TripsCacheTable, TripsCacheData>,
          ),
          TripsCacheData,
          PrefetchHooks Function()
        > {
  $$TripsCacheTableTableManager(_$AppDatabase db, $TripsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientTripId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> driverId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> tarih = const Value.absent(),
                Value<DateTime?> fabrikaCikisAt = const Value.absent(),
                Value<DateTime?> fabrikaGirisAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedLocallyAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCacheCompanion(
                clientTripId: clientTripId,
                serverId: serverId,
                driverId: driverId,
                vehicleId: vehicleId,
                tarih: tarih,
                fabrikaCikisAt: fabrikaCikisAt,
                fabrikaGirisAt: fabrikaGirisAt,
                synced: synced,
                retryCount: retryCount,
                lastError: lastError,
                updatedLocallyAt: updatedLocallyAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientTripId,
                Value<String?> serverId = const Value.absent(),
                required String driverId,
                required String vehicleId,
                required String tarih,
                Value<DateTime?> fabrikaCikisAt = const Value.absent(),
                Value<DateTime?> fabrikaGirisAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime updatedLocallyAt,
                Value<int> rowid = const Value.absent(),
              }) => TripsCacheCompanion.insert(
                clientTripId: clientTripId,
                serverId: serverId,
                driverId: driverId,
                vehicleId: vehicleId,
                tarih: tarih,
                fabrikaCikisAt: fabrikaCikisAt,
                fabrikaGirisAt: fabrikaGirisAt,
                synced: synced,
                retryCount: retryCount,
                lastError: lastError,
                updatedLocallyAt: updatedLocallyAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsCacheTable,
      TripsCacheData,
      $$TripsCacheTableFilterComposer,
      $$TripsCacheTableOrderingComposer,
      $$TripsCacheTableAnnotationComposer,
      $$TripsCacheTableCreateCompanionBuilder,
      $$TripsCacheTableUpdateCompanionBuilder,
      (
        TripsCacheData,
        BaseReferences<_$AppDatabase, $TripsCacheTable, TripsCacheData>,
      ),
      TripsCacheData,
      PrefetchHooks Function()
    >;
typedef $$TripStopsCacheTableCreateCompanionBuilder =
    TripStopsCacheCompanion Function({
      required String clientStopId,
      Value<String?> serverId,
      required String clientTripId,
      required int sira,
      required DateTime firmaGirisAt,
      Value<String?> tripTypeId,
      Value<String?> requesterId,
      Value<String?> cikisNedeni,
      Value<String?> gidilenIl,
      Value<String?> gidilenIlce,
      Value<String?> gidilenSirketId,
      Value<String?> gidilenSirketFree,
      Value<String?> irsaliyeNo,
      Value<DateTime?> firmaCikisAt,
      Value<String?> notlar,
      Value<bool> synced,
      Value<int> retryCount,
      Value<String?> lastError,
      required DateTime updatedLocallyAt,
      Value<int> rowid,
    });
typedef $$TripStopsCacheTableUpdateCompanionBuilder =
    TripStopsCacheCompanion Function({
      Value<String> clientStopId,
      Value<String?> serverId,
      Value<String> clientTripId,
      Value<int> sira,
      Value<DateTime> firmaGirisAt,
      Value<String?> tripTypeId,
      Value<String?> requesterId,
      Value<String?> cikisNedeni,
      Value<String?> gidilenIl,
      Value<String?> gidilenIlce,
      Value<String?> gidilenSirketId,
      Value<String?> gidilenSirketFree,
      Value<String?> irsaliyeNo,
      Value<DateTime?> firmaCikisAt,
      Value<String?> notlar,
      Value<bool> synced,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> updatedLocallyAt,
      Value<int> rowid,
    });

class $$TripStopsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TripStopsCacheTable> {
  $$TripStopsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientStopId => $composableBuilder(
    column: $table.clientStopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientTripId => $composableBuilder(
    column: $table.clientTripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sira => $composableBuilder(
    column: $table.sira,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firmaGirisAt => $composableBuilder(
    column: $table.firmaGirisAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripTypeId => $composableBuilder(
    column: $table.tripTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requesterId => $composableBuilder(
    column: $table.requesterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cikisNedeni => $composableBuilder(
    column: $table.cikisNedeni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gidilenIl => $composableBuilder(
    column: $table.gidilenIl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gidilenIlce => $composableBuilder(
    column: $table.gidilenIlce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gidilenSirketId => $composableBuilder(
    column: $table.gidilenSirketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gidilenSirketFree => $composableBuilder(
    column: $table.gidilenSirketFree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get irsaliyeNo => $composableBuilder(
    column: $table.irsaliyeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firmaCikisAt => $composableBuilder(
    column: $table.firmaCikisAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notlar => $composableBuilder(
    column: $table.notlar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedLocallyAt => $composableBuilder(
    column: $table.updatedLocallyAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripStopsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TripStopsCacheTable> {
  $$TripStopsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientStopId => $composableBuilder(
    column: $table.clientStopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientTripId => $composableBuilder(
    column: $table.clientTripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sira => $composableBuilder(
    column: $table.sira,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firmaGirisAt => $composableBuilder(
    column: $table.firmaGirisAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripTypeId => $composableBuilder(
    column: $table.tripTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requesterId => $composableBuilder(
    column: $table.requesterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cikisNedeni => $composableBuilder(
    column: $table.cikisNedeni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gidilenIl => $composableBuilder(
    column: $table.gidilenIl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gidilenIlce => $composableBuilder(
    column: $table.gidilenIlce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gidilenSirketId => $composableBuilder(
    column: $table.gidilenSirketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gidilenSirketFree => $composableBuilder(
    column: $table.gidilenSirketFree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get irsaliyeNo => $composableBuilder(
    column: $table.irsaliyeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firmaCikisAt => $composableBuilder(
    column: $table.firmaCikisAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notlar => $composableBuilder(
    column: $table.notlar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedLocallyAt => $composableBuilder(
    column: $table.updatedLocallyAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripStopsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripStopsCacheTable> {
  $$TripStopsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientStopId => $composableBuilder(
    column: $table.clientStopId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientTripId => $composableBuilder(
    column: $table.clientTripId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sira =>
      $composableBuilder(column: $table.sira, builder: (column) => column);

  GeneratedColumn<DateTime> get firmaGirisAt => $composableBuilder(
    column: $table.firmaGirisAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tripTypeId => $composableBuilder(
    column: $table.tripTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requesterId => $composableBuilder(
    column: $table.requesterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cikisNedeni => $composableBuilder(
    column: $table.cikisNedeni,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gidilenIl =>
      $composableBuilder(column: $table.gidilenIl, builder: (column) => column);

  GeneratedColumn<String> get gidilenIlce => $composableBuilder(
    column: $table.gidilenIlce,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gidilenSirketId => $composableBuilder(
    column: $table.gidilenSirketId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gidilenSirketFree => $composableBuilder(
    column: $table.gidilenSirketFree,
    builder: (column) => column,
  );

  GeneratedColumn<String> get irsaliyeNo => $composableBuilder(
    column: $table.irsaliyeNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firmaCikisAt => $composableBuilder(
    column: $table.firmaCikisAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notlar =>
      $composableBuilder(column: $table.notlar, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedLocallyAt => $composableBuilder(
    column: $table.updatedLocallyAt,
    builder: (column) => column,
  );
}

class $$TripStopsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripStopsCacheTable,
          TripStopsCacheData,
          $$TripStopsCacheTableFilterComposer,
          $$TripStopsCacheTableOrderingComposer,
          $$TripStopsCacheTableAnnotationComposer,
          $$TripStopsCacheTableCreateCompanionBuilder,
          $$TripStopsCacheTableUpdateCompanionBuilder,
          (
            TripStopsCacheData,
            BaseReferences<
              _$AppDatabase,
              $TripStopsCacheTable,
              TripStopsCacheData
            >,
          ),
          TripStopsCacheData,
          PrefetchHooks Function()
        > {
  $$TripStopsCacheTableTableManager(
    _$AppDatabase db,
    $TripStopsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripStopsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripStopsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripStopsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientStopId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> clientTripId = const Value.absent(),
                Value<int> sira = const Value.absent(),
                Value<DateTime> firmaGirisAt = const Value.absent(),
                Value<String?> tripTypeId = const Value.absent(),
                Value<String?> requesterId = const Value.absent(),
                Value<String?> cikisNedeni = const Value.absent(),
                Value<String?> gidilenIl = const Value.absent(),
                Value<String?> gidilenIlce = const Value.absent(),
                Value<String?> gidilenSirketId = const Value.absent(),
                Value<String?> gidilenSirketFree = const Value.absent(),
                Value<String?> irsaliyeNo = const Value.absent(),
                Value<DateTime?> firmaCikisAt = const Value.absent(),
                Value<String?> notlar = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedLocallyAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripStopsCacheCompanion(
                clientStopId: clientStopId,
                serverId: serverId,
                clientTripId: clientTripId,
                sira: sira,
                firmaGirisAt: firmaGirisAt,
                tripTypeId: tripTypeId,
                requesterId: requesterId,
                cikisNedeni: cikisNedeni,
                gidilenIl: gidilenIl,
                gidilenIlce: gidilenIlce,
                gidilenSirketId: gidilenSirketId,
                gidilenSirketFree: gidilenSirketFree,
                irsaliyeNo: irsaliyeNo,
                firmaCikisAt: firmaCikisAt,
                notlar: notlar,
                synced: synced,
                retryCount: retryCount,
                lastError: lastError,
                updatedLocallyAt: updatedLocallyAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientStopId,
                Value<String?> serverId = const Value.absent(),
                required String clientTripId,
                required int sira,
                required DateTime firmaGirisAt,
                Value<String?> tripTypeId = const Value.absent(),
                Value<String?> requesterId = const Value.absent(),
                Value<String?> cikisNedeni = const Value.absent(),
                Value<String?> gidilenIl = const Value.absent(),
                Value<String?> gidilenIlce = const Value.absent(),
                Value<String?> gidilenSirketId = const Value.absent(),
                Value<String?> gidilenSirketFree = const Value.absent(),
                Value<String?> irsaliyeNo = const Value.absent(),
                Value<DateTime?> firmaCikisAt = const Value.absent(),
                Value<String?> notlar = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime updatedLocallyAt,
                Value<int> rowid = const Value.absent(),
              }) => TripStopsCacheCompanion.insert(
                clientStopId: clientStopId,
                serverId: serverId,
                clientTripId: clientTripId,
                sira: sira,
                firmaGirisAt: firmaGirisAt,
                tripTypeId: tripTypeId,
                requesterId: requesterId,
                cikisNedeni: cikisNedeni,
                gidilenIl: gidilenIl,
                gidilenIlce: gidilenIlce,
                gidilenSirketId: gidilenSirketId,
                gidilenSirketFree: gidilenSirketFree,
                irsaliyeNo: irsaliyeNo,
                firmaCikisAt: firmaCikisAt,
                notlar: notlar,
                synced: synced,
                retryCount: retryCount,
                lastError: lastError,
                updatedLocallyAt: updatedLocallyAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripStopsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripStopsCacheTable,
      TripStopsCacheData,
      $$TripStopsCacheTableFilterComposer,
      $$TripStopsCacheTableOrderingComposer,
      $$TripStopsCacheTableAnnotationComposer,
      $$TripStopsCacheTableCreateCompanionBuilder,
      $$TripStopsCacheTableUpdateCompanionBuilder,
      (
        TripStopsCacheData,
        BaseReferences<_$AppDatabase, $TripStopsCacheTable, TripStopsCacheData>,
      ),
      TripStopsCacheData,
      PrefetchHooks Function()
    >;
typedef $$VehiclesCacheTableCreateCompanionBuilder =
    VehiclesCacheCompanion Function({
      required String id,
      required String plaka,
      Value<String?> aciklama,
      Value<bool> aktif,
      Value<int> rowid,
    });
typedef $$VehiclesCacheTableUpdateCompanionBuilder =
    VehiclesCacheCompanion Function({
      Value<String> id,
      Value<String> plaka,
      Value<String?> aciklama,
      Value<bool> aktif,
      Value<int> rowid,
    });

class $$VehiclesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesCacheTable> {
  $$VehiclesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plaka => $composableBuilder(
    column: $table.plaka,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aciklama => $composableBuilder(
    column: $table.aciklama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesCacheTable> {
  $$VehiclesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plaka => $composableBuilder(
    column: $table.plaka,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aciklama => $composableBuilder(
    column: $table.aciklama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesCacheTable> {
  $$VehiclesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plaka =>
      $composableBuilder(column: $table.plaka, builder: (column) => column);

  GeneratedColumn<String> get aciklama =>
      $composableBuilder(column: $table.aciklama, builder: (column) => column);

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);
}

class $$VehiclesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesCacheTable,
          VehiclesCacheData,
          $$VehiclesCacheTableFilterComposer,
          $$VehiclesCacheTableOrderingComposer,
          $$VehiclesCacheTableAnnotationComposer,
          $$VehiclesCacheTableCreateCompanionBuilder,
          $$VehiclesCacheTableUpdateCompanionBuilder,
          (
            VehiclesCacheData,
            BaseReferences<
              _$AppDatabase,
              $VehiclesCacheTable,
              VehiclesCacheData
            >,
          ),
          VehiclesCacheData,
          PrefetchHooks Function()
        > {
  $$VehiclesCacheTableTableManager(_$AppDatabase db, $VehiclesCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plaka = const Value.absent(),
                Value<String?> aciklama = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCacheCompanion(
                id: id,
                plaka: plaka,
                aciklama: aciklama,
                aktif: aktif,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plaka,
                Value<String?> aciklama = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCacheCompanion.insert(
                id: id,
                plaka: plaka,
                aciklama: aciklama,
                aktif: aktif,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesCacheTable,
      VehiclesCacheData,
      $$VehiclesCacheTableFilterComposer,
      $$VehiclesCacheTableOrderingComposer,
      $$VehiclesCacheTableAnnotationComposer,
      $$VehiclesCacheTableCreateCompanionBuilder,
      $$VehiclesCacheTableUpdateCompanionBuilder,
      (
        VehiclesCacheData,
        BaseReferences<_$AppDatabase, $VehiclesCacheTable, VehiclesCacheData>,
      ),
      VehiclesCacheData,
      PrefetchHooks Function()
    >;
typedef $$TripTypesCacheTableCreateCompanionBuilder =
    TripTypesCacheCompanion Function({
      required String id,
      required String code,
      required String label,
      Value<bool> requiresIrsaliye,
      Value<int> sira,
      Value<bool> aktif,
      Value<int> rowid,
    });
typedef $$TripTypesCacheTableUpdateCompanionBuilder =
    TripTypesCacheCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> label,
      Value<bool> requiresIrsaliye,
      Value<int> sira,
      Value<bool> aktif,
      Value<int> rowid,
    });

class $$TripTypesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TripTypesCacheTable> {
  $$TripTypesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresIrsaliye => $composableBuilder(
    column: $table.requiresIrsaliye,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sira => $composableBuilder(
    column: $table.sira,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripTypesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TripTypesCacheTable> {
  $$TripTypesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresIrsaliye => $composableBuilder(
    column: $table.requiresIrsaliye,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sira => $composableBuilder(
    column: $table.sira,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripTypesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripTypesCacheTable> {
  $$TripTypesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get requiresIrsaliye => $composableBuilder(
    column: $table.requiresIrsaliye,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sira =>
      $composableBuilder(column: $table.sira, builder: (column) => column);

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);
}

class $$TripTypesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripTypesCacheTable,
          TripTypesCacheData,
          $$TripTypesCacheTableFilterComposer,
          $$TripTypesCacheTableOrderingComposer,
          $$TripTypesCacheTableAnnotationComposer,
          $$TripTypesCacheTableCreateCompanionBuilder,
          $$TripTypesCacheTableUpdateCompanionBuilder,
          (
            TripTypesCacheData,
            BaseReferences<
              _$AppDatabase,
              $TripTypesCacheTable,
              TripTypesCacheData
            >,
          ),
          TripTypesCacheData,
          PrefetchHooks Function()
        > {
  $$TripTypesCacheTableTableManager(
    _$AppDatabase db,
    $TripTypesCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripTypesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripTypesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripTypesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<bool> requiresIrsaliye = const Value.absent(),
                Value<int> sira = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripTypesCacheCompanion(
                id: id,
                code: code,
                label: label,
                requiresIrsaliye: requiresIrsaliye,
                sira: sira,
                aktif: aktif,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String label,
                Value<bool> requiresIrsaliye = const Value.absent(),
                Value<int> sira = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripTypesCacheCompanion.insert(
                id: id,
                code: code,
                label: label,
                requiresIrsaliye: requiresIrsaliye,
                sira: sira,
                aktif: aktif,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripTypesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripTypesCacheTable,
      TripTypesCacheData,
      $$TripTypesCacheTableFilterComposer,
      $$TripTypesCacheTableOrderingComposer,
      $$TripTypesCacheTableAnnotationComposer,
      $$TripTypesCacheTableCreateCompanionBuilder,
      $$TripTypesCacheTableUpdateCompanionBuilder,
      (
        TripTypesCacheData,
        BaseReferences<_$AppDatabase, $TripTypesCacheTable, TripTypesCacheData>,
      ),
      TripTypesCacheData,
      PrefetchHooks Function()
    >;
typedef $$RequestersCacheTableCreateCompanionBuilder =
    RequestersCacheCompanion Function({
      required String id,
      required String fullName,
      Value<bool> aktif,
      Value<int> rowid,
    });
typedef $$RequestersCacheTableUpdateCompanionBuilder =
    RequestersCacheCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<bool> aktif,
      Value<int> rowid,
    });

class $$RequestersCacheTableFilterComposer
    extends Composer<_$AppDatabase, $RequestersCacheTable> {
  $$RequestersCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestersCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestersCacheTable> {
  $$RequestersCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestersCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestersCacheTable> {
  $$RequestersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);
}

class $$RequestersCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestersCacheTable,
          RequestersCacheData,
          $$RequestersCacheTableFilterComposer,
          $$RequestersCacheTableOrderingComposer,
          $$RequestersCacheTableAnnotationComposer,
          $$RequestersCacheTableCreateCompanionBuilder,
          $$RequestersCacheTableUpdateCompanionBuilder,
          (
            RequestersCacheData,
            BaseReferences<
              _$AppDatabase,
              $RequestersCacheTable,
              RequestersCacheData
            >,
          ),
          RequestersCacheData,
          PrefetchHooks Function()
        > {
  $$RequestersCacheTableTableManager(
    _$AppDatabase db,
    $RequestersCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestersCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestersCacheCompanion(
                id: id,
                fullName: fullName,
                aktif: aktif,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestersCacheCompanion.insert(
                id: id,
                fullName: fullName,
                aktif: aktif,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestersCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestersCacheTable,
      RequestersCacheData,
      $$RequestersCacheTableFilterComposer,
      $$RequestersCacheTableOrderingComposer,
      $$RequestersCacheTableAnnotationComposer,
      $$RequestersCacheTableCreateCompanionBuilder,
      $$RequestersCacheTableUpdateCompanionBuilder,
      (
        RequestersCacheData,
        BaseReferences<
          _$AppDatabase,
          $RequestersCacheTable,
          RequestersCacheData
        >,
      ),
      RequestersCacheData,
      PrefetchHooks Function()
    >;
typedef $$CompaniesCacheTableCreateCompanionBuilder =
    CompaniesCacheCompanion Function({
      required String id,
      required String name,
      Value<String?> sehir,
      Value<bool> aktif,
      Value<int> rowid,
    });
typedef $$CompaniesCacheTableUpdateCompanionBuilder =
    CompaniesCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> sehir,
      Value<bool> aktif,
      Value<int> rowid,
    });

class $$CompaniesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesCacheTable> {
  $$CompaniesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sehir => $composableBuilder(
    column: $table.sehir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompaniesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesCacheTable> {
  $$CompaniesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sehir => $composableBuilder(
    column: $table.sehir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesCacheTable> {
  $$CompaniesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sehir =>
      $composableBuilder(column: $table.sehir, builder: (column) => column);

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);
}

class $$CompaniesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesCacheTable,
          CompaniesCacheData,
          $$CompaniesCacheTableFilterComposer,
          $$CompaniesCacheTableOrderingComposer,
          $$CompaniesCacheTableAnnotationComposer,
          $$CompaniesCacheTableCreateCompanionBuilder,
          $$CompaniesCacheTableUpdateCompanionBuilder,
          (
            CompaniesCacheData,
            BaseReferences<
              _$AppDatabase,
              $CompaniesCacheTable,
              CompaniesCacheData
            >,
          ),
          CompaniesCacheData,
          PrefetchHooks Function()
        > {
  $$CompaniesCacheTableTableManager(
    _$AppDatabase db,
    $CompaniesCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sehir = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCacheCompanion(
                id: id,
                name: name,
                sehir: sehir,
                aktif: aktif,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> sehir = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCacheCompanion.insert(
                id: id,
                name: name,
                sehir: sehir,
                aktif: aktif,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompaniesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesCacheTable,
      CompaniesCacheData,
      $$CompaniesCacheTableFilterComposer,
      $$CompaniesCacheTableOrderingComposer,
      $$CompaniesCacheTableAnnotationComposer,
      $$CompaniesCacheTableCreateCompanionBuilder,
      $$CompaniesCacheTableUpdateCompanionBuilder,
      (
        CompaniesCacheData,
        BaseReferences<_$AppDatabase, $CompaniesCacheTable, CompaniesCacheData>,
      ),
      CompaniesCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsCacheTableTableManager get tripsCache =>
      $$TripsCacheTableTableManager(_db, _db.tripsCache);
  $$TripStopsCacheTableTableManager get tripStopsCache =>
      $$TripStopsCacheTableTableManager(_db, _db.tripStopsCache);
  $$VehiclesCacheTableTableManager get vehiclesCache =>
      $$VehiclesCacheTableTableManager(_db, _db.vehiclesCache);
  $$TripTypesCacheTableTableManager get tripTypesCache =>
      $$TripTypesCacheTableTableManager(_db, _db.tripTypesCache);
  $$RequestersCacheTableTableManager get requestersCache =>
      $$RequestersCacheTableTableManager(_db, _db.requestersCache);
  $$CompaniesCacheTableTableManager get companiesCache =>
      $$CompaniesCacheTableTableManager(_db, _db.companiesCache);
}
