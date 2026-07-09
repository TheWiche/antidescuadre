# Planificación de App — "AntiDescuadre"

---

## 1. Resumen ejecutivo

App móvil de gestión de ventas y cobros para bares/restaurantes, de uso diario, **offline y de un solo usuario por instalación** (sin sistema de roles). Cada jornada de trabajo se organiza a partir de un **turno**: se inicia un turno y a partir de ahí arranca toda la operación del día.

El negocio puede vender de dos formas:

1. **Venta directa** (barra o caja): se pide y se cobra en el momento.
2. **Cuenta pendiente por mesa**: se abre una cuenta, se van agregando productos, y se cobra después (total, dividido, o por lo que cada quien consumió).

Todo el catálogo de productos, categorías, variantes, precios y alias de mesas es **totalmente configurable**. Además, esa configuración se puede **exportar/importar**, para poder reutilizarla en otro dispositivo o "perfil" (soporte a múltiples locales sin necesidad de cuentas online).

---

## 2. Principios de diseño

- **El turno es el punto de partida**: no se opera (vender, abrir mesas, cobrar) sin haber iniciado un turno; es el "comienzo de todo" en el día a día.
- **Flexibilidad de mesas**: alias 100% editables, sin depender de un orden físico.
- **Configurabilidad total**: productos, categorías, subcategorías, variantes (con posible precio extra), precios, tiempos de alerta de pedidos pendientes — todo editable por el usuario, nada precargado de fábrica.
- **Offline y personal**: una sola persona usa cada instalación; no hay roles ni permisos diferenciados.
- **Portabilidad de configuración**: lo configurado se puede exportar/importar como archivo, permitiendo replicar la misma configuración en otro local/dispositivo.
- **Trazabilidad de comprobantes**: toda transferencia queda con un estado de legalización claro, y no puede pasar desapercibida mientras esté pendiente (ver 3.7).

---

## 3. Módulos funcionales

### 3.1 Turno / inicio y cierre de jornada
- Al abrir la app para empezar a trabajar, el usuario **inicia un turno**; este es el punto de partida de todo lo demás (ventas, mesas, cobros, comprobantes).
- Todo lo que ocurre durante la jornada (ventas directas, cuentas de mesa, pagos, comprobantes, pedidos pendientes) queda asociado al turno activo.
- Existe también la opción de **cerrar el turno** explícitamente.
- **Restricción para cerrar turno**: no se puede cerrar si quedan mesas con saldo pendiente por cobrar; primero hay que cobrar (o al menos dejar en $0) todas las cuentas abiertas.
- El dashboard y los reportes pueden organizarse por turno, además de por fecha.

### 3.2 Venta directa (barra / caja)
- Selección rápida de productos del catálogo.
- Cobro inmediato (efectivo y/o transferencia).
- No requiere abrir una "cuenta" persistente; es una transacción de una sola vez.

### 3.3 Mesas y cuentas pendientes
- Vista general de mesas (ocupadas / libres).
- Cada mesa tiene un **alias editable** (ej. "La de la ventana", "VIP 2") en vez de un número fijo obligatorio.
- Se puede abrir una cuenta en una mesa y agregar productos progresivamente mientras los clientes están sentados.
- La cuenta acumula ítems hasta que se decide cobrar (total, dividido, o por consumo — ver 3.5).

### 3.4 Catálogo de productos (configuración)
- Alta, edición y baja de productos por parte del dueño.
- Edición libre de precios en cualquier momento.
- **Categorías y subcategorías** totalmente configurables (ej. "Bebidas > Cervezas", "Bebidas > Cócteles > Mojitos").
- **Productos con variantes/opciones configurables** (ej. "Michelada" con base cerveza o soda, y dentro de cada una varias marcas/sabores; "Mojito" con distintos sabores).
- Cada variante puede tener un **precio extra o diferencial configurable** respecto al precio base del producto (ej. una base premium cuesta un poco más).
- Nada del catálogo viene precargado de fábrica; todo lo arma el propietario según su negocio.

### 3.5 Cobro de cuentas y división de pago
- Una cuenta se puede cobrar completa o dividida. Dos formas de dividir:
  1. **Por partes** (ej. la cuenta se reparte en N partes, iguales o manuales).
  2. **Por consumo real**: cada persona paga exactamente los productos que tomó (se asignan ítems específicos a cada parte).
- Cada parte de pago puede **combinar métodos**: por ejemplo, una misma parte pagada mitad en efectivo y mitad en transferencia (no está limitado a un solo método por parte).
- **Cálculo de vuelto**: totalmente opcional — se puede ingresar cuánto dio el cliente y la app calcula el vuelto en vivo; no requiere configurar moneda ni denominaciones de antemano.

### 3.6 Comprobantes de transferencia (fotos)
- Módulo de cámara para capturar la foto del comprobante.
- Permite **rotar** y **repetir/volver a tomar** la foto antes de guardar.
- Las fotos se guardan en una **carpeta creada por la app dentro de la galería** del dispositivo.
- Cada comprobante queda ligado a la mesa correspondiente (cuando aplica); una misma mesa puede tener varios comprobantes.
- **Captura libre**: también se puede tomar una foto de transferencia sin ligarla a ninguna mesa.

