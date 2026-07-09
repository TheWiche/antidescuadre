// La comanda de instalación: pestañas por plataforma y pasos que se marcan
// como "entregados". Al completarlos todos, cae el sello INSTALACIÓN SALDADA.

const PASOS = {
  android: {
    subtitulo: 'Android · Chrome',
    pasos: [
      { t: 'Abre la app en Chrome', d: 'Toca «Abrir la app» arriba, o escanea el enlace desde otro dispositivo.' },
      { t: 'Toca el menú ⋮ (arriba a la derecha)', d: 'El de los tres puntos, junto a la barra de dirección.' },
      { t: 'Elige «Agregar a pantalla de inicio» o «Instalar app»', d: 'Chrome a veces te lo ofrece solo con un aviso abajo: acéptalo y listo.' },
      { t: 'Confirma con «Instalar»', d: 'El ícono aparece junto a tus demás apps.' },
      { t: 'Ábrela desde el ícono', d: 'Pantalla completa, sin navegador, y funciona sin internet.' },
    ],
  },
  iphone: {
    subtitulo: 'iPhone / iPad · Safari',
    pasos: [
      { t: 'Abre la app en Safari', d: 'Importante: debe ser Safari, no Chrome ni el navegador de Instagram.' },
      { t: 'Toca el botón Compartir', d: 'El cuadrito con la flecha hacia arriba, en la barra de abajo.' },
      { t: 'Baja y elige «Agregar a inicio»', d: 'En la lista de acciones (Add to Home Screen).' },
      { t: 'Toca «Agregar»', d: 'El ícono queda en tu pantalla de inicio.' },
      { t: 'Ábrela desde el ícono', d: 'Se abre a pantalla completa, como cualquier app.' },
    ],
  },
  pc: {
    subtitulo: 'Computadora · Chrome o Edge',
    pasos: [
      { t: 'Abre la app en Chrome o Edge', d: 'Con el botón «Abrir la app» de esta página.' },
      { t: 'Busca el ícono de instalar en la barra de dirección', d: 'Un monitor con flecha (⊕), a la derecha de la URL.' },
      { t: 'Haz clic en «Instalar»', d: 'Se abre en su propia ventana, sin pestañas alrededor.' },
      { t: 'Ánclala si quieres', d: 'A la barra de tareas o al dock, como cualquier programa.' },
    ],
  },
}

export function iniciarGuia() {
  const contenedor = document.getElementById('guia-pasos')
  const subtitulo = document.getElementById('guia-subtitulo')
  const barra = document.getElementById('guia-barra')
  const estado = document.getElementById('guia-estado')
  const sello = document.getElementById('guia-sello')
  const pestanas = document.querySelectorAll('.guia-pestanas [role="tab"]')
  if (!contenedor) return

  let plataforma = detectarPlataforma()
  const hechos = new Map() // plataforma -> Set de índices

  function pintar() {
    const datos = PASOS[plataforma]
    subtitulo.textContent = datos.subtitulo
    contenedor.innerHTML = ''
    const marcados = hechos.get(plataforma) ?? new Set()

    datos.pasos.forEach((paso, i) => {
      const li = document.createElement('li')
      li.className = 'guia-paso' + (marcados.has(i) ? ' hecho' : '')
      li.style.animationDelay = `${i * 70}ms`
      li.setAttribute('role', 'checkbox')
      li.setAttribute('aria-checked', String(marcados.has(i)))
      li.tabIndex = 0
      li.innerHTML = `
        <span class="caja" aria-hidden="true">✓</span>
        <span class="paso-texto"><b>${i + 1}. ${paso.t}</b><span>${paso.d}</span></span>
      `
      const alternar = () => {
        const set = hechos.get(plataforma) ?? new Set()
        set.has(i) ? set.delete(i) : set.add(i)
        hechos.set(plataforma, set)
        li.classList.toggle('hecho', set.has(i))
        li.setAttribute('aria-checked', String(set.has(i)))
        actualizarProgreso()
      }
      li.addEventListener('click', alternar)
      li.addEventListener('keydown', e => {
        if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); alternar() }
      })
      contenedor.appendChild(li)
    })
    actualizarProgreso()
  }

  function actualizarProgreso() {
    const total = PASOS[plataforma].pasos.length
    const listos = (hechos.get(plataforma) ?? new Set()).size
    barra.style.width = `${(listos / total) * 100}%`
    estado.textContent = `${listos} de ${total} pasos`
    const completo = listos === total
    if (completo && sello.hidden) {
      sello.hidden = false
      if (navigator.vibrate) navigator.vibrate(30)
    } else if (!completo) {
      sello.hidden = true
    }
  }

  pestanas.forEach(tab => {
    tab.addEventListener('click', () => {
      plataforma = tab.dataset.plataforma
      pestanas.forEach(t => t.setAttribute('aria-selected', String(t === tab)))
      pintar()
    })
  })

  // Preseleccionar la pestaña del dispositivo del visitante
  pestanas.forEach(t => t.setAttribute('aria-selected', String(t.dataset.plataforma === plataforma)))
  pintar()
}

function detectarPlataforma() {
  const ua = navigator.userAgent
  if (/iPhone|iPad|iPod/i.test(ua)) return 'iphone'
  if (/Android/i.test(ua)) return 'android'
  return 'pc'
}
