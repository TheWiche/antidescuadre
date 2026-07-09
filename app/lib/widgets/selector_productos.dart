// Selector de productos: la interacción central de la app (sección 4).
// Tocar un producto sin variantes lo suma al instante con rebote de
// confirmación; uno con variantes abre su hoja de opciones (anidadas).
// La canasta vive abajo y se confirma en un solo gesto.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/modelos.dart';
import '../datos/proveedores.dart';
import '../logica/cuentas.dart';
import '../logica/dinero.dart';
import '../tema/tema.dart';
import '../widgets/comunes.dart';
import '../widgets/hoja.dart';

class SelectorProductos extends ConsumerStatefulWidget {
  final String titulo;
  final String textoConfirmar;

  const SelectorProductos({super.key, required this.titulo, required this.textoConfirmar});

  /// Abre el selector a pantalla completa; devuelve las líneas confirmadas o null.
  static Future<List<LineaNueva>?> abrir(
    BuildContext context, {
    required String titulo,
    required String textoConfirmar,
  }) =>
      Navigator.of(context).push<List<LineaNueva>>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SelectorProductos(titulo: titulo, textoConfirmar: textoConfirmar),
      ));

  @override
  ConsumerState<SelectorProductos> createState() => _SelectorProductosState();
}

class _SelectorProductosState extends ConsumerState<SelectorProductos> {
  int? _categoriaActual;
  String _filtro = '';
  final List<LineaNueva> _canasta = [];
  int? _reboteId;

  String _clave(LineaNueva l) =>
      '${l.producto.id}|${l.variantes.map((v) => v.camino.join('>')).join('|')}';

