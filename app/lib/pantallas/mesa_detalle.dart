// Detalle de mesa (secciones 3.3, 3.9, 3.10): la cuenta se ve como un ticket
// de comanda real — tandas con hora, estado de entrega por ítem, total y
// saldo — con las acciones de agregar, cobrar, factura y comprobante.

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/modelos.dart';
import '../datos/proveedores.dart';
import '../logica/cuentas.dart';
import '../logica/dinero.dart';
import '../servicios/fotos.dart';
import '../tema/tema.dart';
import '../tema/ticket.dart';
import '../widgets/camara.dart';
import '../widgets/comunes.dart';
import '../widgets/factura_vista.dart';
import '../widgets/flujo_cobro.dart';
import '../widgets/hoja.dart';
import '../widgets/selector_productos.dart';

class PantallaMesaDetalle extends ConsumerWidget {
  final int mesaId;
  const PantallaMesaDetalle({super.key, required this.mesaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesas = ref.watch(mesasProv).value ?? [];
    final mesa = mesas.where((m) => m.id == mesaId).firstOrNull;
    final turno = ref.watch(turnoActivoProv).value;
    final cuenta = ref.watch(cuentaDeMesaProv(mesaId)).value;
    final ajustes = ref.watch(ajustesProv).value;

    if (mesa == null) return const Scaffold(body: SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.base800,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: () => _renombrar(context, ref, mesa, cuenta != null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(mesa.alias, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: F.display, fontSize: 20, fontWeight: FontWeight.w700,
                ))),
            const SizedBox(width: 6),
            const Icon(LucideIcons.pencil, size: 14, color: C.crema38),
          ]),
        ),
      ),
      body: turno == null
          ? const SinTurno(mensaje: 'Inicia el turno para abrir la cuenta de esta mesa.')
          : cuenta == null
              ? _MesaLibre(mesaId: mesaId, turnoId: turno.id)
              : _CuentaAbierta(mesa: mesa, cuenta: cuenta,
                  nombreNegocio: ajustes?.nombreNegocio ?? 'Mi bar'),
    );
  }

  Future<void> _renombrar(
      BuildContext context, WidgetRef ref, Mesa mesa, bool ocupada) async {
    final controlador = TextEditingController(text: mesa.alias);
    await mostrarHoja(context, constructor: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TituloHoja('Alias de la mesa'),
            TextField(controller: controlador, autofocus: true,
                textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 14),
            Boton('Guardar', expandir: true, alTocar: () async {
              final alias = controlador.text.trim();
              if (alias.isEmpty) return;
              final db = ref.read(baseDatos);
              await (db.update(db.mesas)..where((m) => m.id.equals(mesa.id)))
                  .write(MesasCompanion(alias: Value(alias)));
              if (ctx.mounted) Navigator.pop(ctx);
            }),
            if (!ocupada) ...[
              const SizedBox(height: 10),
              Boton('Eliminar mesa', icono: LucideIcons.trash2, tono: TonoBoton.peligro,
                  expandir: true, alTocar: () async {
                final db = ref.read(baseDatos);
                await (db.delete(db.mesas)..where((m) => m.id.equals(mesa.id))).go();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) Navigator.pop(context);
              }),
            ],
          ],
        ));
  }
}

