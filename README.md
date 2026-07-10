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
- [jose](https://github.com/panva/jose) — JWT signing/verification, [bcryptjs](https://github.com/dcodeIO/bcrypt.js) — password hashing

## Autentikasi

Setiap halaman (`/`, `/live`, `/history`, `/shipment`) dilindungi oleh Edge Middleware
(`middleware.js`) — permintaan tanpa sesi valid akan di-redirect ke `/login.html`
sebelum HTML halaman terkirim.

- **Login page:** `login.html` — POST ke `/api/auth/login`
- **Session cookie:** JWT (`jose`), disimpan sebagai cookie `HttpOnly`, `SameSite=Lax`, berlaku 12 jam
- **User store (prototype):** `api/_lib/users.js` — daftar user hardcoded dengan password ter-hash bcrypt (belum pakai database sungguhan, konsisten dengan data trip/DO lain di app ini). Kredensial akun tidak didokumentasikan di sini — simpan secara terpisah (mis. password manager).

### Setup

1. Set environment variable `JWT_SECRET` di Vercel project settings (generate dengan `openssl rand -base64 48`). Lihat `.env.example`.
2. `npm install` untuk dependency `jose` dan `bcryptjs`.
3. Untuk menambah/ubah user: hash password baru dengan `bcryptjs`, lalu tambahkan ke `api/_lib/users.js`.

Sebelum menambahkan user sungguhan, migrasikan `api/_lib/users.js` ke database asli — file
hardcoded ini hanya cocok untuk prototype/demo.

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
│   ├── _lib/users.js       ← Prototype user store (bcrypt-hashed passwords)
│   └── auth/
│       ├── login.js        ← POST — verify credentials, issue session cookie
│       ├── logout.js       ← POST — clear session cookie
│       └── session.js      ← GET — current session info
├── vercel.json             ← Vercel routing config
├── package.json            ← Backend dependencies (jose, bcryptjs)
├── .env.example            ← Documents JWT_SECRET
└── README.md
```
