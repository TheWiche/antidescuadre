// Venta directa (sección 3.2): barra o caja — se pide y se cobra al momento,
// sin cuenta persistente de mesa.

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/proveedores.dart';
import '../logica/cuentas.dart';
import '../logica/dinero.dart';
import '../tema/tema.dart';
import '../widgets/comunes.dart';
import '../widgets/factura_vista.dart';
import '../widgets/flujo_cobro.dart';
import '../widgets/hoja.dart';
import '../widgets/selector_productos.dart';

class PantallaVender extends ConsumerWidget {
  const PantallaVender({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turno = ref.watch(turnoActivoProv);

    return SafeArea(
      child: switch (turno) {
        AsyncData(value: final t) when t == null => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Text('Venta directa', style: Theme.of(context).textTheme.headlineLarge),
              const SinTurno(mensaje: 'Inicia el turno para vender en barra o caja.'),
            ],
          ),
        AsyncData(value: final t?) => _Contenido(turno: t),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Contenido extends ConsumerWidget {
  final Turno turno;
  const _Contenido({required this.turno});

  Future<void> _nuevaVenta(BuildContext context, WidgetRef ref) async {
    final db = ref.read(baseDatos);
    final lineas = await SelectorProductos.abrir(
      context,
      titulo: 'Venta directa',
      textoConfirmar: 'Cobrar',
    );
    if (lineas == null || lineas.isEmpty) return;

    final cuentaId = await db.into(db.cuentas).insert(CuentasCompanion.insert(
          turnoId: turno.id,
          abiertaEn: DateTime.now(),
          esDirecta: const Value(true),
        ));
    // En barra los ítems nacen entregados: se sirven al momento
    await agregarTanda(db, cuentaId, lineas, entregadoInmediato: true);

    if (!context.mounted) return;
    final saldada = await PantallaCobro.abrir(
      context,
      cuentaId: cuentaId,
      turnoId: turno.id,
      mesaId: null,
      mesaAlias: 'Venta directa',
      soloTotal: true,
    );
    if (saldada) {
      if (context.mounted) await mostrarSello(context, 'Venta cobrada');
    } else {
      // Venta abandonada sin ningún cobro: se descarta
      final suyos = await (db.select(db.pagos)
            ..where((p) => p.cuentaId.equals(cuentaId)))
          .get();
      if (suyos.isEmpty) {
        await (db.delete(db.items)..where((i) => i.cuentaId.equals(cuentaId))).go();
        await (db.delete(db.cuentas)..where((c) => c.id.equals(cuentaId))).go();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(baseDatos);
    final pagos = ref.watch(pagosDeTurnoProv(turno.id)).value ?? [];
    final ventas = ref.watch(_ventasDirectasProv(turno.id)).value ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text('Venta directa', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        const Text('Barra o caja: se pide y se cobra al momento.',
            style: TextStyle(color: C.crema60, fontSize: 14)),
        const SizedBox(height: 16),
        Boton('Nueva venta', icono: LucideIcons.zap, alto: 60, expandir: true,
            alTocar: () => _nuevaVenta(context, ref)),
        const SizedBox(height: 20),
        if (ventas.isEmpty)
          const Vacio(icono: LucideIcons.beer,
              titulo: 'Aún no hay ventas directas en este turno')
        else
          Tarjeta(
            relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(children: [
              for (final v in ventas)
                Builder(builder: (_) {
                  final pago = pagos.where((p) => p.cuentaId == v.id).toList();
                  final total = redondear(pago.fold(0.0, (s, p) => s + p.monto));
                  final ef = pago.fold(0.0, (s, p) => s + p.efectivo);
                  final tr = pago.fold(0.0, (s, p) => s + p.transferencia);
                  return InkWell(
                    onTap: () async {
                      final itemsVenta = await (db.select(db.items)
                            ..where((i) => i.cuentaId.equals(v.id)))
                          .get();
                      if (!context.mounted) return;
                      final ajustes = ref.read(ajustesProv).value;
                      await mostrarHoja(context, constructor: (_) => FacturaVista(
                            nombreNegocio: ajustes?.nombreNegocio ?? 'Mi bar',
                            alias: 'Venta directa',
                            fecha: v.abiertaEn,
                            items: itemsVenta,
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        Text(horaCorta(v.abiertaEn),
                            style: estiloMono(tamano: 12, color: C.crema38)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(dinero(total),
                            style: estiloMono(peso: FontWeight.w700, tamano: 15))),
                        if (ef > 0)
                          const Icon(LucideIcons.banknote, size: 15, color: C.ambar),
                        if (ef > 0 && tr > 0) const SizedBox(width: 6),
                        if (tr > 0)
                          const Icon(LucideIcons.landmark, size: 15, color: C.cian),
                      ]),
                    ),
                  );
                }),
            ]),
          ),
      ],
    );
  }
}

final _ventasDirectasProv = StreamProvider.family<List<Cuenta>, int>(
  (ref, turnoId) {
    final db = ref.watch(baseDatos);
    final q = db.select(db.cuentas)
      ..where((c) =>
          c.turnoId.equals(turnoId) & c.esDirecta.equals(true) & c.estado.equals('cerrada'))
      ..orderBy([(c) => OrderingTerm.desc(c.abiertaEn)]);
    return q.watch();
  },
);
