# AntiDescuadre

Ventas y cobros sin descuadres para bares y restaurantes. App móvil **offline-first,
de un solo usuario por instalación**, construida como PWA instalable.
La lógica de negocio implementada es la de `../planificacion-app-cuadre.md`.

## Cómo ejecutarla

```bash
npm install
npm run dev        # desarrollo → http://localhost:5173 (accesible en red local)
npm run build      # producción → dist/ (PWA con service worker, funciona offline)
npm run preview    # sirve el build de producción
```

Para usarla en el teléfono: abre la URL de red que imprime Vite (o despliega `dist/`
en cualquier hosting estático) y usa **"Agregar a pantalla de inicio"** — queda
instalada como app, con sus datos guardados localmente (IndexedDB).

> La cámara del navegador requiere HTTPS fuera de `localhost`. Si se abre por IP
> en red local, la captura de comprobantes usa la cámara nativa del teléfono
> (selector de archivo con `capture`), que funciona igual.

## Stack

- **React 18 + TypeScript + Vite** · PWA con `vite-plugin-pwa`
- **Dexie (IndexedDB)** — persistencia local offline; las fotos de comprobantes se
  guardan como blobs en la base
- **Framer Motion** (animaciones/gestos) · **Lucide** (íconos)
- Tipografías autoalojadas: Bricolage Grotesque (display), Instrument Sans (texto),
  Spline Sans Mono (números y tickets)

## Estructura

```
src/
  db/          tipos de dominio + esquema Dexie
  logica/      lógica de negocio pura (cuentas, dinero, factura, export/import)
  componentes/ piezas compartidas (Ticket firma, Hoja, Cámara, SelectorProductos,
               FlujoCobro, FacturaVista…)
  pantallas/   Resumen (turno/dashboard), Mesas, MesaDetalle, Vender, Pendientes,
               Comprobantes, Catálogo, Ajustes, Más
```

## Sistema de diseño — "La comanda de la casa"

- Paleta: ciruela de medianoche `#221723` / `#2F2130`, ámbar cerveza `#F6A83C`
  (efectivo/acción), cian eléctrico `#56C8E8` (transferencias/legalización),
  menta `#6FCF97` (entregado/pagado), crema `#F7EFE3`, rojo alerta `#FF6B6B`.
  El color codifica el negocio: ámbar = efectivo, cian = transferencia, menta = listo.
- **Elemento firma:** el ticket de comanda troquelado (borde dentado, papel crema,
  tipografía mono). La cuenta de cada mesa y las facturas *son* un ticket; las líneas
  nuevas "se imprimen" con animación de resorte.
- Navegación de pulgar: barra inferior de 5 pestañas; la notificación de comprobantes
  pendientes es una cinta persistente sobre la barra (no descartable, no bloqueante).
