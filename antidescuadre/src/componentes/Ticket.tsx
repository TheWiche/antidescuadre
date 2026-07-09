import type { ReactNode } from 'react'
import { motion } from 'framer-motion'

// El elemento firma de AntiDescuadre: papel de comanda troquelado.
// Las líneas nuevas "se imprimen" entrando con resorte desde arriba.

export function Ticket({ children }: { children: ReactNode }) {
  return <div className="ticket">{children}</div>
}

export function LineaImpresa({ children, id }: { children: ReactNode; id: string | number }) {
  return (
    <motion.div
      key={id}
      layout
      initial={{ opacity: 0, y: -14, scaleY: 0.6 }}
      animate={{ opacity: 1, y: 0, scaleY: 1 }}
      exit={{ opacity: 0, height: 0 }}
      transition={{ type: 'spring', damping: 24, stiffness: 420 }}
      style={{ transformOrigin: 'top' }}
    >
      {children}
    </motion.div>
  )
}
