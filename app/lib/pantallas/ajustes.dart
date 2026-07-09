// Ajustes (secciones 3.9 y 3.11): nombre del negocio, alerta global de
// pedidos, y el corazón del multi-local — exportar/importar SOLO la
// configuración (nunca datos operativos de un turno, regla 15).

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/proveedores.dart';
import '../logica/configuracion.dart';
import '../tema/tema.dart';
import '../widgets/hoja.dart';

class PantallaAjustes extends ConsumerStatefulWidget {
  const PantallaAjustes({super.key});

  @override
  ConsumerState<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends ConsumerState<PantallaAjustes> {
  final _nombreCtrl = TextEditingController();
  final _minutosCtrl = TextEditingController();
  bool _cargado = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _minutosCtrl.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: C.ciruela600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _exportar({required bool compartir}) async {
    final db = ref.read(baseDatos);
    final config = await exportarConfiguracion(db);
    final json = const JsonEncoder.withIndent('  ').convert(config);
    final nombre = 'antidescuadre-config-${DateTime.now().toIso8601String().substring(0, 10)}.json';
    final dir = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(dir.path, nombre));
    await archivo.writeAsString(json);

    if (compartir) {
      await SharePlus.instance.share(ShareParams(
        files: [XFile(archivo.path)],
        subject: 'Configuración AntiDescuadre',
      ));
    } else {
      // Guardar en una ubicación elegida por el usuario
      final destino = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar configuración',
        fileName: nombre,
        bytes: Uint8List.fromList(utf8.encode(json)),
      );
      if (destino != null && mounted) _aviso('Configuración exportada');
    }
  }

  Future<void> _importar() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (resultado == null || resultado.files.isEmpty) return;
    try {
      final bytes = resultado.files.first.bytes;
      final texto = bytes != null
          ? utf8.decode(bytes)
          : await File(resultado.files.first.path!).readAsString();
      final config = validarConfiguracion(jsonDecode(texto));
      if (config == null) {
        if (mounted) _aviso('El archivo no es una configuración válida');
        return;
      }
      if (!mounted) return;
      final ok = await confirmar(
        context,
        titulo: '¿Importar esta configuración?',
        detalle:
            '«${config['nombreNegocio']}» · ${(config['productos'] as List).length} productos, '
            '${(config['categorias'] as List).length} categorías, '
            '${(config['mesas'] as List).length} mesas. Reemplaza tu catálogo y mesas '
            'actuales; las ventas y turnos no se tocan.',
        textoConfirmar: 'Importar y reemplazar',
        peligro: true,
      );
      if (!ok) return;
      await importarConfiguracion(ref.read(baseDatos), config);
      if (mounted) {
        setState(() {
          _nombreCtrl.text = config['nombreNegocio'] as String? ?? 'Mi bar';
          _minutosCtrl.text = '${config['alertaMinutos'] ?? 10}';
        });
        _aviso('Configuración importada');
      }
    } catch (_) {
      if (mounted) _aviso('No se pudo leer el archivo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = ref.watch(ajustesProv).value;
    if (ajustes != null && !_cargado) {
      _cargado = true;
      _nombreCtrl.text = ajustes.nombreNegocio;
      _minutosCtrl.text = '${ajustes.alertaMinutos}';
    }
    final db = ref.read(baseDatos);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.ciruela800,
        centerTitle: true,
        title: const Text('Ajustes', style: TextStyle(
          fontFamily: F.display, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Tarjeta(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const EtiquetaCampo('Nombre del negocio'),
              TextField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Mi bar'),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) db.guardarAjustes(nombreNegocio: v.trim());
                },
                onTapOutside: (_) {
                  final v = _nombreCtrl.text.trim();
                  if (v.isNotEmpty) db.guardarAjustes(nombreNegocio: v);
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 14),
              const EtiquetaCampo('Alerta de pedidos sin entregar (minutos)'),
              TextField(
                controller: _minutosCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: estiloMono(),
                onSubmitted: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n > 0) db.guardarAjustes(alertaMinutos: n);
                },
                onTapOutside: (_) {
                  final n = int.tryParse(_minutosCtrl.text);
                  if (n != null && n > 0) db.guardarAjustes(alertaMinutos: n);
                  FocusScope.of(context).unfocus();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 2),
                child: Text(
                  'Un solo valor global: pasado ese tiempo, el pedido se resalta en «Por entregar».',
                  style: TextStyle(fontSize: 13, color: C.crema38),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          Tarjeta(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Configuración portátil',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text(
                'Exporta el catálogo, categorías, variantes, precios, alias de mesas y '
                'ajustes para replicarlos en otro dispositivo. No incluye ventas, '
                'turnos ni comprobantes.',
                style: TextStyle(fontSize: 14, color: C.crema60),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Boton('Exportar', icono: LucideIcons.download,
                    tono: TonoBoton.fantasma, alTocar: () => _exportar(compartir: false))),
                const SizedBox(width: 10),
                Expanded(child: Boton('Compartir', icono: LucideIcons.share2,
                    tono: TonoBoton.fantasma, alTocar: () => _exportar(compartir: true))),
              ]),
              const SizedBox(height: 10),
              Boton('Importar configuración', icono: LucideIcons.fileUp,
                  expandir: true, alTocar: _importar),
            ]),
          ),
          const SizedBox(height: 16),
          const Text(
            'AntiDescuadre · uso individual y offline · tus datos viven solo en este dispositivo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: C.crema38),
          ),
        ],
      ),
    );
  }
}
