// Base de datos local (SQLite vía Drift), offline-first y reactiva.
// Espejo del modelo de datos de planificacion-app-cuadre.md (sección 6).

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'base.g.dart';

class Turnos extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fin => dateTime().nullable()();
  TextColumn get estado => text().withDefault(const Constant('activo'))(); // activo | cerrado
}

class Mesas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get alias => text()(); // 100% editable, sin número fijo (regla 3)
  IntColumn get orden => integer().withDefault(const Constant(0))();
}

class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  IntColumn get padreId => integer().nullable()(); // anidación libre
}

class Productos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  RealColumn get precio => real()(); // precio base
  IntColumn get categoriaId => integer().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  TextColumn get gruposJson => text().withDefault(const Constant('[]'))(); // variantes anidadas
}

class Cuentas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mesaId => integer().nullable()(); // null = venta directa
  IntColumn get turnoId => integer()();
  TextColumn get estado => text().withDefault(const Constant('abierta'))(); // abierta | cerrada
  DateTimeColumn get abiertaEn => dateTime()();
  DateTimeColumn get cerradaEn => dateTime().nullable()();
  BoolColumn get esDirecta => boolean().withDefault(const Constant(false))();
}

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cuentaId => integer()();
  IntColumn get productoId => integer().nullable()();
  TextColumn get nombre => text()(); // congelado al agregar
  TextColumn get variantesJson => text().withDefault(const Constant('[]'))();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real()(); // congelado al agregar (base + deltas)
  TextColumn get estado => text().withDefault(const Constant('pendiente'))(); // pendiente | entregado
  DateTimeColumn get agregadoEn => dateTime()();
  DateTimeColumn get entregadoEn => dateTime().nullable()();
  IntColumn get tandaId => integer()(); // agrupa lo confirmado junto (factura cronológica)
  TextColumn get parteId => text().nullable()(); // asignación en división por consumo
}

// Una "parte" de pago cobrada; puede combinar efectivo y transferencia (regla 7).
class Pagos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cuentaId => integer()();
  IntColumn get turnoId => integer()();
  TextColumn get etiqueta => text()();
  RealColumn get monto => real()();
  RealColumn get efectivo => real()();
  RealColumn get transferencia => real()();
  RealColumn get recibido => real().nullable()(); // para el vuelto (opcional, regla 11)
  RealColumn get vuelto => real().nullable()();
  DateTimeColumn get creadoEn => dateTime()();
}

class Comprobantes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rutaArchivo => text()(); // foto en el almacenamiento de la app
  DateTimeColumn get fecha => dateTime()();
  IntColumn get turnoId => integer().nullable()();
  IntColumn get mesaId => integer().nullable()(); // captura libre => null (regla 10)
  TextColumn get aliasMesa => text().nullable()(); // congelado para historial
  IntColumn get cuentaId => integer().nullable()();
  IntColumn get pagoId => integer().nullable()();
  RealColumn get monto => real().nullable()();
  TextColumn get estado => text().withDefault(const Constant('pendiente'))(); // pendiente | legalizada
  DateTimeColumn get legalizadaEn => dateTime().nullable()();
}

class Ajustes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombreNegocio => text().withDefault(const Constant('Mi bar'))();
  IntColumn get alertaMinutos => integer().withDefault(const Constant(10))(); // único valor global (regla 13)
}

@DriftDatabase(tables: [
  Turnos, Mesas, Categorias, Productos, Cuentas, Items, Pagos, Comprobantes, Ajustes,
])
class BaseDatos extends _$BaseDatos {
  BaseDatos() : super(driftDatabase(name: 'antidescuadre'));

  BaseDatos.prueba(super.e); // para tests con NativeDatabase.memory()

  @override
  int get schemaVersion => 1;

  // ---------- Ajustes ----------
  Stream<Ajuste> verAjustes() =>
      select(ajustes).watchSingleOrNull().map((a) =>
          a ?? const Ajuste(id: 0, nombreNegocio: 'Mi bar', alertaMinutos: 10));

  Future<void> guardarAjustes({String? nombreNegocio, int? alertaMinutos}) async {
    final actual = await select(ajustes).getSingleOrNull();
    if (actual == null) {
      await into(ajustes).insert(AjustesCompanion.insert(
        nombreNegocio: Value(nombreNegocio ?? 'Mi bar'),
        alertaMinutos: Value(alertaMinutos ?? 10),
      ));
    } else {
      await (update(ajustes)..where((a) => a.id.equals(actual.id))).write(AjustesCompanion(
        nombreNegocio: nombreNegocio != null ? Value(nombreNegocio) : const Value.absent(),
        alertaMinutos: alertaMinutos != null ? Value(alertaMinutos) : const Value.absent(),
      ));
    }
  }

