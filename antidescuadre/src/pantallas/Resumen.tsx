import { useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import {
  Banknote, ClipboardList, Landmark, Moon, ReceiptText, Sunrise,
} from 'lucide-react'
import { db, obtenerAjustes } from '../db/db'
import type { Pago, Turno } from '../db/tipos'
import { dinero, fechaCorta, horaCorta, redondear } from '../logica/dinero'
import {
  cerrarTurno, iniciarTurno, mesasConSaldoPendiente, saldoCuenta, type MesaConSaldo,
  turnoActivo,
} from '../logica/cuentas'
import { Hoja } from '../componentes/Hoja'
import { Confirmar } from '../componentes/Confirmar'

function resumenPagos(pagos: Pago[]) {
  return {
    total: redondear(pagos.reduce((s, p) => s + p.monto, 0)),
    efectivo: redondear(pagos.reduce((s, p) => s + p.efectivo, 0)),
    transferencia: redondear(pagos.reduce((s, p) => s + p.transferencia, 0)),
  }
}

export function Resumen() {
  const navegar = useNavigate()
  const turno = useLiveQuery(() => turnoActivo(), [])
  const ajustes = useLiveQuery(() => obtenerAjustes(), [])
  const cargando = turno === undefined

  return (
    <div className="pantalla">
      <p className="pantalla-sub" style={{ marginBottom: 2 }}>{ajustes?.nombreNegocio ?? ''}</p>
      <h1 className="pantalla-titulo" style={{ marginBottom: 18 }}>AntiDescuadre</h1>
      {cargando ? null : turno ? (
        <TurnoActivo turno={turno} />
      ) : (
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }}>
          <div className="tarjeta centrado" style={{ padding: '36px 20px', marginBottom: 20 }}>
            <Sunrise size={42} strokeWidth={1.5} style={{ color: 'var(--ambar)', marginBottom: 10 }} />
            <h2 style={{ fontSize: 21, marginBottom: 4 }}>Empieza la jornada</h2>
            <p className="tenue" style={{ margin: '0 0 20px' }}>
              El turno es el punto de partida: ventas, mesas y cobros quedan asociados a él.
            </p>
            <button
              className="btn btn-primario btn-bloque"
              style={{ fontSize: 17, padding: '16px 22px' }}
              onClick={async () => { await iniciarTurno(); navegar('/mesas') }}
            >
              Iniciar turno
            </button>
          </div>
          <Historial />
        </motion.div>
      )}
    </div>
  )
}