  void _sumar(Producto producto, List<SeleccionVariante> variantes, int cantidad) {
    setState(() {
      final nueva = LineaNueva(producto: producto, variantes: variantes, cantidad: cantidad);
      final i = _canasta.indexWhere((l) => _clave(l) == _clave(nueva));
      if (i >= 0) {
        _canasta[i] = LineaNueva(
          producto: producto, variantes: variantes,
          cantidad: _canasta[i].cantidad + cantidad,
        );
      } else {
        _canasta.add(nueva);
      }
      _reboteId = producto.id;
    });
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted && _reboteId == producto.id) setState(() => _reboteId = null);
    });
  }

  int _cantidadDe(Producto p) => _canasta
      .where((l) => l.producto.id == p.id)
      .fold(0, (s, l) => s + l.cantidad);

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProv).value ?? [];
    final productos =
        (ref.watch(productosProv).value ?? []).where((p) => p.activo).toList();

    // Rastro de categorías (migas)
    final rastro = <Categoria>[];
    var actual = categorias.where((c) => c.id == _categoriaActual).firstOrNull;
    while (actual != null) {
      rastro.insert(0, actual);
      final padre = actual.padreId;
      actual = categorias.where((c) => c.id == padre).firstOrNull;
    }
    final subcategorias =
        categorias.where((c) => c.padreId == _categoriaActual).toList();

    // Productos visibles: filtro de texto o categoría actual + descendientes
    List<Producto> visibles;
    final texto = _filtro.trim().toLowerCase();
    if (texto.isNotEmpty) {
      visibles = productos.where((p) => p.nombre.toLowerCase().contains(texto)).toList();
    } else if (_categoriaActual == null) {
      visibles = productos;
    } else {
      final descendientes = <int>{_categoriaActual!};
      var crecio = true;
      while (crecio) {
        crecio = false;
        for (final c in categorias) {
          if (c.padreId != null &&
              descendientes.contains(c.padreId) &&
              !descendientes.contains(c.id)) {
            descendientes.add(c.id);
            crecio = true;
          }
        }
      }
      visibles = productos
          .where((p) => p.categoriaId != null && descendientes.contains(p.categoriaId))
          .toList();
    }

    final totalCanasta = redondear(_canasta.fold(0.0, (s, l) => s + l.total));
    final cantidadCanasta = _canasta.fold(0, (s, l) => s + l.cantidad);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.ciruela800,
        title: Text(widget.titulo, style: const TextStyle(
          fontFamily: F.display, fontSize: 19, fontWeight: FontWeight.w700,
        )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _filtro = v),
            decoration: const InputDecoration(
              hintText: 'Buscar producto…',
              prefixIcon: Icon(LucideIcons.search, size: 18, color: C.crema38),
            ),
          ),
        ),

        // Migas de categorías
        if (texto.isEmpty)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_categoriaActual != null) ...[
                  _ChipNav(
                    icono: LucideIcons.chevronLeft,
                    texto: rastro.length > 1 ? rastro[rastro.length - 2].nombre : 'Todo',
                    alTocar: () => setState(() => _categoriaActual =
                        rastro.length > 1 ? rastro[rastro.length - 2].id : null),
                  ),
                  const SizedBox(width: 8),
                  ChipEstado.ambar(rastro.last.nombre),
                  const SizedBox(width: 8),
                ],
                for (final c in subcategorias) ...[
                  _ChipNav(texto: c.nombre,
                      alTocar: () => setState(() => _categoriaActual = c.id)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),

        // Cuadrícula de productos
        Expanded(
          child: visibles.isEmpty
              ? Vacio(
                  icono: LucideIcons.package,
                  titulo: productos.isEmpty
                      ? 'El catálogo está vacío'
                      : 'Nada por aquí',
                  detalle: productos.isEmpty ? 'Créalo en Más → Catálogo.' : null,
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190, mainAxisExtent: 96,
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: visibles.length,
                  itemBuilder: (_, i) {
                    final p = visibles[i];
                    final enCanasta = _cantidadDe(p);
                    return _TarjetaProducto(
                      producto: p,
                      enCanasta: enCanasta,
                      rebote: _reboteId == p.id,
                      alTocar: () {
                        final grupos = gruposDeJson(p.gruposJson);
                        if (grupos.isEmpty) {
                          _sumar(p, const [], 1);
                        } else {
                          _elegirVariantes(p, grupos);
                        }
                      },
                    );
                  },
                ),
        ),
      ]),

      // Barra de canasta
      bottomSheet: cantidadCanasta == 0
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0x001A111B), C.ciruela900],
                  stops: [0, 0.4],
                ),
              ),
              child: SafeArea(
                child: Row(children: [
                  Boton(
                    '$cantidadCanasta',
                    icono: LucideIcons.shoppingCart,
                    tono: TonoBoton.fantasma,
                    alTocar: _verCanasta,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Boton(
                      '${widget.textoConfirmar} · ${dinero(totalCanasta)}',
                      alto: 52,
                      alTocar: () => Navigator.pop(context, List.of(_canasta)),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }

  // ---------- Hoja de variantes (opciones anidadas, regla 5) ----------
  Future<void> _elegirVariantes(Producto producto, List<GrupoVariante> grupos) async {
    final resultado = await mostrarHoja<(List<SeleccionVariante>, int)>(
      context,
      constructor: (ctx) => _HojaVariantes(producto: producto, grupos: grupos),
    );
    if (resultado != null) _sumar(producto, resultado.$1, resultado.$2);
  }

  // ---------- Hoja de canasta (revisar/ajustar) ----------
  Future<void> _verCanasta() async {
    await mostrarHoja(context, constructor: (ctx) => StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const TituloHoja('Por agregar'),
              if (_canasta.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Canasta vacía', textAlign: TextAlign.center,
                      style: TextStyle(color: C.crema38)),
                ),
              for (var i = 0; i < _canasta.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_canasta[i].producto.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (_canasta[i].variantes.isNotEmpty)
                          Text(etiquetaVariantes(_canasta[i].variantes),
                              style: const TextStyle(fontSize: 13, color: C.crema60)),
                        Text('${dinero(_canasta[i].unitario)} c/u',
                            style: estiloMono(tamano: 12, color: C.crema38)),
                      ]),
                    ),
                    Stepper2(
                      valor: _canasta[i].cantidad,
                      minimo: 0,
                      alCambiar: (v) {
                        setState(() {
                          if (v <= 0) {
                            _canasta.removeAt(i);
                          } else {
                            _canasta[i] = LineaNueva(
                              producto: _canasta[i].producto,
                              variantes: _canasta[i].variantes,
                              cantidad: v,
                            );
                          }
                        });
                        setSheet(() {});
                      },
                    ),
                  ]),
                ),
            ],
          ),
        ));
    setState(() {});
  }
}

class _ChipNav extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback alTocar;
  const _ChipNav({required this.texto, this.icono, required this.alTocar});

  @override
  Widget build(BuildContext context) => Material(
        color: C.crema07,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: alTocar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: C.crema12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icono != null) Icon(icono, size: 14, color: C.crema60),
              Text(texto, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: C.crema60,
              )),
            ]),
          ),
        ),
      );
}

