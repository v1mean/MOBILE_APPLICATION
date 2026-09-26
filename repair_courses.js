import { supabaseAdmin } from './backend/src/config/supabase.js';

async function repair() {
  const { data: courses } = await supabaseAdmin.from('courses').select('id, category, subject_id').is('subject_id', null);
  console.log('Courses to repair:', courses?.length);
  
  if (courses && courses.length > 0) {
    const { data: subjects } = await supabaseAdmin.from('Subjects').select('id, name');
    
    for (const c of courses) {
      if (!c.category) continue;
      const match = subjects.find(s => s.name.toLowerCase() === c.category.toLowerCase());
      if (match) {
        await supabaseAdmin.from('courses').update({ subject_id: match.id }).eq('id', c.id);
        console.log('Repaired course', c.id, 'with subject', match.name);
      } else {
        console.log('Could not find subject for category:', c.category);
      }
    }
  }
}
repair();
