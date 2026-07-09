import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useLiveQuery } from 'dexie-react-hooks'
import {
  ArrowLeft, ChevronLeft, ChevronRight, CornerDownRight, FolderOpen, Package, Pencil, Plus, Trash2, X,
} from 'lucide-react'
import { db } from '../db/db'
import type { Categoria, GrupoVariante, OpcionVariante, Producto } from '../db/tipos'
import { dinero, leerMonto } from '../logica/dinero'
import { Hoja } from '../componentes/Hoja'
import { Vacio } from '../componentes/Vacio'

// Catálogo: todo lo arma el propietario — categorías y subcategorías sin
// límite de nivel, productos con variantes anidadas y precio extra opcional.
// Nada viene precargado de fábrica.
export function Catalogo() {
  const navegar = useNavigate()
  const categorias = useLiveQuery(() => db.categorias.toArray(), []) ?? []
  const productos = useLiveQuery(() => db.productos.toArray(), []) ?? []

  const [actualId, setActualId] = useState<number | null>(null)
  const [editandoCategoria, setEditandoCategoria] = useState<Categoria | 'nueva' | null>(null)
  const [editandoProducto, setEditandoProducto] = useState<Producto | 'nuevo' | null>(null)

  const rastro = useMemo(() => {
    const camino: Categoria[] = []
    let c = categorias.find(x => x.id === actualId)
    while (c) {
      camino.unshift(c)
      c = categorias.find(x => x.id === c!.padreId)
    }
    return camino
  }, [categorias, actualId])

  const subcategorias = categorias.filter(c => c.padreId === actualId)
  const productosAqui = productos.filter(p => p.categoriaId === actualId)

  return (
    <div className="pantalla">
      <div className="espaciado" style={{ marginBottom: 8 }}>
        <button className="btn btn-fantasma" style={{ padding: '10px 14px' }} onClick={() => navegar('/mas')}>
          <ArrowLeft size={18} />
        </button>
        <h1 style={{ fontSize: 21 }}>Catálogo</h1>
        <div style={{ width: 46 }} />
      </div>

      {/* Migas de categorías */}
      <div className="horizontal" style={{ overflowX: 'auto', flexWrap: 'nowrap', marginBottom: 14 }}>
        {actualId !== null && (
          <button
            className="chip chip-neutro"
            style={{ flexShrink: 0 }}
            onClick={() => setActualId(rastro.length > 1 ? rastro[rastro.length - 2].id! : null)}
          >
            <ChevronLeft size={14} /> {rastro.length > 1 ? rastro[rastro.length - 2].nombre : 'Inicio'}
          </button>
        )}
        <span className="chip chip-ambar" style={{ flexShrink: 0 }}>
          {rastro.length === 0 ? 'Todo el catálogo' : rastro.map(c => c.nombre).join(' › ')}
        </span>
      </div>

      {subcategorias.length === 0 && productosAqui.length === 0 ? (
        <Vacio
          icono={Package}
          titulo={actualId === null ? 'El catálogo está vacío' : 'Categoría vacía'}
          detalle="Crea categorías y productos con los botones de abajo."
        />
      ) : (
        <div className="apilado">
          {subcategorias.map(c => {
            const cuenta = productos.filter(p => p.categoriaId === c.id).length
            const sub = categorias.filter(x => x.padreId === c.id).length
            return (
              <div className="tarjeta horizontal" key={c.id} style={{ padding: '12px 14px' }}>
                <button className="horizontal crece" style={{ textAlign: 'left' }} onClick={() => setActualId(c.id!)}>
                  <FolderOpen size={19} style={{ color: 'var(--ambar)', flexShrink: 0 }} />
                  <div className="crece">
                    <div style={{ fontWeight: 700 }}>{c.nombre}</div>
                    <div className="pequeno muy-tenue">
                      {sub > 0 && `${sub} subcategoría${sub > 1 ? 's' : ''} · `}{cuenta} producto{cuenta !== 1 ? 's' : ''}
                    </div>
                  </div>
                  <ChevronRight size={17} style={{ color: 'var(--crema-38)' }} />
                </button>
                <button className="btn btn-fantasma" style={{ padding: 9 }} onClick={() => setEditandoCategoria(c)}>
                  <Pencil size={15} />
                </button>
              </div>
            )
          })}

          {productosAqui.map(p => (
            <motion.button
              key={p.id}
              whileTap={{ scale: 0.98 }}
              className="tarjeta espaciado"
              style={{ textAlign: 'left', opacity: p.activo ? 1 : 0.5, padding: '12px 14px' }}
              onClick={() => setEditandoProducto(p)}
            >
              <div>
                <div style={{ fontWeight: 700 }}>{p.nombre}{!p.activo && ' · inactivo'}</div>
                {p.grupos.length > 0 && (
                  <div className="pequeno muy-tenue">
                    {p.grupos.map(g => g.nombre).join(' · ')}
                  </div>
                )}
              </div>
              <span className="mono" style={{ fontWeight: 700 }}>{dinero(p.precio)}{p.grupos.length > 0 && ' +'}</span>
            </motion.button>
          ))}
        </div>
      )}

      <div className="horizontal" style={{ marginTop: 18 }}>
        <button className="btn btn-fantasma crece" onClick={() => setEditandoCategoria('nueva')}>
          <Plus size={17} /> Categoría
        </button>
        <button className="btn btn-primario crece" onClick={() => setEditandoProducto('nuevo')}>
          <Plus size={17} /> Producto
        </button>
      </div>

      {editandoCategoria && (
        <EditorCategoria
          categoria={editandoCategoria === 'nueva' ? null : editandoCategoria}
          padreId={actualId}
          tieneContenido={c =>
            categorias.some(x => x.padreId === c) || productos.some(p => p.categoriaId === c)}
          alCerrar={() => setEditandoCategoria(null)}
        />
      )}

      {editandoProducto && (
        <EditorProducto
          producto={editandoProducto === 'nuevo' ? null : editandoProducto}
          categoriaId={actualId}
          rutaCategoria={rastro.map(c => c.nombre).join(' › ') || 'Sin categoría'}
          alCerrar={() => setEditandoProducto(null)}
        />
      )}
    </div>
  )
}

