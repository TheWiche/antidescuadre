import type { LucideIcon } from 'lucide-react'

interface Props {
  icono: LucideIcon
  titulo: string
  detalle?: string
}

export function Vacio({ icono: Icono, titulo, detalle }: Props) {
  return (
    <div className="centrado" style={{ padding: '48px 24px', color: 'var(--crema-38)' }}>
      <Icono size={40} strokeWidth={1.5} style={{ marginBottom: 12 }} />
      <div style={{ fontWeight: 600, color: 'var(--crema-60)', marginBottom: 4 }}>{titulo}</div>
      {detalle && <div className="pequeno">{detalle}</div>}
    </div>
  )
}
