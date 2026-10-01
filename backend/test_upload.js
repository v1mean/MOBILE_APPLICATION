import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import FormData from 'form-data';
import fetch from 'node-fetch';

const supabaseAdmin = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function test() {
  const { data: user, error: userError } = await supabaseAdmin.auth.admin.getUserById('da0edd07-253d-44c8-949e-40bfd6b8ed94'); // AnnRoseSandra

  // we need an access token. let's just bypass auth in a local copy of the route or create a mock token? 
  // actually, let's just inspect the backend logs if it's running. 
}
test();
