// Vibración de confirmación centralizada: un solo interruptor en Ajustes
// (regla de personalización) gatea toda la háptica de la app. Mismo patrón
// estático que Notificaciones._lista — se sincroniza una vez desde la raíz.

import 'package:flutter/services.dart';

abstract final class Haptico {
  static bool activo = true;

  static void ligero() {
    if (activo) HapticFeedback.lightImpact();
  }

  static void medio() {
    if (activo) HapticFeedback.mediumImpact();
  }

  static void seleccion() {
    if (activo) HapticFeedback.selectionClick();
  }
}
