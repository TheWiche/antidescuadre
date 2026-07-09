// Menú "Más": accesos a catálogo, comprobantes y ajustes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/proveedores.dart';
import '../tema/tema.dart';
import 'ajustes.dart';
import 'catalogo.dart';
import 'comprobantes.dart';

class PantallaMas extends ConsumerWidget {
  const PantallaMas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosProv).value?.length ?? 0;
    final pendientes = ref.watch(pendientesLegalizarProv).value ?? 0;

    final opciones = [
      (
        icono: LucideIcons.bookOpen,
        titulo: 'Catálogo',
        detalle: productos > 0
            ? '$productos producto${productos != 1 ? 's' : ''}'
            : 'Crea tus productos y categorías',
        color: C.ambar,
        alerta: false,
        destino: () => const PantallaCatalogo(),
      ),
      (
        icono: LucideIcons.landmark,
        titulo: 'Comprobantes',
        detalle: pendientes > 0
            ? '$pendientes pendiente${pendientes != 1 ? 's' : ''} por legalizar'
            : 'Transferencias y legalización',
        color: C.cian,
        alerta: pendientes > 0,
        destino: () => const PantallaComprobantes(),
      ),
      (
        icono: LucideIcons.settings,
        titulo: 'Ajustes',
        detalle: 'Negocio, alertas, exportar/importar',
        color: C.crema60,
        alerta: false,
        destino: () => const PantallaAjustes(),
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text('Más', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          const Text('Configuración y herramientas del negocio.',
              style: TextStyle(color: C.crema60, fontSize: 14)),
          const SizedBox(height: 16),
          for (final o in opciones) ...[
            Tarjeta(
              alTocar: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => o.destino())),
              child: Row(children: [
                Icon(o.icono, size: 22, color: o.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(o.titulo, style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16.5,
                    )),
                    Text(o.detalle, style: const TextStyle(fontSize: 13, color: C.crema60)),
                  ]),
                ),
                const Icon(LucideIcons.chevronRight, size: 18, color: C.crema38),
              ]),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
