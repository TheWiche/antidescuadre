import { db } from '../db/db'
import type { Cuenta, ItemCuenta, Pago, SeleccionVariante, Producto } from '../db/tipos'
import { redondear } from './dinero'

export function totalItem(item: ItemCuenta): number {
  return redondear(item.precioUnitario * item.cantidad)
}

export function totalItems(items: ItemCuenta[]): number {
  return redondear(items.reduce((s, it) => s + totalItem(it), 0))
}

export function totalPagado(pagos: Pago[]): number {
  return redondear(pagos.reduce((s, p) => s + p.monto, 0))
}

export function saldoCuenta(items: ItemCuenta[], pagos: Pago[]): number {
  return redondear(totalItems(items) - totalPagado(pagos))
}

export function precioUnitario(producto: Producto, variantes: SeleccionVariante[]): number {
  return redondear(producto.precio + variantes.reduce((s, v) => s + v.delta, 0))
}

export function etiquetaVariantes(variantes: SeleccionVariante[]): string {
  return variantes.map(v => v.camino.join(' · ')).join(' · ')
}

// ---------- Operaciones sobre cuentas ----------

export async function abrirCuentaEnMesa(mesaId: number, turnoId: number): Promise<number> {
  return db.cuentas.add({
    mesaId, turnoId, estado: 'abierta', abiertaEn: Date.now(), esDirecta: false,
  })
}

export async function cuentaActivaDeMesa(mesaId: number): Promise<Cuenta | undefined> {
  return db.cuentas.where({ mesaId }).filter(c => c.estado === 'abierta').first()
}

export interface LineaNueva {
  producto: Producto
  variantes: SeleccionVariante[]
  cantidad: number
}

// Agrega una tanda de productos a una cuenta. Los ítems nacen "pendientes"
// (regla 12); en venta directa nacen entregados porque se sirven en barra.
export async function agregarTanda(
  cuentaId: number, lineas: LineaNueva[], entregadoInmediato = false,
): Promise<void> {
  const ahora = Date.now()
  await db.items.bulkAdd(lineas.map(l => ({
    cuentaId,
    productoId: l.producto.id ?? null,
    nombre: l.producto.nombre,
    variantes: l.variantes,
    cantidad: l.cantidad,
    precioUnitario: precioUnitario(l.producto, l.variantes),
    estado: entregadoInmediato ? 'entregado' as const : 'pendiente' as const,
    agregadoEn: ahora,
    entregadoEn: entregadoInmediato ? ahora : undefined,
    tandaId: ahora,
  })))
}

export async function cerrarCuenta(cuentaId: number): Promise<void> {
  await db.cuentas.update(cuentaId, { estado: 'cerrada', cerradaEn: Date.now() })
}

// ---------- Turno ----------

// Devuelve null (no undefined) cuando no hay turno, para que useLiveQuery
// pueda distinguir "cargando" (undefined) de "sin turno activo" (null).
export async function turnoActivo() {
  return (await db.turnos.where('estado').equals('activo').first()) ?? null
}

export async function iniciarTurno(): Promise<number> {
  return db.turnos.add({ inicio: Date.now(), estado: 'activo' })
}

export interface MesaConSaldo { mesaId: number | null; alias: string; saldo: number }

// Mesas del turno con saldo pendiente (bloquean el cierre — regla 1b).
export async function mesasConSaldoPendiente(turnoId: number): Promise<MesaConSaldo[]> {
  const abiertas = await db.cuentas.where({ turnoId }).filter(c => c.estado === 'abierta').toArray()
  const resultado: MesaConSaldo[] = []
  for (const c of abiertas) {
    const items = await db.items.where({ cuentaId: c.id! }).toArray()
    const pagos = await db.pagos.where({ cuentaId: c.id! }).toArray()
    const saldo = saldoCuenta(items, pagos)
    if (saldo > 0) {
      const mesa = c.mesaId != null ? await db.mesas.get(c.mesaId) : undefined
      resultado.push({ mesaId: c.mesaId, alias: mesa?.alias ?? 'Venta directa', saldo })
    }
  }
  return resultado
}

// Cierra el turno si ninguna mesa tiene saldo; las cuentas abiertas en $0 se cierran.
export async function cerrarTurno(turnoId: number): Promise<{ ok: boolean; bloqueos: MesaConSaldo[] }> {
  const bloqueos = await mesasConSaldoPendiente(turnoId)
  if (bloqueos.length > 0) return { ok: false, bloqueos }
  const abiertas = await db.cuentas.where({ turnoId }).filter(c => c.estado === 'abierta').toArray()
  for (const c of abiertas) await cerrarCuenta(c.id!)
  await db.turnos.update(turnoId, { estado: 'cerrado', fin: Date.now() })
  return { ok: true, bloqueos: [] }
}
