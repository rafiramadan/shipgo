import bcrypt from 'bcryptjs';
import { signSession, buildSessionCookie } from '../_lib/auth.js';
import { findUserByEmail } from '../_lib/users.js';

// Simple in-memory throttle to slow down brute-force guesses. Resets on cold start
// and isn't shared across serverless instances — a real deployment should back this
// with a shared store (e.g. Redis) instead.
const attempts = new Map();
const MAX_ATTEMPTS = 8;
const WINDOW_MS = 5 * 60 * 1000;

function tooManyAttempts(key) {
  const now = Date.now();
  const record = attempts.get(key);
  if (!record || now - record.first > WINDOW_MS) {
    attempts.set(key, { count: 1, first: now });
    return false;
  }
  record.count += 1;
  return record.count > MAX_ATTEMPTS;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, password } = req.body || {};
  if (!email || !password || typeof email !== 'string' || typeof password !== 'string') {
    return res.status(400).json({ error: 'Email dan password wajib diisi.' });
  }

  const normalizedEmail = email.trim().toLowerCase();
  const throttleKey = (req.headers['x-forwarded-for'] || req.socket?.remoteAddress || 'unknown') + ':' + normalizedEmail;
  if (tooManyAttempts(throttleKey)) {
    return res.status(429).json({ error: 'Terlalu banyak percobaan gagal. Coba lagi dalam beberapa menit.' });
  }

  const user = findUserByEmail(normalizedEmail);
  // Trim to absorb stray whitespace/newlines from copy-paste — these demo passwords
  // never intentionally contain leading/trailing spaces.
  const valid = user ? bcrypt.compareSync(password.trim(), user.passwordHash) : false;
  if (!valid) {
    return res.status(401).json({ error: 'Email atau password salah.' });
  }

  const token = await signSession({ sub: user.id, name: user.name, role: user.role, email: user.email });
  res.setHeader('Set-Cookie', buildSessionCookie(token));
  return res.status(200).json({ user: { name: user.name, role: user.role, email: user.email } });
}
