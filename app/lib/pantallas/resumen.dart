// Turno + dashboard (secciones 3.1 y 3.8): iniciar/cerrar turno con la
// restricción de saldos (regla 1b), totales cobrados por método, pendiente
// por cobrar por mesa, contadores y turnos anteriores.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/proveedores.dart';
import '../logica/cuentas.dart';
import '../logica/dinero.dart';
import '../tema/tema.dart';
import '../widgets/hoja.dart';

class PantallaResumen extends ConsumerWidget {
  const PantallaResumen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turno = ref.watch(turnoActivoProv);
    final ajustes = ref.watch(ajustesProv).value;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text(ajustes?.nombreNegocio ?? '', style: const TextStyle(color: C.crema60, fontSize: 14)),
          const SizedBox(height: 2),
          Text('AntiDescuadre', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 18),
          switch (turno) {
            AsyncData(value: final t?) => _TurnoActivo(turno: t),
            AsyncData() => const _InicioJornada(),
            _ => const SizedBox(height: 200),
          },
          const SizedBox(height: 12),
          const _Historial(),
        ],
      ),
    );
  }
}

class _InicioJornada extends ConsumerWidget {
  const _InicioJornada();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Tarjeta(
        relleno: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(children: [
          const Icon(LucideIcons.sunrise, size: 42, color: C.ambar),
          const SizedBox(height: 10),
          Text('Empieza la jornada', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          const Text(
            'El turno es el punto de partida: ventas, mesas y cobros quedan asociados a él.',
            textAlign: TextAlign.center,
            style: TextStyle(color: C.crema60),
          ),
          const SizedBox(height: 20),
          Boton('Iniciar turno', expandir: true, alto: 54,
              alTocar: () => ref.read(baseDatos).iniciarTurno()),
        ]),
      );
}

class _TurnoActivo extends ConsumerWidget {
  final Turno turno;
  const _TurnoActivo({required this.turno});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(baseDatos);
    final pagos = ref.watch(pagosDeTurnoProv(turno.id)).value ?? [];
    final abiertas = ref.watch(cuentasAbiertasProv(turno.id)).value ?? [];
    final itemsAbiertos = ref.watch(itemsAbiertosDeTurnoProv(turno.id)).value ?? [];
    final pagosAbiertos = ref.watch(pagosAbiertosDeTurnoProv(turno.id)).value ?? [];
    final mesas = ref.watch(mesasProv).value ?? [];
    final comprobantesPend = ref.watch(pendientesLegalizarProv).value ?? 0;

    final total = redondear(pagos.fold(0.0, (s, p) => s + p.monto));
    final efectivo = redondear(pagos.fold(0.0, (s, p) => s + p.efectivo));
    final transferencia = redondear(pagos.fold(0.0, (s, p) => s + p.transferencia));
    final porEntregar = itemsAbiertos.where((i) => i.estado == 'pendiente').length;

    final mesasPendientes = <({String alias, double saldo})>[];
    for (final c in abiertas) {
      final saldo = saldoCuenta(
        itemsAbiertos.where((i) => i.cuentaId == c.id).toList(),
        pagosAbiertos.where((p) => p.cuentaId == c.id).toList(),
      );
      if (saldo > 0) {
        final alias = c.mesaId == null
            ? 'Venta directa'
            : mesas.where((m) => m.id == c.mesaId).firstOrNull?.alias ?? 'Mesa';
        mesasPendientes.add((alias: alias, saldo: saldo));
      }
    }
    final totalPendiente =
        redondear(mesasPendientes.fold(0.0, (s, m) => s + m.saldo));