class _MesaLibre extends ConsumerWidget {
  final int mesaId;
  final int turnoId;
  const _MesaLibre({required this.mesaId, required this.turnoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cerradas = ref
            .watch(cuentasCerradasDeMesaProv((mesaId: mesaId, turnoId: turnoId)))
            .value ??
        [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Tarjeta(
          relleno: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
          child: Column(children: [
            const ChipEstado.neutro('mesa libre'),
            const SizedBox(height: 14),
            const Text(
              'Abre una cuenta y ve agregando lo que pidan; se cobra cuando ellos quieran.',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.crema60),
            ),
            const SizedBox(height: 20),
            Boton('Abrir cuenta', expandir: true, alto: 54, alTocar: () async {
              final db = ref.read(baseDatos);
              final cuentaId = await db.abrirCuentaEnMesa(mesaId, turnoId);
              if (!context.mounted) return;
              final lineas = await SelectorProductos.abrir(
                context,
                titulo: 'Agregar productos',
                textoConfirmar: 'Agregar a la cuenta',
              );
              if (lineas != null && lineas.isNotEmpty) {
                await agregarTanda(db, cuentaId, lineas);
              }
            }),
          ]),
        ),
        if (cerradas.isNotEmpty) ...[
          const SizedBox(height: 16),
          const EtiquetaCampo('Cuentas recientes de esta mesa'),
          for (final c in cerradas) ...[
            _CuentaCerradaTarjeta(cuenta: c),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

// Cuenta ya saldada de esta mesa (dentro del turno activo): permite
// "rescatarla" en vez de abrir una cuenta nueva desde cero — el caso de
// "ya cerré la cuenta pero piden una ronda más" (regla 1: no se mezcla con
// turnos ya cerrados).
class _CuentaCerradaTarjeta extends ConsumerWidget {
  final Cuenta cuenta;
  const _CuentaCerradaTarjeta({required this.cuenta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsDeCuentaProv(cuenta.id)).value ?? [];
    final total = totalItems(items);
    return Tarjeta(
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dinero(total), style: estiloMono(tamano: 16, peso: FontWeight.w700)),
            if (cuenta.cerradaEn != null)
              Text('cerrada ${horaCorta(cuenta.cerradaEn!)}',
                  style: const TextStyle(fontSize: 13, color: C.crema60)),
          ]),
        ),
        Boton('Reabrir', icono: LucideIcons.rotateCcw, tono: TonoBoton.fantasma,
            alTocar: () => ref.read(baseDatos).reabrirCuenta(cuenta.id)),
      ]),
    );
  }
}

class _CuentaAbierta extends ConsumerWidget {
  final Mesa mesa;
  final Cuenta cuenta;
  final String nombreNegocio;
  const _CuentaAbierta({required this.mesa, required this.cuenta, required this.nombreNegocio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(baseDatos);
    final items = ref.watch(itemsDeCuentaProv(cuenta.id)).value ?? [];
    final pagos = ref.watch(pagosDeCuentaProv(cuenta.id)).value ?? [];
    final total = totalItems(items);
    final pagado = totalPagado(pagos);
    final saldo = saldoCuenta(items, pagos);

    // Tandas cronológicas
    final porTanda = <int, List<Item>>{};
    for (final it in items) {
      porTanda.putIfAbsent(it.tandaId, () => []).add(it);
    }
    final tandas = porTanda.keys.toList()..sort();

    Future<void> agregar() async {
      final lineas = await SelectorProductos.abrir(
        context,
        titulo: mesa.alias,
        textoConfirmar: 'Agregar a la cuenta',
      );
      if (lineas != null && lineas.isNotEmpty) {
        await agregarTanda(db, cuenta.id, lineas);
      }
    }

    Future<void> cobrar() async {
      final saldada = await PantallaCobro.abrir(
        context,
        cuentaId: cuenta.id,
        turnoId: cuenta.turnoId,
        mesaId: mesa.id,
        mesaAlias: mesa.alias,
      );
      if (saldada && context.mounted) {
        await mostrarSello(context, 'Cuenta saldada');
        if (context.mounted) Navigator.pop(context);
      }
    }

    Future<void> comprobante() async {
      final foto = await PantallaCamara.abrir(context,
          titulo: 'Comprobante · ${mesa.alias}');
      if (foto == null) return;
      final ruta = await Fotos.guardarComprobante(foto);
      await db.into(db.comprobantes).insert(ComprobantesCompanion.insert(
            rutaArchivo: ruta,
            fecha: DateTime.now(),
            turnoId: Value(cuenta.turnoId),
            mesaId: Value(mesa.id),
            aliasMesa: Value(mesa.alias),
            cuentaId: Value(cuenta.id),
          ));
    }

    Future<void> cancelarCuenta() async {
      final ok = await confirmar(
        context,
        titulo: '¿Cancelar la cuenta?',
        detalle: 'Se quitarán los productos agregados y la mesa quedará libre.',
        textoConfirmar: 'Cancelar cuenta',
        peligro: true,
      );
      if (!ok) return;
      await (db.delete(db.items)..where((i) => i.cuentaId.equals(cuenta.id))).go();
      await (db.delete(db.cuentas)..where((c) => c.id.equals(cuenta.id))).go();
      if (context.mounted) Navigator.pop(context);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        // La cuenta como ticket de comanda (elemento firma)
        Ticket(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TicketCabecera(
              titulo: nombreNegocio,
              meta: '${mesa.alias} · abierta ${horaCorta(cuenta.abiertaEn)}',
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('— cuenta vacía, agrega el primer pedido —',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: C.papelTintaSuave)),
              ),
            for (final tandaId in tandas) ...[
              TicketHora(horaCorta(DateTime.fromMillisecondsSinceEpoch(tandaId))),
              for (final it in porTanda[tandaId]!)
                _LineaItem(item: it, alTocar: () => _opcionesItem(context, ref, it)),
            ],
            const TicketSeparador(),
            TicketLinea(izquierda: 'TOTAL', derecha: dinero(total), negrita: true),
            if (pagado > 0) ...[
              TicketLinea(izquierda: 'pagado', derecha: '−${dinero(pagado)}'),
              TicketLinea(izquierda: 'SALDO', derecha: dinero(saldo), negrita: true),
            ],
          ]),
        ),
        const SizedBox(height: 18),

