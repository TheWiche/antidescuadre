// Almacenamiento de fotos de comprobantes: el archivo dentro de la app es la
// fuente de verdad; además se intenta guardar una copia en el álbum
// "AntiDescuadre" de la galería del dispositivo (sección 3.6). Si la galería
// falla (permiso negado, etc.) el flujo no se rompe.

import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Fotos {
  static Future<String> guardarComprobante(Uint8List bytesJpeg) async {
    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(docs.path, 'comprobantes'));
    if (!carpeta.existsSync()) carpeta.createSync(recursive: true);
    final ruta = p.join(
      carpeta.path,
      'comprobante-${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(ruta).writeAsBytes(bytesJpeg);

    // Copia en la galería, en el álbum de la app (best-effort)
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        await Gal.requestAccess(toAlbum: true);
      }
      await Gal.putImage(ruta, album: 'AntiDescuadre');
    } catch (_) {/* la base de la app conserva la foto */}

    return ruta;
  }
}