    Future<void> intentarCerrar() async {
      final bloqueos = await mesasConSaldoPendiente(db, turno.id);
      if (!context.mounted) return;
      if (bloqueos.isNotEmpty) {
        await mostrarHoja(context, constructor: (ctx) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const TituloHoja('Aún no puedes cerrar',
                    sub: 'Hay mesas con saldo pendiente. Cóbralas (o déjalas en \$0) para cerrar el turno.'),
                for (final b in bloqueos)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Expanded(child: Text(b.alias,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: C.crema))),
                      Text(dinero(b.saldo), style: estiloMono(color: C.ambar, peso: FontWeight.w700)),
                    ]),
                  ),
                const SizedBox(height: 12),
                Boton('Entendido', tono: TonoBoton.fantasma, expandir: true,
                    alTocar: () => Navigator.pop(ctx)),
              ],
            ));
        return;
      }
      final ok = await confirmar(
        context,
        titulo: '¿Cerrar el turno?',
        detalle:
            'Cobrado: ${dinero(total)} (${dinero(efectivo)} efectivo · ${dinero(transferencia)} transferencia).',
        textoConfirmar: 'Cerrar turno',
      );
      if (ok) await cerrarTurno(db, turno.id);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ChipEstado.menta('Turno activo · desde ${horaCorta(turno.inicio)}'),
        Boton('Cerrar turno', icono: LucideIcons.moon, tono: TonoBoton.fantasma,
            alto: 38, alTocar: intentarCerrar),
      ]),
      const SizedBox(height: 12),

      // Cobrado del turno
      Tarjeta(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const EtiquetaCampo('Cobrado en el turno'),
          Text(dinero(total), style: const TextStyle(
            fontFamily: F.display, fontSize: 38, fontWeight: FontWeight.w700, color: C.crema,
          )),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChipEstado.ambar('${dinero(efectivo)} efectivo',
                icono: LucideIcons.banknote, mono: true),
            ChipEstado.cian('${dinero(transferencia)} transferencia',
                icono: LucideIcons.landmark, mono: true),
          ]),
        ]),
      ),
      const SizedBox(height: 12),

      // Pendiente por cobrar
      Tarjeta(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const EtiquetaCampo('Pendiente por cobrar'),
            Text(dinero(totalPendiente), style: estiloMono(
              tamano: 20, peso: FontWeight.w700,
              color: totalPendiente > 0 ? C.ambar : C.menta,
            )),
          ]),
          for (final m in mesasPendientes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                Expanded(child: Text(m.alias,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                Text(dinero(m.saldo), style: estiloMono()),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 12),

      // Contadores
      Row(children: [
        Expanded(child: _Contador(
          icono: LucideIcons.clipboardList,
          valor: porEntregar,
          texto: 'por entregar',
          activo: C.ambar,
        )),
        const SizedBox(width: 10),
        Expanded(child: _Contador(
          icono: LucideIcons.landmark,
          valor: comprobantesPend,
          texto: 'por legalizar',
          activo: C.cian,
        )),
      ]),
    ]);
  }
}

class _Contador extends StatelessWidget {
  final IconData icono;
  final int valor;
  final String texto;
  final Color activo;
  const _Contador({required this.icono, required this.valor, required this.texto, required this.activo});

  @override
  Widget build(BuildContext context) => Tarjeta(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icono, size: 20, color: valor > 0 ? activo : C.crema38),
          const SizedBox(height: 6),
          Text('$valor', style: estiloMono(tamano: 24, peso: FontWeight.w700)),
          Text(texto, style: const TextStyle(fontSize: 13, color: C.crema60)),
        ]),
      );
}

// Turnos anteriores: el dashboard también se mira por turno/fecha (3.8).
class _Historial extends ConsumerWidget {
  const _Historial();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cerrados = ref.watch(turnosCerradosProv).value ?? [];
    if (cerrados.isEmpty) return const SizedBox.shrink();

    return Tarjeta(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const EtiquetaCampo('Turnos anteriores'),
        for (final t in cerrados.take(14))
          InkWell(
            onTap: () => _verDetalle(context, ref, t),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(children: [
                const Icon(LucideIcons.receipt, size: 17, color: C.crema38),
                const SizedBox(width: 10),
                Expanded(child: Text(fechaCorta(t.inicio),
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                Text(
                  '${horaCorta(t.inicio)}–${t.fin != null ? horaCorta(t.fin!) : ''}',
                  style: estiloMono(tamano: 12, color: C.crema38),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  Future<void> _verDetalle(BuildContext context, WidgetRef ref, Turno t) async {
    final pagos = await (ref.read(baseDatos).select(ref.read(baseDatos).pagos)
          ..where((p) => p.turnoId.equals(t.id)))
        .get();
    final total = redondear(pagos.fold(0.0, (s, p) => s + p.monto));
    final efectivo = redondear(pagos.fold(0.0, (s, p) => s + p.efectivo));
    final transferencia = redondear(pagos.fold(0.0, (s, p) => s + p.transferencia));
    if (!context.mounted) return;
    await mostrarHoja(context, constructor: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TituloHoja(fechaCorta(t.inicio),
                sub: '${horaCorta(t.inicio)} – ${t.fin != null ? horaCorta(t.fin!) : '—'}'),
            Text(dinero(total), style: const TextStyle(
              fontFamily: F.display, fontSize: 34, fontWeight: FontWeight.w700, color: C.crema,
            )),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChipEstado.ambar('${dinero(efectivo)} efectivo',
                  icono: LucideIcons.banknote, mono: true),
              ChipEstado.cian('${dinero(transferencia)} transferencia',
                  icono: LucideIcons.landmark, mono: true),
            ]),
            const SizedBox(height: 12),
            Text('${pagos.length} cobros registrados',
                style: const TextStyle(fontSize: 13, color: C.crema60)),
          ],
        ));
  }
}