function TurnoActivo({ turno }: { turno: Turno }) {
  const turnoId = turno.id!
  const pagos = useLiveQuery(() => db.pagos.where({ turnoId }).toArray(), [turnoId]) ?? []
  const abiertas = useLiveQuery(
    () => db.cuentas.where({ turnoId }).filter(c => c.estado === 'abierta').toArray(), [turnoId],
  ) ?? []
  const mesas = useLiveQuery(() => db.mesas.toArray(), []) ?? []
  const comprobantesPend = useLiveQuery(() => db.comprobantes.where('estado').equals('pendiente').count(), []) ?? 0

  const idsAbiertas = abiertas.map(c => c.id!)
  const itemsAbiertos = useLiveQuery(async () => {
    if (idsAbiertas.length === 0) return []
    return db.items.where('cuentaId').anyOf(idsAbiertas).toArray()
  }, [idsAbiertas.join(',')]) ?? []
  const pagosAbiertos = useLiveQuery(async () => {
    if (idsAbiertas.length === 0) return []
    return db.pagos.where('cuentaId').anyOf(idsAbiertas).toArray()
  }, [idsAbiertas.join(',')]) ?? []

  const { total, efectivo, transferencia } = resumenPagos(pagos)
  const porEntregar = itemsAbiertos.filter(i => i.estado === 'pendiente').length

  const mesasPendientes = useMemo(() => {
    return abiertas.map(c => {
      const items = itemsAbiertos.filter(i => i.cuentaId === c.id)
      const suyos = pagosAbiertos.filter(p => p.cuentaId === c.id)
      const saldo = saldoCuenta(items, suyos)
      const alias = c.mesaId != null
        ? (mesas.find(m => m.id === c.mesaId)?.alias ?? 'Mesa')
        : 'Venta directa'
      return { cuenta: c, alias, saldo }
    }).filter(x => x.saldo > 0)
  }, [abiertas, itemsAbiertos, pagosAbiertos, mesas])

  const totalPendiente = redondear(mesasPendientes.reduce((s, m) => s + m.saldo, 0))

  const [confirmandoCierre, setConfirmandoCierre] = useState(false)
  const [bloqueos, setBloqueos] = useState<MesaConSaldo[] | null>(null)

  async function intentarCerrar() {
    const pendientes = await mesasConSaldoPendiente(turnoId)
    if (pendientes.length > 0) setBloqueos(pendientes)
    else setConfirmandoCierre(true)
  }

  return (
    <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="apilado">
      <div className="espaciado">
        <span className="chip chip-menta">Turno activo · desde {horaCorta(turno.inicio)}</span>
        <button className="btn btn-fantasma pequeno" style={{ padding: '9px 14px' }} onClick={intentarCerrar}>
          <Moon size={15} /> Cerrar turno
        </button>
      </div>

      {/* Cobrado del turno */}
      <div className="tarjeta">
        <span className="etiqueta-campo">Cobrado en el turno</span>
        <div className="mono" style={{ fontSize: 38, fontWeight: 700, fontFamily: 'var(--f-display)' }}>
          {dinero(total)}
        </div>
        <div className="horizontal" style={{ marginTop: 8, flexWrap: 'wrap' }}>
          <span className="chip chip-ambar"><Banknote size={14} /> {dinero(efectivo)} efectivo</span>
          <span className="chip chip-cian"><Landmark size={14} /> {dinero(transferencia)} transferencia</span>
        </div>
      </div>

      {/* Pendiente por cobrar */}
      <div className="tarjeta">
        <div className="espaciado">
          <span className="etiqueta-campo" style={{ margin: 0 }}>Pendiente por cobrar</span>
          <span className="mono" style={{ fontSize: 20, fontWeight: 700, color: totalPendiente > 0 ? 'var(--ambar)' : 'var(--menta)' }}>
            {dinero(totalPendiente)}
          </span>
        </div>
        {mesasPendientes.length > 0 && (
          <div style={{ marginTop: 6 }}>
            {mesasPendientes.map(m => (
              <Link
                key={m.cuenta.id}
                to={m.cuenta.mesaId != null ? `/mesas/${m.cuenta.mesaId}` : '/mesas'}
                className="fila"
                style={{ textDecoration: 'none', color: 'inherit' }}
              >
                <span className="crece" style={{ fontWeight: 600 }}>{m.alias}</span>
                <span className="mono">{dinero(m.saldo)}</span>
              </Link>
            ))}
          </div>
        )}
      </div>

      {/* Accesos con contadores */}
      <div className="horizontal" style={{ alignItems: 'stretch' }}>
        <Link to="/pendientes" className="tarjeta crece" style={{ textDecoration: 'none', color: 'inherit' }}>
          <ClipboardList size={20} style={{ color: porEntregar > 0 ? 'var(--ambar)' : 'var(--crema-38)' }} />
          <div className="mono" style={{ fontSize: 24, fontWeight: 700 }}>{porEntregar}</div>
          <div className="pequeno tenue">por entregar</div>
        </Link>
        <Link to="/mas/comprobantes" className="tarjeta crece" style={{ textDecoration: 'none', color: 'inherit' }}>
          <Landmark size={20} style={{ color: comprobantesPend > 0 ? 'var(--cian)' : 'var(--crema-38)' }} />
          <div className="mono" style={{ fontSize: 24, fontWeight: 700 }}>{comprobantesPend}</div>
          <div className="pequeno tenue">por legalizar</div>
        </Link>
      </div>

      <Historial />

      {/* Cierre bloqueado por mesas con saldo (regla 1b) */}
      <Hoja abierta={bloqueos !== null} alCerrar={() => setBloqueos(null)}>
        <div className="hoja-titulo">Aún no puedes cerrar</div>
        <p className="tenue" style={{ marginTop: -6 }}>
          Hay mesas con saldo pendiente. Cóbralas (o déjalas en $0) para cerrar el turno.
        </p>
        {(bloqueos ?? []).map((b, i) => (
          <div className="fila" key={i}>
            <span className="crece" style={{ fontWeight: 600 }}>{b.alias}</span>
            <span className="mono" style={{ color: 'var(--ambar)' }}>{dinero(b.saldo)}</span>
          </div>
        ))}
        <button className="btn btn-fantasma btn-bloque" style={{ marginTop: 14 }} onClick={() => setBloqueos(null)}>
          Entendido
        </button>
      </Hoja>

      <Confirmar
        abierta={confirmandoCierre}
        titulo="¿Cerrar el turno?"
        detalle={`Cobrado: ${dinero(total)} (${dinero(efectivo)} efectivo · ${dinero(transferencia)} transferencia).`}
        textoConfirmar="Cerrar turno"
        alConfirmar={async () => { await cerrarTurno(turnoId); setConfirmandoCierre(false) }}
        alCancelar={() => setConfirmandoCierre(false)}
      />
    </motion.div>
  )
}

