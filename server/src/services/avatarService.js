import { supabaseAdmin } from '../config/supabase.js';
import { verifyFirebaseToken } from '../config/firebase.js';
import { query } from '../config/database.js';

let ensureTablePromise = null;

async function ensureAvatarTable() {
  if (ensureTablePromise) return ensureTablePromise;
  ensureTablePromise = (async () => {
    await query(`
      CREATE TABLE IF NOT EXISTS avatar_profiles (
        user_id TEXT PRIMARY KEY,
        config JSONB NOT NULL,
        updated_at TIMESTAMPTZ DEFAULT now()
      );
    `);
  })();
  return ensureTablePromise;
}

export async function getAvatarConfig(firebaseIdToken) {
  if (!firebaseIdToken) throw new Error('firebaseIdToken is required');

  const decoded = await verifyFirebaseToken(firebaseIdToken);
  await ensureAvatarTable();

  const { data, error } = await supabaseAdmin
    .from('avatar_profiles')
    .select('config')
    .eq('user_id', decoded.uid)
    .maybeSingle();

  if (error) throw new Error(error.message);
  return { userId: decoded.uid, config: data?.config ?? null };
}

export async function saveAvatarConfig(firebaseIdToken, config) {
  if (!firebaseIdToken) throw new Error('firebaseIdToken is required');
  if (!config) throw new Error('config is required');

  const decoded = await verifyFirebaseToken(firebaseIdToken);
  await ensureAvatarTable();

  const { error } = await supabaseAdmin.from('avatar_profiles').upsert({
    user_id: decoded.uid,
    config,
    updated_at: new Date().toISOString(),
  });

  if (error) throw new Error(error.message);
  return { userId: decoded.uid };
}
