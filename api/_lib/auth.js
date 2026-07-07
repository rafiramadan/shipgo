// Shared session helpers — imported by both Node serverless functions (api/auth/*)
// and the Edge middleware (middleware.js). Kept dependency-free besides `jose` so it
// works unmodified in both runtimes. Prefixed folder (_lib) so Vercel does not expose
// this as its own API route.
import { SignJWT, jwtVerify } from 'jose';

export const SESSION_COOKIE = 'shipgo_session';
const SESSION_TTL = '12h';
const SESSION_MAX_AGE_SEC = 60 * 60 * 12;

function getSecretKey() {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    // Prototype fallback only — always set JWT_SECRET in the Vercel project's
    // Environment Variables before this goes anywhere near real users/data.
    console.warn('[auth] JWT_SECRET is not set — using an insecure development fallback.');
  }
  return new TextEncoder().encode(secret || 'dev-only-insecure-secret-do-not-use-in-production');
}

function isProdEnv() {
  return process.env.VERCEL_ENV === 'production' || process.env.NODE_ENV === 'production';
}

export async function signSession(payload) {
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(SESSION_TTL)
    .sign(getSecretKey());
}

export async function verifySession(token) {
  if (!token) return null;
  try {
    const { payload } = await jwtVerify(token, getSecretKey());
    return payload;
  } catch {
    return null;
  }
}

export function parseCookie(cookieHeader, name) {
  if (!cookieHeader) return null;
  for (const part of cookieHeader.split(';')) {
    const idx = part.indexOf('=');
    if (idx === -1) continue;
    if (part.slice(0, idx).trim() === name) return decodeURIComponent(part.slice(idx + 1).trim());
  }
  return null;
}

export function buildSessionCookie(token) {
  const attrs = [
    `${SESSION_COOKIE}=${encodeURIComponent(token)}`,
    'Path=/',
    'HttpOnly',
    'SameSite=Lax',
    `Max-Age=${SESSION_MAX_AGE_SEC}`,
  ];
  if (isProdEnv()) attrs.push('Secure');
  return attrs.join('; ');
}

export function buildClearCookie() {
  const attrs = [`${SESSION_COOKIE}=`, 'Path=/', 'HttpOnly', 'SameSite=Lax', 'Max-Age=0'];
  if (isProdEnv()) attrs.push('Secure');
  return attrs.join('; ');
}
