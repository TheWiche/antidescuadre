// Catálogo (sección 3.4): todo lo arma el propietario — categorías y
// subcategorías sin límite de nivel, productos con variantes anidadas y
// precio extra opcional. Nada viene precargado de fábrica.

import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../datos/base.dart';
import '../datos/modelos.dart';
import '../datos/proveedores.dart';
import '../logica/dinero.dart';
import '../tema/tema.dart';
import '../widgets/comunes.dart';
import '../widgets/hoja.dart';

String _idNuevo() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
    Random().nextInt(9999).toString();

class PantallaCatalogo extends ConsumerStatefulWidget {
  const PantallaCatalogo({super.key});

  @override
  ConsumerState<PantallaCatalogo> createState() => _PantallaCatalogoState();
}

class _PantallaCatalogoState extends ConsumerState<PantallaCatalogo> {
  int? _actual;

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProv).value ?? [];
    final productos = ref.watch(productosProv).value ?? [];

    final rastro = <Categoria>[];
    var c = categorias.where((x) => x.id == _actual).firstOrNull;
    while (c != null) {
      rastro.insert(0, c);
      final padre = c.padreId;
      c = categorias.where((x) => x.id == padre).firstOrNull;
    }
    final subcategorias = categorias.where((x) => x.padreId == _actual).toList();
    final productosAqui = productos.where((p) => p.categoriaId == _actual).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.ciruela800,
        centerTitle: true,
        title: const Text('Catálogo', style: TextStyle(
          fontFamily: F.display, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (_actual != null) {
              setState(() =>
                  _actual = rastro.length > 1 ? rastro[rastro.length - 2].id : null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          // Migas
          Row(children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ChipEstado.ambar(
                  rastro.isEmpty
                      ? 'Todo el catálogo'
                      : rastro.map((x) => x.nombre).join(' › '),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          if (subcategorias.isEmpty && productosAqui.isEmpty)
            Vacio(
              icono: LucideIcons.package,
              titulo: _actual == null ? 'El catálogo está vacío' : 'Categoría vacía',
              detalle: 'Crea categorías y productos con los botones de abajo.',
            ),

          for (final cat in subcategorias) ...[
            Tarjeta(
              relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _actual = cat.id),
                    child: Row(children: [
                      const Icon(LucideIcons.folderOpen, size: 19, color: C.ambar),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Builder(builder: (_) {
                          final nHijas = ref.read(categoriasProv).value
                                  ?.where((x) => x.padreId == cat.id).length ?? 0;
                          final nProd = ref.read(productosProv).value
                                  ?.where((p) => p.categoriaId == cat.id).length ?? 0;
                          return Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.nombre, style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                                Text(
                                  '${nHijas > 0 ? '$nHijas subcategoría${nHijas > 1 ? 's' : ''} · ' : ''}'
                                  '$nProd producto${nProd != 1 ? 's' : ''}',
                                  style: const TextStyle(fontSize: 12.5, color: C.crema38),
                                ),
                              ]);
                        }),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 17, color: C.crema38),
                    ]),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 15, color: C.crema60),
                  onPressed: () => _editarCategoria(cat),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],

          for (final p in productosAqui) ...[
            Opacity(
              opacity: p.activo ? 1 : 0.5,
              child: Tarjeta(
                relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                alTocar: () => _editarProducto(p, rastro),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${p.nombre}${p.activo ? '' : ' · inactivo'}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (gruposDeJson(p.gruposJson).isNotEmpty)
                        Text(
                          gruposDeJson(p.gruposJson).map((g) => g.nombre).join(' · '),
                          style: const TextStyle(fontSize: 12.5, color: C.crema38),
                        ),
                    ]),
                  ),
                  Text(
                    dinero(p.precio) + (gruposDeJson(p.gruposJson).isNotEmpty ? ' +' : ''),
                    style: estiloMono(peso: FontWeight.w700),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Boton('Categoría', icono: LucideIcons.plus,
                tono: TonoBoton.fantasma, alTocar: () => _editarCategoria(null))),
            const SizedBox(width: 10),
            Expanded(child: Boton('Producto', icono: LucideIcons.plus,
                alTocar: () => _editarProducto(null, rastro))),
          ]),
        ],
      ),
    );
  }

  // ---------- Editor de categoría ----------
  Future<void> _editarCategoria(Categoria? cat) async {
    final db = ref.read(baseDatos);
    final controlador = TextEditingController(text: cat?.nombre ?? '');
    final categorias = ref.read(categoriasProv).value ?? [];
    final productos = ref.read(productosProv).value ?? [];
    final bloqueada = cat != null &&
        (categorias.any((x) => x.padreId == cat.id) ||
            productos.any((p) => p.categoriaId == cat.id));

    await mostrarHoja(context, constructor: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TituloHoja(cat == null ? 'Nueva categoría' : 'Editar categoría'),
            const EtiquetaCampo('Nombre'),
            TextField(
              controller: controlador,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'ej. Bebidas, Cervezas, Cócteles…',
              ),
            ),
            const SizedBox(height: 14),
            Boton('Guardar', expandir: true, alTocar: () async {
              final nombre = controlador.text.trim();
              if (nombre.isEmpty) return;
              if (cat == null) {
                await db.into(db.categorias).insert(CategoriasCompanion.insert(
                      nombre: nombre, padreId: Value(_actual),
                    ));
              } else {
                await (db.update(db.categorias)..where((x) => x.id.equals(cat.id)))
                    .write(CategoriasCompanion(nombre: Value(nombre)));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            }),
            if (cat != null) ...[
              const SizedBox(height: 10),
              Boton('Eliminar categoría', icono: LucideIcons.trash2,
                  tono: TonoBoton.peligro, expandir: true,
                  alTocar: bloqueada ? null : () async {
                await (db.delete(db.categorias)..where((x) => x.id.equals(cat.id))).go();
                if (ctx.mounted) Navigator.pop(ctx);
              }),
              if (bloqueada)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Para eliminarla, primero vacíala (subcategorías y productos).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: C.crema38),
                  ),
                ),
            ],
          ],
        ));
  }

  // ---------- Editor de producto (con variantes anidadas) ----------
  Future<void> _editarProducto(Producto? producto, List<Categoria> rastro) async {
    await mostrarHoja(context, constructor: (ctx) => _EditorProducto(
          producto: producto,
          categoriaId: producto?.categoriaId ?? _actual,
          rutaCategoria: rastro.isEmpty
              ? 'Sin categoría'
              : rastro.map((c) => c.nombre).join(' › '),
        ));
  }
}

