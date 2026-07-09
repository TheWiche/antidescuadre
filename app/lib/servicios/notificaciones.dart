// Notificación Android persistente y no descartable mientras existan
// comprobantes pendientes de legalizar (regla 9). Complementa la cinta
// visible dentro de la app; si el sistema niega el permiso, la cinta
// interna sigue cumpliendo la regla.

import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificaciones {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _lista = false;

  static Future<void> iniciar() async {
    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _lista = true;
    } catch (_) {
      _lista = false; // sin permiso: la cinta interna sigue avisando
    }
  }

  static Future<void> actualizarPendientes(int cantidad) async {
    if (!_lista) return;
    try {
      if (cantidad <= 0) {
        await _plugin.cancel(1);
        return;
      }
      await _plugin.show(
        1,
        'Transferencias por legalizar',
        cantidad == 1
            ? 'Hay 1 comprobante pendiente de legalizar en barra.'
            : 'Hay $cantidad comprobantes pendientes de legalizar en barra.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'legalizacion',
            'Comprobantes por legalizar',
            channelDescription:
                'Aviso obligatorio mientras haya transferencias sin legalizar',
            importance: Importance.high,
            priority: Priority.high,
            ongoing: true, // no descartable
            autoCancel: false,
            onlyAlertOnce: true,
            color: Color(0xFF56C8E8),
          ),
        ),
      );
    } catch (_) {/* best-effort */}
  }
}
