import { useEffect, useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import { Check, CheckCheck, ClipboardList, Flame } from 'lucide-react'
import { db, obtenerAjustes } from '../db/db'
import type { Cuenta, ItemCuenta } from '../db/tipos'
import { minutosDesde } from '../logica/dinero'
import { etiquetaVariantes, turnoActivo } from '../logica/cuentas'
import { SinTurno } from '../componentes/SinTurno'
import { Vacio } from '../componentes/Vacio'

// Pedidos pendientes por entregar, agrupados por mesa. Si un pedido supera
// el tiempo límite global (Ajustes), se resalta con alerta visual (regla 13).
export function Pendientes() {
  const turno = useLiveQuery(() => turnoActivo(), [])
  const ajustes = useLiveQuery(() => obtenerAjustes(), [])
  const mesas = useLiveQuery(() => db.mesas.toArray(), []) ?? []
  const abiertas = useLiveQuery(
    () => turno?.id
      ? db.cuentas.where({ turnoId: turno.id }).filter(c => c.estado === 'abierta').toArray()
      : Promise.resolve([] as Cuenta[]),
    [turno?.id],
  ) ?? []
  const idsAbiertas = abiertas.map(c => c.id!)
  const pendientes = useLiveQuery(
    () => idsAbiertas.length
      ? db.items.where('cuentaId').anyOf(idsAbiertas).filter(i => i.estado === 'pendiente').toArray()
      : Promise.resolve([] as ItemCuenta[]),
    [idsAbiertas.join(',')],
  ) ?? []

  // El reloj de "hace X min" se refresca solo
  const [, setTic] = useState(0)
  useEffect(() => {
    const intervalo = setInterval(() => setTic(t => t + 1), 20000)
    return () => clearInterval(intervalo)
  }, [])

  const limite = ajustes?.alertaMinutos ?? 10

  const grupos = useMemo(() => {
    const porCuenta = new Map<number, typeof pendientes>()
    for (const it of pendientes) {
      const lista = porCuenta.get(it.cuentaId) ?? []
      lista.push(it)
      porCuenta.set(it.cuentaId, lista)
    }
    return [...porCuenta.entries()].map(([cuentaId, lista]) => {
      const cuenta = abiertas.find(c => c.id === cuentaId)
      const alias = cuenta?.mesaId != null
        ? (mesas.find(m => m.id === cuenta.mesaId)?.alias ?? 'Mesa')
        : 'Venta directa'
      return { cuentaId, alias, items: lista.sort((a, b) => a.agregadoEn - b.agregadoEn) }
    })
  }, [pendientes, abiertas, mesas])

  if (turno === undefined) return <div className="pantalla" />
  if (!turno) {
    return (
      <div className="pantalla">
        <h1 className="pantalla-titulo">Por entregar</h1>
        <SinTurno mensaje="Inicia el turno para ver los pedidos en marcha." />
      </div>
    )
  }

  return (
    <div className="pantalla">
      <h1 className="pantalla-titulo">Por entregar</h1>
      <p className="pantalla-sub">
        Lo que falta llevar a cada mesa · alerta a los {limite} min.
      </p>

      {grupos.length === 0 ? (
        <Vacio icono={ClipboardList} titulo="Todo entregado" detalle="Nada pendiente por llevar." />
      ) : (
        <div className="apilado">
          <AnimatePresence initial={false}>
            {grupos.map(g => (
              <motion.div
                key={g.cuentaId}
                layout
                initial={{ opacity: 0, y: 14 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.96 }}
                className="tarjeta"
              >
                <div className="espaciado" style={{ marginBottom: 4 }}>
                  <h3 style={{ fontSize: 17 }}>{g.alias}</h3>
                  <button
                    className="chip chip-menta"
                    style={{ padding: '7px 12px' }}
                    onClick={async () => {
                      const ahora = Date.now()
                      for (const it of g.items) {
                        await db.items.update(it.id!, { estado: 'entregado', entregadoEn: ahora })
                      }
                      if (navigator.vibrate) navigator.vibrate(20)
                    }}
                  >
                    <CheckCheck size={14} /> Todo entregado
                  </button>
                </div>
                <AnimatePresence initial={false}>
                  {g.items.map(it => {
                    const minutos = minutosDesde(it.agregadoEn)
                    const tarde = minutos >= limite
                    return (
                      <motion.div
                        key={it.id}
                        layout
                        exit={{ opacity: 0, x: 60 }}
                        transition={{ duration: 0.18 }}
                        className="fila"
                      >
                        <div className="crece">
                          <div style={{ fontWeight: 600 }}>
                            {it.cantidad > 1 && <span className="mono">{it.cantidad} × </span>}
                            {it.nombre}
                          </div>
                          {it.variantes.length > 0 && (
                            <div className="pequeno tenue">{etiquetaVariantes(it.variantes)}</div>
                          )}
                        </div>
                        <span className={`chip ${tarde ? 'chip-rojo pulsa' : 'chip-neutro'} mono`}>
                          {tarde && <Flame size={13} />}
                          {minutos < 1 ? 'ahora' : `${minutos} min`}
                        </span>
                        <motion.button
                          whileTap={{ scale: 0.85 }}
                          className="btn btn-menta"
                          style={{ padding: 10, borderRadius: 12 }}
                          aria-label="Marcar entregado"
                          onClick={async () => {
                            await db.items.update(it.id!, { estado: 'entregado', entregadoEn: Date.now() })
                            if (navigator.vibrate) navigator.vibrate(12)
                          }}
                        >
                          <Check size={18} />
                        </motion.button>
                      </motion.div>
                    )
                  })}
                </AnimatePresence>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      )}
    </div>
  )
}
