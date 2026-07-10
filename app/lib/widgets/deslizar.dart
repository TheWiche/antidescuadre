// Patrón "deslizar para confirmar": una perilla que se arrastra hasta el
// final de una pista, en vez de un botón tocable — evita confirmar por
// accidente en acciones sensibles (legalizar, cancelar cuenta, cerrar turno).
// No es swipe-para-revelar-acciones (flutter_slidable); es slide-to-confirm,
// hecho a mano con Animation/GestureDetector como el resto de la app.

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../servicios/haptico.dart';

class DeslizarConfirmar extends StatefulWidget {
  final String texto;
  final String textoConfirmado;
  final Color color;
  final Color colorPerilla;
  final IconData icono;
  final VoidCallback alConfirmar;
  final bool habilitado;
  final double alto;

  const DeslizarConfirmar({
    super.key,
    required this.texto,
    this.textoConfirmado = '¡Listo!',
    required this.color,
    required this.colorPerilla,
    this.icono = LucideIcons.chevronsRight,
    required this.alConfirmar,
    this.habilitado = true,
    this.alto = 56,
  });

  @override
  State<DeslizarConfirmar> createState() => _DeslizarConfirmarState();
}

class _DeslizarConfirmarState extends State<DeslizarConfirmar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resorte = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 320),
  )..addListener(() => setState(() {}));

  bool _arrastrando = false;
  bool _confirmado = false;
  static const _perilla = 48.0;

  double get _progreso => _resorte.value;

  @override
  void dispose() {
    _resorte.dispose();
    super.dispose();
  }

  void _actualizar(double dx, double ancho) {
    if (!widget.habilitado || _confirmado) return;
    final maximo = ancho - _perilla;
    if (maximo <= 0) return;
    _resorte.value = ((dx - _perilla / 2) / maximo).clamp(0.0, 1.0);
  }

  void _soltar() {
    if (!widget.habilitado || _confirmado) return;
    setState(() => _arrastrando = false);
    if (_progreso > 0.78) {
      setState(() => _confirmado = true);
      Haptico.medio();
      _resorte.animateTo(1, curve: Curves.easeOutCubic).whenComplete(() {
        widget.alConfirmar();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() => _confirmado = false);
            _resorte.value = 0;
          }
        });
      });
    } else {
      _resorte.animateBack(0, curve: Curves.elasticOut);
    }
  }

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: widget.habilitado ? 1 : 0.4,
        child: LayoutBuilder(builder: (context, restricciones) {
          final ancho = restricciones.maxWidth;
          return GestureDetector(
            onHorizontalDragStart: widget.habilitado
                ? (_) => setState(() => _arrastrando = true)
                : null,
            onHorizontalDragUpdate: widget.habilitado
                ? (d) => _actualizar(d.localPosition.dx, ancho)
                : null,
            onHorizontalDragEnd: widget.habilitado ? (_) => _soltar() : null,
            onHorizontalDragCancel: widget.habilitado
                ? () => setState(() => _arrastrando = false)
                : null,
            child: Container(
              height: widget.alto,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: widget.color.withValues(alpha: 0.32)),
              ),
              child: Stack(alignment: Alignment.centerLeft, children: [
                FractionallySizedBox(
                  widthFactor:
                      ((_progreso * (ancho - _perilla)) + _perilla) / ancho,
                  child: Container(color: widget.color.withValues(alpha: 0.24)),
                ),
                Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: (1 - _progreso * 1.7).clamp(0.0, 1.0),
                    child: Text(
                      _confirmado ? widget.textoConfirmado : widget.texto,
                      style: TextStyle(fontWeight: FontWeight.w700, color: widget.color),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _arrastrando ? Duration.zero : const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  left: 3 + _progreso * (ancho - _perilla - 6),
                  top: 3,
                  bottom: 3,
                  child: Container(
                    width: _perilla - 6,
                    decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                    child: Icon(
                      _confirmado ? LucideIcons.check : widget.icono,
                      color: widget.colorPerilla,
                      size: 20,
                    ),
                  ),
                ),
              ]),
            ),
          );
        }),
      );
}
