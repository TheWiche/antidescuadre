import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Sunrise } from 'lucide-react'
import { iniciarTurno } from '../logica/cuentas'

// Compuerta de turno: sin turno activo no se opera (regla 1).
export function SinTurno({ mensaje }: { mensaje: string }) {
  const navegar = useNavigate()
  return (
    <div className="centrado" style={{ padding: '56px 24px' }}>
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ type: 'spring', damping: 18 }}
      >
        <Sunrise size={44} strokeWidth={1.5} style={{ color: 'var(--ambar)', marginBottom: 12 }} />
        <h2 style={{ fontSize: 22, marginBottom: 6 }}>El turno aún no empieza</h2>
        <p className="tenue" style={{ marginTop: 0, marginBottom: 22 }}>{mensaje}</p>
        <button
          className="btn btn-primario"
          onClick={async () => { await iniciarTurno(); navegar('/') }}
        >
          Iniciar turno
        </button>
      </motion.div>
    </div>
  )
}
