const fs = require('fs');
let file = 'lib/screens/teacher_schedules_screen.dart';
let content = fs.readFileSync(file, 'utf8');

const targetStr = `      final data = await JomnesDB
          .from('teacher_schedule_view')
          .select()
          .eq('tutor_id', session.user.id);`;

const replaceStr = `      final today = DateTime.now().toIso8601String().split('T')[0];
      final data = await JomnesDB
          .from('teacher_schedule_view')
          .select()
          .eq('tutor_id', session.user.id)
          .eq('booking_date', today);`;

content = content.replace(targetStr, replaceStr);
fs.writeFileSync(file, content);
