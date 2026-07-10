// Campo de monto con teclado numérico propio: en vez del teclado del
// sistema (que tapa media pantalla y es inconsistente entre dispositivos),
// un teclado grande anclado justo debajo del campo — más rápido y con la
// cara de un POS real. Envuelve un TextEditingController normal, así que
// leerMonto()/la validación existente no cambian.

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../servicios/haptico.dart';
import '../tema/tema.dart';

class CampoMonto extends StatefulWidget {
  final TextEditingController controlador;
  final Color color;
  final VoidCallback? alCambiar;

  const CampoMonto({
    super.key,
    required this.controlador,
    this.color = C.crema,
    this.alCambiar,
  });

  @override
  State<CampoMonto> createState() => CampoMontoState();
}

class CampoMontoState extends State<CampoMonto> {
  bool _abierto = false;

  void cerrar() {
    if (mounted && _abierto) setState(() => _abierto = false);
  }

  void _tocar(String d) {
    final actual = widget.controlador.text;
    String nuevo;
    if (d == '⌫') {
      nuevo = actual.isEmpty ? '' : actual.substring(0, actual.length - 1);
    } else if (d == ',') {
      nuevo = actual.contains(',') ? actual : (actual.isEmpty ? '0,' : '$actual,');
    } else {
      nuevo = actual.length >= 9 ? actual : actual + d;
    }
    Haptico.seleccion();
    setState(() => widget.controlador.text = nuevo);
    widget.alCambiar?.call();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() => _abierto = !_abierto),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: C.base900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _abierto ? widget.color : C.crema12,
                  width: 1.5,
                ),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    widget.controlador.text.isEmpty ? '0' : widget.controlador.text,
                    style: estiloMono(tamano: 17, peso: FontWeight.w700, color: widget.color),
                  ),
                ),
                Icon(
                  _abierto ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16, color: C.crema38,
                ),
              ]),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOut,
            crossFadeState: _abierto ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _Teclado(alTocar: _tocar),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      );
}

class _Teclado extends StatelessWidget {
  final ValueChanged<String> alTocar;
  const _Teclado({required this.alTocar});

  static const _filas = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final fila in _filas)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              for (var i = 0; i < fila.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(child: _Tecla(fila[i], onTap: () => alTocar(fila[i]))),
              ],
            ]),
          ),
      ]);
}

class _Tecla extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _Tecla(this.texto, {required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: C.base600,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Center(
              child: texto == '⌫'
                  ? const Icon(LucideIcons.delete, size: 18, color: C.crema)
                  : Text(texto, style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: C.crema,
                    )),
            ),
          ),
        ),
      );
}
