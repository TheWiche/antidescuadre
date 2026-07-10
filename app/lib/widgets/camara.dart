// Cámara de comprobantes (sección 3.6): vista en vivo, capturar, rotar en
// pasos de 90°, repetir la toma y confirmar. Devuelve los bytes JPEG.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../servicios/haptico.dart';
import '../tema/tema.dart';

class PantallaCamara extends StatefulWidget {
  final String titulo;
  const PantallaCamara({super.key, required this.titulo});

  static Future<Uint8List?> abrir(BuildContext context, {required String titulo}) =>
      Navigator.of(context).push<Uint8List>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PantallaCamara(titulo: titulo),
      ));

  @override
  State<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends State<PantallaCamara> {
  CameraController? _controlador;
  String? _error;
  Uint8List? _captura; // bytes originales de la toma
  int _rotacion = 0; // grados en pasos de 90
  Uint8List? _previa; // captura con la rotación aplicada
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _iniciarCamara();
  }

  Future<void> _iniciarCamara() async {
    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) {
        setState(() => _error = 'Este dispositivo no tiene cámara disponible.');
        return;
      }
      final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );
      final controlador = CameraController(
        trasera, ResolutionPreset.high,
        enableAudio: false,
      );
      await controlador.initialize();
      if (!mounted) {
        await controlador.dispose();
        return;
      }
      setState(() => _controlador = controlador);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Sin acceso a la cámara. Revisa el permiso en Ajustes del sistema.');
      }
    }
  }

  @override
  void dispose() {
    _controlador?.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    final c = _controlador;
    if (c == null || !c.value.isInitialized || _procesando) return;
    setState(() => _procesando = true);
    try {
      final archivo = await c.takePicture();
      final bytes = await archivo.readAsBytes();
      Haptico.medio();
      setState(() {
        _captura = bytes;
        _rotacion = 0;
        _previa = bytes;
      });
    } catch (_) {/* se queda en vista previa */} finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _rotar() async {
    if (_captura == null || _procesando) return;
    setState(() {
      _procesando = true;
      _rotacion = (_rotacion + 90) % 360;
    });
    final bytes = _captura!;
    final grados = _rotacion;
    final rotada = await _aplicarRotacion(bytes, grados);
    if (mounted) {
      setState(() {
        _previa = rotada;
        _procesando = false;
      });
    }
  }

  static Future<Uint8List> _aplicarRotacion(Uint8List bytes, int grados) async {
    if (grados % 360 == 0) return bytes;
    final decodificada = img.decodeImage(bytes);
    if (decodificada == null) return bytes;
    final girada = img.copyRotate(decodificada, angle: grados);
    return Uint8List.fromList(img.encodeJpg(girada, quality: 90));
  }

  @override
  Widget build(BuildContext context) {
    final c = _controlador;
    return Scaffold(
      backgroundColor: C.base900,
      appBar: AppBar(
        backgroundColor: C.base900,
        title: Text(widget.titulo, style: const TextStyle(
          fontFamily: F.display, fontSize: 18, fontWeight: FontWeight.w700,
        )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            width: double.infinity,
            child: _previa != null
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Image.memory(
                      _previa!,
                      key: ValueKey(_rotacion),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(LucideIcons.camera, size: 40, color: C.crema38),
                            const SizedBox(height: 10),
                            Text(_error!, textAlign: TextAlign.center,
                                style: const TextStyle(color: C.crema60)),
                          ]),
                        ),
                      )
                    : c != null && c.value.isInitialized
                        ? CameraPreview(c)
                        : const Center(child: CircularProgressIndicator(color: C.ambar)),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: _captura != null
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Boton('Repetir', icono: LucideIcons.undo2, tono: TonoBoton.fantasma,
                        alTocar: () => setState(() {
                              _captura = null;
                              _previa = null;
                              _rotacion = 0;
                            })),
                    const SizedBox(width: 12),
                    Boton('Rotar', icono: LucideIcons.rotateCw, tono: TonoBoton.fantasma,
                        alTocar: _procesando ? null : _rotar),
                    const SizedBox(width: 12),
                    Boton('Guardar', icono: LucideIcons.check, tono: TonoBoton.cian,
                        alTocar: _procesando
                            ? null
                            : () => Navigator.pop(context, _previa)),
                  ])
                : Center(
                    child: GestureDetector(
                      onTap: _tomarFoto,
                      child: AnimatedScale(
                        scale: _procesando ? 0.85 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: C.crema,
                            border: Border.all(color: C.crema38, width: 5),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}
