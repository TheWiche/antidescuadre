import type { ItemCuenta } from '../db/tipos'
import { dinero, horaCorta } from './dinero'
import { etiquetaVariantes, totalItem, totalItems } from './cuentas'

// Factura cronológica: tandas en orden de llegada, cada una con su hora (3.10.1)
export interface TandaFactura {
  hora: number
  lineas: { texto: string; cantidad: number; total: number }[]
}

export function facturaCronologica(items: ItemCuenta[]): TandaFactura[] {
  const porTanda = new Map<number, ItemCuenta[]>()
  for (const it of items) {
    const lista = porTanda.get(it.tandaId) ?? []
    lista.push(it)
    porTanda.set(it.tandaId, lista)
  }
  return [...porTanda.entries()]
    .sort((a, b) => a[0] - b[0])
    .map(([tanda, lista]) => ({
      hora: tanda,
      lineas: lista.map(it => ({
        texto: it.nombre + (it.variantes.length ? ` (${etiquetaVariantes(it.variantes)})` : ''),
        cantidad: it.cantidad,
        total: totalItem(it),
      })),
    }))
}

// Factura agrupada: mismos datos, sumados por producto+variante (3.10.2)
export interface LineaAgrupada { texto: string; cantidad: number; unitario: number; total: number }

export function facturaAgrupada(items: ItemCuenta[]): LineaAgrupada[] {
  const grupos = new Map<string, LineaAgrupada>()
  for (const it of items) {
    const texto = it.nombre + (it.variantes.length ? ` (${etiquetaVariantes(it.variantes)})` : '')
    const clave = `${texto}|${it.precioUnitario}`
    const previo = grupos.get(clave)
    if (previo) {
      previo.cantidad += it.cantidad
      previo.total = Math.round((previo.total + totalItem(it)) * 100) / 100
    } else {
      grupos.set(clave, { texto, cantidad: it.cantidad, unitario: it.precioUnitario, total: totalItem(it) })
    }
  }
  return [...grupos.values()]
}

export function facturaComoTexto(
  nombreNegocio: string, alias: string, items: ItemCuenta[], modo: 'cronologica' | 'agrupada',
): string {
  const lineas: string[] = [nombreNegocio.toUpperCase(), alias, '·'.repeat(24)]
  if (modo === 'cronologica') {
    for (const tanda of facturaCronologica(items)) {
      lineas.push(`— ${horaCorta(tanda.hora)} —`)
      for (const l of tanda.lineas) lineas.push(`${l.cantidad} × ${l.texto}  ${dinero(l.total)}`)
    }
  } else {
    for (const l of facturaAgrupada(items)) {
      lineas.push(`${l.texto} ×${l.cantidad} (${dinero(l.unitario)} c/u)  ${dinero(l.total)}`)
    }
  }
  lineas.push('·'.repeat(24), `TOTAL  ${dinero(totalItems(items))}`)
  return lineas.join('\n')
}
