// Supabase client configuration
// Used for optional real-time features, storage, and auth

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://trcmyrwxihgkmxnvhfqv.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || '';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

// Anon client - for frontend/public requests
export const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Service role client - for admin operations (use carefully!)
export const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// Supabase features available:
// - Real-time subscriptions
// - File storage
// - Authentication management
// - Functions (serverless)
// - Vector embeddings (for AI)

export default supabaseClient;
