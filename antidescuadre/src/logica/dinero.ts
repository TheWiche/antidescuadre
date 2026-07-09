// Manejo de dinero: sin moneda configurada (regla 11), formato $ con 2 decimales
// solo cuando hacen falta. Redondeo a centavos para evitar arrastres de flotantes.

export function redondear(n: number): number {
  return Math.round(n * 100) / 100
}

export function dinero(n: number): string {
  const r = redondear(n)
  const tieneCentavos = Math.abs(r % 1) > 0.004
  return '$' + r.toLocaleString('es', {
    minimumFractionDigits: tieneCentavos ? 2 : 0,
    maximumFractionDigits: 2,
  })
}

export function leerMonto(texto: string): number {
  const limpio = texto.replace(/[^0-9.,]/g, '').replace(',', '.')
  const n = parseFloat(limpio)
  return Number.isFinite(n) && n >= 0 ? redondear(n) : 0
}

export function horaCorta(epoch: number): string {
  return new Date(epoch).toLocaleTimeString('es', { hour: 'numeric', minute: '2-digit' })
}

export function fechaCorta(epoch: number): string {
  return new Date(epoch).toLocaleDateString('es', { weekday: 'short', day: 'numeric', month: 'short' })
}

export function fechaLarga(epoch: number): string {
  return new Date(epoch).toLocaleDateString('es', { day: 'numeric', month: 'long', year: 'numeric' })
}

export function minutosDesde(epoch: number, ahora: number = Date.now()): number {
  return Math.floor((ahora - epoch) / 60000)
}