// Historial de turnos cerrados: el dashboard se puede mirar por turno y fecha.
function Historial() {
  const cerrados = useLiveQuery(
    () => db.turnos.where('estado').equals('cerrado').reverse().sortBy('inicio'), [],
  ) ?? []
  const [abierto, setAbierto] = useState<Turno | null>(null)
  const pagosDe = useLiveQuery(async () => {
    if (!abierto) return []
    return db.pagos.where({ turnoId: abierto.id! }).toArray()
  }, [abierto?.id]) ?? []

  if (cerrados.length === 0) return null
  const r = resumenPagos(pagosDe)

  return (
    <div className="tarjeta">
      <span className="etiqueta-campo">Turnos anteriores</span>
      {cerrados.slice(0, 14).map(t => (
        <button key={t.id} className="fila" style={{ width: '100%', textAlign: 'left' }} onClick={() => setAbierto(t)}>
          <ReceiptText size={17} style={{ color: 'var(--crema-38)' }} />
          <span className="crece" style={{ fontWeight: 600 }}>{fechaCorta(t.inicio)}</span>
          <span className="pequeno muy-tenue mono">{horaCorta(t.inicio)}–{t.fin ? horaCorta(t.fin) : ''}</span>
        </button>
      ))}

      <Hoja abierta={abierto !== null} alCerrar={() => setAbierto(null)}>
        {abierto && (
          <>
            <div className="hoja-titulo">{fechaCorta(abierto.inicio)}</div>
            <p className="tenue pequeno" style={{ marginTop: -8 }}>
              {horaCorta(abierto.inicio)} – {abierto.fin ? horaCorta(abierto.fin) : '—'}
            </p>
            <div className="mono" style={{ fontSize: 34, fontWeight: 700, fontFamily: 'var(--f-display)' }}>
              {dinero(r.total)}
            </div>
            <div className="horizontal" style={{ marginTop: 8, flexWrap: 'wrap' }}>
              <span className="chip chip-ambar"><Banknote size={14} /> {dinero(r.efectivo)} efectivo</span>
              <span className="chip chip-cian"><Landmark size={14} /> {dinero(r.transferencia)} transferencia</span>
            </div>
            <div className="pequeno tenue" style={{ marginTop: 12 }}>{pagosDe.length} cobros registrados</div>
          </>
        )}
      </Hoja>
    </div>
  )
}
