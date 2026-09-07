import { createClient } from "@supabase/supabase-js";
import ws from "ws";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Load .env from backend directory, then fallback to MOBILE_APPLICATION directory
dotenv.config({ path: path.resolve(__dirname, "../../.env") });
dotenv.config({ path: path.resolve(__dirname, "../../../.env") });
dotenv.config();

const supabaseUrl =
  process.env.SUPABASE_URL || "https://wlyknabitdvynmfeqcuy.supabase.co";

const supabaseAnonKey =
  process.env.SUPABASE_ANON_KEY ||
  process.env.SUPABASE_PUBLISHABLE_KEY ||
  "sb_publishable_Caawyy6UyVUEGKAsCZKdaQ_TZSZjYtt";

const supabaseServiceRoleKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  process.env.SUPABASE_SERVICE_KEY ||
  supabaseAnonKey;

if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
  console.warn(
    "[Supabase] SUPABASE_SERVICE_ROLE_KEY is not set. Falling back to anon key for admin client."
  );
}

// Node.js 20 does not have native WebSocket support.
// Pass the 'ws' package as the transport so Supabase Realtime can connect.
const clientOptions = {
  global: { fetch },
  realtime: { transport: ws },
};

export const supabase = createClient(supabaseUrl, supabaseAnonKey, clientOptions);

export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey, {
  ...clientOptions,
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});
