import { signSession, buildSessionCookie } from '../_lib/auth.js';

// Simple in-memory throttle to slow down PIN brute-forcing — a 6-digit PIN only has
// 1,000,000 combinations, so this matters more here than it would for a real password.
// Only FAILED attempts count toward the limit, and a successful login clears the
// counter, so a couple of mistyped digits can never lock out the correct PIN afterwards.
const attempts = new Map();
const MAX_ATTEMPTS = 8;
const WINDOW_MS = 5 * 60 * 1000;

function isThrottled(key) {
  const record = attempts.get(key);
  if (!record || Date.now() - record.first > WINDOW_MS) return false;
  return record.count >= MAX_ATTEMPTS;
}
function recordFailedAttempt(key) {
  const now = Date.now();
  const record = attempts.get(key);
  if (!record || now - record.first > WINDOW_MS) {
    attempts.set(key, { count: 1, first: now });
  } else {
    record.count += 1;
  }
}
function clearAttempts(key) {
  attempts.delete(key);
}

// Prototype-only shared access PIN — set SHIPGO_PIN in Vercel's Environment Variables
// to change it without a code change. Falls back to the documented demo PIN.
const SHIPGO_PIN = process.env.SHIPGO_PIN || '000000';

// Single shared identity for the session — this prototype no longer distinguishes
// individual accounts, so every PIN login represents the same platform user.
const SESSION_USER = { sub: 'shipgo-pin', name: 'Rafi Ramadani', role: 'Administrator', email: 'rafi.ramadani@paracorpgroup.com' };

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { pin } = req.body || {};
  if (!pin || typeof pin !== 'string') {
    return res.status(400).json({ error: 'PIN wajib diisi.' });
  }

  const normalizedPin = pin.trim();
  const throttleKey = req.headers['x-forwarded-for'] || req.socket?.remoteAddress || 'unknown';
  if (isThrottled(throttleKey)) {
    return res.status(429).json({ error: 'Terlalu banyak percobaan gagal. Coba lagi dalam beberapa menit.' });
  }

  if (normalizedPin !== SHIPGO_PIN) {
    recordFailedAttempt(throttleKey);
    return res.status(401).json({ error: 'PIN salah.' });
  }

  clearAttempts(throttleKey);
  const token = await signSession(SESSION_USER);
  res.setHeader('Set-Cookie', buildSessionCookie(token));
  return res.status(200).json({
    user: { name: SESSION_USER.name, role: SESSION_USER.role, email: SESSION_USER.email },
  });
}
