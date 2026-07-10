// Modelos de dominio que viven como JSON dentro de la base (variantes)
// y selecciones congeladas en los ítems. Fiel a planificacion-app-cuadre.md
// (sección 3.4): grupos de opciones por producto, con opciones anidadas
// (ej. "Base" > Cerveza > Corona) y ajuste de precio opcional por opción.

import 'dart:convert';

class OpcionVariante {
  final String id;
  final String nombre;
  final double delta; // precio extra respecto al precio base (puede ser 0)
  final List<OpcionVariante> hijas;

  const OpcionVariante({
    required this.id,
    required this.nombre,
    this.delta = 0,
    this.hijas = const [],
  });

  OpcionVariante copiarCon({String? nombre, double? delta, List<OpcionVariante>? hijas}) =>
      OpcionVariante(
        id: id,
        nombre: nombre ?? this.nombre,
        delta: delta ?? this.delta,
        hijas: hijas ?? this.hijas,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'nombre': nombre,
        'delta': delta,
        if (hijas.isNotEmpty) 'hijas': hijas.map((h) => h.aJson()).toList(),
      };

  factory OpcionVariante.deJson(Map<String, dynamic> j) => OpcionVariante(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? '',
        delta: (j['delta'] as num?)?.toDouble() ?? 0,
        hijas: (j['hijas'] as List?)
                ?.map((h) => OpcionVariante.deJson(h as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class GrupoVariante {
  final String id;
  final String nombre; // ej. "Base", "Sabor"
  final List<OpcionVariante> opciones;

  const GrupoVariante({required this.id, required this.nombre, required this.opciones});

  GrupoVariante copiarCon({String? nombre, List<OpcionVariante>? opciones}) =>
      GrupoVariante(id: id, nombre: nombre ?? this.nombre, opciones: opciones ?? this.opciones);

  Map<String, dynamic> aJson() => {
        'id': id,
        'nombre': nombre,
        'opciones': opciones.map((o) => o.aJson()).toList(),
      };

  factory GrupoVariante.deJson(Map<String, dynamic> j) => GrupoVariante(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? '',
        opciones: (j['opciones'] as List?)
                ?.map((o) => OpcionVariante.deJson(o as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

// ¿Alguna opción (o sub-opción anidada, en cualquier grupo) cuesta más que
// la base? Solo en ese caso vale la pena mostrar un "+" junto al precio —
// tener variantes no implica que alguna cueste extra (ej. solo "Sabor").
bool tieneRecargoReal(List<GrupoVariante> grupos) {
  bool enOpciones(List<OpcionVariante> ops) =>
      ops.any((o) => o.delta > 0 || enOpciones(o.hijas));
  return grupos.any((g) => enOpciones(g.opciones));
}

List<GrupoVariante> gruposDeJson(String texto) {
  if (texto.isEmpty) return const [];
  final dato = jsonDecode(texto);
  if (dato is! List) return const [];
  return dato.map((g) => GrupoVariante.deJson(g as Map<String, dynamic>)).toList();
}

String gruposAJson(List<GrupoVariante> grupos) =>
    jsonEncode(grupos.map((g) => g.aJson()).toList());

// Selección hecha al agregar un ítem: por cada grupo, el camino elegido.
class SeleccionVariante {
  final String grupo;
  final List<String> camino; // nombres, ej. ["Cerveza", "Corona"]
  final double delta; // suma de deltas del camino

  const SeleccionVariante({required this.grupo, required this.camino, required this.delta});

  Map<String, dynamic> aJson() => {'grupo': grupo, 'camino': camino, 'delta': delta};

  factory SeleccionVariante.deJson(Map<String, dynamic> j) => SeleccionVariante(
        grupo: j['grupo'] as String? ?? '',
        camino: (j['camino'] as List?)?.map((c) => c as String).toList() ?? const [],
        delta: (j['delta'] as num?)?.toDouble() ?? 0,
      );
}

List<SeleccionVariante> seleccionesDeJson(String texto) {
  if (texto.isEmpty) return const [];
  final dato = jsonDecode(texto);
  if (dato is! List) return const [];
  return dato.map((s) => SeleccionVariante.deJson(s as Map<String, dynamic>)).toList();
}

String seleccionesAJson(List<SeleccionVariante> selecciones) =>
    jsonEncode(selecciones.map((s) => s.aJson()).toList());

String etiquetaVariantes(List<SeleccionVariante> variantes) =>
    variantes.map((v) => v.camino.join(' · ')).join(' · ');
