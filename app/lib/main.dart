import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pantallas/raiz.dart';
import 'servicios/notificaciones.dart';
import 'tema/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await Notificaciones.iniciar();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.base900,
  ));
  runApp(const ProviderScope(child: AppAntiDescuadre()));
}

class AppAntiDescuadre extends StatelessWidget {
  const AppAntiDescuadre({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AntiDescuadre',
        debugShowCheckedModeBanner: false,
        theme: temaAntiDescuadre(),
        locale: const Locale('es'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('es'), Locale('en')],
        home: const PantallaRaiz(),
      );
}
