import { Hoja } from './Hoja'

interface Props {
  abierta: boolean
  titulo: string
  detalle?: string
  textoConfirmar: string
  peligro?: boolean
  alConfirmar: () => void
  alCancelar: () => void
}

export function Confirmar({ abierta, titulo, detalle, textoConfirmar, peligro, alConfirmar, alCancelar }: Props) {
  return (
    <Hoja abierta={abierta} alCerrar={alCancelar}>
      <div className="hoja-titulo">{titulo}</div>
      {detalle && <p className="tenue" style={{ marginTop: -6 }}>{detalle}</p>}
      <div className="apilado" style={{ marginTop: 16 }}>
        <button
          className={`btn btn-bloque ${peligro ? 'btn-peligro' : 'btn-primario'}`}
          onClick={alConfirmar}
        >
          {textoConfirmar}
        </button>
        <button className="btn btn-fantasma btn-bloque" onClick={alCancelar}>Cancelar</button>
      </div>
    </Hoja>
  )
}
