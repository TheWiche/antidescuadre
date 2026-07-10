// Manejo de dinero y fecha/hora: el cálculo en sí no exige moneda configurada
// (regla 11), pero el símbolo mostrado y el formato de hora sí son
// personalizables desde Ajustes. Se leen de `Formato`, sincronizada una vez
// desde la raíz de la app — evita pasar parámetros nuevos por los ~11
// archivos que llaman dinero()/horaCorta(), igual patrón que Haptico.activo.

import 'package:intl/intl.dart';

abstract final class Formato {
  static String simbolo = '\$';
  static bool horas24 = false;
}

double redondear(double n) => (n * 100).roundToDouble() / 100;

String dinero(double n) {
  final r = redondear(n);
  final tieneCentavos = (r % 1).abs() > 0.004;
  final formato = NumberFormat.decimalPatternDigits(
    locale: 'es',
    decimalDigits: tieneCentavos ? 2 : 0,
  );
  return '${Formato.simbolo}${formato.format(r)}';
}

double leerMonto(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
  final n = double.tryParse(limpio);
  if (n == null || !n.isFinite || n < 0) return 0;
  return redondear(n);
}

String horaCorta(DateTime t) =>
    (Formato.horas24 ? DateFormat.Hm('es') : DateFormat.jm('es')).format(t);

String fechaCorta(DateTime t) => DateFormat('EEE d MMM', 'es').format(t);

String fechaLarga(DateTime t) => DateFormat("d 'de' MMMM 'de' y", 'es').format(t);

int minutosDesde(DateTime desde, [DateTime? ahora]) =>
    (ahora ?? DateTime.now()).difference(desde).inMinutes;