class _EditorProducto extends ConsumerStatefulWidget {
  final Producto? producto;
  final int? categoriaId;
  final String rutaCategoria;
  const _EditorProducto({
    required this.producto,
    required this.categoriaId,
    required this.rutaCategoria,
  });

  @override
  ConsumerState<_EditorProducto> createState() => _EditorProductoState();
}

class _EditorProductoState extends ConsumerState<_EditorProducto> {
  late final _nombreCtrl = TextEditingController(text: widget.producto?.nombre ?? '');
  late final _precioCtrl =
      TextEditingController(text: widget.producto != null ? '${widget.producto!.precio}' : '');
  late bool _activo = widget.producto?.activo ?? true;
  late final List<GrupoVariante> _grupos =
      widget.producto != null ? gruposDeJson(widget.producto!.gruposJson) : [];

  bool _opcionesValidas(List<OpcionVariante> ops) =>
      ops.isNotEmpty &&
      ops.every((o) =>
          o.nombre.trim().isNotEmpty && (o.hijas.isEmpty || _opcionesValidas(o.hijas)));

  bool get _valido =>
      _nombreCtrl.text.trim().isNotEmpty &&
      _grupos.every((g) => g.nombre.trim().isNotEmpty && _opcionesValidas(g.opciones));

  List<OpcionVariante> _limpiar(List<OpcionVariante> ops) => [
        for (final o in ops)
          OpcionVariante(
            id: o.id,
            nombre: o.nombre.trim(),
            delta: o.delta,
            hijas: _limpiar(o.hijas),
          ),
      ];

