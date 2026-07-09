// Hoja inferior: la superficie modal estándar de la app, y el diálogo de
// confirmación de la casa.

import 'package:flutter/material.dart';

import '../tema/tema.dart';

Future<T?> mostrarHoja<T>(BuildContext context, {required WidgetBuilder constructor}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: constructor(ctx),
        ),
      ),
    );

class TituloHoja extends StatelessWidget {
  final String texto;
  final String? sub;
  const TituloHoja(this.texto, {super.key, this.sub});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(texto, style: const TextStyle(
            fontFamily: F.display, fontSize: 20, fontWeight: FontWeight.w700, color: C.crema,
          )),
          if (sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(sub!, style: const TextStyle(color: C.crema60, fontSize: 14)),
            ),
        ]),
      );
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  String? detalle,
  required String textoConfirmar,
  bool peligro = false,
}) async {
  final r = await mostrarHoja<bool>(context, constructor: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TituloHoja(titulo, sub: detalle),
          const SizedBox(height: 8),
          Boton(
            textoConfirmar,
            tono: peligro ? TonoBoton.peligro : TonoBoton.ambar,
            expandir: true,
            alTocar: () => Navigator.pop(ctx, true),
          ),
          const SizedBox(height: 10),
          Boton('Cancelar', tono: TonoBoton.fantasma, expandir: true,
              alTocar: () => Navigator.pop(ctx, false)),
        ],
      ));
  return r ?? false;
}
