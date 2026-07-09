// La impresora del hero: imprime un ticket de ejemplo línea por línea,
// con ritmo de impresora térmica real (ráfagas + pausas entre tandas).

const GUION = [
  { tipo: 'titulo', texto: 'MI BAR' },
  { tipo: 'meta', texto: 'La de la ventana · viernes' },
  { tipo: 'hr' },
  { tipo: 'meta', texto: '— 8:14 pm —' },
  { tipo: 'linea', izq: '3× Cerveza', der: '$7,50' },
  { tipo: 'linea', izq: '1× Michelada · Corona', der: '$3,50' },
  { tipo: 'meta', texto: '— 9:02 pm —' },
  { tipo: 'linea', izq: '2× Alitas BBQ', der: '$9' },
  { tipo: 'linea', izq: '3× Cerveza', der: '$7,50' },
  { tipo: 'hr' },
  { tipo: 'total', izq: 'TOTAL', der: '$27,50' },
  { tipo: 'linea', izq: 'efectivo', der: '$14' },
  { tipo: 'linea', izq: 'transferencia ✓ legalizada', der: '$13,50' },
  { tipo: 'hr' },
  { tipo: 'exito', texto: 'DESCUADRE: $0,00' },
  { tipo: 'meta', texto: '¡gracias por venir!' },
]

const PAUSAS = { titulo: 320, meta: 260, hr: 180, linea: 210, total: 380, exito: 500 }

function crearNodo(linea) {
  if (linea.tipo === 'hr') {
    const hr = document.createElement('hr')
    hr.className = 'ticket-hr'
    return hr
  }
  const div = document.createElement('div')
  if (linea.tipo === 'titulo') { div.className = 'ticket-titulo'; div.style.textAlign = 'center'; div.textContent = linea.texto }
  else if (linea.tipo === 'meta') { div.className = 'ticket-meta'; div.style.textAlign = 'center'; div.textContent = linea.texto }
  else if (linea.tipo === 'exito') { div.className = 'exito'; div.style.textAlign = 'center'; div.textContent = linea.texto }
  else {
    div.className = linea.tipo === 'total' ? 'ticket-total' : 'ticket-linea'
    const a = document.createElement('span')
    const b = document.createElement('span')
    a.textContent = linea.izq
    b.textContent = linea.der
    div.append(a, b)
  }
  div.style.animation = 'imprimir-linea 0.3s cubic-bezier(0.2, 1, 0.3, 1) both'
  return div
}

export function iniciarImpresora() {
  const ticket = document.getElementById('ticket-hero')
  if (!ticket) return

  const reducido = matchMedia('(prefers-reduced-motion: reduce)').matches
  if (reducido) {
    for (const linea of GUION) ticket.appendChild(crearNodo(linea))
    return
  }

  const cursor = document.createElement('span')
  cursor.className = 'cursor'
  ticket.appendChild(cursor)

  let i = 0
  const imprimir = () => {
    if (i >= GUION.length) {
      cursor.remove()
      ticket.classList.add('impreso')
      return
    }
    const linea = GUION[i++]
    ticket.insertBefore(crearNodo(linea), cursor)
    setTimeout(imprimir, PAUSAS[linea.tipo] ?? 220)
  }
  setTimeout(imprimir, 500)
}
