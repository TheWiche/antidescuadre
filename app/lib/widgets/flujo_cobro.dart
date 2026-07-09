// Flujo de cobro (sección 3.5): una cuenta se cobra completa o dividida por
// partes (iguales o manuales) o por consumo real. Cada parte puede combinar
// efectivo y transferencia (regla 7); toda transferencia exige foto de
// comprobante (regla 8); el vuelto es opcional y en vivo (regla 11).

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
import 'camara.dart';
import 'comunes.dart';

class PantallaCobro extends ConsumerStatefulWidget {
  final int cuentaId;
  final int turnoId;
  final int? mesaId;
  final String mesaAlias;
  final bool soloTotal; // venta directa: cobro inmediato sin división

  const PantallaCobro({
    super.key,
    required this.cuentaId,
    required this.turnoId,
    required this.mesaId,
    required this.mesaAlias,
    this.soloTotal = false,
  });

  /// Devuelve true si la cuenta quedó saldada (y cerrada).
  static Future<bool> abrir(
    BuildContext context, {
    required int cuentaId,
    required int turnoId,
    required int? mesaId,
    required String mesaAlias,
    bool soloTotal = false,
  }) async {
    final r = await Navigator.of(context).push<bool>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PantallaCobro(
        cuentaId: cuentaId, turnoId: turnoId, mesaId: mesaId,
        mesaAlias: mesaAlias, soloTotal: soloTotal,
      ),
    ));
    return r ?? false;
  }

  @override
  ConsumerState<PantallaCobro> createState() => _PantallaCobroState();
}

class _PantallaCobroState extends ConsumerState<PantallaCobro> {
  late String _modo = widget.soloTotal ? 'todo' : 'elegir';
  ({String etiqueta, double monto})? _parteActiva;

