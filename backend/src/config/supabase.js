import { createClient } from "@supabase/supabase-js";
import ws from "ws";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

dotenv.config({ path: path.resolve(__dirname, "../../.env") });
dotenv.config({ path: path.resolve(__dirname, "../../../.env") });
dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;

const supabaseAnonKey =
  process.env.SUPABASE_ANON_KEY || process.env.SUPABASE_PUBLISHABLE_KEY;

const supabaseServiceRoleKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    "[Supabase] SUPABASE_URL and SUPABASE_ANON_KEY (or SUPABASE_PUBLISHABLE_KEY) must be set in .env"
  );
}

if (!supabaseServiceRoleKey) {
  throw new Error(
    "[Supabase] SUPABASE_SERVICE_ROLE_KEY is not set. Admin operations require the service role key."
  );
}

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
