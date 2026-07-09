import { AnimatePresence, motion } from 'framer-motion'
import type { ReactNode } from 'react'

interface Props {
  abierta: boolean
  alCerrar: () => void
  children: ReactNode
}

// Hoja inferior (bottom sheet): la superficie modal estándar de la app.
// Se cierra tocando el velo o arrastrando hacia abajo.
export function Hoja({ abierta, alCerrar, children }: Props) {
  return (
    <AnimatePresence>
      {abierta && (
        <>
          <motion.div
            className="velo"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.18 }}
            onClick={alCerrar}
          />
          <motion.div
            className="hoja"
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 32, stiffness: 380 }}
            drag="y"
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={{ top: 0, bottom: 0.6 }}
            onDragEnd={(_, info) => {
              if (info.offset.y > 90 || info.velocity.y > 500) alCerrar()
            }}
          >
            <div className="hoja-asa" />
            <div className="hoja-cuerpo">{children}</div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
