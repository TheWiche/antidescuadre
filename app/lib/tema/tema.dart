// Sistema de diseño "Medianoche Joya" — azul-negro profundo con ámbar dorado
// (efectivo/acción), zafiro (transferencias), esmeralda (entregado/pagado),
// rubí (alerta) y un papel de ticket en crema cálido como elemento firma.

import 'package:flutter/material.dart';

abstract final class C {
  static const base900 = Color(0xFF090D16); // hundido: campos, barra nav, gradientes
  static const base800 = Color(0xFF0D1220); // fondo base de la app
  static const base700 = Color(0xFF161D2E); // tarjetas
  static const base600 = Color(0xFF1E2740); // elevado / variantes anidadas
  static const crema = Color(0xFFECEEF4);
  static const crema60 = Color(0x99ECEEF4);
  static const crema38 = Color(0x61ECEEF4);
  static const crema12 = Color(0x1FECEEF4);
  static const crema07 = Color(0x12ECEEF4);
  static const ambar = Color(0xFFE8B34D);
  static const ambarSuave = Color(0x29E8B34D);
  static const ambarTinta = Color(0xFF2B1D06);
  static const cian = Color(0xFF5B93E0);
  static const cianSuave = Color(0x265B93E0);
  static const cianTinta = Color(0xFF0D1A33);
  static const menta = Color(0xFF4CBE86);
  static const mentaSuave = Color(0x264CBE86);
  static const mentaTinta = Color(0xFF07241A);
  static const rojo = Color(0xFFEB5E5E);
  static const rojoSuave = Color(0x29EB5E5E);

  // Papel del ticket (elemento firma)
  static const papel = Color(0xFFF6EFE1);
  static const papelTinta = Color(0xFF22233A);
  static const papelTintaSuave = Color(0x8C22233A);
  static const tintaExito = Color(0xFF1F6B4E);
  static const tintaAlerta = Color(0xFFA6511F);
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
    surface: C.base700,
    onSurface: C.crema,
    surfaceContainerHighest: C.base600,
    error: C.rojo,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: C.base800,
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
      fillColor: C.base900,
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
      backgroundColor: C.base700,
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

// ---------- Envoltorio táctil: escala sutil al presionar ----------
// Usa Listener (no compite en la arena de gestos) para no robarle el toque
// al widget real que maneja el tap — solo observa para animar la presión.
class _Presionable extends StatefulWidget {
  final Widget child;
  final bool activo;
  const _Presionable({required this.child, required this.activo});

  @override
  State<_Presionable> createState() => _PresionableState();
}

class _PresionableState extends State<_Presionable> {
  bool _presionado = false;

  void _set(bool v) {
    if (!widget.activo) return;
    if (_presionado != v) setState(() => _presionado = v);
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: AnimatedScale(
          scale: _presionado ? 0.96 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
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
      TonoBoton.peligro => (C.rojoSuave, C.rojo, const Color(0x4DEB5E5E)),
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
    final envuelto = _Presionable(activo: alTocar != null, child: boton);
    return expandir ? SizedBox(width: double.infinity, child: envuelto) : envuelto;
  }
}

// ---------- Tarjeta de la casa ----------
class Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry relleno;
  final Color? fondo;
  final Color? borde;
  final VoidCallback? alTocar;
  final VoidCallback? alPresionarLargo;
  final bool sombra;

  const Tarjeta({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.all(16),
    this.fondo,
    this.borde,
    this.alTocar,
    this.alPresionarLargo,
    this.sombra = true,
  });

  @override
  Widget build(BuildContext context) {
    final caja = Container(
      padding: relleno,
      decoration: BoxDecoration(
        color: fondo ?? C.base700,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borde ?? C.crema07),
        boxShadow: sombra
            ? [
                BoxShadow(
                  color: C.base900.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (alTocar == null && alPresionarLargo == null) return caja;
    return _Presionable(
      activo: alTocar != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: alTocar,
          onLongPress: alPresionarLargo,
          borderRadius: BorderRadius.circular(20),
          child: caja,
        ),
      ),
    );
  }
}
