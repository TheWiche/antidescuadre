// Sistema de diseño "La comanda de la casa" — el mismo lenguaje de la marca:
// ciruela de medianoche, ámbar cerveza (efectivo/acción), cian eléctrico
// (transferencias), menta (entregado/pagado), crema (texto), rojo (alerta).

import 'package:flutter/material.dart';

abstract final class C {
  static const ciruela900 = Color(0xFF1A111B);
  static const ciruela800 = Color(0xFF221723);
  static const ciruela700 = Color(0xFF2F2130);
  static const ciruela600 = Color(0xFF3D2C3E);
  static const crema = Color(0xFFF7EFE3);
  static const crema60 = Color(0x99F7EFE3);
  static const crema38 = Color(0x61F7EFE3);
  static const crema12 = Color(0x1FF7EFE3);
  static const crema07 = Color(0x12F7EFE3);
  static const ambar = Color(0xFFF6A83C);
  static const ambarSuave = Color(0x29F6A83C);
  static const ambarTinta = Color(0xFF3A2A14);
  static const cian = Color(0xFF56C8E8);
  static const cianSuave = Color(0x2656C8E8);
  static const cianTinta = Color(0xFF0E2A33);
  static const menta = Color(0xFF6FCF97);
  static const mentaSuave = Color(0x266FCF97);
  static const mentaTinta = Color(0xFF0F2A1C);
  static const rojo = Color(0xFFFF6B6B);
  static const rojoSuave = Color(0x29FF6B6B);

  // Papel del ticket
  static const papel = Color(0xFFF7EFE3);
  static const papelTinta = Color(0xFF2B1E2C);
  static const papelTintaSuave = Color(0x8C2B1E2C);
  static const tintaExito = Color(0xFF2E7D54);
  static const tintaAlerta = Color(0xFFB3541E);
}

abstract final class F {
  static const display = 'Bricolage';
  static const texto = 'Instrument';
  static const mono = 'SplineMono';
}

TextStyle estiloMono({
  double tamano = 14,
  FontWeight peso = FontWeight.w400,
  Color color = C.crema,
}) =>
    TextStyle(
      fontFamily: F.mono,
      fontSize: tamano,
      fontWeight: peso,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

ThemeData temaAntiDescuadre() {
  const esquema = ColorScheme.dark(
    primary: C.ambar,
    onPrimary: C.ambarTinta,
    secondary: C.cian,
    onSecondary: C.cianTinta,
    surface: C.ciruela800,
    onSurface: C.crema,
    surfaceContainerHighest: C.ciruela700,
    error: C.rojo,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: C.ciruela800,
    fontFamily: F.texto,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      // Títulos con carácter (display)
      headlineLarge: TextStyle(
        fontFamily: F.display, fontSize: 26, fontWeight: FontWeight.w700, color: C.crema,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: F.display, fontSize: 21, fontWeight: FontWeight.w700, color: C.crema,
      ),
      titleMedium: TextStyle(
        fontFamily: F.display, fontSize: 17, fontWeight: FontWeight.w700, color: C.crema,
      ),
      bodyMedium: TextStyle(fontSize: 15.5, color: C.crema, height: 1.4),
      bodySmall: TextStyle(fontSize: 13, color: C.crema60),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.ciruela900,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      hintStyle: const TextStyle(color: C.crema38),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.crema12, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.ambar, width: 1.5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: C.ciruela700,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      dragHandleColor: C.crema12,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}

// ---------- Etiqueta de campo (mayúsculas pequeñas) ----------
class EtiquetaCampo extends StatelessWidget {
  final String texto;
  final Color color;
  const EtiquetaCampo(this.texto, {super.key, this.color = C.crema60});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Text(
          texto.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
      );
}

// ---------- Chip de estado ----------
class ChipEstado extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color color;
  final IconData? icono;
  final bool mono;

  const ChipEstado(
    this.texto, {
    super.key,
    required this.fondo,
    required this.color,
    this.icono,
    this.mono = false,
  });

  const ChipEstado.ambar(this.texto, {super.key, this.icono, this.mono = false})
      : fondo = C.ambarSuave, color = C.ambar;
  const ChipEstado.cian(this.texto, {super.key, this.icono, this.mono = false})
      : fondo = C.cianSuave, color = C.cian;
  const ChipEstado.menta(this.texto, {super.key, this.icono, this.mono = false})
      : fondo = C.mentaSuave, color = C.menta;
  const ChipEstado.rojo(this.texto, {super.key, this.icono, this.mono = false})
      : fondo = C.rojoSuave, color = C.rojo;
  const ChipEstado.neutro(this.texto, {super.key, this.icono, this.mono = false})
      : fondo = C.crema07, color = C.crema60;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icono != null) ...[Icon(icono, size: 14, color: color), const SizedBox(width: 5)],
          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: mono ? F.mono : null,
            ),
          ),
        ]),
      );
}

// ---------- Botones de la casa ----------
enum TonoBoton { ambar, cian, menta, fantasma, peligro }

class Boton extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final TonoBoton tono;
  final VoidCallback? alTocar;
  final bool expandir;
  final double alto;
  final Widget? contenidoExtra;

  const Boton(
    this.texto, {
    super.key,
    this.icono,
    this.tono = TonoBoton.ambar,
    this.alTocar,
    this.expandir = false,
    this.alto = 50,
    this.contenidoExtra,
  });

  @override
  Widget build(BuildContext context) {
    final (fondo, color, borde) = switch (tono) {
      TonoBoton.ambar => (C.ambar, C.ambarTinta, null),
      TonoBoton.cian => (C.cian, C.cianTinta, null),
      TonoBoton.menta => (C.menta, C.mentaTinta, null),
      TonoBoton.fantasma => (C.crema07, C.crema, C.crema12),
      TonoBoton.peligro => (C.rojoSuave, C.rojo, const Color(0x4DFF6B6B)),
    };
    final boton = FilledButton(
      onPressed: alTocar,
      style: FilledButton.styleFrom(
        backgroundColor: fondo,
        foregroundColor: color,
        disabledBackgroundColor: fondo.withValues(alpha: 0.35),
        disabledForegroundColor: color.withValues(alpha: 0.5),
        minimumSize: Size(0, alto),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: borde != null ? BorderSide(color: borde) : BorderSide.none,
        ),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, fontFamily: F.texto,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icono != null) ...[Icon(icono, size: 19), const SizedBox(width: 8)],
          Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
          if (contenidoExtra != null) ...[const SizedBox(width: 6), contenidoExtra!],
        ],
      ),
    );
    return expandir ? SizedBox(width: double.infinity, child: boton) : boton;
  }
}

// ---------- Tarjeta de la casa ----------
class Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry relleno;
  final Color? fondo;
  final Color? borde;
  final VoidCallback? alTocar;

  const Tarjeta({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.all(16),
    this.fondo,
    this.borde,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final caja = Container(
      padding: relleno,
      decoration: BoxDecoration(
        color: fondo ?? C.ciruela700,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borde ?? C.crema07),
      ),
      child: child,
    );
    if (alTocar == null) return caja;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(18),
        child: caja,
      ),
    );
  }
}
