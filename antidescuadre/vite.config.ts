import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  // En GitHub Pages la app vive bajo /<repo>/app/; localmente queda en '/'
  base: process.env.BASE_URL ?? '/',
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['icono.svg'],
      manifest: {
        name: 'AntiDescuadre',
        short_name: 'AntiDescuadre',
        description: 'Ventas y cobros sin descuadres para tu bar',
        lang: 'es',
        display: 'standalone',
        orientation: 'portrait',
        background_color: '#221723',
        theme_color: '#221723',
        icons: [
          { src: 'icono.svg', sizes: 'any', type: 'image/svg+xml', purpose: 'any' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,woff2}'],
        maximumFileSizeToCacheInBytes: 4 * 1024 * 1024,
      },
    }),
  ],
  server: { host: true },
})
