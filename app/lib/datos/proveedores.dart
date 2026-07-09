// Proveedores Riverpod: una sola instancia de la base y streams reactivos
// que la UI observa (equivalente al useLiveQuery de la versión web).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base.dart';

final baseDatos = Provider<BaseDatos>((ref) => BaseDatos());

final turnoActivoProv = StreamProvider<Turno?>(
  (ref) => ref.watch(baseDatos).verTurnoActivo(),
);

final ajustesProv = StreamProvider<Ajuste>(
  (ref) => ref.watch(baseDatos).verAjustes(),
);

final mesasProv = StreamProvider<List<Mesa>>(
  (ref) => ref.watch(baseDatos).verMesas(),
);

final pendientesLegalizarProv = StreamProvider<int>(
  (ref) => ref.watch(baseDatos).verPendientesLegalizar(),
);

final cuentasAbiertasProv = StreamProvider.family<List<Cuenta>, int>(
  (ref, turnoId) => ref.watch(baseDatos).verCuentasAbiertas(turnoId),
);

final cuentaDeMesaProv = StreamProvider.family<Cuenta?, int>(
  (ref, mesaId) => ref.watch(baseDatos).verCuentaActivaDeMesa(mesaId),
);

final itemsDeCuentaProv = StreamProvider.family<List<Item>, int>(
  (ref, cuentaId) => ref.watch(baseDatos).verItemsDeCuenta(cuentaId),
);

final pagosDeCuentaProv = StreamProvider.family<List<Pago>, int>(
  (ref, cuentaId) => ref.watch(baseDatos).verPagosDeCuenta(cuentaId),
);

final pagosDeTurnoProv = StreamProvider.family<List<Pago>, int>(
  (ref, turnoId) => ref.watch(baseDatos).verPagosDeTurno(turnoId),
);

final itemsAbiertosDeTurnoProv = StreamProvider.family<List<Item>, int>(
  (ref, turnoId) => ref.watch(baseDatos).verItemsAbiertosDeTurno(turnoId),
);

final pagosAbiertosDeTurnoProv = StreamProvider.family<List<Pago>, int>(
  (ref, turnoId) => ref.watch(baseDatos).verPagosDeCuentasAbiertas(turnoId),
);

final turnosCerradosProv = StreamProvider<List<Turno>>(
  (ref) => ref.watch(baseDatos).verTurnosCerrados(),
);

final categoriasProv = StreamProvider<List<Categoria>>(
  (ref) => ref.watch(baseDatos).select(ref.watch(baseDatos).categorias).watch(),
);

final productosProv = StreamProvider<List<Producto>>(
  (ref) => ref.watch(baseDatos).select(ref.watch(baseDatos).productos).watch(),
);
