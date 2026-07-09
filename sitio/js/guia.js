// La comanda de instalación del APK: pasos que se marcan como "entregados".
// Al completarlos todos, cae el sello INSTALACIÓN SALDADA.

export const URL_APK =
  'https://github.com/TheWiche/antidescuadre/releases/latest/download/antidescuadre.apk'

const PASOS = [
  {
    t: 'Descarga el APK',
    d: 'Toca el botón de abajo. El archivo antidescuadre.apk queda en tus Descargas.',
    boton: true,
  },
  {
    t: 'Ábrelo desde la notificación de descarga',
    d: 'O búscalo en Archivos → Descargas y tócalo.',
  },
  {
    t: 'Permite «instalar apps desconocidas»',
    d: 'Android lo pide la primera vez porque el APK no viene de Play Store. Actívalo para AntiDescuadre y vuelve.',
  },
  {
    t: 'Toca «Instalar»',
    d: 'En un par de segundos queda junto a tus demás apps.',
  },
  {
    t: 'Ábrela e inicia tu turno',
    d: 'Pantalla completa, sin navegador, y funciona sin internet.',
  },
]

export function iniciarGuia() {
  const contenedor = document.getElementById('guia-pasos')
  const barra = document.getElementById('guia-barra')
  const estado = document.getElementById('guia-estado')
  const sello = document.getElementById('guia-sello')
  if (!contenedor) return

  const hechos = new Set()

  function actualizarProgreso() {
    barra.style.width = `${(hechos.size / PASOS.length) * 100}%`
    estado.textContent = `${hechos.size} de ${PASOS.length} pasos`
    const completo = hechos.size === PASOS.length
    if (completo && sello.hidden) {
      sello.hidden = false
      if (navigator.vibrate) navigator.vibrate(30)
    } else if (!completo) {
      sello.hidden = true
    }
  }

  PASOS.forEach((paso, i) => {
    const li = document.createElement('li')
    li.className = 'guia-paso'
    li.style.animationDelay = `${i * 70}ms`
    li.setAttribute('role', 'checkbox')
    li.setAttribute('aria-checked', 'false')
    li.tabIndex = 0
    li.innerHTML = `
      <span class="caja" aria-hidden="true">✓</span>
      <span class="paso-texto">
        <b>${i + 1}. ${paso.t}</b><span>${paso.d}</span>
        ${paso.boton ? `<a class="btn btn-ambar guia-descarga" href="${URL_APK}">⬇ Descargar APK</a>` : ''}
      </span>
    `
    const alternar = () => {
      hechos.has(i) ? hechos.delete(i) : hechos.add(i)
      li.classList.toggle('hecho', hechos.has(i))
      li.setAttribute('aria-checked', String(hechos.has(i)))
      actualizarProgreso()
    }
    li.addEventListener('click', e => {
      // No marcar el paso si lo que se tocó fue el botón de descarga
      if (e.target.closest('.guia-descarga')) return
      alternar()
    })
    li.addEventListener('keydown', e => {
      if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); alternar() }
    })
    contenedor.appendChild(li)
  })
  actualizarProgreso()
}
