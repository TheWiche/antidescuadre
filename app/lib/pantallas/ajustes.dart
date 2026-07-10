// Ajustes (secciones 3.9 y 3.11): personalización del negocio (nombre,
// moneda, formato de hora, vibración, alerta de pedidos, recordatorio de
// respaldo) y el corazón del multi-local — exportar/importar SOLO la
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
  final _monedaCtrl = TextEditingController();
  bool _cargado = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _minutosCtrl.dispose();
    _monedaCtrl.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: C.base600,
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

    var exportado = false;
    if (compartir) {
      final r = await SharePlus.instance.share(ShareParams(
        files: [XFile(archivo.path)],
        subject: 'Configuración AntiDescuadre',
      ));
      exportado = r.status != ShareResultStatus.dismissed;
    } else {
      // Guardar en una ubicación elegida por el usuario
      final destino = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar configuración',
        fileName: nombre,
        bytes: Uint8List.fromList(utf8.encode(json)),
      );
      exportado = destino != null;
      if (exportado && mounted) _aviso('Configuración exportada');
    }
    if (exportado) {
      // Alimenta el recordatorio de respaldo del dashboard
      await db.guardarAjustes(ultimaExportacion: DateTime.now());
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
        textoConfirmar: 'Importar',
        peligro: true,
      );
      if (!ok) return;
      await importarConfiguracion(ref.read(baseDatos), config);
      if (mounted) {
        setState(() => _cargado = false); // recargar campos desde la base
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
      _monedaCtrl.text = ajustes.simboloMoneda;
    }
    final db = ref.read(baseDatos);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: C.base800,
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
          // ---------- Negocio ----------
          Tarjeta(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Negocio', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
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
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const EtiquetaCampo('Símbolo de moneda'),
                    TextField(
                      controller: _monedaCtrl,
                      maxLength: 5,
                      decoration: const InputDecoration(
                        hintText: '\$', counterText: '',
                      ),
                      onSubmitted: (v) {
                        if (v.trim().isNotEmpty) db.guardarAjustes(simboloMoneda: v.trim());
                      },
                      onTapOutside: (_) {
                        final v = _monedaCtrl.text.trim();
                        if (v.isNotEmpty) db.guardarAjustes(simboloMoneda: v);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 2),
                      child: Text('ej. \$, S/., Bs., €',
                          style: TextStyle(fontSize: 12, color: C.crema38)),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const EtiquetaCampo('Alerta de pedidos (min)'),
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
                      padding: EdgeInsets.only(top: 4, left: 2),
                      child: Text('resalta en «Por entregar»',
                          style: TextStyle(fontSize: 12, color: C.crema38)),
                    ),
                  ]),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // ---------- Preferencias ----------
          Tarjeta(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Preferencias', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              _FilaSwitch(
                titulo: 'Hora en formato 24 h',
                detalle: (ajustes?.formato24h ?? false) ? '18:30' : '6:30 p. m.',
                valor: ajustes?.formato24h ?? false,
                alCambiar: (v) => db.guardarAjustes(formato24h: v),
              ),
              _FilaSwitch(
                titulo: 'Vibrar al confirmar acciones',
                detalle: 'Cobros, entregas, legalizaciones…',
                valor: ajustes?.vibracionActiva ?? true,
                alCambiar: (v) => db.guardarAjustes(vibracionActiva: v),
              ),
              const SizedBox(height: 10),
              const EtiquetaCampo('Recordar exportar un respaldo'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (dias, texto) in const [
                  (0, 'Nunca'), (7, 'Cada 7 días'), (15, 'Cada 15 días'), (30, 'Cada 30 días'),
                ])
                  GestureDetector(
                    onTap: () => db.guardarAjustes(recordatorioBackupDias: dias),
                    child: (ajustes?.recordatorioBackupDias ?? 0) == dias
                        ? ChipEstado.ambar(texto)
                        : ChipEstado.neutro(texto),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // ---------- Configuración portátil ----------
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

class _FilaSwitch extends StatelessWidget {
  final String titulo;
  final String detalle;
  final bool valor;
  final ValueChanged<bool> alCambiar;
  const _FilaSwitch({
    required this.titulo,
    required this.detalle,
    required this.valor,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => alCambiar(!valor),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(detalle, style: const TextStyle(fontSize: 13, color: C.crema38)),
              ]),
            ),
            Switch(
              value: valor,
              activeThumbColor: C.crema,
              activeTrackColor: C.menta,
              onChanged: alCambiar,
            ),
          ]),
        ),
      );
}
