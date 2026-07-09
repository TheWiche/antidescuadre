# AntiDescuadre

App **nativa de Android** para gestión de ventas y cobros en bares y restaurantes.
Offline, de un solo usuario por instalación, sin cuentas ni nube. Implementa fielmente
la lógica de negocio de [`planificacion-app-cuadre.md`](planificacion-app-cuadre.md).

- **Descargar el APK**: https://github.com/TheWiche/antidescuadre/releases/latest/download/antidescuadre.apk
- **Página de presentación e instalación**: https://thewiche.github.io/antidescuadre/

## Qué hace

Turnos como punto de partida del día · mesas con alias libres · catálogo configurable
con categorías anidadas y variantes con precio extra · cuentas por mesa vistas como
ticket de comanda · cobro total / por partes / por consumo, combinando efectivo y
transferencia, con vuelto opcional · comprobantes de transferencia por cámara (rotar,
repetir) guardados en la app y en la galería, con legalización obligatoria y aviso
persistente · pedidos pendientes por entregar con alerta por tiempo · factura
cronológica o agrupada · exportar/importar la configuración para multi-local.

## Estructura

```
app/     App Flutter (Dart) para Android — el producto
sitio/   Página estática de presentación y descarga del APK (GitHub Pages)
.github/ Workflow: publica el sitio en Pages y el APK firmado en Releases
```

## Stack

Flutter 3.44 · Drift (SQLite reactivo) · Riverpod · camera + image + gal ·
flutter_local_notifications · share_plus + file_picker · lucide_icons_flutter.
Tipografías empaquetadas: Bricolage Grotesque, Instrument Sans, Spline Sans Mono.

## Desarrollo

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera el código de Drift
flutter test                                                # lógica de negocio
flutter run                                                 # en emulador o dispositivo
flutter build apk --release                                 # APK (firma: ver abajo)
```

### Firma del APK

El release se firma con un keystore que **no** está en el repositorio. Para compilar
un release firmado localmente, crea `app/android/key.properties` (ignorado por git):

```
storeFile=RUTA/AL/antidescuadre-release.keystore
storePassword=…
keyAlias=…
keyPassword=…
```

En CI, el mismo keystore se inyecta desde secretos del repositorio
(`ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
`ANDROID_KEY_PASSWORD`) y el APK firmado se publica en el release `latest`.

## Diseño — "La comanda de la casa"

Ciruela de medianoche con tres acentos que codifican el negocio: **ámbar** = efectivo
y acción, **cian** = transferencias, **menta** = entregado y pagado. El elemento firma
es el ticket de comanda troquelado (papel crema, tipografía mono, borde dentado): la
cuenta de cada mesa y las facturas *son* un ticket.
