// Lógica pura de cuentas: totales, saldos, precios con variantes y las
// operaciones de negocio (tandas, cierre de cuenta y de turno con su
// restricción — reglas 1b, 5, 6 y 12 del documento de planificación).

import 'package:drift/drift.dart';

import '../datos/base.dart';
import '../datos/modelos.dart';
import 'dinero.dart';

double totalItem(Item item) => redondear(item.precioUnitario * item.cantidad);

double totalItems(List<Item> lista) =>
    redondear(lista.fold(0.0, (s, it) => s + totalItem(it)));

double totalPagado(List<Pago> lista) =>
    redondear(lista.fold(0.0, (s, p) => s + p.monto));

double saldoCuenta(List<Item> itemsCuenta, List<Pago> pagosCuenta) =>
    redondear(totalItems(itemsCuenta) - totalPagado(pagosCuenta));

double precioUnitario(Producto producto, List<SeleccionVariante> variantes) =>
    redondear(producto.precio + variantes.fold(0.0, (s, v) => s + v.delta));

// Reparte un saldo en n partes iguales a centavos; la última absorbe el residuo.
List<double> partesIguales(double saldo, int n) {
  final base = (saldo / n * 100).floorToDouble() / 100;
  return List.generate(
    n,
    (i) => i == n - 1 ? redondear(saldo - base * (n - 1)) : base,
  );
}

// Línea elegida en el selector, aún no confirmada.
class LineaNueva {
  final Producto producto;
  final List<SeleccionVariante> variantes;
  final int cantidad;

  const LineaNueva({required this.producto, required this.variantes, required this.cantidad});

  double get unitario => precioUnitario(producto, variantes);
  double get total => redondear(unitario * cantidad);
}

// Agrega una tanda de productos a una cuenta. Los ítems siempre nacen
// "pendientes" (regla 12).
Future<void> agregarTanda(
  BaseDatos db,
  int cuentaId,
  List<LineaNueva> lineas,
) async {
  final ahora = DateTime.now();
  await db.batch((b) {
    b.insertAll(db.items, [
      for (final l in lineas)
        ItemsCompanion.insert(
          cuentaId: cuentaId,
          productoId: Value(l.producto.id),
          nombre: l.producto.nombre,
          variantesJson: Value(seleccionesAJson(l.variantes)),
          cantidad: l.cantidad,
          precioUnitario: l.unitario,
          estado: const Value('pendiente'),
          agregadoEn: ahora,
          tandaId: ahora.millisecondsSinceEpoch,
        ),
    ]);
  });
}

class MesaConSaldo {
  final int? mesaId;
  final String alias;
  final double saldo;
  const MesaConSaldo({required this.mesaId, required this.alias, required this.saldo});
}

// Mesas del turno con saldo pendiente: bloquean el cierre (regla 1b).
Future<List<MesaConSaldo>> mesasConSaldoPendiente(BaseDatos db, int turnoId) async {
  final abiertas = await (db.select(db.cuentas)
        ..where((c) => c.turnoId.equals(turnoId) & c.estado.equals('abierta')))
      .get();
  final resultado = <MesaConSaldo>[];
  for (final c in abiertas) {
    final itemsCuenta =
        await (db.select(db.items)..where((i) => i.cuentaId.equals(c.id))).get();
    final pagosCuenta =
        await (db.select(db.pagos)..where((p) => p.cuentaId.equals(c.id))).get();
    final saldo = saldoCuenta(itemsCuenta, pagosCuenta);
    if (saldo > 0) {
      final mesa = c.mesaId == null
          ? null
          : await (db.select(db.mesas)..where((m) => m.id.equals(c.mesaId!)))
              .getSingleOrNull();
      resultado.add(MesaConSaldo(
        mesaId: c.mesaId,
        alias: mesa?.alias ?? 'Venta directa',
        saldo: saldo,
      ));
    }
  }
  return resultado;
}

class ResultadoCierre {
  final bool ok;
  final List<MesaConSaldo> bloqueos;
  const ResultadoCierre(this.ok, this.bloqueos);
}

// Cierra el turno solo si ninguna mesa tiene saldo; las cuentas abiertas
// en $0 se cierran junto con el turno.
Future<ResultadoCierre> cerrarTurno(BaseDatos db, int turnoId) async {
  final bloqueos = await mesasConSaldoPendiente(db, turnoId);
  if (bloqueos.isNotEmpty) return ResultadoCierre(false, bloqueos);
  final abiertas = await (db.select(db.cuentas)
        ..where((c) => c.turnoId.equals(turnoId) & c.estado.equals('abierta')))
      .get();
  for (final c in abiertas) {
    await db.cerrarCuenta(c.id);
  }
  await (db.update(db.turnos)..where((t) => t.id.equals(turnoId))).write(TurnosCompanion(
    estado: const Value('cerrado'),
    fin: Value(DateTime.now()),
  ));
  return const ResultadoCierre(true, []);
}
