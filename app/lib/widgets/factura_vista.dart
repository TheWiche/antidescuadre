// Factura de una cuenta (sección 3.10): los mismos datos con dos lentes —
// cronológica o agrupada — sobre el mismo papel, con cruce suave y compartir.

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base.dart';
import '../logica/cuentas.dart';
import '../logica/dinero.dart';
import '../logica/factura.dart';
import '../tema/tema.dart';
import '../tema/ticket.dart';

class FacturaVista extends StatefulWidget {
  final String nombreNegocio;
  final String alias;
  final DateTime fecha;
  final List<Item> items;

  const FacturaVista({
    super.key,
    required this.nombreNegocio,
    required this.alias,
    required this.fecha,
    required this.items,
  });

  @override
  State<FacturaVista> createState() => _FacturaVistaState();
}

class _FacturaVistaState extends State<FacturaVista> {
  String _modo = 'cronologica';

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector de modo
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: C.ciruela900,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(children: [
              for (final (valor, texto) in [
                ('cronologica', 'Cronológica'),
                ('agrupada', 'Agrupada'),
              ])
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _modo = valor),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _modo == valor ? C.ambar : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      alignment: Alignment.center,
                      child: Text(texto, style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14.5,
                        color: _modo == valor ? C.ambarTinta : C.crema60,
                      )),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 16),

          Ticket(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TicketCabecera(
                titulo: widget.nombreNegocio,
                meta: '${widget.alias} · ${fechaLarga(widget.fecha)}',
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Column(
                  key: ValueKey(_modo),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _modo == 'cronologica'
                      ? [
                          for (final tanda in facturaCronologica(widget.items)) ...[
                            TicketHora(horaCorta(tanda.hora)),
                            for (final l in tanda.lineas)
                              TicketLinea(
                                izquierda: '${l.cantidad}× ${l.texto}',
                                derecha: dinero(l.total),
                              ),
                          ],
                        ]
                      : [
                          for (final l in facturaAgrupada(widget.items))
                            TicketLinea(
                              izquierda: '${l.texto} ×${l.cantidad}',
                              sub: '${dinero(l.unitario)} c/u',
                              derecha: dinero(l.total),
                            ),
                        ],
                ),
              ),
              const TicketSeparador(),
              TicketLinea(
                izquierda: 'TOTAL',
                derecha: dinero(totalItems(widget.items)),
                negrita: true,
              ),
              const TicketNota('¡gracias por venir!'),
            ]),
          ),
          const SizedBox(height: 16),

          Boton('Compartir factura', icono: LucideIcons.share2, tono: TonoBoton.fantasma,
              expandir: true, alTocar: () {
            SharePlus.instance.share(ShareParams(
              text: facturaComoTexto(
                widget.nombreNegocio, widget.alias, widget.items, _modo,
              ),
              subject: 'Cuenta · ${widget.alias}',
            ));
          }),
        ],
      );
}
