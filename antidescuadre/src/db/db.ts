import Dexie, { type Table } from 'dexie'
import type {
  Turno, Mesa, Categoria, Producto, Cuenta, ItemCuenta, Pago, Comprobante, Ajustes,
} from './tipos'

class BaseAntiDescuadre extends Dexie {
  turnos!: Table<Turno, number>
  mesas!: Table<Mesa, number>
  categorias!: Table<Categoria, number>
  productos!: Table<Producto, number>
  cuentas!: Table<Cuenta, number>
  items!: Table<ItemCuenta, number>
  pagos!: Table<Pago, number>
  comprobantes!: Table<Comprobante, number>
  ajustes!: Table<Ajustes, number>

  constructor() {
    super('antidescuadre')
    this.version(1).stores({
      turnos: '++id, estado, inicio',
      mesas: '++id, orden',
      categorias: '++id, padreId',
      productos: '++id, categoriaId, activo',
      cuentas: '++id, mesaId, turnoId, estado',
      items: '++id, cuentaId, estado, tandaId',
      pagos: '++id, cuentaId, turnoId',
      comprobantes: '++id, estado, turnoId, mesaId, cuentaId',
      ajustes: '++id',
    })
  }
}

export const db = new BaseAntiDescuadre()

export const AJUSTES_DEFECTO: Ajustes = {
  nombreNegocio: 'Mi bar',
  alertaMinutos: 10,
}

export async function obtenerAjustes(): Promise<Ajustes> {
  const a = await db.ajustes.toCollection().first()
  return a ?? AJUSTES_DEFECTO
}

export async function guardarAjustes(cambios: Partial<Ajustes>): Promise<void> {
  const actual = await db.ajustes.toCollection().first()
  if (actual?.id != null) await db.ajustes.update(actual.id, cambios)
  else await db.ajustes.add({ ...AJUSTES_DEFECTO, ...cambios })
}
