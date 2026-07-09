// Revelado por scroll: cuando un elemento .revelar (o la franja del problema)
// entra al viewport, recibe la clase .visto y su transición CSS lo anima.

export function iniciarRevelado() {
  const objetivos = document.querySelectorAll('.revelar, .franja-problema')
  if (!('IntersectionObserver' in window)) {
    objetivos.forEach(el => el.classList.add('visto'))
    return
  }
  const observador = new IntersectionObserver(entradas => {
    for (const entrada of entradas) {
      if (entrada.isIntersecting) {
        entrada.target.classList.add('visto')
        observador.unobserve(entrada.target)
      }
    }
  }, { threshold: 0.2, rootMargin: '0px 0px -8% 0px' })
  objetivos.forEach(el => observador.observe(el))
}
