// Facturación (sección 3.10): los mismos ítems vistos con dos lentes —
// cronológica (por tandas con hora) o agrupada (sumada por producto+variante).

import '../datos/base.dart';
import '../datos/modelos.dart';
import 'cuentas.dart';
import 'dinero.dart';

class LineaFactura {
  final String texto;
  final int cantidad;
  final double total;
  const LineaFactura({required this.texto, required this.cantidad, required this.total});
}

class TandaFactura {
  final DateTime hora;
  final List<LineaFactura> lineas;
  const TandaFactura({required this.hora, required this.lineas});
}

String _textoItem(Item it) {
  final variantes = seleccionesDeJson(it.variantesJson);
  return it.nombre +
      (variantes.isNotEmpty ? ' (${etiquetaVariantes(variantes)})' : '');
}

List<TandaFactura> facturaCronologica(List<Item> itemsCuenta) {
  final porTanda = <int, List<Item>>{};
  for (final it in itemsCuenta) {
    porTanda.putIfAbsent(it.tandaId, () => []).add(it);
  }
  final tandas = porTanda.keys.toList()..sort();
  return [
    for (final t in tandas)
      TandaFactura(
        hora: DateTime.fromMillisecondsSinceEpoch(t),
        lineas: [
          for (final it in porTanda[t]!)
            LineaFactura(texto: _textoItem(it), cantidad: it.cantidad, total: totalItem(it)),
        ],
      ),
  ];
}

class LineaAgrupada {
  final String texto;
  final int cantidad;
  final double unitario;
  final double total;
  const LineaAgrupada({
    required this.texto,
    required this.cantidad,
    required this.unitario,
    required this.total,
  });
}

List<LineaAgrupada> facturaAgrupada(List<Item> itemsCuenta) {
  final grupos = <String, LineaAgrupada>{};
  for (final it in itemsCuenta) {
    final texto = _textoItem(it);
    final clave = '$texto|${it.precioUnitario}';
    final previo = grupos[clave];
    if (previo == null) {
      grupos[clave] = LineaAgrupada(
        texto: texto,
        cantidad: it.cantidad,
        unitario: it.precioUnitario,
        total: totalItem(it),
      );
    } else {
      grupos[clave] = LineaAgrupada(
        texto: texto,
        cantidad: previo.cantidad + it.cantidad,
        unitario: previo.unitario,
        total: redondear(previo.total + totalItem(it)),
      );
    }
  }
  return grupos.values.toList();
}

String facturaComoTexto(
  String nombreNegocio,
  String alias,
  List<Item> itemsCuenta,
  String modo, // 'cronologica' | 'agrupada'
) {
  final lineas = <String>[nombreNegocio.toUpperCase(), alias, '·' * 24];
  if (modo == 'cronologica') {
    for (final tanda in facturaCronologica(itemsCuenta)) {
      lineas.add('— ${horaCorta(tanda.hora)} —');
      for (final l in tanda.lineas) {
        lineas.add('${l.cantidad} × ${l.texto}  ${dinero(l.total)}');
      }
    }
  } else {
    for (final l in facturaAgrupada(itemsCuenta)) {
      lineas.add('${l.texto} ×${l.cantidad} (${dinero(l.unitario)} c/u)  ${dinero(l.total)}');
    }
  }
  lineas.add('·' * 24);
  lineas.add('TOTAL  ${dinero(totalItems(itemsCuenta))}');
  return lineas.join('\n');
}
