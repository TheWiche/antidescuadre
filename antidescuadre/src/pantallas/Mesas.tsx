import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import { Armchair, Plus } from 'lucide-react'
import { db } from '../db/db'
import type { ItemCuenta, Pago } from '../db/tipos'
import { dinero } from '../logica/dinero'
import { saldoCuenta, turnoActivo } from '../logica/cuentas'
import { SinTurno } from '../componentes/SinTurno'
import { Vacio } from '../componentes/Vacio'
import { Hoja } from '../componentes/Hoja'

export function Mesas() {
  const navegar = useNavigate()
  const turno = useLiveQuery(() => turnoActivo(), [])
  const mesas = useLiveQuery(() => db.mesas.orderBy('orden').toArray(), []) ?? []
  const abiertas = useLiveQuery(
    () => db.cuentas.filter(c => c.estado === 'abierta' && c.mesaId !== null).toArray(), [],
  ) ?? []
  const idsAbiertas = abiertas.map(c => c.id!)
  const items = useLiveQuery(
    () => idsAbiertas.length ? db.items.where('cuentaId').anyOf(idsAbiertas).toArray() : Promise.resolve([] as ItemCuenta[]),
    [idsAbiertas.join(',')],
  ) ?? []
  const pagos = useLiveQuery(
    () => idsAbiertas.length ? db.pagos.where('cuentaId').anyOf(idsAbiertas).toArray() : Promise.resolve([] as Pago[]),
    [idsAbiertas.join(',')],
  ) ?? []

  const [agregando, setAgregando] = useState(false)
  const [alias, setAlias] = useState('')

  if (turno === undefined) return <div className="pantalla" />
  if (!turno) {
    return (
      <div className="pantalla">
        <h1 className="pantalla-titulo">Mesas</h1>
        <SinTurno mensaje="Inicia el turno para abrir cuentas en las mesas." />
      </div>
    )
  }

  return (
    <div className="pantalla">
      <div className="espaciado" style={{ marginBottom: 4 }}>
        <h1 className="pantalla-titulo" style={{ margin: 0 }}>Mesas</h1>
        <button className="btn btn-fantasma" style={{ padding: '9px 16px' }} onClick={() => { setAlias(''); setAgregando(true) }}>
          <Plus size={17} /> Mesa
        </button>
      </div>
      <p className="pantalla-sub">Toca una mesa para ver su cuenta.</p>

      {mesas.length === 0 ? (
        <Vacio
          icono={Armchair}
          titulo="Sin mesas todavía"
          detalle="Crea tus mesas con el alias que quieras: «La de la ventana», «VIP 2»…"
        />
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))', gap: 12 }}>
          {mesas.map((mesa, i) => {
            const cuenta = abiertas.find(c => c.mesaId === mesa.id)
            const ocupada = !!cuenta
            const saldo = cuenta
              ? saldoCuenta(items.filter(x => x.cuentaId === cuenta.id), pagos.filter(x => x.cuentaId === cuenta.id))
              : 0
            const porEntregar = cuenta
              ? items.filter(x => x.cuentaId === cuenta.id && x.estado === 'pendiente').length
              : 0
            return (
              <motion.button
                key={mesa.id}
                initial={{ opacity: 0, y: 14 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: Math.min(i * 0.03, 0.3) }}
                whileTap={{ scale: 0.96 }}
                className="tarjeta"
                style={{
                  textAlign: 'left', minHeight: 108,
                  display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
                  borderColor: ocupada ? 'var(--ambar)' : undefined,
                  background: ocupada ? 'var(--ciruela-600)' : undefined,
                }}
                onClick={() => navegar(`/mesas/${mesa.id}`)}
              >
                <div style={{ fontWeight: 700, fontSize: 16.5, lineHeight: 1.2 }}>{mesa.alias}</div>
                <div>
                  {ocupada ? (
                    <>
                      <div className="mono" style={{ fontSize: 19, fontWeight: 700, color: 'var(--ambar)' }}>
                        {dinero(saldo)}
                      </div>
                      {porEntregar > 0 && (
                        <div className="pequeno" style={{ color: 'var(--crema-60)' }}>
                          {porEntregar} por entregar
                        </div>
                      )}
                    </>
                  ) : (
                    <span className="chip chip-neutro">libre</span>
                  )}
                </div>
              </motion.button>
            )
          })}
        </div>
      )}

      <Hoja abierta={agregando} alCerrar={() => setAgregando(false)}>
        <div className="hoja-titulo">Nueva mesa</div>
        <span className="etiqueta-campo">Alias</span>
        <input
          autoFocus
          placeholder="ej. La de la ventana"
          value={alias}
          onChange={e => setAlias(e.target.value)}
          onKeyDown={async e => {
            if (e.key === 'Enter' && alias.trim()) {
              await db.mesas.add({ alias: alias.trim(), orden: mesas.length })
              setAgregando(false)
            }
          }}
        />
        <button
          className="btn btn-primario btn-bloque"
          style={{ marginTop: 14 }}
          disabled={!alias.trim()}
          onClick={async () => {
            await db.mesas.add({ alias: alias.trim(), orden: mesas.length })
            setAgregando(false)
          }}
        >
          Crear mesa
        </button>
      </Hoja>
    </div>
  )
}
