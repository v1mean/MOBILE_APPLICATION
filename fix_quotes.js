const fs = require('fs');
let file = 'lib/screens/teacher_schedules_screen.dart';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
  "child: Text('${booking['student_name']} (${booking['booking_date']?.toString().split('-').slice(1).join('/') ?? ''}) - Booked', style:",
  "child: Text('${booking['student_name']} (${booking['booking_date'] ?? ''}) - Booked', style:"
);

fs.writeFileSync(file, content);
