// Vista general de mesas (sección 3.3): libres/ocupadas, alias 100%
// editables, saldo y pendientes de cada cuenta abierta.

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
import '../widgets/hoja.dart';
import 'mesa_detalle.dart';

class PantallaMesas extends ConsumerWidget {
  const PantallaMesas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turno = ref.watch(turnoActivoProv);
    final mesas = ref.watch(mesasProv).value ?? [];

    return SafeArea(
      child: switch (turno) {
        AsyncData(value: final t) when t == null => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Text('Mesas', style: Theme.of(context).textTheme.headlineLarge),
              const SinTurno(mensaje: 'Inicia el turno para abrir cuentas en las mesas.'),
            ],
          ),
        AsyncData(value: final t?) => _Cuadricula(turno: t, mesas: mesas),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Cuadricula extends ConsumerWidget {
  final Turno turno;
  final List<Mesa> mesas;
  const _Cuadricula({required this.turno, required this.mesas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abiertas = ref.watch(cuentasAbiertasProv(turno.id)).value ?? [];
    final itemsAbiertos = ref.watch(itemsAbiertosDeTurnoProv(turno.id)).value ?? [];
    final pagosAbiertos = ref.watch(pagosAbiertosDeTurnoProv(turno.id)).value ?? [];

    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        sliver: SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Mesas', style: Theme.of(context).textTheme.headlineLarge),
              Boton('Mesa', icono: LucideIcons.plus, tono: TonoBoton.fantasma,
                  alto: 40, alTocar: () => _nuevaMesa(context, ref)),
            ]),
            const SizedBox(height: 4),
            const Text('Toca una mesa para ver su cuenta.',
                style: TextStyle(color: C.crema60, fontSize: 14)),
            const SizedBox(height: 16),
          ]),
        ),
      ),
      if (mesas.isEmpty)
        const SliverToBoxAdapter(
          child: Vacio(
            icono: LucideIcons.armchair,
            titulo: 'Sin mesas todavía',
            detalle: 'Crea tus mesas con el alias que quieras: «La de la ventana», «VIP 2»…',
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, mainAxisExtent: 112,
              crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              childCount: mesas.length,
              (contexto, i) {
                final mesa = mesas[i];
                final cuenta =
                    abiertas.where((c) => c.mesaId == mesa.id).firstOrNull;
                final saldo = cuenta == null
                    ? 0.0
                    : saldoCuenta(
                        itemsAbiertos.where((x) => x.cuentaId == cuenta.id).toList(),
                        pagosAbiertos.where((x) => x.cuentaId == cuenta.id).toList(),
                      );
                final porEntregar = cuenta == null
                    ? 0
                    : itemsAbiertos
                        .where((x) => x.cuentaId == cuenta.id && x.estado == 'pendiente')
                        .length;
                final ocupada = cuenta != null;
                return Tarjeta(
                  fondo: ocupada ? C.base600 : null,
                  borde: ocupada ? C.ambar : null,
                  alTocar: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PantallaMesaDetalle(mesaId: mesa.id),
                  )),
                  relleno: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(mesa.alias, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16, height: 1.2,
                          )),
                      if (ocupada)
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(dinero(saldo), style: estiloMono(
                            tamano: 19, peso: FontWeight.w700, color: C.ambar,
                          )),
                          if (porEntregar > 0)
                            Text('$porEntregar por entregar',
                                style: const TextStyle(fontSize: 12.5, color: C.crema60)),
                        ])
                      else
                        const ChipEstado.neutro('libre'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
    ]);
  }

  Future<void> _nuevaMesa(BuildContext context, WidgetRef ref) async {
    final controlador = TextEditingController();
    await mostrarHoja(context, constructor: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TituloHoja('Nueva mesa'),
            const EtiquetaCampo('Alias'),
            TextField(
              controller: controlador,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'ej. La de la ventana'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            Boton('Crear mesa', expandir: true, alTocar: () async {
              final alias = controlador.text.trim();
              if (alias.isEmpty) return;
              final db = ref.read(baseDatos);
              await db.into(db.mesas).insert(MesasCompanion.insert(
                    alias: alias, orden: Value(mesas.length),
                  ));
              if (ctx.mounted) Navigator.pop(ctx);
            }),
          ],
        ));
  }
}
