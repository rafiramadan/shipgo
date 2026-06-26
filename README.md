# ShipGo GPS Tracking Platform

Prototype platform GPS Tracking untuk ShipGo TMS — PT Parama Global Inspira.

## Halaman

| Halaman | File | URL |
|---------|------|-----|
| Dashboard | `index.html` | `/` |
| Live Tracking | `live-tracking.html` | `/live` |
| History Tracking | `history-tracking.html` | `/history` |
| Shipment Planning | `shipment-planning.html` | `/shipment` |

## Fitur

- **Live Tracking** — Peta OpenStreetMap real-time, cluster marker, popup Shipment & DO, tab Pesanan & Peringatan, sidebar expand/hover
- **History Tracking** — Route playback (1×–10×), geofence radius per drop point, event log, trip summary, driver performance score, export CSV/PDF/Excel
- **Shipment Planning** — Create planning, assign driver & fleet, route type Direct/Transit

## Tech Stack

- HTML5 + CSS3 + Vanilla JS (no build step)
- [Leaflet.js](https://leafletjs.com/) — peta interaktif
- [Leaflet MarkerCluster](https://github.com/Leaflet/Leaflet.markercluster) — cluster marker
- [OpenStreetMap](https://www.openstreetmap.org/) — tile provider
- [Font Awesome 6](https://fontawesome.com/) — icons
- [Google Fonts — Inter](https://fonts.google.com/specimen/Inter)

## Deploy ke Vercel

Sudah dikonfigurasi via `vercel.json`. Cukup connect repo ini ke Vercel.

## Struktur File

```
shipgo-gps/
├── index.html              ← Landing page / dashboard
├── live-tracking.html      ← Live Tracking
├── history-tracking.html   ← History Tracking
├── shipment-planning.html  ← Shipment Planning
├── vercel.json             ← Vercel routing config
└── README.md
```
