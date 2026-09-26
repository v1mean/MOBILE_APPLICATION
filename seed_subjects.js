import { supabaseAdmin } from './backend/src/config/supabase.js';

const missingSubjects = [
  'General', 'Khmer', 'English', 'Chinese', 'Spanish', 'Primary school',
  'Gym trainer', 'Volleyball coach', 'Football coach', 'Swimming coach',
  'Teaching driving', 'Badminton coach'
];

async function seed() {
  for (const name of missingSubjects) {
    const { data, error } = await supabaseAdmin.from('Subjects').insert([{ name }]).select();
    if (error) {
      console.log('Error adding', name, error.message);
    } else {
      console.log('Added', name, data[0].id);
    }
  }
}
seed();
