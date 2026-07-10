// Notificación Android verdaderamente persistente mientras existan
// comprobantes pendientes de legalizar (regla 9). `ongoing:true` en una
// notificación normal NO garantiza que no se pueda deslizar fuera de la
// bandeja — esa garantía real en Android solo la da una notificación ligada
// a un foreground service: mientras el servicio corre, el sistema no deja
// que el usuario la descarte. Se inicia al pasar de 0 a >0 pendientes y se
// detiene (la notificación desaparece) al volver a 0.

import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// El handler real no necesita hacer nada: todo el trabajo (contar
// pendientes, decidir cuándo arrancar/detener) ya vive en el isolate
// principal vía Riverpod. Este handler solo mantiene vivo el servicio.
@pragma('vm:entry-point')
void iniciarHandlerNotificacion() {
  FlutterForegroundTask.setTaskHandler(_HandlerVacio());
}

class _HandlerVacio extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

abstract final class Notificaciones {
  static bool _listo = false;
  static bool _corriendo = false;

  static Future<void> iniciar() async {
    if (!Platform.isAndroid) return;
    try {
      FlutterForegroundTask.initCommunicationPort();
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'legalizacion',
          channelName: 'Comprobantes por legalizar',
          channelDescription:
              'Aviso persistente mientras haya transferencias sin legalizar',
          channelImportance: NotificationChannelImportance.HIGH,
          priority: NotificationPriority.HIGH,
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          autoRunOnBoot: false,
          allowWakeLock: false,
          allowWifiLock: false,
        ),
      );
      final permiso = await FlutterForegroundTask.checkNotificationPermission();
      if (permiso != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
      _listo = true;
    } catch (_) {
      _listo = false; // sin permiso: la cinta interna sigue avisando
    }
  }

  static Future<void> actualizarPendientes(int cantidad) async {
    if (!_listo) return;
    try {
      if (cantidad <= 0) {
        if (_corriendo) {
          await FlutterForegroundTask.stopService();
          _corriendo = false;
        }
        return;
      }
      final texto = cantidad == 1
          ? 'Hay 1 comprobante pendiente de legalizar en barra.'
          : 'Hay $cantidad comprobantes pendientes de legalizar en barra.';
      if (_corriendo) {
        await FlutterForegroundTask.updateService(
          notificationTitle: 'Transferencias por legalizar',
          notificationText: texto,
        );
      } else {
        await FlutterForegroundTask.startService(
          serviceId: 1,
          serviceTypes: const [ForegroundServiceTypes.dataSync],
          notificationTitle: 'Transferencias por legalizar',
          notificationText: texto,
          callback: iniciarHandlerNotificacion,
        );
        _corriendo = true;
      }
    } catch (_) {/* best-effort */}
  }
}
