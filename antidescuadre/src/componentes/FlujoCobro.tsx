import { useEffect, useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import { ArrowLeft, Banknote, Check, Landmark, Minus, Plus, UserRound, X } from 'lucide-react'
import { db } from '../db/db'
import type { ItemCuenta } from '../db/tipos'
import { dinero, leerMonto, redondear } from '../logica/dinero'
import { cerrarCuenta, etiquetaVariantes, saldoCuenta, totalItem, totalPagado } from '../logica/cuentas'
import { Camara } from './Camara'

type Modo = 'elegir' | 'todo' | 'partes' | 'consumo'

interface Props {
  abierta: boolean
  cuentaId: number
  turnoId: number
  mesaId: number | null
  mesaAlias: string
  soloTotal?: boolean // venta directa: cobro inmediato sin división
  alCerrar: () => void
  alCuentaSaldada: () => void
}

interface ParteEnCurso {
  etiqueta: string
  monto: number
}

// Flujo de cobro: una cuenta se cobra completa o dividida por partes
// (iguales o manuales) o por consumo real. Cada parte puede combinar
// efectivo y transferencia; toda transferencia exige foto de comprobante.
export function FlujoCobro({ abierta, cuentaId, turnoId, mesaId, mesaAlias, soloTotal, alCerrar, alCuentaSaldada }: Props) {
  const items = useLiveQuery(() => db.items.where({ cuentaId }).toArray(), [cuentaId]) ?? []
  const pagos = useLiveQuery(() => db.pagos.where({ cuentaId }).toArray(), [cuentaId]) ?? []
  const saldo = saldoCuenta(items, pagos)
  const pagado = totalPagado(pagos)

  const [modo, setModo] = useState<Modo>('elegir')
  const [parteActiva, setParteActiva] = useState<ParteEnCurso | null>(null)

  useEffect(() => {
    if (abierta) { setModo(soloTotal ? 'todo' : 'elegir'); setParteActiva(null) }
  }, [abierta, soloTotal])

  // En "cobrar todo" la parte se deriva del saldo en vivo (no se congela),
  // así siempre refleja los ítems ya cargados.
  const parteMostrada = parteActiva
    ?? (modo === 'todo' && saldo > 0 ? { etiqueta: 'Cuenta completa', monto: saldo } : null)

  async function registrarPago(datos: {
    etiqueta: string; monto: number; efectivo: number; transferencia: number
    recibido?: number; vuelto?: number; comprobante?: Blob
  }) {
    const pagoId = await db.pagos.add({
      cuentaId, turnoId,
      etiqueta: datos.etiqueta,
      monto: datos.monto,
      efectivo: datos.efectivo,
      transferencia: datos.transferencia,
      recibido: datos.recibido,
      vuelto: datos.vuelto,
      creadoEn: Date.now(),
    })
    if (datos.comprobante) {
      await db.comprobantes.add({
        imagen: datos.comprobante,
        fecha: Date.now(),
        turnoId, mesaId, aliasMesa: mesaId != null ? mesaAlias : null,
        cuentaId, pagoId,
        monto: datos.transferencia,
        estado: 'pendiente',
      })
    }
    setParteActiva(null)
    const nuevoSaldo = redondear(saldo - datos.monto)
    if (nuevoSaldo <= 0) {
      await cerrarCuenta(cuentaId)
      alCuentaSaldada()
    } else if (modo === 'todo' && !soloTotal) {
      setModo('elegir')
    }
  }

  return (
    <AnimatePresence>
      {abierta && (
        <motion.div
          initial={{ y: '100%' }}
          animate={{ y: 0 }}
          exit={{ y: '100%' }}
          transition={{ type: 'spring', damping: 32, stiffness: 320 }}
          style={{ position: 'fixed', inset: 0, zIndex: 62, background: 'var(--ciruela-800)', overflowY: 'auto' }}
        >
          <div style={{ maxWidth: 560, margin: '0 auto', padding: '14px 16px calc(30px + var(--safe-b))' }}>
            <div className="espaciado" style={{ marginBottom: 14 }}>
              <button
                className="btn btn-fantasma"
                style={{ padding: '10px 14px' }}
                aria-label="Volver"
                onClick={() => {
                  if (parteActiva && !soloTotal && modo !== 'todo') setParteActiva(null)
                  else if (modo !== 'elegir' && !soloTotal) { setParteActiva(null); setModo('elegir') }
                  else alCerrar()
                }}
              >
                <ArrowLeft size={18} />
              </button>
              <h2 style={{ fontSize: 19 }}>Cobrar · {mesaAlias}</h2>
              <div style={{ width: 46 }} />
            </div>

            {/* Saldo grande */}
            <div className="centrado" style={{ marginBottom: 18 }}>
              <div className="muy-tenue pequeno" style={{ letterSpacing: '0.08em', textTransform: 'uppercase' }}>Por cobrar</div>
              <motion.div
                key={saldo}
                initial={{ scale: 1.05 }}
                animate={{ scale: 1 }}
                className="mono"
                style={{ fontSize: 42, fontWeight: 700, fontFamily: 'var(--f-display)' }}
              >
                {dinero(saldo)}
              </motion.div>
              {pagado > 0 && (
                <span className="chip chip-menta">ya pagado {dinero(pagado)}</span>
              )}
            </div>

            {parteMostrada ? (
              <FormularioParte
                clave={parteMostrada.etiqueta + parteMostrada.monto}
                etiqueta={parteMostrada.etiqueta}
                montoInicial={parteMostrada.monto}
                maximo={saldo}
                alConfirmar={registrarPago}
                alCancelar={() => {
                  setParteActiva(null)
                  if (modo === 'todo') { if (soloTotal) alCerrar(); else setModo('elegir') }
                }}
              />
            ) : modo === 'elegir' ? (
              <div className="apilado">
                <OpcionModo titulo="Cobrar todo" detalle="La cuenta completa de una vez" onClick={() => setModo('todo')} />
                <OpcionModo titulo="Dividir en partes" detalle="Partes iguales o montos a mano" onClick={() => setModo('partes')} />
                <OpcionModo titulo="Por consumo" detalle="Cada quien paga lo que tomó" onClick={() => setModo('consumo')} />
              </div>
            ) : modo === 'partes' ? (
              <DivisionPorPartes saldo={saldo} alCobrarParte={(p) => setParteActiva(p)} />
            ) : modo === 'consumo' ? (
              <DivisionPorConsumo
                items={items}
                alCobrarPersona={(nombre, monto) => setParteActiva({ etiqueta: nombre, monto })}
              />
            ) : null}
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

function OpcionModo({ titulo, detalle, onClick }: { titulo: string; detalle: string; onClick: () => void }) {
  return (
    <motion.button whileTap={{ scale: 0.97 }} className="tarjeta" style={{ textAlign: 'left' }} onClick={onClick}>
      <div style={{ fontWeight: 700, fontSize: 17 }}>{titulo}</div>
      <div className="tenue pequeno">{detalle}</div>
    </motion.button>
  )
}

// ---------- División por partes (iguales o manuales) ----------

function DivisionPorPartes({ saldo, alCobrarParte }: {
  saldo: number
  alCobrarParte: (p: ParteEnCurso) => void
}) {
  const [n, setN] = useState(2)
  const [manuales, setManuales] = useState<Record<number, string>>({})

  const partes = useMemo(() => {
    const base = Math.floor((saldo / n) * 100) / 100
    return Array.from({ length: n }, (_, i) => {
      const manual = manuales[i]
      if (manual !== undefined) return leerMonto(manual)
      // la última parte absorbe el residuo del redondeo
      return i === n - 1 ? redondear(saldo - base * (n - 1)) : base
    })
  }, [saldo, n, manuales])

  const suma = redondear(partes.reduce((s, p) => s + p, 0))

  return (
    <div className="apilado">
      <div className="tarjeta espaciado">
        <span style={{ fontWeight: 600 }}>¿En cuántas partes?</span>
        <div className="horizontal">
          <button className="btn btn-fantasma" style={{ padding: 9 }} onClick={() => { setN(v => Math.max(2, v - 1)); setManuales({}) }}><Minus size={16} /></button>
          <span className="mono" style={{ fontSize: 20, fontWeight: 700, minWidth: 26, textAlign: 'center' }}>{n}</span>
          <button className="btn btn-fantasma" style={{ padding: 9 }} onClick={() => { setN(v => Math.min(20, v + 1)); setManuales({}) }}><Plus size={16} /></button>
        </div>
      </div>
      {partes.map((monto, i) => (
        <div className="tarjeta espaciado" key={i}>
          <div>
            <div style={{ fontWeight: 600 }}>Parte {i + 1} de {n}</div>
            <input
              className="mono"
              inputMode="decimal"
              value={manuales[i] ?? String(monto)}
              onChange={e => setManuales(prev => ({ ...prev, [i]: e.target.value }))}
              style={{ width: 110, marginTop: 6, padding: '8px 10px' }}
            />
          </div>
          <button
            className="btn btn-primario"
            disabled={monto <= 0 || monto > saldo + 0.005}
            onClick={() => alCobrarParte({ etiqueta: `Parte ${i + 1} de ${n}`, monto })}
          >
            Cobrar
          </button>
        </div>
      ))}
      {Math.abs(suma - saldo) > 0.005 && (
        <div className="pequeno centrado" style={{ color: 'var(--ambar)' }}>
          Las partes suman {dinero(suma)} y el saldo es {dinero(saldo)} — se cobra parte por parte, el saldo manda.
        </div>
      )}
    </div>
  )
}

// ---------- División por consumo real ----------
// Se asignan ítems específicos a cada persona; la asignación se guarda en el
// ítem (parteId) para poder salir y volver sin perderla.

function DivisionPorConsumo({ items, alCobrarPersona }: {
  items: ItemCuenta[]
  alCobrarPersona: (nombre: string, monto: number) => void
}) {
  const personasGuardadas = useMemo(() => {
    const s = new Set<string>()
    for (const it of items) if (it.parteId) s.add(it.parteId)
    return [...s]
  }, [items])
  const [personasNuevas, setPersonasNuevas] = useState<string[]>([])
  const [activa, setActiva] = useState<string | null>(null)
  const [nombreNuevo, setNombreNuevo] = useState('')

  const personas = useMemo(
    () => [...new Set([...personasGuardadas, ...personasNuevas])],
    [personasGuardadas, personasNuevas],
  )

  function agregarPersona() {
    const nombre = nombreNuevo.trim() || `Persona ${personas.length + 1}`
    if (!personas.includes(nombre)) setPersonasNuevas(prev => [...prev, nombre])
    setActiva(nombre)
    setNombreNuevo('')
  }

  async function alternarItem(item: ItemCuenta) {
    if (!activa) return
    const nuevo = item.parteId === activa ? undefined : activa
    await db.items.update(item.id!, { parteId: nuevo })
  }

  function subtotal(persona: string): number {
    return redondear(items.filter(it => it.parteId === persona).reduce((s, it) => s + totalItem(it), 0))
  }

  const sinAsignar = items.filter(it => !it.parteId)

  return (
    <div className="apilado">
      <div className="horizontal" style={{ flexWrap: 'wrap' }}>
        {personas.map(p => (
          <button
            key={p}
            className={`chip ${activa === p ? 'chip-ambar' : 'chip-neutro'}`}
            style={{ padding: '8px 14px', fontSize: 14 }}
            onClick={() => setActiva(activa === p ? null : p)}
          >
            <UserRound size={14} /> {p} · <span className="mono">{dinero(subtotal(p))}</span>
          </button>
        ))}
      </div>
      <div className="horizontal">
        <input
          placeholder="Nombre (opcional)…"
          value={nombreNuevo}
          onChange={e => setNombreNuevo(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && agregarPersona()}
        />
        <button className="btn btn-fantasma" style={{ whiteSpace: 'nowrap' }} onClick={agregarPersona}>
          <Plus size={16} /> Persona
        </button>
      </div>

      {activa ? (
        <div className="pequeno" style={{ color: 'var(--ambar)' }}>
          Toca los productos que consumió <b>{activa}</b>:
        </div>
      ) : personas.length > 0 ? (
        <div className="pequeno tenue">Elige una persona para asignarle productos.</div>
      ) : (
        <div className="pequeno tenue">Agrega a las personas que van a pagar.</div>
      )}

      <div className="tarjeta" style={{ padding: '4px 14px' }}>
        {items.map(it => {
          const asignadoA = it.parteId
          return (
            <motion.button
              key={it.id}
              whileTap={activa ? { scale: 0.98 } : {}}
              className="fila"
              style={{ width: '100%', textAlign: 'left', opacity: !activa && !asignadoA ? 0.75 : 1 }}
              onClick={() => alternarItem(it)}
            >
              <div className="crece">
                <div style={{ fontWeight: 600 }}>
                  {it.cantidad > 1 && <span className="mono">{it.cantidad} × </span>}{it.nombre}
                </div>
                {it.variantes.length > 0 && <div className="pequeno tenue">{etiquetaVariantes(it.variantes)}</div>}
              </div>
              <span className="mono pequeno tenue">{dinero(totalItem(it))}</span>
              {asignadoA && (
                <motion.span initial={{ scale: 0.6 }} animate={{ scale: 1 }} className={`chip ${asignadoA === activa ? 'chip-ambar' : 'chip-neutro'}`}>
                  {asignadoA}
                </motion.span>
              )}
            </motion.button>
          )
        })}
        {items.length === 0 && <div className="muy-tenue centrado" style={{ padding: 16 }}>Sin productos</div>}
      </div>

      {sinAsignar.length === 0 && items.length > 0 && (
        <div className="pequeno centrado" style={{ color: 'var(--menta)' }}>Todo asignado ✓</div>
      )}

      {personas.filter(p => subtotal(p) > 0).map(p => (
        <div className="tarjeta espaciado" key={p}>
          <div>
            <div style={{ fontWeight: 600 }}>{p}</div>
            <div className="mono tenue pequeno">{dinero(subtotal(p))}</div>
          </div>
          <button className="btn btn-primario" onClick={() => alCobrarPersona(p, subtotal(p))}>Cobrar</button>
        </div>
      ))}
    </div>
  )
}

// ---------- Formulario de una parte: métodos combinados + vuelto ----------

function FormularioParte({ clave, etiqueta, montoInicial, maximo, alConfirmar, alCancelar }: {
  clave: string
  etiqueta: string
  montoInicial: number
  maximo: number
  alConfirmar: (datos: {
    etiqueta: string; monto: number; efectivo: number; transferencia: number
    recibido?: number; vuelto?: number; comprobante?: Blob
  }) => void
  alCancelar: () => void
}) {
  const [textoEfectivo, setTextoEfectivo] = useState(String(montoInicial))
  const [textoTransfer, setTextoTransfer] = useState('0')
  const [textoRecibido, setTextoRecibido] = useState('')
  const [camaraAbierta, setCamaraAbierta] = useState(false)
  const [guardando, setGuardando] = useState(false)

  // Reiniciar si cambia la parte a cobrar
  const [claveActual, setClaveActual] = useState(clave)
  if (clave !== claveActual) {
    setClaveActual(clave)
    setTextoEfectivo(String(montoInicial))
    setTextoTransfer('0')
    setTextoRecibido('')
  }

  const efectivo = leerMonto(textoEfectivo)
  const transferencia = leerMonto(textoTransfer)
  const monto = redondear(efectivo + transferencia)
  const recibido = textoRecibido.trim() === '' ? undefined : leerMonto(textoRecibido)
  const vuelto = recibido !== undefined ? redondear(recibido - efectivo) : undefined
  const valido = monto > 0 && monto <= maximo + 0.005

  function repartir(todoA: 'efectivo' | 'transferencia') {
    if (todoA === 'efectivo') { setTextoEfectivo(String(montoInicial)); setTextoTransfer('0') }
    else { setTextoEfectivo('0'); setTextoTransfer(String(montoInicial)) }
  }

  function terminar(comprobante?: Blob) {
    if (guardando) return
    setGuardando(true)
    alConfirmar({
      etiqueta, monto, efectivo, transferencia,
      recibido, vuelto: vuelto !== undefined && vuelto >= 0 ? vuelto : undefined,
      comprobante,
    })
  }

  return (
    <motion.div initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} className="apilado">
      <div className="espaciado">
        <h3 style={{ fontSize: 18 }}>{etiqueta}</h3>
        <span className="mono" style={{ fontSize: 18, fontWeight: 700 }}>{dinero(montoInicial)}</span>
      </div>

      <div className="horizontal">
        <button className="chip chip-ambar" style={{ padding: '8px 14px' }} onClick={() => repartir('efectivo')}>
          <Banknote size={15} /> Todo efectivo
        </button>
        <button className="chip chip-cian" style={{ padding: '8px 14px' }} onClick={() => repartir('transferencia')}>
          <Landmark size={15} /> Todo transferencia
        </button>
      </div>

      <div className="horizontal" style={{ alignItems: 'flex-start' }}>
        <div className="crece">
          <span className="etiqueta-campo" style={{ color: 'var(--ambar)' }}>Efectivo</span>
          <input
            className="mono" inputMode="decimal" value={textoEfectivo}
            onFocus={e => e.target.select()}
            onChange={e => {
              setTextoEfectivo(e.target.value)
              const resto = redondear(montoInicial - leerMonto(e.target.value))
              setTextoTransfer(String(Math.max(0, resto)))
            }}
          />
        </div>
        <div className="crece">
          <span className="etiqueta-campo" style={{ color: 'var(--cian)' }}>Transferencia</span>
          <input
            className="mono" inputMode="decimal" value={textoTransfer}
            onFocus={e => e.target.select()}
            onChange={e => {
              setTextoTransfer(e.target.value)
              const resto = redondear(montoInicial - leerMonto(e.target.value))
              setTextoEfectivo(String(Math.max(0, resto)))
            }}
          />
        </div>
      </div>

      {monto !== redondear(montoInicial) && valido && (
        <div className="pequeno" style={{ color: 'var(--ambar)' }}>
          Se cobrarán {dinero(monto)} (los métodos suman distinto a la parte original).
        </div>
      )}
      {!valido && monto > 0 && (
        <div className="pequeno" style={{ color: 'var(--rojo)' }}>No puede superar el saldo ({dinero(maximo)}).</div>
      )}

      {efectivo > 0 && (
        <div className="tarjeta">
          <span className="etiqueta-campo">¿Con cuánto paga? (opcional, para el vuelto)</span>
          <input
            className="mono" inputMode="decimal" placeholder="ej. 20"
            value={textoRecibido} onChange={e => setTextoRecibido(e.target.value)}
          />
          <AnimatePresence>
            {vuelto !== undefined && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="espaciado"
                style={{ marginTop: 10 }}
              >
                <span className="tenue">Vuelto</span>
                <span className="mono" style={{ fontSize: 22, fontWeight: 700, color: vuelto >= 0 ? 'var(--menta)' : 'var(--rojo)' }}>
                  {dinero(Math.abs(vuelto))}{vuelto < 0 ? ' faltan' : ''}
                </span>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      )}

      <button
        className={`btn btn-bloque ${transferencia > 0 ? 'btn-cian' : 'btn-primario'}`}
        disabled={!valido || guardando}
        onClick={() => transferencia > 0 ? setCamaraAbierta(true) : terminar()}
      >
        {transferencia > 0
          ? <>Tomar comprobante y cobrar <span className="mono">{dinero(monto)}</span></>
          : <><Check size={18} /> Cobrar <span className="mono">{dinero(monto)}</span></>}
      </button>
      <button className="btn btn-fantasma btn-bloque" onClick={alCancelar}><X size={16} /> Cancelar</button>

      <Camara
        abierta={camaraAbierta}
        titulo={`Comprobante · ${dinero(transferencia)}`}
        alCancelar={() => setCamaraAbierta(false)}
        alCapturar={blob => { setCamaraAbierta(false); terminar(blob) }}
      />
    </motion.div>
  )
}