### 3.7 Legalización de comprobantes
- Todo comprobante de transferencia nace en estado **"pendiente de legalizar"** (aún no se ha mostrado/verificado en barra).
- Mientras exista al menos un comprobante pendiente, la app muestra una **notificación obligatoria y no descartable** (no se puede cerrar ni borrar) avisando que hay una transferencia pendiente por legalizar.
- Los comprobantes pendientes aparecen listados en un apartado dedicado ("Pendientes por legalizar").
- Al verificarlo, se marca como **"legalizada"**; si ya no quedan pendientes, la notificación desaparece.

### 3.8 Dashboard / resumen
- Qué mesas tienen saldo pendiente y por cuánto.
- Total pendiente por cobrar.
- Total cobrado (efectivo / transferencia), filtrable por turno y/o por fecha.
- Cantidad de comprobantes pendientes por legalizar.
- Cantidad de pedidos pendientes por entregar.

### 3.9 Pedidos pendientes por entregar
- Los productos agregados a una cuenta nacen en estado **"pendiente"** hasta marcarse como **"entregado"**.
- Listado clasificado por mesa, para saber qué falta por llevar a cada una.
- **Alerta visual configurable**: si un pedido lleva más de cierto tiempo sin entregarse, se resalta con un aviso. El tiempo límite es **un solo valor global**, configurable desde Ajustes (no varía por producto ni por mesa).

### 3.10 Facturación / recibos
Para una misma cuenta, dos formas de ver la factura (generadas dinámicamente de los mismos datos):

1. **Factura cronológica**: cada tanda de productos agregada aparece como línea con su hora (ej. 3 cervezas a las 8:00pm, 3 más a las 8:30pm, etc.).
2. **Factura agrupada**: los mismos productos, sumados y multiplicados por precio unitario (ej. "Cerveza x9 · subtotal").

### 3.11 Perfiles, multi-local y exportación de configuración
- Uso individual y offline: cada usuario configura y personaliza su propia instancia como quiera.
- En **Ajustes**, un apartado para **exportar/importar configuración** (productos, categorías, variantes, precios, alias de mesas, alertas, etc.) como archivo, para compartirla o replicarla en otro dispositivo.
- El archivo de exportación incluye **únicamente configuración** (catálogo, categorías, variantes, precios, alias de mesas, ajustes generales). **No incluye** datos operativos de un turno (mesas activas, cuentas abiertas, ventas o comprobantes del momento).
- Esto habilita un uso tipo **multi-local**: cada local puede tener su propio perfil/configuración, sin necesidad de cuentas online ni sistema de roles.

---

## 4. Experiencia de usuario y diseño (UX/UI)

- La app debe sentirse **animada, dinámica e intuitiva**, no una tabla de datos fría.
- Especial cuidado en la interacción de **agregar productos a una mesa**: rápida, fluida, con feedback visual/animado.
- Transiciones suaves y coherentes entre mesas, cuentas, comprobantes y facturas.
- Marcar un pedido como "entregado", legalizar un comprobante, o cambiar entre factura cronológica/agrupada deben sentirse fluidos, no como recargar una pantalla distinta.
- La notificación de comprobantes pendientes por legalizar debe ser visible y persistente, pero sin resultar invasiva al punto de bloquear el resto del uso de la app.

---

## 5. Reglas de negocio (resumen)

| # | Regla |
|---|---|
| 1 | Se debe iniciar un turno antes de operar; todo lo que ocurre en el día queda asociado a ese turno. |
| 1b | El turno se puede cerrar explícitamente, pero no si quedan mesas con saldo pendiente por cobrar. |
| 2 | Una venta puede ser directa (sin mesa) o vía cuenta de mesa (pendiente). |
| 3 | Los alias de mesa son libres y editables en cualquier momento. |
| 4 | Los productos, categorías, subcategorías y variantes son totalmente configurables por el dueño. |
| 5 | Una variante de producto puede tener un precio extra configurable respecto al precio base. |
| 6 | Una cuenta de mesa puede dividirse por partes arbitrarias o por consumo real de cada persona. |
| 7 | Una misma parte de pago puede combinar efectivo y transferencia. |
| 8 | Toda transferencia requiere foto de comprobante y nace en estado "pendiente de legalizar". |
| 9 | Mientras haya comprobantes pendientes de legalizar, se muestra una notificación obligatoria no descartable. |
| 10 | Un comprobante puede o no estar ligado a una mesa; una mesa puede tener varios. |
| 11 | El vuelto se calcula de forma opcional a partir del monto recibido, sin necesidad de configurar moneda. |
| 12 | Un producto agregado a una cuenta inicia en estado "pendiente" hasta marcarse como "entregado". |
| 13 | Si un pedido pendiente supera un tiempo límite (valor global configurable) sin entregarse, se muestra una alerta visual. |
| 14 | Toda cuenta puede verse como factura cronológica o como factura agrupada. |
| 15 | La app es de uso individual/offline (sin roles); solo la configuración (catálogo, ajustes) se puede exportar/importar — los datos operativos de un turno no se incluyen. |

