import { verifySession, parseCookie, SESSION_COOKIE } from '../_lib/auth.js';

export default async function handler(req, res) {
  const token = parseCookie(req.headers.cookie, SESSION_COOKIE);
  const session = await verifySession(token);
  if (!session) return res.status(401).json({ authenticated: false });
  return res.status(200).json({
    authenticated: true,
    user: { name: session.name, role: session.role, email: session.email },
  });
}
