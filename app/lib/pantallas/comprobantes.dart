// Comprobantes de transferencia (secciones 3.6 y 3.7): nacen "pendientes de
// legalizar" y aquí se verifican. También captura libre, sin mesa (regla 10).

import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/proveedores.dart';
import '../logica/dinero.dart';
import '../servicios/fotos.dart';
import '../tema/tema.dart';
import '../widgets/camara.dart';
import '../widgets/comunes.dart';

final _comprobantesProv = StreamProvider.family<List<Comprobante>, String>(
  (ref, estado) => ref.watch(baseDatos).verComprobantes(estado),
);

class PantallaComprobantes extends ConsumerStatefulWidget {
  const PantallaComprobantes({super.key});

  @override
  ConsumerState<PantallaComprobantes> createState() => _PantallaComprobantesState();
}

class _PantallaComprobantesState extends ConsumerState<PantallaComprobantes> {
  String _pestana = 'pendiente';

  Future<void> _capturaLibre() async {
    final foto = await PantallaCamara.abrir(context, titulo: 'Comprobante suelto');
    if (foto == null) return;
    final db = ref.read(baseDatos);
    final turno = await db.turnoActivo();
    final ruta = await Fotos.guardarComprobante(foto);
    await db.into(db.comprobantes).insert(ComprobantesCompanion.insert(
          rutaArchivo: ruta,
          fecha: DateTime.now(),
          turnoId: Value(turno?.id),
        ));
    setState(() => _pestana = 'pendiente');
  }

  @override
  Widget build(BuildContext context) {
    final lista = ref.watch(_comprobantesProv(_pestana)).value ?? [];
    final pendientesTotal = ref.watch(pendientesLegalizarProv).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.ciruela800,
        centerTitle: true,
        title: const Text('Comprobantes', style: TextStyle(
          fontFamily: F.display, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              style: IconButton.styleFrom(backgroundColor: C.cian),
              icon: const Icon(LucideIcons.camera, size: 19, color: C.cianTinta),
              onPressed: _capturaLibre,
              tooltip: 'Captura libre',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          const Text('Toda transferencia queda aquí hasta legalizarse en barra.',
              style: TextStyle(color: C.crema60, fontSize: 14)),
          const SizedBox(height: 14),

          // Pestañas pendientes/legalizadas
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: C.ciruela900, borderRadius: BorderRadius.circular(99),
            ),
            child: Row(children: [
              for (final (valor, texto) in [
                ('pendiente', 'Pendientes${pendientesTotal > 0 ? ' · $pendientesTotal' : ''}'),
                ('legalizada', 'Legalizadas'),
              ])
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _pestana = valor),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _pestana == valor ? C.cian : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      alignment: Alignment.center,
                      child: Text(texto, style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14.5,
                        color: _pestana == valor ? C.cianTinta : C.crema60,
                      )),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 16),

          if (lista.isEmpty)
            Vacio(
              icono: _pestana == 'pendiente' ? LucideIcons.badgeCheck : LucideIcons.landmark,
              titulo: _pestana == 'pendiente'
                  ? 'Nada pendiente por legalizar'
                  : 'Aún no hay legalizadas',
              detalle: _pestana == 'pendiente'
                  ? 'Todas las transferencias están al día.'
                  : null,
            )
          else
            for (final c in lista) ...[
              _TarjetaComprobante(comprobante: c),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _TarjetaComprobante extends ConsumerWidget {
  final Comprobante comprobante;
  const _TarjetaComprobante({required this.comprobante});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = comprobante;
    final pendiente = c.estado == 'pendiente';
    final archivo = File(c.rutaArchivo);

    return Tarjeta(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => _ampliar(context, archivo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: archivo.existsSync()
                ? Image.file(archivo, width: 74, height: 74, fit: BoxFit.cover)
                : Container(width: 74, height: 74, color: C.ciruela900,
                    child: const Icon(LucideIcons.imageOff, color: C.crema38)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.aliasMesa ?? 'Captura libre',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${fechaCorta(c.fecha)} · ${horaCorta(c.fecha)}',
                style: const TextStyle(fontSize: 13, color: C.crema60)),
            if (c.monto != null)
              Text(dinero(c.monto!), style: estiloMono(tamano: 13, color: C.cian)),
            const SizedBox(height: 8),
            if (pendiente)
              Boton('Legalizar', icono: LucideIcons.badgeCheck, tono: TonoBoton.cian,
                  alto: 38, alTocar: () async {
                HapticFeedback.lightImpact();
                await ref.read(baseDatos).legalizarComprobante(c.id);
              })
            else
              ChipEstado.menta(
                'legalizada ${c.legalizadaEn != null ? horaCorta(c.legalizadaEn!) : ''}',
                icono: LucideIcons.badgeCheck,
              ),
          ]),
        ),
      ]),
    );
  }

  void _ampliar(BuildContext context, File archivo) {
    if (!archivo.existsSync()) return;
    showDialog(
      context: context,
      barrierColor: const Color(0xF20C060D),
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${comprobante.aliasMesa ?? 'Captura libre'} · ${fechaCorta(comprobante.fecha)} ${horaCorta(comprobante.fecha)}',
              style: const TextStyle(color: C.crema60, fontSize: 13,
                  decoration: TextDecoration.none, fontFamily: F.texto,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              child: Image.file(archivo, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
