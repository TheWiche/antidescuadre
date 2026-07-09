import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useLiveQuery } from 'dexie-react-hooks'
import { ArrowLeft, Download, FileUp, Share2 } from 'lucide-react'
import { obtenerAjustes, guardarAjustes } from '../db/db'
import type { ConfigExportada } from '../db/tipos'
import {
  descargarArchivo, exportarConfiguracion, importarConfiguracion, validarConfiguracion,
} from '../logica/configuracion'
import { Confirmar } from '../componentes/Confirmar'

// Ajustes: nombre del negocio, alerta global de pedidos, y el corazón del
// multi-local: exportar/importar SOLO la configuración (nunca datos de turno).
export function Ajustes() {
  const navegar = useNavigate()
  const ajustes = useLiveQuery(() => obtenerAjustes(), [])
  const [nombre, setNombre] = useState<string | null>(null)
  const [minutos, setMinutos] = useState<string | null>(null)
  const [importando, setImportando] = useState<ConfigExportada | null>(null)
  const [aviso, setAviso] = useState('')
  const inputArchivo = useRef<HTMLInputElement>(null)

  useEffect(() => {
    if (ajustes && nombre === null) {
      setNombre(ajustes.nombreNegocio)
      setMinutos(String(ajustes.alertaMinutos))
    }
  }, [ajustes, nombre])

  function avisar(texto: string) {
    setAviso(texto)
    setTimeout(() => setAviso(''), 2400)
  }

  async function exportar(compartir: boolean) {
    const config = await exportarConfiguracion()
    const json = JSON.stringify(config, null, 2)
    const nombreArchivo = `antidescuadre-config-${new Date().toISOString().slice(0, 10)}.json`
    if (compartir && navigator.share && navigator.canShare?.({ files: [new File([json], nombreArchivo, { type: 'application/json' })] })) {
      try {
        await navigator.share({ files: [new File([json], nombreArchivo, { type: 'application/json' })], title: 'Configuración AntiDescuadre' })
        return
      } catch { /* cancelado: cae a descarga */ }
    }
    descargarArchivo(nombreArchivo, json)
    avisar('Configuración exportada')
  }

  return (
    <div className="pantalla">
      <div className="espaciado" style={{ marginBottom: 8 }}>
        <button className="btn btn-fantasma" style={{ padding: '10px 14px' }} onClick={() => navegar('/mas')}>
          <ArrowLeft size={18} />
        </button>
        <h1 style={{ fontSize: 21 }}>Ajustes</h1>
        <div style={{ width: 46 }} />
      </div>

      <div className="apilado">
        <div className="tarjeta apilado">
          <div>
            <span className="etiqueta-campo">Nombre del negocio</span>
            <input
              value={nombre ?? ''}
              onChange={e => setNombre(e.target.value)}
              onBlur={() => nombre?.trim() && guardarAjustes({ nombreNegocio: nombre.trim() })}
              placeholder="Mi bar"
            />
          </div>
          <div>
            <span className="etiqueta-campo">Alerta de pedidos sin entregar (minutos)</span>
            <input
              className="mono"
              inputMode="numeric"
              value={minutos ?? ''}
              onChange={e => setMinutos(e.target.value.replace(/\D/g, ''))}
              onBlur={() => {
                const n = parseInt(minutos ?? '', 10)
                if (Number.isFinite(n) && n > 0) guardarAjustes({ alertaMinutos: n })
              }}
            />
            <p className="pequeno muy-tenue" style={{ margin: '6px 2px 0' }}>
              Un solo valor global: pasado ese tiempo, el pedido se resalta en «Por entregar».
            </p>
          </div>
        </div>

        <div className="tarjeta apilado">
          <div>
            <h3 style={{ fontSize: 17, marginBottom: 4 }}>Configuración portátil</h3>
            <p className="pequeno tenue" style={{ margin: 0 }}>
              Exporta el catálogo, categorías, variantes, precios, alias de mesas y ajustes
              para replicarlos en otro dispositivo o local. <b>No incluye</b> ventas, turnos
              ni comprobantes.
            </p>
          </div>
          <div className="horizontal">
            <button className="btn btn-fantasma crece" onClick={() => exportar(false)}>
              <Download size={17} /> Exportar
            </button>
            <button className="btn btn-fantasma crece" onClick={() => exportar(true)}>
              <Share2 size={17} /> Compartir
            </button>
          </div>
          <button className="btn btn-primario btn-bloque" onClick={() => inputArchivo.current?.click()}>
            <FileUp size={17} /> Importar configuración
          </button>
          <input
            ref={inputArchivo}
            type="file"
            accept="application/json,.json"
            hidden
            onChange={async e => {
              const archivo = e.target.files?.[0]
              e.target.value = ''
              if (!archivo) return
              try {
                const config = validarConfiguracion(JSON.parse(await archivo.text()))
                if (!config) { avisar('El archivo no es una configuración válida'); return }
                setImportando(config)
              } catch {
                avisar('No se pudo leer el archivo')
              }
            }}
          />
        </div>

        <p className="pequeno muy-tenue centrado">
          AntiDescuadre · uso individual y offline · tus datos viven solo en este dispositivo
        </p>
      </div>

      <Confirmar
        abierta={importando !== null}
        titulo="¿Importar esta configuración?"
        detalle={importando
          ? `«${importando.nombreNegocio}» · ${importando.productos.length} productos, ${importando.categorias.length} categorías, ${importando.mesas.length} mesas. Reemplaza tu catálogo y mesas actuales; las ventas y turnos no se tocan.`
          : undefined}
        textoConfirmar="Importar y reemplazar"
        peligro
        alConfirmar={async () => {
          if (importando) {
            await importarConfiguracion(importando)
            setNombre(importando.nombreNegocio)
            setMinutos(String(importando.alertaMinutos))
            avisar('Configuración importada')
          }
          setImportando(null)
        }}
        alCancelar={() => setImportando(null)}
      />

      {aviso && (
        <div
          style={{
            position: 'fixed', bottom: 'calc(var(--tab-h) + var(--safe-b) + 18px)', left: 0, right: 0,
            display: 'flex', justifyContent: 'center', zIndex: 45, pointerEvents: 'none',
          }}
        >
          <span className="chip chip-menta" style={{ padding: '10px 18px', fontSize: 14 }}>{aviso}</span>
        </div>
      )}
    </div>
  )
}