  Future<void> _registrarPago({
    required String etiqueta,
    required double monto,
    required double efectivo,
    required double transferencia,
    double? recibido,
    double? vuelto,
    List<int>? fotoComprobante,
    required double saldoPrevio,
  }) async {
    final db = ref.read(baseDatos);
    final pagoId = await db.into(db.pagos).insert(PagosCompanion.insert(
          cuentaId: widget.cuentaId,
          turnoId: widget.turnoId,
          etiqueta: etiqueta,
          monto: monto,
          efectivo: efectivo,
          transferencia: transferencia,
          recibido: Value(recibido),
          vuelto: Value(vuelto),
          creadoEn: DateTime.now(),
        ));

    if (fotoComprobante != null) {
      // Regla 8: la transferencia nace "pendiente de legalizar", ligada a la mesa
      final ruta = await Fotos.guardarComprobante(
        Uint8List.fromList(fotoComprobante),
      );
      await db.into(db.comprobantes).insert(ComprobantesCompanion.insert(
            rutaArchivo: ruta,
            fecha: DateTime.now(),
            turnoId: Value(widget.turnoId),
            mesaId: Value(widget.mesaId),
            aliasMesa: Value(widget.mesaId != null ? widget.mesaAlias : null),
            cuentaId: Value(widget.cuentaId),
            pagoId: Value(pagoId),
            monto: Value(transferencia),
          ));
    }

    final nuevoSaldo = redondear(saldoPrevio - monto);
    if (nuevoSaldo <= 0) {
      await db.cerrarCuenta(widget.cuentaId);
      if (mounted) Navigator.pop(context, true);
      return;
    }
    setState(() {
      _parteActiva = null;
      if (_modo == 'todo' && !widget.soloTotal) _modo = 'elegir';
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsDeCuentaProv(widget.cuentaId)).value ?? [];
    final pagos = ref.watch(pagosDeCuentaProv(widget.cuentaId)).value ?? [];
    final saldo = saldoCuenta(items, pagos);
    final pagado = totalPagado(pagos);

    // En "cobrar todo" la parte se deriva del saldo en vivo, nunca se congela.
    final parteMostrada = _parteActiva ??
        (_modo == 'todo' && saldo > 0
            ? (etiqueta: 'Cuenta completa', monto: saldo)
            : null);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.ciruela800,
        centerTitle: true,
        title: Text('Cobrar · ${widget.mesaAlias}', style: const TextStyle(
          fontFamily: F.display, fontSize: 19, fontWeight: FontWeight.w700,
        )),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (_parteActiva != null && !widget.soloTotal && _modo != 'todo') {
              setState(() => _parteActiva = null);
            } else if (_modo != 'elegir' && !widget.soloTotal) {
              setState(() { _parteActiva = null; _modo = 'elegir'; });
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          // Saldo grande
          Center(child: Column(children: [
            const Text('POR COBRAR', style: TextStyle(
              fontSize: 12, letterSpacing: 1.2, color: C.crema38, fontWeight: FontWeight.w600,
            )),
            Text(dinero(saldo), style: const TextStyle(
              fontFamily: F.display, fontSize: 42, fontWeight: FontWeight.w700, color: C.crema,
            )),
            if (pagado > 0) ChipEstado.menta('ya pagado ${dinero(pagado)}', mono: true),
          ])),
          const SizedBox(height: 18),

          if (parteMostrada != null)
            _FormularioParte(
              key: ValueKey('${parteMostrada.etiqueta}|${parteMostrada.monto}'),
              etiqueta: parteMostrada.etiqueta,
              montoInicial: parteMostrada.monto,
              maximo: saldo,
              alConfirmar: (datos) => _registrarPago(
                etiqueta: datos.etiqueta,
                monto: datos.monto,
                efectivo: datos.efectivo,
                transferencia: datos.transferencia,
                recibido: datos.recibido,
                vuelto: datos.vuelto,
                fotoComprobante: datos.foto,
                saldoPrevio: saldo,
              ),
              alCancelar: () {
                setState(() {
                  _parteActiva = null;
                  if (_modo == 'todo') {
                    if (widget.soloTotal) {
                      Navigator.pop(context, false);
                    } else {
                      _modo = 'elegir';
                    }
                  }
                });
              },
            )
          else if (_modo == 'elegir') ...[
            _OpcionModo(titulo: 'Cobrar todo', detalle: 'La cuenta completa de una vez',
                alTocar: () => setState(() => _modo = 'todo')),
            const SizedBox(height: 12),
            _OpcionModo(titulo: 'Dividir en partes', detalle: 'Partes iguales o montos a mano',
                alTocar: () => setState(() => _modo = 'partes')),
            const SizedBox(height: 12),
            _OpcionModo(titulo: 'Por consumo', detalle: 'Cada quien paga lo que tomó',
                alTocar: () => setState(() => _modo = 'consumo')),
          ] else if (_modo == 'partes')
            _DivisionPorPartes(
              saldo: saldo,
              alCobrarParte: (p) => setState(() => _parteActiva = p),
            )
          else if (_modo == 'consumo')
            _DivisionPorConsumo(
              items: items,
              alCobrarPersona: (nombre, monto) =>
                  setState(() => _parteActiva = (etiqueta: nombre, monto: monto)),
            ),
        ],
      ),
    );
  }
}

class _OpcionModo extends StatelessWidget {
  final String titulo;
  final String detalle;
  final VoidCallback alTocar;
  const _OpcionModo({required this.titulo, required this.detalle, required this.alTocar});

  @override
  Widget build(BuildContext context) => Tarjeta(
        alTocar: alTocar,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: const TextStyle(
            fontFamily: F.display, fontSize: 17, fontWeight: FontWeight.w700,
          )),
          Text(detalle, style: const TextStyle(fontSize: 13.5, color: C.crema60)),
        ]),
      );
}

// ---------- División por partes (iguales o manuales) ----------

class _DivisionPorPartes extends StatefulWidget {
  final double saldo;
  final ValueChanged<({String etiqueta, double monto})> alCobrarParte;
  const _DivisionPorPartes({required this.saldo, required this.alCobrarParte});

  @override
  State<_DivisionPorPartes> createState() => _DivisionPorPartesState();
}

class _DivisionPorPartesState extends State<_DivisionPorPartes> {
  int _n = 2;
  final Map<int, String> _manuales = {};

