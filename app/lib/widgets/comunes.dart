// Widgets pequeños compartidos: estado vacío, sello de éxito, compuerta de
// turno y stepper de cantidad.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/proveedores.dart';
import '../servicios/haptico.dart';
import '../tema/tema.dart';

class Vacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  const Vacio({super.key, required this.icono, required this.titulo, this.detalle});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(children: [
          Icon(icono, size: 40, color: C.crema38),
          const SizedBox(height: 12),
          Text(titulo, textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: C.crema60)),
          if (detalle != null) ...[
            const SizedBox(height: 4),
            Text(detalle!, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: C.crema38)),
          ],
        ]),
      );
}

// Sello de goma sobre la pantalla: "CUENTA SALDADA", "VENTA COBRADA"…
Future<void> mostrarSello(BuildContext context, String texto) async {
  Haptico.medio();
  // Cierre automático fiable: capturamos el navegador raíz antes de mostrar y
  // programamos el pop sobre él (no dependemos del `mounted` del pageBuilder,
  // que puede no dispararse y dejaría la barrera bloqueando toda la app).
  final navegador = Navigator.of(context, rootNavigator: true);
  var cerrado = false;
  Future.delayed(const Duration(milliseconds: 1150), () {
    if (!cerrado) {
      cerrado = true;
      navegador.pop();
    }
  });
  await showGeneralDialog(
    context: context,
    barrierColor: const Color(0xBF090D16),
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final escala = Tween(begin: 2.2, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutBack))
          .animate(anim);
      return Center(
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: escala,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: C.menta, width: 4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  texto.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: F.display,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    letterSpacing: 1.5,
                    color: C.menta,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Compuerta de turno (regla 1): sin turno activo no se opera.
class SinTurno extends ConsumerWidget {
  final String mensaje;
  const SinTurno({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        child: Column(children: [
          const Icon(LucideIcons.sunrise, size: 44, color: C.ambar),
          const SizedBox(height: 12),
          Text('El turno aún no empieza',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(mensaje, textAlign: TextAlign.center,
              style: const TextStyle(color: C.crema60)),
          const SizedBox(height: 22),
          Boton('Iniciar turno', alTocar: () => ref.read(baseDatos).iniciarTurno()),
        ]),
      );
}

class Stepper2 extends StatelessWidget {
  final int valor;
  final ValueChanged<int> alCambiar;
  final int minimo;
  const Stepper2({super.key, required this.valor, required this.alCambiar, this.minimo = 1});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        _boton(LucideIcons.minus, valor > minimo ? () => alCambiar(valor - 1) : null),
        SizedBox(
          width: 44,
          child: Text('$valor', textAlign: TextAlign.center,
              style: estiloMono(tamano: 20, peso: FontWeight.w700)),
        ),
        _boton(LucideIcons.plus, () => alCambiar(valor + 1)),
      ]);

  Widget _boton(IconData icono, VoidCallback? alTocar) => Material(
        color: C.crema07,
        shape: const CircleBorder(side: BorderSide(color: C.crema12)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: alTocar == null
              ? null
              : () { Haptico.seleccion(); alTocar(); },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icono, size: 17, color: alTocar == null ? C.crema38 : C.crema),
          ),
        ),
      );
}
