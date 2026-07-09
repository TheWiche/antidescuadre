import { useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import { ChevronLeft, Minus, Plus, Search, ShoppingBasket, X } from 'lucide-react'
import { db } from '../db/db'
import type { Categoria, GrupoVariante, OpcionVariante, Producto, SeleccionVariante } from '../db/tipos'
import { dinero, redondear } from '../logica/dinero'
import { precioUnitario, etiquetaVariantes, type LineaNueva } from '../logica/cuentas'
import { Hoja } from './Hoja'

interface Props {
  abierta: boolean
  titulo: string
  textoConfirmar: string
  alConfirmar: (lineas: LineaNueva[]) => void
  alCerrar: () => void
}

// Selector de productos: la interacción central de la app. Tocar un producto
// sin variantes lo suma al instante (con rebote de confirmación); uno con
// variantes abre su hoja de opciones. La canasta vive abajo y se confirma
// en un solo gesto.
export function SelectorProductos({ abierta, titulo, textoConfirmar, alConfirmar, alCerrar }: Props) {
  const categorias = useLiveQuery(() => db.categorias.toArray(), []) ?? []
  const productos = useLiveQuery(() => db.productos.filter(p => p.activo).toArray(), []) ?? []

  const [categoriaActual, setCategoriaActual] = useState<number | null>(null)
  const [filtro, setFiltro] = useState('')
  const [canasta, setCanasta] = useState<LineaNueva[]>([])
  const [productoVariantes, setProductoVariantes] = useState<Producto | null>(null)
  const [verCanasta, setVerCanasta] = useState(false)
  const [reboteId, setReboteId] = useState<number | null>(null)

  const subcategorias = categorias.filter(c => c.padreId === categoriaActual)
  const rastro = useMemo(() => {
    const camino: Categoria[] = []
    let actual = categorias.find(c => c.id === categoriaActual)
    while (actual) {
      camino.unshift(actual)
      actual = categorias.find(c => c.id === actual!.padreId)
    }
    return camino
  }, [categorias, categoriaActual])

  const visibles = useMemo(() => {
    const texto = filtro.trim().toLowerCase()
    if (texto) return productos.filter(p => p.nombre.toLowerCase().includes(texto))
    if (categoriaActual === null) return productos
    // Incluye productos de la categoría actual y de todas sus descendientes
    const descendientes = new Set<number>([categoriaActual])
    let creció = true
    while (creció) {
      creció = false
      for (const c of categorias) {
        if (c.padreId !== null && descendientes.has(c.padreId) && !descendientes.has(c.id!)) {
          descendientes.add(c.id!)
          creció = true
        }
      }
    }
    return productos.filter(p => p.categoriaId !== null && descendientes.has(p.categoriaId))
  }, [productos, categorias, categoriaActual, filtro])

  const totalCanasta = redondear(canasta.reduce((s, l) => s + precioUnitario(l.producto, l.variantes) * l.cantidad, 0))
  const cantidadCanasta = canasta.reduce((s, l) => s + l.cantidad, 0)

  function claveLinea(l: LineaNueva): string {
    return `${l.producto.id}|${l.variantes.map(v => v.camino.join('>')).join('|')}`
  }

  function sumar(producto: Producto, variantes: SeleccionVariante[], cantidad: number) {
    setCanasta(prev => {
      const nueva: LineaNueva = { producto, variantes, cantidad }
      const idx = prev.findIndex(l => claveLinea(l) === claveLinea(nueva))
      if (idx >= 0) {
        const copia = [...prev]
        copia[idx] = { ...copia[idx], cantidad: copia[idx].cantidad + cantidad }
        return copia
      }
      return [...prev, nueva]
    })
    setReboteId(producto.id ?? null)
    setTimeout(() => setReboteId(null), 350)
    if (navigator.vibrate) navigator.vibrate(12)
  }

  function tocarProducto(p: Producto) {
    if (p.grupos.length > 0) setProductoVariantes(p)
    else sumar(p, [], 1)
  }

  function cantidadDe(p: Producto): number {
    return canasta.filter(l => l.producto.id === p.id).reduce((s, l) => s + l.cantidad, 0)
  }

  function cerrarTodo() {
    setCanasta([])
    setFiltro('')
    setCategoriaActual(null)
    alCerrar()
  }

  return (
    <AnimatePresence>
      {abierta && (
        <motion.div
          initial={{ y: '100%' }}
          animate={{ y: 0 }}
          exit={{ y: '100%' }}
          transition={{ type: 'spring', damping: 32, stiffness: 320 }}
          style={{
            position: 'fixed', inset: 0, zIndex: 60, background: 'var(--ciruela-800)',
            display: 'flex', flexDirection: 'column',
          }}
        >
          <div style={{ maxWidth: 560, margin: '0 auto', width: '100%', display: 'flex', flexDirection: 'column', height: '100%' }}>
            {/* Cabecera */}
            <div className="espaciado" style={{ padding: '14px 16px 8px' }}>
              <button className="btn btn-fantasma" style={{ padding: '10px 14px' }} onClick={cerrarTodo}>
                <X size={18} />
              </button>
              <h2 style={{ fontSize: 19 }}>{titulo}</h2>
              <div style={{ width: 46 }} />
            </div>

            {/* Buscador */}
            <div style={{ padding: '4px 16px 10px', position: 'relative' }}>
              <Search size={17} style={{ position: 'absolute', left: 30, top: '50%', transform: 'translateY(-58%)', color: 'var(--crema-38)' }} />
              <input
                value={filtro}
                onChange={e => setFiltro(e.target.value)}
                placeholder="Buscar producto…"
                style={{ paddingLeft: 42 }}
              />
            </div>

            {/* Categorías */}
            {!filtro && (
              <div className="horizontal" style={{ padding: '0 16px 10px', overflowX: 'auto', flexWrap: 'nowrap' }}>
                {categoriaActual !== null && (
                  <button
                    className="chip chip-neutro"
                    style={{ flexShrink: 0 }}
                    onClick={() => setCategoriaActual(rastro.length > 1 ? rastro[rastro.length - 2].id! : null)}
                  >
                    <ChevronLeft size={14} />
                    {rastro.length > 1 ? rastro[rastro.length - 2].nombre : 'Todo'}
                  </button>
                )}
                {categoriaActual !== null && (
                  <span className="chip chip-ambar" style={{ flexShrink: 0 }}>{rastro[rastro.length - 1]?.nombre}</span>
                )}
                {subcategorias.map(c => (
                  <button
                    key={c.id}
                    className="chip chip-neutro"
                    style={{ flexShrink: 0, border: '1px solid var(--crema-12)' }}
                    onClick={() => setCategoriaActual(c.id!)}
                  >
                    {c.nombre}
                  </button>
                ))}
              </div>
            )}

            {/* Cuadrícula de productos */}
            <div style={{ flex: 1, overflowY: 'auto', padding: '2px 16px 120px' }}>
              {visibles.length === 0 ? (
                <div className="centrado muy-tenue" style={{ padding: '40px 20px' }}>
                  {productos.length === 0
                    ? 'El catálogo está vacío. Créalo en Más → Catálogo.'
                    : 'Nada por aquí.'}
                </div>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))', gap: 10 }}>
                  {visibles.map(p => {
                    const enCanasta = cantidadDe(p)
                    return (
                      <motion.button
                        key={p.id}
                        onClick={() => tocarProducto(p)}
                        animate={reboteId === p.id ? { scale: [1, 1.06, 1] } : {}}
                        transition={{ duration: 0.3 }}
                        whileTap={{ scale: 0.95 }}
                        className="tarjeta"
                        style={{
                          textAlign: 'left', position: 'relative', minHeight: 92,
                          display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
                          borderColor: enCanasta ? 'var(--ambar)' : undefined,
                        }}
                      >
                        <div style={{ fontWeight: 600, fontSize: 15, lineHeight: 1.25 }}>{p.nombre}</div>
                        <div className="espaciado" style={{ marginTop: 8 }}>
                          <span className="mono tenue pequeno">{dinero(p.precio)}{p.grupos.length > 0 && ' +'}</span>
                          {p.grupos.length > 0 && <span className="pequeno muy-tenue">opciones</span>}
                        </div>
                        <AnimatePresence>
                          {enCanasta > 0 && (
                            <motion.span
                              initial={{ scale: 0 }}
                              animate={{ scale: 1 }}
                              exit={{ scale: 0 }}
                              key={enCanasta}
                              className="mono"
                              style={{
                                position: 'absolute', top: -7, right: -7,
                                background: 'var(--ambar)', color: 'var(--ambar-tinta)',
                                borderRadius: 99, minWidth: 26, height: 26, fontWeight: 700,
                                display: 'grid', placeItems: 'center', fontSize: 13, padding: '0 7px',
                              }}
                            >
                              {enCanasta}
                            </motion.span>
                          )}
                        </AnimatePresence>
                      </motion.button>
                    )
                  })}
                </div>
              )}
            </div>

            {/* Barra de canasta */}
            <AnimatePresence>
              {canasta.length > 0 && (
                <motion.div
                  initial={{ y: 90, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  exit={{ y: 90, opacity: 0 }}
                  transition={{ type: 'spring', damping: 28, stiffness: 380 }}
                  style={{
                    position: 'absolute', bottom: 0, left: 0, right: 0,
                    padding: '12px 16px calc(16px + var(--safe-b))',
                    background: 'linear-gradient(transparent, var(--ciruela-900) 35%)',
                    display: 'flex', gap: 10, maxWidth: 560, margin: '0 auto',
                  }}
                >
                  <button
                    className="btn btn-fantasma"
                    style={{ background: 'var(--ciruela-700)' }}
                    onClick={() => setVerCanasta(true)}
                  >
                    <ShoppingBasket size={19} />
                    <motion.span key={cantidadCanasta} initial={{ scale: 1.4 }} animate={{ scale: 1 }} className="mono">
                      {cantidadCanasta}
                    </motion.span>
                  </button>
                  <button
                    className="btn btn-primario crece"
                    onClick={() => {
                      const lineas = canasta
                      setCanasta([])
                      setFiltro('')
                      alConfirmar(lineas)
                    }}
                  >
                    {textoConfirmar} · <span className="mono">{dinero(totalCanasta)}</span>
                  </button>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Hoja de variantes */}
          <HojaVariantes
            producto={productoVariantes}
            alCerrar={() => setProductoVariantes(null)}
            alAgregar={(variantes, cantidad) => {
              if (productoVariantes) sumar(productoVariantes, variantes, cantidad)
              setProductoVariantes(null)
            }}
          />

          {/* Hoja de canasta (revisar/ajustar) */}
          <Hoja abierta={verCanasta} alCerrar={() => setVerCanasta(false)}>
            <div className="hoja-titulo">Por agregar</div>
            {canasta.map((l, i) => (
              <div className="fila" key={i}>
                <div className="crece">
                  <div style={{ fontWeight: 600 }}>{l.producto.nombre}</div>
                  {l.variantes.length > 0 && (
                    <div className="pequeno tenue">{etiquetaVariantes(l.variantes)}</div>
                  )}
                  <div className="pequeno mono muy-tenue">{dinero(precioUnitario(l.producto, l.variantes))} c/u</div>
                </div>
                <div className="horizontal">
                  <button
                    className="btn btn-fantasma"
                    style={{ padding: 9 }}
                    onClick={() => setCanasta(prev => prev
                      .map((x, j) => j === i ? { ...x, cantidad: x.cantidad - 1 } : x)
                      .filter(x => x.cantidad > 0))}
                  >
                    <Minus size={16} />
                  </button>
                  <span className="mono" style={{ minWidth: 22, textAlign: 'center', fontWeight: 700 }}>{l.cantidad}</span>
                  <button
                    className="btn btn-fantasma"
                    style={{ padding: 9 }}
                    onClick={() => setCanasta(prev => prev.map((x, j) => j === i ? { ...x, cantidad: x.cantidad + 1 } : x))}
                  >
                    <Plus size={16} />
                  </button>
                </div>
              </div>
            ))}
            {canasta.length === 0 && <div className="muy-tenue centrado" style={{ padding: 20 }}>Canasta vacía</div>}
          </Hoja>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

// ---------- Hoja de selección de variantes ----------
// Recorre cada grupo del producto; dentro de un grupo las opciones pueden
// anidarse (ej. Base > Cerveza > Corona) y cada nivel puede sumar precio.

function HojaVariantes({ producto, alCerrar, alAgregar }: {
  producto: Producto | null
  alCerrar: () => void
  alAgregar: (variantes: SeleccionVariante[], cantidad: number) => void
}) {
  const [selecciones, setSelecciones] = useState<Record<string, { camino: OpcionVariante[] }>>({})
  const [cantidad, setCantidad] = useState(1)
  const [claveProducto, setClaveProducto] = useState<number | null>(null)

  // Reiniciar al cambiar de producto
  if (producto && producto.id !== claveProducto) {
    setClaveProducto(producto.id ?? null)
    setSelecciones({})
    setCantidad(1)
  }

  if (!producto) return <Hoja abierta={false} alCerrar={alCerrar}>{null}</Hoja>

  function esCompleta(grupo: GrupoVariante): boolean {
    const sel = selecciones[grupo.id]
    if (!sel || sel.camino.length === 0) return false
    const ultima = sel.camino[sel.camino.length - 1]
    return !ultima.hijas || ultima.hijas.length === 0
  }

  const completo = producto.grupos.every(esCompleta)

  const variantesElegidas: SeleccionVariante[] = producto.grupos.map(g => {
    const camino = selecciones[g.id]?.camino ?? []
    return {
      grupo: g.nombre,
      camino: camino.map(o => o.nombre),
      delta: redondear(camino.reduce((s, o) => s + (o.delta || 0), 0)),
    }
  })

  const unitario = completo ? precioUnitario(producto, variantesElegidas) : producto.precio

  return (
    <Hoja abierta={!!producto} alCerrar={alCerrar}>
      <div className="hoja-titulo" style={{ marginBottom: 2 }}>{producto.nombre}</div>
      <div className="mono tenue pequeno" style={{ marginBottom: 14 }}>
        {dinero(unitario)}{!completo && producto.grupos.some(g => tieneDeltas(g.opciones)) ? ' + opciones' : ''}
      </div>

      {producto.grupos.map(grupo => {
        const camino = selecciones[grupo.id]?.camino ?? []
        const nivel = camino.length === 0
          ? grupo.opciones
          : camino[camino.length - 1].hijas ?? []
        const terminado = esCompleta(grupo)
        return (
          <div key={grupo.id} style={{ marginBottom: 16 }}>
            <span className="etiqueta-campo">{grupo.nombre}</span>
            {camino.length > 0 && (
              <div className="horizontal" style={{ flexWrap: 'wrap', marginBottom: 8 }}>
                {camino.map((op, i) => (
                  <button
                    key={i}
                    className="chip chip-ambar"
                    onClick={() => setSelecciones(prev => ({
                      ...prev, [grupo.id]: { camino: camino.slice(0, i) },
                    }))}
                  >
                    {op.nombre}{op.delta ? <span className="mono"> +{dinero(op.delta).slice(1)}</span> : null}
                    <X size={12} />
                  </button>
                ))}
              </div>
            )}
            {!terminado && (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(120px, 1fr))', gap: 8 }}>
                {nivel.map(op => (
                  <motion.button
                    key={op.id}
                    whileTap={{ scale: 0.94 }}
                    className="tarjeta"
                    style={{ padding: '12px 12px', textAlign: 'center', background: 'var(--ciruela-600)' }}
                    onClick={() => setSelecciones(prev => ({
                      ...prev, [grupo.id]: { camino: [...camino, op] },
                    }))}
                  >
                    <div style={{ fontWeight: 600, fontSize: 14.5 }}>{op.nombre}</div>
                    {op.delta > 0 && <div className="mono pequeno" style={{ color: 'var(--ambar)' }}>+{dinero(op.delta).slice(1)}</div>}
                    {op.hijas && op.hijas.length > 0 && <div className="pequeno muy-tenue">elegir…</div>}
                  </motion.button>
                ))}
              </div>
            )}
          </div>
        )
      })}

      <div className="horizontal" style={{ justifyContent: 'center', gap: 16, margin: '6px 0 16px' }}>
        <button className="btn btn-fantasma" style={{ padding: 11 }} onClick={() => setCantidad(c => Math.max(1, c - 1))}>
          <Minus size={17} />
        </button>
        <span className="mono" style={{ fontSize: 22, fontWeight: 700, minWidth: 34, textAlign: 'center' }}>{cantidad}</span>
        <button className="btn btn-fantasma" style={{ padding: 11 }} onClick={() => setCantidad(c => c + 1)}>
          <Plus size={17} />
        </button>
      </div>

      <button
        className="btn btn-primario btn-bloque"
        disabled={!completo}
        onClick={() => alAgregar(variantesElegidas, cantidad)}
      >
        Agregar {cantidad > 1 ? `${cantidad} ` : ''}· <span className="mono">{dinero(redondear(unitario * cantidad))}</span>
      </button>
    </Hoja>
  )
}

function tieneDeltas(opciones: OpcionVariante[]): boolean {
  return opciones.some(o => o.delta > 0 || (o.hijas && tieneDeltas(o.hijas)))
}
