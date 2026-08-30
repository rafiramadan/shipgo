// Shared Supabase client for pages doing real CRUD against the tables in
// supabase/schema.sql. Include AFTER the supabase-js CDN script and
// auth-guard.js:
//   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
//   <script src="/supabase-client.js"></script>
//
// The project URL/anon key are fetched from /api/config (backed by Vercel
// Environment Variables) rather than hardcoded here, so no real project
// credentials ever need to live in committed source — see api/config.js.
//
// getSupabaseClient() resolves to `null` when SUPABASE_URL/SUPABASE_ANON_KEY
// aren't set yet. Callers should treat that as "fall back to this page's
// built-in mock data" rather than throwing, so the prototype keeps working
// for anyone who hasn't provisioned a Supabase project yet.
let _shipgoSupabasePromise = null;

function getSupabaseClient() {
  if (_shipgoSupabasePromise) return _shipgoSupabasePromise;
  _shipgoSupabasePromise = (async () => {
    try {
      const res = await fetch('/api/config', { credentials: 'same-origin' });
      const { supabaseUrl, supabaseAnonKey } = await res.json();
      if (!supabaseUrl || !supabaseAnonKey) {
        console.warn('[shipgo] SUPABASE_URL / SUPABASE_ANON_KEY are not set — this page will use its built-in mock data instead of Supabase.');
        return null;
      }
      if (typeof window.supabase === 'undefined' || !window.supabase.createClient) {
        console.error('[shipgo] supabase-js did not load — check the CDN <script> tag.');
        return null;
      }
      return window.supabase.createClient(supabaseUrl, supabaseAnonKey);
    } catch (e) {
      console.error('[shipgo] Could not initialize the Supabase client:', e);
      return null;
    }
  })();
  return _shipgoSupabasePromise;
}
