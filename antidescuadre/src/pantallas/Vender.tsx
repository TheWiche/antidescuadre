import { useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import { Banknote, Beer, Landmark, Zap } from 'lucide-react'
import { db, obtenerAjustes } from '../db/db'
import type { Cuenta, ItemCuenta, Pago } from '../db/tipos'
import { dinero, horaCorta } from '../logica/dinero'
import { agregarTanda, turnoActivo } from '../logica/cuentas'
import { SelectorProductos } from '../componentes/SelectorProductos'
import { FlujoCobro } from '../componentes/FlujoCobro'
import { FacturaVista } from '../componentes/FacturaVista'
import { SinTurno } from '../componentes/SinTurno'
import { Hoja } from '../componentes/Hoja'
import { Vacio } from '../componentes/Vacio'

// Venta directa (barra/caja): se pide y se cobra en el momento,
// sin cuenta persistente de mesa.
export function Vender() {
  const turno = useLiveQuery(() => turnoActivo(), [])
  const ajustes = useLiveQuery(() => obtenerAjustes(), [])
  const ventas = useLiveQuery(
    () => turno?.id
      ? db.cuentas.where({ turnoId: turno.id }).filter(c => c.esDirecta && c.estado === 'cerrada').reverse().sortBy('abiertaEn')
      : Promise.resolve([] as Cuenta[]),
    [turno?.id],
  ) ?? []
  const pagos = useLiveQuery(
    () => turno?.id ? db.pagos.where({ turnoId: turno.id }).toArray() : Promise.resolve([] as Pago[]),
    [turno?.id],
  ) ?? []

  const [selectorAbierto, setSelectorAbierto] = useState(false)
  const [cuentaCobrando, setCuentaCobrando] = useState<number | null>(null)
  const [exito, setExito] = useState(false)
  const [facturaDe, setFacturaDe] = useState<number | null>(null)

  const itemsFactura = useLiveQuery(
    () => facturaDe ? db.items.where({ cuentaId: facturaDe }).toArray() : Promise.resolve([] as ItemCuenta[]),
    [facturaDe],
  ) ?? []

  if (turno === undefined) return <div className="pantalla" />
  if (!turno) {
    return (
      <div className="pantalla">
        <h1 className="pantalla-titulo">Venta directa</h1>
        <SinTurno mensaje="Inicia el turno para vender en barra o caja." />
      </div>
    )
  }

  return (
    <div className="pantalla">
      <h1 className="pantalla-titulo">Venta directa</h1>
      <p className="pantalla-sub">Barra o caja: se pide y se cobra al momento.</p>

      <motion.button
        whileTap={{ scale: 0.97 }}
        className="btn btn-primario btn-bloque"
        style={{ fontSize: 18, padding: '20px 22px', marginBottom: 20 }}
        onClick={() => setSelectorAbierto(true)}
      >
        <Zap size={21} /> Nueva venta
      </motion.button>

      {ventas.length === 0 ? (
        <Vacio icono={Beer} titulo="Aún no hay ventas directas en este turno" />
      ) : (
        <div className="tarjeta" style={{ padding: '4px 14px' }}>
          {ventas.map(v => {
            const pago = pagos.filter(p => p.cuentaId === v.id)
            const total = pago.reduce((s, p) => s + p.monto, 0)
            const ef = pago.reduce((s, p) => s + p.efectivo, 0)
            const tr = pago.reduce((s, p) => s + p.transferencia, 0)
            return (
              <button key={v.id} className="fila" style={{ width: '100%', textAlign: 'left' }} onClick={() => setFacturaDe(v.id!)}>
                <span className="mono muy-tenue pequeno">{horaCorta(v.abiertaEn)}</span>
                <span className="crece mono" style={{ fontWeight: 700 }}>{dinero(total)}</span>
                {ef > 0 && <Banknote size={15} style={{ color: 'var(--ambar)' }} />}
                {tr > 0 && <Landmark size={15} style={{ color: 'var(--cian)' }} />}
              </button>
            )
          })}
        </div>
      )}

      <SelectorProductos
        abierta={selectorAbierto}
        titulo="Venta directa"
        textoConfirmar="Cobrar"
        alCerrar={() => setSelectorAbierto(false)}
        alConfirmar={async lineas => {
          const cuentaId = await db.cuentas.add({
            mesaId: null, turnoId: turno.id!, estado: 'abierta',
            abiertaEn: Date.now(), esDirecta: true,
          })
          await agregarTanda(cuentaId, lineas, true)
          setSelectorAbierto(false)
          setCuentaCobrando(cuentaId)
        }}
      />

      {cuentaCobrando !== null && (
        <FlujoCobro
          abierta
          cuentaId={cuentaCobrando}
          turnoId={turno.id!}
          mesaId={null}
          mesaAlias="Venta directa"
          soloTotal
          alCerrar={async () => {
            // Venta abandonada sin ningún cobro: se descarta
            const suyos = await db.pagos.where({ cuentaId: cuentaCobrando }).count()
            if (suyos === 0) {
              await db.items.where({ cuentaId: cuentaCobrando }).delete()
              await db.cuentas.delete(cuentaCobrando)
            }
            setCuentaCobrando(null)
          }}
          alCuentaSaldada={() => {
            setCuentaCobrando(null)
            setExito(true)
            setTimeout(() => setExito(false), 1100)
          }}
        />
      )}

      <Hoja abierta={facturaDe !== null} alCerrar={() => setFacturaDe(null)}>
        <FacturaVista
          nombreNegocio={ajustes?.nombreNegocio ?? 'Mi bar'}
          alias="Venta directa"
          fecha={ventas.find(v => v.id === facturaDe)?.abiertaEn ?? Date.now()}
          items={itemsFactura}
        />
      </Hoja>

      <AnimatePresence>
        {exito && (
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            style={{ position: 'fixed', inset: 0, zIndex: 80, display: 'grid', placeItems: 'center', background: 'rgba(12,6,13,0.75)' }}
          >
            <motion.div
              initial={{ scale: 0.4, rotate: -14 }}
              animate={{ scale: 1, rotate: -8 }}
              transition={{ type: 'spring', damping: 12, stiffness: 260 }}
              style={{
                border: '4px solid var(--menta)', color: 'var(--menta)', borderRadius: 14,
                padding: '10px 26px', fontFamily: 'var(--f-display)', fontWeight: 800,
                fontSize: 30, letterSpacing: '0.06em', textTransform: 'uppercase',
              }}
            >
              Venta cobrada
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