  @override
  Widget build(BuildContext context) {
    final iguales = partesIguales(widget.saldo, _n);
    final partes = [
      for (var i = 0; i < _n; i++)
        _manuales.containsKey(i) ? leerMonto(_manuales[i]!) : iguales[i],
    ];
    final suma = redondear(partes.fold(0.0, (s, p) => s + p));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Tarjeta(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('¿En cuántas partes?', style: TextStyle(fontWeight: FontWeight.w600)),
          Stepper2(valor: _n, minimo: 2,
              alCambiar: (v) => setState(() { _n = v.clamp(2, 20); _manuales.clear(); })),
        ]),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < _n; i++) ...[
        Tarjeta(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Parte ${i + 1} de $_n', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue: _manuales[i] ?? '${partes[i]}',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: estiloMono(),
                    onChanged: (v) => setState(() => _manuales[i] = v),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
              ]),
            ),
            Boton('Cobrar',
                alTocar: partes[i] > 0 && partes[i] <= widget.saldo + 0.005
                    ? () => widget.alCobrarParte(
                        (etiqueta: 'Parte ${i + 1} de $_n', monto: partes[i]))
                    : null),
          ]),
        ),
        const SizedBox(height: 12),
      ],
      if ((suma - widget.saldo).abs() > 0.005)
        Text(
          'Las partes suman ${dinero(suma)} y el saldo es ${dinero(widget.saldo)} — se cobra parte por parte, el saldo manda.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: C.ambar),
        ),
    ]);
  }
}

// ---------- División por consumo real ----------
// Se asignan ítems a cada persona; la asignación se guarda en el ítem
// (parteId) para poder salir y volver sin perderla.

class _DivisionPorConsumo extends ConsumerStatefulWidget {
  final List<Item> items;
  final void Function(String nombre, double monto) alCobrarPersona;
  const _DivisionPorConsumo({required this.items, required this.alCobrarPersona});

  @override
  ConsumerState<_DivisionPorConsumo> createState() => _DivisionPorConsumoState();
}

class _DivisionPorConsumoState extends ConsumerState<_DivisionPorConsumo> {
  final List<String> _personasNuevas = [];
  String? _activa;
  final _nombreCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  List<String> get _personas => {
        ...widget.items.where((i) => i.parteId != null).map((i) => i.parteId!),
        ..._personasNuevas,
      }.toList();

  double _subtotal(String persona) => redondear(widget.items
      .where((i) => i.parteId == persona)
      .fold(0.0, (s, i) => s + totalItem(i)));

  void _agregarPersona() {
    final nombre = _nombreCtrl.text.trim().isEmpty
        ? 'Persona ${_personas.length + 1}'
        : _nombreCtrl.text.trim();
    setState(() {
      if (!_personas.contains(nombre)) _personasNuevas.add(nombre);
      _activa = nombre;
      _nombreCtrl.clear();
    });
  }

  Future<void> _alternarItem(Item item) async {
    if (_activa == null) return;
    final db = ref.read(baseDatos);
    final nuevo = item.parteId == _activa ? null : _activa;
    await (db.update(db.items)..where((i) => i.id.equals(item.id)))
        .write(ItemsCompanion(parteId: Value(nuevo)));
  }

