// Entidades del dominio — fiel al modelo de datos de planificacion-app-cuadre.md

export interface Turno {
  id?: number
  inicio: number // epoch ms
  fin?: number
  estado: 'activo' | 'cerrado'
}

export interface Mesa {
  id?: number
  alias: string // 100% editable, sin número fijo obligatorio
  orden: number
}

export interface Categoria {
  id?: number
  nombre: string
  padreId: number | null // null = categoría raíz; anidación libre
}

// Opción de variante: puede tener hijas (ej. Base > Cerveza > Corona).
// El ajuste de precio efectivo es la suma de los deltas del camino elegido.
export interface OpcionVariante {
  id: string
  nombre: string
  delta: number // precio extra respecto al precio base (puede ser 0)
  hijas?: OpcionVariante[]
}

export interface GrupoVariante {
  id: string
  nombre: string // ej. "Base", "Sabor"
  opciones: OpcionVariante[]
}

export interface Producto {
  id?: number
  nombre: string
  precio: number // precio base
  categoriaId: number | null
  activo: boolean
  grupos: GrupoVariante[] // vacío si no tiene variantes
}

// Selección hecha al agregar un ítem: por cada grupo, el camino de opciones elegido
export interface SeleccionVariante {
  grupo: string
  camino: string[] // nombres, ej. ["Cerveza", "Corona"]
  delta: number // suma de deltas del camino
}

export interface Cuenta {
  id?: number
  mesaId: number | null // null = venta directa
  turnoId: number
  estado: 'abierta' | 'cerrada'
  abiertaEn: number
  cerradaEn?: number
  esDirecta: boolean
}

export interface ItemCuenta {
  id?: number
  cuentaId: number
  productoId: number | null
  nombre: string // congelado al agregar
  variantes: SeleccionVariante[]
  cantidad: number
  precioUnitario: number // congelado al agregar (base + deltas)
  estado: 'pendiente' | 'entregado'
  agregadoEn: number
  entregadoEn?: number
  tandaId: number // agrupa los ítems confirmados juntos (para factura cronológica)
  parteId?: string // asignación en división por consumo
}

// Una "parte" de pago ya cobrada. El pago de una cuenta puede constar de
// varias partes (división); cada parte puede combinar efectivo y transferencia.
export interface Pago {
  id?: number
  cuentaId: number
  turnoId: number
  etiqueta: string // ej. "Cuenta completa", "Parte 2 de 3", "Ana"
  monto: number
  efectivo: number
  transferencia: number
  recibido?: number // cuánto entregó el cliente en efectivo (opcional)
  vuelto?: number
  creadoEn: number
}

export interface Comprobante {
  id?: number
  imagen: Blob
  fecha: number
  turnoId: number | null
  mesaId: number | null // captura libre => null
  aliasMesa: string | null // congelado para historial
  cuentaId: number | null
  pagoId: number | null
  monto: number | null
  estado: 'pendiente' | 'legalizada'
  legalizadaEn?: number
}

export interface Ajustes {
  id?: number
  nombreNegocio: string
  alertaMinutos: number // único valor global para pedidos sin entregar
}

// Archivo de exportación: SOLO configuración, nunca datos operativos.
export interface ConfigExportada {
  app: 'antidescuadre'
  version: 1
  exportadoEn: string
  nombreNegocio: string
  alertaMinutos: number
  categorias: { id: number; nombre: string; padreId: number | null }[]
  productos: {
    nombre: string
    precio: number
    categoriaId: number | null
    activo: boolean
    grupos: GrupoVariante[]
  }[]
  mesas: { alias: string; orden: number }[]
}
