import { Route, Routes, useLocation, useNavigate } from 'react-router-dom'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import {
  Beer, ClipboardList, LayoutGrid, Menu, ReceiptText, Landmark,
} from 'lucide-react'
import { db } from './db/db'
import { Resumen } from './pantallas/Resumen'
import { Mesas } from './pantallas/Mesas'
import { MesaDetalle } from './pantallas/MesaDetalle'
import { Vender } from './pantallas/Vender'
import { Pendientes } from './pantallas/Pendientes'
import { Mas } from './pantallas/Mas'
import { Catalogo } from './pantallas/Catalogo'
import { Comprobantes } from './pantallas/Comprobantes'
import { Ajustes } from './pantallas/Ajustes'

const PESTANAS = [
  { ruta: '/', etiqueta: 'Turno', Icono: ReceiptText },
  { ruta: '/mesas', etiqueta: 'Mesas', Icono: LayoutGrid },
  { ruta: '/vender', etiqueta: 'Vender', Icono: Beer },
  { ruta: '/pendientes', etiqueta: 'Por entregar', Icono: ClipboardList },
  { ruta: '/mas', etiqueta: 'Más', Icono: Menu },
]

export default function App() {
  const ubicacion = useLocation()
  const navegar = useNavigate()

  const pendientesLegalizar = useLiveQuery(
    () => db.comprobantes.where('estado').equals('pendiente').count(), [],
  ) ?? 0

  const raiz = '/' + (ubicacion.pathname.split('/')[1] ?? '')

  return (
    <>
      <AnimatePresence mode="wait" initial={false}>
        <motion.div
          key={ubicacion.pathname}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -6 }}
          transition={{ duration: 0.16, ease: 'easeOut' }}
        >
          <Routes location={ubicacion}>
            <Route path="/" element={<Resumen />} />
            <Route path="/mesas" element={<Mesas />} />
            <Route path="/mesas/:id" element={<MesaDetalle />} />
            <Route path="/vender" element={<Vender />} />
            <Route path="/pendientes" element={<Pendientes />} />
            <Route path="/mas" element={<Mas />} />
            <Route path="/mas/catalogo" element={<Catalogo />} />
            <Route path="/mas/comprobantes" element={<Comprobantes />} />
            <Route path="/mas/ajustes" element={<Ajustes />} />
          </Routes>
        </motion.div>
      </AnimatePresence>

      {/* Notificación obligatoria y no descartable de comprobantes pendientes
          (regla 9): visible siempre que exista al menos uno, sin bloquear. */}
      <AnimatePresence>
        {pendientesLegalizar > 0 && ubicacion.pathname !== '/mas/comprobantes' && (
          <motion.div
            className="cinta-legalizar"
            initial={{ y: 60, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 60, opacity: 0 }}
            transition={{ type: 'spring', damping: 26, stiffness: 300 }}
          >
            <button onClick={() => navegar('/mas/comprobantes')}>
              <Landmark size={18} className="pulsa" />
              <span className="crece" style={{ textAlign: 'left' }}>
                {pendientesLegalizar === 1
                  ? '1 transferencia pendiente por legalizar'
                  : `${pendientesLegalizar} transferencias pendientes por legalizar`}
              </span>
              <span style={{ fontWeight: 800 }}>Ver</span>
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      <nav className="tabbar">
        <div className="tabbar-inner">
          {PESTANAS.map(({ ruta, etiqueta, Icono }) => {
            const activa = raiz === ruta || (ruta === '/' && ubicacion.pathname === '/')
            return (
              <button key={ruta} className={`tab ${activa ? 'activa' : ''}`} onClick={() => navegar(ruta)}>
                {activa && (
                  <motion.span
                    layoutId="tab-indicador"
                    style={{
                      position: 'absolute', top: 0, width: 34, height: 3,
                      borderRadius: 99, background: 'var(--ambar)',
                    }}
                  />
                )}
                <Icono size={21} strokeWidth={activa ? 2.4 : 2} />
                {etiqueta}
              </button>
            )
          })}
        </div>
      </nav>
    </>
  )
}
