// Cáscara de la app: navegación inferior de 5 pestañas + la cinta persistente
// de comprobantes por legalizar (regla 9) que vive sobre la barra, visible en
// toda la app sin bloquear el uso.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/proveedores.dart';
import '../servicios/notificaciones.dart';
import '../tema/tema.dart';
import 'comprobantes.dart';
import 'mas.dart';
import 'mesas.dart';
import 'pendientes.dart';
import 'resumen.dart';
import 'vender.dart';

class PantallaRaiz extends ConsumerStatefulWidget {
  const PantallaRaiz({super.key});

  @override
  ConsumerState<PantallaRaiz> createState() => _PantallaRaizState();
}

class _PantallaRaizState extends ConsumerState<PantallaRaiz> {
  int _pestana = 0;

  static const _titulos = ['Turno', 'Mesas', 'Vender', 'Por entregar', 'Más'];
  static const _iconos = [
    LucideIcons.receipt,
    LucideIcons.layoutGrid,
    LucideIcons.beer,
    LucideIcons.clipboardList,
    LucideIcons.menu,
  ];

  @override
  Widget build(BuildContext context) {
    final pendientes = ref.watch(pendientesLegalizarProv).value ?? 0;

    // Mantener la notificación del sistema sincronizada (regla 9)
    ref.listen(pendientesLegalizarProv, (_, ahora) {
      Notificaciones.actualizarPendientes(ahora.value ?? 0);
    });

    return Scaffold(
      body: IndexedStack(index: _pestana, children: const [
        PantallaResumen(),
        PantallaMesas(),
        PantallaVender(),
        PantallaPendientes(),
        PantallaMas(),
      ]),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        // Cinta obligatoria y no descartable mientras haya pendientes
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: pendientes == 0
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Material(
                    color: C.cian,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PantallaComprobantes(),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        child: Row(children: [
                          const _IconoPulso(),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pendientes == 1
                                  ? '1 transferencia pendiente por legalizar'
                                  : '$pendientes transferencias pendientes por legalizar',
                              style: const TextStyle(
                                color: C.cianTinta, fontWeight: FontWeight.w700, fontSize: 14,
                              ),
                            ),
                          ),
                          const Text('Ver', style: TextStyle(
                            color: C.cianTinta, fontWeight: FontWeight.w800, fontSize: 14,
                          )),
                        ]),
                      ),
                    ),
                  ),
                ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Color(0xEB1A111B),
            border: Border(top: BorderSide(color: C.crema07)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(children: [
                for (var i = 0; i < _titulos.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _pestana = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 3,
                            width: _pestana == i ? 34 : 0,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: C.ambar,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          Icon(_iconos[i], size: 21,
                              color: _pestana == i ? C.ambar : C.crema38),
                          const SizedBox(height: 3),
                          Text(_titulos[i], style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: _pestana == i ? C.ambar : C.crema38,
                          )),
                        ],
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _IconoPulso extends StatefulWidget {
  const _IconoPulso();

  @override
  State<_IconoPulso> createState() => _IconoPulsoState();
}

class _IconoPulsoState extends State<_IconoPulso>
    with SingleTickerProviderStateMixin {
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
        opacity: Tween(begin: 1.0, end: 0.5).animate(_controlador),
        child: const Icon(LucideIcons.landmark, size: 18, color: C.cianTinta),
      );
}
