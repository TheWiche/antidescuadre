import { Link } from 'react-router-dom'
import { useLiveQuery } from 'dexie-react-hooks'
import { BookOpen, ChevronRight, Landmark, Settings } from 'lucide-react'
import { db } from '../db/db'

export function Mas() {
  const productos = useLiveQuery(() => db.productos.count(), []) ?? 0
  const pendientes = useLiveQuery(() => db.comprobantes.where('estado').equals('pendiente').count(), []) ?? 0

  const opciones = [
    {
      ruta: '/mas/catalogo', Icono: BookOpen, titulo: 'Catálogo',
      detalle: productos > 0 ? `${productos} producto${productos !== 1 ? 's' : ''}` : 'Crea tus productos y categorías',
      color: 'var(--ambar)',
    },
    {
      ruta: '/mas/comprobantes', Icono: Landmark, titulo: 'Comprobantes',
      detalle: pendientes > 0 ? `${pendientes} pendiente${pendientes !== 1 ? 's' : ''} por legalizar` : 'Transferencias y legalización',
      color: 'var(--cian)', alerta: pendientes > 0,
    },
    {
      ruta: '/mas/ajustes', Icono: Settings, titulo: 'Ajustes',
      detalle: 'Negocio, alertas, exportar/importar',
      color: 'var(--crema-60)',
    },
  ]

  return (
    <div className="pantalla">
      <h1 className="pantalla-titulo">Más</h1>
      <p className="pantalla-sub">Configuración y herramientas del negocio.</p>
      <div className="apilado">
        {opciones.map(({ ruta, Icono, titulo, detalle, color, alerta }) => (
          <Link key={ruta} to={ruta} className="tarjeta horizontal" style={{ textDecoration: 'none', color: 'inherit', padding: '16px' }}>
            <Icono size={22} style={{ color, flexShrink: 0 }} className={alerta ? 'pulsa' : undefined} />
            <div className="crece">
              <div style={{ fontWeight: 700, fontSize: 16.5 }}>{titulo}</div>
              <div className="pequeno tenue">{detalle}</div>
            </div>
            <ChevronRight size={18} style={{ color: 'var(--crema-38)' }} />
          </Link>
        ))}
      </div>
    </div>
  )
}
