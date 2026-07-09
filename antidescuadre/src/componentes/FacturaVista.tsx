import { useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { Share2 } from 'lucide-react'
import type { ItemCuenta } from '../db/tipos'
import { dinero, horaCorta, fechaLarga } from '../logica/dinero'
import { totalItems } from '../logica/cuentas'
import { facturaAgrupada, facturaCronologica, facturaComoTexto } from '../logica/factura'
import { Ticket } from './Ticket'

interface Props {
  nombreNegocio: string
  alias: string
  fecha: number
  items: ItemCuenta[]
}

// Factura de una cuenta: mismos datos, dos lentes (cronológica / agrupada).
// El cambio entre modos es un cruce suave sobre el mismo papel, no otra pantalla.
export function FacturaVista({ nombreNegocio, alias, fecha, items }: Props) {
  const [modo, setModo] = useState<'cronologica' | 'agrupada'>('cronologica')
  const [copiado, setCopiado] = useState(false)

  async function compartir() {
    const texto = facturaComoTexto(nombreNegocio, alias, items, modo)
    if (navigator.share) {
      try { await navigator.share({ title: `Cuenta · ${alias}`, text: texto }) } catch { /* cancelado */ }
    } else {
      await navigator.clipboard.writeText(texto)
      setCopiado(true)
      setTimeout(() => setCopiado(false), 1600)
    }
  }

  return (
    <div className="apilado">
      {/* Selector de modo */}
      <div style={{ display: 'flex', background: 'var(--ciruela-900)', borderRadius: 999, padding: 4 }}>
        {([['cronologica', 'Cronológica'], ['agrupada', 'Agrupada']] as const).map(([valor, texto]) => (
          <button
            key={valor}
            onClick={() => setModo(valor)}
            style={{ flex: 1, position: 'relative', padding: '10px 0', fontWeight: 600, fontSize: 14.5, color: modo === valor ? 'var(--ambar-tinta)' : 'var(--crema-60)' }}
          >
            {modo === valor && (
              <motion.span
                layoutId="modo-factura"
                style={{ position: 'absolute', inset: 0, background: 'var(--ambar)', borderRadius: 999 }}
                transition={{ type: 'spring', damping: 30, stiffness: 400 }}
              />
            )}
            <span style={{ position: 'relative' }}>{texto}</span>
          </button>
        ))}
      </div>

      <Ticket>
        <div className="ticket-cabecera">
          <div className="ticket-titulo">{nombreNegocio}</div>
          <div className="ticket-meta">{alias} · {fechaLarga(fecha)}</div>
        </div>
        <AnimatePresence mode="wait">
          <motion.div
            key={modo}
            initial={{ opacity: 0, y: 6 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -6 }}
            transition={{ duration: 0.15 }}
          >
            {modo === 'cronologica' ? (
              facturaCronologica(items).map(tanda => (
                <div key={tanda.hora}>
                  <div className="ticket-hora">{horaCorta(tanda.hora)}</div>
                  {tanda.lineas.map((l, i) => (
                    <div className="ticket-linea" key={i}>
                      <span>{l.cantidad}×</span>
                      <span className="nombre">{l.texto}</span>
                      <span className="precio">{dinero(l.total)}</span>
                    </div>
                  ))}
                </div>
              ))
            ) : (
              facturaAgrupada(items).map((l, i) => (
                <div className="ticket-linea" key={i}>
                  <span className="nombre">{l.texto} ×{l.cantidad}</span>
                  <span className="ticket-meta">{dinero(l.unitario)} c/u</span>
                  <span className="precio">{dinero(l.total)}</span>
                </div>
              ))
            )}
          </motion.div>
        </AnimatePresence>
        <div className="ticket-total">
          <span>TOTAL</span>
          <span>{dinero(totalItems(items))}</span>
        </div>
        <div className="ticket-nota">¡gracias por venir!</div>
      </Ticket>

      <button className="btn btn-fantasma btn-bloque" onClick={compartir}>
        <Share2 size={17} /> {copiado ? '¡Copiada!' : 'Compartir factura'}
      </button>
    </div>
  )
}