  @override
  Widget build(BuildContext context) {
    final sinAsignar = widget.items.where((i) => i.parteId == null).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final p in _personas)
          GestureDetector(
            onTap: () => setState(() => _activa = _activa == p ? null : p),
            child: _activa == p
                ? ChipEstado.ambar('$p · ${dinero(_subtotal(p))}',
                    icono: LucideIcons.user)
                : ChipEstado.neutro('$p · ${dinero(_subtotal(p))}',
                    icono: LucideIcons.user),
          ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(hintText: 'Nombre (opcional)…'),
            onSubmitted: (_) => _agregarPersona(),
          ),
        ),
        const SizedBox(width: 10),
        Boton('Persona', icono: LucideIcons.plus, tono: TonoBoton.fantasma,
            alTocar: _agregarPersona),
      ]),
      const SizedBox(height: 10),
      Text(
        _activa != null
            ? 'Toca los productos que consumió $_activa:'
            : _personas.isNotEmpty
                ? 'Elige una persona para asignarle productos.'
                : 'Agrega a las personas que van a pagar.',
        style: TextStyle(fontSize: 13.5,
            color: _activa != null ? C.ambar : C.crema60),
      ),
      const SizedBox(height: 8),

      Tarjeta(
        relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(children: [
          for (final it in widget.items)
            InkWell(
              onTap: () => _alternarItem(it),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${it.cantidad > 1 ? '${it.cantidad} × ' : ''}${it.nombre}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (seleccionesDeJson(it.variantesJson).isNotEmpty)
                        Text(etiquetaVariantes(seleccionesDeJson(it.variantesJson)),
                            style: const TextStyle(fontSize: 13, color: C.crema60)),
                    ]),
                  ),
                  Text(dinero(totalItem(it)),
                      style: estiloMono(tamano: 13, color: C.crema60)),
                  if (it.parteId != null) ...[
                    const SizedBox(width: 8),
                    it.parteId == _activa
                        ? ChipEstado.ambar(it.parteId!)
                        : ChipEstado.neutro(it.parteId!),
                  ],
                ]),
              ),
            ),
          if (widget.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin productos', style: TextStyle(color: C.crema38)),
            ),
        ]),
      ),
      if (sinAsignar == 0 && widget.items.isNotEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Todo asignado ✓', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: C.menta)),
        ),
      const SizedBox(height: 12),

      for (final p in _personas.where((p) => _subtotal(p) > 0)) ...[
        Tarjeta(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(dinero(_subtotal(p)), style: estiloMono(tamano: 13, color: C.crema60)),
              ]),
            ),
            Boton('Cobrar', alTocar: () => widget.alCobrarPersona(p, _subtotal(p))),
          ]),
        ),
        const SizedBox(height: 12),
      ],
    ]);
  }
}

// ---------- Formulario de una parte: métodos combinados + vuelto ----------

class DatosPago {
  final String etiqueta;
  final double monto;
  final double efectivo;
  final double transferencia;
  final double? recibido;
  final double? vuelto;
  final List<int>? foto;
  const DatosPago({
    required this.etiqueta, required this.monto, required this.efectivo,
    required this.transferencia, this.recibido, this.vuelto, this.foto,
  });
}

class _FormularioParte extends StatefulWidget {
  final String etiqueta;
  final double montoInicial;
  final double maximo;
  final ValueChanged<DatosPago> alConfirmar;
  final VoidCallback alCancelar;

  const _FormularioParte({
    super.key,
    required this.etiqueta,
    required this.montoInicial,
    required this.maximo,
    required this.alConfirmar,
    required this.alCancelar,
  });

  @override
  State<_FormularioParte> createState() => _FormularioParteState();
}

