import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
// HashRouter: la app puede servirse desde cualquier subruta estática
// (ej. GitHub Pages en /antidescuadre/app/) sin reescrituras de servidor.
import { HashRouter } from 'react-router-dom'
import '@fontsource-variable/bricolage-grotesque/index.css'
import '@fontsource-variable/instrument-sans/index.css'
import '@fontsource/spline-sans-mono/400.css'
import '@fontsource/spline-sans-mono/500.css'
import '@fontsource/spline-sans-mono/700.css'
import './styles/global.css'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HashRouter>
      <App />
    </HashRouter>
  </StrictMode>,
)
