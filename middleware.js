// Vercel Edge Middleware — runs before any static page is served, so an
// unauthenticated request never even receives the protected HTML. This is the real
// access control; auth-guard.js on the client is just UX polish on top of it.
import { verifySession, parseCookie, SESSION_COOKIE } from './api/_lib/auth.js';

export const config = {
  matcher: [
    '/',
    '/index.html',
    '/live',
    '/live-tracking.html',
    '/history',
    '/history-tracking.html',
    '/shipment',
    '/shipment-planning.html',
    '/roles',
    '/group-role.html',
    '/users',
    '/user-management.html',
    '/config',
    '/feature-config.html',
    '/shipping-point',
    '/shipping-point.html',
    '/app-monitoring',
    '/app-monitoring.html',
    '/driver-app-version',
    '/driver-app-version.html',
  ],
};

export default async function middleware(request) {
  const token = parseCookie(request.headers.get('cookie'), SESSION_COOKIE);
  const session = await verifySession(token);
  if (session) return; // valid session — let the request through untouched

  const url = new URL(request.url);
  const loginUrl = new URL('/login.html', url.origin);
  loginUrl.searchParams.set('next', url.pathname);

  // This redirect decision depends on the caller's session cookie, so it must never be
  // cached by a shared/edge cache — otherwise one unauthenticated hit on a path can get
  // cached and replayed as a forced login redirect to every later visitor of that same
  // path, even ones with a perfectly valid session.
  const response = Response.redirect(loginUrl, 307);
  response.headers.set('Cache-Control', 'no-store');
  return response;
}
