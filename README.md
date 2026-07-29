# ShipGo GPS Tracking Platform

Prototype platform GPS Tracking untuk ShipGo TMS — PT Parama Global Inspira.

## Halaman

| Halaman | File | URL |
|---------|------|-----|
| Dashboard | `index.html` | `/` |
| Live Tracking | `live-tracking.html` | `/live` |
| History Tracking | `history-tracking.html` | `/history` |
| Shipment Planning | `shipment-planning.html` | `/shipment` |
| User & Access · Group / Role | `group-role.html` | `/roles` |
| User & Access · User Management | `user-management.html` | `/users` |
| Configuration · Feature Config | `feature-config.html` | `/config` |
| Master Data · Shipping Point | `shipping-point.html` | `/shipping-point` |
| Fleet · App Monitoring · Version Monitoring | `app-monitoring.html` | `/app-monitoring` |
| Fleet · App Monitoring · Driver App Version | `driver-app-version.html` | `/driver-app-version` |

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
- Vercel Serverless Functions + Edge Middleware — login/session backend (`api/`, `middleware.js`)
- [jose](https://github.com/panva/jose) — JWT signing/verification

## Autentikasi

Setiap halaman aplikasi dilindungi oleh Edge Middleware (`middleware.js`) — permintaan
tanpa sesi valid akan di-redirect ke `/login.html` sebelum HTML halaman terkirim.

- **Login page:** `login.html` — satu form PIN 6 digit, POST ke `/api/auth/login`
- **Akses:** PIN tunggal bersama (bukan per-user) — cocok untuk prototype yang dibagikan ke banyak reviewer tanpa perlu akun masing-masing. Default PIN: `000000`
- **Session cookie:** JWT (`jose`), disimpan sebagai cookie `HttpOnly`, `SameSite=Lax`, berlaku 12 jam
- **Rate limit:** maksimal 8 percobaan PIN salah per 5 menit per IP; percobaan berhasil mereset hitungannya

### Setup

1. Set environment variable `JWT_SECRET` di Vercel project settings (generate dengan `openssl rand -base64 48`). Lihat `.env.example`.
2. (Opsional) Set `SHIPGO_PIN` untuk mengganti PIN akses dari default `000000`.
3. `npm install` untuk dependency `jose`.

## Deploy ke Vercel

Sudah dikonfigurasi via `vercel.json` (rewrites + headers, kompatibel dengan Edge Middleware).
Cukup connect repo ini ke Vercel dan set `JWT_SECRET` di Environment Variables sebelum deploy pertama.

## Struktur File

```
shipgo-gps/
├── index.html              ← Landing page / dashboard
├── live-tracking.html      ← Live Tracking
├── history-tracking.html   ← History Tracking
├── shipment-planning.html  ← Shipment Planning
├── login.html              ← Login page
├── auth-guard.js           ← Client-side session check + topbar wiring (protected pages)
├── middleware.js           ← Edge Middleware — gates every protected page
├── api/
│   ├── _lib/auth.js        ← JWT sign/verify + cookie helpers (shared)
│   └── auth/
│       ├── login.js        ← POST — verify PIN, issue session cookie
│       ├── logout.js       ← POST — clear session cookie
│       └── session.js      ← GET — current session info
├── vercel.json             ← Vercel routing config
├── package.json            ← Backend dependencies (jose)
├── .env.example            ← Documents JWT_SECRET
└── README.md
```