// ---------- Editor de categoría ----------

function EditorCategoria({ categoria, padreId, tieneContenido, alCerrar }: {
  categoria: Categoria | null
  padreId: number | null
  tieneContenido: (id: number) => boolean
  alCerrar: () => void
}) {
  const [nombre, setNombre] = useState(categoria?.nombre ?? '')
  const bloqueada = categoria?.id != null && tieneContenido(categoria.id)

  async function guardar() {
    const limpio = nombre.trim()
    if (!limpio) return
    if (categoria?.id != null) await db.categorias.update(categoria.id, { nombre: limpio })
    else await db.categorias.add({ nombre: limpio, padreId })
    alCerrar()
  }

  return (
    <Hoja abierta alCerrar={alCerrar}>
      <div className="hoja-titulo">{categoria ? 'Editar categoría' : 'Nueva categoría'}</div>
      <span className="etiqueta-campo">Nombre</span>
      <input
        autoFocus placeholder="ej. Bebidas, Cervezas, Cócteles…"
        value={nombre} onChange={e => setNombre(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && guardar()}
      />
      <button className="btn btn-primario btn-bloque" style={{ marginTop: 14 }} disabled={!nombre.trim()} onClick={guardar}>
        Guardar
      </button>
      {categoria?.id != null && (
        <>
          <button
            className="btn btn-peligro btn-bloque"
            style={{ marginTop: 10 }}
            disabled={bloqueada}
            onClick={async () => { await db.categorias.delete(categoria.id!); alCerrar() }}
          >
            <Trash2 size={16} /> Eliminar categoría
          </button>
          {bloqueada && (
            <p className="pequeno muy-tenue centrado" style={{ marginTop: 8 }}>
              Para eliminarla, primero vacíala (subcategorías y productos).
            </p>
          )}
        </>
      )}
    </Hoja>
  )
}

// ---------- Editor de producto (con variantes anidadas) ----------

function EditorProducto({ producto, categoriaId, rutaCategoria, alCerrar }: {
  producto: Producto | null
  categoriaId: number | null
  rutaCategoria: string
  alCerrar: () => void
}) {
  const [nombre, setNombre] = useState(producto?.nombre ?? '')
  const [precioTexto, setPrecioTexto] = useState(producto ? String(producto.precio) : '')
  const [activo, setActivo] = useState(producto?.activo ?? true)
  const [grupos, setGrupos] = useState<GrupoVariante[]>(
    () => JSON.parse(JSON.stringify(producto?.grupos ?? [])),
  )

  const precio = leerMonto(precioTexto)
  const valido = nombre.trim().length > 0 && gruposValidos(grupos)

  async function guardar() {
    const datos = {
      nombre: nombre.trim(),
      precio,
      activo,
      grupos: limpiarGrupos(grupos),
      categoriaId: producto ? producto.categoriaId : categoriaId,
    }
    if (producto?.id != null) await db.productos.put({ ...datos, id: producto.id } as Producto)
    else await db.productos.add(datos as Producto)
    alCerrar()
  }

  return (
    <Hoja abierta alCerrar={alCerrar}>
      <div className="hoja-titulo">{producto ? 'Editar producto' : 'Nuevo producto'}</div>
      <p className="pequeno muy-tenue" style={{ marginTop: -10 }}>{rutaCategoria}</p>

      <div className="apilado">
        <div>
          <span className="etiqueta-campo">Nombre</span>
          <input autoFocus={!producto} placeholder="ej. Michelada" value={nombre} onChange={e => setNombre(e.target.value)} />
        </div>
        <div>
          <span className="etiqueta-campo">Precio base</span>
          <input className="mono" inputMode="decimal" placeholder="0" value={precioTexto} onChange={e => setPrecioTexto(e.target.value)} />
        </div>

        <button className="tarjeta espaciado" style={{ padding: '12px 14px' }} onClick={() => setActivo(a => !a)}>
          <span style={{ fontWeight: 600 }}>Disponible para la venta</span>
          <span
            style={{
              width: 46, height: 27, borderRadius: 99, padding: 3, boxSizing: 'border-box',
              background: activo ? 'var(--menta)' : 'var(--crema-12)', transition: 'background 0.2s',
            }}
          >
            <motion.span
              animate={{ x: activo ? 19 : 0 }}
              transition={{ type: 'spring', damping: 24, stiffness: 400 }}
              style={{ display: 'block', width: 21, height: 21, borderRadius: '50%', background: 'var(--crema)' }}
            />
          </span>
        </button>

        {/* Grupos de variantes */}
        <div>
          <span className="etiqueta-campo">Variantes / opciones</span>
          <p className="pequeno muy-tenue" style={{ margin: '0 0 10px 2px' }}>
            Ej.: «Base» con Cerveza o Soda, y dentro de cada una sus marcas.
            El «+» de precio es opcional.
          </p>
          <div className="apilado">
            {grupos.map((g, gi) => (
              <div className="tarjeta" key={g.id} style={{ background: 'var(--ciruela-600)', padding: 12 }}>
                <div className="horizontal" style={{ marginBottom: 8 }}>
                  <input
                    placeholder="Nombre del grupo (ej. Base, Sabor)"
                    value={g.nombre}
                    onChange={e => setGrupos(prev => prev.map((x, i) => i === gi ? { ...x, nombre: e.target.value } : x))}
                    style={{ fontWeight: 600 }}
                  />
                  <button
                    className="btn btn-peligro" style={{ padding: 10 }}
                    onClick={() => setGrupos(prev => prev.filter((_, i) => i !== gi))}
                  >
                    <Trash2 size={15} />
                  </button>
                </div>
                <EditorOpciones
                  opciones={g.opciones}
                  nivel={0}
                  alCambiar={ops => setGrupos(prev => prev.map((x, i) => i === gi ? { ...x, opciones: ops } : x))}
                />
                <button
                  className="chip chip-neutro" style={{ marginTop: 8 }}
                  onClick={() => setGrupos(prev => prev.map((x, i) =>
                    i === gi ? { ...x, opciones: [...x.opciones, opcionNueva()] } : x))}
                >
                  <Plus size={13} /> Opción
                </button>
              </div>
            ))}
            <button
              className="btn btn-fantasma btn-bloque"
              onClick={() => setGrupos(prev => [...prev, { id: idNuevo(), nombre: '', opciones: [opcionNueva()] }])}
            >
              <Plus size={16} /> Grupo de opciones
            </button>
          </div>
        </div>

        <button className="btn btn-primario btn-bloque" disabled={!valido} onClick={guardar}>
          Guardar producto
        </button>
        {producto?.id != null && (
          <button
            className="btn btn-peligro btn-bloque"
            onClick={async () => { await db.productos.delete(producto.id!); alCerrar() }}
          >
            <Trash2 size={16} /> Eliminar producto
          </button>
        )}
      </div>
    </Hoja>
  )
}

// Editor recursivo de opciones: cada opción puede tener sub-opciones.
function EditorOpciones({ opciones, nivel, alCambiar }: {
  opciones: OpcionVariante[]
  nivel: number
  alCambiar: (ops: OpcionVariante[]) => void
}) {
  return (
    <div className="apilado" style={{ gap: 6 }}>
      {opciones.map((op, i) => (
        <div key={op.id}>
          <div className="horizontal" style={{ marginLeft: nivel * 18 }}>
            {nivel > 0 && <CornerDownRight size={14} style={{ color: 'var(--crema-38)', flexShrink: 0 }} />}
            <input
              placeholder="Opción"
              value={op.nombre}
              onChange={e => alCambiar(opciones.map((x, j) => j === i ? { ...x, nombre: e.target.value } : x))}
              style={{ padding: '9px 11px' }}
            />
            <input
              className="mono"
              inputMode="decimal"
              placeholder="+0"
              value={op.delta ? String(op.delta) : ''}
              onChange={e => alCambiar(opciones.map((x, j) => j === i ? { ...x, delta: leerMonto(e.target.value) } : x))}
              style={{ width: 72, padding: '9px 10px', flexShrink: 0 }}
            />
            <button
              className="btn btn-fantasma" style={{ padding: 8, flexShrink: 0 }}
              title="Agregar sub-opción"
              onClick={() => alCambiar(opciones.map((x, j) =>
                j === i ? { ...x, hijas: [...(x.hijas ?? []), opcionNueva()] } : x))}
            >
              <CornerDownRight size={14} />
            </button>
            <button
              className="btn btn-fantasma" style={{ padding: 8, flexShrink: 0, color: 'var(--rojo)' }}
              onClick={() => alCambiar(opciones.filter((_, j) => j !== i))}
            >
              <X size={14} />
            </button>
          </div>
          {op.hijas && op.hijas.length > 0 && (
            <div style={{ marginTop: 6 }}>
              <EditorOpciones
                opciones={op.hijas}
                nivel={nivel + 1}
                alCambiar={hijas => alCambiar(opciones.map((x, j) => j === i ? { ...x, hijas } : x))}
              />
            </div>
          )}
        </div>
      ))}
    </div>
  )
}

function idNuevo(): string {
  return Math.random().toString(36).slice(2, 10)
}

function opcionNueva(): OpcionVariante {
  return { id: idNuevo(), nombre: '', delta: 0 }
}

// Un producto es válido si todos sus grupos tienen nombre y opciones con nombre.
function gruposValidos(grupos: GrupoVariante[]): boolean {
  const opcionesValidas = (ops: OpcionVariante[]): boolean =>
    ops.length > 0 && ops.every(o => o.nombre.trim().length > 0 && (!o.hijas || o.hijas.length === 0 || opcionesValidas(o.hijas)))
  return grupos.every(g => g.nombre.trim().length > 0 && opcionesValidas(g.opciones))
}

// Al guardar: recorta espacios y elimina ramas de hijas vacías.
function limpiarGrupos(grupos: GrupoVariante[]): GrupoVariante[] {
  const limpiarOps = (ops: OpcionVariante[]): OpcionVariante[] => ops.map(o => {
    const limpia: OpcionVariante = { id: o.id, nombre: o.nombre.trim(), delta: o.delta || 0 }
    if (o.hijas && o.hijas.length > 0) limpia.hijas = limpiarOps(o.hijas)
    return limpia
  })
  return grupos.map(g => ({ id: g.id, nombre: g.nombre.trim(), opciones: limpiarOps(g.opciones) }))
}
