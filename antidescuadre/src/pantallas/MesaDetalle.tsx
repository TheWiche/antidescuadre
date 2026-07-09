import { useMemo, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import {
  ArrowLeft, Camera, Check, CircleDashed, HandCoins, Pencil, Plus, ReceiptText, Trash2,
} from 'lucide-react'
import { db, obtenerAjustes } from '../db/db'
import type { ItemCuenta, Pago } from '../db/tipos'
import { dinero, horaCorta } from '../logica/dinero'
import {
  abrirCuentaEnMesa, agregarTanda, etiquetaVariantes, saldoCuenta, totalItem, totalItems, totalPagado,
  turnoActivo,
} from '../logica/cuentas'
import { SelectorProductos } from '../componentes/SelectorProductos'
import { FlujoCobro } from '../componentes/FlujoCobro'
import { FacturaVista } from '../componentes/FacturaVista'
import { Ticket, LineaImpresa } from '../componentes/Ticket'
import { Camara } from '../componentes/Camara'
import { Hoja } from '../componentes/Hoja'
import { Confirmar } from '../componentes/Confirmar'
import { SinTurno } from '../componentes/SinTurno'

export function MesaDetalle() {
  const { id } = useParams()
  const mesaId = Number(id)
  const navegar = useNavigate()

  const turno = useLiveQuery(() => turnoActivo(), [])
  const mesa = useLiveQuery(() => db.mesas.get(mesaId), [mesaId])
  const ajustes = useLiveQuery(() => obtenerAjustes(), [])
  const cuenta = useLiveQuery(
    () => db.cuentas.where({ mesaId }).filter(c => c.estado === 'abierta').first(), [mesaId],
  )
  const items = useLiveQuery(
    () => cuenta?.id ? db.items.where({ cuentaId: cuenta.id }).toArray() : Promise.resolve([] as ItemCuenta[]),
    [cuenta?.id],
  ) ?? []
  const pagos = useLiveQuery(
    () => cuenta?.id ? db.pagos.where({ cuentaId: cuenta.id }).toArray() : Promise.resolve([] as Pago[]),
    [cuenta?.id],
  ) ?? []

  const [selectorAbierto, setSelectorAbierto] = useState(false)
  const [cobroAbierto, setCobroAbierto] = useState(false)
  const [facturaAbierta, setFacturaAbierta] = useState(false)
  const [camaraAbierta, setCamaraAbierta] = useState(false)
  const [renombrando, setRenombrando] = useState(false)
  const [aliasNuevo, setAliasNuevo] = useState('')
  const [itemSel, setItemSel] = useState<ItemCuenta | null>(null)
  const [confirmandoCancelar, setConfirmandoCancelar] = useState(false)
  const [exito, setExito] = useState(false)

  const tandas = useMemo(() => {
    const mapa = new Map<number, ItemCuenta[]>()
    for (const it of items) {
      const lista = mapa.get(it.tandaId) ?? []
      lista.push(it)
      mapa.set(it.tandaId, lista)
    }
    return [...mapa.entries()].sort((a, b) => a[0] - b[0])
  }, [items])

  if (!mesa || turno === undefined) return <div className="pantalla" />

  const total = totalItems(items)
  const pagado = totalPagado(pagos)
  const saldo = saldoCuenta(items, pagos)

  return (
    <div className="pantalla">
      <div className="espaciado" style={{ marginBottom: 14 }}>
        <button className="btn btn-fantasma" style={{ padding: '10px 14px' }} onClick={() => navegar('/mesas')}>
          <ArrowLeft size={18} />
        </button>
        <button className="horizontal" onClick={() => { setAliasNuevo(mesa.alias); setRenombrando(true) }}>
          <h1 style={{ fontSize: 21 }}>{mesa.alias}</h1>
          <Pencil size={15} style={{ color: 'var(--crema-38)' }} />
        </button>
        <div style={{ width: 46 }} />
      </div>

      {!turno ? (
        <SinTurno mensaje="Inicia el turno para abrir la cuenta de esta mesa." />
      ) : !cuenta ? (
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="tarjeta centrado" style={{ padding: '38px 20px' }}>
          <span className="chip chip-neutro" style={{ marginBottom: 14 }}>mesa libre</span>
          <p className="tenue" style={{ margin: '0 0 20px' }}>
            Abre una cuenta y ve agregando lo que pidan; se cobra cuando ellos quieran.
          </p>
          <button
            className="btn btn-primario btn-bloque"
            style={{ fontSize: 17, padding: '16px 22px' }}
            onClick={async () => {
              await abrirCuentaEnMesa(mesaId, turno.id!)
              setSelectorAbierto(true)
            }}
          >
            Abrir cuenta
          </button>
        </motion.div>
      ) : (
        <>
          {/* La cuenta como ticket de comanda (elemento firma) */}
          <Ticket>
            <div className="ticket-cabecera">
              <div className="ticket-titulo">{ajustes?.nombreNegocio ?? 'Mi bar'}</div>
              <div className="ticket-meta">{mesa.alias} · abierta {horaCorta(cuenta.abiertaEn)}</div>
            </div>
            {items.length === 0 && (
              <div className="centrado ticket-meta" style={{ padding: '14px 0' }}>
                — cuenta vacía, agrega el primer pedido —
              </div>
            )}
            <AnimatePresence initial={false}>
              {tandas.map(([tandaId, lista]) => (
                <LineaImpresa key={tandaId} id={tandaId}>
                  <div className="ticket-hora">{horaCorta(tandaId)}</div>
                  {lista.map(it => (
                    <button
                      key={it.id}
                      className="ticket-linea"
                      style={{ width: '100%', textAlign: 'left', color: 'inherit', fontFamily: 'inherit', fontSize: 'inherit' }}
                      onClick={() => setItemSel(it)}
                    >
                      <span>{it.cantidad}×</span>
                      <span className="nombre">
                        {it.nombre}
                        {it.variantes.length > 0 && (
                          <span style={{ color: 'var(--papel-tinta-suave)' }}> · {etiquetaVariantes(it.variantes)}</span>
                        )}
                      </span>
                      {it.estado === 'pendiente'
                        ? <CircleDashed size={13} style={{ color: '#b3541e', flexShrink: 0 }} />
                        : <Check size={13} style={{ color: '#2e7d54', flexShrink: 0 }} />}
                      <span className="precio">{dinero(totalItem(it))}</span>
                    </button>
                  ))}
                </LineaImpresa>
              ))}
            </AnimatePresence>
            <div className="ticket-total">
              <span>TOTAL</span>
              <span>{dinero(total)}</span>
            </div>
            {pagado > 0 && (
              <>
                <div className="ticket-linea"><span className="nombre">pagado</span><span className="precio">−{dinero(pagado)}</span></div>
                <div className="ticket-linea" style={{ fontWeight: 700 }}>
                  <span className="nombre">SALDO</span><span className="precio">{dinero(saldo)}</span>
                </div>
              </>
            )}
          </Ticket>

          {/* Acciones de la cuenta */}
          <div className="apilado" style={{ marginTop: 18 }}>
            <div className="horizontal">
              <button className="btn btn-primario crece" style={{ padding: '16px 20px', fontSize: 17 }} onClick={() => setSelectorAbierto(true)}>
                <Plus size={20} /> Agregar
              </button>
              <button
                className="btn btn-menta crece"
                style={{ padding: '16px 20px', fontSize: 17 }}
                disabled={saldo <= 0}
                onClick={() => setCobroAbierto(true)}
              >
                <HandCoins size={20} /> Cobrar
              </button>
            </div>
            <div className="horizontal">
              <button className="btn btn-fantasma crece" disabled={items.length === 0} onClick={() => setFacturaAbierta(true)}>
                <ReceiptText size={17} /> Factura
              </button>
              <button className="btn btn-fantasma crece" onClick={() => setCamaraAbierta(true)}>
                <Camera size={17} /> Comprobante
              </button>
              {pagos.length === 0 && (
                <button className="btn btn-peligro" style={{ padding: '14px 16px' }} onClick={() => setConfirmandoCancelar(true)}>
                  <Trash2 size={17} />
                </button>
              )}
            </div>
          </div>
        </>
      )}

      {/* Selector de productos → agrega una tanda a la cuenta */}
      <SelectorProductos
        abierta={selectorAbierto}
        titulo={mesa.alias}
        textoConfirmar="Agregar a la cuenta"
        alCerrar={() => setSelectorAbierto(false)}
        alConfirmar={async lineas => {
          if (cuenta?.id) await agregarTanda(cuenta.id, lineas)
          setSelectorAbierto(false)
        }}
      />

      {/* Cobro */}
      {cuenta?.id && (
        <FlujoCobro
          abierta={cobroAbierto}
          cuentaId={cuenta.id}
          turnoId={cuenta.turnoId}
          mesaId={mesaId}
          mesaAlias={mesa.alias}
          alCerrar={() => setCobroAbierto(false)}
          alCuentaSaldada={() => {
            setCobroAbierto(false)
            setExito(true)
            setTimeout(() => { setExito(false); navegar('/mesas') }, 1200)
          }}
        />
      )}

      {/* Factura cronológica / agrupada */}
      <Hoja abierta={facturaAbierta} alCerrar={() => setFacturaAbierta(false)}>
        <FacturaVista
          nombreNegocio={ajustes?.nombreNegocio ?? 'Mi bar'}
          alias={mesa.alias}
          fecha={cuenta?.abiertaEn ?? Date.now()}
          items={items}
        />
      </Hoja>

      {/* Comprobante ligado a esta mesa */}
      <Camara
        abierta={camaraAbierta}
        titulo={`Comprobante · ${mesa.alias}`}
        alCancelar={() => setCamaraAbierta(false)}
        alCapturar={async blob => {
          await db.comprobantes.add({
            imagen: blob, fecha: Date.now(),
            turnoId: turno?.id ?? null, mesaId, aliasMesa: mesa.alias,
            cuentaId: cuenta?.id ?? null, pagoId: null, monto: null,
            estado: 'pendiente',
          })
          setCamaraAbierta(false)
        }}
      />

      {/* Ítem: entregar / devolver a pendiente / eliminar */}
      <Hoja abierta={itemSel !== null} alCerrar={() => setItemSel(null)}>
        {itemSel && (
          <>
            <div className="hoja-titulo">
              {itemSel.cantidad}× {itemSel.nombre}
              {itemSel.variantes.length > 0 && <span className="tenue"> · {etiquetaVariantes(itemSel.variantes)}</span>}
            </div>
            <div className="apilado">
              {itemSel.estado === 'pendiente' ? (
                <button
                  className="btn btn-menta btn-bloque"
                  onClick={async () => {
                    await db.items.update(itemSel.id!, { estado: 'entregado', entregadoEn: Date.now() })
                    setItemSel(null)
                  }}
                >
                  <Check size={18} /> Marcar entregado
                </button>
              ) : (
                <button
                  className="btn btn-fantasma btn-bloque"
                  onClick={async () => {
                    await db.items.update(itemSel.id!, { estado: 'pendiente', entregadoEn: undefined })
                    setItemSel(null)
                  }}
                >
                  <CircleDashed size={18} /> Devolver a pendiente
                </button>
              )}
              <button
                className="btn btn-peligro btn-bloque"
                onClick={async () => {
                  await db.items.delete(itemSel.id!)
                  setItemSel(null)
                }}
              >
                <Trash2 size={17} /> Quitar de la cuenta
              </button>
            </div>
          </>
        )}
      </Hoja>

      {/* Renombrar / eliminar mesa */}
      <Hoja abierta={renombrando} alCerrar={() => setRenombrando(false)}>
        <div className="hoja-titulo">Alias de la mesa</div>
        <input value={aliasNuevo} onChange={e => setAliasNuevo(e.target.value)} autoFocus />
        <button
          className="btn btn-primario btn-bloque"
          style={{ marginTop: 14 }}
          disabled={!aliasNuevo.trim()}
          onClick={async () => {
            await db.mesas.update(mesaId, { alias: aliasNuevo.trim() })
            setRenombrando(false)
          }}
        >
          Guardar
        </button>
        {!cuenta && (
          <button
            className="btn btn-peligro btn-bloque"
            style={{ marginTop: 10 }}
            onClick={async () => {
              await db.mesas.delete(mesaId)
              navegar('/mesas')
            }}
          >
            <Trash2 size={16} /> Eliminar mesa
          </button>
        )}
      </Hoja>

      <Confirmar
        abierta={confirmandoCancelar}
        titulo="¿Cancelar la cuenta?"
        detalle="Se quitarán los productos agregados y la mesa quedará libre."
        textoConfirmar="Cancelar cuenta"
        peligro
        alConfirmar={async () => {
          if (cuenta?.id) {
            await db.items.where({ cuentaId: cuenta.id }).delete()
            await db.cuentas.delete(cuenta.id)
          }
          setConfirmandoCancelar(false)
          navegar('/mesas')
        }}
        alCancelar={() => setConfirmandoCancelar(false)}
      />

      {/* Sello de cuenta saldada */}
      <AnimatePresence>
        {exito && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            style={{ position: 'fixed', inset: 0, zIndex: 80, display: 'grid', placeItems: 'center', background: 'rgba(12,6,13,0.75)' }}
          >
            <motion.div
              initial={{ scale: 0.4, rotate: -14 }}
              animate={{ scale: 1, rotate: -8 }}
              transition={{ type: 'spring', damping: 12, stiffness: 260 }}
              style={{
                border: '4px solid var(--menta)', color: 'var(--menta)',
                borderRadius: 14, padding: '10px 26px',
                fontFamily: 'var(--f-display)', fontWeight: 800, fontSize: 30,
                letterSpacing: '0.06em', textTransform: 'uppercase',
              }}
            >
              Cuenta saldada
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
