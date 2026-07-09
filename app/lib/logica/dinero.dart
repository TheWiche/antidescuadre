// Manejo de dinero: sin moneda configurada (regla 11), formato $ con 2
// decimales solo cuando hacen falta. Redondeo a centavos para evitar
// arrastres de coma flotante. Port 1:1 de la lógica ya verificada en web.

import 'package:intl/intl.dart';

double redondear(double n) => (n * 100).roundToDouble() / 100;

String dinero(double n) {
  final r = redondear(n);
  final tieneCentavos = (r % 1).abs() > 0.004;
  final formato = NumberFormat.decimalPatternDigits(
    locale: 'es',
    decimalDigits: tieneCentavos ? 2 : 0,
  );
  return '\$${formato.format(r)}';
}

double leerMonto(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
  final n = double.tryParse(limpio);
  if (n == null || !n.isFinite || n < 0) return 0;
  return redondear(n);
}

String horaCorta(DateTime t) => DateFormat.jm('es').format(t);

String fechaCorta(DateTime t) => DateFormat('EEE d MMM', 'es').format(t);

String fechaLarga(DateTime t) => DateFormat("d 'de' MMMM 'de' y", 'es').format(t);

int minutosDesde(DateTime desde, [DateTime? ahora]) =>
    (ahora ?? DateTime.now()).difference(desde).inMinutes;
