import { db, obtenerAjustes, guardarAjustes } from '../db/db'
import type { ConfigExportada } from '../db/tipos'

// Exporta SOLO configuración (catálogo, categorías, variantes, precios,
// alias de mesas, ajustes). Nunca datos operativos de turno (regla 15).
export async function exportarConfiguracion(): Promise<ConfigExportada> {
  const [ajustes, categorias, productos, mesas] = await Promise.all([
    obtenerAjustes(),
    db.categorias.toArray(),
    db.productos.toArray(),
    db.mesas.orderBy('orden').toArray(),
  ])
  return {
    app: 'antidescuadre',
    version: 1,
    exportadoEn: new Date().toISOString(),
    nombreNegocio: ajustes.nombreNegocio,
    alertaMinutos: ajustes.alertaMinutos,
    categorias: categorias.map(c => ({ id: c.id!, nombre: c.nombre, padreId: c.padreId })),
    productos: productos.map(p => ({
      nombre: p.nombre, precio: p.precio, categoriaId: p.categoriaId,
      activo: p.activo, grupos: p.grupos,
    })),
    mesas: mesas.map(m => ({ alias: m.alias, orden: m.orden })),
  }
}

export function validarConfiguracion(dato: unknown): ConfigExportada | null {
  if (typeof dato !== 'object' || dato === null) return null
  const c = dato as Record<string, unknown>
  if (c.app !== 'antidescuadre' || c.version !== 1) return null
  if (!Array.isArray(c.categorias) || !Array.isArray(c.productos) || !Array.isArray(c.mesas)) return null
  return c as unknown as ConfigExportada
}

// Reemplaza la configuración actual por la importada. No toca datos operativos
// (turnos, cuentas, ítems, pagos, comprobantes).
export async function importarConfiguracion(config: ConfigExportada): Promise<void> {
  await db.transaction('rw', [db.categorias, db.productos, db.mesas, db.ajustes], async () => {
    await db.categorias.clear()
    await db.productos.clear()
    await db.mesas.clear()

    // Reinsertar categorías conservando la jerarquía con ids nuevos
    const mapaIds = new Map<number, number>()
    const pendientes = [...config.categorias]
    let vueltas = 0
    while (pendientes.length > 0 && vueltas < 100) {
      vueltas++
      for (let i = pendientes.length - 1; i >= 0; i--) {
        const cat = pendientes[i]
        if (cat.padreId === null || mapaIds.has(cat.padreId)) {
          const nuevoId = await db.categorias.add({
            nombre: cat.nombre,
            padreId: cat.padreId === null ? null : mapaIds.get(cat.padreId)!,
          })
          mapaIds.set(cat.id, nuevoId)
          pendientes.splice(i, 1)
        }
      }
    }

    for (const p of config.productos) {
      await db.productos.add({
        nombre: p.nombre,
        precio: p.precio,
        categoriaId: p.categoriaId != null ? (mapaIds.get(p.categoriaId) ?? null) : null,
        activo: p.activo !== false,
        grupos: Array.isArray(p.grupos) ? p.grupos : [],
      })
    }

    await db.mesas.bulkAdd(config.mesas.map((m, i) => ({ alias: m.alias, orden: m.orden ?? i })))
  })
  await guardarAjustes({
    nombreNegocio: config.nombreNegocio ?? 'Mi bar',
    alertaMinutos: config.alertaMinutos ?? 10,
  })
}

export function descargarArchivo(nombre: string, contenido: string): void {
  const blob = new Blob([contenido], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = nombre
  a.click()
  setTimeout(() => URL.revokeObjectURL(url), 5000)
}
