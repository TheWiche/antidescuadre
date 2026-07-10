// Pedidos pendientes por entregar (sección 3.9), agrupados por mesa. Si un
// pedido supera el tiempo límite global (Ajustes), se resalta (regla 13).

import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../servicios/haptico.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/modelos.dart';
import '../datos/proveedores.dart';
import '../logica/dinero.dart';
import '../tema/tema.dart';
import '../widgets/comunes.dart';

class PantallaPendientes extends ConsumerStatefulWidget {
  const PantallaPendientes({super.key});

  @override
  ConsumerState<PantallaPendientes> createState() => _PantallaPendientesState();
}

class _PantallaPendientesState extends ConsumerState<PantallaPendientes> {
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    // El "hace X min" se refresca solo
    _reloj = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final turno = ref.watch(turnoActivoProv);
    final ajustes = ref.watch(ajustesProv).value;
    final limite = ajustes?.alertaMinutos ?? 10;

    return SafeArea(
      child: switch (turno) {
        AsyncData(value: final t) when t == null => ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Text('Por entregar', style: Theme.of(context).textTheme.headlineLarge),
              const SinTurno(mensaje: 'Inicia el turno para ver los pedidos en marcha.'),
            ],
          ),
        AsyncData(value: final t?) => _Lista(turno: t, limite: limite),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Lista extends ConsumerWidget {
  final Turno turno;
  final int limite;
  const _Lista({required this.turno, required this.limite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(baseDatos);
    final abiertas = ref.watch(cuentasAbiertasProv(turno.id)).value ?? [];
    final itemsAbiertos = ref.watch(itemsAbiertosDeTurnoProv(turno.id)).value ?? [];
    final mesas = ref.watch(mesasProv).value ?? [];

    final pendientes =
        itemsAbiertos.where((i) => i.estado == 'pendiente').toList()
          ..sort((a, b) => a.agregadoEn.compareTo(b.agregadoEn));
    final porCuenta = <int, List<Item>>{};
    for (final it in pendientes) {
      porCuenta.putIfAbsent(it.cuentaId, () => []).add(it);
    }

    Future<void> entregar(Item it) async {
      Haptico.ligero();
      await (db.update(db.items)..where((i) => i.id.equals(it.id)))
          .write(ItemsCompanion(
        estado: const Value('entregado'),
        entregadoEn: Value(DateTime.now()),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text('Por entregar', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('Lo que falta llevar a cada mesa · alerta a los $limite min.',
            style: const TextStyle(color: C.crema60, fontSize: 14)),
        const SizedBox(height: 16),
        if (porCuenta.isEmpty)
          const Vacio(icono: LucideIcons.clipboardList, titulo: 'Todo entregado',
              detalle: 'Nada pendiente por llevar.')
        else
          for (final entrada in porCuenta.entries) ...[
            Builder(builder: (_) {
              final cuenta =
                  abiertas.where((c) => c.id == entrada.key).firstOrNull;
              final alias =
                  mesas.where((m) => m.id == cuenta?.mesaId).firstOrNull?.alias ?? 'Mesa';
              return Tarjeta(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(alias, style: const TextStyle(
                      fontFamily: F.display, fontSize: 17, fontWeight: FontWeight.w700,
                    )),
                    GestureDetector(
                      onTap: () async {
                        Haptico.medio();
                        final ahora = DateTime.now();
                        for (final it in entrada.value) {
                          await (db.update(db.items)..where((i) => i.id.equals(it.id)))
                              .write(ItemsCompanion(
                            estado: const Value('entregado'),
                            entregadoEn: Value(ahora),
                          ));
                        }
                      },
                      child: const ChipEstado.menta('Todo entregado',
                          icono: LucideIcons.checkCheck),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  for (final it in entrada.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${it.cantidad > 1 ? '${it.cantidad} × ' : ''}${it.nombre}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (seleccionesDeJson(it.variantesJson).isNotEmpty)
                                  Text(
                                    etiquetaVariantes(seleccionesDeJson(it.variantesJson)),
                                    style: const TextStyle(fontSize: 13, color: C.crema60),
                                  ),
                              ]),
                        ),
                        _ChipTiempo(minutos: minutosDesde(it.agregadoEn), limite: limite),
                        const SizedBox(width: 10),
                        Material(
                          color: C.menta,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => entregar(it),
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: Icon(LucideIcons.check, size: 18, color: C.mentaTinta),
                            ),
                          ),
                        ),
                      ]),
                    ),
                ]),
              );
            }),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ChipTiempo extends StatelessWidget {
  final int minutos;
  final int limite;
  const _ChipTiempo({required this.minutos, required this.limite});

  @override
  Widget build(BuildContext context) {
    final tarde = minutos >= limite;
    final texto = minutos < 1 ? 'ahora' : '$minutos min';
    if (!tarde) return ChipEstado.neutro(texto, mono: true);
    return _Parpadeo(child: ChipEstado.rojo(texto, icono: LucideIcons.flame, mono: true));
  }
}

class _Parpadeo extends StatefulWidget {
  final Widget child;
  const _Parpadeo({required this.child});

  @override
  State<_Parpadeo> createState() => _ParpadeoState();
}

class _ParpadeoState extends State<_Parpadeo> with SingleTickerProviderStateMixin {
  late final _controlador = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.55).animate(_controlador),
        child: widget.child,
      );
}