class _TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final int enCanasta;
  final bool rebote;
  final VoidCallback alTocar;

  const _TarjetaProducto({
    required this.producto,
    required this.enCanasta,
    required this.rebote,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final tieneOpciones = producto.gruposJson.length > 2;
    return AnimatedScale(
      scale: rebote ? 1.05 : 1,
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOut,
      child: Stack(clipBehavior: Clip.none, children: [
        Tarjeta(
          alTocar: alTocar,
          relleno: const EdgeInsets.all(13),
          borde: enCanasta > 0 ? C.ambar : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15, height: 1.25,
                  )),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  dinero(producto.precio) + (tieneOpciones ? ' +' : ''),
                  style: estiloMono(tamano: 13, color: C.crema60),
                ),
                if (tieneOpciones)
                  const Text('opciones', style: TextStyle(fontSize: 12, color: C.crema38)),
              ]),
            ],
          ),
        ),
        if (enCanasta > 0)
          Positioned(
            top: -7, right: -7,
            child: TweenAnimationBuilder(
              key: ValueKey(enCanasta),
              tween: Tween<double>(begin: 1.35, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              builder: (_, escala, hijo) => Transform.scale(scale: escala, child: hijo),
              child: Container(
                constraints: const BoxConstraints(minWidth: 26),
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: const BoxDecoration(
                  color: C.ambar, borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
                alignment: Alignment.center,
                child: Text('$enCanasta', style: estiloMono(
                  tamano: 13, peso: FontWeight.w700, color: C.ambarTinta,
                )),
              ),
            ),
          ),
      ]),
    );
  }
}

// Hoja de selección de variantes: recorre cada grupo; dentro de un grupo las
// opciones pueden anidarse (ej. Base > Cerveza > Corona) y cada nivel puede
// sumar precio extra.
class _HojaVariantes extends StatefulWidget {
  final Producto producto;
  final List<GrupoVariante> grupos;
  const _HojaVariantes({required this.producto, required this.grupos});

  @override
  State<_HojaVariantes> createState() => _HojaVariantesState();
}

class _HojaVariantesState extends State<_HojaVariantes> {
  final Map<String, List<OpcionVariante>> _caminos = {};
  int _cantidad = 1;

  bool _completo(GrupoVariante g) {
    final camino = _caminos[g.id] ?? const [];
    if (camino.isEmpty) return false;
    return camino.last.hijas.isEmpty;
  }

  List<SeleccionVariante> get _selecciones => [
        for (final g in widget.grupos)
          SeleccionVariante(
            grupo: g.nombre,
            camino: (_caminos[g.id] ?? const []).map((o) => o.nombre).toList(),
            delta: redondear((_caminos[g.id] ?? const [])
                .fold(0.0, (s, o) => s + o.delta)),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final todoCompleto = widget.grupos.every(_completo);
    final unitario = todoCompleto
        ? precioUnitario(widget.producto, _selecciones)
        : widget.producto.precio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TituloHoja(widget.producto.nombre),
        Text(dinero(unitario), style: estiloMono(tamano: 14, color: C.crema60)),
        const SizedBox(height: 14),

        for (final grupo in widget.grupos) ...[
          EtiquetaCampo(grupo.nombre),
          // Camino elegido (chips ámbar; tocar retrocede a ese nivel)
          if ((_caminos[grupo.id] ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < _caminos[grupo.id]!.length; i++)
                  GestureDetector(
                    onTap: () => setState(() =>
                        _caminos[grupo.id] = _caminos[grupo.id]!.sublist(0, i)),
                    child: ChipEstado.ambar(
                      _caminos[grupo.id]![i].nombre +
                          (_caminos[grupo.id]![i].delta > 0
                              ? ' +${dinero(_caminos[grupo.id]![i].delta).substring(1)}'
                              : '') + '  ✕',
                    ),
                  ),
              ]),
            ),
          if (!_completo(grupo))
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final op in ((_caminos[grupo.id] ?? const []).isEmpty
                  ? grupo.opciones
                  : _caminos[grupo.id]!.last.hijas))
                Material(
                  color: C.ciruela600,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _caminos[grupo.id] =
                        [...(_caminos[grupo.id] ?? const []), op]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      constraints: const BoxConstraints(minWidth: 100),
                      child: Column(children: [
                        Text(op.nombre, style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.5,
                        )),
                        if (op.delta > 0)
                          Text('+${dinero(op.delta).substring(1)}',
                              style: estiloMono(tamano: 12, color: C.ambar)),
                        if (op.hijas.isNotEmpty)
                          const Text('elegir…',
                              style: TextStyle(fontSize: 12, color: C.crema38)),
                      ]),
                    ),
                  ),
                ),
            ]),
          const SizedBox(height: 14),
        ],

        Center(child: Stepper2(valor: _cantidad, alCambiar: (v) => setState(() => _cantidad = v))),
        const SizedBox(height: 16),
        Boton(
          'Agregar${_cantidad > 1 ? ' $_cantidad' : ''} · ${dinero(redondear(unitario * _cantidad))}',
          expandir: true,
          alTocar: todoCompleto
              ? () => Navigator.pop(context, (_selecciones, _cantidad))
              : null,
        ),
      ],
    );
  }
}