class _FormularioParteState extends State<_FormularioParte> {
  late final _efectivoCtrl = TextEditingController(text: '${widget.montoInicial}');
  late final _transferCtrl = TextEditingController(text: '0');
  final _recibidoCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _efectivoCtrl.dispose();
    _transferCtrl.dispose();
    _recibidoCtrl.dispose();
    super.dispose();
  }

  void _repartir(bool todoEfectivo) => setState(() {
        _efectivoCtrl.text = todoEfectivo ? '${widget.montoInicial}' : '0';
        _transferCtrl.text = todoEfectivo ? '0' : '${widget.montoInicial}';
      });

  Future<void> _terminar() async {
    if (_guardando) return;
    final efectivo = leerMonto(_efectivoCtrl.text);
    final transferencia = leerMonto(_transferCtrl.text);
    final monto = redondear(efectivo + transferencia);
    final recibido =
        _recibidoCtrl.text.trim().isEmpty ? null : leerMonto(_recibidoCtrl.text);
    final vuelto = recibido != null ? redondear(recibido - efectivo) : null;

    List<int>? foto;
    if (transferencia > 0) {
      // Regla 8: toda transferencia requiere foto de comprobante
      foto = await PantallaCamara.abrir(context,
          titulo: 'Comprobante · ${dinero(transferencia)}');
      if (foto == null) return; // canceló la cámara: no se cobra
    }
    setState(() => _guardando = true);
    widget.alConfirmar(DatosPago(
      etiqueta: widget.etiqueta,
      monto: monto,
      efectivo: efectivo,
      transferencia: transferencia,
      recibido: recibido,
      vuelto: vuelto != null && vuelto >= 0 ? vuelto : null,
      foto: foto,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final efectivo = leerMonto(_efectivoCtrl.text);
    final transferencia = leerMonto(_transferCtrl.text);
    final monto = redondear(efectivo + transferencia);
    final recibido =
        _recibidoCtrl.text.trim().isEmpty ? null : leerMonto(_recibidoCtrl.text);
    final vuelto = recibido != null ? redondear(recibido - efectivo) : null;
    final valido = monto > 0 && monto <= widget.maximo + 0.005;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.etiqueta, style: const TextStyle(
          fontFamily: F.display, fontSize: 18, fontWeight: FontWeight.w700,
        )),
        Text(dinero(widget.montoInicial),
            style: estiloMono(tamano: 18, peso: FontWeight.w700)),
      ]),
      const SizedBox(height: 12),

      Row(children: [
        GestureDetector(
          onTap: () => _repartir(true),
          child: const ChipEstado.ambar('Todo efectivo', icono: LucideIcons.banknote),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _repartir(false),
          child: const ChipEstado.cian('Todo transferencia', icono: LucideIcons.landmark),
        ),
      ]),
      const SizedBox(height: 14),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const EtiquetaCampo('Efectivo', color: C.ambar),
          TextField(
            controller: _efectivoCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: estiloMono(),
            onTap: () => _efectivoCtrl.selection = TextSelection(
                baseOffset: 0, extentOffset: _efectivoCtrl.text.length),
            onChanged: (v) => setState(() {
              final resto = redondear(widget.montoInicial - leerMonto(v));
              _transferCtrl.text = '${resto > 0 ? resto : 0}';
            }),
          ),
        ])),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const EtiquetaCampo('Transferencia', color: C.cian),
          TextField(
            controller: _transferCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: estiloMono(),
            onTap: () => _transferCtrl.selection = TextSelection(
                baseOffset: 0, extentOffset: _transferCtrl.text.length),
            onChanged: (v) => setState(() {
              final resto = redondear(widget.montoInicial - leerMonto(v));
              _efectivoCtrl.text = '${resto > 0 ? resto : 0}';
            }),
          ),
        ])),
      ]),
      const SizedBox(height: 10),

      if (valido && (monto - redondear(widget.montoInicial)).abs() > 0.005)
        Text('Se cobrarán ${dinero(monto)} (los métodos suman distinto a la parte original).',
            style: const TextStyle(fontSize: 13, color: C.ambar)),
      if (!valido && monto > 0)
        Text('No puede superar el saldo (${dinero(widget.maximo)}).',
            style: const TextStyle(fontSize: 13, color: C.rojo)),

      if (efectivo > 0) ...[
        const SizedBox(height: 8),
        Tarjeta(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const EtiquetaCampo('¿Con cuánto paga? (opcional, para el vuelto)'),
            TextField(
              controller: _recibidoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: estiloMono(),
              decoration: const InputDecoration(hintText: 'ej. 20'),
              onChanged: (_) => setState(() {}),
            ),
            if (vuelto != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Vuelto', style: TextStyle(color: C.crema60)),
                  Text(
                    '${dinero(vuelto.abs())}${vuelto < 0 ? ' faltan' : ''}',
                    style: estiloMono(tamano: 22, peso: FontWeight.w700,
                        color: vuelto >= 0 ? C.menta : C.rojo),
                  ),
                ]),
              ),
          ]),
        ),
      ],
      const SizedBox(height: 16),

      Boton(
        transferencia > 0
            ? 'Tomar comprobante y cobrar ${dinero(monto)}'
            : 'Cobrar ${dinero(monto)}',
        icono: transferencia > 0 ? LucideIcons.camera : LucideIcons.check,
        tono: transferencia > 0 ? TonoBoton.cian : TonoBoton.ambar,
        expandir: true,
        alto: 54,
        alTocar: valido && !_guardando ? _terminar : null,
      ),
      const SizedBox(height: 10),
      Boton('Cancelar', icono: LucideIcons.x, tono: TonoBoton.fantasma,
          expandir: true, alTocar: widget.alCancelar),
    ]);
  }
}