  Future<void> _guardar() async {
    final db = ref.read(baseDatos);
    final datos = ProductosCompanion(
      nombre: Value(_nombreCtrl.text.trim()),
      precio: Value(leerMonto(_precioCtrl.text)),
      activo: Value(_activo),
      categoriaId: Value(widget.categoriaId),
      gruposJson: Value(gruposAJson([
        for (final g in _grupos)
          GrupoVariante(id: g.id, nombre: g.nombre.trim(), opciones: _limpiar(g.opciones)),
      ])),
    );
    if (widget.producto == null) {
      await db.into(db.productos).insert(datos);
    } else {
      await (db.update(db.productos)..where((p) => p.id.equals(widget.producto!.id)))
          .write(datos);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TituloHoja(
            widget.producto == null ? 'Nuevo producto' : 'Editar producto',
            sub: widget.rutaCategoria,
          ),
          const EtiquetaCampo('Nombre'),
          TextField(
            controller: _nombreCtrl,
            autofocus: widget.producto == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'ej. Michelada'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          const EtiquetaCampo('Precio base'),
          TextField(
            controller: _precioCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: estiloMono(),
            decoration: const InputDecoration(hintText: '0'),
          ),
          const SizedBox(height: 12),

          Tarjeta(
            relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            alTocar: () => setState(() => _activo = !_activo),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Disponible para la venta',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(
                value: _activo,
                activeThumbColor: C.crema,
                activeTrackColor: C.menta,
                onChanged: (v) => setState(() => _activo = v),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          const EtiquetaCampo('Variantes / opciones'),
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'Ej.: «Base» con Cerveza o Soda, y dentro de cada una sus marcas. El «+» de precio es opcional.',
              style: TextStyle(fontSize: 13, color: C.crema38),
            ),
          ),
          for (var gi = 0; gi < _grupos.length; gi++) ...[
            Tarjeta(
              fondo: C.ciruela600,
              relleno: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _grupos[gi].nombre,
                      decoration: const InputDecoration(
                          hintText: 'Nombre del grupo (ej. Base, Sabor)'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      onChanged: (v) => setState(() =>
                          _grupos[gi] = _grupos[gi].copiarCon(nombre: v)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 17, color: C.rojo),
                    onPressed: () => setState(() => _grupos.removeAt(gi)),
                  ),
                ]),
                const SizedBox(height: 8),
                _EditorOpciones(
                  opciones: _grupos[gi].opciones,
                  nivel: 0,
                  alCambiar: (ops) => setState(() =>
                      _grupos[gi] = _grupos[gi].copiarCon(opciones: ops)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _grupos[gi] = _grupos[gi].copiarCon(
                          opciones: [
                            ..._grupos[gi].opciones,
                            OpcionVariante(id: _idNuevo(), nombre: ''),
                          ],
                        )),
                    icon: const Icon(LucideIcons.plus, size: 14, color: C.crema60),
                    label: const Text('Opción', style: TextStyle(color: C.crema60)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          Boton('Grupo de opciones', icono: LucideIcons.plus, tono: TonoBoton.fantasma,
              expandir: true, alTocar: () => setState(() => _grupos.add(
                    GrupoVariante(id: _idNuevo(), nombre: '', opciones: [
                      OpcionVariante(id: _idNuevo(), nombre: ''),
                    ]),
                  ))),
          const SizedBox(height: 16),

          Boton('Guardar producto', expandir: true, alTocar: _valido ? _guardar : null),
          if (widget.producto != null) ...[
            const SizedBox(height: 10),
            Boton('Eliminar producto', icono: LucideIcons.trash2, tono: TonoBoton.peligro,
                expandir: true, alTocar: () async {
              final db = ref.read(baseDatos);
              await (db.delete(db.productos)
                    ..where((p) => p.id.equals(widget.producto!.id)))
                  .go();
              if (mounted && context.mounted) Navigator.pop(context);
            }),
          ],
        ],
      );
}

// Editor recursivo de opciones: cada opción puede tener sub-opciones.
class _EditorOpciones extends StatelessWidget {
  final List<OpcionVariante> opciones;
  final int nivel;
  final ValueChanged<List<OpcionVariante>> alCambiar;

  const _EditorOpciones({
    required this.opciones,
    required this.nivel,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < opciones.length; i++) ...[
            Padding(
              padding: EdgeInsets.only(left: nivel * 18.0, bottom: 6),
              child: Row(children: [
                if (nivel > 0) ...[
                  const Icon(LucideIcons.cornerDownRight, size: 14, color: C.crema38),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: TextFormField(
                    key: ValueKey('n${opciones[i].id}'),
                    initialValue: opciones[i].nombre,
                    decoration: const InputDecoration(
                      hintText: 'Opción',
                      contentPadding: EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    ),
                    onChanged: (v) => alCambiar([
                      for (var j = 0; j < opciones.length; j++)
                        j == i ? opciones[j].copiarCon(nombre: v) : opciones[j],
                    ]),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 68,
                  child: TextFormField(
                    key: ValueKey('d${opciones[i].id}'),
                    initialValue:
                        opciones[i].delta > 0 ? '${opciones[i].delta}' : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: estiloMono(tamano: 13),
                    decoration: const InputDecoration(
                      hintText: '+0',
                      contentPadding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                    ),
                    onChanged: (v) => alCambiar([
                      for (var j = 0; j < opciones.length; j++)
                        j == i ? opciones[j].copiarCon(delta: leerMonto(v)) : opciones[j],
                    ]),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(LucideIcons.cornerDownRight, size: 15, color: C.crema60),
                  tooltip: 'Agregar sub-opción',
                  onPressed: () => alCambiar([
                    for (var j = 0; j < opciones.length; j++)
                      j == i
                          ? opciones[j].copiarCon(hijas: [
                              ...opciones[j].hijas,
                              OpcionVariante(id: _idNuevo(), nombre: ''),
                            ])
                          : opciones[j],
                  ]),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(LucideIcons.x, size: 15, color: C.rojo),
                  onPressed: () => alCambiar([
                    for (var j = 0; j < opciones.length; j++)
                      if (j != i) opciones[j],
                  ]),
                ),
              ]),
            ),
            if (opciones[i].hijas.isNotEmpty)
              _EditorOpciones(
                opciones: opciones[i].hijas,
                nivel: nivel + 1,
                alCambiar: (hijas) => alCambiar([
                  for (var j = 0; j < opciones.length; j++)
                    j == i ? opciones[j].copiarCon(hijas: hijas) : opciones[j],
                ]),
              ),
          ],
        ],
      );
}
