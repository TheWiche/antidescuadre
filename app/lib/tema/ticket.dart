// El elemento firma de AntiDescuadre: papel de comanda troquelado.
// Borde dentado arriba y abajo, papel crema, tinta ciruela, tipografía mono.

import 'package:flutter/material.dart';

import 'tema.dart';

class _TroqueladoClipper extends CustomClipper<Path> {
  final double diente;
  const _TroqueladoClipper({this.diente = 11});

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, diente);
    final anchoDiente = size.width / (size.width / 18).round();
    // Dientes superiores
    var x = 0.0;
    var arriba = true;
    while (x < size.width - 0.1) {
      x += anchoDiente / 2;
      path.lineTo(x.clamp(0, size.width), arriba ? 0 : diente);
      arriba = !arriba;
    }
    path.lineTo(size.width, diente);
    path.lineTo(size.width, size.height - diente);
    // Dientes inferiores (de derecha a izquierda)
    x = size.width;
    arriba = true;
    while (x > 0.1) {
      x -= anchoDiente / 2;
      path.lineTo(x.clamp(0, size.width), arriba ? size.height : size.height - diente);
      arriba = !arriba;
    }
    path.lineTo(0, size.height - diente);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TroqueladoClipper old) => old.diente != diente;
}

class Ticket extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry relleno;

  const Ticket({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.fromLTRB(18, 30, 18, 30),
  });

  @override
  Widget build(BuildContext context) => PhysicalShape(
        clipper: const _TroqueladoClipper(),
        color: C.papel,
        elevation: 14,
        shadowColor: const Color(0xCC0A050B),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: F.mono,
            fontSize: 13.5,
            height: 1.5,
            color: C.papelTinta,
          ),
          child: Padding(padding: relleno, child: child),
        ),
      );
}

// ---------- Piezas internas del ticket ----------

class TicketCabecera extends StatelessWidget {
  final String titulo;
  final String meta;
  const TicketCabecera({super.key, required this.titulo, required this.meta});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(
          titulo.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: F.display, fontWeight: FontWeight.w800, fontSize: 17,
            letterSpacing: 0.4, color: C.papelTinta,
          ),
        ),
        Text(meta, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: C.papelTintaSuave)),
        const TicketSeparador(),
      ]);
}

class TicketSeparador extends StatelessWidget {
  const TicketSeparador({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: (_, restricciones) => Text(
            '- ' * (restricciones.maxWidth / 11).floor(),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(color: C.papelTintaSuave, fontSize: 12),
          ),
        ),
      );
}

// "— 8:14 pm —·····" hora de una tanda
class TicketHora extends StatelessWidget {
  final String hora;
  const TicketHora(this.hora, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: Row(children: [
          Text(hora, style: const TextStyle(fontSize: 11, letterSpacing: 0.6, color: C.papelTintaSuave)),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(color: C.papelTintaSuave, thickness: 0.7, height: 1),
          ),
        ]),
      );
}

class TicketLinea extends StatelessWidget {
  final String izquierda;
  final String derecha;
  final Widget? indicador;
  final String? sub;
  final bool negrita;
  final VoidCallback? alTocar;

  const TicketLinea({
    super.key,
    required this.izquierda,
    required this.derecha,
    this.indicador,
    this.sub,
    this.negrita = false,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontFamily: F.mono,
      fontSize: negrita ? 16 : 13.5,
      fontWeight: negrita ? FontWeight.w700 : FontWeight.w400,
      color: C.papelTinta,
      height: 1.4,
    );
    final fila = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(izquierda, style: estilo),
            if (sub != null)
              Text(sub!, style: const TextStyle(fontSize: 11.5, color: C.papelTintaSuave)),
          ]),
        ),
        if (indicador != null) ...[indicador!, const SizedBox(width: 6)],
        Text(derecha, style: estilo),
      ]),
    );
    if (alTocar == null) return fila;
    return InkWell(onTap: alTocar, child: fila);
  }
}

class TicketNota extends StatelessWidget {
  final String texto;
  const TicketNota(this.texto, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11.5, color: C.papelTintaSuave),
        ),
      );
}
