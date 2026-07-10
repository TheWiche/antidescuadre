// Exportar/importar configuración (sección 3.11, regla 15): SOLO catálogo,
// categorías, variantes, precios, alias de mesas y ajustes. Nunca datos
// operativos de un turno (mesas activas, cuentas, ventas, comprobantes).

import 'dart:convert';

import 'package:drift/drift.dart';

import '../datos/base.dart';

Future<Map<String, dynamic>> exportarConfiguracion(BaseDatos db) async {
  final ajustes = await db.select(db.ajustes).getSingleOrNull();
  final categorias = await db.select(db.categorias).get();
  final productos = await db.select(db.productos).get();
  final mesas = await (db.select(db.mesas)
        ..orderBy([(m) => OrderingTerm.asc(m.orden)]))
      .get();
  return {
    'app': 'antidescuadre',
    'version': 2,
    'exportadoEn': DateTime.now().toIso8601String(),
    'nombreNegocio': ajustes?.nombreNegocio ?? 'Mi bar',
    'alertaMinutos': ajustes?.alertaMinutos ?? 10,
    'simboloMoneda': ajustes?.simboloMoneda ?? '\$',
    'formato24h': ajustes?.formato24h ?? false,
    'recordatorioBackupDias': ajustes?.recordatorioBackupDias ?? 0,
    'vibracionActiva': ajustes?.vibracionActiva ?? true,
    'categorias': [
      for (final c in categorias) {'id': c.id, 'nombre': c.nombre, 'padreId': c.padreId},
    ],
    'productos': [
      for (final p in productos)
        {
          'nombre': p.nombre,
          'precio': p.precio,
          'categoriaId': p.categoriaId,
          'activo': p.activo,
          'grupos': jsonDecode(p.gruposJson),
        },
    ],
    'mesas': [
      for (final m in mesas) {'alias': m.alias, 'orden': m.orden},
    ],
  };
}

Map<String, dynamic>? validarConfiguracion(Object? dato) {
  if (dato is! Map<String, dynamic>) return null;
  // Acepta versión 1 (archivos viejos) y 2; los campos nuevos que falten
  // caen a sus valores por defecto al importar.
  if (dato['app'] != 'antidescuadre' || (dato['version'] != 1 && dato['version'] != 2)) {
    return null;
  }
  if (dato['categorias'] is! List || dato['productos'] is! List || dato['mesas'] is! List) {
    return null;
  }
  return dato;
}

// Reemplaza la configuración actual por la importada, reconstruyendo la
// jerarquía de categorías con ids nuevos. No toca datos operativos.
Future<void> importarConfiguracion(BaseDatos db, Map<String, dynamic> config) async {
  await db.transaction(() async {
    await db.delete(db.categorias).go();
    await db.delete(db.productos).go();
    await db.delete(db.mesas).go();

    final mapaIds = <int, int>{};
    final pendientes = List<Map<String, dynamic>>.from(
      (config['categorias'] as List).map((c) => Map<String, dynamic>.from(c as Map)),
    );
    var vueltas = 0;
    while (pendientes.isNotEmpty && vueltas < 100) {
      vueltas++;
      for (var i = pendientes.length - 1; i >= 0; i--) {
        final cat = pendientes[i];
        final padre = cat['padreId'] as int?;
        if (padre == null || mapaIds.containsKey(padre)) {
          final nuevoId = await db.into(db.categorias).insert(CategoriasCompanion.insert(
                nombre: cat['nombre'] as String,
                padreId: Value(padre == null ? null : mapaIds[padre]),
              ));
          mapaIds[cat['id'] as int] = nuevoId;
          pendientes.removeAt(i);
        }
      }
    }

    for (final p in config['productos'] as List) {
      final prod = Map<String, dynamic>.from(p as Map);
      final grupos = prod['grupos'];
      await db.into(db.productos).insert(ProductosCompanion.insert(
            nombre: prod['nombre'] as String,
            precio: (prod['precio'] as num).toDouble(),
            categoriaId: Value(
              prod['categoriaId'] == null ? null : mapaIds[prod['categoriaId'] as int],
            ),
            activo: Value(prod['activo'] != false),
            gruposJson: Value(grupos is List ? jsonEncode(grupos) : '[]'),
          ));
    }

    var i = 0;
    for (final m in config['mesas'] as List) {
      final mesa = Map<String, dynamic>.from(m as Map);
      await db.into(db.mesas).insert(MesasCompanion.insert(
            alias: mesa['alias'] as String,
            orden: Value(mesa['orden'] as int? ?? i),
          ));
      i++;
    }
  });
  await db.guardarAjustes(
    nombreNegocio: config['nombreNegocio'] as String? ?? 'Mi bar',
    alertaMinutos: config['alertaMinutos'] as int? ?? 10,
    simboloMoneda: config['simboloMoneda'] as String? ?? '\$',
    formato24h: config['formato24h'] as bool? ?? false,
    recordatorioBackupDias: config['recordatorioBackupDias'] as int? ?? 0,
    vibracionActiva: config['vibracionActiva'] as bool? ?? true,
  );
}
