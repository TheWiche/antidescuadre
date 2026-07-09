import { useEffect, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import { ArrowLeft, BadgeCheck, Camera, Landmark, X } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { db } from '../db/db'
import { turnoActivo } from '../logica/cuentas'
import type { Comprobante } from '../db/tipos'
import { dinero, fechaCorta, horaCorta } from '../logica/dinero'
import { Camara } from '../componentes/Camara'
import { Vacio } from '../componentes/Vacio'

// Comprobantes de transferencia: nacen "pendientes de legalizar" y aquí se
// verifican. También se pueden capturar sueltos, sin mesa (captura libre).
export function Comprobantes() {
  const navegar = useNavigate()
  const [pestana, setPestana] = useState<'pendiente' | 'legalizada'>('pendiente')
  const lista = useLiveQuery(
    () => db.comprobantes.where('estado').equals(pestana).reverse().sortBy('fecha'),
    [pestana],
  ) ?? []
  const pendientesTotal = useLiveQuery(() => db.comprobantes.where('estado').equals('pendiente').count(), []) ?? 0
  const turno = useLiveQuery(() => turnoActivo(), [])

  const [camaraAbierta, setCamaraAbierta] = useState(false)
  const [ampliado, setAmpliado] = useState<Comprobante | null>(null)

  return (
    <div className="pantalla">
      <div className="espaciado" style={{ marginBottom: 8 }}>
        <button className="btn btn-fantasma" style={{ padding: '10px 14px' }} onClick={() => navegar('/mas')}>
          <ArrowLeft size={18} />
        </button>
        <h1 style={{ fontSize: 21 }}>Comprobantes</h1>
        <button className="btn btn-cian" style={{ padding: '10px 14px' }} onClick={() => setCamaraAbierta(true)} aria-label="Captura libre">
          <Camera size={18} />
        </button>
      </div>
      <p className="pantalla-sub">Toda transferencia queda aquí hasta legalizarse en barra.</p>

      <div style={{ display: 'flex', background: 'var(--ciruela-900)', borderRadius: 999, padding: 4, marginBottom: 16 }}>
        {([['pendiente', `Pendientes${pendientesTotal ? ` · ${pendientesTotal}` : ''}`], ['legalizada', 'Legalizadas']] as const).map(([valor, texto]) => (
          <button
            key={valor}
            onClick={() => setPestana(valor)}
            style={{ flex: 1, position: 'relative', padding: '10px 0', fontWeight: 600, fontSize: 14.5, color: pestana === valor ? 'var(--cian-tinta)' : 'var(--crema-60)' }}
          >
            {pestana === valor && (
              <motion.span
                layoutId="pestana-comprobantes"
                style={{ position: 'absolute', inset: 0, background: 'var(--cian)', borderRadius: 999 }}
                transition={{ type: 'spring', damping: 30, stiffness: 400 }}
              />
            )}
            <span style={{ position: 'relative' }}>{texto}</span>
          </button>
        ))}
      </div>

      {lista.length === 0 ? (
        <Vacio
          icono={pestana === 'pendiente' ? BadgeCheck : Landmark}
          titulo={pestana === 'pendiente' ? 'Nada pendiente por legalizar' : 'Aún no hay legalizadas'}
          detalle={pestana === 'pendiente' ? 'Todas las transferencias están al día.' : undefined}
        />
      ) : (
        <div className="apilado">
          <AnimatePresence initial={false}>
            {lista.map(c => (
              <TarjetaComprobante
                key={c.id}
                comprobante={c}
                alAmpliar={() => setAmpliado(c)}
              />
            ))}
          </AnimatePresence>
        </div>
      )}

      {/* Captura libre: comprobante sin mesa (flujo 4) */}
      <Camara
        abierta={camaraAbierta}
        titulo="Comprobante suelto"
        alCancelar={() => setCamaraAbierta(false)}
        alCapturar={async blob => {
          await db.comprobantes.add({
            imagen: blob, fecha: Date.now(),
            turnoId: turno?.id ?? null, mesaId: null, aliasMesa: null,
            cuentaId: null, pagoId: null, monto: null,
            estado: 'pendiente',
          })
          setCamaraAbierta(false)
          setPestana('pendiente')
        }}
      />

      {/* Visor a pantalla completa */}
      <AnimatePresence>
        {ampliado && (
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            onClick={() => setAmpliado(null)}
            style={{ position: 'fixed', inset: 0, zIndex: 75, background: 'rgba(12,6,13,0.95)', display: 'flex', flexDirection: 'column' }}
          >
            <div className="espaciado" style={{ padding: 14 }}>
              <span className="tenue pequeno">
                {ampliado.aliasMesa ?? 'Captura libre'} · {fechaCorta(ampliado.fecha)} {horaCorta(ampliado.fecha)}
              </span>
              <button className="btn btn-fantasma" style={{ padding: '9px 13px' }}><X size={17} /></button>
            </div>
            <ImagenComprobante blob={ampliado.imagen} estilo={{ flex: 1, objectFit: 'contain', width: '100%', minHeight: 0, marginBottom: 20 }} />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

function TarjetaComprobante({ comprobante: c, alAmpliar }: {
  comprobante: Comprobante
  alAmpliar: () => void
}) {
  const pendiente = c.estado === 'pendiente'
  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 14 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, x: pendiente ? 80 : -80, transition: { duration: 0.22 } }}
      className="tarjeta horizontal"
      style={{ alignItems: 'stretch' }}
    >
      <button onClick={alAmpliar} style={{ flexShrink: 0 }}>
        <ImagenComprobante
          blob={c.imagen}
          estilo={{ width: 74, height: 74, objectFit: 'cover', borderRadius: 12, display: 'block' }}
        />
      </button>
      <div className="crece" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontWeight: 700 }}>{c.aliasMesa ?? 'Captura libre'}</div>
          <div className="pequeno tenue">{fechaCorta(c.fecha)} · {horaCorta(c.fecha)}</div>
          {c.monto != null && <div className="mono pequeno" style={{ color: 'var(--cian)' }}>{dinero(c.monto)}</div>}
        </div>
        {pendiente ? (
          <motion.button
            whileTap={{ scale: 0.95 }}
            className="btn btn-cian"
            style={{ padding: '9px 16px', alignSelf: 'flex-start', fontSize: 14 }}
            onClick={async () => {
              await db.comprobantes.update(c.id!, { estado: 'legalizada', legalizadaEn: Date.now() })
              if (navigator.vibrate) navigator.vibrate(16)
            }}
          >
            <BadgeCheck size={16} /> Legalizar
          </motion.button>
        ) : (
          <span className="chip chip-menta" style={{ alignSelf: 'flex-start' }}>
            <BadgeCheck size={13} /> legalizada {c.legalizadaEn ? horaCorta(c.legalizadaEn) : ''}
          </span>
        )}
      </div>
    </motion.div>
  )
}

// Convierte el blob guardado en la base a una URL de imagen, con limpieza.
function ImagenComprobante({ blob, estilo }: { blob: Blob; estilo?: React.CSSProperties }) {
  const [url, setUrl] = useState<string | null>(null)
  useEffect(() => {
    const u = URL.createObjectURL(blob)
    setUrl(u)
    return () => URL.revokeObjectURL(u)
  }, [blob])
  if (!url) return <div style={{ ...estilo, background: 'var(--ciruela-900)' }} />
  return <img src={url} alt="Comprobante de transferencia" style={estilo} />
}
