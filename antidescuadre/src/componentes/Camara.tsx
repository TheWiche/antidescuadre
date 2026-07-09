import { useEffect, useRef, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { Camera, Check, ImageUp, RotateCw, Undo2, X } from 'lucide-react'

interface Props {
  abierta: boolean
  titulo?: string
  alCapturar: (imagen: Blob) => void
  alCancelar: () => void
}

// Cámara de comprobantes: vista en vivo, capturar, rotar en pasos de 90°,
// repetir la toma y confirmar. Si el dispositivo no da acceso a la cámara
// del navegador, se usa la cámara nativa vía selector de archivo.
export function Camara({ abierta, titulo, alCapturar, alCancelar }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null)
  const streamRef = useRef<MediaStream | null>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const [sinCamara, setSinCamara] = useState(false)
  const [captura, setCaptura] = useState<HTMLCanvasElement | null>(null)
  const [rotacion, setRotacion] = useState(0)
  const [urlPrevia, setUrlPrevia] = useState<string | null>(null)

  useEffect(() => {
    if (!abierta) return
    let cancelado = false
    setCaptura(null)
    setRotacion(0)
    setSinCamara(false)
    navigator.mediaDevices?.getUserMedia({
      video: { facingMode: 'environment', width: { ideal: 1920 } },
      audio: false,
    }).then(stream => {
      if (cancelado) { stream.getTracks().forEach(t => t.stop()); return }
      streamRef.current = stream
      if (videoRef.current) videoRef.current.srcObject = stream
    }).catch(() => { if (!cancelado) setSinCamara(true) })
    return () => {
      cancelado = true
      streamRef.current?.getTracks().forEach(t => t.stop())
      streamRef.current = null
    }
  }, [abierta])

  // Regenerar la vista previa cuando cambia la captura o la rotación
  useEffect(() => {
    if (!captura) { setUrlPrevia(null); return }
    const girado = rotarCanvas(captura, rotacion)
    const url = girado.toDataURL('image/jpeg', 0.9)
    setUrlPrevia(url)
  }, [captura, rotacion])

  function tomarFoto() {
    const video = videoRef.current
    if (!video || video.videoWidth === 0) return
    const c = document.createElement('canvas')
    c.width = video.videoWidth
    c.height = video.videoHeight
    c.getContext('2d')!.drawImage(video, 0, 0)
    setCaptura(c)
    setRotacion(0)
  }

  function cargarArchivo(archivo: File) {
    const img = new Image()
    const url = URL.createObjectURL(archivo)
    img.onload = () => {
      const c = document.createElement('canvas')
      c.width = img.naturalWidth
      c.height = img.naturalHeight
      c.getContext('2d')!.drawImage(img, 0, 0)
      URL.revokeObjectURL(url)
      setCaptura(c)
      setRotacion(0)
    }
    img.src = url
  }

  function confirmar() {
    if (!captura) return
    rotarCanvas(captura, rotacion).toBlob(blob => {
      if (blob) alCapturar(blob)
    }, 'image/jpeg', 0.9)
  }

  return (
    <AnimatePresence>
      {abierta && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          style={{
            position: 'fixed', inset: 0, zIndex: 70, background: '#0c060d',
            display: 'flex', flexDirection: 'column',
          }}
        >
          <div className="espaciado" style={{ padding: '14px 16px' }}>
            <button className="btn btn-fantasma" style={{ padding: '10px 14px' }} onClick={alCancelar}>
              <X size={18} />
            </button>
            <div style={{ fontWeight: 700 }}>{titulo ?? 'Comprobante'}</div>
            <div style={{ width: 46 }} />
          </div>

          <div style={{ flex: 1, position: 'relative', overflow: 'hidden', margin: '0 12px', borderRadius: 20, background: '#000' }}>
            {captura && urlPrevia ? (
              <motion.img
                key={rotacion}
                src={urlPrevia}
                initial={{ scale: 0.96, opacity: 0.6 }}
                animate={{ scale: 1, opacity: 1 }}
                style={{ width: '100%', height: '100%', objectFit: 'contain' }}
              />
            ) : sinCamara ? (
              <div className="centrado" style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center', color: 'var(--crema-60)', padding: 24 }}>
                <div>
                  <Camera size={40} strokeWidth={1.5} style={{ marginBottom: 10 }} />
                  <div>Sin acceso a la cámara del navegador.</div>
                  <div className="pequeno muy-tenue">Usa el botón de abajo para abrir la cámara del teléfono.</div>
                </div>
              </div>
            ) : (
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              />
            )}
          </div>

          <div style={{ padding: '18px 16px calc(18px + var(--safe-b))' }}>
            {captura ? (
              <div className="horizontal" style={{ justifyContent: 'center', gap: 14 }}>
                <button className="btn btn-fantasma" onClick={() => { setCaptura(null); setRotacion(0) }}>
                  <Undo2 size={18} /> Repetir
                </button>
                <button className="btn btn-fantasma" onClick={() => setRotacion(r => (r + 90) % 360)}>
                  <RotateCw size={18} /> Rotar
                </button>
                <button className="btn btn-cian" onClick={confirmar}>
                  <Check size={18} /> Guardar
                </button>
              </div>
            ) : (
              <div className="horizontal" style={{ justifyContent: 'center', gap: 14 }}>
                <button className="btn btn-fantasma" onClick={() => inputRef.current?.click()}>
                  <ImageUp size={18} /> {sinCamara ? 'Abrir cámara / galería' : 'Galería'}
                </button>
                {!sinCamara && (
                  <motion.button
                    whileTap={{ scale: 0.88 }}
                    onClick={tomarFoto}
                    aria-label="Tomar foto"
                    style={{
                      width: 72, height: 72, borderRadius: '50%',
                      background: 'var(--crema)', border: '5px solid var(--crema-38)',
                    }}
                  />
                )}
              </div>
            )}
            <input
              ref={inputRef}
              type="file"
              accept="image/*"
              capture="environment"
              hidden
              onChange={e => {
                const archivo = e.target.files?.[0]
                if (archivo) cargarArchivo(archivo)
                e.target.value = ''
              }}
            />
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

function rotarCanvas(origen: HTMLCanvasElement, grados: number): HTMLCanvasElement {
  if (grados % 360 === 0) return origen
  const c = document.createElement('canvas')
  const vertical = grados % 180 !== 0
  c.width = vertical ? origen.height : origen.width
  c.height = vertical ? origen.width : origen.height
  const ctx = c.getContext('2d')!
  ctx.translate(c.width / 2, c.height / 2)
  ctx.rotate((grados * Math.PI) / 180)
  ctx.drawImage(origen, -origen.width / 2, -origen.height / 2)
  return c
}
