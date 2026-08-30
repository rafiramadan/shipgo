// Hands the browser the Supabase project URL + anon key so pages can talk to
// Supabase directly via supabase-js. Both values are safe to expose client
// side — Supabase's anon key is designed for this and access is enforced by
// the RLS policies in supabase/schema.sql, not by keeping the key secret.
// Serving them from an endpoint (rather than hardcoding into committed HTML)
// means the real values only ever live in Vercel's Environment Variables,
// the same place JWT_SECRET and SHIPGO_PIN already live.
export default async function handler(req, res) {
  res.setHeader('Cache-Control', 'no-store');
  return res.status(200).json({
    supabaseUrl: process.env.SUPABASE_URL || '',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY || '',
  });
}