        // Acciones
        Row(children: [
          Expanded(child: Boton('Agregar', icono: LucideIcons.plus, alto: 54,
              alTocar: agregar)),
          const SizedBox(width: 10),
          Expanded(child: Boton('Cobrar', icono: LucideIcons.coins,
              tono: TonoBoton.menta, alto: 54,
              alTocar: saldo > 0 ? cobrar : null)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Boton('Factura', icono: LucideIcons.receipt,
              tono: TonoBoton.fantasma,
              alTocar: items.isEmpty ? null : () => mostrarHoja(context,
                  constructor: (_) => FacturaVista(
                        nombreNegocio: nombreNegocio,
                        fecha: cuenta.abiertaEn,
                        items: items,
                      )))),
          const SizedBox(width: 10),
          Expanded(child: Boton('Comprobante', icono: LucideIcons.camera,
              tono: TonoBoton.fantasma, alTocar: comprobante)),
          if (pagos.isEmpty) ...[
            const SizedBox(width: 10),
            Boton('', icono: LucideIcons.trash2, tono: TonoBoton.peligro,
                alTocar: cancelarCuenta),
          ],
        ]),
      ],
    );
  }

  Future<void> _opcionesItem(BuildContext context, WidgetRef ref, Item it) async {
    final db = ref.read(baseDatos);
    final variantes = seleccionesDeJson(it.variantesJson);
    await mostrarHoja(context, constructor: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TituloHoja(
              '${it.cantidad}× ${it.nombre}',
              sub: variantes.isNotEmpty ? etiquetaVariantes(variantes) : null,
            ),
            if (it.estado == 'pendiente')
              Boton('Marcar entregado', icono: LucideIcons.check, tono: TonoBoton.menta,
                  expandir: true, alTocar: () async {
                await (db.update(db.items)..where((i) => i.id.equals(it.id)))
                    .write(ItemsCompanion(
                  estado: const Value('entregado'),
                  entregadoEn: Value(DateTime.now()),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              })
            else
              Boton('Devolver a pendiente', icono: LucideIcons.circleDashed,
                  tono: TonoBoton.fantasma, expandir: true, alTocar: () async {
                await (db.update(db.items)..where((i) => i.id.equals(it.id)))
                    .write(const ItemsCompanion(
                  estado: Value('pendiente'),
                  entregadoEn: Value(null),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              }),
            const SizedBox(height: 10),
            Boton('Quitar de la cuenta', icono: LucideIcons.trash2,
                tono: TonoBoton.peligro, expandir: true, alTocar: () async {
              await (db.delete(db.items)..where((i) => i.id.equals(it.id))).go();
              if (ctx.mounted) Navigator.pop(ctx);
            }),
          ],
        ));
  }
}

class _LineaItem extends StatelessWidget {
  final Item item;
  final VoidCallback alTocar;
  const _LineaItem({required this.item, required this.alTocar});

  @override
  Widget build(BuildContext context) {
    final variantes = seleccionesDeJson(item.variantesJson);
    return TweenAnimationBuilder(
      key: ValueKey(item.id),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (_, v, hijo) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - v) * -10), child: hijo),
      ),
      child: TicketLinea(
        izquierda: '${item.cantidad}× ${item.nombre}'
            '${variantes.isNotEmpty ? ' · ${etiquetaVariantes(variantes)}' : ''}',
        derecha: dinero(totalItem(item)),
        indicador: Icon(
          item.estado == 'pendiente' ? LucideIcons.circleDashed : LucideIcons.check,
          size: 13,
          color: item.estado == 'pendiente' ? C.tintaAlerta : C.tintaExito,
        ),
        alTocar: alTocar,
      ),
    );
  }
}