  // ---------- Turno (regla 1: el punto de partida de todo) ----------
  Stream<Turno?> verTurnoActivo() =>
      (select(turnos)..where((t) => t.estado.equals('activo'))).watchSingleOrNull();

  Future<Turno?> turnoActivo() =>
      (select(turnos)..where((t) => t.estado.equals('activo'))).getSingleOrNull();

  Future<int> iniciarTurno() =>
      into(turnos).insert(TurnosCompanion.insert(inicio: DateTime.now()));

  Stream<List<Turno>> verTurnosCerrados() => (select(turnos)
        ..where((t) => t.estado.equals('cerrado'))
        ..orderBy([(t) => OrderingTerm.desc(t.inicio)]))
      .watch();

  // ---------- Mesas ----------
  Stream<List<Mesa>> verMesas() =>
      (select(mesas)..orderBy([(m) => OrderingTerm.asc(m.orden)])).watch();

  // ---------- Cuentas ----------
  Stream<Cuenta?> verCuentaActivaDeMesa(int mesaId) => (select(cuentas)
        ..where((c) => c.mesaId.equals(mesaId) & c.estado.equals('abierta')))
      .watchSingleOrNull();

  Stream<List<Cuenta>> verCuentasAbiertas(int turnoId) => (select(cuentas)
        ..where((c) => c.turnoId.equals(turnoId) & c.estado.equals('abierta')))
      .watch();

  Future<int> abrirCuentaEnMesa(int mesaId, int turnoId) =>
      into(cuentas).insert(CuentasCompanion.insert(
        mesaId: Value(mesaId),
        turnoId: turnoId,
        abiertaEn: DateTime.now(),
      ));

  Future<void> cerrarCuenta(int cuentaId) async {
    await (update(cuentas)..where((c) => c.id.equals(cuentaId))).write(CuentasCompanion(
      estado: const Value('cerrada'),
      cerradaEn: Value(DateTime.now()),
    ));
  }

  // ---------- Items ----------
  Stream<List<Item>> verItemsDeCuenta(int cuentaId) => (select(items)
        ..where((i) => i.cuentaId.equals(cuentaId))
        ..orderBy([(i) => OrderingTerm.asc(i.agregadoEn), (i) => OrderingTerm.asc(i.id)]))
      .watch();

  Stream<List<Item>> verItemsDeCuentas(List<int> cuentaIds) {
    if (cuentaIds.isEmpty) return Stream.value(const []);
    return (select(items)..where((i) => i.cuentaId.isIn(cuentaIds))).watch();
  }

  // Ítems de las cuentas abiertas de un turno (dashboard y pendientes)
  Stream<List<Item>> verItemsAbiertosDeTurno(int turnoId) {
    final q = select(items).join([
      innerJoin(cuentas, cuentas.id.equalsExp(items.cuentaId)),
    ])
      ..where(cuentas.turnoId.equals(turnoId) & cuentas.estado.equals('abierta'));
    return q.watch().map((filas) => filas.map((f) => f.readTable(items)).toList());
  }

  Stream<List<Pago>> verPagosDeCuentasAbiertas(int turnoId) {
    final q = select(pagos).join([
      innerJoin(cuentas, cuentas.id.equalsExp(pagos.cuentaId)),
    ])
      ..where(cuentas.turnoId.equals(turnoId) & cuentas.estado.equals('abierta'));
    return q.watch().map((filas) => filas.map((f) => f.readTable(pagos)).toList());
  }

  // ---------- Pagos ----------
  Stream<List<Pago>> verPagosDeCuenta(int cuentaId) =>
      (select(pagos)..where((p) => p.cuentaId.equals(cuentaId))).watch();

  Stream<List<Pago>> verPagosDeTurno(int turnoId) =>
      (select(pagos)..where((p) => p.turnoId.equals(turnoId))).watch();

  Stream<List<Pago>> verPagosDeCuentas(List<int> cuentaIds) {
    if (cuentaIds.isEmpty) return Stream.value(const []);
    return (select(pagos)..where((p) => p.cuentaId.isIn(cuentaIds))).watch();
  }

  // ---------- Comprobantes ----------
  Stream<int> verPendientesLegalizar() {
    final cuenta = comprobantes.id.count();
    final q = selectOnly(comprobantes)
      ..addColumns([cuenta])
      ..where(comprobantes.estado.equals('pendiente'));
    return q.watchSingle().map((fila) => fila.read(cuenta) ?? 0);
  }

  Stream<List<Comprobante>> verComprobantes(String estado) => (select(comprobantes)
        ..where((c) => c.estado.equals(estado))
        ..orderBy([(c) => OrderingTerm.desc(c.fecha)]))
      .watch();

  Future<void> legalizarComprobante(int id) async {
    await (update(comprobantes)..where((c) => c.id.equals(id))).write(ComprobantesCompanion(
      estado: const Value('legalizada'),
      legalizadaEn: Value(DateTime.now()),
    ));
  }
}