---

## 6. Modelo de datos sugerido (entidades)

- **Turno**: hora de inicio, hora de fin (si se cerró), estado (activo/cerrado). Solo puede pasar a "cerrado" si ninguna mesa asociada tiene saldo pendiente.
- **Local/Perfil**: datos del negocio configurado (nombre, catálogo asociado); exportable/importable.
- **CategoriaProducto**: nombre, categoría padre (opcional, para subcategorías).
- **Producto**: nombre, precio base, categoría asociada, activo/inactivo.
- **VarianteProducto / OpcionProducto**: grupo de opciones de un producto (ej. "Base": Cerveza/Soda), cada opción con nombre y **ajuste de precio opcional**.
- **Mesa**: alias (editable), estado (libre/ocupada), cuenta activa (si aplica).
- **Cuenta**: mesa asociada (o null si es venta directa), turno asociado, estado (abierta/cerrada), lista de ítems, fecha de apertura/cierre.
- **ItemCuenta**: producto (y variante elegida, si aplica), cantidad, precio unitario al agregarlo, estado (pendiente/entregado), hora de agregado, hora de entrega, parte de pago asignada (si se dividió por consumo).
- **Pago**: cuenta asociada, una o varias sub-partes con su propio monto y método (efectivo y/o transferencia combinados), vuelto calculado (si aplica efectivo).
- **ComprobanteTransferencia**: imagen, fecha/hora, pago asociado (opcional), mesa asociada (opcional), **estado de legalización** (pendiente de legalizar / legalizada).
- **Factura** (vista derivada, no necesariamente una tabla nueva): generada a partir de los `ItemCuenta` de una cuenta, en modo cronológico o agrupado.

---

## 7. Flujos de usuario principales

1. **Inicio y cierre de turno**: abrir la app → iniciar turno → queda habilitada toda la operación del día. Al querer cerrar turno: la app verifica que no haya mesas con saldo pendiente (si las hay, bloquea el cierre y avisa cuáles faltan por cobrar) → si todo está en $0, se cierra el turno.
2. **Venta directa**: elegir productos → cobrar (efectivo/transferencia) → si transferencia, capturar comprobante (queda pendiente de legalizar) → fin.
3. **Cuenta de mesa**: abrir mesa (o elegir existente) → agregar productos (quedan "pendientes" por entregar) → marcar ítems como entregados a medida que se llevan → al cobrar, elegir cobro total, por partes, o por consumo real → cada parte define método(s) de pago → si hay transferencia, capturar comprobante ligado a esa mesa → cerrar cuenta cuando el saldo llega a cero.
4. **Comprobante suelto**: acceder a "Cámara de comprobantes" fuera del flujo de mesas → capturar/rotar/repetir → queda pendiente de legalizar.
5. **Legalización**: la app muestra notificación persistente mientras haya comprobantes pendientes → entrar al listado de pendientes → verificar y marcar como legalizado.
6. **Entrega de pedidos**: entrar al módulo de pendientes → ver ítems agrupados por mesa (con alerta si alguno lleva demasiado tiempo) → marcar como entregado.
7. **Generación de factura**: desde una mesa/cuenta → elegir vista cronológica o agrupada → mostrar/compartir.
8. **Exportar/importar configuración**: desde Ajustes → exportar configuración actual (catálogo, categorías, variantes, precios, alias de mesas, ajustes) a un archivo → compartirlo o importarlo en otro dispositivo/perfil para replicar el mismo catálogo y ajustes. No se exportan datos operativos de turno (mesas activas, ventas, comprobantes en curso).

---

## 8. Consideraciones técnicas (a definir)

- Plataforma: app móvil (requiere cámara y acceso a galería) — ¿Android, iOS o ambas?
- Persistencia: base de datos local (ej. SQLite), pensada para funcionamiento **offline-first** (sin backend obligatorio).
- Exportación/importación de configuración: archivo local (ej. JSON) con solo catálogo/ajustes (sin datos operativos de turno), que el usuario puede compartir manualmente.
- Permisos necesarios: cámara, almacenamiento/galería, notificaciones (para el aviso obligatorio de comprobantes pendientes).
- Motor de animaciones/UI a definir según plataforma, para cumplir el criterio de la sección 4.

---

## 9. Preguntas abiertas / decisiones pendientes

Sin preguntas pendientes por ahora — el documento refleja todas las decisiones tomadas hasta el momento. Cualquier ajuste nuevo se puede agregar aquí a medida que surja.

---

## 10. Fuera de alcance (explícito, por ahora)

- Sistema de roles/permisos de usuario (la app es de uso individual por instalación).
- Sincronización en la nube o multi-dispositivo en tiempo real (el "multi-local" se resuelve vía exportar/importar configuración, no vía cuentas online).
- Registro obligatorio de denominaciones de billetes para el vuelto (se mantiene opcional).
