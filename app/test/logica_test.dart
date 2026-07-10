// Tests de la lógica de negocio pura, fiel a planificacion-app-cuadre.md:
// dinero/redondeos, precios con variantes anidadas, saldos, división en
// partes con residuo, factura cronológica/agrupada y export/import.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:antidescuadre/datos/base.dart';
import 'package:antidescuadre/datos/modelos.dart';
import 'package:antidescuadre/logica/cuentas.dart';
import 'package:antidescuadre/logica/dinero.dart';
import 'package:antidescuadre/logica/factura.dart';
import 'package:antidescuadre/logica/configuracion.dart';

Item itemPrueba({
  int id = 1,
  int cuentaId = 1,
  String nombre = 'Cerveza',
  String variantesJson = '[]',
  int cantidad = 1,
  double precioUnitario = 2.5,
  String estado = 'pendiente',
  int? tandaId,
  DateTime? agregadoEn,
}) {
  final ahora = agregadoEn ?? DateTime(2026, 7, 10, 20, 0);
  return Item(
    id: id,
    cuentaId: cuentaId,
    productoId: null,
    nombre: nombre,
    variantesJson: variantesJson,
    cantidad: cantidad,
    precioUnitario: precioUnitario,
    estado: estado,
    agregadoEn: ahora,
    entregadoEn: null,
    tandaId: tandaId ?? ahora.millisecondsSinceEpoch,
    parteId: null,
  );
}

Pago pagoPrueba({double monto = 5, double efectivo = 5, double transferencia = 0}) => Pago(
      id: 1,
      cuentaId: 1,
      turnoId: 1,
      etiqueta: 'Parte',
      monto: monto,
      efectivo: efectivo,
      transferencia: transferencia,
      recibido: null,
      vuelto: null,
      creadoEn: DateTime(2026, 7, 10, 21, 0),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('dinero', () {
    test('redondea a centavos y evita arrastres de flotante', () {
      expect(redondear(0.1 + 0.2), 0.3);
      expect(redondear(10 / 3), 3.33);
    });

    test('formatea sin decimales cuando no hacen falta', () {
      expect(dinero(5), '\$5');
      expect(dinero(3.5), contains('3'));
      expect(dinero(3.5), contains('50'));
    });

    test('leerMonto tolera comas, símbolos y basura', () {
      expect(leerMonto('2,50'), 2.5);
      expect(leerMonto(r'$ 12.00'), 12);
      expect(leerMonto('abc'), 0);
      expect(leerMonto('-5'), 5); // el signo se descarta: nunca montos negativos
    });
  });

  group('precios con variantes (regla 5)', () {
    final michelada = Producto(
      id: 1, nombre: 'Michelada', precio: 3, categoriaId: null, activo: true,
      gruposJson: '[]',
    );

    test('suma los deltas del camino elegido', () {
      final seleccion = [
        const SeleccionVariante(grupo: 'Base', camino: ['Cerveza', 'Corona'], delta: 0.5),
      ];
      expect(precioUnitario(michelada, seleccion), 3.5);
    });

    test('sin variantes usa el precio base', () {
      expect(precioUnitario(michelada, const []), 3);
    });

    test('el árbol de variantes sobrevive ida y vuelta por JSON', () {
      final grupos = [
        const GrupoVariante(id: 'g1', nombre: 'Base', opciones: [
          OpcionVariante(id: 'o1', nombre: 'Cerveza', hijas: [
            OpcionVariante(id: 'o2', nombre: 'Corona', delta: 0.5),
          ]),
          OpcionVariante(id: 'o3', nombre: 'Soda'),
        ]),
      ];
      final vuelta = gruposDeJson(gruposAJson(grupos));
      expect(vuelta.single.nombre, 'Base');
      expect(vuelta.single.opciones.first.hijas.single.delta, 0.5);
      expect(vuelta.single.opciones.last.nombre, 'Soda');
    });
  });

  group('saldos', () {
    test('saldo = total de ítems - pagado', () {
      final lista = [
        itemPrueba(cantidad: 3, precioUnitario: 2.5), // 7.50
        itemPrueba(id: 2, precioUnitario: 3.5), // 3.50
      ];
      expect(totalItems(lista), 11);
      expect(saldoCuenta(lista, [pagoPrueba(monto: 5)]), 6);
      expect(saldoCuenta(lista, [pagoPrueba(monto: 11)]), 0);
    });
  });

  group('división por partes (regla 6)', () {
    test('partes iguales: la última absorbe el residuo del redondeo', () {
      final partes = partesIguales(10, 3);
      expect(partes, [3.33, 3.33, 3.34]);
      expect(redondear(partes.fold(0.0, (s, p) => s + p)), 10);
    });

    test('reparto exacto no deja residuo', () {
      expect(partesIguales(9, 3), [3, 3, 3]);
    });
  });

  group('factura (sección 3.10)', () {
    final tanda1 = DateTime(2026, 7, 10, 20, 0).millisecondsSinceEpoch;
    final tanda2 = DateTime(2026, 7, 10, 20, 30).millisecondsSinceEpoch;
    final lista = [
      itemPrueba(id: 1, cantidad: 3, tandaId: tanda1),
      itemPrueba(id: 2, cantidad: 3, tandaId: tanda2),
      itemPrueba(
        id: 3,
        nombre: 'Michelada',
        precioUnitario: 3.5,
        tandaId: tanda2,
        variantesJson:
            '[{"grupo":"Base","camino":["Cerveza","Corona"],"delta":0.5}]',
      ),
    ];

    test('cronológica: una tanda por confirmación, en orden', () {
      final tandas = facturaCronologica(lista);
      expect(tandas, hasLength(2));
      expect(tandas.first.lineas.single.cantidad, 3);
      expect(tandas.last.lineas, hasLength(2));
      expect(tandas.last.lineas.last.texto, 'Michelada (Cerveza · Corona)');
    });

    test('agrupada: mismos datos sumados por producto+variante', () {
      final grupos = facturaAgrupada(lista);
      expect(grupos, hasLength(2));
      final cerveza = grupos.firstWhere((g) => g.texto == 'Cerveza');
      expect(cerveza.cantidad, 6);
      expect(cerveza.total, 15);
    });

    test('texto compartible incluye el total y no el alias de la mesa', () {
      final texto = facturaComoTexto('Mi bar', lista, 'agrupada');
      expect(texto, contains('MI BAR'));
      expect(texto, contains('TOTAL'));
      expect(texto, isNot(contains('VIP 2')));
    });
  });

  group('configuración exportable (regla 15)', () {
    test('valida el formato y rechaza archivos ajenos', () {
      expect(validarConfiguracion({'app': 'otra', 'version': 1}), isNull);
      expect(validarConfiguracion('texto'), isNull);
      expect(
        validarConfiguracion({
          'app': 'antidescuadre', 'version': 1,
          'categorias': [], 'productos': [], 'mesas': [],
        }),
        isNotNull,
      );
    });
  });
}
