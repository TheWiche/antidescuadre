// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// ignore_for_file: type=lint
class $TurnosTable extends Turnos with TableInfo<$TurnosTable, Turno> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finMeta = const VerificationMeta('fin');
  @override
  late final GeneratedColumn<DateTime> fin = GeneratedColumn<DateTime>(
    'fin',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('activo'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, inicio, fin, estado];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turnos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Turno> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fin')) {
      context.handle(
        _finMeta,
        fin.isAcceptableOrUnknown(data['fin']!, _finMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Turno map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Turno(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fin'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $TurnosTable createAlias(String alias) {
    return $TurnosTable(attachedDatabase, alias);
  }
}

class Turno extends DataClass implements Insertable<Turno> {
  final int id;
  final DateTime inicio;
  final DateTime? fin;
  final String estado;
  const Turno({
    required this.id,
    required this.inicio,
    this.fin,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['inicio'] = Variable<DateTime>(inicio);
    if (!nullToAbsent || fin != null) {
      map['fin'] = Variable<DateTime>(fin);
    }
    map['estado'] = Variable<String>(estado);
    return map;
  }

  TurnosCompanion toCompanion(bool nullToAbsent) {
    return TurnosCompanion(
      id: Value(id),
      inicio: Value(inicio),
      fin: fin == null && nullToAbsent ? const Value.absent() : Value(fin),
      estado: Value(estado),
    );
  }

  factory Turno.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Turno(
      id: serializer.fromJson<int>(json['id']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fin: serializer.fromJson<DateTime?>(json['fin']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'inicio': serializer.toJson<DateTime>(inicio),
      'fin': serializer.toJson<DateTime?>(fin),
      'estado': serializer.toJson<String>(estado),
    };
  }

  Turno copyWith({
    int? id,
    DateTime? inicio,
    Value<DateTime?> fin = const Value.absent(),
    String? estado,
  }) => Turno(
    id: id ?? this.id,
    inicio: inicio ?? this.inicio,
    fin: fin.present ? fin.value : this.fin,
    estado: estado ?? this.estado,
  );
  Turno copyWithCompanion(TurnosCompanion data) {
    return Turno(
      id: data.id.present ? data.id.value : this.id,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fin: data.fin.present ? data.fin.value : this.fin,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Turno(')
          ..write('id: $id, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, inicio, fin, estado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Turno &&
          other.id == this.id &&
          other.inicio == this.inicio &&
          other.fin == this.fin &&
          other.estado == this.estado);
}

class TurnosCompanion extends UpdateCompanion<Turno> {
  final Value<int> id;
  final Value<DateTime> inicio;
  final Value<DateTime?> fin;
  final Value<String> estado;
  const TurnosCompanion({
    this.id = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fin = const Value.absent(),
    this.estado = const Value.absent(),
  });
  TurnosCompanion.insert({
    this.id = const Value.absent(),
    required DateTime inicio,
    this.fin = const Value.absent(),
    this.estado = const Value.absent(),
  }) : inicio = Value(inicio);
  static Insertable<Turno> custom({
    Expression<int>? id,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fin,
    Expression<String>? estado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inicio != null) 'inicio': inicio,
      if (fin != null) 'fin': fin,
      if (estado != null) 'estado': estado,
    });
  }

  TurnosCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? inicio,
    Value<DateTime?>? fin,
    Value<String>? estado,
  }) {
    return TurnosCompanion(
      id: id ?? this.id,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      estado: estado ?? this.estado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fin.present) {
      map['fin'] = Variable<DateTime>(fin.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnosCompanion(')
          ..write('id: $id, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }
}

class $MesasTable extends Mesas with TableInfo<$MesasTable, Mesa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MesasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, alias, orden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mesas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mesa> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mesa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mesa(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
    );
  }

  @override
  $MesasTable createAlias(String alias) {
    return $MesasTable(attachedDatabase, alias);
  }
}

class Mesa extends DataClass implements Insertable<Mesa> {
  final int id;
  final String alias;
  final int orden;
  const Mesa({required this.id, required this.alias, required this.orden});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alias'] = Variable<String>(alias);
    map['orden'] = Variable<int>(orden);
    return map;
  }

  MesasCompanion toCompanion(bool nullToAbsent) {
    return MesasCompanion(
      id: Value(id),
      alias: Value(alias),
      orden: Value(orden),
    );
  }

  factory Mesa.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mesa(
      id: serializer.fromJson<int>(json['id']),
      alias: serializer.fromJson<String>(json['alias']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alias': serializer.toJson<String>(alias),
      'orden': serializer.toJson<int>(orden),
    };
  }

  Mesa copyWith({int? id, String? alias, int? orden}) => Mesa(
    id: id ?? this.id,
    alias: alias ?? this.alias,
    orden: orden ?? this.orden,
  );
  Mesa copyWithCompanion(MesasCompanion data) {
    return Mesa(
      id: data.id.present ? data.id.value : this.id,
      alias: data.alias.present ? data.alias.value : this.alias,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mesa(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alias, orden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mesa &&
          other.id == this.id &&
          other.alias == this.alias &&
          other.orden == this.orden);
}

class MesasCompanion extends UpdateCompanion<Mesa> {
  final Value<int> id;
  final Value<String> alias;
  final Value<int> orden;
  const MesasCompanion({
    this.id = const Value.absent(),
    this.alias = const Value.absent(),
    this.orden = const Value.absent(),
  });
  MesasCompanion.insert({
    this.id = const Value.absent(),
    required String alias,
    this.orden = const Value.absent(),
  }) : alias = Value(alias);
  static Insertable<Mesa> custom({
    Expression<int>? id,
    Expression<String>? alias,
    Expression<int>? orden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alias != null) 'alias': alias,
      if (orden != null) 'orden': orden,
    });
  }

  MesasCompanion copyWith({
    Value<int>? id,
    Value<String>? alias,
    Value<int>? orden,
  }) {
    return MesasCompanion(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MesasCompanion(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _padreIdMeta = const VerificationMeta(
    'padreId',
  );
  @override
  late final GeneratedColumn<int> padreId = GeneratedColumn<int>(
    'padre_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, padreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('padre_id')) {
      context.handle(
        _padreIdMeta,
        padreId.isAcceptableOrUnknown(data['padre_id']!, _padreIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      padreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}padre_id'],
      ),
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nombre;
  final int? padreId;
  const Categoria({required this.id, required this.nombre, this.padreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || padreId != null) {
      map['padre_id'] = Variable<int>(padreId);
    }
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      padreId: padreId == null && nullToAbsent
          ? const Value.absent()
          : Value(padreId),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      padreId: serializer.fromJson<int?>(json['padreId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'padreId': serializer.toJson<int?>(padreId),
    };
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    Value<int?> padreId = const Value.absent(),
  }) => Categoria(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    padreId: padreId.present ? padreId.value : this.padreId,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      padreId: data.padreId.present ? data.padreId.value : this.padreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('padreId: $padreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, padreId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.padreId == this.padreId);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<int?> padreId;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.padreId = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.padreId = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<int>? padreId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (padreId != null) 'padre_id': padreId,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<int?>? padreId,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      padreId: padreId ?? this.padreId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (padreId.present) {
      map['padre_id'] = Variable<int>(padreId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('padreId: $padreId')
          ..write(')'))
        .toString();
  }
}

class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
    'precio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _gruposJsonMeta = const VerificationMeta(
    'gruposJson',
  );
  @override
  late final GeneratedColumn<String> gruposJson = GeneratedColumn<String>(
    'grupos_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    precio,
    categoriaId,
    activo,
    gruposJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(
        _precioMeta,
        precio.isAcceptableOrUnknown(data['precio']!, _precioMeta),
      );
    } else if (isInserting) {
      context.missing(_precioMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('grupos_json')) {
      context.handle(
        _gruposJsonMeta,
        gruposJson.isAcceptableOrUnknown(data['grupos_json']!, _gruposJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      precio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      gruposJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grupos_json'],
      )!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final int id;
  final String nombre;
  final double precio;
  final int? categoriaId;
  final bool activo;
  final String gruposJson;
  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.categoriaId,
    required this.activo,
    required this.gruposJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['precio'] = Variable<double>(precio);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    map['activo'] = Variable<bool>(activo);
    map['grupos_json'] = Variable<String>(gruposJson);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      precio: Value(precio),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      activo: Value(activo),
      gruposJson: Value(gruposJson),
    );
  }

  factory Producto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precio: serializer.fromJson<double>(json['precio']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      activo: serializer.fromJson<bool>(json['activo']),
      gruposJson: serializer.fromJson<String>(json['gruposJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'precio': serializer.toJson<double>(precio),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'activo': serializer.toJson<bool>(activo),
      'gruposJson': serializer.toJson<String>(gruposJson),
    };
  }

  Producto copyWith({
    int? id,
    String? nombre,
    double? precio,
    Value<int?> categoriaId = const Value.absent(),
    bool? activo,
    String? gruposJson,
  }) => Producto(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    precio: precio ?? this.precio,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    activo: activo ?? this.activo,
    gruposJson: gruposJson ?? this.gruposJson,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precio: data.precio.present ? data.precio.value : this.precio,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      activo: data.activo.present ? data.activo.value : this.activo,
      gruposJson: data.gruposJson.present
          ? data.gruposJson.value
          : this.gruposJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precio: $precio, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('activo: $activo, ')
          ..write('gruposJson: $gruposJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, precio, categoriaId, activo, gruposJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.precio == this.precio &&
          other.categoriaId == this.categoriaId &&
          other.activo == this.activo &&
          other.gruposJson == this.gruposJson);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<double> precio;
  final Value<int?> categoriaId;
  final Value<bool> activo;
  final Value<String> gruposJson;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precio = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.activo = const Value.absent(),
    this.gruposJson = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required double precio,
    this.categoriaId = const Value.absent(),
    this.activo = const Value.absent(),
    this.gruposJson = const Value.absent(),
  }) : nombre = Value(nombre),
       precio = Value(precio);
  static Insertable<Producto> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<double>? precio,
    Expression<int>? categoriaId,
    Expression<bool>? activo,
    Expression<String>? gruposJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (precio != null) 'precio': precio,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (activo != null) 'activo': activo,
      if (gruposJson != null) 'grupos_json': gruposJson,
    });
  }

  ProductosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<double>? precio,
    Value<int?>? categoriaId,
    Value<bool>? activo,
    Value<String>? gruposJson,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      categoriaId: categoriaId ?? this.categoriaId,
      activo: activo ?? this.activo,
      gruposJson: gruposJson ?? this.gruposJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (gruposJson.present) {
      map['grupos_json'] = Variable<String>(gruposJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('precio: $precio, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('activo: $activo, ')
          ..write('gruposJson: $gruposJson')
          ..write(')'))
        .toString();
  }
}

class $CuentasTable extends Cuentas with TableInfo<$CuentasTable, Cuenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mesaIdMeta = const VerificationMeta('mesaId');
  @override
  late final GeneratedColumn<int> mesaId = GeneratedColumn<int>(
    'mesa_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _turnoIdMeta = const VerificationMeta(
    'turnoId',
  );
  @override
  late final GeneratedColumn<int> turnoId = GeneratedColumn<int>(
    'turno_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('abierta'),
  );
  static const VerificationMeta _abiertaEnMeta = const VerificationMeta(
    'abiertaEn',
  );
  @override
  late final GeneratedColumn<DateTime> abiertaEn = GeneratedColumn<DateTime>(
    'abierta_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cerradaEnMeta = const VerificationMeta(
    'cerradaEn',
  );
  @override
  late final GeneratedColumn<DateTime> cerradaEn = GeneratedColumn<DateTime>(
    'cerrada_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mesaId,
    turnoId,
    estado,
    abiertaEn,
    cerradaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuentas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cuenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mesa_id')) {
      context.handle(
        _mesaIdMeta,
        mesaId.isAcceptableOrUnknown(data['mesa_id']!, _mesaIdMeta),
      );
    }
    if (data.containsKey('turno_id')) {
      context.handle(
        _turnoIdMeta,
        turnoId.isAcceptableOrUnknown(data['turno_id']!, _turnoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_turnoIdMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('abierta_en')) {
      context.handle(
        _abiertaEnMeta,
        abiertaEn.isAcceptableOrUnknown(data['abierta_en']!, _abiertaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_abiertaEnMeta);
    }
    if (data.containsKey('cerrada_en')) {
      context.handle(
        _cerradaEnMeta,
        cerradaEn.isAcceptableOrUnknown(data['cerrada_en']!, _cerradaEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cuenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cuenta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mesaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mesa_id'],
      ),
      turnoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turno_id'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      abiertaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}abierta_en'],
      )!,
      cerradaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cerrada_en'],
      ),
    );
  }

  @override
  $CuentasTable createAlias(String alias) {
    return $CuentasTable(attachedDatabase, alias);
  }
}

class Cuenta extends DataClass implements Insertable<Cuenta> {
  final int id;
  final int? mesaId;
  final int turnoId;
  final String estado;
  final DateTime abiertaEn;
  final DateTime? cerradaEn;
  const Cuenta({
    required this.id,
    this.mesaId,
    required this.turnoId,
    required this.estado,
    required this.abiertaEn,
    this.cerradaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || mesaId != null) {
      map['mesa_id'] = Variable<int>(mesaId);
    }
    map['turno_id'] = Variable<int>(turnoId);
    map['estado'] = Variable<String>(estado);
    map['abierta_en'] = Variable<DateTime>(abiertaEn);
    if (!nullToAbsent || cerradaEn != null) {
      map['cerrada_en'] = Variable<DateTime>(cerradaEn);
    }
    return map;
  }

  CuentasCompanion toCompanion(bool nullToAbsent) {
    return CuentasCompanion(
      id: Value(id),
      mesaId: mesaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaId),
      turnoId: Value(turnoId),
      estado: Value(estado),
      abiertaEn: Value(abiertaEn),
      cerradaEn: cerradaEn == null && nullToAbsent
          ? const Value.absent()
          : Value(cerradaEn),
    );
  }

  factory Cuenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cuenta(
      id: serializer.fromJson<int>(json['id']),
      mesaId: serializer.fromJson<int?>(json['mesaId']),
      turnoId: serializer.fromJson<int>(json['turnoId']),
      estado: serializer.fromJson<String>(json['estado']),
      abiertaEn: serializer.fromJson<DateTime>(json['abiertaEn']),
      cerradaEn: serializer.fromJson<DateTime?>(json['cerradaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mesaId': serializer.toJson<int?>(mesaId),
      'turnoId': serializer.toJson<int>(turnoId),
      'estado': serializer.toJson<String>(estado),
      'abiertaEn': serializer.toJson<DateTime>(abiertaEn),
      'cerradaEn': serializer.toJson<DateTime?>(cerradaEn),
    };
  }

  Cuenta copyWith({
    int? id,
    Value<int?> mesaId = const Value.absent(),
    int? turnoId,
    String? estado,
    DateTime? abiertaEn,
    Value<DateTime?> cerradaEn = const Value.absent(),
  }) => Cuenta(
    id: id ?? this.id,
    mesaId: mesaId.present ? mesaId.value : this.mesaId,
    turnoId: turnoId ?? this.turnoId,
    estado: estado ?? this.estado,
    abiertaEn: abiertaEn ?? this.abiertaEn,
    cerradaEn: cerradaEn.present ? cerradaEn.value : this.cerradaEn,
  );
  Cuenta copyWithCompanion(CuentasCompanion data) {
    return Cuenta(
      id: data.id.present ? data.id.value : this.id,
      mesaId: data.mesaId.present ? data.mesaId.value : this.mesaId,
      turnoId: data.turnoId.present ? data.turnoId.value : this.turnoId,
      estado: data.estado.present ? data.estado.value : this.estado,
      abiertaEn: data.abiertaEn.present ? data.abiertaEn.value : this.abiertaEn,
      cerradaEn: data.cerradaEn.present ? data.cerradaEn.value : this.cerradaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cuenta(')
          ..write('id: $id, ')
          ..write('mesaId: $mesaId, ')
          ..write('turnoId: $turnoId, ')
          ..write('estado: $estado, ')
          ..write('abiertaEn: $abiertaEn, ')
          ..write('cerradaEn: $cerradaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mesaId, turnoId, estado, abiertaEn, cerradaEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cuenta &&
          other.id == this.id &&
          other.mesaId == this.mesaId &&
          other.turnoId == this.turnoId &&
          other.estado == this.estado &&
          other.abiertaEn == this.abiertaEn &&
          other.cerradaEn == this.cerradaEn);
}

class CuentasCompanion extends UpdateCompanion<Cuenta> {
  final Value<int> id;
  final Value<int?> mesaId;
  final Value<int> turnoId;
  final Value<String> estado;
  final Value<DateTime> abiertaEn;
  final Value<DateTime?> cerradaEn;
  const CuentasCompanion({
    this.id = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.turnoId = const Value.absent(),
    this.estado = const Value.absent(),
    this.abiertaEn = const Value.absent(),
    this.cerradaEn = const Value.absent(),
  });
  CuentasCompanion.insert({
    this.id = const Value.absent(),
    this.mesaId = const Value.absent(),
    required int turnoId,
    this.estado = const Value.absent(),
    required DateTime abiertaEn,
    this.cerradaEn = const Value.absent(),
  }) : turnoId = Value(turnoId),
       abiertaEn = Value(abiertaEn);
  static Insertable<Cuenta> custom({
    Expression<int>? id,
    Expression<int>? mesaId,
    Expression<int>? turnoId,
    Expression<String>? estado,
    Expression<DateTime>? abiertaEn,
    Expression<DateTime>? cerradaEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mesaId != null) 'mesa_id': mesaId,
      if (turnoId != null) 'turno_id': turnoId,
      if (estado != null) 'estado': estado,
      if (abiertaEn != null) 'abierta_en': abiertaEn,
      if (cerradaEn != null) 'cerrada_en': cerradaEn,
    });
  }

  CuentasCompanion copyWith({
    Value<int>? id,
    Value<int?>? mesaId,
    Value<int>? turnoId,
    Value<String>? estado,
    Value<DateTime>? abiertaEn,
    Value<DateTime?>? cerradaEn,
  }) {
    return CuentasCompanion(
      id: id ?? this.id,
      mesaId: mesaId ?? this.mesaId,
      turnoId: turnoId ?? this.turnoId,
      estado: estado ?? this.estado,
      abiertaEn: abiertaEn ?? this.abiertaEn,
      cerradaEn: cerradaEn ?? this.cerradaEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mesaId.present) {
      map['mesa_id'] = Variable<int>(mesaId.value);
    }
    if (turnoId.present) {
      map['turno_id'] = Variable<int>(turnoId.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (abiertaEn.present) {
      map['abierta_en'] = Variable<DateTime>(abiertaEn.value);
    }
    if (cerradaEn.present) {
      map['cerrada_en'] = Variable<DateTime>(cerradaEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuentasCompanion(')
          ..write('id: $id, ')
          ..write('mesaId: $mesaId, ')
          ..write('turnoId: $turnoId, ')
          ..write('estado: $estado, ')
          ..write('abiertaEn: $abiertaEn, ')
          ..write('cerradaEn: $cerradaEn')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cuentaIdMeta = const VerificationMeta(
    'cuentaId',
  );
  @override
  late final GeneratedColumn<int> cuentaId = GeneratedColumn<int>(
    'cuenta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantesJsonMeta = const VerificationMeta(
    'variantesJson',
  );
  @override
  late final GeneratedColumn<String> variantesJson = GeneratedColumn<String>(
    'variantes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendiente'),
  );
  static const VerificationMeta _agregadoEnMeta = const VerificationMeta(
    'agregadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> agregadoEn = GeneratedColumn<DateTime>(
    'agregado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entregadoEnMeta = const VerificationMeta(
    'entregadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> entregadoEn = GeneratedColumn<DateTime>(
    'entregado_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tandaIdMeta = const VerificationMeta(
    'tandaId',
  );
  @override
  late final GeneratedColumn<int> tandaId = GeneratedColumn<int>(
    'tanda_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parteIdMeta = const VerificationMeta(
    'parteId',
  );
  @override
  late final GeneratedColumn<String> parteId = GeneratedColumn<String>(
    'parte_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuentaId,
    productoId,
    nombre,
    variantesJson,
    cantidad,
    precioUnitario,
    estado,
    agregadoEn,
    entregadoEn,
    tandaId,
    parteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cuenta_id')) {
      context.handle(
        _cuentaIdMeta,
        cuentaId.isAcceptableOrUnknown(data['cuenta_id']!, _cuentaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuentaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('variantes_json')) {
      context.handle(
        _variantesJsonMeta,
        variantesJson.isAcceptableOrUnknown(
          data['variantes_json']!,
          _variantesJsonMeta,
        ),
      );
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('agregado_en')) {
      context.handle(
        _agregadoEnMeta,
        agregadoEn.isAcceptableOrUnknown(data['agregado_en']!, _agregadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_agregadoEnMeta);
    }
    if (data.containsKey('entregado_en')) {
      context.handle(
        _entregadoEnMeta,
        entregadoEn.isAcceptableOrUnknown(
          data['entregado_en']!,
          _entregadoEnMeta,
        ),
      );
    }
    if (data.containsKey('tanda_id')) {
      context.handle(
        _tandaIdMeta,
        tandaId.isAcceptableOrUnknown(data['tanda_id']!, _tandaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tandaIdMeta);
    }
    if (data.containsKey('parte_id')) {
      context.handle(
        _parteIdMeta,
        parteId.isAcceptableOrUnknown(data['parte_id']!, _parteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cuentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cuenta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      variantesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variantes_json'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      agregadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}agregado_en'],
      )!,
      entregadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entregado_en'],
      ),
      tandaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tanda_id'],
      )!,
      parteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parte_id'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final int cuentaId;
  final int? productoId;
  final String nombre;
  final String variantesJson;
  final int cantidad;
  final double precioUnitario;
  final String estado;
  final DateTime agregadoEn;
  final DateTime? entregadoEn;
  final int tandaId;
  final String? parteId;
  const Item({
    required this.id,
    required this.cuentaId,
    this.productoId,
    required this.nombre,
    required this.variantesJson,
    required this.cantidad,
    required this.precioUnitario,
    required this.estado,
    required this.agregadoEn,
    this.entregadoEn,
    required this.tandaId,
    this.parteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cuenta_id'] = Variable<int>(cuentaId);
    if (!nullToAbsent || productoId != null) {
      map['producto_id'] = Variable<int>(productoId);
    }
    map['nombre'] = Variable<String>(nombre);
    map['variantes_json'] = Variable<String>(variantesJson);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['estado'] = Variable<String>(estado);
    map['agregado_en'] = Variable<DateTime>(agregadoEn);
    if (!nullToAbsent || entregadoEn != null) {
      map['entregado_en'] = Variable<DateTime>(entregadoEn);
    }
    map['tanda_id'] = Variable<int>(tandaId);
    if (!nullToAbsent || parteId != null) {
      map['parte_id'] = Variable<String>(parteId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      cuentaId: Value(cuentaId),
      productoId: productoId == null && nullToAbsent
          ? const Value.absent()
          : Value(productoId),
      nombre: Value(nombre),
      variantesJson: Value(variantesJson),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      estado: Value(estado),
      agregadoEn: Value(agregadoEn),
      entregadoEn: entregadoEn == null && nullToAbsent
          ? const Value.absent()
          : Value(entregadoEn),
      tandaId: Value(tandaId),
      parteId: parteId == null && nullToAbsent
          ? const Value.absent()
          : Value(parteId),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      cuentaId: serializer.fromJson<int>(json['cuentaId']),
      productoId: serializer.fromJson<int?>(json['productoId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      variantesJson: serializer.fromJson<String>(json['variantesJson']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      estado: serializer.fromJson<String>(json['estado']),
      agregadoEn: serializer.fromJson<DateTime>(json['agregadoEn']),
      entregadoEn: serializer.fromJson<DateTime?>(json['entregadoEn']),
      tandaId: serializer.fromJson<int>(json['tandaId']),
      parteId: serializer.fromJson<String?>(json['parteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cuentaId': serializer.toJson<int>(cuentaId),
      'productoId': serializer.toJson<int?>(productoId),
      'nombre': serializer.toJson<String>(nombre),
      'variantesJson': serializer.toJson<String>(variantesJson),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'estado': serializer.toJson<String>(estado),
      'agregadoEn': serializer.toJson<DateTime>(agregadoEn),
      'entregadoEn': serializer.toJson<DateTime?>(entregadoEn),
      'tandaId': serializer.toJson<int>(tandaId),
      'parteId': serializer.toJson<String?>(parteId),
    };
  }

  Item copyWith({
    int? id,
    int? cuentaId,
    Value<int?> productoId = const Value.absent(),
    String? nombre,
    String? variantesJson,
    int? cantidad,
    double? precioUnitario,
    String? estado,
    DateTime? agregadoEn,
    Value<DateTime?> entregadoEn = const Value.absent(),
    int? tandaId,
    Value<String?> parteId = const Value.absent(),
  }) => Item(
    id: id ?? this.id,
    cuentaId: cuentaId ?? this.cuentaId,
    productoId: productoId.present ? productoId.value : this.productoId,
    nombre: nombre ?? this.nombre,
    variantesJson: variantesJson ?? this.variantesJson,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    estado: estado ?? this.estado,
    agregadoEn: agregadoEn ?? this.agregadoEn,
    entregadoEn: entregadoEn.present ? entregadoEn.value : this.entregadoEn,
    tandaId: tandaId ?? this.tandaId,
    parteId: parteId.present ? parteId.value : this.parteId,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      cuentaId: data.cuentaId.present ? data.cuentaId.value : this.cuentaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      variantesJson: data.variantesJson.present
          ? data.variantesJson.value
          : this.variantesJson,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      estado: data.estado.present ? data.estado.value : this.estado,
      agregadoEn: data.agregadoEn.present
          ? data.agregadoEn.value
          : this.agregadoEn,
      entregadoEn: data.entregadoEn.present
          ? data.entregadoEn.value
          : this.entregadoEn,
      tandaId: data.tandaId.present ? data.tandaId.value : this.tandaId,
      parteId: data.parteId.present ? data.parteId.value : this.parteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombre: $nombre, ')
          ..write('variantesJson: $variantesJson, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('estado: $estado, ')
          ..write('agregadoEn: $agregadoEn, ')
          ..write('entregadoEn: $entregadoEn, ')
          ..write('tandaId: $tandaId, ')
          ..write('parteId: $parteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cuentaId,
    productoId,
    nombre,
    variantesJson,
    cantidad,
    precioUnitario,
    estado,
    agregadoEn,
    entregadoEn,
    tandaId,
    parteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.cuentaId == this.cuentaId &&
          other.productoId == this.productoId &&
          other.nombre == this.nombre &&
          other.variantesJson == this.variantesJson &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.estado == this.estado &&
          other.agregadoEn == this.agregadoEn &&
          other.entregadoEn == this.entregadoEn &&
          other.tandaId == this.tandaId &&
          other.parteId == this.parteId);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<int> cuentaId;
  final Value<int?> productoId;
  final Value<String> nombre;
  final Value<String> variantesJson;
  final Value<int> cantidad;
  final Value<double> precioUnitario;
  final Value<String> estado;
  final Value<DateTime> agregadoEn;
  final Value<DateTime?> entregadoEn;
  final Value<int> tandaId;
  final Value<String?> parteId;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.variantesJson = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.estado = const Value.absent(),
    this.agregadoEn = const Value.absent(),
    this.entregadoEn = const Value.absent(),
    this.tandaId = const Value.absent(),
    this.parteId = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required int cuentaId,
    this.productoId = const Value.absent(),
    required String nombre,
    this.variantesJson = const Value.absent(),
    required int cantidad,
    required double precioUnitario,
    this.estado = const Value.absent(),
    required DateTime agregadoEn,
    this.entregadoEn = const Value.absent(),
    required int tandaId,
    this.parteId = const Value.absent(),
  }) : cuentaId = Value(cuentaId),
       nombre = Value(nombre),
       cantidad = Value(cantidad),
       precioUnitario = Value(precioUnitario),
       agregadoEn = Value(agregadoEn),
       tandaId = Value(tandaId);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<int>? cuentaId,
    Expression<int>? productoId,
    Expression<String>? nombre,
    Expression<String>? variantesJson,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
    Expression<String>? estado,
    Expression<DateTime>? agregadoEn,
    Expression<DateTime>? entregadoEn,
    Expression<int>? tandaId,
    Expression<String>? parteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (productoId != null) 'producto_id': productoId,
      if (nombre != null) 'nombre': nombre,
      if (variantesJson != null) 'variantes_json': variantesJson,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (estado != null) 'estado': estado,
      if (agregadoEn != null) 'agregado_en': agregadoEn,
      if (entregadoEn != null) 'entregado_en': entregadoEn,
      if (tandaId != null) 'tanda_id': tandaId,
      if (parteId != null) 'parte_id': parteId,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? cuentaId,
    Value<int?>? productoId,
    Value<String>? nombre,
    Value<String>? variantesJson,
    Value<int>? cantidad,
    Value<double>? precioUnitario,
    Value<String>? estado,
    Value<DateTime>? agregadoEn,
    Value<DateTime?>? entregadoEn,
    Value<int>? tandaId,
    Value<String?>? parteId,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      cuentaId: cuentaId ?? this.cuentaId,
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      variantesJson: variantesJson ?? this.variantesJson,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      estado: estado ?? this.estado,
      agregadoEn: agregadoEn ?? this.agregadoEn,
      entregadoEn: entregadoEn ?? this.entregadoEn,
      tandaId: tandaId ?? this.tandaId,
      parteId: parteId ?? this.parteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cuentaId.present) {
      map['cuenta_id'] = Variable<int>(cuentaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (variantesJson.present) {
      map['variantes_json'] = Variable<String>(variantesJson.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (agregadoEn.present) {
      map['agregado_en'] = Variable<DateTime>(agregadoEn.value);
    }
    if (entregadoEn.present) {
      map['entregado_en'] = Variable<DateTime>(entregadoEn.value);
    }
    if (tandaId.present) {
      map['tanda_id'] = Variable<int>(tandaId.value);
    }
    if (parteId.present) {
      map['parte_id'] = Variable<String>(parteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombre: $nombre, ')
          ..write('variantesJson: $variantesJson, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('estado: $estado, ')
          ..write('agregadoEn: $agregadoEn, ')
          ..write('entregadoEn: $entregadoEn, ')
          ..write('tandaId: $tandaId, ')
          ..write('parteId: $parteId')
          ..write(')'))
        .toString();
  }
}

class $PagosTable extends Pagos with TableInfo<$PagosTable, Pago> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cuentaIdMeta = const VerificationMeta(
    'cuentaId',
  );
  @override
  late final GeneratedColumn<int> cuentaId = GeneratedColumn<int>(
    'cuenta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _turnoIdMeta = const VerificationMeta(
    'turnoId',
  );
  @override
  late final GeneratedColumn<int> turnoId = GeneratedColumn<int>(
    'turno_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etiquetaMeta = const VerificationMeta(
    'etiqueta',
  );
  @override
  late final GeneratedColumn<String> etiqueta = GeneratedColumn<String>(
    'etiqueta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _efectivoMeta = const VerificationMeta(
    'efectivo',
  );
  @override
  late final GeneratedColumn<double> efectivo = GeneratedColumn<double>(
    'efectivo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferenciaMeta = const VerificationMeta(
    'transferencia',
  );
  @override
  late final GeneratedColumn<double> transferencia = GeneratedColumn<double>(
    'transferencia',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recibidoMeta = const VerificationMeta(
    'recibido',
  );
  @override
  late final GeneratedColumn<double> recibido = GeneratedColumn<double>(
    'recibido',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vueltoMeta = const VerificationMeta('vuelto');
  @override
  late final GeneratedColumn<double> vuelto = GeneratedColumn<double>(
    'vuelto',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cuentaId,
    turnoId,
    etiqueta,
    monto,
    efectivo,
    transferencia,
    recibido,
    vuelto,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pago> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cuenta_id')) {
      context.handle(
        _cuentaIdMeta,
        cuentaId.isAcceptableOrUnknown(data['cuenta_id']!, _cuentaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cuentaIdMeta);
    }
    if (data.containsKey('turno_id')) {
      context.handle(
        _turnoIdMeta,
        turnoId.isAcceptableOrUnknown(data['turno_id']!, _turnoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_turnoIdMeta);
    }
    if (data.containsKey('etiqueta')) {
      context.handle(
        _etiquetaMeta,
        etiqueta.isAcceptableOrUnknown(data['etiqueta']!, _etiquetaMeta),
      );
    } else if (isInserting) {
      context.missing(_etiquetaMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('efectivo')) {
      context.handle(
        _efectivoMeta,
        efectivo.isAcceptableOrUnknown(data['efectivo']!, _efectivoMeta),
      );
    } else if (isInserting) {
      context.missing(_efectivoMeta);
    }
    if (data.containsKey('transferencia')) {
      context.handle(
        _transferenciaMeta,
        transferencia.isAcceptableOrUnknown(
          data['transferencia']!,
          _transferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferenciaMeta);
    }
    if (data.containsKey('recibido')) {
      context.handle(
        _recibidoMeta,
        recibido.isAcceptableOrUnknown(data['recibido']!, _recibidoMeta),
      );
    }
    if (data.containsKey('vuelto')) {
      context.handle(
        _vueltoMeta,
        vuelto.isAcceptableOrUnknown(data['vuelto']!, _vueltoMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pago map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pago(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cuentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cuenta_id'],
      )!,
      turnoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turno_id'],
      )!,
      etiqueta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etiqueta'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      efectivo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}efectivo'],
      )!,
      transferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transferencia'],
      )!,
      recibido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recibido'],
      ),
      vuelto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vuelto'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $PagosTable createAlias(String alias) {
    return $PagosTable(attachedDatabase, alias);
  }
}

class Pago extends DataClass implements Insertable<Pago> {
  final int id;
  final int cuentaId;
  final int turnoId;
  final String etiqueta;
  final double monto;
  final double efectivo;
  final double transferencia;
  final double? recibido;
  final double? vuelto;
  final DateTime creadoEn;
  const Pago({
    required this.id,
    required this.cuentaId,
    required this.turnoId,
    required this.etiqueta,
    required this.monto,
    required this.efectivo,
    required this.transferencia,
    this.recibido,
    this.vuelto,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cuenta_id'] = Variable<int>(cuentaId);
    map['turno_id'] = Variable<int>(turnoId);
    map['etiqueta'] = Variable<String>(etiqueta);
    map['monto'] = Variable<double>(monto);
    map['efectivo'] = Variable<double>(efectivo);
    map['transferencia'] = Variable<double>(transferencia);
    if (!nullToAbsent || recibido != null) {
      map['recibido'] = Variable<double>(recibido);
    }
    if (!nullToAbsent || vuelto != null) {
      map['vuelto'] = Variable<double>(vuelto);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  PagosCompanion toCompanion(bool nullToAbsent) {
    return PagosCompanion(
      id: Value(id),
      cuentaId: Value(cuentaId),
      turnoId: Value(turnoId),
      etiqueta: Value(etiqueta),
      monto: Value(monto),
      efectivo: Value(efectivo),
      transferencia: Value(transferencia),
      recibido: recibido == null && nullToAbsent
          ? const Value.absent()
          : Value(recibido),
      vuelto: vuelto == null && nullToAbsent
          ? const Value.absent()
          : Value(vuelto),
      creadoEn: Value(creadoEn),
    );
  }

  factory Pago.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pago(
      id: serializer.fromJson<int>(json['id']),
      cuentaId: serializer.fromJson<int>(json['cuentaId']),
      turnoId: serializer.fromJson<int>(json['turnoId']),
      etiqueta: serializer.fromJson<String>(json['etiqueta']),
      monto: serializer.fromJson<double>(json['monto']),
      efectivo: serializer.fromJson<double>(json['efectivo']),
      transferencia: serializer.fromJson<double>(json['transferencia']),
      recibido: serializer.fromJson<double?>(json['recibido']),
      vuelto: serializer.fromJson<double?>(json['vuelto']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cuentaId': serializer.toJson<int>(cuentaId),
      'turnoId': serializer.toJson<int>(turnoId),
      'etiqueta': serializer.toJson<String>(etiqueta),
      'monto': serializer.toJson<double>(monto),
      'efectivo': serializer.toJson<double>(efectivo),
      'transferencia': serializer.toJson<double>(transferencia),
      'recibido': serializer.toJson<double?>(recibido),
      'vuelto': serializer.toJson<double?>(vuelto),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Pago copyWith({
    int? id,
    int? cuentaId,
    int? turnoId,
    String? etiqueta,
    double? monto,
    double? efectivo,
    double? transferencia,
    Value<double?> recibido = const Value.absent(),
    Value<double?> vuelto = const Value.absent(),
    DateTime? creadoEn,
  }) => Pago(
    id: id ?? this.id,
    cuentaId: cuentaId ?? this.cuentaId,
    turnoId: turnoId ?? this.turnoId,
    etiqueta: etiqueta ?? this.etiqueta,
    monto: monto ?? this.monto,
    efectivo: efectivo ?? this.efectivo,
    transferencia: transferencia ?? this.transferencia,
    recibido: recibido.present ? recibido.value : this.recibido,
    vuelto: vuelto.present ? vuelto.value : this.vuelto,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Pago copyWithCompanion(PagosCompanion data) {
    return Pago(
      id: data.id.present ? data.id.value : this.id,
      cuentaId: data.cuentaId.present ? data.cuentaId.value : this.cuentaId,
      turnoId: data.turnoId.present ? data.turnoId.value : this.turnoId,
      etiqueta: data.etiqueta.present ? data.etiqueta.value : this.etiqueta,
      monto: data.monto.present ? data.monto.value : this.monto,
      efectivo: data.efectivo.present ? data.efectivo.value : this.efectivo,
      transferencia: data.transferencia.present
          ? data.transferencia.value
          : this.transferencia,
      recibido: data.recibido.present ? data.recibido.value : this.recibido,
      vuelto: data.vuelto.present ? data.vuelto.value : this.vuelto,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pago(')
          ..write('id: $id, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('turnoId: $turnoId, ')
          ..write('etiqueta: $etiqueta, ')
          ..write('monto: $monto, ')
          ..write('efectivo: $efectivo, ')
          ..write('transferencia: $transferencia, ')
          ..write('recibido: $recibido, ')
          ..write('vuelto: $vuelto, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cuentaId,
    turnoId,
    etiqueta,
    monto,
    efectivo,
    transferencia,
    recibido,
    vuelto,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pago &&
          other.id == this.id &&
          other.cuentaId == this.cuentaId &&
          other.turnoId == this.turnoId &&
          other.etiqueta == this.etiqueta &&
          other.monto == this.monto &&
          other.efectivo == this.efectivo &&
          other.transferencia == this.transferencia &&
          other.recibido == this.recibido &&
          other.vuelto == this.vuelto &&
          other.creadoEn == this.creadoEn);
}

class PagosCompanion extends UpdateCompanion<Pago> {
  final Value<int> id;
  final Value<int> cuentaId;
  final Value<int> turnoId;
  final Value<String> etiqueta;
  final Value<double> monto;
  final Value<double> efectivo;
  final Value<double> transferencia;
  final Value<double?> recibido;
  final Value<double?> vuelto;
  final Value<DateTime> creadoEn;
  const PagosCompanion({
    this.id = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.turnoId = const Value.absent(),
    this.etiqueta = const Value.absent(),
    this.monto = const Value.absent(),
    this.efectivo = const Value.absent(),
    this.transferencia = const Value.absent(),
    this.recibido = const Value.absent(),
    this.vuelto = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  PagosCompanion.insert({
    this.id = const Value.absent(),
    required int cuentaId,
    required int turnoId,
    required String etiqueta,
    required double monto,
    required double efectivo,
    required double transferencia,
    this.recibido = const Value.absent(),
    this.vuelto = const Value.absent(),
    required DateTime creadoEn,
  }) : cuentaId = Value(cuentaId),
       turnoId = Value(turnoId),
       etiqueta = Value(etiqueta),
       monto = Value(monto),
       efectivo = Value(efectivo),
       transferencia = Value(transferencia),
       creadoEn = Value(creadoEn);
  static Insertable<Pago> custom({
    Expression<int>? id,
    Expression<int>? cuentaId,
    Expression<int>? turnoId,
    Expression<String>? etiqueta,
    Expression<double>? monto,
    Expression<double>? efectivo,
    Expression<double>? transferencia,
    Expression<double>? recibido,
    Expression<double>? vuelto,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (turnoId != null) 'turno_id': turnoId,
      if (etiqueta != null) 'etiqueta': etiqueta,
      if (monto != null) 'monto': monto,
      if (efectivo != null) 'efectivo': efectivo,
      if (transferencia != null) 'transferencia': transferencia,
      if (recibido != null) 'recibido': recibido,
      if (vuelto != null) 'vuelto': vuelto,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  PagosCompanion copyWith({
    Value<int>? id,
    Value<int>? cuentaId,
    Value<int>? turnoId,
    Value<String>? etiqueta,
    Value<double>? monto,
    Value<double>? efectivo,
    Value<double>? transferencia,
    Value<double?>? recibido,
    Value<double?>? vuelto,
    Value<DateTime>? creadoEn,
  }) {
    return PagosCompanion(
      id: id ?? this.id,
      cuentaId: cuentaId ?? this.cuentaId,
      turnoId: turnoId ?? this.turnoId,
      etiqueta: etiqueta ?? this.etiqueta,
      monto: monto ?? this.monto,
      efectivo: efectivo ?? this.efectivo,
      transferencia: transferencia ?? this.transferencia,
      recibido: recibido ?? this.recibido,
      vuelto: vuelto ?? this.vuelto,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cuentaId.present) {
      map['cuenta_id'] = Variable<int>(cuentaId.value);
    }
    if (turnoId.present) {
      map['turno_id'] = Variable<int>(turnoId.value);
    }
    if (etiqueta.present) {
      map['etiqueta'] = Variable<String>(etiqueta.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (efectivo.present) {
      map['efectivo'] = Variable<double>(efectivo.value);
    }
    if (transferencia.present) {
      map['transferencia'] = Variable<double>(transferencia.value);
    }
    if (recibido.present) {
      map['recibido'] = Variable<double>(recibido.value);
    }
    if (vuelto.present) {
      map['vuelto'] = Variable<double>(vuelto.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosCompanion(')
          ..write('id: $id, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('turnoId: $turnoId, ')
          ..write('etiqueta: $etiqueta, ')
          ..write('monto: $monto, ')
          ..write('efectivo: $efectivo, ')
          ..write('transferencia: $transferencia, ')
          ..write('recibido: $recibido, ')
          ..write('vuelto: $vuelto, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

class $ComprobantesTable extends Comprobantes
    with TableInfo<$ComprobantesTable, Comprobante> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprobantesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rutaArchivoMeta = const VerificationMeta(
    'rutaArchivo',
  );
  @override
  late final GeneratedColumn<String> rutaArchivo = GeneratedColumn<String>(
    'ruta_archivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _turnoIdMeta = const VerificationMeta(
    'turnoId',
  );
  @override
  late final GeneratedColumn<int> turnoId = GeneratedColumn<int>(
    'turno_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mesaIdMeta = const VerificationMeta('mesaId');
  @override
  late final GeneratedColumn<int> mesaId = GeneratedColumn<int>(
    'mesa_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasMesaMeta = const VerificationMeta(
    'aliasMesa',
  );
  @override
  late final GeneratedColumn<String> aliasMesa = GeneratedColumn<String>(
    'alias_mesa',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cuentaIdMeta = const VerificationMeta(
    'cuentaId',
  );
  @override
  late final GeneratedColumn<int> cuentaId = GeneratedColumn<int>(
    'cuenta_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagoIdMeta = const VerificationMeta('pagoId');
  @override
  late final GeneratedColumn<int> pagoId = GeneratedColumn<int>(
    'pago_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendiente'),
  );
  static const VerificationMeta _legalizadaEnMeta = const VerificationMeta(
    'legalizadaEn',
  );
  @override
  late final GeneratedColumn<DateTime> legalizadaEn = GeneratedColumn<DateTime>(
    'legalizada_en',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rutaArchivo,
    fecha,
    turnoId,
    mesaId,
    aliasMesa,
    cuentaId,
    pagoId,
    monto,
    estado,
    legalizadaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comprobantes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Comprobante> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ruta_archivo')) {
      context.handle(
        _rutaArchivoMeta,
        rutaArchivo.isAcceptableOrUnknown(
          data['ruta_archivo']!,
          _rutaArchivoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rutaArchivoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('turno_id')) {
      context.handle(
        _turnoIdMeta,
        turnoId.isAcceptableOrUnknown(data['turno_id']!, _turnoIdMeta),
      );
    }
    if (data.containsKey('mesa_id')) {
      context.handle(
        _mesaIdMeta,
        mesaId.isAcceptableOrUnknown(data['mesa_id']!, _mesaIdMeta),
      );
    }
    if (data.containsKey('alias_mesa')) {
      context.handle(
        _aliasMesaMeta,
        aliasMesa.isAcceptableOrUnknown(data['alias_mesa']!, _aliasMesaMeta),
      );
    }
    if (data.containsKey('cuenta_id')) {
      context.handle(
        _cuentaIdMeta,
        cuentaId.isAcceptableOrUnknown(data['cuenta_id']!, _cuentaIdMeta),
      );
    }
    if (data.containsKey('pago_id')) {
      context.handle(
        _pagoIdMeta,
        pagoId.isAcceptableOrUnknown(data['pago_id']!, _pagoIdMeta),
      );
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('legalizada_en')) {
      context.handle(
        _legalizadaEnMeta,
        legalizadaEn.isAcceptableOrUnknown(
          data['legalizada_en']!,
          _legalizadaEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Comprobante map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Comprobante(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rutaArchivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruta_archivo'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      turnoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turno_id'],
      ),
      mesaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mesa_id'],
      ),
      aliasMesa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_mesa'],
      ),
      cuentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cuenta_id'],
      ),
      pagoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pago_id'],
      ),
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      legalizadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}legalizada_en'],
      ),
    );
  }

  @override
  $ComprobantesTable createAlias(String alias) {
    return $ComprobantesTable(attachedDatabase, alias);
  }
}

class Comprobante extends DataClass implements Insertable<Comprobante> {
  final int id;
  final String rutaArchivo;
  final DateTime fecha;
  final int? turnoId;
  final int? mesaId;
  final String? aliasMesa;
  final int? cuentaId;
  final int? pagoId;
  final double? monto;
  final String estado;
  final DateTime? legalizadaEn;
  const Comprobante({
    required this.id,
    required this.rutaArchivo,
    required this.fecha,
    this.turnoId,
    this.mesaId,
    this.aliasMesa,
    this.cuentaId,
    this.pagoId,
    this.monto,
    required this.estado,
    this.legalizadaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ruta_archivo'] = Variable<String>(rutaArchivo);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || turnoId != null) {
      map['turno_id'] = Variable<int>(turnoId);
    }
    if (!nullToAbsent || mesaId != null) {
      map['mesa_id'] = Variable<int>(mesaId);
    }
    if (!nullToAbsent || aliasMesa != null) {
      map['alias_mesa'] = Variable<String>(aliasMesa);
    }
    if (!nullToAbsent || cuentaId != null) {
      map['cuenta_id'] = Variable<int>(cuentaId);
    }
    if (!nullToAbsent || pagoId != null) {
      map['pago_id'] = Variable<int>(pagoId);
    }
    if (!nullToAbsent || monto != null) {
      map['monto'] = Variable<double>(monto);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || legalizadaEn != null) {
      map['legalizada_en'] = Variable<DateTime>(legalizadaEn);
    }
    return map;
  }

  ComprobantesCompanion toCompanion(bool nullToAbsent) {
    return ComprobantesCompanion(
      id: Value(id),
      rutaArchivo: Value(rutaArchivo),
      fecha: Value(fecha),
      turnoId: turnoId == null && nullToAbsent
          ? const Value.absent()
          : Value(turnoId),
      mesaId: mesaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaId),
      aliasMesa: aliasMesa == null && nullToAbsent
          ? const Value.absent()
          : Value(aliasMesa),
      cuentaId: cuentaId == null && nullToAbsent
          ? const Value.absent()
          : Value(cuentaId),
      pagoId: pagoId == null && nullToAbsent
          ? const Value.absent()
          : Value(pagoId),
      monto: monto == null && nullToAbsent
          ? const Value.absent()
          : Value(monto),
      estado: Value(estado),
      legalizadaEn: legalizadaEn == null && nullToAbsent
          ? const Value.absent()
          : Value(legalizadaEn),
    );
  }

  factory Comprobante.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Comprobante(
      id: serializer.fromJson<int>(json['id']),
      rutaArchivo: serializer.fromJson<String>(json['rutaArchivo']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      turnoId: serializer.fromJson<int?>(json['turnoId']),
      mesaId: serializer.fromJson<int?>(json['mesaId']),
      aliasMesa: serializer.fromJson<String?>(json['aliasMesa']),
      cuentaId: serializer.fromJson<int?>(json['cuentaId']),
      pagoId: serializer.fromJson<int?>(json['pagoId']),
      monto: serializer.fromJson<double?>(json['monto']),
      estado: serializer.fromJson<String>(json['estado']),
      legalizadaEn: serializer.fromJson<DateTime?>(json['legalizadaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rutaArchivo': serializer.toJson<String>(rutaArchivo),
      'fecha': serializer.toJson<DateTime>(fecha),
      'turnoId': serializer.toJson<int?>(turnoId),
      'mesaId': serializer.toJson<int?>(mesaId),
      'aliasMesa': serializer.toJson<String?>(aliasMesa),
      'cuentaId': serializer.toJson<int?>(cuentaId),
      'pagoId': serializer.toJson<int?>(pagoId),
      'monto': serializer.toJson<double?>(monto),
      'estado': serializer.toJson<String>(estado),
      'legalizadaEn': serializer.toJson<DateTime?>(legalizadaEn),
    };
  }

  Comprobante copyWith({
    int? id,
    String? rutaArchivo,
    DateTime? fecha,
    Value<int?> turnoId = const Value.absent(),
    Value<int?> mesaId = const Value.absent(),
    Value<String?> aliasMesa = const Value.absent(),
    Value<int?> cuentaId = const Value.absent(),
    Value<int?> pagoId = const Value.absent(),
    Value<double?> monto = const Value.absent(),
    String? estado,
    Value<DateTime?> legalizadaEn = const Value.absent(),
  }) => Comprobante(
    id: id ?? this.id,
    rutaArchivo: rutaArchivo ?? this.rutaArchivo,
    fecha: fecha ?? this.fecha,
    turnoId: turnoId.present ? turnoId.value : this.turnoId,
    mesaId: mesaId.present ? mesaId.value : this.mesaId,
    aliasMesa: aliasMesa.present ? aliasMesa.value : this.aliasMesa,
    cuentaId: cuentaId.present ? cuentaId.value : this.cuentaId,
    pagoId: pagoId.present ? pagoId.value : this.pagoId,
    monto: monto.present ? monto.value : this.monto,
    estado: estado ?? this.estado,
    legalizadaEn: legalizadaEn.present ? legalizadaEn.value : this.legalizadaEn,
  );
  Comprobante copyWithCompanion(ComprobantesCompanion data) {
    return Comprobante(
      id: data.id.present ? data.id.value : this.id,
      rutaArchivo: data.rutaArchivo.present
          ? data.rutaArchivo.value
          : this.rutaArchivo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      turnoId: data.turnoId.present ? data.turnoId.value : this.turnoId,
      mesaId: data.mesaId.present ? data.mesaId.value : this.mesaId,
      aliasMesa: data.aliasMesa.present ? data.aliasMesa.value : this.aliasMesa,
      cuentaId: data.cuentaId.present ? data.cuentaId.value : this.cuentaId,
      pagoId: data.pagoId.present ? data.pagoId.value : this.pagoId,
      monto: data.monto.present ? data.monto.value : this.monto,
      estado: data.estado.present ? data.estado.value : this.estado,
      legalizadaEn: data.legalizadaEn.present
          ? data.legalizadaEn.value
          : this.legalizadaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Comprobante(')
          ..write('id: $id, ')
          ..write('rutaArchivo: $rutaArchivo, ')
          ..write('fecha: $fecha, ')
          ..write('turnoId: $turnoId, ')
          ..write('mesaId: $mesaId, ')
          ..write('aliasMesa: $aliasMesa, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('pagoId: $pagoId, ')
          ..write('monto: $monto, ')
          ..write('estado: $estado, ')
          ..write('legalizadaEn: $legalizadaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rutaArchivo,
    fecha,
    turnoId,
    mesaId,
    aliasMesa,
    cuentaId,
    pagoId,
    monto,
    estado,
    legalizadaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comprobante &&
          other.id == this.id &&
          other.rutaArchivo == this.rutaArchivo &&
          other.fecha == this.fecha &&
          other.turnoId == this.turnoId &&
          other.mesaId == this.mesaId &&
          other.aliasMesa == this.aliasMesa &&
          other.cuentaId == this.cuentaId &&
          other.pagoId == this.pagoId &&
          other.monto == this.monto &&
          other.estado == this.estado &&
          other.legalizadaEn == this.legalizadaEn);
}

class ComprobantesCompanion extends UpdateCompanion<Comprobante> {
  final Value<int> id;
  final Value<String> rutaArchivo;
  final Value<DateTime> fecha;
  final Value<int?> turnoId;
  final Value<int?> mesaId;
  final Value<String?> aliasMesa;
  final Value<int?> cuentaId;
  final Value<int?> pagoId;
  final Value<double?> monto;
  final Value<String> estado;
  final Value<DateTime?> legalizadaEn;
  const ComprobantesCompanion({
    this.id = const Value.absent(),
    this.rutaArchivo = const Value.absent(),
    this.fecha = const Value.absent(),
    this.turnoId = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.aliasMesa = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.pagoId = const Value.absent(),
    this.monto = const Value.absent(),
    this.estado = const Value.absent(),
    this.legalizadaEn = const Value.absent(),
  });
  ComprobantesCompanion.insert({
    this.id = const Value.absent(),
    required String rutaArchivo,
    required DateTime fecha,
    this.turnoId = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.aliasMesa = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.pagoId = const Value.absent(),
    this.monto = const Value.absent(),
    this.estado = const Value.absent(),
    this.legalizadaEn = const Value.absent(),
  }) : rutaArchivo = Value(rutaArchivo),
       fecha = Value(fecha);
  static Insertable<Comprobante> custom({
    Expression<int>? id,
    Expression<String>? rutaArchivo,
    Expression<DateTime>? fecha,
    Expression<int>? turnoId,
    Expression<int>? mesaId,
    Expression<String>? aliasMesa,
    Expression<int>? cuentaId,
    Expression<int>? pagoId,
    Expression<double>? monto,
    Expression<String>? estado,
    Expression<DateTime>? legalizadaEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rutaArchivo != null) 'ruta_archivo': rutaArchivo,
      if (fecha != null) 'fecha': fecha,
      if (turnoId != null) 'turno_id': turnoId,
      if (mesaId != null) 'mesa_id': mesaId,
      if (aliasMesa != null) 'alias_mesa': aliasMesa,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (pagoId != null) 'pago_id': pagoId,
      if (monto != null) 'monto': monto,
      if (estado != null) 'estado': estado,
      if (legalizadaEn != null) 'legalizada_en': legalizadaEn,
    });
  }

  ComprobantesCompanion copyWith({
    Value<int>? id,
    Value<String>? rutaArchivo,
    Value<DateTime>? fecha,
    Value<int?>? turnoId,
    Value<int?>? mesaId,
    Value<String?>? aliasMesa,
    Value<int?>? cuentaId,
    Value<int?>? pagoId,
    Value<double?>? monto,
    Value<String>? estado,
    Value<DateTime?>? legalizadaEn,
  }) {
    return ComprobantesCompanion(
      id: id ?? this.id,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      fecha: fecha ?? this.fecha,
      turnoId: turnoId ?? this.turnoId,
      mesaId: mesaId ?? this.mesaId,
      aliasMesa: aliasMesa ?? this.aliasMesa,
      cuentaId: cuentaId ?? this.cuentaId,
      pagoId: pagoId ?? this.pagoId,
      monto: monto ?? this.monto,
      estado: estado ?? this.estado,
      legalizadaEn: legalizadaEn ?? this.legalizadaEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rutaArchivo.present) {
      map['ruta_archivo'] = Variable<String>(rutaArchivo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (turnoId.present) {
      map['turno_id'] = Variable<int>(turnoId.value);
    }
    if (mesaId.present) {
      map['mesa_id'] = Variable<int>(mesaId.value);
    }
    if (aliasMesa.present) {
      map['alias_mesa'] = Variable<String>(aliasMesa.value);
    }
    if (cuentaId.present) {
      map['cuenta_id'] = Variable<int>(cuentaId.value);
    }
    if (pagoId.present) {
      map['pago_id'] = Variable<int>(pagoId.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (legalizadaEn.present) {
      map['legalizada_en'] = Variable<DateTime>(legalizadaEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprobantesCompanion(')
          ..write('id: $id, ')
          ..write('rutaArchivo: $rutaArchivo, ')
          ..write('fecha: $fecha, ')
          ..write('turnoId: $turnoId, ')
          ..write('mesaId: $mesaId, ')
          ..write('aliasMesa: $aliasMesa, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('pagoId: $pagoId, ')
          ..write('monto: $monto, ')
          ..write('estado: $estado, ')
          ..write('legalizadaEn: $legalizadaEn')
          ..write(')'))
        .toString();
  }
}

class $AjustesTable extends Ajustes with TableInfo<$AjustesTable, Ajuste> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AjustesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreNegocioMeta = const VerificationMeta(
    'nombreNegocio',
  );
  @override
  late final GeneratedColumn<String> nombreNegocio = GeneratedColumn<String>(
    'nombre_negocio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Mi bar'),
  );
  static const VerificationMeta _alertaMinutosMeta = const VerificationMeta(
    'alertaMinutos',
  );
  @override
  late final GeneratedColumn<int> alertaMinutos = GeneratedColumn<int>(
    'alerta_minutos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _simboloMonedaMeta = const VerificationMeta(
    'simboloMoneda',
  );
  @override
  late final GeneratedColumn<String> simboloMoneda = GeneratedColumn<String>(
    'simbolo_moneda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('\$'),
  );
  static const VerificationMeta _formato24hMeta = const VerificationMeta(
    'formato24h',
  );
  @override
  late final GeneratedColumn<bool> formato24h = GeneratedColumn<bool>(
    'formato24h',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("formato24h" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recordatorioBackupDiasMeta =
      const VerificationMeta('recordatorioBackupDias');
  @override
  late final GeneratedColumn<int> recordatorioBackupDias = GeneratedColumn<int>(
    'recordatorio_backup_dias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ultimaExportacionMeta = const VerificationMeta(
    'ultimaExportacion',
  );
  @override
  late final GeneratedColumn<DateTime> ultimaExportacion =
      GeneratedColumn<DateTime>(
        'ultima_exportacion',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vibracionActivaMeta = const VerificationMeta(
    'vibracionActiva',
  );
  @override
  late final GeneratedColumn<bool> vibracionActiva = GeneratedColumn<bool>(
    'vibracion_activa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibracion_activa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombreNegocio,
    alertaMinutos,
    simboloMoneda,
    formato24h,
    recordatorioBackupDias,
    ultimaExportacion,
    vibracionActiva,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ajustes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ajuste> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_negocio')) {
      context.handle(
        _nombreNegocioMeta,
        nombreNegocio.isAcceptableOrUnknown(
          data['nombre_negocio']!,
          _nombreNegocioMeta,
        ),
      );
    }
    if (data.containsKey('alerta_minutos')) {
      context.handle(
        _alertaMinutosMeta,
        alertaMinutos.isAcceptableOrUnknown(
          data['alerta_minutos']!,
          _alertaMinutosMeta,
        ),
      );
    }
    if (data.containsKey('simbolo_moneda')) {
      context.handle(
        _simboloMonedaMeta,
        simboloMoneda.isAcceptableOrUnknown(
          data['simbolo_moneda']!,
          _simboloMonedaMeta,
        ),
      );
    }
    if (data.containsKey('formato24h')) {
      context.handle(
        _formato24hMeta,
        formato24h.isAcceptableOrUnknown(data['formato24h']!, _formato24hMeta),
      );
    }
    if (data.containsKey('recordatorio_backup_dias')) {
      context.handle(
        _recordatorioBackupDiasMeta,
        recordatorioBackupDias.isAcceptableOrUnknown(
          data['recordatorio_backup_dias']!,
          _recordatorioBackupDiasMeta,
        ),
      );
    }
    if (data.containsKey('ultima_exportacion')) {
      context.handle(
        _ultimaExportacionMeta,
        ultimaExportacion.isAcceptableOrUnknown(
          data['ultima_exportacion']!,
          _ultimaExportacionMeta,
        ),
      );
    }
    if (data.containsKey('vibracion_activa')) {
      context.handle(
        _vibracionActivaMeta,
        vibracionActiva.isAcceptableOrUnknown(
          data['vibracion_activa']!,
          _vibracionActivaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ajuste map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ajuste(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombreNegocio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_negocio'],
      )!,
      alertaMinutos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alerta_minutos'],
      )!,
      simboloMoneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}simbolo_moneda'],
      )!,
      formato24h: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}formato24h'],
      )!,
      recordatorioBackupDias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recordatorio_backup_dias'],
      )!,
      ultimaExportacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_exportacion'],
      ),
      vibracionActiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibracion_activa'],
      )!,
    );
  }

  @override
  $AjustesTable createAlias(String alias) {
    return $AjustesTable(attachedDatabase, alias);
  }
}

class Ajuste extends DataClass implements Insertable<Ajuste> {
  final int id;
  final String nombreNegocio;
  final int alertaMinutos;
  final String simboloMoneda;
  final bool formato24h;
  final int recordatorioBackupDias;
  final DateTime? ultimaExportacion;
  final bool vibracionActiva;
  const Ajuste({
    required this.id,
    required this.nombreNegocio,
    required this.alertaMinutos,
    required this.simboloMoneda,
    required this.formato24h,
    required this.recordatorioBackupDias,
    this.ultimaExportacion,
    required this.vibracionActiva,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_negocio'] = Variable<String>(nombreNegocio);
    map['alerta_minutos'] = Variable<int>(alertaMinutos);
    map['simbolo_moneda'] = Variable<String>(simboloMoneda);
    map['formato24h'] = Variable<bool>(formato24h);
    map['recordatorio_backup_dias'] = Variable<int>(recordatorioBackupDias);
    if (!nullToAbsent || ultimaExportacion != null) {
      map['ultima_exportacion'] = Variable<DateTime>(ultimaExportacion);
    }
    map['vibracion_activa'] = Variable<bool>(vibracionActiva);
    return map;
  }

  AjustesCompanion toCompanion(bool nullToAbsent) {
    return AjustesCompanion(
      id: Value(id),
      nombreNegocio: Value(nombreNegocio),
      alertaMinutos: Value(alertaMinutos),
      simboloMoneda: Value(simboloMoneda),
      formato24h: Value(formato24h),
      recordatorioBackupDias: Value(recordatorioBackupDias),
      ultimaExportacion: ultimaExportacion == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaExportacion),
      vibracionActiva: Value(vibracionActiva),
    );
  }

  factory Ajuste.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ajuste(
      id: serializer.fromJson<int>(json['id']),
      nombreNegocio: serializer.fromJson<String>(json['nombreNegocio']),
      alertaMinutos: serializer.fromJson<int>(json['alertaMinutos']),
      simboloMoneda: serializer.fromJson<String>(json['simboloMoneda']),
      formato24h: serializer.fromJson<bool>(json['formato24h']),
      recordatorioBackupDias: serializer.fromJson<int>(
        json['recordatorioBackupDias'],
      ),
      ultimaExportacion: serializer.fromJson<DateTime?>(
        json['ultimaExportacion'],
      ),
      vibracionActiva: serializer.fromJson<bool>(json['vibracionActiva']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreNegocio': serializer.toJson<String>(nombreNegocio),
      'alertaMinutos': serializer.toJson<int>(alertaMinutos),
      'simboloMoneda': serializer.toJson<String>(simboloMoneda),
      'formato24h': serializer.toJson<bool>(formato24h),
      'recordatorioBackupDias': serializer.toJson<int>(recordatorioBackupDias),
      'ultimaExportacion': serializer.toJson<DateTime?>(ultimaExportacion),
      'vibracionActiva': serializer.toJson<bool>(vibracionActiva),
    };
  }

  Ajuste copyWith({
    int? id,
    String? nombreNegocio,
    int? alertaMinutos,
    String? simboloMoneda,
    bool? formato24h,
    int? recordatorioBackupDias,
    Value<DateTime?> ultimaExportacion = const Value.absent(),
    bool? vibracionActiva,
  }) => Ajuste(
    id: id ?? this.id,
    nombreNegocio: nombreNegocio ?? this.nombreNegocio,
    alertaMinutos: alertaMinutos ?? this.alertaMinutos,
    simboloMoneda: simboloMoneda ?? this.simboloMoneda,
    formato24h: formato24h ?? this.formato24h,
    recordatorioBackupDias:
        recordatorioBackupDias ?? this.recordatorioBackupDias,
    ultimaExportacion: ultimaExportacion.present
        ? ultimaExportacion.value
        : this.ultimaExportacion,
    vibracionActiva: vibracionActiva ?? this.vibracionActiva,
  );
  Ajuste copyWithCompanion(AjustesCompanion data) {
    return Ajuste(
      id: data.id.present ? data.id.value : this.id,
      nombreNegocio: data.nombreNegocio.present
          ? data.nombreNegocio.value
          : this.nombreNegocio,
      alertaMinutos: data.alertaMinutos.present
          ? data.alertaMinutos.value
          : this.alertaMinutos,
      simboloMoneda: data.simboloMoneda.present
          ? data.simboloMoneda.value
          : this.simboloMoneda,
      formato24h: data.formato24h.present
          ? data.formato24h.value
          : this.formato24h,
      recordatorioBackupDias: data.recordatorioBackupDias.present
          ? data.recordatorioBackupDias.value
          : this.recordatorioBackupDias,
      ultimaExportacion: data.ultimaExportacion.present
          ? data.ultimaExportacion.value
          : this.ultimaExportacion,
      vibracionActiva: data.vibracionActiva.present
          ? data.vibracionActiva.value
          : this.vibracionActiva,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ajuste(')
          ..write('id: $id, ')
          ..write('nombreNegocio: $nombreNegocio, ')
          ..write('alertaMinutos: $alertaMinutos, ')
          ..write('simboloMoneda: $simboloMoneda, ')
          ..write('formato24h: $formato24h, ')
          ..write('recordatorioBackupDias: $recordatorioBackupDias, ')
          ..write('ultimaExportacion: $ultimaExportacion, ')
          ..write('vibracionActiva: $vibracionActiva')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombreNegocio,
    alertaMinutos,
    simboloMoneda,
    formato24h,
    recordatorioBackupDias,
    ultimaExportacion,
    vibracionActiva,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ajuste &&
          other.id == this.id &&
          other.nombreNegocio == this.nombreNegocio &&
          other.alertaMinutos == this.alertaMinutos &&
          other.simboloMoneda == this.simboloMoneda &&
          other.formato24h == this.formato24h &&
          other.recordatorioBackupDias == this.recordatorioBackupDias &&
          other.ultimaExportacion == this.ultimaExportacion &&
          other.vibracionActiva == this.vibracionActiva);
}

class AjustesCompanion extends UpdateCompanion<Ajuste> {
  final Value<int> id;
  final Value<String> nombreNegocio;
  final Value<int> alertaMinutos;
  final Value<String> simboloMoneda;
  final Value<bool> formato24h;
  final Value<int> recordatorioBackupDias;
  final Value<DateTime?> ultimaExportacion;
  final Value<bool> vibracionActiva;
  const AjustesCompanion({
    this.id = const Value.absent(),
    this.nombreNegocio = const Value.absent(),
    this.alertaMinutos = const Value.absent(),
    this.simboloMoneda = const Value.absent(),
    this.formato24h = const Value.absent(),
    this.recordatorioBackupDias = const Value.absent(),
    this.ultimaExportacion = const Value.absent(),
    this.vibracionActiva = const Value.absent(),
  });
  AjustesCompanion.insert({
    this.id = const Value.absent(),
    this.nombreNegocio = const Value.absent(),
    this.alertaMinutos = const Value.absent(),
    this.simboloMoneda = const Value.absent(),
    this.formato24h = const Value.absent(),
    this.recordatorioBackupDias = const Value.absent(),
    this.ultimaExportacion = const Value.absent(),
    this.vibracionActiva = const Value.absent(),
  });
  static Insertable<Ajuste> custom({
    Expression<int>? id,
    Expression<String>? nombreNegocio,
    Expression<int>? alertaMinutos,
    Expression<String>? simboloMoneda,
    Expression<bool>? formato24h,
    Expression<int>? recordatorioBackupDias,
    Expression<DateTime>? ultimaExportacion,
    Expression<bool>? vibracionActiva,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreNegocio != null) 'nombre_negocio': nombreNegocio,
      if (alertaMinutos != null) 'alerta_minutos': alertaMinutos,
      if (simboloMoneda != null) 'simbolo_moneda': simboloMoneda,
      if (formato24h != null) 'formato24h': formato24h,
      if (recordatorioBackupDias != null)
        'recordatorio_backup_dias': recordatorioBackupDias,
      if (ultimaExportacion != null) 'ultima_exportacion': ultimaExportacion,
      if (vibracionActiva != null) 'vibracion_activa': vibracionActiva,
    });
  }

  AjustesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombreNegocio,
    Value<int>? alertaMinutos,
    Value<String>? simboloMoneda,
    Value<bool>? formato24h,
    Value<int>? recordatorioBackupDias,
    Value<DateTime?>? ultimaExportacion,
    Value<bool>? vibracionActiva,
  }) {
    return AjustesCompanion(
      id: id ?? this.id,
      nombreNegocio: nombreNegocio ?? this.nombreNegocio,
      alertaMinutos: alertaMinutos ?? this.alertaMinutos,
      simboloMoneda: simboloMoneda ?? this.simboloMoneda,
      formato24h: formato24h ?? this.formato24h,
      recordatorioBackupDias:
          recordatorioBackupDias ?? this.recordatorioBackupDias,
      ultimaExportacion: ultimaExportacion ?? this.ultimaExportacion,
      vibracionActiva: vibracionActiva ?? this.vibracionActiva,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreNegocio.present) {
      map['nombre_negocio'] = Variable<String>(nombreNegocio.value);
    }
    if (alertaMinutos.present) {
      map['alerta_minutos'] = Variable<int>(alertaMinutos.value);
    }
    if (simboloMoneda.present) {
      map['simbolo_moneda'] = Variable<String>(simboloMoneda.value);
    }
    if (formato24h.present) {
      map['formato24h'] = Variable<bool>(formato24h.value);
    }
    if (recordatorioBackupDias.present) {
      map['recordatorio_backup_dias'] = Variable<int>(
        recordatorioBackupDias.value,
      );
    }
    if (ultimaExportacion.present) {
      map['ultima_exportacion'] = Variable<DateTime>(ultimaExportacion.value);
    }
    if (vibracionActiva.present) {
      map['vibracion_activa'] = Variable<bool>(vibracionActiva.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AjustesCompanion(')
          ..write('id: $id, ')
          ..write('nombreNegocio: $nombreNegocio, ')
          ..write('alertaMinutos: $alertaMinutos, ')
          ..write('simboloMoneda: $simboloMoneda, ')
          ..write('formato24h: $formato24h, ')
          ..write('recordatorioBackupDias: $recordatorioBackupDias, ')
          ..write('ultimaExportacion: $ultimaExportacion, ')
          ..write('vibracionActiva: $vibracionActiva')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDatos extends GeneratedDatabase {
  _$BaseDatos(QueryExecutor e) : super(e);
  $BaseDatosManager get managers => $BaseDatosManager(this);
  late final $TurnosTable turnos = $TurnosTable(this);
  late final $MesasTable mesas = $MesasTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $CuentasTable cuentas = $CuentasTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $PagosTable pagos = $PagosTable(this);
  late final $ComprobantesTable comprobantes = $ComprobantesTable(this);
  late final $AjustesTable ajustes = $AjustesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    turnos,
    mesas,
    categorias,
    productos,
    cuentas,
    items,
    pagos,
    comprobantes,
    ajustes,
  ];
}

typedef $$TurnosTableCreateCompanionBuilder =
    TurnosCompanion Function({
      Value<int> id,
      required DateTime inicio,
      Value<DateTime?> fin,
      Value<String> estado,
    });
typedef $$TurnosTableUpdateCompanionBuilder =
    TurnosCompanion Function({
      Value<int> id,
      Value<DateTime> inicio,
      Value<DateTime?> fin,
      Value<String> estado,
    });

class $$TurnosTableFilterComposer extends Composer<_$BaseDatos, $TurnosTable> {
  $$TurnosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TurnosTableOrderingComposer
    extends Composer<_$BaseDatos, $TurnosTable> {
  $$TurnosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TurnosTableAnnotationComposer
    extends Composer<_$BaseDatos, $TurnosTable> {
  $$TurnosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fin =>
      $composableBuilder(column: $table.fin, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$TurnosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $TurnosTable,
          Turno,
          $$TurnosTableFilterComposer,
          $$TurnosTableOrderingComposer,
          $$TurnosTableAnnotationComposer,
          $$TurnosTableCreateCompanionBuilder,
          $$TurnosTableUpdateCompanionBuilder,
          (Turno, BaseReferences<_$BaseDatos, $TurnosTable, Turno>),
          Turno,
          PrefetchHooks Function()
        > {
  $$TurnosTableTableManager(_$BaseDatos db, $TurnosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime?> fin = const Value.absent(),
                Value<String> estado = const Value.absent(),
              }) => TurnosCompanion(
                id: id,
                inicio: inicio,
                fin: fin,
                estado: estado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime inicio,
                Value<DateTime?> fin = const Value.absent(),
                Value<String> estado = const Value.absent(),
              }) => TurnosCompanion.insert(
                id: id,
                inicio: inicio,
                fin: fin,
                estado: estado,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TurnosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $TurnosTable,
      Turno,
      $$TurnosTableFilterComposer,
      $$TurnosTableOrderingComposer,
      $$TurnosTableAnnotationComposer,
      $$TurnosTableCreateCompanionBuilder,
      $$TurnosTableUpdateCompanionBuilder,
      (Turno, BaseReferences<_$BaseDatos, $TurnosTable, Turno>),
      Turno,
      PrefetchHooks Function()
    >;
typedef $$MesasTableCreateCompanionBuilder =
    MesasCompanion Function({
      Value<int> id,
      required String alias,
      Value<int> orden,
    });
typedef $$MesasTableUpdateCompanionBuilder =
    MesasCompanion Function({
      Value<int> id,
      Value<String> alias,
      Value<int> orden,
    });

class $$MesasTableFilterComposer extends Composer<_$BaseDatos, $MesasTable> {
  $$MesasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MesasTableOrderingComposer extends Composer<_$BaseDatos, $MesasTable> {
  $$MesasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MesasTableAnnotationComposer
    extends Composer<_$BaseDatos, $MesasTable> {
  $$MesasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);
}

class $$MesasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $MesasTable,
          Mesa,
          $$MesasTableFilterComposer,
          $$MesasTableOrderingComposer,
          $$MesasTableAnnotationComposer,
          $$MesasTableCreateCompanionBuilder,
          $$MesasTableUpdateCompanionBuilder,
          (Mesa, BaseReferences<_$BaseDatos, $MesasTable, Mesa>),
          Mesa,
          PrefetchHooks Function()
        > {
  $$MesasTableTableManager(_$BaseDatos db, $MesasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MesasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MesasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MesasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => MesasCompanion(id: id, alias: alias, orden: orden),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String alias,
                Value<int> orden = const Value.absent(),
              }) => MesasCompanion.insert(id: id, alias: alias, orden: orden),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MesasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $MesasTable,
      Mesa,
      $$MesasTableFilterComposer,
      $$MesasTableOrderingComposer,
      $$MesasTableAnnotationComposer,
      $$MesasTableCreateCompanionBuilder,
      $$MesasTableUpdateCompanionBuilder,
      (Mesa, BaseReferences<_$BaseDatos, $MesasTable, Mesa>),
      Mesa,
      PrefetchHooks Function()
    >;
typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      required String nombre,
      Value<int?> padreId,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<int?> padreId,
    });

class $$CategoriasTableFilterComposer
    extends Composer<_$BaseDatos, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get padreId => $composableBuilder(
    column: $table.padreId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$BaseDatos, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get padreId => $composableBuilder(
    column: $table.padreId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$BaseDatos, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get padreId =>
      $composableBuilder(column: $table.padreId, builder: (column) => column);
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (Categoria, BaseReferences<_$BaseDatos, $CategoriasTable, Categoria>),
          Categoria,
          PrefetchHooks Function()
        > {
  $$CategoriasTableTableManager(_$BaseDatos db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int?> padreId = const Value.absent(),
              }) =>
                  CategoriasCompanion(id: id, nombre: nombre, padreId: padreId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<int?> padreId = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                nombre: nombre,
                padreId: padreId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, BaseReferences<_$BaseDatos, $CategoriasTable, Categoria>),
      Categoria,
      PrefetchHooks Function()
    >;
typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      required String nombre,
      required double precio,
      Value<int?> categoriaId,
      Value<bool> activo,
      Value<String> gruposJson,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<double> precio,
      Value<int?> categoriaId,
      Value<bool> activo,
      Value<String> gruposJson,
    });

class $$ProductosTableFilterComposer
    extends Composer<_$BaseDatos, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gruposJson => $composableBuilder(
    column: $table.gruposJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosTableOrderingComposer
    extends Composer<_$BaseDatos, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gruposJson => $composableBuilder(
    column: $table.gruposJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$BaseDatos, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<String> get gruposJson => $composableBuilder(
    column: $table.gruposJson,
    builder: (column) => column,
  );
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ProductosTable,
          Producto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (Producto, BaseReferences<_$BaseDatos, $ProductosTable, Producto>),
          Producto,
          PrefetchHooks Function()
        > {
  $$ProductosTableTableManager(_$BaseDatos db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> precio = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<String> gruposJson = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                nombre: nombre,
                precio: precio,
                categoriaId: categoriaId,
                activo: activo,
                gruposJson: gruposJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required double precio,
                Value<int?> categoriaId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<String> gruposJson = const Value.absent(),
              }) => ProductosCompanion.insert(
                id: id,
                nombre: nombre,
                precio: precio,
                categoriaId: categoriaId,
                activo: activo,
                gruposJson: gruposJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ProductosTable,
      Producto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (Producto, BaseReferences<_$BaseDatos, $ProductosTable, Producto>),
      Producto,
      PrefetchHooks Function()
    >;
typedef $$CuentasTableCreateCompanionBuilder =
    CuentasCompanion Function({
      Value<int> id,
      Value<int?> mesaId,
      required int turnoId,
      Value<String> estado,
      required DateTime abiertaEn,
      Value<DateTime?> cerradaEn,
    });
typedef $$CuentasTableUpdateCompanionBuilder =
    CuentasCompanion Function({
      Value<int> id,
      Value<int?> mesaId,
      Value<int> turnoId,
      Value<String> estado,
      Value<DateTime> abiertaEn,
      Value<DateTime?> cerradaEn,
    });

class $$CuentasTableFilterComposer
    extends Composer<_$BaseDatos, $CuentasTable> {
  $$CuentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnoId => $composableBuilder(
    column: $table.turnoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get abiertaEn => $composableBuilder(
    column: $table.abiertaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cerradaEn => $composableBuilder(
    column: $table.cerradaEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CuentasTableOrderingComposer
    extends Composer<_$BaseDatos, $CuentasTable> {
  $$CuentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnoId => $composableBuilder(
    column: $table.turnoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get abiertaEn => $composableBuilder(
    column: $table.abiertaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cerradaEn => $composableBuilder(
    column: $table.cerradaEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CuentasTableAnnotationComposer
    extends Composer<_$BaseDatos, $CuentasTable> {
  $$CuentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mesaId =>
      $composableBuilder(column: $table.mesaId, builder: (column) => column);

  GeneratedColumn<int> get turnoId =>
      $composableBuilder(column: $table.turnoId, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get abiertaEn =>
      $composableBuilder(column: $table.abiertaEn, builder: (column) => column);

  GeneratedColumn<DateTime> get cerradaEn =>
      $composableBuilder(column: $table.cerradaEn, builder: (column) => column);
}

class $$CuentasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $CuentasTable,
          Cuenta,
          $$CuentasTableFilterComposer,
          $$CuentasTableOrderingComposer,
          $$CuentasTableAnnotationComposer,
          $$CuentasTableCreateCompanionBuilder,
          $$CuentasTableUpdateCompanionBuilder,
          (Cuenta, BaseReferences<_$BaseDatos, $CuentasTable, Cuenta>),
          Cuenta,
          PrefetchHooks Function()
        > {
  $$CuentasTableTableManager(_$BaseDatos db, $CuentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mesaId = const Value.absent(),
                Value<int> turnoId = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime> abiertaEn = const Value.absent(),
                Value<DateTime?> cerradaEn = const Value.absent(),
              }) => CuentasCompanion(
                id: id,
                mesaId: mesaId,
                turnoId: turnoId,
                estado: estado,
                abiertaEn: abiertaEn,
                cerradaEn: cerradaEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> mesaId = const Value.absent(),
                required int turnoId,
                Value<String> estado = const Value.absent(),
                required DateTime abiertaEn,
                Value<DateTime?> cerradaEn = const Value.absent(),
              }) => CuentasCompanion.insert(
                id: id,
                mesaId: mesaId,
                turnoId: turnoId,
                estado: estado,
                abiertaEn: abiertaEn,
                cerradaEn: cerradaEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CuentasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $CuentasTable,
      Cuenta,
      $$CuentasTableFilterComposer,
      $$CuentasTableOrderingComposer,
      $$CuentasTableAnnotationComposer,
      $$CuentasTableCreateCompanionBuilder,
      $$CuentasTableUpdateCompanionBuilder,
      (Cuenta, BaseReferences<_$BaseDatos, $CuentasTable, Cuenta>),
      Cuenta,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required int cuentaId,
      Value<int?> productoId,
      required String nombre,
      Value<String> variantesJson,
      required int cantidad,
      required double precioUnitario,
      Value<String> estado,
      required DateTime agregadoEn,
      Value<DateTime?> entregadoEn,
      required int tandaId,
      Value<String?> parteId,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<int> cuentaId,
      Value<int?> productoId,
      Value<String> nombre,
      Value<String> variantesJson,
      Value<int> cantidad,
      Value<double> precioUnitario,
      Value<String> estado,
      Value<DateTime> agregadoEn,
      Value<DateTime?> entregadoEn,
      Value<int> tandaId,
      Value<String?> parteId,
    });

class $$ItemsTableFilterComposer extends Composer<_$BaseDatos, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantesJson => $composableBuilder(
    column: $table.variantesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get agregadoEn => $composableBuilder(
    column: $table.agregadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entregadoEn => $composableBuilder(
    column: $table.entregadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tandaId => $composableBuilder(
    column: $table.tandaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parteId => $composableBuilder(
    column: $table.parteId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer extends Composer<_$BaseDatos, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantesJson => $composableBuilder(
    column: $table.variantesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get agregadoEn => $composableBuilder(
    column: $table.agregadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entregadoEn => $composableBuilder(
    column: $table.entregadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tandaId => $composableBuilder(
    column: $table.tandaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parteId => $composableBuilder(
    column: $table.parteId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$BaseDatos, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cuentaId =>
      $composableBuilder(column: $table.cuentaId, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get variantesJson => $composableBuilder(
    column: $table.variantesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get agregadoEn => $composableBuilder(
    column: $table.agregadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entregadoEn => $composableBuilder(
    column: $table.entregadoEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tandaId =>
      $composableBuilder(column: $table.tandaId, builder: (column) => column);

  GeneratedColumn<String> get parteId =>
      $composableBuilder(column: $table.parteId, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$BaseDatos, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$BaseDatos db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cuentaId = const Value.absent(),
                Value<int?> productoId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> variantesJson = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime> agregadoEn = const Value.absent(),
                Value<DateTime?> entregadoEn = const Value.absent(),
                Value<int> tandaId = const Value.absent(),
                Value<String?> parteId = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                cuentaId: cuentaId,
                productoId: productoId,
                nombre: nombre,
                variantesJson: variantesJson,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                estado: estado,
                agregadoEn: agregadoEn,
                entregadoEn: entregadoEn,
                tandaId: tandaId,
                parteId: parteId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cuentaId,
                Value<int?> productoId = const Value.absent(),
                required String nombre,
                Value<String> variantesJson = const Value.absent(),
                required int cantidad,
                required double precioUnitario,
                Value<String> estado = const Value.absent(),
                required DateTime agregadoEn,
                Value<DateTime?> entregadoEn = const Value.absent(),
                required int tandaId,
                Value<String?> parteId = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                cuentaId: cuentaId,
                productoId: productoId,
                nombre: nombre,
                variantesJson: variantesJson,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                estado: estado,
                agregadoEn: agregadoEn,
                entregadoEn: entregadoEn,
                tandaId: tandaId,
                parteId: parteId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$BaseDatos, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$PagosTableCreateCompanionBuilder =
    PagosCompanion Function({
      Value<int> id,
      required int cuentaId,
      required int turnoId,
      required String etiqueta,
      required double monto,
      required double efectivo,
      required double transferencia,
      Value<double?> recibido,
      Value<double?> vuelto,
      required DateTime creadoEn,
    });
typedef $$PagosTableUpdateCompanionBuilder =
    PagosCompanion Function({
      Value<int> id,
      Value<int> cuentaId,
      Value<int> turnoId,
      Value<String> etiqueta,
      Value<double> monto,
      Value<double> efectivo,
      Value<double> transferencia,
      Value<double?> recibido,
      Value<double?> vuelto,
      Value<DateTime> creadoEn,
    });

class $$PagosTableFilterComposer extends Composer<_$BaseDatos, $PagosTable> {
  $$PagosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnoId => $composableBuilder(
    column: $table.turnoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etiqueta => $composableBuilder(
    column: $table.etiqueta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get efectivo => $composableBuilder(
    column: $table.efectivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transferencia => $composableBuilder(
    column: $table.transferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recibido => $composableBuilder(
    column: $table.recibido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vuelto => $composableBuilder(
    column: $table.vuelto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagosTableOrderingComposer extends Composer<_$BaseDatos, $PagosTable> {
  $$PagosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnoId => $composableBuilder(
    column: $table.turnoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etiqueta => $composableBuilder(
    column: $table.etiqueta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get efectivo => $composableBuilder(
    column: $table.efectivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transferencia => $composableBuilder(
    column: $table.transferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recibido => $composableBuilder(
    column: $table.recibido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vuelto => $composableBuilder(
    column: $table.vuelto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagosTableAnnotationComposer
    extends Composer<_$BaseDatos, $PagosTable> {
  $$PagosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cuentaId =>
      $composableBuilder(column: $table.cuentaId, builder: (column) => column);

  GeneratedColumn<int> get turnoId =>
      $composableBuilder(column: $table.turnoId, builder: (column) => column);

  GeneratedColumn<String> get etiqueta =>
      $composableBuilder(column: $table.etiqueta, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<double> get efectivo =>
      $composableBuilder(column: $table.efectivo, builder: (column) => column);

  GeneratedColumn<double> get transferencia => $composableBuilder(
    column: $table.transferencia,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recibido =>
      $composableBuilder(column: $table.recibido, builder: (column) => column);

  GeneratedColumn<double> get vuelto =>
      $composableBuilder(column: $table.vuelto, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$PagosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $PagosTable,
          Pago,
          $$PagosTableFilterComposer,
          $$PagosTableOrderingComposer,
          $$PagosTableAnnotationComposer,
          $$PagosTableCreateCompanionBuilder,
          $$PagosTableUpdateCompanionBuilder,
          (Pago, BaseReferences<_$BaseDatos, $PagosTable, Pago>),
          Pago,
          PrefetchHooks Function()
        > {
  $$PagosTableTableManager(_$BaseDatos db, $PagosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cuentaId = const Value.absent(),
                Value<int> turnoId = const Value.absent(),
                Value<String> etiqueta = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<double> efectivo = const Value.absent(),
                Value<double> transferencia = const Value.absent(),
                Value<double?> recibido = const Value.absent(),
                Value<double?> vuelto = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => PagosCompanion(
                id: id,
                cuentaId: cuentaId,
                turnoId: turnoId,
                etiqueta: etiqueta,
                monto: monto,
                efectivo: efectivo,
                transferencia: transferencia,
                recibido: recibido,
                vuelto: vuelto,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cuentaId,
                required int turnoId,
                required String etiqueta,
                required double monto,
                required double efectivo,
                required double transferencia,
                Value<double?> recibido = const Value.absent(),
                Value<double?> vuelto = const Value.absent(),
                required DateTime creadoEn,
              }) => PagosCompanion.insert(
                id: id,
                cuentaId: cuentaId,
                turnoId: turnoId,
                etiqueta: etiqueta,
                monto: monto,
                efectivo: efectivo,
                transferencia: transferencia,
                recibido: recibido,
                vuelto: vuelto,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PagosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $PagosTable,
      Pago,
      $$PagosTableFilterComposer,
      $$PagosTableOrderingComposer,
      $$PagosTableAnnotationComposer,
      $$PagosTableCreateCompanionBuilder,
      $$PagosTableUpdateCompanionBuilder,
      (Pago, BaseReferences<_$BaseDatos, $PagosTable, Pago>),
      Pago,
      PrefetchHooks Function()
    >;
typedef $$ComprobantesTableCreateCompanionBuilder =
    ComprobantesCompanion Function({
      Value<int> id,
      required String rutaArchivo,
      required DateTime fecha,
      Value<int?> turnoId,
      Value<int?> mesaId,
      Value<String?> aliasMesa,
      Value<int?> cuentaId,
      Value<int?> pagoId,
      Value<double?> monto,
      Value<String> estado,
      Value<DateTime?> legalizadaEn,
    });
typedef $$ComprobantesTableUpdateCompanionBuilder =
    ComprobantesCompanion Function({
      Value<int> id,
      Value<String> rutaArchivo,
      Value<DateTime> fecha,
      Value<int?> turnoId,
      Value<int?> mesaId,
      Value<String?> aliasMesa,
      Value<int?> cuentaId,
      Value<int?> pagoId,
      Value<double?> monto,
      Value<String> estado,
      Value<DateTime?> legalizadaEn,
    });

class $$ComprobantesTableFilterComposer
    extends Composer<_$BaseDatos, $ComprobantesTable> {
  $$ComprobantesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rutaArchivo => $composableBuilder(
    column: $table.rutaArchivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnoId => $composableBuilder(
    column: $table.turnoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasMesa => $composableBuilder(
    column: $table.aliasMesa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagoId => $composableBuilder(
    column: $table.pagoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get legalizadaEn => $composableBuilder(
    column: $table.legalizadaEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ComprobantesTableOrderingComposer
    extends Composer<_$BaseDatos, $ComprobantesTable> {
  $$ComprobantesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rutaArchivo => $composableBuilder(
    column: $table.rutaArchivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnoId => $composableBuilder(
    column: $table.turnoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasMesa => $composableBuilder(
    column: $table.aliasMesa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagoId => $composableBuilder(
    column: $table.pagoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get legalizadaEn => $composableBuilder(
    column: $table.legalizadaEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ComprobantesTableAnnotationComposer
    extends Composer<_$BaseDatos, $ComprobantesTable> {
  $$ComprobantesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rutaArchivo => $composableBuilder(
    column: $table.rutaArchivo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get turnoId =>
      $composableBuilder(column: $table.turnoId, builder: (column) => column);

  GeneratedColumn<int> get mesaId =>
      $composableBuilder(column: $table.mesaId, builder: (column) => column);

  GeneratedColumn<String> get aliasMesa =>
      $composableBuilder(column: $table.aliasMesa, builder: (column) => column);

  GeneratedColumn<int> get cuentaId =>
      $composableBuilder(column: $table.cuentaId, builder: (column) => column);

  GeneratedColumn<int> get pagoId =>
      $composableBuilder(column: $table.pagoId, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get legalizadaEn => $composableBuilder(
    column: $table.legalizadaEn,
    builder: (column) => column,
  );
}

class $$ComprobantesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ComprobantesTable,
          Comprobante,
          $$ComprobantesTableFilterComposer,
          $$ComprobantesTableOrderingComposer,
          $$ComprobantesTableAnnotationComposer,
          $$ComprobantesTableCreateCompanionBuilder,
          $$ComprobantesTableUpdateCompanionBuilder,
          (
            Comprobante,
            BaseReferences<_$BaseDatos, $ComprobantesTable, Comprobante>,
          ),
          Comprobante,
          PrefetchHooks Function()
        > {
  $$ComprobantesTableTableManager(_$BaseDatos db, $ComprobantesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprobantesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprobantesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprobantesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rutaArchivo = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int?> turnoId = const Value.absent(),
                Value<int?> mesaId = const Value.absent(),
                Value<String?> aliasMesa = const Value.absent(),
                Value<int?> cuentaId = const Value.absent(),
                Value<int?> pagoId = const Value.absent(),
                Value<double?> monto = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> legalizadaEn = const Value.absent(),
              }) => ComprobantesCompanion(
                id: id,
                rutaArchivo: rutaArchivo,
                fecha: fecha,
                turnoId: turnoId,
                mesaId: mesaId,
                aliasMesa: aliasMesa,
                cuentaId: cuentaId,
                pagoId: pagoId,
                monto: monto,
                estado: estado,
                legalizadaEn: legalizadaEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rutaArchivo,
                required DateTime fecha,
                Value<int?> turnoId = const Value.absent(),
                Value<int?> mesaId = const Value.absent(),
                Value<String?> aliasMesa = const Value.absent(),
                Value<int?> cuentaId = const Value.absent(),
                Value<int?> pagoId = const Value.absent(),
                Value<double?> monto = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> legalizadaEn = const Value.absent(),
              }) => ComprobantesCompanion.insert(
                id: id,
                rutaArchivo: rutaArchivo,
                fecha: fecha,
                turnoId: turnoId,
                mesaId: mesaId,
                aliasMesa: aliasMesa,
                cuentaId: cuentaId,
                pagoId: pagoId,
                monto: monto,
                estado: estado,
                legalizadaEn: legalizadaEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ComprobantesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ComprobantesTable,
      Comprobante,
      $$ComprobantesTableFilterComposer,
      $$ComprobantesTableOrderingComposer,
      $$ComprobantesTableAnnotationComposer,
      $$ComprobantesTableCreateCompanionBuilder,
      $$ComprobantesTableUpdateCompanionBuilder,
      (
        Comprobante,
        BaseReferences<_$BaseDatos, $ComprobantesTable, Comprobante>,
      ),
      Comprobante,
      PrefetchHooks Function()
    >;
typedef $$AjustesTableCreateCompanionBuilder =
    AjustesCompanion Function({
      Value<int> id,
      Value<String> nombreNegocio,
      Value<int> alertaMinutos,
      Value<String> simboloMoneda,
      Value<bool> formato24h,
      Value<int> recordatorioBackupDias,
      Value<DateTime?> ultimaExportacion,
      Value<bool> vibracionActiva,
    });
typedef $$AjustesTableUpdateCompanionBuilder =
    AjustesCompanion Function({
      Value<int> id,
      Value<String> nombreNegocio,
      Value<int> alertaMinutos,
      Value<String> simboloMoneda,
      Value<bool> formato24h,
      Value<int> recordatorioBackupDias,
      Value<DateTime?> ultimaExportacion,
      Value<bool> vibracionActiva,
    });

class $$AjustesTableFilterComposer
    extends Composer<_$BaseDatos, $AjustesTable> {
  $$AjustesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreNegocio => $composableBuilder(
    column: $table.nombreNegocio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertaMinutos => $composableBuilder(
    column: $table.alertaMinutos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get simboloMoneda => $composableBuilder(
    column: $table.simboloMoneda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get formato24h => $composableBuilder(
    column: $table.formato24h,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordatorioBackupDias => $composableBuilder(
    column: $table.recordatorioBackupDias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimaExportacion => $composableBuilder(
    column: $table.ultimaExportacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibracionActiva => $composableBuilder(
    column: $table.vibracionActiva,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AjustesTableOrderingComposer
    extends Composer<_$BaseDatos, $AjustesTable> {
  $$AjustesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreNegocio => $composableBuilder(
    column: $table.nombreNegocio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertaMinutos => $composableBuilder(
    column: $table.alertaMinutos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get simboloMoneda => $composableBuilder(
    column: $table.simboloMoneda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get formato24h => $composableBuilder(
    column: $table.formato24h,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordatorioBackupDias => $composableBuilder(
    column: $table.recordatorioBackupDias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimaExportacion => $composableBuilder(
    column: $table.ultimaExportacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibracionActiva => $composableBuilder(
    column: $table.vibracionActiva,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AjustesTableAnnotationComposer
    extends Composer<_$BaseDatos, $AjustesTable> {
  $$AjustesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreNegocio => $composableBuilder(
    column: $table.nombreNegocio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertaMinutos => $composableBuilder(
    column: $table.alertaMinutos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get simboloMoneda => $composableBuilder(
    column: $table.simboloMoneda,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get formato24h => $composableBuilder(
    column: $table.formato24h,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordatorioBackupDias => $composableBuilder(
    column: $table.recordatorioBackupDias,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ultimaExportacion => $composableBuilder(
    column: $table.ultimaExportacion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibracionActiva => $composableBuilder(
    column: $table.vibracionActiva,
    builder: (column) => column,
  );
}

class $$AjustesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $AjustesTable,
          Ajuste,
          $$AjustesTableFilterComposer,
          $$AjustesTableOrderingComposer,
          $$AjustesTableAnnotationComposer,
          $$AjustesTableCreateCompanionBuilder,
          $$AjustesTableUpdateCompanionBuilder,
          (Ajuste, BaseReferences<_$BaseDatos, $AjustesTable, Ajuste>),
          Ajuste,
          PrefetchHooks Function()
        > {
  $$AjustesTableTableManager(_$BaseDatos db, $AjustesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AjustesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AjustesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AjustesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombreNegocio = const Value.absent(),
                Value<int> alertaMinutos = const Value.absent(),
                Value<String> simboloMoneda = const Value.absent(),
                Value<bool> formato24h = const Value.absent(),
                Value<int> recordatorioBackupDias = const Value.absent(),
                Value<DateTime?> ultimaExportacion = const Value.absent(),
                Value<bool> vibracionActiva = const Value.absent(),
              }) => AjustesCompanion(
                id: id,
                nombreNegocio: nombreNegocio,
                alertaMinutos: alertaMinutos,
                simboloMoneda: simboloMoneda,
                formato24h: formato24h,
                recordatorioBackupDias: recordatorioBackupDias,
                ultimaExportacion: ultimaExportacion,
                vibracionActiva: vibracionActiva,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombreNegocio = const Value.absent(),
                Value<int> alertaMinutos = const Value.absent(),
                Value<String> simboloMoneda = const Value.absent(),
                Value<bool> formato24h = const Value.absent(),
                Value<int> recordatorioBackupDias = const Value.absent(),
                Value<DateTime?> ultimaExportacion = const Value.absent(),
                Value<bool> vibracionActiva = const Value.absent(),
              }) => AjustesCompanion.insert(
                id: id,
                nombreNegocio: nombreNegocio,
                alertaMinutos: alertaMinutos,
                simboloMoneda: simboloMoneda,
                formato24h: formato24h,
                recordatorioBackupDias: recordatorioBackupDias,
                ultimaExportacion: ultimaExportacion,
                vibracionActiva: vibracionActiva,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AjustesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $AjustesTable,
      Ajuste,
      $$AjustesTableFilterComposer,
      $$AjustesTableOrderingComposer,
      $$AjustesTableAnnotationComposer,
      $$AjustesTableCreateCompanionBuilder,
      $$AjustesTableUpdateCompanionBuilder,
      (Ajuste, BaseReferences<_$BaseDatos, $AjustesTable, Ajuste>),
      Ajuste,
      PrefetchHooks Function()
    >;

class $BaseDatosManager {
  final _$BaseDatos _db;
  $BaseDatosManager(this._db);
  $$TurnosTableTableManager get turnos =>
      $$TurnosTableTableManager(_db, _db.turnos);
  $$MesasTableTableManager get mesas =>
      $$MesasTableTableManager(_db, _db.mesas);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$CuentasTableTableManager get cuentas =>
      $$CuentasTableTableManager(_db, _db.cuentas);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$PagosTableTableManager get pagos =>
      $$PagosTableTableManager(_db, _db.pagos);
  $$ComprobantesTableTableManager get comprobantes =>
      $$ComprobantesTableTableManager(_db, _db.comprobantes);
  $$AjustesTableTableManager get ajustes =>
      $$AjustesTableTableManager(_db, _db.ajustes);
}
